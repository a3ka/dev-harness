#!/usr/bin/env bash
# ПРИЧИНА: модель угроз: список ЗАЩИЩАЕТ: отсутствует
# Р1 (green/vacuous) — секции «## Модель угроз» нет вовсе → rc 0, вне
# применимости барьера (присутствие — cognitive-only критика, roles/critic.md).
# Красная половина (добавлена конверсией на протокол verify_antiplacebo.sh,
# находка Н1 verdicts/review/contracts-041-k1.md) — та же граница с ДРУГОЙ
# стороны: заголовок ПРИСУТСТВУЕТ, но тело до EOF пусто (ни ЗАЩИЩАЕТ:, ни
# НЕ ЗАЩИЩАЕТ:) → rc 1. Пара «заголовка нет вовсе» / «заголовок есть, тело
# пусто» дискриминирует стаб, который решает применимость по ЛЮБОМУ
# появлению маркера «## Модель угроз» в файле (в т.ч. пустому), а не по
# факту присутствия списков.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/tm_case01.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

put_contract "$WORK/g.md" '# kontrakt

## Predmet
p bez sekcii modeli ugroz'
run_barrier "$WORK" 'g.md'
if [ "${BARRIER:-x}" = "$SUBJ" ]; then
  accept 'case_01 (зелёный: заголовка нет)'
  printf '%s\n' "$LAST_OUT" | grep -Fq 'секция отсутствует' || { printf 'ОТКАЗ: case_01: нет фразы «секция отсутствует»:\n%s\n' "$LAST_OUT" >&2; exit 1; }
fi

put_contract "$WORK/r.md" '# kontrakt

## Predmet
p

## Модель угроз'
run_barrier "$WORK" 'r.md'
if [ "${BARRIER:-x}" = "$SUBJ" ]; then
  refuse 'case_01 (красный: заголовок есть, тело пусто)' 'модель угроз: список ЗАЩИЩАЕТ: отсутствует'
fi

exit 0
