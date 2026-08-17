# ПРИЧИНА: существовал и на HEAD его нет: verdicts/steward/v-s.md
#
# Находка адверсария, и самая злая из четырёх: область бралась с HEAD, поэтому УДАЛЕНИЕ файла
# роли вместе с её вердиктами снимало защиту с них же. Каталог перестаёт входить в область,
# `existed` его не содержит, барьер зелен. Защита, которую снимает тот же коммит, что и удаляет
# предмет, защитой не является.
#
# Закрыто объединением по всем достижимым коммитам: роль существовала — её каталог защищён
# навсегда, даже если роли больше нет.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R"
mkdir -p "$R/verdicts/steward"
printf -- '---\nname: steward\nverdict: verdicts/steward/\n---\nсмотритель\n' > "$R/roles/steward.md"
printf 'вердикт смотрителя\n' > "$R/verdicts/steward/v-s.md"
commit_all "$R" 'заведена роль steward со своим каталогом вердиктов'
"$BARRIER" "$R"
g "$R" rm -q roles/steward.md verdicts/steward/v-s.md
g "$R" commit -q -m 'роль упразднена вместе со своими вердиктами'
"$BARRIER" "$R"
