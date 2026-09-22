#!/usr/bin/env bash
# Р6 (red) — буллет ниже порога формы (< 4 слов И < 24 знаков) → rc 1,
# именованная причина с буллетом дословно.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

W="$(mktemp -d "${TMPDIR:-/tmp}/tm_case06.XXXXXX")"; trap 'rm -rf "$W"' EXIT
F="$W/c.md"
put_contract "$F" '# kontrakt

## Predmet
p

## Модель угроз

ЗАЩИЩАЕТ:
- корректный разбор буллетов независимо от их текстового содержимого и знаков

НЕ ЗАЩИЩАЕТ:
- мало слов тут'
run_barrier "$W" 'c.md'
refuse 'case_06' 'модель угроз: буллет ниже порога формы: мало слов тут'
exit 0
