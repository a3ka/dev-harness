#!/usr/bin/env bash
# ПРИЧИНА: precision-гейт 043: ... барьер dummy не вызван живьём ...
# Б2 fix: case пытается подделать трассу через printf "+ /path\n"
# >&"$BASH_XTRACEFD" (классический обход прежнего кода через BASH_XTRACEFD).
# Новый код: BASH_XTRACEFD НЕ передаётся case'у — >&"$BASH_XTRACEFD" даёт
# bash-ошибку «bad fd» → case завершается rc=1 ДО трейсового прогона → прямая
# самопроверка (Б3 fix) ловит rc=1. Альтернативно, /proc-наблюдение трейсового
# прогона (Б2 fix) не находит exec барьера, потому что case его не зовёт.
# В обоих случаях — отказ «барьер dummy не вызван живьём» или
# «самопроверка провалена (rc 1, …)»; обход прежним кодом зелёным проходил.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case15.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
mk_mint "$WORK" 043
mk_dummy_barrier "$WORK" dummy
mk_family_case "$WORK" dummy 'red_poddelka_trasy.sh' '#!/usr/bin/env bash
# Попытка подделать трассу через BASH_XTRACEFD (обход прежнего кода):
#   printf "+ /path/to/barrier.sh\n" >&"$BASH_XTRACEFD"
# Прежний код: BASH_XTRACEFD был доступен case-файлу, подделка проходила зелёной.
# Новый код: BASH_XTRACEFD НЕ передаётся → >&"$BASH_XTRACEFD" → bad fd → exit 1
#   → прямая самопроверка ловит rc=1.
# ВАЖНО: этот сценарий эксплуатирует ТОЛЬКО обход Б2; он НЕ вызывает барьер.
set +e
printf "+ %s\n" "$WORK/scripts/check_dummy.sh" >&"$BASH_XTRACEFD"
rc_printf=$?
exit $rc_printf
'
put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md fixtures/check_dummy/'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
# Два канала ловят обход — прямой rc и /proc-наблюдение. Принимаем любой.
[ "${BARRIER:-x}" = "$SUBJ" ] && {
  if printf '%s' "$LAST_OUT" | grep -Fq 'барьер dummy не вызван живьём'; then
    printf 'case_15: подделка трассы через BASH_XTRACEFD поймана /proc-наблюдением\n' >&2
    exit 0
  fi
  if printf '%s' "$LAST_OUT" | grep -Fq 'самопроверка провалена'; then
    printf 'case_15: подделка трассы через BASH_XTRACEFD поймана прямой самопроверкой\n' >&2
    exit 0
  fi
  refuse 'case_15 (обход Б2 не отвергнут)' \
    'барьер dummy не вызван живьём'
}
exit 0