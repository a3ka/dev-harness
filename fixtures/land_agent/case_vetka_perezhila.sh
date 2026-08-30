# ПРИЧИНА: главное дерево загрязнено мимо worktree
#
# Срез 3 контракта 016, И-4: после УСПЕШНОГО приземления ветки wip/<NNN>/<автор> нет в
# `for-each-ref` — снос ветки и worktree идёт СРАЗУ, тем же вызовом. Предмет этой
# фикстуры — именно СНОС: зелёный контроль сверяет отсутствие ветки после rc 0
# (assert_landed), красный — что на ОТКАЗЕ ветка ПЕРЕЖИВАЕТ вызов, то есть сноса без
# приземления не бывает.
#
# Различимость входа (Н-39): порядок сноса несущий — пока worktree жив, ветка в нём
# вычекана и `git branch -D` отказывает «used by worktree»; ветка тихо переживала
# успешное приземление (замер: for-each-ref печатал refs/heads/wip/001/implementer после
# rc 0). Порядок в land_agent.sh исправлен, и зелёная половина этой фикстуры его держит.
#
# Зелёный контроль: приземление rc 0 → ветки нет в for-each-ref.
# Красное: грязный главный чекаут → rc 1 «главное дерево загрязнено мимо worktree», и
# ветка wip/002/implementer ОСТАЁТСЯ в for-each-ref. Воспроизводимо: грязь на диске.
#
# Серийные вызовы — `|| true` (А-32).
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"
cd "$R"

# ── Зелёный контроль: приземление наблюдается ПЕРЕХОДОМ (И-1) + снос (И-4) ────
mk_wip "$R" wip/001/implementer "$WORK/wt-green"
commit_in "$WORK/wt-green" implementer implementer@dev-harness.local 'предмет в зоне'
mb="$(git -C "$R" rev-parse main)"
tip="$(git -C "$R" rev-parse refs/heads/wip/001/implementer)"
"$BARRIER" --branch wip/001/implementer --worktree "$WORK/wt-green" --root "$R" || true
assert_landed "$R" "$mb" "$tip" wip/001/implementer

# ── Красное: отказ приземления — ветка обязана пережить вызов ─────────────────
mk_wip "$R" wip/002/implementer "$WORK/wt-perezhila"
commit_in "$WORK/wt-perezhila" implementer implementer@dev-harness.local 'предмет второй ветки'
printf 'грязь, приехавшая мимо worktree\n' > "$R/dirty_file.txt"
out_land="$("$BARRIER" --branch wip/002/implementer --worktree "$WORK/wt-perezhila" --root "$R" || true)"
if ! printf '%s\n' "$out_land" | grep -q 'загрязнено мимо worktree'; then
  printf 'ОТКАЗ: land при грязном главном дереве не назвал загрязнение: %s\n' "$out_land" >&2
  exit 1
fi
if ! git -C "$R" for-each-ref --format='%(refname)' 'refs/heads/wip/' | grep -q '^refs/heads/wip/002/implementer$'; then
  printf 'ОТКАЗ: ветка снесена на отказе — снос без приземления (И-4)\n' >&2
  exit 1
fi
