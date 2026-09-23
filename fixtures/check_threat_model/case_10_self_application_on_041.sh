#!/usr/bin/env bash
# ПРИЧИНА: модель угроз: список ЗАЩИЩАЕТ: отсутствует
# Р10 (green, self-application, ОБЯЗАТЕЛЬНАЯ фикстура §Инварианты п.2(v)) —
# check_threat_model.sh на СОБСТВЕННОМ буквальном тексте контракта 041: этот
# контракт ВВОДИТ гард, парсящий поле «## Модель угроз», и это поле
# встречается В САМОМ 041 — self-application-green ДО заморозки.
#
# Красная половина (конверсия на протокол verify_antiplacebo.sh, находка Н1
# verdicts/review/contracts-041-k1.md) — простой форженый вход на ДРУГОМ
# (не «contracts/041-*») пути, чтобы у этого case была своя пара
# зелёный/красный независимо от case_11 (который специально испытывает
# path-паттерн-стаб на ТОМ ЖЕ относительном пути, что и настоящий 041).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/tm_case10.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

CONTRACT_REL="$(cd "$REPO/contracts" && ls 041-*.md 2>/dev/null | head -n1)"
[ -n "$CONTRACT_REL" ] || { printf 'ОТКАЗ: case_10: contracts/041-*.md не найден на дереве\n' >&2; exit 1; }
run_barrier "$REPO" "contracts/$CONTRACT_REL"
[ "${BARRIER:-x}" = "$SUBJ" ] && accept 'case_10 (зелёный: self-application на 041)'

put_contract "$WORK/r.md" '# kontrakt

## Predmet
p

## Модель угроз

НЕ ЗАЩИЩАЕТ:
- враждебное окружение вызывающего процесса за пределами базового PATH-экспорта'
run_barrier "$WORK" 'r.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && refuse 'case_10 (красный: форженый вход на другом пути)' 'модель угроз: список ЗАЩИЩАЕТ: отсутствует'

exit 0
