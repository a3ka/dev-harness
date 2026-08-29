# ПРИЧИНА: несбитая ветка пропала из for-each-ref после GC
#
# Срез 4 контракта 016, И-6: GC удаляет СЛИТЫЕ wip/*; несбитые СОХРАННЫ.
# Здесь создаётся wip/* ветка, которая НЕ слита в main (tip не достижим из HEAD).
# Ожидание: ветка ПЕРЕЖИВАЕТ прогон GC и остаётся в for-each-ref.
# Красное (для различения): имитация того, что ветка была снесена (проверка через ЭТУ фикстуру —
# невозможно проверить «ветка была снесена», если скрипт сам не сносит; контракт требует
# только «ветка сохранна наблюдаемо»).
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

# Создать wip/* ветку с коммитом, который НЕ слит в main.
g "$R" branch wip/010/leftover main
g "$R" -c user.name=leftover -c user.email=l@l commit --allow-empty -q -m 'unsynced' HEAD:
# Используем обновление ref напрямую — коммит не на main.
git -C "$R" update-ref refs/heads/wip/010/leftover HEAD 2>/dev/null \
  || git -C "$R" branch -f wip/010/leftover HEAD

# Зелёный контроль: ветка ДО GC есть.
before="$(git -C "$R" for-each-ref --format='%(refname)' 'refs/heads/wip/' 2>/dev/null | sort)"
[ -n "$before" ] || { printf 'ОТКАЗ: ветка wip/leftover не создана — фикстура пустая\n' >&2; exit 1; }

# Прогон GC.
"$BARRIER" "$R" || true

# Проверка: ветка wip/010/leftover ОБЯЗАНА ОСТАТЬСЯ.
if ! git -C "$R" for-each-ref --format='%(refname)' 'refs/heads/wip/' 2>/dev/null | grep -q 'wip/010/leftover'; then
  printf 'ОТКАЗ: несбитая ветка wip/010/leftover снесена GC — должна быть СОХРАННА (И-6)\n' >&2
  exit 1
fi
