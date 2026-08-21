# ПРИЧИНА: коммит не разрешается
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Несуществующий sha — отказ до всякого похода в сеть. Зелёный контроль:
# HEAD (умолчание) → 0. Красное: явный мёртвый sha → 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R"
"$BARRIER" "$R"

"$BARRIER" "$R" deadbeefdeadbeefdeadbeefdeadbeefdeadbeef
