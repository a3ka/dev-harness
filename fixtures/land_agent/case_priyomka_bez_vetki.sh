# ПРИЧИНА: HEAD worktree не отличается от main
#
# Срез 3 контракта 016, И-8 (§6.5-1): приёмка-OK-без-ветки красная — приземление
# отказывает, если приёмка зелёная, а ПРЕДМЕТА в HEAD worktree нет. Наблюдаемое
# отношение — HEAD worktree к базе ветки, а не рапорт приёмки.
#
# Различимость входа (Н-39): ветка wip/* заведена и worktree выдан, но коммита в нём НЕ
# сделано — HEAD worktree равен main. Судья, проверяющий лишь «ветка есть», зелен.
#
# Зелёный контроль: ветка с коммитом в worktree → rc 0 и четыре сверки И-1.
# Красное: ветка wip/002/implementer от main БЕЗ своего коммита → rc 1 «HEAD worktree не
# отличается от main». Воспроизводимо: пустая ветка остаётся пустой.
#
# Серийные вызовы — `|| true` (А-32).
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"
cd "$R"

# ── Зелёный контроль: приземление наблюдается ПЕРЕХОДОМ (И-1) ─────────────────
mk_wip "$R" wip/001/implementer "$WORK/wt-green"
commit_in "$WORK/wt-green" implementer implementer@dev-harness.local 'предмет в зоне'
mb="$(git -C "$R" rev-parse main)"
tip="$(git -C "$R" rev-parse refs/heads/wip/001/implementer)"
"$BARRIER" --branch wip/001/implementer --worktree "$WORK/wt-green" --root "$R" || true
assert_landed "$R" "$mb" "$tip" wip/001/implementer

# ── Красное: ветка без предмета — HEAD worktree совпадает с main ──────────────
mk_wip "$R" wip/002/implementer "$WORK/wt-pusto"
out_land="$("$BARRIER" --branch wip/002/implementer --worktree "$WORK/wt-pusto" --root "$R" || true)"
if ! printf '%s\n' "$out_land" | grep -q 'не отличается от main'; then
  printf 'ОТКАЗ: land на пустой ветке не назвал отсутствие предмета: %s\n' "$out_land" >&2
  exit 1
fi
# Ветка пережила отказ: сноса без приземления не бывает (И-4 держится только при успехе).
if ! git -C "$R" for-each-ref --format='%(refname)' 'refs/heads/wip/' | grep -q '^refs/heads/wip/002/implementer$'; then
  printf 'ОТКАЗ: ветка снесена на отказе — снос без приземления\n' >&2
  exit 1
fi
