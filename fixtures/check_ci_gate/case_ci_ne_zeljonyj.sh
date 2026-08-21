# ПРИЧИНА: CI не зелёный
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Гейт перед судьями: любой check-run с conclusion ≠ success — судью не звать.
# Зелёный контроль: оба прогона success → 0. Красное: прогон «test»failure → 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R"
"$BARRIER" "$R"

ci_red > "$WORK/curl.json"
"$BARRIER" "$R"
