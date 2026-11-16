#!/usr/bin/env bash
# 191 — ОБМАННАЯ РЕАЛИЗАЦИЯ (батарея): ноги потолков НЕТ.
# Дефект: check_ceilings.sh не вызывается — черновик без раздела
# незаполненных требований проходит дверь зелёной. Различающий вход: клетка m03.
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
noga "проводка красна" "scripts/check_provodka.sh" --grammar "$BASE" "$CONTRACT"
printf 'КРИТИК: дверь зелёная\n'
exit 0
