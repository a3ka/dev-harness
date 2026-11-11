#!/usr/bin/env bash
# ЧЕСТНАЯ МОДЕЛЬ предмета 191 — три ноги формы в двери перед критиком.
# Это модель НОГ (ж/з/и), не двойник всей двери 072: аргументация ног,
# именованные отказы, семантика пропуска и fail-closed — дословно те,
# что контракт 191 требует от scripts/pre_critic.sh. Порядок ж→з→и.
set -uo pipefail

CONTRACT="${1:?использование: pre_critic.sh <отн-путь-контракта>}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет корня скрипта\n' >&2; exit 2; }
BASE="$ROOT"
CONTRACT_FILE="$BASE/$CONTRACT"
[ -f "$CONTRACT_FILE" ] || { printf 'NOT_IMPLEMENTED: контракт не найден: %s\n' "$CONTRACT" >&2; exit 2; }
[ -r "$CONTRACT_FILE" ] || { printf 'NOT_IMPLEMENTED: контракт не читается: %s\n' "$CONTRACT" >&2; exit 2; }

refuse() { printf 'ОТКАЗ: %s\n' "$1" >&2; exit 1; }

# noga <маркер-фраза> <гейт-скрипт> [аргументы…]
# Отсутствие гейта в корне — ПРОПУСК ноги (канон д2/д3: чужие toy-миры).
# Любой ненулевой rc гейта (1 и 2) — отказ: fail-closed, «нечем проверить» ≠ проверено.
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

# ── (ж) модель угроз (контракт 041: форма секции) ──
noga "модель угроз красна" "scripts/check_threat_model.sh" "$BASE" "$CONTRACT"

# ── (з) потолки и раздел незаполненных требований (контракты 004/013) ──
noga "потолки красны" "scripts/check_ceilings.sh" "$BASE"

# ── (и) грамматика каналов ПРОВОДКА (контракт 038, режим --grammar) ──
noga "проводка красна" "scripts/check_provodka.sh" --grammar "$BASE" "$CONTRACT"

printf 'КРИТИК: дверь зелёная\n'
exit 0
