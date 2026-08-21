# ПРИЧИНА: чек-раны пусты
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Пустой список check-runs — workflow не запускался; «нечего проверять»
# не равно «проверено» (пустая выборка — красное). Зелёный контроль: прогоны
# success → 0. Красное: total_count=0 → 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R"
"$BARRIER" "$R"

ci_empty > "$WORK/curl.json"
"$BARRIER" "$R"
