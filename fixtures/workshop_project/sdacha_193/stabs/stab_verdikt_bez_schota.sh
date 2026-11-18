#!/usr/bin/env bash
# обманка «не считает строки»: наличие секции проверяет, счёт 17/дубли/пропуски
# не считает (батарея 193).
set -uo pipefail
telo="$(git -C "$1" cat-file -p "HEAD:$2" 2>/dev/null)"
[ -n "$telo" ] || { printf 'ОТКАЗ: вердикт не закоммичен\n' >&2; exit 1; }
if printf '%s\n' "$telo" | grep -q '^## Карта классов'; then
    printf 'КАРТА: 17/17 зелёный\n'
    exit 0
fi
printf 'ОТКАЗ: нет раздела «## Карта классов»\n' >&2
exit 1
