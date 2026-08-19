# ПРИЧИНА: вне объявленного множества
# ОКРУЖЕНИЕ: PATH=$WORK/repo/bin:$PATH
#
# Круг 4 адверсария, находка 2: скрытый пятый каталог (`.not-mirrored`) в skills/
# проходил — ls не перечисляет имена с точкой. Теперь состав читается ls -A:
# скрытые имена — часть состава.
# Зелёный контроль: точное множество → 0. Красное: skills/.rogue-skill — код 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
"$BARRIER" --live "$R"

# Порча: скрытый пятый каталог в источнике (в зеркале его нет — деревья различны)
mkdir -p "$R/skills/.not-mirrored"
"$BARRIER" --live "$R" || true

# Порча 2: скрытый каталог СИНХРОНИЗИРОВАН в оба корня — состав всё равно неточен
rm -rf "$R/skills/.not-mirrored"
mkdir -p "$R/skills/.rogue" "$R/.agents/skills/.rogue"
"$BARRIER" --live "$R"
