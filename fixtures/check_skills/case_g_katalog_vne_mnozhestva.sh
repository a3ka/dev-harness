# ПРИЧИНА: вне объявленного множества
#
# Ветвь (г): каталог в skills/ вне объявленных четырёх — лишний скил не лежит молча.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
"$BARRIER" "$R"

mkdir -p "$R/skills/rogue-skill"
printf -- '---\nname: rogue-skill\ndescription: rogue\n---\nrogue body\n' > "$R/skills/rogue-skill/SKILL.md"
"$BARRIER" "$R"
