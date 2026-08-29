# ПРИЧИНА: committer merge-коммита приземления — не orchestrator
#
# Срез 3 контракта 016, И-1: merge-коммит приземления подписан orchestrator (зашитая в
# скрипте identity). Если merge-коммит подписан ДРУГИМ — это валится проверкой merge_cn
# != orchestrator.
#
# Вход подобран РАЗЛИЧИМЫМ (Н-39): имитация merge от чужой identity — barrierm должен отказать.
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

# Создать wip/* ветку с одним коммитом (с явной identity implementer, чтобы коммиттер был
# зарегистрирован в реестре).
WT_DIR="$(mktemp -d /tmp/land-agent-orch.XXXXXX)"
git -C "$R" branch wip/003/implementer main
git -C "$R" worktree add -q "$WT_DIR" wip/003/implementer
commit_as "$R" implementer 'работа'

# Подменить merge вручную: НЕ вызывать land_agent (он бы слил правильно), а построить merge
# самостоятельно от чужой identity. Затем land_agent ОБЯЗАН отказать на проверке
# merge_cn != orchestrator.
git -C "$R" -c user.name=architect -c user.email=architect@l -c commit.gpgsign=false \
    merge --no-ff wip/003/implementer -m 'merge from architect' 2>/dev/null
if "$BARRIER" "$R" wip/003/implementer "$WT_DIR" >/dev/null 2>&1; then
  printf 'ОТКАЗ: land_agent не отказал при merge от чужой identity — коммиттер merge не orchestrator (И-1)\n' >&2
  exit 1
fi
