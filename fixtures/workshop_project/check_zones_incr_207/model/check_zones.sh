#!/usr/bin/env bash
# МОДЕЛЬ 207 (фигстура батареи, НЕ производственная дверь): check_zones --incr
# с судом окна ОДИН РАЗ. Отличие от scripts/check_zones.sh базы — только форма
# incr-ветви: данные окна (список коммитов, merge-исключения, batched-авторы,
# batched-пути, решения по путям) готовятся ОДНИМ проходом до цикла по
# контрактам, а цикл по контрактам с зонами лишь воспроизводит пер-контрактные
# решения (счётчики commits/checked, СПАСЕНО, записанные bad-строки) из
# готовых данных. Вывод — байт-в-байт вывод прежнего incr-режима двери;
# При K>0 git-вызовы окна (rev-list x2, log --no-walk, diff-tree) — по одному
# на прогон при соответствующем непустом входе, не на контракт; при K=0 — ноль.
#
# ГРАНИЦА МОДЕЛИ (документирована контрактом 207 §НЕ ЗАЩИЩАЕТ):
#  - модель судит ТОЛЬКО incr-окно (--incr с валидным кешем-предком); вызов без
#    --incr — rc 2 NOT_IMPLEMENTED: полный прогон — предмет производственной
#    двери, батарея сравнивает модель с ней, а не с собой;
#  - блок «ПРЕДСТОЯЩЕЕ v+1» опущен: миры батареи не несут accept-вердикта
#    v+1 на HEAD, ветвь недостижима на них (производственная дверь несёт блок,
#    его инварианты судит семья fixtures/check_zones/ без правок);
#  - исторические ГРАНДФАЗЕР-комитеты и REPLACE-форма минт-признания опущены:
#    недостижимы на мирах батареи (ADD-форма покрыта клеткой e12), производственная
#    дверь несёт их, регресс — семья fixtures/check_zones/.
# Чтение зон, грамматика ЗОНА/СПАСЕНО/РАБОТА, merge-исключения `land: wip/…`,
# draft-признание 023(iv), минт-признание 031 ADD, фильтр процессных файлов,
# тексты ok()/bad(), сводка и коды возврата — ОТ ДВЕРИ дословно.
set -euo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
export PATH=/usr/bin:/bin

skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }
command -v dirname >/dev/null 2>&1 || skip "нет dirname в доверенном PATH — путь скрипта нечем вычислить"
command -v git     >/dev/null 2>&1 || skip "нет git в доверенном PATH — историю коммитов нечем читать"
command -v awk     >/dev/null 2>&1 || skip "нет awk в доверенном PATH — разбор зон, авторов и путей нечем вести"
command -v sed     >/dev/null 2>&1 || skip "нет sed в доверенном PATH — хунк-парсер минт-дельты нечем вести"
command -v grep    >/dev/null 2>&1 || skip "нет grep в доверенном PATH — фильтрацию строк нечем вести"
command -v sort    >/dev/null 2>&1 || skip "нет sort в доверенном PATH — множества коммитов и авторов нечем упорядочить"
command -v tr      >/dev/null 2>&1 || skip "нет tr в доверенном PATH — служебную очистку строк нечем вести"
command -v wc      >/dev/null 2>&1 || skip "нет wc в доверенном PATH — счёт строк нечем вести"
command -v mktemp  >/dev/null 2>&1 || skip "нет mktemp в доверенном PATH — скратч-каталог нечем создать"
command -v mkdir   >/dev/null 2>&1 || skip "нет mkdir в доверенном PATH — tmp/ нечем создать"
command -v cp      >/dev/null 2>&1 || skip "нет cp в доверенном PATH — вывод zones_load нечем скопировать"
command -v rm      >/dev/null 2>&1 || skip "нет rm в доверенном PATH — скратч нечем убрать"
command -v mv      >/dev/null 2>&1 || skip "нет mv в доверенном PATH — промежуточные файлы нечем переименовать"
command -v comm    >/dev/null 2>&1 || skip "нет comm в доверенном PATH — разность судимых и исключённых коммитов нечем считать"

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXT_ID_LIB=1
# shellcheck disable=SC1091
. "$SELF_DIR/next_id.sh"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_roles.sh"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_zones.sh"
# check_charter.sh (грамматика РАЗРЕШИЛ-ВЛАДЕЛЕЦ) модель не сорсит: единственный
# его потребитель здесь — блок «ПРЕДСТОЯЩЕЕ v+1», опущенный по границе модели.
INCR_NAME=check_zones
# shellcheck disable=SC1091
if [ -f "$SELF_DIR/lib_incr.sh" ]; then
  . "$SELF_DIR/lib_incr.sh"
