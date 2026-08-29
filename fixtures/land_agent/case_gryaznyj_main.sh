# ПРИЧИНА: грязный главный чекаут
#
# Срез 3 контракта 016, И-7: главный чекаут загрязнён мимо worktree → rc 1.
# Грязный = в основном checkout есть unstaged/untracked, которые НЕ лежат в worktree.
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

WT_DIR="$(mktemp -d /tmp/land-agent-dirty.XXXXXX)"
git -C "$R" branch wip/006/implementer main
git -C "$R" worktree add -q "$WT_DIR" wip/006/implementer
commit_as "$R" implementer 'в зоне'

# Загрязнить главный чекаут — файл вне worktree.
printf 'грязь\n' > "$R/dirty_file.txt"

# Зелёный контроль: барьер отказывает, и отказ ссылается на загрязнение.
if "$BARRIER" "$R" wip/006/implementer "$WT_DIR" >/dev/null 2>&1; then
  printf 'ОТКАЗ: land_agent не отказал при грязном главном чекауте (И-7)\n' >&2
  exit 1
fi
