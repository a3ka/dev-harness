#!/usr/bin/env bash
# ПРИЧИНА: модель угроз: список НЕ ЗАЩИЩАЕТ: пуст (нет буллета)
# Р5 (red) — НЕ ЗАЩИЩАЕТ: присутствует, но без единого буллета сразу после
# метки → rc 1, именованная причина. Зелёная половина (конверсия на
# протокол verify_antiplacebo.sh, находка Н1
# verdicts/review/contracts-041-k1.md) — положительный контроль: полный
# честный вход → rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/tm_case05.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

put_contract "$WORK/g.md" '# kontrakt

## Predmet
p

## Модель угроз

ЗАЩИЩАЕТ:
- корректный разбор буллетов независимо от их текстового содержимого и знаков

НЕ ЗАЩИЩАЕТ:
- враждебное окружение вызывающего процесса за пределами базового PATH-экспорта'
run_barrier "$WORK" 'g.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && accept 'case_05 (зелёный: полный честный вход)'

put_contract "$WORK/r.md" '# kontrakt

## Predmet
p

## Модель угроз

ЗАЩИЩАЕТ:
- корректный разбор буллетов независимо от их текстового содержимого и знаков

НЕ ЗАЩИЩАЕТ:'
run_barrier "$WORK" 'r.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && refuse 'case_05 (красный)' 'модель угроз: список НЕ ЗАЩИЩАЕТ: пуст (нет буллета)'

exit 0
