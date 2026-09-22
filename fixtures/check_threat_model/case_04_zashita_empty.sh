#!/usr/bin/env bash
# Р4 (red) — ЗАЩИЩАЕТ: присутствует, но без единого буллета сразу после метки
# (пустая строка обрывает список) → rc 1, именованная причина.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

W="$(mktemp -d "${TMPDIR:-/tmp}/tm_case04.XXXXXX")"; trap 'rm -rf "$W"' EXIT
F="$W/c.md"
put_contract "$F" '# kontrakt

## Predmet
p

## Модель угроз

ЗАЩИЩАЕТ:

НЕ ЗАЩИЩАЕТ:
- враждебное окружение вызывающего процесса за пределами базового PATH-экспорта'
run_barrier "$W" 'c.md'
refuse 'case_04' 'модель угроз: список ЗАЩИЩАЕТ: пуст (нет буллета)'
exit 0