else
  incr_parse() { INCR_CACHE=""; INCR_MODE="full"; INCR_BASE=""; INCR_HEAD=""; INCR_N=0; INCR_RC=0; INCR_REST=("$@"); }
  incr_fail() { :; }
  incr_finish() { :; }
fi

incr_parse "$@"
[ "$INCR_RC" -eq 0 ] || { incr_fail; exit 1; }
set -- "${INCR_REST[@]}"

ROOT="$(cd "${1:-"$SELF_DIR/.."}" && pwd)"
INCR_GIT_ROOT="$ROOT"
LIB_ZONES_ROOT="$ROOT"

# Модель судит только incr-окно: полный режим — производственная дверь.
[ "${INCR_MODE:-full}" = "incr" ] || skip "модель 207 судит только --incr окно; полный прогон — производственная check_zones.sh (клетки сравнения — на ней)"

fails=0
ok()   { printf '  ok   %s\n' "$*" >&2; }
bad()  { fails=$((fails + 1)); printf '  FAIL %s\n' "$*" >&2; }

# shellcheck disable=SC1091
. "$SELF_DIR/lib_registry.sh"

command -v git >/dev/null 2>&1 || skip "нет git — историю коммитов прочитать нечем"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || skip "$ROOT не репозиторий git"
git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1 || skip "в $ROOT нет ни одного коммита"

g() { git -C "$ROOT" "$@"; }

if [ ! -f "$ROOT/harness.project.json" ]; then
  _PROFILE_REGISTRY_PATH="registry"
else
  _pr_paths="$(project_paths_resolve "$ROOT" 2>/dev/null)" \
    || { printf 'workflow ОТКАЗ: профиль битый или workflowPaths вне репо\n' >&2; exit 1; }
  _PROFILE_REGISTRY_PATH="$(printf '%s' "$_pr_paths" | jq -r '.registry' 2>/dev/null || true)"
  [ -n "$_PROFILE_REGISTRY_PATH" ] || { printf 'workflow ОТКАЗ: registry пуст\n' >&2; exit 1; }
  unset _pr_paths
fi
_PROFILE_REGISTRY_FILE="${_PROFILE_REGISTRY_PATH%/}/contracts.tsv"

mkdir -p "$ROOT/tmp"
TMP="$(mktemp -d "$ROOT/tmp/zones.XXXXXX")"
trap '__lib_zones_cleanup; rm -rf "$TMP"' EXIT

state="$(registry_state "$ROOT" 'frozen/')"
case "$state" in
  full|unknown-remote) ;;
  *)
    printf 'ОТКАЗ: реестр заморозок (refs/tags/frozen/*) недоступен: %s\n' "$state" >&2
    printf 'Лечится: %s\n' "$(registry_cure "$state")" >&2
    printf 'Без реестра зоны не читаются, и барьер стал бы пусто-зелёным.\n' >&2
    exit 1
    ;;
esac

out="$(zones_load "$ROOT" 2>/dev/null)" || {
  printf 'NOT_IMPLEMENTED: реестр заморозок недоступен\n' >&2; exit 2; }
cp "$out/zones_scoped"    "$TMP/zones_scoped"
cp "$out/zones_violations" "$TMP/zones_violations"
cp "$out/ranges"          "$TMP/ranges"
cp "$out/contracts_list"  "$TMP/contracts_list"
contracts=$(wc -l < "$TMP/contracts_list" | tr -d ' ')
: > "$TMP/saved"
: > "$TMP/process_excluded"
g for-each-ref --format='%(refname)' 'refs/tags/frozen/contracts/' 2>/dev/null | sort > "$TMP/tags" || true
# «ПРЕДСТОЯЩЕЕ v+1» опущен по границе модели (см. шапку): pred_file пуст.
: > "$TMP/pred_file"

