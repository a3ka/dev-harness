# ПРИЧИНА: существовал и на HEAD его нет: plans/003-vremenny.md
#
# Способ четвёртый: файл добавлен и удалён внутри ОДНОЙ ветки. На кончиках истории его нет
# вовсе, поэтому сверка «начало против конца» не видит ничего. Промежуточный коммит достижим
# от HEAD — этого достаточно.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R"
"$BARRIER" "$R"
printf 'временный план\n' > "$R/plans/003-vremenny.md"
commit_all "$R" 'временный план добавлен'
g "$R" rm -q plans/003-vremenny.md
g "$R" commit -q -m 'временный план убран'
"$BARRIER" "$R"
