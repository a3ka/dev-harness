#!/usr/bin/env bash
# ПРИЧИНА: честный черновик без коллизий и без затронутых семей → rc 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case01.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md fresh/path/only.txt'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && accept 'case_01 (честный вход, нет коллизий)'
exit 0
