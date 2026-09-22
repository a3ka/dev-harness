#!/usr/bin/env bash
# Р3 (red) — список НЕ ЗАЩИЩАЕТ: отсутствует целиком, ЗАЩИЩАЕТ: честен →
# rc 1, именованная причина.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

W="$(mktemp -d "${TMPDIR:-/tmp}/tm_case03.XXXXXX")"; trap 'rm -rf "$W"' EXIT
F="$W/c.md"
put_contract "$F" '# kontrakt

## Predmet
p

## Модель угроз

ЗАЩИЩАЕТ:
- корректный разбор буллетов независимо от их текстового содержимого и знаков'
run_barrier "$W" 'c.md'
refuse 'case_03' 'модель угроз: список НЕ ЗАЩИЩАЕТ: отсутствует'
exit 0
