# ПРИЧИНА: имя живо, OID сменился
#
# Срез 4 контракта 016, И-6: цель ref wip/* НЕ ДОЛЖНА смениться после GC.
# Любая смена цели (update-ref, reset --hard) равносильна сносу и красна одной сверкой.
#
# Зелёный контроль: oid_before == oid_after для зависшей ветки.
# Красное: имитация смены цели вне GC (ручной update-ref), ожидание отказа GC.
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

# Создать wip/* ветку, не слитую в main.
g "$R" branch wip/011/leftover main
# Дополнительный коммит — становится кончиком ветки, не достижимым из main.
g "$R" -c user.name=leftover -c user.email=l@l commit --allow-empty -q -m 'extra'
git -C "$R" branch -f wip/011/leftover HEAD

# Зафиксировать oid_before.
oid_before="$(git -C "$R" rev-parse refs/heads/wip/011/leftover)"

# Прогон GC.
"$BARRIER" "$R" || true

# Проверка: oid_after ДОЛЖЕН == oid_before.
oid_after="$(git -C "$R" rev-parse refs/heads/wip/011/leftover 2>/dev/null || true)"
if [ "$oid_after" != "$oid_before" ]; then
  printf 'ОТКАЗ: цель wip/011/leftover сменена (oid_before=%s, oid_after=%s) — перевод ref красный (И-6)\n' \
    "${oid_before:0:8}" "${oid_after:0:8}" >&2
  exit 1
fi
