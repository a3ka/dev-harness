#!/usr/bin/env bash
# s8_molchalivyj.sh — ОБМАННЫЙ СТАБ: класс «пусто-зелёное» — всегда rc 0, молча,
# без единой строки вердикта. Наблюдаемая ложь: d0_chistoe — компаратор даёт
# именованный отказ «пустая выборка ПОСЛЕ» (сверка структурная, не «не краснеет»).
# Каркас не используется: у лжи нет ветвей.
[ -n "${RED113_REAL_CHARTER:-}" ] || { printf 'СТАБ: нет RED113_REAL_CHARTER\n' >&2; exit 125; }
for a in "$@"; do
  if [ "$a" = "--oracle" ]; then shift; exec bash "$RED113_REAL_CHARTER" "$@"; fi
done
exit 0
