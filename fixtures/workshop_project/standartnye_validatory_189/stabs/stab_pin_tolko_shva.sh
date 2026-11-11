#!/usr/bin/env bash
# 189 — ОБМАННАЯ РЕАЛИЗАЦИЯ (батарея): sha256 сверяется только для шва.
# Дефект: цепочка резолва цела (шов → дом установки → command -v), но пин
# проверяется ТОЛЬКО у бинаря, пришедшего через шов; найденный в доме или в
# PATH бинарь запускается без сверки — подмена в PATH проходит молча.
# Различающий вход: клетка v21 (среда без швов бинарей, actionlint с иным
# sha256 первым в PATH — честный субъект обязан отказать rc 2 VALIDATOR_PIN).
set -uo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PINS="${VALIDATE_STD_PINS:-$SELF_DIR/../ops/server/validators.tsv}"
PY="${VALIDATE_STD_PYTHON:-python3}"

otkaz2() { printf '%s\n' "$*" >&2; exit 2; }

pin_kolonki() { # $1=инструмент → "version<TAB>sha256" (пусто, если строки нет)
  awk -F'\t' -v t="$1" '$1 == t { printf "%s\t%s\n", $2, $3; exit }' "$PINS" 2>/dev/null
}

sha256_faila() { sha256sum "$1" 2>/dev/null | awk '{ print $1 }'; }

rezolve_bin() { # ДЕФЕКТ: пин — только для шва; дом/PATH — без сверки sha256
  local instrument="$1" shev="$2" bin="" ver pin fakt shevoj=""
  bin="${!shev:-}"
  if [ -z "$bin" ]; then
    IFS="$(printf '\t')" read -r ver pin <<< "$(pin_kolonki "$instrument")"
    [ -n "$ver" ] || otkaz2 "VALIDATOR_MISSING: $instrument (нет строки пина: $PINS)"
    bin="$HOME/.local/state/dev-harness/validators/$instrument/$ver/$instrument"
    if [ ! -f "$bin" ]; then
      bin="$(command -v "$instrument" 2>/dev/null || true)"
    fi
  else
    shevoj="1"
  fi
  [ -n "$bin" ] && [ -f "$bin" ] || otkaz2 "VALIDATOR_MISSING: $instrument"
  if [ -n "$shevoj" ]; then
    IFS="$(printf '\t')" read -r ver pin <<< "$(pin_kolonki "$instrument")"
    [ -n "$ver" ] || otkaz2 "VALIDATOR_MISSING: $instrument (нет строки пина: $PINS)"
    [ -n "$pin" ] || otkaz2 "VALIDATOR_MISSING: $instrument (пин без sha256: $PINS)"
    fakt="$(sha256_faila "$bin")"
    [ -n "$fakt" ] || otkaz2 "VALIDATOR_MISSING: $instrument (sha256 не читается: $bin)"
    [ "$fakt" = "$pin" ] || otkaz2 "VALIDATOR_PIN: $instrument фактический $fakt ≠ пин $pin"
  fi
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
