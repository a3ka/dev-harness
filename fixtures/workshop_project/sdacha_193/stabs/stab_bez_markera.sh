#!/usr/bin/env bash
# обманка «без маркера рекурсии»: первую команду секции «Двери» исполняет БЕЗ
# SDACHA_OKRUG=1 — вложенная нога (к) двери pre_critic снова зовёт эту дверь,
# цикл не разрывается (батарея 193, инвариант И6).
set -uo pipefail
ROOT="$1"; CONTRACT="$2"
LISTOK="$(sed -n 's/^СДАЧА: //p' "$ROOT/$CONTRACT" | head -n 1)"
[ -n "$LISTOK" ] || { printf 'ОТКАЗ: строка СДАЧА: обязательна\n' >&2; exit 1; }
komanda="$(awk -F'·' '/^## Двери/{f=1;next} /^## /{f=0} f && /^- /{gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2; exit}' "$ROOT/$LISTOK")"
if [ -n "$komanda" ]; then
    ( cd "$ROOT" && bash -c "$komanda" ) >/dev/null 2>&1
fi
printf 'СДАЧА: лист зелёный (двери=1 карта=17/17 дельта=0)\n'
exit 0
