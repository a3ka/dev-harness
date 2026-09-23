#!/usr/bin/env bash
# ПРИЧИНА: precision-гейт 043: ПЕРЕСЕЧЕНИЕ не привязан: ...
# Строка ПЕРЕСЕЧЕНИЕ грамматически валидна, но путь НЕ заявлен этим же автором
# в ЗОНА черновика — привязка (Н-39: обход "любой ПЕРЕСЕЧЕНИЕ гасит любую
# коллизию" без проверки, что путь вообще принадлежит автору строки).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case05.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md a/b.txt

ПЕРЕСЕЧЕНИЕ architect: sovsem/drugoj/put.txt — 999 путь не заявлен этим автором в ЗОНА'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && refuse 'case_05 (ПЕРЕСЕЧЕНИЕ не привязан)' \
  'ПЕРЕСЕЧЕНИЕ не привязан: путь sovsem/drugoj/put.txt не заявлен автором architect в ЗОНА этого черновика'
exit 0
