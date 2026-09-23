#!/usr/bin/env bash
# ПРИЧИНА: precision-гейт 043: ... самопроверка провалена (rc 1, ожидался 0) ...
# Case-файл РЕАЛЬНО вызывает барьер живьём (проходит подтверждение живости), но
# его собственная самопроверка (rc) не нулевая — регрессия/сломанное
# предъявление обязана краснить ДАЖЕ когда барьер честно вызван.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/pg_case08.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

mk_toy_repo "$WORK"
mk_mint "$WORK" 043
mk_dummy_barrier "$WORK" dummy
mk_family_case "$WORK" dummy 'red_slomannaja_samoproverka.sh' "#!/usr/bin/env bash
\"$WORK/scripts/check_dummy.sh\" a b >/dev/null 2>&1
exit 1
"
put_draft "$WORK/contracts/043-toy-draft.md" '# kontrakt

## Predmet
p

## Зоны

ЗОНА architect: contracts/043-toy-draft.md fixtures/check_dummy/'

run_barrier "$WORK" 'contracts/043-toy-draft.md'
if [ "$LAST_RC" -eq 2 ] && printf '%s' "$LAST_OUT" | grep -Fq 'нет strace'; then
  printf 'case_08: strace недоступен в этом окружении — нечем подтвердить живой вызов, rc2 честен\n' >&2
  exit 0
fi
[ "${BARRIER:-x}" = "$SUBJ" ] && refuse 'case_08 (самопроверка провалена)' \
  'fixtures/check_dummy/red_slomannaja_samoproverka.sh: самопроверка провалена (rc 1, ожидался 0)'
exit 0
