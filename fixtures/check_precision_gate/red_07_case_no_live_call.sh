#!/usr/bin/env bash
# ПРИЧИНА: precision-гейт 043: ... барьер dummy не вызван живьём ...
# Case-файл заявляет себя red_ и самопроверяется честно (rc 1), но НИКОГДА не
# исполняет барьер семьи живьём — ровно класс Н-113/031: диспетчер-отказ/мок
# неотличим от настоящего красного, если верить только rc самого case-файла.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case07.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
mk_mint "$WORK" 043
mk_dummy_barrier "$WORK" dummy
mk_family_case "$WORK" dummy 'red_bez_vyzova.sh' '#!/usr/bin/env bash
# "самопроверяется" честно, но барьер ни разу не исполнен
exit 0
'
put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md fixtures/check_dummy/'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
if [ "$LAST_RC" -eq 2 ] && printf '%s' "$LAST_OUT" | grep -Fq 'нет strace'; then
  printf 'case_07: strace недоступен в этом окружении — нечем подтвердить живой вызов, rc2 честен\n' >&2
  exit 0
fi
[ "${BARRIER:-x}" = "$SUBJ" ] && refuse 'case_07 (барьер не вызван живьём)' \
  'fixtures/check_dummy/red_bez_vyzova.sh: барьер dummy не вызван живьём'
exit 0
