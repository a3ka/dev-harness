#!/usr/bin/env bash
# 189 — ОБМАННАЯ РЕАЛИЗАЦИЯ (батарея): лишние аргументы молча отбрасываются.
# Дефект (Б-1 ревьюера contracts-189-impl-v1): workflow/bash проверяют лишь
# непустоту $1, json — лишь «не меньше двух»; вызов с несколькими файлами
# проверяет первый и молча даёт rc 0 по непроверенным остальным.
# Различающий вход: клетка v36 (bash: честный скрипт + сломанный sintaksis.sh —
# обманка даёт rc 0 по первому файлу, ожидание клетки rc 2 NOT_IMPLEMENTED).
set -uo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PINS="${VALIDATE_STD_PINS:-$SELF_DIR/../ops/server/validators.tsv}"
PY="${VALIDATE_STD_PYTHON:-python3}"

otkaz2() { printf '%s\n' "$*" >&2; exit 2; }

pin_kolonki() { # $1=инструмент → "version<TAB>sha256" (пусто, если строки нет);
  # rc≠0 — пин-файл НЕ ЧИТАЕТСЯ (awk его не открывает). Три состояния пин-файла
  # различимы (Блок 4 критика, вызов 3): «файла нет»/«не читается» →
  # VALIDATOR_PINS ДО резолва, «файл цел, строки нет» → VALIDATOR_MISSING.
  awk -F'\t' -v t="$1" '$1 == t { printf "%s\t%s\n", $2, $3; exit }' "$PINS" 2>/dev/null
}

sha256_faila() { sha256sum "$1" 2>/dev/null | awk '{ print $1 }'; }

rezolve_bin() { # $1=инструмент, $2=имя шва ENV → путь проверенного бинаря
  local instrument="$1" shev="$2" bin="" ver pin fakt vp
  bin="${!shev:-}"
  if [ -z "$bin" ]; then
    vp="$(pin_kolonki "$instrument")" \
      || otkaz2 "VALIDATOR_PINS: файл пинов не читается: $PINS"
    IFS="$(printf '\t')" read -r ver pin <<< "$vp"
    [ -n "$ver" ] || otkaz2 "VALIDATOR_MISSING: $instrument (нет строки пина: $PINS)"
    bin="$HOME/.local/state/dev-harness/validators/$instrument/$ver/$instrument"
    if [ ! -f "$bin" ]; then
      bin="$(command -v "$instrument" 2>/dev/null || true)"
    fi
  fi
  [ -n "$bin" ] && [ -f "$bin" ] || otkaz2 "VALIDATOR_MISSING: $instrument"
  vp="$(pin_kolonki "$instrument")" \
    || otkaz2 "VALIDATOR_PINS: файл пинов не читается: $PINS"
  IFS="$(printf '\t')" read -r ver pin <<< "$vp"
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
    # ДЕФЕКТ: проверяется лишь непустота $1, лишние аргументы молча теряются.
    [ -n "${1:-}" ] || otkaz2 "NOT_IMPLEMENTED: validate_std.sh workflow <файл>"
    bin="$(rezolve_bin actionlint VALIDATE_STD_ACTIONLINT)" || exit $?
    "$bin" "$1"
    exit $?
    ;;
  bash)
    # ДЕФЕКТ: проверяется лишь непустота $1, лишние аргументы молча теряются.
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
    # ДЕФЕКТ: проверяется лишь «не меньше двух», третий и далее молча теряются.
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
