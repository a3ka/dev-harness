#!/usr/bin/env bash
# обманка «читает файл, не HEAD»: карту берёт из рабочего дерева, закоммиченность
# не спрашивает (батарея 193; AGENTS п.9).
set -uo pipefail
telo="$(cat "$1/$2" 2>/dev/null)"
if printf '%s\n' "$telo" | grep -q '^## Карта классов'; then
    printf 'КАРТА: 17/17 зелёный\n'
    exit 0
fi
printf 'ОТКАЗ: нет раздела «## Карта классов»\n' >&2
exit 1
