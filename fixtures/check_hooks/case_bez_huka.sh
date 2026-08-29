# ПРИЧИНА: механизм установки без хука
#
# Q6 контракта 016: check:hooks проверяет МЕХАНИЗМ установки. Ветвь: коммиченного
# .githooks/pre-commit нет (либо он не исполняем) — остальной механизм цел.
# Зелёный контроль: полный механизм → rc 0; порча: хук удалён → rc 1.
set -uo pipefail
R="$WORK/meh"
# shellcheck disable=SC1091
. "$(dirname "$0")/_mehanizm.sh"
mehanizm "$R"

"$BARRIER" "$R" || true

rm "$R/.githooks/pre-commit"
"$BARRIER" "$R" || true
