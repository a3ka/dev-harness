#!/usr/bin/env bash
# ПРИЧИНА: проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: roles/actor.md (резолв:
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK
# case_04 — RED: roles/actor.md — symlink на ../policies/r.md (круг 3а, Б1).
# Л проходит, г3 проходит (таргет существует), К ловит: readlink резолвит
# ВНЕ плоского roles/, остаток `policies/r.md` содержит `/` → die с хвостом
# ` (резолв: <канон>)`.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case04_038.XXXXXX")"
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
commit_all "$R" 'r4: kanale roles/actor simlink'

# Пост-коммит: внешний таргет и симлинк ВНЕ git (barrier читает ФС).
mkdir -p "$R/policies"
printf 'Norma stroki roli v igrushke R.\n' > "$R/policies/r.md"
ln -s ../policies/r.md "$R/roles/actor.md"

RED_OUT="$("$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_04 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: roles/actor.md (резолв: ' \
    || { printf 'FAIL: case_04 red хвост «(резолв: …)» отсутствует\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_04: прямой rc 1, причина с хвостом (резолв:)\n' >&2
  exit 0
fi
exit 0
