#!/usr/bin/env bash
# 189 — ОБМАННАЯ РЕАЛИЗАЦИЯ (батарея): дом установки и command -v удалены.
# Дефект: резолв ТОЛЬКО через шов VALIDATE_STD_ACTIONLINT/SHELLCHECK — без шва
# инструмент «отсутствует», даже если он установлен в доме установки с
# пин-совпадающим sha (главный потребительский путь предмета 189).
# Различающий вход: клетка v18 (среда без швов бинарей, пин-совпадающий бинарь
# в доме установки — честный субъект обязан его ЗАПУСТИТЬ, rc инструмента 0).
set -uo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PINS="${VALIDATE_STD_PINS:-$SELF_DIR/../ops/server/validators.tsv}"
PY="${VALIDATE_STD_PYTHON:-python3}"

otkaz2() { printf '%s\n' "$*" >&2; exit 2; }

pin_kolonki() { # $1=инструмент → "version<TAB>sha256" (пусто, если строки нет)
  awk -F'\t' -v t="$1" '$1 == t { printf "%s\t%s\n", $2, $3; exit }' "$PINS" 2>/dev/null
}

sha256_faila() { sha256sum "$1" 2>/dev/null | awk '{ print $1 }'; }

rezolve_bin() { # ДЕФЕКТ: ветви «дом установки» и «command -v» удалены
  local instrument="$1" shev="$2" bin="" ver pin fakt
  bin="${!shev:-}"
  [ -n "$bin" ] || otkaz2 "VALIDATOR_MISSING: $instrument"
  [ -n "$bin" ] && [ -f "$bin" ] || otkaz2 "VALIDATOR_MISSING: $instrument"
  IFS="$(printf '\t')" read -r ver pin <<< "$(pin_kolonki "$instrument")"
  [ -n "$ver" ] || otkaz2 "VALIDATOR_MISSING: $instrument (нет строки пина: $PINS)"
  [ -n "$pin" ] || otkaz2 "VALIDATOR_MISSING: $instrument (пин без sha256: $PINS)"
  fakt="$(sha256_faila "$bin")"
  [ -n "$fakt" ] || otkaz2 "VALIDATOR_MISSING: $instrument (sha256 не читается: $bin)"
  [ "$fakt" = "$pin" ] || otkaz2 "VALIDATOR_PIN: $instrument фактический $fakt ≠ пин $pin"
  printf '%s\n' "$bin"
}

[ -f "$PINS" ] || otkaz2 "VALIDATOR_PINS: файл пинов не найден: $PINS"

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
