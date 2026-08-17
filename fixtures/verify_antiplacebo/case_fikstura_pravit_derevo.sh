# ПРИЧИНА: фикстуры изменили дерево вне $WORK
#
# Фикстура добилась красного, но заплатила за это правкой самого дерева. Такая фикстура
# оставляет за собой поломку, которую потом ищут неделю и находят не там: следующий барьер
# упадёт по причине, которой в его предмете нет.
#
# Правка здесь СОХРАНЯЕТ размер и mtime — так адверсарий обошёл прежний слепок по
# `путь+размер+mtime`. Слепок берётся по содержимому, поэтому подмена байта видна.
set -euo pipefail
. "$(dirname "$0")/_fake_root.sh"
fake_root "$WORK"
# Жертва правки — файл, который никто не разбирает. Первая редакция портила первый байт
# САМОЙ фикстуры, и повторный прогон проверяющего краснел уже по другой причине: шапка
# `# ПРИЧИНА:` была разрушена той же правкой. Жертва обязана быть нейтральной, иначе мера
# меняет предмет, о котором говорит.
mkdir -p "$WORK/plans"
printf 'подставной план: жертва правки\n' > "$WORK/plans/001-zhertva.md"
"$BARRIER" "$WORK"
{
  printf '# ПРИЧИНА: игрушка сломана\n'
  printf 'set -euo pipefail\n'
  printf 'mkdir -p "$WORK/scripts"\n'
  printf 'BARRIER_ROOT="$WORK" "$BARRIER"\n'
  printf 'touch "$WORK/.slomano"\n'
  printf 'BARRIER_ROOT="$WORK" "$BARRIER" || true\n'
  printf 'zhertva="$REPO/plans/001-zhertva.md"\n'
  printf 'metka="$WORK/mtime"\n'
  printf 'touch -r "$zhertva" "$metka"\n'
  printf 'python3 -c "import sys;p=sys.argv[1];b=bytearray(open(p,\\"rb\\").read());b[0]=b[0]^32;open(p,\\"wb\\").write(bytes(b))" "$zhertva"\n'
  printf 'touch -r "$metka" "$zhertva"\n'
} > "$WORK/fixtures/verify_toy/case_slomano.sh"
"$BARRIER" "$WORK"
