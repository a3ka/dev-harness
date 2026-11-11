#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# ЧЕСТНАЯ МОДЕЛЬ контракта 195 — потребители 116: зонная атрибуция окна писателя.
# Это НЕ реализация: реализация — scripts/check_consumers.sh (зона implementer,
# пишется по контракту 195). Модель несёт контрактную семантику п1/п2/п3/п1-b в
# объёме, необходимом клеткам батареи potrebiteli_116_195, и зелена на ВСЕХ
# честных клетках уже сегодня (--model). ЕДИНЫЙ читатель ЗОНА-строк —
# scripts/lib_zones.sh (контракт 016): модель подключает его, а не парсит зоны
# второй реализацией; фразы отказов — побайтово фразы гейта.
#
# Семантика 195 (инварианты И-5..И-8 контракта):
#   судимое множество окна N — прежнее (062 И-1: хребет ∪ свои ленды, без
#   чужих land:-лендов, без owner/owner — Н-300);
#   правка писателя w коммитом c судится контрактом N ⟺
#     пара (автор c, w) покрыта ЗОНА-строками ВЫСШЕЙ заморозки N (И-6, своё
#     покрытие приоритетно: M==N никогда не исключается), ИЛИ
#     пара НЕ покрыта зоной никакого другого замороженного M≠N с коммитом c
#     в диапазоне M (frozen/M/1..done/M/1|HEAD — И-5, наружная атрибуция);
#   своё-покрытие И-6 реализовано ОДНОЙ ветвью — приоритетной проверкой
#     zone_covers(n) ПЕРЕД наружной атрибуцией (Б-3 круга 2: дублирующий
#     фильтр M==N внутри attributed_out был МЁРТВЫМ кодом — attributed_out
#     вызывается только после неудачи zone_covers для той же пары, и ЗОНА-
#     строка N не может покрыть в нём пару, которую только что не покрыла;
#     удаление фильтра ненаблюдаемо ни одной клеткой — прогоны в докладах
#     кругов 2 и 3);
#   отказ добычи окна/зон — именованный rc 1, не пустое множество (И-8).
#
# Использование: model_gate.sh <корень> <отн-путь-контракта>
# rc: 0 — окно зелёное; 1 — именованный отказ; 2 — нечем проверить.
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
export PATH=/usr/bin:/bin

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# SELF_DIR = <корень>/fixtures/workshop_project/potrebiteli_116_195/model → 4 уровня вверх = корень.
HARNESS="${HARNESS_ROOT:-$(cd "$SELF_DIR/../../../.." && pwd -P)}"
[ -d "$HARNESS/scripts" ] || HARNESS="$(cd "$SELF_DIR/../../../.." && pwd -P)"
[ -d "$HARNESS/scripts" ] || HARNESS="$(cd "$SELF_DIR/../../.." && pwd -P)"
# shellcheck disable=SC1091
. "$HARNESS/scripts/lib_zones.sh"

