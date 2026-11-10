#!/usr/bin/env bash
# СРЕЗ «где мы по плану» из ОПУБЛИКОВАННОГО origin/main (контракт 182, Н-439).
#
# Боль, которую закрывает: после перезагрузки сессии исчез /tmp, HANDOFF отстал
# от origin/main, и владельцу доложили устаревшее «ЖДЁТ УТРА» вместо реального
# состояния ROADMAP. Срез читает ПУБЛИКОВАННОЕ дерево и опубликованные теги —
# рабочее дерево и проза HANDOFF не являются источником статуса.
#
# Вход:
#   bash scripts/orch_plan_slice.sh --repo <абсолютный путь к git-репозиторию>
#   (без --repo — корень собственного git-репозитория скрипта).
#
# Вывод (stdout, построчно):
#   PLAN_SNAPSHOT: origin/main=<полный SHA>
#   PLAN: <id> | ROADMAP=<пара>/<этап> | STATUS=<...> | NEXT=<...>
#   … по одной строке на строку registry/plan.tsv, в порядке plan.tsv.
#
# Источники (только опубликованные; всё читается через `git show <sha>:<путь>`):
#   registry/plan.tsv      — id/пара/этап/зависит/источник/трек (шесть полей);
#   ROADMAP.md             — generated-блок: пара/id/этап/трек/зависит/источник;
#   registry/contracts.tsv — реестр выдачи (числовой id обязан быть зарегистрирован);
#   registry/pauzy.tsv     — санкционированные паузы (условие возврата — дословно);
#   remote-теги origin     — frozen/contracts/<id>/<v> и done/contracts/<id>/<v>;
#                            тег подтверждает статус, только если ОПУБЛИКОВАН (ls-remote)
#                            и указывает на предка origin/main.
#
# Статус (приоритет по инварианту 2): done > ПАУЗА > frozen > черновик.
# Единственный допустимый маркер ожидания в выдаче — санкционированная ПАУЗА;
# строка «ЖДЁТ …» из HANDOFF в срез не попадает (её источник — архив решений).
#
# Коды возврата:
#   0 — срез напечатан;
#   1 — именованный отказ, stdout ПУСТ (ни одной вводящей в заблуждение строки):
#       PLAN_SOURCE_UNAVAILABLE — нет обязательного источника на origin/main;
#       PLAN_ROADMAP_RASHOZHDENIE — plan.tsv расходится с generated-блоком ROADMAP;
#   2 — нечем проверить (usage / NOT_IMPLEMENTED).

set -uo pipefail

# Канон станции: детерминированная локаль для разбора UTF-8 (прецедент
# scripts/check_provodka.sh). Гигиена Н-85: снять чужие GIT_* — иначе CLI судит
# не тот репозиторий (прецедент scripts/orch_restart.sh).
export LC_ALL=C.UTF-8
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES

die()  { printf '%s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

usage() { printf 'ИСПОЛЬЗОВАНИЕ: bash %s --repo <абсолютный путь к git-репозиторию>\n' "${0##*/}"; }

repo=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      [ "$#" -gt 1 ] || { usage >&2; skip "неверный вызов: --repo требует путь"; }
      repo="$2"; shift 2 ;;
    --repo=*) repo="${1#--repo=}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; skip "неверный вызов: неизвестный аргумент" ;;
  esac
done

SELF_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)" \
  || die "PLAN_SOURCE_UNAVAILABLE: не найден каталог скрипта"
if [ -z "$repo" ]; then
  repo="$(git -C "$SELF_DIR" rev-parse --show-toplevel 2>/dev/null)" \
    || die "PLAN_SOURCE_UNAVAILABLE: не указан --repo, а корень скрипта не git-репозиторий"
fi
[ -d "$repo" ] || die "PLAN_SOURCE_UNAVAILABLE: нет каталога: $repo"

