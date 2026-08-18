# ПРИЧИНА: hash шапки не совпадает
#
# Ветвь (в): hash источника в шапке-адаптации не равен значению из блоба высшей заморозки
# контракта 003. Смена источника без vN невозможна.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
# Для теста хеш берём из тега заморозки контракта 003 в подставном дереве
mkdir -p "$R/verdicts/critic"
printf 'accept\ntest\n' > "$R/verdicts/critic/contracts-003-v1.md"
printf '# contract 003 test\nhash: 9c9f36ccd399\n' > "$R/contracts/003-x.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" config user.name Ф
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" config user.email f@l
commit_all "$R" base
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" tag -a frozen/contracts/003/1 -m test
"$BARRIER" "$R"

sed -i 's/^hash: 9c9f36ccd399$/hash: deadbeef0000/' "$R/contracts/003-x.md"
commit_all "$R" wrong-hash
"$BARRIER" "$R"
