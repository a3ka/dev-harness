#!/usr/bin/env bash
# 191 — ОБМАННАЯ РЕАЛИЗАЦИЯ (батарея): ноги проводки НЕТ.
# Дефект: check_provodka.sh --grammar не вызывается — строка ПРОВОДКА вне
# грамматики каналов проходит дверь зелёной. Различающий вход: клетка p01.
set -uo pipefail
CONTRACT="${1:?использование: pre_critic.sh <отн-путь-контракта>}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет корня скрипта\n' >&2; exit 2; }
BASE="$ROOT"
CONTRACT_FILE="$BASE/$CONTRACT"
[ -f "$CONTRACT_FILE" ] || { printf 'NOT_IMPLEMENTED: контракт не найден: %s\n' "$CONTRACT" >&2; exit 2; }
refuse() { printf 'ОТКАЗ: %s\n' "$1" >&2; exit 1; }
noga() {
  local marker="$1" script="$2"; shift 2
  [ -x "$ROOT/$script" ] || return 0
  local rc=0 out
  out="$(bash "$ROOT/$script" "$@" 2>&1)" || rc=$?
  if [ "$rc" -ne 0 ]; then
    refuse "$marker (rc=$rc): $(printf '%s' "$out" | head -n 1)"
  fi
  printf '  ok   %s\n' "$marker" >&2
}
noga "модель угроз красна" "scripts/check_threat_model.sh" "$BASE" "$CONTRACT"
noga "потолки красны" "scripts/check_ceilings.sh" "$BASE"
printf 'КРИТИК: дверь зелёная\n'
exit 0
