#!/usr/bin/env bash
# 189 — ОБМАНКА: пин-файл только из ENV, дефолт снят (мутант A1b критика,
# вызов 2): резолв пин-файла по умолчанию удалён, пре-чек файла снят. На входе
# клетки v26-defolt-chestnyj (вариант-корень с пин-файлом мира на ДЕФОЛТНОМ
# месте, среда без единого VALIDATE_STD_*) дефект наблюдаем: VALIDATE_STD_PINS
# в среде нет → PINS пуст → VALIDATOR_MISSING rc 2 вместо rc 0 — станционный
# путь «одной командой без швов» (Предмет (а)) сломан. На клетках со швом
# VALIDATE_STD_PINS стаб честен — краснота там не требуется (Н-39).
set -uo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PINS="${VALIDATE_STD_PINS:-}"
PY="${VALIDATE_STD_PYTHON:-python3}"

otkaz2() { printf '%s\n' "$*" >&2; exit 2; }

pin_kolonki() { # $1=инструмент → "version<TAB>sha256" (пусто, если строки нет)
  awk -F'\t' -v t="$1" '$1 == t { printf "%s\t%s\n", $2, $3; exit }' "$PINS" 2>/dev/null
}

sha256_faila() { sha256sum "$1" 2>/dev/null | awk '{ print $1 }'; }

rezolve_bin() { # $1=инструмент, $2=имя шва ENV → путь проверенного бинаря
  local instrument="$1" shev="$2" bin="" ver pin fakt
  bin="${!shev:-}"
  if [ -z "$bin" ]; then
    IFS="$(printf '\t')" read -r ver pin <<< "$(pin_kolonki "$instrument")"
    [ -n "$ver" ] || otkaz2 "VALIDATOR_MISSING: $instrument (нет строки пина: $PINS)"
    bin="$HOME/.local/state/dev-harness/validators/$instrument/$ver/$instrument"
    if [ ! -f "$bin" ]; then
      bin="$(command -v "$instrument" 2>/dev/null || true)"
    fi
  fi
  [ -n "$bin" ] && [ -f "$bin" ] || otkaz2 "VALIDATOR_MISSING: $instrument"
  IFS="$(printf '\t')" read -r ver pin <<< "$(pin_kolonki "$instrument")"
  [ -n "$ver" ] || otkaz2 "VALIDATOR_MISSING: $instrument (нет строки пина: $PINS)"
  [ -n "$pin" ] || otkaz2 "VALIDATOR_MISSING: $instrument (пин без sha256: $PINS)"
  fakt="$(sha256_faila "$bin")"
  [ -n "$fakt" ] || otkaz2 "VALIDATOR_MISSING: $instrument (sha256 не читается: $bin)"
  [ "$fakt" = "$pin" ] || otkaz2 "VALIDATOR_PIN: $instrument фактический $fakt ≠ пин $pin"
  printf '%s\n' "$bin"
}

mode="${1:-}"
[ "$#" -gt 0 ] && shift

case "$mode" in
  workflow)
    [ -n "${1:-}" ] || otkaz2 "NOT_IMPLEMENTED: validate_std.sh workflow <файл>"
    bin="$(rezolve_bin actionlint VALIDATE_STD_ACTIONLINT)" || exit $?
    "$bin" "$1"
    exit $?
    ;;
  bash)
    [ -n "${1:-}" ] || otkaz2 "NOT_IMPLEMENTED: validate_std.sh bash <файл>"
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
    if [ "$#" -lt 2 ] || [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
      otkaz2 "NOT_IMPLEMENTED: validate_std.sh json <схема> <документ>"
    fi
    "$PY" "$SELF_DIR/validate_std_json.py" "$1" "$2"
    exit $?
    ;;
  *)
    otkaz2 "NOT_IMPLEMENTED: режим неизвестен: ${mode:-<пусто>}; использование: validate_std.sh workflow <файл> | bash <файл> | json <схема> <документ>"
    ;;
esac
