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
# ДВА РЕЖИМА (контракт 182 v2, И-5/И-6):
#   Станционный — маркера harness.project.json на снятом SHA нет: пути и сообщения
#   побайтово как в v1, резолвер и jq не требуются.
#   Проектный — маркер ОПУБЛИКОВАН (`git cat-file -e <sha>:harness.project.json`):
#   пути источников — из ЕДИНОГО резолвера 996 `project_paths_resolve` (next_id.sh):
#   план `<registry>/plan.tsv`, ROADMAP `<roadmap>`, паузы `<registry>/pauzy.tsv`
#   (ОПЦИОНАЛЬНЫ — их отсутствие есть пустое множество пауз, не отказ), реестр выдачи
#   `<registry>/contracts.tsv`. Корневая станционная раскладка в проектном режиме НЕ
#   читается: опубликованная приманка — ловушка, а не источник. Живой корень без
#   маркера при опубликованном маркере — рассинхрон и ИМЕНОВАННЫЙ отказ; отказ
#   правдив: stdout пуст, stderr начинается с
#   `PLAN_SOURCE_UNAVAILABLE: проектный режим (harness.project.json на origin/main=<sha>):`
#   и называет причину с профильным путём и названный выход.
#
# Статус (приоритет по инварианту 2): done > ПАУЗА > frozen > черновик.
# Единственный допустимый маркер ожидания в выдаче — санкционированная ПАУЗА;
# строка «ЖДЁТ …» из HANDOFF в срез не попадает (её источник — архив решений).
#
# Коды возврата:
#   0 — срез напечатан;
#   1 — именованный отказ, stdout ПУСТ (ни одной вводящей в заблуждение строки):
#       PLAN_SOURCE_UNAVAILABLE — нет обязательного источника на origin/main;
#       PLAN_ROADMAP_RASHOZHDENIE — generated-блок ROADMAP отсутствует или повреждён
#       либо plan.tsv расходится с этим блоком;
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
repo_abs="$(cd -- "$repo" && pwd -P)" \
  || die "PLAN_SOURCE_UNAVAILABLE: не разрешён корень: $repo"

# ── снятый SHA published origin/main ──────────────────────────────────────────
sha="$(git -C "$repo" rev-parse --verify origin/main 2>/dev/null)" \
  || die "PLAN_SOURCE_UNAVAILABLE: нет опубликованной ветки origin/main в $repo"
case "$sha" in
  *[!0-9a-f]*|'') die "PLAN_SOURCE_UNAVAILABLE: origin/main не читается как коммит: $repo" ;;
esac
[ "${#sha}" -ge 40 ] || die "PLAN_SOURCE_UNAVAILABLE: origin/main не полный SHA: $sha"

# ── РЕЖИМ ИСТОЧНИКА: маркер опубликованного дерева (И-5) ─────────────────────
# Проектный режим — по НАЛИЧИЮ harness.project.json на СНЯТОМ SHA (опубликованное
# дерево), а не по живому корню: опубликованный маркер без живого — рассинхрон
# (именованный отказ), а не повод вернуться к станционной корневой раскладке.
mode="station"
if git -C "$repo" cat-file -e "$sha:harness.project.json" 2>/dev/null; then
  mode="project"
fi

# Пути источников: станционная раскладка по умолчанию; в проектном режиме — из
# ЕДИНОГО резолвера 996 (project_paths_resolve, scripts/next_id.sh): свой разбор
# workflowPaths был бы вторым резолвером и разошёлся бы с остальными дверями.
plan_rel="registry/plan.tsv"
roadmap_rel="ROADMAP.md"
pauzy_rel="registry/pauzy.tsv"
contracts_rel="registry/contracts.tsv"

