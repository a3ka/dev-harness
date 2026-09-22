#!/usr/bin/env bash
# Р10 (green, self-application, ОБЯЗАТЕЛЬНАЯ фикстура §Инварианты п.2(v)) —
# check_threat_model.sh на СОБСТВЕННОМ буквальном тексте контракта 041: этот
# контракт ВВОДИТ гард, парсящий поле «## Модель угроз», и это поле
# встречается В САМОМ 041 — self-application-green ДО заморозки.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

CONTRACT_REL="$(cd "$REPO/contracts" && ls 041-*.md 2>/dev/null | head -n1)"
[ -n "$CONTRACT_REL" ] || { printf 'ОТКАЗ: case_10: contracts/041-*.md не найден на дереве\n' >&2; exit 1; }
run_barrier "$REPO" "contracts/$CONTRACT_REL"
accept 'case_10 (self-application на 041)'
exit 0
