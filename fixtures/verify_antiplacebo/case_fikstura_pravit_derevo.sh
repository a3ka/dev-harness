# ПРИЧИНА: фикстуры изменили дерево вне $WORK
#
# Фикстура добилась красного, но заплатила за это правкой самого дерева. Такая фикстура
# оставляет за собой поломку, которую потом ищут неделю и находят не там: следующий барьер
# упадёт по причине, которой в его предмете нет.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
{
  printf '# ПРИЧИНА: игрушка сломана\n'
  printf 'set -euo pipefail\n'
  printf 'touch "$WORK/.slomano"\n'
  printf 'BARRIER_ROOT="$WORK" "$BARRIER" || true\n'
  printf 'printf "\\n# след\\n" >> "$REPO/scripts/verify_toy.sh"\n'
} > "$WORK/fixtures/verify_toy/case_slomano.sh"
"$BARRIER" "$WORK"
