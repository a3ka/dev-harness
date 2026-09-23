#!/usr/bin/env bash
# ПРИЧИНА: precision-гейт 043: зона-коллизия: ...
# Черновик заявляет путь, уже в union под ДРУГИМ NNN для ДРУГОГО автора, без
# строки ПЕРЕСЕЧЕНИЕ — обязан отказать именованно (задача а, Н-113/Н-115).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case02.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
mk_foreign_frozen "$WORK" 999 otherauthor shared/thing.txt
put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md shared/thing.txt'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && refuse 'case_02 (коллизия не объявлена)' \
  'зона-коллизия: shared/thing.txt заявлен architect (этот контракт, NNN 043), уже в union под NNN 999 для otherauthor'
exit 0
