#!/usr/bin/env bash
# ПРИЧИНА: precision-гейт 043: ПЕРЕСЕЧЕНИЕ не по грамматике: ...
# Строка ПЕРЕСЕЧЕНИЕ без em-dash/NNN-поля — вне грамматики, не засчитывается
# как объявление даже если путь легитимно в ЗОНА.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case04.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md a/b.txt

ПЕРЕСЕЧЕНИЕ architect: a/b.txt без причины и без NNN'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && refuse 'case_04 (ПЕРЕСЕЧЕНИЕ вне грамматики)' \
  'ПЕРЕСЕЧЕНИЕ не по грамматике:'
exit 0
