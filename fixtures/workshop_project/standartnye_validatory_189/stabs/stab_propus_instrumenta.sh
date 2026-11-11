#!/usr/bin/env bash
# 189 — ОБМАННАЯ РЕАЛИЗАЦИЯ (батарея): отсутствующий инструмент — «пропуск» с rc 0.
# Дефект: skip → pass вместо именованного rc 2 VALIDATOR_MISSING.
# Различающий вход: клетка v06 (шов указывает на несуществующий бинарь).
set -uo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PINS="${VALIDATE_STD_PINS:-$SELF_DIR/../ops/server/validators.tsv}"
PY="${VALIDATE_STD_PYTHON:-python3}"

otkaz2() { printf '%s\n' "$*" >&2; exit 2; }

[ -f "$PINS" ] || otkaz2 "VALIDATOR_PINS: файл пинов не найден: $PINS"

mode="${1:-}"
[ "$#" -gt 0 ] && shift

case "$mode" in
  workflow)
    [ -n "${1:-}" ] || otkaz2 "NOT_IMPLEMENTED: validate_std.sh workflow <файл>"
    bin="${VALIDATE_STD_ACTIONLINT:-}"
    if [ -z "$bin" ] || [ ! -f "$bin" ]; then
      # ДЕФЕКТ: инструмента нет — предупреждение и rc 0, проверка «пройдена».
      printf 'предупреждение: actionlint не найден, проверка пропущена\n' >&2
      exit 0
    fi
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
    bin="${VALIDATE_STD_SHELLCHECK:-}"
    if [ -z "$bin" ] || [ ! -f "$bin" ]; then
      printf 'предупреждение: shellcheck не найден, проверка пропущена\n' >&2
      exit 0
    fi
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
    otkaz2 "NOT_IMPLEMENTED: режим неизвестен: ${mode:-<пусто>}"
    ;;
esac
