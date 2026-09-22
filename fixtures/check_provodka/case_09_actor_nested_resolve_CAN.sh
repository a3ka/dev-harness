#!/usr/bin/env bash
# ПРИЧИНА: проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: roles/actor.md (резолв:
# ОКРУЖЕНИЕ: BARRIER_ROOT=$WORK
# case_09 — RED: roles/actor.md — symlink на `sub/x.md` (вложенный резолв).
# Л проходит; г3 проходит; К ловит: readlink резолвит в `$ROOT/roles/sub/x.md`,
# остаток `sub/x.md` содержит `/` → die с хвостом ` (резолв: …)`.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  REPO="$(cd "$HERE/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/case09_038.XXXXXX")"
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
commit_all "$R" 'r9: actor → vlozhennogo'

# Пост-коммит: таргет roles/sub/x.md + симлинк roles/actor.md → sub/x.md.
mkdir -p "$R/roles/sub"
printf 'Norma stroki roli v igrushke R.\n' > "$R/roles/sub/x.md"
ln -s sub/x.md "$R/roles/actor.md"

RED_OUT="$("$BARRIER" "$R" "$R/contracts/001-x.md" 2>&1)"; RED_RC=$?

if [ -z "${BARRIER:-}" ] || [ "${BARRIER:-x}" = "$REPO/scripts/check_provodka.sh" ]; then
  [ "$RED_RC" -eq 1 ] || { printf 'FAIL: case_09 red rc=%s, ожидался 1\n%s\n' "$RED_RC" "$RED_OUT" >&2; exit 1; }
  printf '%s' "$RED_OUT" | grep -Fq 'проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: roles/actor.md (резолв: ' \
    || { printf 'FAIL: case_09 red хвост «(резолв: …)» отсутствует\n%s\n' "$RED_OUT" >&2; exit 1; }
  printf 'case_09: прямой rc 1, причина с хвостом (резолв:)\n' >&2
  exit 0
fi
exit 0
