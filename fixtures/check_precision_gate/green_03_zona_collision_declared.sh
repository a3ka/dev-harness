#!/usr/bin/env bash
# ПРИЧИНА: та же коллизия что case_02, но с валидной строкой ПЕРЕСЕЧЕНИЕ —
# явное union-объявление (правило 7 AGENTS.md) снимает блокер → rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case03.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
mk_foreign_frozen "$WORK" 999 otherauthor shared/thing.txt
put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md shared/thing.txt

ПЕРЕСЕЧЕНИЕ architect: shared/thing.txt — 999 совместное сопровождение файла обеими сторонами сознательно'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && accept 'case_03 (коллизия объявлена ПЕРЕСЕЧЕНИЕ)'
exit 0
