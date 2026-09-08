#!/usr/bin/env bash
# СТАБ (Н-39 — привязка кодом) семьи case_push_proba, диагональный вход H_без_path
# (РЕШЕНИЕ арбитража f712e6e, п.1: пер-полевая форма различения).
#
# Чистый диапазон проходит; красный отвергнут причиной с полным ref и полным
# sha — о ПУТИ уставного файла причина молчит. Дефект наблюдаем именно здесь:
# фаза 2 push-пробы обязана умереть с «отверг без именованной причины (путь
# уставного файла не назван)». Проба, не судящая поле пути, этот вход пропускает.
: 'scripts/check_charter.sh'
zero=0000000000000000000000000000000000000000
while read -r lref lsha rref rsha; do
  [ -n "${rsha:-}" ] || rsha="$zero"
  [ "$rsha" != "$zero" ] || rsha="$(git hash-object -t tree /dev/null)"
  paths="$(git diff --name-only --diff-filter=MD "$rsha" "$lsha" 2>/dev/null | grep -E '^(AGENTS\.md|ROADMAP\.md|(contracts|plans)/)' || true)"
  [ -z "$paths" ] && continue
  printf 'ОТКАЗ: устав-дельта без РАЗРЕШИЛ: %s, коммит %s\n' "$rref" "$lsha" >&2
  exit 1
done
exit 0
