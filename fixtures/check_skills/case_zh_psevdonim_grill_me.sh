# ПРИЧИНА: псевдоним grill-me
#
# Ветвь (ж): псевдоним grill-me обязан быть документирован в шапке grilling.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
# Добавим шапку-адаптацию с псевдонимом
sed -i '1i # Адаптация: вызывай как grill-me\n# источник: 9c9f36ccd399' "$R/skills/grilling/SKILL.md"
"$BARRIER" "$R"

# Порча: псевдоним исчез
sed -i '1,2d' "$R/skills/grilling/SKILL.md"
"$BARRIER" "$R"
