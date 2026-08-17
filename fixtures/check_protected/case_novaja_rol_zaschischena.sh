# ПРИЧИНА: существовал и на HEAD его нет: verdicts/steward/v-s.md
#
# Область, а не порог. Роль `steward` в барьере не упомянута ни словом: её каталог вердиктов
# берётся из её же файла роли, поля `verdict:`. Список каталогов, набранный руками, отстал бы
# ровно на одну роль и молча — за одну сессию в этом репозитории добавление области дважды
# сразу находило необъявленное.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R"
mkdir -p "$R/verdicts/steward"
printf -- '---\nname: steward\nverdict: verdicts/steward/\n---\nсмотритель\n' > "$R/roles/steward.md"
printf 'вердикт новой роли\n' > "$R/verdicts/steward/v-s.md"
commit_all "$R" 'заведена роль steward со своим каталогом вердиктов'
"$BARRIER" "$R"
g "$R" rm -q verdicts/steward/v-s.md
g "$R" commit -q -m 'вердикт новой роли удалён'
"$BARRIER" "$R"
