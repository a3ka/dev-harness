# ПРИЧИНА: главное дерево загрязнено мимо worktree
#
# Срез 3 контракта 016, И-7 (§6.5-2): грязный главный чекаут на приземлении → rc 1.
# Грязь — состояние ГЛАВНОГО дерева, а не worktree: агент работает в выданном worktree,
# и всё, что появилось в главном чекауте, приехало мимо него.
#
# Различимость входа (Н-39): вход — untracked-файл в КОРНЕ главного дерева при полностью
# исправной ветке (предмет в HEAD worktree есть, identity сцеплена, имя в реестре).
# Судья, слепой к чистоте главного дерева, на этом входе зелен.
#
# Зелёный контроль: та же схема на ЧИСТОМ главном дереве → rc 0 и четыре сверки И-1.
# Красное: тот же сценарий + dirty_file.txt в $R → rc 1 «главное дерево загрязнено мимо
# worktree». Воспроизводимо повтором проверяющего: грязь остаётся на диске.
#
# Серийные вызовы — `|| true` (А-32): серединный красный не обрывает case по set -e.
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"
cd "$R"

# ── Зелёный контроль: приземление наблюдается ПЕРЕХОДОМ (И-1) ─────────────────
# main_before и tip пинуются ДО вызова; заранее построенного merge в фикстуре нет —
# создать его может только сам вызов барьера.
mk_wip "$R" wip/001/implementer "$WORK/wt-green"
commit_in "$WORK/wt-green" implementer implementer@dev-harness.local 'предмет в зоне'
mb="$(git -C "$R" rev-parse main)"
tip="$(git -C "$R" rev-parse refs/heads/wip/001/implementer)"
"$BARRIER" --branch wip/001/implementer --worktree "$WORK/wt-green" --root "$R" || true
assert_landed "$R" "$mb" "$tip" wip/001/implementer

# ── Красное: главный чекаут загрязнён мимо worktree ───────────────────────────
mk_wip "$R" wip/002/implementer "$WORK/wt-dirty"
commit_in "$WORK/wt-dirty" implementer implementer@dev-harness.local 'предмет второй ветки'
printf 'грязь, приехавшая мимо worktree\n' > "$R/dirty_file.txt"
out_land="$("$BARRIER" --branch wip/002/implementer --worktree "$WORK/wt-dirty" --root "$R" || true)"
if ! printf '%s\n' "$out_land" | grep -q 'загрязнено мимо worktree'; then
  printf 'ОТКАЗ: land при грязном главном дереве не назвал загрязнение: %s\n' "$out_land" >&2
  exit 1
fi
