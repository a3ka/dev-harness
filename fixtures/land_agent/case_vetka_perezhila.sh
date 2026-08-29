# ПРИЧИНА: ветка пережила
#
# Срез 3 контракта 016, И-4: после приземления веток wip/<NNN>/<автор> НЕТ в for-each-ref.
# land_agent удаляет ветку и worktree СРАЗУ после merge.
#
# Зелёный контроль: land_agent отрабатывает успешно → ветка и worktree удалены. Красное:
# после ручного приземления (имитация «забытого» приземления) ветка остаётся.
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

WT_DIR="$(mktemp -d /tmp/land-agent-survive.XXXXXX)"
git -C "$R" branch wip/008/implementer main
git -C "$R" worktree add -q "$WT_DIR" wip/008/implementer
commit_as "$R" implementer 'предмет'

# Зелёный контроль: land_agent сносит ветку + worktree.
"$BARRIER" "$R" wip/008/implementer "$WT_DIR" || true

# Красное: создать wip/* ветку и НЕ удалять — имитация «забытого» приземления.
git -C "$R" branch wip/009/leftover main
git -C "$R" worktree add -q /tmp/land-agent-leftover.XXXXXX wip/009/leftover
if ! git -C "$R" for-each-ref --format='%(refname)' 'refs/heads/wip/leftover' | grep -q .; then
  printf 'ОТКАЗ: фикстура не смогла создать wip/leftover — ветки для красного нет\n' >&2
  exit 1
fi