awk -v FS='\0' 'NF >= 3 {
  reason = $3
  file = $2; author = $4; path = $5; raw_line = $6
  if (reason == "bad_author")
    printf("строка ЗОНА вне объявленной грамматики в %s: «%s» — нужно «ЗОНА <имя-автора>: <путь> [<путь>…]»\n", file, raw_line)
  else if (reason == "tab_in_author")
    printf("строка ЗОНА вне объявленной грамматики в %s: имя автора «%s» содержит табуляцию — имя сериализуется как TSV-поле и разделитель в нём не живёт\n", file, author)
  else if (reason == "no_paths")
    printf("строка ЗОНА вне объявленной грамматики в %s: «%s» — у автора «%s» не назван ни один путь\n", file, raw_line, author)
  else if (reason == "quote_in_path")
    printf("строка ЗОНА вне объявленной грамматики в %s: путь «%s» у автора «%s» содержит кавычку — пути разделены пробелами, кавычек грамматика не несёт\n", file, path, author)
  else if (reason == "bad_prefix")
    printf("строка ЗОНА вне объявленной грамматики в %s: путь «%s» у автора «%s» — путь обязан быть относительным, без шаблонов, .. и пробелов; каталог завершается /\n", file, path, author)
}' "$TMP/zones_violations" | while IFS= read -r line; do bad "$line"; done

# РАБОТА НЕ РАЗДАЁТСЯ + СПАСЕНО — от двери дословно (предстоящее-ветвь чтения
# тела опущена: pred_file пуст, тело всегда из блоба высшей заморозки).
while IFS= read -r nnn; do
  [ -n "$nnn" ] || continue
  vmax=0
  while IFS= read -r t; do
    if [[ "$t" =~ ^refs/tags/frozen/contracts/${nnn}/([0-9]+)$ ]]; then
      k=$((10#${BASH_REMATCH[1]}))
      [ "$k" -gt "$vmax" ] && vmax="$k"
    fi
  done < "$TMP/tags"
  [ "$vmax" -gt 0 ] || continue
  file="$(g ls-tree -r --name-only "refs/tags/frozen/contracts/$nnn/$vmax^{commit}" -- ':(literal)contracts/' 2>/dev/null \
        | awk -v n="$nnn" 'index($0, "contracts/" n "-") == 1 { print; exit }')"
  [ -n "$file" ] || continue
  body="$(g cat-file -p "refs/tags/frozen/contracts/$nnn/$vmax^{commit}:$file" 2>/dev/null || true)"

  declared=0
  if awk -F'\t' -v n="$nnn" '$3 == n' "$TMP/zones_scoped" | grep -q .; then declared=1; fi
  while IFS= read -r line; do
    declared=1
    reason="${line#РАБОТА НЕ РАЗДАЁТСЯ:}"
    if [ -z "${reason//[[:space:]]/}" ]; then
      bad "строка РАБОТА НЕ РАЗДАЁТСЯ вне объявленной грамматики в $file: причина пуста — объявление без причины неотличим из опечатки"
    else
      ok "$file — работа не раздаётся:${reason}"
    fi
  done < <(printf '%s\n' "$body" | grep '^РАБОТА НЕ РАЗДАЁТСЯ:' || true)

  s_until="HEAD"
  if g rev-parse --verify --quiet "refs/tags/done/contracts/$nnn/1" >/dev/null 2>&1; then
    s_until="refs/tags/done/contracts/$nnn/1"
  fi
  while IFS= read -r line; do
    rest="${line#СПАСЕНО }"
    s_author="${rest%%:*}"
    s_tail="${rest#*:}"
    if [ "$s_author" = "$rest" ] || [ -z "${s_author//[[:space:]]/}" ] || [[ "$s_author" == *$'\t'* ]]; then
      bad "строка СПАСЕНО вне объявленной грамматики в $file: «$line» — нужно «СПАСЕНО <автор>: <полные хеши> — <причина>»"
      continue
    fi
    if ! awk -F'\t' -v a="$s_author" -v n="$nnn" '$1 == a && $3 == n { f=1 } END { exit(f ? 0 : 1) }' "$TMP/zones_scoped"; then
      bad "строка СПАСЕНО вне объявленной грамматики в $file: автор «$s_author» не объявлен ЗОНА-строкой этого контракта"
      continue
    fi
    case "$s_tail" in
      *—*) s_hashes="${s_tail%%—*}"; s_reason="${s_tail#*—}" ;;
      *)   bad "строка СПАСЕНО вне объявленной грамматики в $file: «$line» — нет «— <причина>»"; continue ;;
    esac
    if [ -z "${s_reason//[[:space:]]/}" ]; then
      bad "строка СПАСЕНО вне объявленной грамматики в $file: причина пуста — объявление без причины неотличим из опечатки"
      continue
    fi
    set -f
    for h in $s_hashes; do
      case "$h" in
        *'"'*) bad "строка СПАСЕНО вне объявленной грамматики в $file: хеш «$h» содержит кавычку" ;;
      esac
      if ! [[ "$h" =~ ^[0-9a-f]{40}$ ]]; then
        bad "строка СПАСЕНО вне объявленной грамматики в $file: «$h» — не полный 40-символьный hex"
        continue
      fi
      if ! g cat-file -e "$h^{commit}" 2>/dev/null; then
        bad "строка СПАСЕНО в $file называет несуществующий коммит «$h»"
        continue
      fi
      g merge-base --is-ancestor "refs/tags/frozen/contracts/$nnn/1" "$h" 2>/dev/null \
        && g merge-base --is-ancestor "$h" "$s_until" 2>/dev/null || {
          bad "строка СПАСЕНО в $file называет коммит «$h» вне диапазона контракта (frozen/contracts/$nnn/1..$s_until)"
          continue
        }
      printf '%s\t%s\t%s\n' "$s_author" "$h" "$nnn" >> "$TMP/saved"
    done
    set +f
  done < <(printf '%s\n' "$body" | grep '^СПАСЕНО ' || true)
  if [ "$declared" -eq 0 ]; then
    bad "$file: контракт не объявил ни зон, ни отказа от раздачи — нужна строка «ЗОНА <автор>: <путь>» либо «РАБОТА НЕ РАЗДАЁТСЯ: <причина>». Молчание не годится: «зон нет» и «зоны забыли» выглядят одинаково"
  fi
