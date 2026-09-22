#!/usr/bin/env bash
# ПРИЧИНА: проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: policies/r.txt
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK
# case_12 — GREEN (плоский резолв симлинка): roles/alias.md → fixer.md
# (относительный, ВНУТРИ roles/). Л + г3 + К все проходят; г4 находит норму
# в таргете (grep следует симлинку автоматически) → rc 0.
# Красное для verify_antiplacebo-инварианта «barrier краснеет и в последующем
# прогоне»: deliberately не-roles канал (замер 3 арбитра) даёт ту же
# именованную причину.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case12_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

G="$WORK/green"; make_toy "$G" 1 0
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/alias.md «Norma stroki roli v igrushke R.»'
commit_all "$G" 'g12: roles/alias simlink fixer'

# Зелёный сценарий — легитимный плоский резолв: симлинк на fixer.md (норма
# строкой в нём есть — от make_toy with_role=1).
ln -s fixer.md "$G/roles/alias.md"
GREEN_OUT="$("$BARRIER" "$G" "$G/contracts/001-x.md" 2>&1)"; GREEN_RC=$?

R="$WORK/red"; make_toy "$R" 1 1
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=policies/r.txt «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$R" 'r12: для инварианта анти-плейсбо (kanale ne-roles)'
RED_OUT="$("$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  # Прямой запуск: проверяем ЗЕЛЁНУЮ сторону (это и есть предмет вектора 12).
  [ "$GREEN_RC" -eq 0 ] || { printf 'FAIL: case_12 green rc=%s, ожидался 0\n%s\n' "$GREEN_RC" "$GREEN_OUT" >&2; exit 1; }
  # на зелёном выводе НЕ должно быть «получено:» от Л/К.
  printf '%s' "$GREEN_OUT" | grep -Fq 'получено:' \
    && { printf 'FAIL: case_12 green: вывод содержит «получено:»\n%s\n' "$GREEN_OUT" >&2; exit 1; }
  printf 'case_12: прямой rc 0 (легитимный плоский симлинк)\n' >&2
  exit 0
fi
exit 0
