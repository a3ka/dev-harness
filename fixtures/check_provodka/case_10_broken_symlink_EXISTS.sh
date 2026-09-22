#!/usr/bin/env bash
# ПРИЧИНА: проводка: role-файл не существует: roles/actor.md
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK
# case_10 — RED: roles/actor.md — symlink на несуществующий таргет (битый).
# Л проходит; г3 ловит: `[ -f ]` РАЗЫМЕНОВЫВАЕТ симлинк, таргета нет → false →
# die с «role-файл не существует» (НЕ Л/К-текст).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case10_038.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
  BARRIER="$REPO/scripts/check_provodka.sh"
  export BARRIER_ROOT="$WORK"
fi

require_absent_subject

G="$WORK/green"; make_toy "$G" 1 1
put_contract "$G" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$G" 'g1: chestnyj vkhod'
"$BARRIER" "$G" "$G/contracts/001-x.md"

R="$WORK/red"; make_toy "$R" 1 0
put_contract "$R" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/actor.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$R" 'r10: actor bitt simlink'

# Пост-коммит: битый симлинк.
ln -s nowhere-does-not-exist.md "$R/roles/actor.md"

RED_OUT="$("$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_10 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: role-файл не существует: roles/actor.md' \
    || { printf 'FAIL: case_10 red причина не названа\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_10: прямой rc 1, причина названа дословно\n' >&2
  exit 0
fi
exit 0
