# ПРИЧИНА: существовал и на HEAD его нет: verdicts/steward/v-s.md
#
# Тот же выключатель, вторая рукоятка: роль остаётся, а её поле `verdict:` меняется на `null`.
# Файл роли на месте, каталог из области выпал, вердикты можно удалять молча. Отдельная
# фикстура, а не вариант первой, потому что это ДРУГОЙ способ добраться до того же результата,
# и правило обязано ловить оба одним основанием: роль объявляла каталог хоть раз в истории.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R"
mkdir -p "$R/verdicts/steward"
printf -- '---\nname: steward\nverdict: verdicts/steward/\n---\nсмотритель\n' > "$R/roles/steward.md"
printf 'вердикт смотрителя\n' > "$R/verdicts/steward/v-s.md"
commit_all "$R" 'заведена роль steward со своим каталогом вердиктов'
"$BARRIER" "$R"
printf -- '---\nname: steward\nverdict: null\n---\nсмотритель без вердиктов\n' > "$R/roles/steward.md"
g "$R" rm -q verdicts/steward/v-s.md
commit_all "$R" 'у роли отобрали каталог вердиктов, вердикт удалён'
"$BARRIER" "$R"
