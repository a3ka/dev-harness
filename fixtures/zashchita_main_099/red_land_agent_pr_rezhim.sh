#!/usr/bin/env bash
# Клетка red_land_agent_pr_rezhim — инвариант З-1 контракта 099:
# land_agent --pr готовит merge в ИНТЕГРАЦИОННУЮ ветку (PREREADY), локальный main
# не двинут, исходная ветка жива, land:-маркер и авторство сохранены; squash/rebase нет.
# До реализации красна «предмет отсутствует»; стаб-пак — battery_stubs.sh (t99-m6).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z99_BASE/zashchita-099-land-$$-${RANDOM}"
trap 'rm -rf "$W"' EXIT
z99_mir_repo "$W" 0

if ! SUBJ="$(z99_subject land_agent.sh)"; then
  printf 'КРАСНО: red_land_agent_pr_rezhim: предмет отсутствует: scripts/land_agent.sh\n' >&2
  exit 1
fi

# Оракул в памяти ДО вызова субъекта (правило 8)
main_before="$(git -C "$Z99_REPO" rev-parse main)"
b_tip="$Z99_B"

out="$(bash "$SUBJ" --branch wip/099/demo --worktree "$W/wt" --root "$Z99_REPO" --pr 2>&1)"; rc=$?
if ! printf '%s' "$out" | grep -Fq 'PREREADY'; then
  printf 'КРАСНО: red_land_agent_pr_rezhim: предмет отсутствует: land_agent PR-режим (--pr); вывод: %s\n' \
    "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

fail() { printf 'КРАСНО: red_land_agent_pr_rezhim: %s\n' "$1" >&2; exit 1; }
[ "$rc" -eq 0 ] || fail "PREREADY без rc 0 (rc=$rc)"
[ "$(git -C "$Z99_REPO" rev-parse main)" = "$main_before" ] \
  || fail "локальный main двинут (режим 016 вместо --pr)"
git -C "$Z99_REPO" show-ref --verify --quiet refs/heads/wip/099/demo \
  || fail "исходная ветка wip/099/demo удалена до принятия PR"
git -C "$Z99_REPO" show-ref --verify --quiet refs/heads/pr/099/demo \
  || fail "интеграционная ветка pr/099/demo не создана"
integ="$(git -C "$Z99_REPO" rev-parse pr/099/demo)"
msg="$(git -C "$Z99_REPO" log -1 --format=%s "$integ")"
printf '%s' "$msg" | grep -Fq 'land: wip/099/demo' || fail "merge без land:-маркера: $msg"
[ "$(git -C "$Z99_REPO" rev-parse "$integ^2")" = "$b_tip" ] || fail "второй родитель merge не вершина исходной ветки"

printf 'ЗЕЛЕНО: red_land_agent_pr_rezhim\n'
exit 0
