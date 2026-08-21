# ПРИЧИНА: не на origin/main
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Незапушенный коммит прогона CI не имеет вовсе — гейт обязан назвать это, а не
# судить локальное дерево. Зелёный контроль: origin/main содержит HEAD → 0.
# Красное: origin/main отведён на родителя — HEAD «не запушен» → 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R"
"$BARRIER" "$R"

printf 'следующий коммит\n' > "$R/files/b.txt"
g "$R" add -A
g "$R" commit -q -m 'незапушенный'
"$BARRIER" "$R"
