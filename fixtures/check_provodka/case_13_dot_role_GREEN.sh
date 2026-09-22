#!/usr/bin/env bash
# ПРИЧИНА: проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: policies/r.txt
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK
# case_13 — GREEN (роль `.` легальна): канал role=roles/..md «…». Грамматика
# «ровно один сегмент, база ненулевая» для `..md` после снятия `roles/`
# сходится; Л + г3 + К все проходят; г4 находит норму в файле → rc 0.
# Красное для инварианта анти-плейсбо.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case13_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

G="$WORK/green"; make_toy "$G" 1 0
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/..md «Norma stroki roli v igrushke R.»'
commit_all "$G" 'g13: rol ..'

# Зелёный сценарий — регулярный файл `roles/..md` с нормой (НЕ родитель
# roles — это имя файла `..md` ВНУТРИ roles).
printf 'Norma stroki roli v igrushke R.\n' > "$G/roles/..md"
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

R="$WORK/red"; make_toy "$R" 1 1
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=policies/r.txt «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$R" 'r13: для инварианта анти-плейсбо (kanale ne-roles)'
RED_OUT="$("$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_13 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_13 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  printf 'case_13: прямой rc 0 (легитимный `roles/..md`)\n' >&2
  exit 0
fi
exit 0
