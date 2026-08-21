# ПРИЧИНА: CI не ответил
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Сбой сети или HTTP — отказ с названной причиной, не молчаливое зелёное:
# отсутствие ответа не равно успеху (пустая выборка — красное).
# Зелёный контроль: success → 0. Красное: curl гибнет кодом 7 → 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R"
"$BARRIER" "$R"

ci_dead
"$BARRIER" "$R"
