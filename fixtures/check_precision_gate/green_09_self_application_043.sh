#!/usr/bin/env bash
# ПРИЧИНА: self-application (норма 041 §Инварианты п.2(v)/п.5) — этот гард
# парсит ЗОНА/ПЕРЕСЕЧЕНИЕ, оба поля встречаются в самом контракте 043,
# вводящем этот гард; прогон на НАСТОЯЩЕМ дереве репозитория, НАСТОЯЩЕМ
# contracts/043-*.md → rc 0 обязателен ДО заморозки (battery_self_application_green
# использует ЭТОТ же путь).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
fi

CONTRACT_REL="$(cd "$REPO" && printf '%s\n' contracts/043-*.md | head -n1)"
[ -f "$REPO/$CONTRACT_REL" ] || { printf 'ОТКАЗ: contracts/043-*.md не найден в %s\n' "$REPO" >&2; exit 1; }

run_barrier "$REPO" "$CONTRACT_REL"
[ "${BARRIER:-x}" = "$SUBJ" ] && accept 'case_09 (self-application на реальном 043)'
exit 0
