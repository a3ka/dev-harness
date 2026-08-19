# ПРИЧИНА: коммит вне зоны
#
# ОБЯЗАТЕЛЬНАЯ фикстура конечности исключения СПАСЕНО — решение арбитража
# verdicts/arbitration/spaseno-konechnost.md, приёмка 5 контракта 003.
# Зелёный контроль: валидная строка СПАСЕНО называет хеш нарушения — барьер 0.
# Красное: СЛЕДУЮЩИЙ коммит того же автора вне зоны, хеш в СПАСЕНО не назван → 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R" 'ЗОНА agent-x: scripts/'

printf 'правка в зоне\n' >> "$R/scripts/a.sh"
commit_as "$R" agent-x 'в зоне'
printf 'нарушение до спасения\n' > "$R/plans/narushenie.md"
commit_as "$R" agent-x 'вне зоны — будет спасён'
SAVED="$(git -C "$R" rev-list -n1 HEAD -- plans/narushenie.md)"

# Зелёный контроль: СПАСЕНО называет ровно этот хеш — из суда зон выведен
freeze_v2 "$R" "ЗОНА agent-x: scripts/
СПАСЕНО agent-x: $SAVED — спасение из таймаута, разрешение владельца подставное"
"$BARRIER" "$R"

# Красное: следующий неназванный хеш того же автора вне зоны — снова красный
printf 'повторное нарушение\n' > "$R/plans/vtoroe.md"
commit_as "$R" agent-x 'вне зоны — НЕ спасён'
"$BARRIER" "$R"
