# ПРИЧИНА: ветки origin/main нет локально
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Удалённый remote уносит и ветку origin/main — прогон CI по sha не существует,
# отказ называет именно это (первый же гейт на пути к сети).
# Зелёный контроль: origin на месте → 0. Красное: origin удалён → 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R"
"$BARRIER" "$R"

g "$R" remote remove origin
"$BARRIER" "$R"
