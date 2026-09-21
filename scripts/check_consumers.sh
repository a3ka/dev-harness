#!/usr/bin/env bash
# Гейт верификации потребителей (контракт 038, §Freeze-верификация потребителей):
# для каждого ЗАРЕГИСТРИРОВАННОГО писателя, тронутого в окне
# frozen/contracts/<NNN>/<v>..HEAD (последняя живая заморозка), контракт обязан
# нести замер-строку census-совместимой формы и ЗЕЛЁНУЮ пробу исполнения каждого
# его ПОТРЕБИТЕЛЯ из scripts/consumers.d/. ЗОНА-альтернатива УДАЛЕНА v3 (Б1):
# перечисление ≠ исполнение, гейт исполняет пробу, не парсит прозу.
#
# Грамматика маппинга — файл-на-пару (Б3): один файл = одна строка =
# одна пара `<writer><TAB><consumer>`; имя файла = базовые имена сторон
# с подчёркиваниями вместо точек. Три писателя-минимума (п1) — настоящие пути:
# scripts/freeze_contract.sh (под тестом в freeze), scripts/lib_registry.sh,
# scripts/done_contract.sh.
#
# ПОРЯДОК ДИАГНОСТИКИ (v3):
#   п4 fail-closed (реестр) → п1 структура маппинга + состав →
#   п2 окно → п3 покрытие пробой → п1-b замер census.
#   п3 показывается РАНЬШЕ п1-b: проба — содержание верификации
#   (правило 8: оракул — сам потребитель), замер — дисциплина census (Б3).
#
# Контракт API:
#   вход: $1 = <корень-дерева>, $2 = <отн-путь-контракта>;
#   rc 0 — все тронутые писатели покрыты пробами (или окно пустое);
#   rc 1 — отказ с ИМЕНОВАННОЙ причиной первой красной;
#   rc 2 — нечем проверить: нет git / контракта / NNN в имени.
#
#   bash scripts/check_consumers.sh <корень> <отн-путь-контракта>
#
# Коды возврата: 0 — зелёный, 1 — отказ, 2 — нечем проверить.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_registry.sh"

die()  { printf '%s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

ROOT="${1:?использование: $0 <корень> <отн-путь-контракта>}"
CONTRACT_PATH="${2:?использование: $0 <корень> <отн-путь-контракта>}"

command -v git >/dev/null 2>&1 || skip "нет git"
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || skip "$ROOT не репозиторий git"
git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1 || skip "в $ROOT нет ни одного коммита"

[ -f "$ROOT/$CONTRACT_PATH" ] || skip "контракт не найден: $ROOT/$CONTRACT_PATH"

# NNN из имени контракта — три цифры, дефис, не-цифра
base="${CONTRACT_PATH##*/}"
n="$(printf '%s' "$base" | sed -nE 's/^([0-9]{3})-.*/\1/p')"
[ -n "$n" ] || skip "имя контракта не по грамматике NNN: $base"

# ── п4: реестр заморозок (lib_registry) — fail-closed на unknown-remote ──
state="$(registry_state "$ROOT" 'frozen/' 2>/dev/null || true)"
case "$state" in
  full) ;;
  shallow)        skip "реестр заморозок shallow — верификация невозможна без полной истории" ;;
  missing-remote) skip "реестр заморозок missing-remote — верификация невозможна без полного реестра" ;;
  unknown-remote) die "потребители 116: реестр заморозок не читается: $state" ;;
  *)              die "потребители 116: реестр заморозок не читается: $state" ;;
esac

# ── п1 (структура маппинга + состав) ─────────────────────────────────────────
MAPDIR="$ROOT/scripts/consumers.d"
# Vacuous (А-199): потребители не зарегистрированы — гейт не имеет
# предмета проверки, отказ был бы ложным. Это НЕ ослабление п1 для
# контрактов с consumers.d: каталог существует → весь п1 (грамматика,
# состав, минимум писателей, замер) исполняется как прежде, и твёрдый
# гейт остаётся в силе для блокера к2-Б1 (зарегистрированный-но-
# непроверяемый потребитель обязан красить). Контракт-регистратор (ЭТОТ
# 038) попадает в эту ветку ДО появления реализации: его frozen-тег ещё
# не несёт consumers.d — здесь же и любой toy/case-репозиторий, для
# которого маппинг не проектируется (случай «нечего верифицировать»).
if [ ! -d "$MAPDIR" ]; then
  exit 0
fi

mapfile -t map_files < <(find "$MAPDIR" -maxdepth 1 -type f -name '*.tsv' | sort)
[ "${#map_files[@]}" -gt 0 ] || die "потребители 116: маппинг не по грамматике: $MAPDIR пуст"

declare -A writer_consumers=()  # writer path → newline-separated consumer paths

for f in "${map_files[@]}"; do
  # Грамматика файла: РОВНО одна строка `<writer><TAB><consumer>` + завершающий \n
  raw="$(cat "$f")"
  [ -n "$raw" ] || die "потребители 116: маппинг не по грамматике: $f"
  lc=$(awk 'END{print NR}' "$f")
  if [ "$lc" != "1" ]; then
    die "потребители 116: маппинг не по грамматике: $f"
  fi
  writer="${raw%%	*}"
  rest="${raw#*	}"
  consumer="$rest"
  [ -n "$writer" ] && [ -n "$consumer" ] || die "потребители 116: маппинг не по грамматике: $f"
  # Имя файла = `<writer-with-.sh>__<consumer-base-dots-as-underscores>.tsv`
  bn="$(basename "$f" .tsv)"
  case "$bn" in
    *__*) ;;
    *) die "потребители 116: имя файла маппинга не соответствует паре: $f" ;;
  esac
  w_base="${bn%%__*}"
  c_base="${bn#*__}"
  [ "${writer##*/}" = "$w_base" ] \
    || die "потребители 116: имя файла маппинга не соответствует паре: $f"
  cbn_raw="${consumer##*/}"
  cbn_norm="${cbn_raw//./_}"
  [ "$cbn_norm" = "$c_base" ] \
    || die "потребители 116: имя файла маппинга не соответствует паре: $f"
  [ -e "$ROOT/$writer" ] || die "потребители 116: путь маппинга не существует: $writer"
  [ -e "$ROOT/$consumer" ] || die "потребители 116: путь маппинга не существует: $consumer"
  writer_consumers[$writer]+="$consumer"$'\n'