die()  { printf '%s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

ROOT="${1:?использование: $0 <корень> <отн-путь-контракта>}"
CONTRACT_PATH="${2:?использование: $0 <корень> <отн-путь-контракта>}"

command -v git >/dev/null 2>&1 || skip "нет git"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || skip "$ROOT не репозиторий git"
[ -f "$ROOT/$CONTRACT_PATH" ] || skip "контракт не найден: $ROOT/$CONTRACT_PATH"

base="${CONTRACT_PATH##*/}"
n="$(printf '%s' "$base" | sed -nE 's/^([0-9]{3})-.*/\1/p')"
[ -n "$n" ] || skip "имя контракта не по грамматике NNN: $base"

# п1 (минимум для клеток): маппинг писатель→потребители из tsv-пар.
MAPDIR="$ROOT/scripts/consumers.d"
[ -d "$MAPDIR" ] || exit 0
declare -A writer_consumers=()
while IFS= read -r f; do
  raw="$(cat "$f")"
  [ -n "$raw" ] || die "потребители 116: маппинг не по грамматике: $f"
  writer="${raw%%	*}"; consumer="${raw#*	}"
  [ -n "$writer" ] && [ -n "$consumer" ] || die "потребители 116: маппинг не по грамматике: $f"
  writer_consumers[$writer]+="$consumer"$'\n'
done < <(find "$MAPDIR" -maxdepth 1 -type f -name '*.tsv' | sort)
[ "${#writer_consumers[@]}" -gt 0 ] || die "потребители 116: маппинг не по грамматике: $MAPDIR пуст"

# п2: окно — последний живой тег заморозки N.
last_frozen="$(git -C "$ROOT" tag -l "frozen/contracts/$n/*" 2>/dev/null | sort -V | tail -n 1)"
[ -n "$last_frozen" ] || exit 0
body="$(cat "$ROOT/$CONTRACT_PATH")"

# Судимое множество (062 И-1 + Н-300): хребет ∪ свои ленды, без чужих land:,
# без owner/owner. Отказ добычи — именованный (И-8).
WINDOW_FAIL='потребители 116: список судимых коммитов окна недоступен'
_commits="$(mktemp)"; _excl="$(mktemp)"
trap 'rm -f "$_commits" "$_excl"' EXIT
if ! git -C "$ROOT" rev-list --no-merges "$last_frozen..HEAD" 2>/dev/null | sort -u > "$_commits"; then
  die "$WINDOW_FAIL"
fi
: > "$_excl"
git -C "$ROOT" rev-list --merges "$last_frozen..HEAD" 2>/dev/null | while IFS= read -r mc; do
  [ -n "$mc" ] || continue
  msg="$(git -C "$ROOT" log -1 --format=%s "$mc" 2>/dev/null)"
  case "$msg" in
    "land: wip/$n/"*) ;;
    "land: wip/"*) git -C "$ROOT" rev-list --no-merges "${mc}^1..${mc}" 2>/dev/null >> "$_excl" ;;
  esac
done
if ! _owners="$(git -C "$ROOT" log --no-merges --format='%H%x09%an%x09%cn' "$last_frozen..HEAD" 2>/dev/null)"; then
  die "$WINDOW_FAIL"
fi
printf '%s\n' "$_owners" | awk -F'\t' '$2 == "owner" && $3 == "owner" { print $1 }' >> "$_excl"
sort -u "$_excl" -o "$_excl"

# Зоны атрибуции — ЕДИНЫЙ читатель lib_zones (016): ЗОНА-строки высших заморозок
# (author<TAB>path<TAB>контракт) + диапазоны применения (frozen/M/1[..done/M/1]).
ZDIR="$(zones_load "$ROOT" 2>/dev/null)" || die 'потребители 116: зоны атрибуции окна не читаются'
[ -n "$ZDIR" ] && [ -f "$ZDIR/zones_scoped" ] && [ -f "$ZDIR/ranges" ] \
  || die 'потребители 116: зоны атрибуции окна не читаются'

# zone_covers <author> <путь> <контракт M> — семантика zones_match_path побайтово:
# каталог с завершающим / — префикс, файл — точное равенство.
zone_covers() {
  local a="$1" w="$2" m="$3" za zp zn
  while IFS=$'\t' read -r za zp zn; do
    [ -n "$za" ] || continue
    [ "$za" = "$a" ] && [ "$zn" = "$m" ] || continue
    case "$zp" in
      */) case "$w" in "$zp"*) return 0 ;; esac ;;
      *)  [ "$w" = "$zp" ] && return 0 ;;
    esac
  done < "$ZDIR/zones_scoped"
  return 1
}

# in_range <контракт M> <коммит> — c ∈ frozen/M/1..(done/M/1|HEAD) по ranges.
in_range() {
  local m="$1" c="$2" range since until
  range="$(awk -F'\t' -v m="$m" '$1 == m { print $2; exit }' "$ZDIR/ranges")"
  [ -n "$range" ] || return 1
  since="${range%%..*}"
  case "$range" in
    *..*) until="${range#*..}" ;;
    *)    until="" ;;
  esac
  git -C "$ROOT" merge-base --is-ancestor "$since" "$c" 2>/dev/null || return 1
  if [ -n "$until" ]; then
    git -C "$ROOT" merge-base --is-ancestor "$c" "$until" 2>/dev/null || return 1
  fi
  return 0
}

