#!/usr/bin/env bash
# Р5 (red) — НЕ ЗАЩИЩАЕТ: присутствует, но без единого буллета сразу после
# метки → rc 1, именованная причина.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

W="$(mktemp -d "${TMPDIR:-/tmp}/tm_case05.XXXXXX")"; trap 'rm -rf "$W"' EXIT
F="$W/c.md"
put_contract "$F" '# kontrakt

## Predmet
p

## Модель угроз

ЗАЩИЩАЕТ:
- корректный разбор буллетов независимо от их текстового содержимого и знаков

НЕ ЗАЩИЩАЕТ:'
run_barrier "$W" 'c.md'
refuse 'case_05' 'модель угроз: список НЕ ЗАЩИЩАЕТ: пуст (нет буллета)'
exit 0
