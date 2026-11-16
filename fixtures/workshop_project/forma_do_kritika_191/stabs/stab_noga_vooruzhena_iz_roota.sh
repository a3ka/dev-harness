#!/usr/bin/env bash
# 191 — ОБМАННАЯ РЕЛИЗАЦИЯ (батарея): нога вооружена от КОРНЯ ДВЕРИ (ROOT),
# а не от судимого дерева (BASE) — прочтение, на котором держался postimpl2
# вердикта 191 v1 (Б-1). Дефект: на --repo-дереве без гейтов формы ноги
# харнесса судят чужой мир — guard-only toy-контракт даёт rc 1 «проводка
# красна», и замороженная батарея 103 падает клетками i2 (tasks/h/777-toy.md).
# На входах без --repo неотличима от честной (BASE==ROOT). Различающий
# вход: клетка r01 (дверь из вооружённого мира, --repo в мир без гейтов
# формы с guard-only контрактом).
set -uo pipefail

REPO_ARG=""
CONTRACT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      REPO_ARG="${2:?использование: pre_critic.sh [--repo R] <отн-путь-контракта>}"
      shift 2
      ;;
    *)
      [ -z "$CONTRACT" ] || { printf 'использование: pre_critic.sh [--repo R] <отн-путь-контракта>\n' >&2; exit 1; }
      CONTRACT="$1"
      shift
      ;;
  esac
done
[ -n "$CONTRACT" ] || { printf 'использование: pre_critic.sh [--repo R] <отн-путь-контракта>\n' >&2; exit 1; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P 2>/dev/null)" \
  || { printf 'NOT_IMPLEMENTED: нет корня скрипта\n' >&2; exit 2; }
if [ -n "$REPO_ARG" ]; then
  BASE="$(cd "$REPO_ARG" 2>/dev/null && pwd -P 2>/dev/null)" \
    || { printf 'NOT_IMPLEMENTED: нет корня проекта: %s\n' "$REPO_ARG" >&2; exit 2; }
else
  BASE="$ROOT"
fi
CONTRACT_FILE="$BASE/$CONTRACT"
[ -f "$CONTRACT_FILE" ] || { printf 'NOT_IMPLEMENTED: контракт не найден: %s\n' "$CONTRACT" >&2; exit 2; }
[ -r "$CONTRACT_FILE" ] || { printf 'NOT_IMPLEMENTED: контракт не читается: %s\n' "$CONTRACT" >&2; exit 2; }

refuse() { printf 'ОТКАЗ: %s\n' "$1" >&2; exit 1; }

# ДЕФЕКТ: скрипт гейта и [ -x ] — от ROOT (корень двери), не от BASE.
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
noga "проводка красна" "scripts/check_provodka.sh" --grammar "$BASE" "$CONTRACT"

printf 'КРИТИК: дверь зелёная\n'
exit 0