# attributed_out <коммит> <автор> <писатель> — наружная атрибуция И-5: пара покрыта
# зоной M≠N ∧ коммит в диапазоне M. Фильтр M==N здесь НЕ нужен и НЕ пишется:
# вызывается только после неудачи zone_covers(n) той же пары — своё-покрытие
# И-6 держит ЕДИНСТВЕННАЯ ветвь zone_covers перед этим вызовом (Б-3 круга 2;
# при удалении той ветви ЗОНА-строки N сами атрибутируют пару наружу —
# клетки kv1/kv3/k187 это ловят).
attributed_out() {
  local c="$1" a="$2" w="$3" za zp zn
  while IFS=$'\t' read -r za zp zn; do
    [ -n "$za" ] || continue
    [ "$za" = "$a" ] || continue
    case "$zp" in
      */) case "$w" in "$zp"*) ;; *) continue ;; esac ;;
      *)  [ "$w" = "$zp" ] || continue ;;
    esac
    if in_range "$zn" "$c"; then return 0; fi
  done < "$ZDIR/zones_scoped"
  return 1
}

# Покоммитная тронутость с атрибуцией: писатель тронут окном N ⟺ ∃ коммит
# судимого множества, менявший его блоб, И пара не атрибутирована наружу (И-5),
# причём собственное покрытие N приоритетно (И-6: M==N не исключается).
touched_writers=()
for w in "${!writer_consumers[@]}"; do
  hit=0
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    out="$(git -C "$ROOT" diff-tree -r --no-commit-id --name-only "$c" -- "$w")" || die "$WINDOW_FAIL"
    [ -n "$out" ] || continue
    a="$(git -C "$ROOT" log -1 --format=%an "$c" 2>/dev/null)" || die "$WINDOW_FAIL"
    if zone_covers "$a" "$w" "$n"; then hit=1; break; fi          # И-6: своё — судится
    if attributed_out "$c" "$a" "$w"; then continue; fi            # И-5: чужое — вне окна
    hit=1; break
  done < <(comm -23 "$_commits" "$_excl")
  [ "$hit" -eq 1 ] && touched_writers+=("$w")
done
rm -f "$_commits" "$_excl"; trap - EXIT

[ "${#touched_writers[@]}" -eq 0 ] && exit 0

# п3: проба исполнения каждого потребителя (фраза гейта дословно).
for w in "${touched_writers[@]}"; do
  consumers_list="${writer_consumers[$w]}"
  while IFS= read -r consumer; do
    [ -n "$consumer" ] || continue
    consumer_escaped="${consumer//\//\\/}"
    probe_line="$(printf '%s\n' "$body" | sed -nE "s/^ПОТРЕБИТЕЛЬ[[:space:]]+${consumer_escaped}[[:space:]]*:[[:space:]]*(.+)$/\\1/p" | sed -n 1p)"
    if [ -z "$probe_line" ]; then
      die "потребители 116: писатель $w изменён, потребитель $consumer не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы"
    fi
    ( cd "$ROOT" && sh -c "$probe_line" ) || die "потребители 116: ПОТРЕБИТЕЛЬ-проба красна: $consumer: rc $?"
  done <<< "$consumers_list"
done

# п1-b: замер-строка census (форма — побайтово из гейта).
if git -C "$ROOT" ls-tree -r --name-only "$last_frozen" -- scripts/consumers.d/ 2>/dev/null | grep -q .; then
  census_pattern='^замер:[[:space:]]*`cat[[:space:]]+scripts/consumers\.d/\*\.tsv[[:space:]]*[|][[:space:]]*wc[[:space:]]+-l`[[:space:]]*=[[:space:]]*[0-9]+[[:space:]]+census[[:space:]]+scripts/consumers\.d/\*\.tsv[[:space:]]*$'
  if ! printf '%s\n' "$body" | grep -Eq "$census_pattern"; then
    tw_list=""
    for w in "${touched_writers[@]}"; do tw_list="$tw_list $w"; done
    die "потребители 116: замер маппинга отсутствует (контракт правит писателя$tw_list)"
  fi
fi

exit 0
