#!/usr/bin/env bash
# ПРИЧИНА: проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: policies/r.txt
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK
# case_01 — RED: канал role=policies/r.txt (круг 1, не-roles/).
# Зелёный контроль: полный честный вход (g1); Красное: тот же контракт с
# подменой role=… на policies/r.txt → Л ловит (литеральный `roles/`
# не снимается).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  # Прямой запуск (НЕ через verify_antiplacebo): барьер и WORK гонит сама фикстура.
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case01_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

# ── Зелёный контроль ─────────────────────────────────────────────────────────
G="$WORK/green"; make_toy "$G" 1 1
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$G" 'g1: chestnyj vkhod'
"$BARRIER" "$G" "$G/contracts/001-x.md"

# ── Красное: тот же каталог, контракт с role=policies/r.txt ─────────────────
R="$WORK/red"; make_toy "$R" 1 1
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=policies/r.txt «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$R" 'r1: kanale ne-roles'
RED_OUT="$("$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  # Прямой запуск: явно проверить rc + причину.
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_01 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: policies/r.txt' \
    || { printf 'FAIL: case_01 red причина не названа\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_01: прямой rc 1, причина названа дословно\n' >&2
  exit 0
fi

exit 0
