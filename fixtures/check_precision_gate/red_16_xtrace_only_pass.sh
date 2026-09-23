#!/usr/bin/env bash
# ПРИЧИНА: precision-гейт 043: ... самопроверка провалена (rc 1, ожидался 0) ...
# Б3 fix: case использует `case $- in *x*) exit 0 ;; *) exit 1 ;; esac` для
# дифференциального поведения под xtrace. Прежний код запускал case ОДИН РАЗ под
# xtrace (BASH_XTRACEFD) — rc=0, проходил. Новый код запускает case ДВА РАЗА:
# 1) прямой (без xtrace) — rc=1, прямая самопроверка ловит; либо
# 2) трейсовый (без xtrace, Б2 fix) — case уже не под xtrace, rc=1, оба rc
#    обязаны быть согласованы.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case16.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
mk_mint "$WORK" 043
mk_dummy_barrier "$WORK" dummy
mk_family_case "$WORK" dummy 'red_xtrace_diff.sh' '#!/usr/bin/env bash
# Дифференциальное поведение под xtrace — обход прежнего кода.
# Новый код: оба прогона (прямой и трейсовый) идут БЕЗ xtrace → case $- не
# содержит x → exit 1 → прямая самопроверка ловит rc=1.
"$WORK/scripts/check_dummy.sh" a b
case $- in
  *x*) exit 0 ;;
  *)   exit 1 ;;
esac
'
put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md fixtures/check_dummy/'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
[ "${BARRIER:-x}" = "$SUBJ" ] && refuse 'case_16 (дифференциальное поведение под xtrace не поймано)' \
  'fixtures/check_dummy/red_xtrace_diff.sh: самопроверка провалена (rc 1, ожидался 0)'
exit 0