# ── снятый SHA published origin/main ──────────────────────────────────────────
sha="$(git -C "$repo" rev-parse --verify origin/main 2>/dev/null)" \
  || die "PLAN_SOURCE_UNAVAILABLE: нет опубликованной ветки origin/main в $repo"
case "$sha" in
  *[!0-9a-f]*|'') die "PLAN_SOURCE_UNAVAILABLE: origin/main не читается как коммит: $repo" ;;
esac
[ "${#sha}" -ge 40 ] || die "PLAN_SOURCE_UNAVAILABLE: origin/main не полный SHA: $sha"

# ── обязательные источники: только блобы снятого SHA ──────────────────────────
plan_blob="$(git -C "$repo" show "$sha:registry/plan.tsv" 2>/dev/null)" \
  || die "PLAN_SOURCE_UNAVAILABLE: нет registry/plan.tsv на origin/main=$sha"
roadmap_blob="$(git -C "$repo" show "$sha:ROADMAP.md" 2>/dev/null)" \
  || die "PLAN_SOURCE_UNAVAILABLE: нет ROADMAP.md на origin/main=$sha"
pauzy_blob="$(git -C "$repo" show "$sha:registry/pauzy.tsv" 2>/dev/null)" \
  || die "PLAN_SOURCE_UNAVAILABLE: нет registry/pauzy.tsv на origin/main=$sha"
contracts_blob="$(git -C "$repo" show "$sha:registry/contracts.tsv" 2>/dev/null)" \
  || die "PLAN_SOURCE_UNAVAILABLE: нет registry/contracts.tsv на origin/main=$sha"

# ── ROADMAP: карта id → (пара, этап, трек, зависит) ───────────────────────────
# При наличии маркеров generated-блока берётся ОН (источник порядка плана);
# без маркеров — все строки файла. Ячейка: пара|id|этап|трек|зависит|источник.
roadmap_map="$(printf '%s\n' "$roadmap_blob" | awk '
  BEGIN { inblock = 0; seen = 0 }
  /BEGIN GENERATED PLAN/ { inblock = 1; seen = 1; next }
  /END GENERATED PLAN/   { inblock = 0; next }
  {
    if (seen && !inblock) next
    n = split($0, parts, "[|]")   # «|» — литерал: одиночный «|» как regex пуст
    if (n != 8) next
    # Ячейка = parts[2..7]: awk нумерует split с 1, пустая левая «|» — parts[1].
    for (j = 1; j <= 6; j++) {
      v = parts[j + 1]
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      fld[j] = v
    }
    if (fld[1] ~ /^[0-9]+$/) printf "%s\t%s\t%s\t%s\t%s\n", fld[2], fld[1], fld[3], fld[4], fld[5]
  }')"

# ── реестр выдачи: числовой id обязан быть зарегистрирован ───────────────────
registered_list="$(printf '%s\n' "$contracts_blob" | awk '
  index($0, " → ") > 0 { print substr($0, 1, index($0, " → ") - 1) }')"

# ── санкционированные паузы: условие возврата — дословно ─────────────────────
pause_list="$(printf '%s\n' "$pauzy_blob" | awk -F'\t' '
  NF >= 4 && substr($0, 1, 1) != "#" { print $1 "\t" $4 }')"

# ── опубликованные теги: ls-remote (не локальные) + предок origin/main ────────
tags_out="$(git -C "$repo" ls-remote --tags origin \
  'refs/tags/frozen/contracts/*' 'refs/tags/done/contracts/*' 2>/dev/null)" \
  || die "PLAN_SOURCE_UNAVAILABLE: не читаются опубликованные теги origin в $repo"
ancestors="$(git -C "$repo" rev-list "$sha" 2>/dev/null)" \
  || die "PLAN_SOURCE_UNAVAILABLE: не читается история origin/main=$sha"

declare -A anc=()
while IFS= read -r c; do
  [ -n "$c" ] && anc["$c"]=1
done <<< "$ancestors"