done

# Писатели-минимум (контракт §Само-применение, п1).
for w in scripts/freeze_contract.sh scripts/lib_registry.sh scripts/done_contract.sh; do
  if [ -z "${writer_consumers[$w]:-}" ]; then
    die "потребители 116: писатели-минимум не зарегистрированы: $w"
  fi
done

# ── п2: окно frozen/contracts/<NNN>/<v> .. HEAD на момент вызова ──────────────
# При первой заморозке — минт-резерв 023 (frozen-тега ещё нет → окно пустое,
# vacuous rc 0). Регистратор (ЭТОТ контракт 038) — здесь vacuous: frozen-тега
# нет, на нём consumers.d ещё нет.
last_frozen="$(git -C "$ROOT" tag -l 'frozen/contracts/'"$n"'/*' 2>/dev/null | sort -V | tail -n 1 || true)"

body="$(cat "$ROOT/$CONTRACT_PATH")"

if [ -z "$last_frozen" ]; then
  exit 0
fi

# Писатели в правке: зарегистрированные писатели, тронутые коммитами окна.
touched_writers=()
for w in "${!writer_consumers[@]}"; do
  if git -C "$ROOT" diff-tree --no-commit-id --name-only -r "$last_frozen"..HEAD -- "$w" 2>/dev/null | grep -q .; then
    touched_writers+=("$w")
  fi
done

# Пустое окно — vacuous rc 0
if [ "${#touched_writers[@]}" -eq 0 ]; then
  exit 0
fi

# ── п3: покрытие ТОЛЬКО пробой исполнения (v3, Б1) ────────────────────────────
# Для каждой пары (тронутый писатель, его потребитель): контракт несёт строку
# `ПОТРЕБИТЕЛЬ <consumer-path>: <cmd>`, гейт ИСПОЛНЯЕТ её в cwd=$ROOT, таймаут 60 с,
# rc 0 обязателен. ПОКАЗЫВАЕТСЯ ПЕРЕД замер-строкой.
for w in "${touched_writers[@]}"; do
  consumers_list="${writer_consumers[$w]}"
  while IFS= read -r consumer; do
    [ -n "$consumer" ] || continue
    consumer_escaped="${consumer//\//\\/}"
    probe_line="$(printf '%s\n' "$body" | sed -nE "s/^ПОТРЕБИТЕЛЬ[[:space:]]+${consumer_escaped}[[:space:]]*:[[:space:]]*(.+)$/\\1/p" | head -n 1)"
    if [ -z "$probe_line" ]; then
      die "потребители 116: писатель $w изменён, потребитель $consumer не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы"
    fi
    _probe_out_file="$(mktemp -t probe116.XXXXXX 2>/dev/null || mktemp)"
    ( cd "$ROOT" && sh -c "$probe_line" ) > "$_probe_out_file" 2>&1 &
    pid=$!
    i=0
    timed_out=0
    while [ "$i" -lt 60 ] && kill -0 "$pid" 2>/dev/null; do
      sleep 1
      i=$((i + 1))
    done
    if kill -0 "$pid" 2>/dev/null; then
      kill -9 "$pid" 2>/dev/null || true
      timed_out=1
    fi
    wait "$pid" 2>/dev/null
    rc=$?
    /usr/bin/rm -f "$_probe_out_file"
    if [ "$timed_out" -eq 1 ]; then
      die "потребители 116: ПОТРЕБИТЕЛЬ-проба превысила таймаут: $consumer"
    fi
    if [ "$rc" != "0" ]; then
      die "потребители 116: ПОТРЕБИТЕЛЬ-проба красна: $consumer: rc $rc"
    fi
  done <<< "$consumers_list"
done

# ── п1-b (замер): если хоть один писатель тронут, контракт обязан нести замер-строку ──
# census-совместимая форма: «замер: `<cmd>` = N census <glob>». Гейт проверяет
# НАЛИЧИЕ строки (исполнение и пересчёт — грамматика 036-В2 на заморозке
# носителя, здесь — наличие).
# Регистратор маппинга (ЭТОТ контракт 038) — на его frozen-теге consumers.d ещё нет
# (живой случай: 038 материализует consumers.d реализацией). Признак объективный:
# git ls-tree <frozen-тег> scripts/consumers.d/ пуст.
if git -C "$ROOT" ls-tree -r --name-only "$last_frozen" -- scripts/consumers.d/ 2>/dev/null | grep -q .; then
  census_pattern='^замер:[[:space:]]*`cat[[:space:]]+scripts/consumers\.d/\*\.tsv[[:space:]]*[|][[:space:]]*wc[[:space:]]+-l`[[:space:]]*=[[:space:]]*[0-9]+[[:space:]]+census[[:space:]]+scripts/consumers\.d/\*\.tsv[[:space:]]*$'
  if ! printf '%s\n' "$body" | grep -Eq "$census_pattern"; then
    tw_list=""
    for w in "${touched_writers[@]}"; do tw_list="$tw_list $w"; done
    die "потребители 116: замер маппинга отсутствует (контракт правит писателя$tw_list)"
  fi
fi

exit 0
