# ПРИЧИНА: состав зеркала
# ОКРУЖЕНИЕ: PATH=$WORK/repo/bin:$PATH
#
# Круг 4 адверсария, находка 2, зеркальная сторона: скрытый элемент ТОЛЬКО в
# .agents/skills/ не ловился — diff шёл по четырём ожидаемым подкаталогам.
# Теперь корни сравниваются ЦЕЛИКОМ (diff -r корень-в-корень).
# Зелёный контроль: точное зеркало → 0. Красное: .agents/skills/.stale — код 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
"$BARRIER" --live "$R"

# Порча: скрытый элемент только в зеркале
mkdir -p "$R/.agents/skills/.stale"
"$BARRIER" --live "$R"
