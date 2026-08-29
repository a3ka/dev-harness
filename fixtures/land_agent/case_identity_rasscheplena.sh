# ПРИЧИНА: identity расщеплена
#
# Срез 3 контракта 016, И-9: committer != author в диапазоне wip/* → отказ.
# --no-verify здесь не помогает: проверка живёт в land_agent, не в хуке.
#
# Вход: коммит с --author=implementer, но committer=other_user. Создаём его напрямую через
# GIT_AUTHOR_NAME/GIT_AUTHOR_EMAIL + GIT_COMMITTER_NAME/GIT_COMMITTER_EMAIL.
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

WT_DIR="$(mktemp -d /tmp/land-agent-split.XXXXXX)"
# Коммит диапазона: author=implementer, committer=stranger.
GIT_AUTHOR_NAME=implementer GIT_AUTHOR_EMAIL=implementer@l \
GIT_COMMITTER_NAME=stranger GIT_COMMITTER_EMAIL=stranger@l \
  git -C "$R" commit --allow-empty -q -m 'расщеплённая identity'
git -C "$R" branch wip/005/implementer main
git -C "$R" worktree add -q "$WT_DIR" wip/005/implementer

# Зелёный контроль: барьер отказывает на проверке committer==author.
if "$BARRIER" "$R" wip/005/implementer "$WT_DIR" >/dev/null 2>&1; then
  printf 'ОТКАЗ: land_agent не отказал при committer != author (И-9 расщепление)\n' >&2
  exit 1
fi
