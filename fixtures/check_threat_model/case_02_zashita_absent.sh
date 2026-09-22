#!/usr/bin/env bash
# Р2 (red) — список ЗАЩИЩАЕТ: отсутствует целиком, НЕ ЗАЩИЩАЕТ: честен →
# rc 1, именованная причина.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

W="$(mktemp -d "${TMPDIR:-/tmp}/tm_case02.XXXXXX")"; trap 'rm -rf "$W"' EXIT
F="$W/c.md"
put_contract "$F" '# kontrakt

## Predmet
p

## Модель угроз

НЕ ЗАЩИЩАЕТ:
- враждебное окружение вызывающего процесса за пределами базового PATH-экспорта'
run_barrier "$W" 'c.md'
refuse 'case_02' 'модель угроз: список ЗАЩИЩАЕТ: отсутствует'
exit 0
