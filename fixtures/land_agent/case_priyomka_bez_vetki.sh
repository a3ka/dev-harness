# ПРИЧИНА: нет предмета в HEAD worktree
#
# Срез 3 контракта 016, И-8: приёмка-OK-без-ветки красная. Если HEAD worktree == main
# (предмета в ветке нет), land_agent отказывает.
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

# Создать wip/* ветку БЕЗ коммитов (т.е. HEAD worktree == main).
WT_DIR="$(mktemp -d /tmp/land-agent-empty.XXXXXX)"
git -C "$R" branch wip/007/implementer main
git -C "$R" worktree add -q "$WT_DIR" wip/007/implementer

# Зелёный контроль: барьер отказывает, потому что нет предмета.
if "$BARRIER" "$R" wip/007/implementer "$WT_DIR" >/dev/null 2>&1; then
  printf 'ОТКАЗ: land_agent не отказал при HEAD worktree == main (И-8)\n' >&2
  exit 1
fi
