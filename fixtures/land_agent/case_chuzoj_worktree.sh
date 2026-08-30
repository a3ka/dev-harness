# ПРИЧИНА: предмет не в worktree
#
# Срез 3 контракта 016, И-8 (b), R016-1: HEAD переданного worktree обязан совпадать с
# tip_sha ветки из --branch. Несовпадение → именованный отказ ДО merge, main не
# мутируется, обе ветки переживают вызов.
#
# Различимость входа (Н-39): две разные wip-ветки, каждая со своим worktree и коммитом;
# на вход подаётся --branch wip/001/implementer с ЧУЖИМ --worktree wt-002 (HEAD wt-002
# = tip wip/002 ≠ tip wip/001). Судья, читающий только «WT_HEAD != main», зелен:
# wt-002 живёт на собственном коммите. Красит ровно сверка wt_head с tip_sha.
#
# До фикса R016-1: merge исполнялся, main мутировался, и лишь И-4 постфактум краснел
# (ветка wip/001 не сносилась — её собственный worktree wt-001 не был передан). После
# фикса: refuse до merge с текстом «HEAD worktree <sha> не совпадает с tip ветки <sha> —
# предмет не в worktree (И-8)», main стоит.
#
# Зелёный контроль: та же ветка wip/001/implementer со СВОИМ worktree wt-001 →
# приземление rc 0, четыре сверки И-1 (main сдвинут, родители корректны, committer
# orchestrator, ветки wip/001 в for-each-ref нет).
# Красное: --branch wip/001/implementer с --worktree wt-002 → rc 1 «предмет не в
# worktree», main не сдвинут, обе ветки живы.
#
# Каждый вход предъявляется СВОИМ (Н-39): зелёный контроль — собственный worktree,
# красное — чужой. Серийные вызовы — `|| true` (А-32).
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"
cd "$R"

# ── Две разные wip-ветки, каждая со своим worktree и пустым коммитом ────────
# Оба коммитера — implementer (в реестре ЗОНА-строки contracts/900-fake.md);
# различие только в tip_sha.
mk_wip "$R" wip/001/implementer "$WORK/wt-001"
commit_in "$WORK/wt-001" implementer implementer@dev-harness.local 'предмет первой ветки'
mk_wip "$R" wip/002/implementer "$WORK/wt-002"
commit_in "$WORK/wt-002" implementer implementer@dev-harness.local 'предмет второй ветки'

# ── Зелёный контроль: приземление наблюдается ПЕРЕХОДОМ (И-1) ─────────────────
# Свой worktree wt-001 для ветки wip/001/implementer — РОВНО то отношение
# «HEAD worktree == tip_sha», которое И-8 (b) требует.
mb="$(git -C "$R" rev-parse main)"
tip="$(git -C "$R" rev-parse refs/heads/wip/001/implementer)"
"$BARRIER" --branch wip/001/implementer --worktree "$WORK/wt-001" --root "$R" || true
assert_landed "$R" "$mb" "$tip" wip/001/implementer

# ── Красное: чужой worktree (wt-002) передан для ветки wip/003/implementer ─────
# Здесь ровно тот вход, что был в репро ревьюера: HEAD worktree указывает на tip
# ДРУГОЙ ветки, не на tip заявленной. До фикса merge успевал исполниться, main
# мутировался, И-4 краснел постфактум; сейчас — refuse до merge, main стоит.
mk_wip "$R" wip/003/implementer "$WORK/wt-003"
commit_in "$WORK/wt-003" implementer implementer@dev-harness.local 'предмет третьей ветки'
mb="$(git -C "$R" rev-parse main)"
out_land="$("$BARRIER" --branch wip/003/implementer --worktree "$WORK/wt-002" --root "$R" || true)"
if ! printf '%s\n' "$out_land" | grep -q 'предмет не в worktree'; then
  printf 'ОТКАЗ: land на чужом worktree не назвал И-8 «предмет не в worktree»: %s\n' "$out_land" >&2
  exit 1
fi
# main не сдвинут (R016-1 — фикс держит мутацию И-8 на ДО-merge).
if [ "$(git -C "$R" rev-parse main)" != "$mb" ]; then
  printf 'ОТКАЗ: main мутирован на отказе И-8 — фикс R016-1 не держится\n' >&2
  exit 1
fi
# Все три ветки живы: отказ до merge, ни merge-коммита, ни сноса.
for br in wip/002/implementer wip/003/implementer; do
  if ! git -C "$R" for-each-ref --format='%(refname)' 'refs/heads/wip/' | grep -q "^refs/heads/${br}\$"; then
    printf 'ОТКАЗ: ветка %s снесена до merge — отказ не был ДО merge\n' "$br" >&2
    exit 1
  fi
done
# И wt-002, и wt-003 тоже живы (worktree remove на отказе не вызывался).
for wt in wt-002 wt-003; do
  if ! git -C "$R" worktree list --porcelain | grep -q "^worktree ${WORK}/${wt}\$"; then
    printf 'ОТКАЗ: worktree %s снесён на отказе И-8 — чистка должна быть только при приземлении\n' "$wt" >&2
    exit 1
  fi
done