if [ "$mode" = "project" ]; then
  prefix="PLAN_SOURCE_UNAVAILABLE: проектный режим (harness.project.json на origin/main=$sha):"
  # Живой корень: маркер опубликован, а в корне его нет — рассинхрон (И-6).
  [ -f "$repo_abs/harness.project.json" ] \
    || die "$prefix живой корень без harness.project.json — опубликованный и живой профиль расходятся; выход: синхронизировать корень (fetch/checkout), станционная раскладка не подменяется"
  # Резолвер — ЕДИНЫЙ (996 Б-5/Б-9). jq и библиотека нужны ТОЛЬКО здесь: в
  # станционном режиме они не требуются (И-5).
  NEXT_ID_LIB=1
  # shellcheck disable=SC1091
  . "$SELF_DIR/next_id.sh" \
    || die "$prefix резолвер путей профиля недоступен; выход: починить профиль проекта (996)"
  [ "$(type -t project_paths_resolve)" = "function" ] \
    || die "$prefix резолвер путей профиля недоступен; выход: починить профиль проекта (996)"
  # ОДИН вызов резолвера: stdout (JSON) и stderr сходятся в одну переменную —
  # при отказе причина не нужна (названный выход ниже), при успехе stdout — JSON.
  ppr_out="$(HARNESS_PROJECT_LAYER_ROOT="$repo_abs" project_paths_resolve "$repo_abs" 2>&1)"
  ppr_rc=$?
  if [ "$ppr_rc" -ne 0 ]; then
    ppr_reason="$(printf '%s' "$ppr_out" | tr '\n' ' ')"
    die "$prefix профиль не разрешается (${ppr_reason:-workflowPaths вне репо}); выход: починить профиль проекта (996)"
  fi
  reg_abs="$(printf '%s' "$ppr_out" | jq -r '.registry // empty' 2>/dev/null)"
  road_abs="$(printf '%s' "$ppr_out" | jq -r '.roadmap // empty' 2>/dev/null)"
  if [ -z "$reg_abs" ] || [ -z "$road_abs" ]; then
    die "$prefix профиль не разрешается (пустые пути профиля); выход: починить профиль проекта (996)"
  fi
  # Абсолютные пути резолвера → относительная форма внутри R (публикуемые пути).
  rel_inside() {
    case "$1" in
      "$repo_abs") printf '%s' '' ;;
      "$repo_abs"/*) printf '%s' "${1#"$repo_abs"/}" ;;
      *) return 1 ;;
    esac
  }
  reg_rel="$(rel_inside "$reg_abs")" \
    || die "$prefix путь реестра вне корня; выход: починить профиль проекта (996)"
  road_rel="$(rel_inside "$road_abs")" \
    || die "$prefix путь ROADMAP вне корня; выход: починить профиль проекта (996)"
  if [ "$reg_rel" = "." ]; then reg_rel=""; fi
  if [ "$road_rel" = "." ]; then road_rel=""; fi
  if [ -n "$reg_rel" ]; then
    plan_rel="$reg_rel/plan.tsv"
    contracts_rel="$reg_rel/contracts.tsv"
    pauzy_rel="$reg_rel/pauzy.tsv"
  else
    plan_rel="plan.tsv"
    contracts_rel="contracts.tsv"
    pauzy_rel="pauzy.tsv"
  fi
  roadmap_rel="${road_rel:-ROADMAP.md}"
fi

# ── обязательные источники: только блобы снятого SHA ──────────────────────────
if [ "$mode" = "project" ]; then
  # Профильные паузы ОПЦИОНАЛЬНЫ (И-8): их отсутствие — пустое множество пауз,
  # а не отказ. Остальные источники обязательны.
  plan_blob="$(git -C "$repo" show "$sha:$plan_rel" 2>/dev/null)" \
    || die "$prefix нет $plan_rel на origin/main=$sha; станционный корневой реестр не подменяет; выход: план проекта заводит владелец коммитом в $plan_rel (996)"
  roadmap_blob="$(git -C "$repo" show "$sha:$roadmap_rel" 2>/dev/null)" \
    || die "$prefix нет $roadmap_rel на origin/main=$sha; выход: ROADMAP проекта заводит владелец коммитом в $roadmap_rel (996)"
  contracts_blob="$(git -C "$repo" show "$sha:$contracts_rel" 2>/dev/null)" \
    || die "$prefix нет $contracts_rel на origin/main=$sha; выход: реестр выдачи проекта заводит владелец коммитом в $contracts_rel (996)"
  pauzy_blob="$(git -C "$repo" show "$sha:$pauzy_rel" 2>/dev/null)" || pauzy_blob=""
else
  plan_blob="$(git -C "$repo" show "$sha:$plan_rel" 2>/dev/null)" \
    || die "PLAN_SOURCE_UNAVAILABLE: нет $plan_rel на origin/main=$sha"
  roadmap_blob="$(git -C "$repo" show "$sha:$roadmap_rel" 2>/dev/null)" \
    || die "PLAN_SOURCE_UNAVAILABLE: нет $roadmap_rel на origin/main=$sha"
  pauzy_blob="$(git -C "$repo" show "$sha:$pauzy_rel" 2>/dev/null)" \
    || die "PLAN_SOURCE_UNAVAILABLE: нет $pauzy_rel на origin/main=$sha"
  contracts_blob="$(git -C "$repo" show "$sha:$contracts_rel" 2>/dev/null)" \
    || die "PLAN_SOURCE_UNAVAILABLE: нет $contracts_rel на origin/main=$sha"
fi

# ── ROADMAP: карта id → (пара, этап, трек, зависит) ───────────────────────────
# Источник карты — СТРОГО generated-блок ROADMAP (контракт 182 И-1/И-4): маркеры
# BEGIN/END должны быть ровно по одному и BEGIN раньше END; разбираются только
# строки МЕЖДУ маркерами. Отсутствие или неединственность блока — именованный
# отказ PLAN_ROADMAP_RASHOZHDENIE, а не зелёный срез по произвольным таблицам
# файла и не приём строк, стоящих вне блока.
# Ячейка: пара|id|этап|трек|зависит|источник.
roadmap_rc=0
roadmap_map="$(printf '%s\n' "$roadmap_blob" | awk '
  BEGIN { inblock = 0; nb = 0; ne = 0; bl = 0; el = 0; nrow = 0 }
  $0 == "<!-- BEGIN GENERATED PLAN -->" {
    nb++
    if (nb == 1) { bl = NR; inblock = 1 }
    next
  }
  $0 == "<!-- END GENERATED PLAN -->" {
    ne++
    if (ne == 1) { el = NR; inblock = 0 }
    next
  }
  {
    if (!inblock) next
    n = split($0, parts, "[|]")   # «|» — литерал: одиночный «|» как regex пуст
    if (n != 8) next
    # Ячейка = parts[2..7]: awk нумерует split с 1, пустая левая «|» — parts[1].
    for (j = 1; j <= 6; j++) {
      v = parts[j + 1]
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      fld[j] = v
    }
    if (fld[1] ~ /^[0-9]+$/) row[++nrow] = fld[2] "\t" fld[1] "\t" fld[3] "\t" fld[4] "\t" fld[5]
  }
  END {
    # Структурная ошибка блока — отдельный код: её отличает владелец от сбоя разбора.
    if (nb != 1 || ne != 1 || bl >= el) exit 3
    for (i = 1; i <= nrow; i++) print row[i]
  }')" || roadmap_rc=$?
if [ "$roadmap_rc" -ne 0 ]; then
  if [ "$roadmap_rc" -eq 3 ]; then
    die "PLAN_ROADMAP_RASHOZHDENIE: generated-блок ROADMAP отсутствует или повреждён (маркеры BEGIN/END не по одному или перевёрнуты) на origin/main=$sha"
  fi
  die "PLAN_ROADMAP_RASHOZHDENIE: не разобран generated-блок ROADMAP на origin/main=$sha"
fi

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
slice_rc=0
slice="$(awk -v sha="$sha" -v contracts_rel="$contracts_rel" '
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
    if (n != 6) fail("строка plan.tsv не из шести полей", f[1])
    id = f[1]; wave = f[2]; stage = f[3]; deps = f[4]; track = f[6]
    if (!(id in rmap)) fail("нет строки generated-блока ROADMAP", id)
    split(rmap[id], r, "\t")
    if (r[1] != wave || r[2] != stage || r[3] != track || r[4] != deps)
      fail("plan.tsv расходится с generated-блоком ROADMAP", id)
    if (id ~ /^[0-9]+$/ && !(id in reg)) fail("нет записи в " contracts_rel, id)
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
  <(printf '%s\n' "$plan_blob"))" || slice_rc=$?
if [ "$slice_rc" -ne 0 ]; then
  # rc 1 — awk уже напечатал именованный отказ с причиной (fail()); stdout пуст.
  # Прочие коды — сбой самого разбора: причина не названа, отказ всё равно именованный.
  if [ "$slice_rc" -ne 1 ]; then
    die "PLAN_ROADMAP_RASHOZHDENIE: не собран срез по published plan.tsv на origin/main=$sha"
  fi
  exit 1
fi

printf '%s\n' "$slice"