done_refs=""
frozen_refs=""
while IFS= read -r line; do
  [ -n "$line" ] || continue
  target="${line%%$'\t'*}"
  ref="${line#*$'\t'}"
  case "$ref" in
    *'^{}') ref="${ref%'^{}'}" ;;
  esac
  [ -n "${anc[$target]:-}" ] || continue   # тег вне истории origin/main не подтверждает статус
  case "$ref" in
    refs/tags/done/contracts/*)   done_refs+="$ref"$'\n' ;;
    refs/tags/frozen/contracts/*) frozen_refs+="$ref"$'\n' ;;
  esac
done <<< "$tags_out"

# ── сборка среза ──────────────────────────────────────────────────────────────
# Порядок потоков: карта ROADMAP, реестр выдачи, done-теги, frozen-теги, паузы,
# строки plan.tsv. Строки печатаются ТОЛЬКО в END — при отказе stdout пуст.
slice="$(awk -v sha="$sha" '
  function fail(why, ident) {
    if (failed) return
    failed = 1
    msg = "PLAN_ROADMAP_RASHOZHDENIE: " why
    if (ident != "") msg = msg ": " ident
    print msg > "/dev/stderr"
    exit 1
  }
  BEGIN { FS = "\t"; nout = 0 }
  FILENAME == ARGV[1] { rmap[$1] = $2 "\t" $3 "\t" $4 "\t" $5; next }
  FILENAME == ARGV[2] { if (length($0)) reg[$0] = 1; next }
  FILENAME == ARGV[3] { if (length($0)) doneref[$0] = 1; next }
  FILENAME == ARGV[4] { if (length($0)) frzref[$0] = 1; next }
  FILENAME == ARGV[5] { if (length($0)) pause[$1] = $2; next }
  FILENAME == ARGV[6] {
    line = $0
    if (line == "") next
    if (substr(line, 1, 1) == "#") next
    if (substr(line, 1, 3) == "id\t") next
    n = split(line, f, "\t")
    if (n != 6) fail("нет строки ROADMAP/registry", "")
    id = f[1]; wave = f[2]; stage = f[3]; deps = f[4]; track = f[6]
    if (!(id in rmap)) fail("нет строки ROADMAP/registry", "")
    split(rmap[id], r, "\t")
    if (r[1] != wave || r[2] != stage || r[3] != track || r[4] != deps)
      fail("plan.tsv расходится с generated-блоком ROADMAP", id)
    if (id ~ /^[0-9]+$/ && !(id in reg)) fail("нет строки ROADMAP/registry", "")
    dpref = "refs/tags/done/contracts/" id "/"
    fpref = "refs/tags/frozen/contracts/" id "/"
    isdone = 0; isfrozen = 0
    for (ref in doneref) if (substr(ref, 1, length(dpref)) == dpref) { isdone = 1; break }
    for (ref in frzref) if (substr(ref, 1, length(fpref)) == fpref) { isfrozen = 1; break }
    if (isdone) {
      status = "done"; nxt = "закрыто"
    } else if (id in pause) {
      status = "ПАУЗА"; nxt = pause[id]
    } else if (isfrozen) {
      status = "frozen"; nxt = "сверить PR/вердикт, затем done"
    } else {
      status = "черновик"; nxt = "контракт → critic → freeze"
    }
    out[++nout] = "PLAN: " id " | ROADMAP=" wave "/" stage " | STATUS=" status " | NEXT=" nxt
  }
  END {
    if (failed) exit 1
    print "PLAN_SNAPSHOT: origin/main=" sha
    for (i = 1; i <= nout; i++) print out[i]
  }' \
  <(printf '%s\n' "$roadmap_map") \
  <(printf '%s\n' "$registered_list") \
  <(printf '%s\n' "$done_refs") \
  <(printf '%s\n' "$frozen_refs") \
  <(printf '%s\n' "$pause_list") \
  <(printf '%s\n' "$plan_blob"))" \
  || die "PLAN_ROADMAP_RASHOZHDENIE: plan.tsv расходится с generated-блоком ROADMAP на origin/main=$sha"

printf '%s\n' "$slice"
