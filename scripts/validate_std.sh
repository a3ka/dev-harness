#!/usr/bin/env bash
# НЕ БАРЬЕР: субъект (SUBJECT) батареи fixtures/workshop_project/standartnye_validatory_189/
# red_standartnye_validatory_189.sh; приёмка предмета 189 (контракт
# contracts/189-standartnye-validatory-i-kanon.md, инварианты 1–3) — красная проба на
# сам scripts/validate_std.sh (режимы --repo/--model/--stabs), не сам скрипт;
# контракт 189 §Проводка: guard=fixtures/workshop_project/standartnye_validatory_189/red_standartnye_validatory_189.sh.
#
# Обёртка стандартных валидаторов станции: workflow — actionlint, bash — `bash -n`
# и shellcheck, json — JSON Schema (Draft 2020-12) движком scripts/validate_std_json.py.
# Пин-дисциплина: бинарь запускается ТОЛЬКО после сверки его sha256 с пином репо
# (ops/server/validators.tsv); выход валидатора пробрасывается буквально — «успех» по
# тексту вывода не признаётся. Отсутствие (инструмента, пина, среды) — именованный
# отказ rc 2, никогда пропуск проверки со зелёным кодом.
#
# Возвращаемые коды: 0 — валидатор прошёл; 1 — валидатор нашёл нарушение (rc бинаря
# пробрасывается буквально); 2 — именованный отказ: VALIDATOR_PINS/VALIDATOR_MISSING/
# VALIDATOR_PIN/SYNTAX/ENGINE_*/NOT_IMPLEMENTED.
set -uo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# Пины бинарей: один файл на оба скрипта предмета (инвариант 2). Шов —
# для стендовых миров; по умолчанию — файл репо рядом с обёрткой.
PINS="${VALIDATE_STD_PINS:-$SELF_DIR/../ops/server/validators.tsv}"
# Интерпретатор субъекта для режима json (инвариант 3).
PY="${VALIDATE_STD_PYTHON:-python3}"

otkaz2() { printf '%s\n' "$*" >&2; exit 2; }

# Проверка числа позиционных аргументов режима (инвариант 3): ровно ожидаемое
# число — иначе rc 2 NOT_IMPLEMENTED с именем режима и ожидаемым числом.
# Молчаливое отбрасывание лишнего аргумента давало ложную зелень по
# непроверенному файлу (Б-1 ревьюера contracts-189-impl-v1).
proverka_argumentov() { # $1=режим $2=фактическое число $3=ожидаемое $4=использование
  [ "$2" -eq "$3" ] \
    || otkaz2 "NOT_IMPLEMENTED: режим $1 ($4): ожидается аргументов ровно $3, получено $2"
}

# Строка пина инструмента: «<версия><TAB><sha256>» в stdout; пусто — строки нет.
# rc≠0 — файл пинов НЕ ЧИТАЕТСЯ: отказ ДО резолва (инвариант 2: три различимых
# состояния пин-файла — «нет», «не читается», «строки нет»).
pin_stroka() {
  local stroka
  stroka="$(awk -F'\t' -v t="$1" '
      /^[[:space:]]*#/ { next }
      $1 == t { printf "%s\t%s\n", $2, $3; exit }' "$PINS" 2>/dev/null)" || return 1
  printf '%s\n' "$stroka"
}

# Путь бинаря, ПРОВЕРЕННОГО по пину: stdout — путь. Порядок резолва (инвариант 2):
# шов ENV → дом установки → command -v; сверка sha256 — на ЛЮБОЙ ветви (иначе подмена
# в PATH прошла бы молча).
rezolve_bin() { # <инструмент> <имя шва ENV>
  local instrument="$1" shev="$2" bin="" ver pin fakt vp
  vp="$(pin_stroka "$instrument")" \
    || otkaz2 "VALIDATOR_PINS: файл пинов не читается: $PINS"
  [ -n "$vp" ] \
    || otkaz2 "VALIDATOR_MISSING: $instrument (нет строки пина: $PINS)"
  IFS="$(printf '\t')" read -r ver pin <<< "$vp"
  [ -n "$pin" ] \
    || otkaz2 "VALIDATOR_MISSING: $instrument (пин без sha256: $PINS)"
  bin="${!shev:-}"
  if [ -z "$bin" ]; then
    if [ -n "${HOME:-}" ]; then
      bin="$HOME/.local/state/dev-harness/validators/$instrument/$ver/$instrument"
    fi
    if [ ! -f "$bin" ]; then
      bin="$(command -v "$instrument" 2>/dev/null || true)"
    fi
  fi
  [ -n "$bin" ] && [ -f "$bin" ] \
    || otkaz2 "VALIDATOR_MISSING: $instrument"
  fakt="$(sha256sum <"$bin" | cut -d' ' -f1)"
  [ -n "$fakt" ] \
    || otkaz2 "VALIDATOR_MISSING: $instrument (sha256 не читается: $bin)"
  [ "$fakt" = "$pin" ] \
    || otkaz2 "VALIDATOR_PIN: $instrument фактический $fakt ≠ пин $pin"
  printf '%s\n' "$bin"
}

[ -f "$PINS" ] || otkaz2 "VALIDATOR_PINS: файл пинов не найден: $PINS"

mode="${1:-}"
[ "$#" -gt 0 ] && shift

case "$mode" in
  workflow)
    proverka_argumentov workflow "$#" 1 "validate_std.sh workflow <файл>"
    [ -n "${1:-}" ] \
      || otkaz2 "NOT_IMPLEMENTED: режим workflow (validate_std.sh workflow <файл>): имя файла пусто"
    bin="$(rezolve_bin actionlint VALIDATE_STD_ACTIONLINT)" || exit $?
    "$bin" "$1"
    exit $?
    ;;
  bash)
    proverka_argumentov bash "$#" 1 "validate_std.sh bash <файл>"
    [ -n "${1:-}" ] \
      || otkaz2 "NOT_IMPLEMENTED: режим bash (validate_std.sh bash <файл>): имя файла пусто"
    bash -n "$1"
    rc=$?
    if [ "$rc" -ne 0 ]; then
      printf 'SYNTAX: bash -n rc=%d: %s\n' "$rc" "$1" >&2
      exit "$rc"
    fi
    bin="$(rezolve_bin shellcheck VALIDATE_STD_SHELLCHECK)" || exit $?
    "$bin" "$1"
    exit $?
    ;;
  json)
    proverka_argumentov json "$#" 2 "validate_std.sh json <схема> <документ>"
    [ -n "${1:-}" ] && [ -n "${2:-}" ] \
      || otkaz2 "NOT_IMPLEMENTED: режим json (validate_std.sh json <схема> <документ>): имя файла пусто"
    "$PY" "$SELF_DIR/validate_std_json.py" "$1" "$2"
    exit $?
    ;;
  *)
    otkaz2 "NOT_IMPLEMENTED: режим неизвестен: ${mode:-<пусто>}; использование: validate_std.sh workflow <файл> | bash <файл> | json <схема> <документ>"
    ;;
esac
