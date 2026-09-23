#!/usr/bin/env bash
# ПРИЧИНА: модель угроз: буллет ниже порога формы: мало слов тут
# Р6 (red) — буллет ниже порога формы (< 4 слов И < 24 знаков) → rc 1,
# именованная причина с буллетом дословно. Зелёная половина (конверсия на
# протокол verify_antiplacebo.sh, находка Н1
# verdicts/review/contracts-041-k1.md) — положительный контроль: полный
# честный вход → rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/tm_case06.XXXXXX")"
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
[ "${BARRIER:-x}" = "$SUBJ" ] && accept 'case_06 (зелёный: полный честный вход)'

put_contract "$WORK/r.md" '# kontrakt

## Predmet
p

## Модель угроз

ЗАЩИЩАЕТ:
- корректный разбор буллетов независимо от их текстового содержимого и знаков

НЕ ЗАЩИЩАЕТ:
- мало слов тут'
run_barrier "$WORK" 'r.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && refuse 'case_06 (красный)' 'модель угроз: буллет ниже порога формы: мало слов тут'

exit 0
