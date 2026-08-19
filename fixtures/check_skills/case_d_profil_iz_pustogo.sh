# ПРИЧИНА: зеркало не совпадает
# ОКРУЖЕНИЕ: PATH=$WORK/repo/bin:$PATH
#
# Ветвь (д), реестровая v4: зеркало .agents/skills — полное дерево skills/, diff -r
# в обе стороны, состав точен. Зелёный контроль: зеркало разложено → 0.
# Красное 1: из зеркала пропал вложенный файл (tdd/mocking.md).
# Красное 2: файл зеркала искажён дописанной строкой.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
"$BARRIER" --live "$R" || true

# Порча 1: неполное дерево — вложенный файл не скопирован
rm "$R/.agents/skills/tdd/mocking.md"
"$BARRIER" --live "$R" || true

# Порча 2: искажённый файл зеркала
cp "$R/skills/tdd/mocking.md" "$R/.agents/skills/tdd/mocking.md"
printf 'лишняя строка\n' >> "$R/.agents/skills/tdd/tests.md"
"$BARRIER" --live "$R" || true