done < "$TMP/contracts_list"

# Как в базовой двери: K=0 заканчивается ДО суда окна и без incr_finish.
# Маркер уже напечатан lib_incr; кеш остаётся базой, даже при rc 0.
if [ ! -s "$TMP/zones_scoped" ]; then
  printf '\nзамороженных контрактов: %d · зон не объявлено — проверять нечего\n' "$contracts" >&2
  [ "$fails" -eq 0 ] || exit 1
  exit 0
fi

is_process_file() {
  case "$1" in
    verdicts/*) return 0 ;;
    HANDOFF.md) return 0 ;;
    NABLIUDENIA*.md)
      case "$1" in */*) return 1 ;; esac
      return 0
      ;;
    docs/handoff-archive/*) return 0 ;;
    .review/*) return 0 ;;
  esac
  return 1
}

commits=0; checked=0

# ── 207: СУД ОКНА ОДИН РАЗ ────────────────────────────────────────────────────
# (1) participating: контракты из ranges с непустым множеством авторов.
: > "$TMP/w_part"
: > "$TMP/w_union_raw"
while IFS=$'\t' read -r nnn since; do
  [ -n "$nnn" ] || continue
  awk -F'\t' -v n="$nnn" '$3 == n { print $1 }' "$TMP/zones_scoped" | sort -u > "$TMP/w_auth_one"
  if [ -s "$TMP/w_auth_one" ]; then
    printf '%s\n' "$nnn" >> "$TMP/w_part"
    cat "$TMP/w_auth_one" >> "$TMP/w_union_raw"
  fi
done < "$TMP/ranges"

if [ -s "$TMP/w_part" ]; then
  sort -u "$TMP/w_union_raw" > "$TMP/authors"
  nnn0="$(sed -n 1p "$TMP/w_part")"
  range="$INCR_BASE..HEAD"

  # (2) окно: не-merge коммиты в хронологии — ОДИН вызов (форма двери :703).
  if ! g rev-list --no-merges --reverse "$range" > "$TMP/w_commits" 2>/dev/null; then
    printf 'ОТКАЗ: git rev-list --no-merges --reverse отказал (контракт %s, диапазон %s) — список судимых коммитов окна недоступен.\n' "$nnn0" "$range" >&2
    printf 'Лечится: диагностируйте git-окружение (PATH, версия git, доступность объектной базы) и повторите прогон.\n' >&2
    printf 'Без списка коммитов окно стало бы пусто-зелёным — это дороже красного (прецедент case_reestr_nedostupen, тот же класс, что круг 1 контракта 040, арбитраж 040-II п.3).\n' >&2
    exit 1
  fi

  # (3) merge-исключения: субъекты и принесённые коммиты — ОДИН проход по
  # merge'ям окна (собственность `land: wip/<NNN>/…` зависит от контракта —
  # потому хранятся субъект и принесённые, а не готовое исключение).
  mkdir -p "$TMP/w_merges"
  : > "$TMP/w_msub"
  g rev-list --merges "$range" 2>/dev/null | while IFS= read -r mc; do
    [ -n "$mc" ] || continue
    msg="$(g log -1 --format=%s "$mc" 2>/dev/null)"
    printf '%s\t%s\n' "$mc" "$msg" >> "$TMP/w_msub"
    case "$msg" in
      "land: wip/"*) g rev-list --no-merges "${mc}^1..${mc}" 2>/dev/null > "$TMP/w_merges/$mc" ;;
    esac
  done

  # (4) авторы окна — ОДИН batched-вызов (форма двери :776-786, fail-closed).
  if [ -s "$TMP/w_commits" ]; then
    if ! g log --no-walk --format='%H%x00%an%x00' --stdin < "$TMP/w_commits" \
        > "$TMP/author_nul" 2>/dev/null; then
      printf 'ОТКАЗ: batched git log --no-walk --stdin отказал (контракт %s, диапазон %s) — список авторов окна недоступен.\n' "$nnn0" "$range" >&2
      printf 'Лечится: диагностируйте git-окружение (PATH, версия git, доступность объектной базы) и повторите прогон.\n' >&2
      printf 'Без списка авторов совпадения по автору не находятся, и окно стало бы пусто-зелёным — это дороже красного (прецедент case_reestr_nedostupen).\n' >&2
      exit 1
    fi
  else
    : > "$TMP/author_nul"
  fi
  tr -d '\n' < "$TMP/author_nul" > "$TMP/author_nul.tmp" && mv "$TMP/author_nul.tmp" "$TMP/author_nul"
  awk -v RS='\0' '
    (NR % 2 == 1) && /^[0-9a-f]{40}$/ { sha = $0; next }
    (NR % 2 == 0) && sha != ""        { printf("%s\t%s\n", sha, $0); sha = "" }
  ' "$TMP/author_nul" > "$TMP/author_map" || : > "$TMP/author_map"
  awk -F'\t' '
    NR == FNR { if ($1 != "") want[$1] = 1; next }
    { seen[$1]++ }
    END {
      missing = 0; dup = 0
      for (s in want) {
        if (!(s in seen))      missing++
        else if (seen[s] != 1) dup++
      }
      printf("%d\t%d\n", missing, dup)
    }
  ' "$TMP/w_commits" "$TMP/author_map" > "$TMP/author_map_completeness"
  IFS=$'\t' read -r missing_shas dup_shas < "$TMP/author_map_completeness"
  if [ "${missing_shas:-0}" -gt 0 ] || [ "${dup_shas:-0}" -gt 0 ]; then
    printf 'ОТКАЗ: batched git log --no-walk --stdin вернул неполный поток (контракт %s, диапазон %s) — %s SHA без записи автора, %s SHA с более чем одной записью; список авторов окна недостоверен.\n' \
      "$nnn0" "$range" "${missing_shas:-0}" "${dup_shas:-0}" >&2
    printf 'Лечится: диагностируйте git-окружение (PATH, версия git, доступность объектной базы) и повторите прогон.\n' >&2
    printf 'Частичный, но синтаксически валидный успешный вывод опаснее явного отказа — недостающая запись сделала бы нарушителя невидимым (verdicts/adversary/contracts-040-oracle-a2-diff-tree-v2.md).\n' >&2
    exit 1
  fi

  # (5) matched: коммиты окна, чей автор объявлен хоть в одном participating.
  awk -F'\t' '
    NR==FNR { z[$1]=1; next }
    ($2 in z) { if (!seen[$1]++) print $1 }
  ' "$TMP/authors" "$TMP/author_map" > "$TMP/w_matched"

  # (6) пути matched-коммитов — ОДИН batched diff-tree (форма двери :863-912).
  if [ -s "$TMP/w_matched" ]; then
    g diff-tree -r --no-renames --raw --always -z --stdin \
      < "$TMP/w_matched" > "$TMP/paths_raw"
  else
    : > "$TMP/paths_raw"
  fi
  : > "$TMP/paths_by_commit"
  awk -v ORS='\0' -v pairsfile="$TMP/paths_by_commit" -v ord="$TMP/w_matched" '
    BEGIN {
      RS = "\n"
      while ((getline line < ord) > 0) {
        if (line != "") { want[line] = 1 }
      }
      close(ord)
      RS = "\0"
      after_meta = 0
      cur = ""
      orphan = 0
    }
    {
      if (after_meta) {
        if (cur != "") { print cur > pairsfile; print $0 > pairsfile }
        else            { orphan++ }
        after_meta = 0
        next
      }
      if (substr($0, 1, 1) == ":") { after_meta = 1; next }
      cur = $0
      seen[$0]++
    }
    END {
      if (after_meta) orphan++
      missing = 0; dup = 0; extra = 0
      for (s in want) {
        if (!(s in seen))      missing++
        else if (seen[s] != 1) dup++
      }
      for (s in seen) { if (!(s in want)) extra++ }
      printf("%d\t%d\t%d\t%d\n", missing, dup, extra, orphan)
    }
  ' "$TMP/paths_raw" > "$TMP/paths_raw_completeness"
  IFS=$'\t' read -r missing_paths dup_paths extra_paths orphan_paths < "$TMP/paths_raw_completeness"
  if [ "${missing_paths:-0}" -gt 0 ] || [ "${dup_paths:-0}" -gt 0 ] || [ "${extra_paths:-0}" -gt 0 ] || [ "${orphan_paths:-0}" -gt 0 ]; then
    printf 'ОТКАЗ: batched git diff-tree --stdin вернул неполный/искажённый поток (контракт %s, диапазон %s) — %s SHA без заголовка путей, %s SHA с более чем одной заголовочной записью, %s постороннего заголовка вне matched, %s записей метаданных без пары-пути; список путей окна недостоверен.\n' \
      "$nnn0" "$range" "${missing_paths:-0}" "${dup_paths:-0}" "${extra_paths:-0}" "${orphan_paths:-0}" >&2
    printf 'Лечится: диагностируйте git-окружение (PATH, версия git, доступность объектной базы) и повторите прогон.\n' >&2
    printf 'Частичный, но синтаксически валидный успешный вывод опаснее явного отказа — недостающая/задвоенная/подложная/оборванная запись сделала бы нарушителя невидимым либо приписала бы его путь постороннему заголовку (verdicts/adversary/contracts-040-oracle-a2-diff-tree-v2.md, находка (б); арбитраж 040-II п.2; verdicts/adversary/contracts-040-v7-circle.md, находка 2; verdicts/adversary/contracts-040-v8-circle.md).\n' >&2
    exit 1
  fi

  # (7) ОДИН проход решений по путям: каждая пара (коммит, путь) судится один
  # раз, bad-строки ЗАПИСЫВАЮТСЯ (NUL-разделённые, путь может нести сырой LF),
  # цикл по контрактам ниже их только воспроизводит.
  mkdir -p "$TMP/w_dec"
  wbad() { printf '%s\0' "$*" >> "$TMP/w_dec/${w_cur}.bad"; }
  while IFS= read -r w_c; do
    [ -n "$w_c" ] || continue
    w_cur="$w_c"
    an="$(awk -F'\t' -v c="$w_c" '$1 == c { print $2; exit }' "$TMP/author_map")"
    [ -n "$an" ] || continue
    # зона автора — ОБЪЕДИНЕНИЕ путей из ВСЕХ замороженных контрактов (дверя :1051).
    awk -F'\t' -v a="$an" '$1 == a { print $2 }' "$TMP/zones_scoped" | sort -u > "$TMP/mine"
    while IFS= read -r -d '' f; do
      [ -n "$f" ] || continue
      # draft-признание (023, ветвь iv) — от двери дословно.
      skip_path=
      if [ "${f%%/*}" = "contracts" ]; then
        base="${f##*/}"
        head3="${base:0:3}"
        case "$head3" in
          [0-9][0-9][0-9])
            path_m="$head3"
            if [ "${base:3:1}" = "-" ]; then
              if g tag --points-at "$w_c" "id/CONTRACT/$path_m" 2>/dev/null \
                   | grep -qxF -- "id/CONTRACT/$path_m"; then
                skip_path=1
              else
                tag_commit="$(g rev-parse --verify --quiet "refs/tags/id/CONTRACT/$path_m^{commit}" 2>/dev/null || true)"
                if [ -n "$tag_commit" ] && g merge-base --is-ancestor "$tag_commit" "$w_c" 2>/dev/null; then
                  freeze_in_ancestors=0
                  while IFS= read -r ft; do
                    [ -z "$ft" ] && continue
                    ft_commit="$(g rev-parse --verify --quiet "${ft}^{commit}" 2>/dev/null || true)"
                    if [ -n "$ft_commit" ] && g merge-base --is-ancestor "$ft_commit" "$w_c" 2>/dev/null; then
                      freeze_in_ancestors=1
                      break
                    fi
                  done < <(g for-each-ref --format='%(refname)' "refs/tags/frozen/contracts/$path_m/" 2>/dev/null)
                  if [ "$freeze_in_ancestors" -eq 0 ]; then
                    skip_path=1
                  fi
                fi
              fi
            fi
            ;;
        esac
      fi
      # минт-признание (031, ветвь ii, ФОРМА ADD) — от двери дословно; REPLACE-форма
      # опущена по границе модели (недостижима на мирах батареи).
      if [ "$an" = "orchestrator" ] && [ "$f" = "$_PROFILE_REGISTRY_FILE" ]; then
        if g rev-parse --verify --quiet "${w_c}^" >/dev/null 2>&1; then
          mint_diff="$(g diff -U0 "${w_c}^" "$w_c" -- "$_PROFILE_REGISTRY_FILE" 2>/dev/null || true)"
        else
          mint_diff="$(g diff -U0 $(g rev-parse --verify 4b825dc642cb6eb9a060e54bf899d15f3f938a82) "$w_c" -- "$_PROFILE_REGISTRY_FILE" 2>/dev/null || true)"
        fi
        hunk_body="$(printf '%s\n' "$mint_diff" | awk '/^@@/ { h=1; next } /^diff / { h=0 } h')"
        mint_add="$(printf '%s\n' "$hunk_body" | awk '/^\+/ { c++ } END { print c+0 }')"
        mint_del="$(printf '%s\n' "$hunk_body" | awk '/^-/ { c++ } END { print c+0 }')"
        form_mode=""
        if [ "$mint_add" -ge 1 ] && [ "$mint_del" -eq 0 ]; then
          form_mode="add"
        elif [ "$mint_add" -eq 1 ] && [ "$mint_del" -eq 1 ]; then
          form_mode="replace"
        else
          wbad "коммит вне зоны: $an ${w_c:0:8} $f — дверь минта 031: дельта манифеста не только-добавление"
          continue
        fi
        added_lines="$(printf '%s\n' "$hunk_body" | sed -n 's/^+\([0-9]\{3\} → [0-9a-f]\{40\}\)$/\1/p')"
        valid_count="$(printf '%s\n' "$added_lines" | awk 'NF { c++ } END { print c+0 }')"
        if [ "$valid_count" -ne "$mint_add" ]; then
          wbad "коммит вне зоны: $an ${w_c:0:8} $f — дверь минта 031: строка не по грамматике манифеста"
          continue
        fi
        if [ "$form_mode" = "add" ]; then
          mint_fail=0
          while IFS= read -r ln; do
            [ -n "$ln" ] || continue
            if [ "$mint_fail" -ne 0 ]; then break; fi
            nnn="${ln%% *}"
            sha_ln="${ln##* }"
            if [ -z "$nnn" ] || [ -z "$sha_ln" ]; then
              wbad "коммит вне зоны: $an ${w_c:0:8} $f — дверь минта 031: строка не по грамматике манифеста"
              mint_fail=1; break
            fi
            if ! g show-ref --verify --quiet "refs/tags/id/CONTRACT/$nnn"; then
              wbad "коммит вне зоны: $an ${w_c:0:8} $f — дверь минта 031: тег id/CONTRACT/$nnn не жив локально"
              mint_fail=1; break
            fi
            tag_type="$(g cat-file -t "refs/tags/id/CONTRACT/$nnn" 2>/dev/null || true)"
            if [ "$tag_type" != "tag" ]; then
              wbad "коммит вне зоны: $an ${w_c:0:8} $f — дверь минта 031: тег id/CONTRACT/$nnn не аннотированный"
              mint_fail=1; break
            fi
            tag_sha="$(g rev-parse "refs/tags/id/CONTRACT/$nnn" 2>/dev/null || true)"
            if [ "$tag_sha" != "$sha_ln" ]; then
              wbad "коммит вне зоны: $an ${w_c:0:8} $f — дверь минта 031: sha строки ≠ tag-object-sha живого тега"
              mint_fail=1; break
            fi
          done <<< "$added_lines"
          if [ "$mint_fail" -ne 0 ]; then
            continue
          fi
          skip_path=1
        fi
      fi
      if [ -n "$skip_path" ]; then
        continue
      fi
      if is_process_file "$f"; then
        printf '%s\n' "$f" >> "$TMP/process_excluded"
        continue
      fi
      inside=1
      while IFS= read -r p; do
        case "$p" in
          */) case "$f" in "$p"*) inside=0; break ;; esac ;;
          *)  [ "$f" = "$p" ] && { inside=0; break; } ;;
        esac
      done < "$TMP/mine"
      [ "$inside" -eq 0 ] || wbad "коммит вне зоны: $an ${w_c:0:8} $f — зона автора (объединение всех замороженных): $(tr '\n' ' ' < "$TMP/mine")"
    done < <(awk -v RS='\0' -v ORS='\0' -v want="$w_c" '
      NR % 2 == 1 { sha = $0; next }
      sha == want { print }
    ' "$TMP/paths_by_commit")
  done < "$TMP/w_matched"
fi

# ── REPLAY: пер-контрактные решения из готовых данных окна ────────────────────
while IFS=$'\t' read -r nnn since; do
  [ -n "$nnn" ] || continue
  replay_prichina=207
  awk -F'\t' -v n="$nnn" '$3 == n { print $1 }' "$TMP/zones_scoped" | sort -u > "$TMP/authors"
  [ -s "$TMP/authors" ] || continue
  # judged(nnn): окно минус коммиты, принесённые ЧУЖИМИ `land: wip/<OTHER>/…`
  # merge'ями (форма двери :714-731, субъекты и принесённые — из прохода (3)).
  : > "$TMP/exclude"  # 207-replay-exclude
  if [ -s "$TMP/w_msub" ]; then
    while IFS=$'\t' read -r mc msub; do
      [ -n "$mc" ] || continue
      case "$msub" in
        "land: wip/${nnn}/"*) ;;
        "land: wip/"*) [ -s "$TMP/w_merges/$mc" ] && cat "$TMP/w_merges/$mc" >> "$TMP/exclude" ;;
      esac
    done < "$TMP/w_msub"
  fi
  sort -u "$TMP/exclude" -o "$TMP/exclude"
  cp "$TMP/w_commits" "$TMP/commits"
  if [ -s "$TMP/exclude" ]; then
    sort -u "$TMP/commits" -o "$TMP/commits_sorted"
    comm -23 "$TMP/commits_sorted" "$TMP/exclude" > "$TMP/judged"
    mv "$TMP/judged" "$TMP/commits"
  fi
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    commits=$((commits + 1))
    an="$(awk -F'\t' -v c="$c" '$1 == c { print $2; exit }' "$TMP/author_map")"
    [ -n "$an" ] || continue
    grep -qxF -- "$an" "$TMP/authors" || continue
    if grep -qxF "$(printf '%s\t%s\t%s' "$an" "$c" "$nnn")" "$TMP/saved"; then
      printf '  ok   контракт %s: коммит %s (%s) — СПАСЕНО, из суда зон выведен\n' "$nnn" "${c:0:8}" "$an" >&2
      continue
    fi
    checked=$((checked + 1))  # 207-replay
    if [ -f "$TMP/w_dec/$c.bad" ]; then
      while IFS= read -r -d '' wline; do
        bad "$wline"
      done < "$TMP/w_dec/$c.bad"
    fi
  done < "$TMP/commits"
done < "$TMP/ranges"

printf '\nпроцессных вне суда:%s\n' "${process_list:+ $process_list}" >&2

printf '\nзамороженных контрактов: %d · объявленных авторов: %d · коммитов в диапазонах: %d · проверено по зонам: %d\n' \
  "$contracts" "$(wc -l < "$TMP/authors" 2>/dev/null | tr -d ' ')" "$commits" "$checked" >&2

if [ "$fails" -eq 0 ]; then
  incr_finish 0
  exit 0
fi
incr_finish 1
exit 1
