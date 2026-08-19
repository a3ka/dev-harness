# ПРИЧИНА: тело не совпадает
# ОКРУЖЕНИЕ: PATH=$WORK/repo/bin:$PATH
#
# Ветвь (е): тело SKILL.md сверяется с raw.githubusercontent по закреплённому hash.
# Для фикстуры — локальная копия снимка: сравнение с upstream имитируется.
# Красное: тело отличается от снимка.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
# Папка снимка для теста
mkdir -p "$R/tmp/snapshot/skills/grilling"
cp "$R/skills/grilling/SKILL.md" "$R/tmp/snapshot/skills/grilling/SKILL.md"
"$BARRIER" --live "$R"

# Порча: тело отличается
printf 'tampered\n' >> "$R/skills/grilling/SKILL.md"
"$BARRIER" --live "$R"
