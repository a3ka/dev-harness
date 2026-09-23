#!/usr/bin/env bash
# ПРИЧИНА: precision-гейт 043: полярность не заявлена: ...
# Черновик заявляет семью dummy (fixtures/check_dummy/) в ЗОНА; в этой семье
# лежит НОВЫЙ (относительно тега минта) case-файл без red_/green_ префикса —
# задача (б) требует структурной декларации полярности basename'ом.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case06.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
mk_mint "$WORK" 043
mk_dummy_barrier "$WORK" dummy
mk_family_case "$WORK" dummy 'case_bez_prefiksa.sh' '#!/usr/bin/env bash
exit 0
'
put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md fixtures/check_dummy/'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && refuse 'case_06 (полярность не заявлена)' \
  'полярность не заявлена: fixtures/check_dummy/case_bez_prefiksa.sh'
exit 0
