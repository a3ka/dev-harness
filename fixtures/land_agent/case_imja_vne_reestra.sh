# ПРИЧИНА: committer merge-коммита — не orchestrator (по сути имя вне реестра)
#
# Срез 3 контракта 016, И-9: committer каждого коммита диапазона wip/* обязан быть в реестре
# ролей замороженных контрактов. Если ни одна ЗОНА-строка не объявляет этого committer — отказ.
#
# Эта фикстура проверяет ровно ИМЯ committer'а диапазона: фикстура создаёт wip/* ветку, где
# коммит подписан РАНЕЕ НЕ ОБЪЯВЛЕННЫМ именем, и ожидает, что land_agent откажет.
#
# В toy-репо нет замороженных контрактов → zones_load выдаёт пустой zones_scoped. Тогда
# РЕЕСТР ПУСТ, и ЛЮБОЕ committer-имя считается вне реестра → отказ. Это И-9 на toy-репо.
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

# wip/* ветка с коммитом от имени unknown_user (не зарегистрирован).
WT_DIR="$(mktemp -d /tmp/land-agent-noauthor.XXXXXX)"
git -C "$R" -c user.name=unknown_user -c user.email=u@l commit --allow-empty -q -m 'основание wip'
git -C "$R" branch wip/004/unknown_user main
git -C "$R" worktree add -q "$WT_DIR" wip/004/unknown_user
git -C "$WT_DIR" -c user.name=unknown_user -c user.email=u@l commit --allow-empty -q -m 'второй коммит wip'

# Зелёный контроль: барьер отказывает, поскольку ни одной ЗОНА-строки нет → реестр пуст →
# имя вне реестра. Ждём rc≠0.
if "$BARRIER" "$R" wip/004/unknown_user "$WT_DIR" >/dev/null 2>&1; then
  printf 'ОТКАЗ: land_agent не отказал при committer вне реестра (И-9)\n' >&2
  exit 1
fi
