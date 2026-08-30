# ПРИЧИНА: предмет не в worktree
#
# Срез 3 контракта 016, И-8 (b), предмет R016-2 (ре-ревью 7e5ed45): постоянная проверка
# чужого worktree, написанная architect'ом — автор проверки НЕ автор механизма; этот
# коммит scripts/land_agent.sh не трогает.
#
# Предмет: tip заявленной ветки и HEAD переданного worktree — РАЗНЫЕ коммиты, значит в
# worktree лежит ЧУЖОЙ предмет, и merge перенёс бы на main именно его. Отказ обязан
# случиться ДО merge: rc 1 «предмет не в worktree», и мутации нет — main стоит, обе
# ветки и оба worktree переживают вызов (снос без приземления не бывает, И-4).
#
# Различимость входа (Н-39): две ветки, каждая со СВОИМ коммитом и worktree; на вход
# подаётся --branch wip/030/implementer с worktree ЧУЖОЙ ветки (wt-020). Судья, читающий
# только «HEAD worktree != main» (И-8 (a)), зелен: wt-020 стоит на собственном коммите.
# Судья, читающий только «ветка жива / worktree жив / реестр / сцепка identity», тоже
# зелен. Красит ровно сверка HEAD worktree == tip_sha ЗАЯВЛЕННОЙ ветки.
#
# Зелёный контроль: своя пара wip/010/implementer + wt-010 → приземление rc 0 наблюдается
# ПЕРЕХОДОМ (assert_landed: main сдвинут вызовом, main^1 == main_before, main^2 == tip,
# committer orchestrator, ветка снесена), и worktree снят тем же вызовом — «удаление
# ветки и worktree СРАЗУ».
#
# Красное (повтор проверяющим жив: состояние не откатывается): --branch wip/030
# --worktree wt-020 → rc 1 «предмет не в worktree»; сохранность — поимённо: main стоит,
# обе ветки живы, оба worktree живы.
#
# Серийные вызовы — `|| true` (А-32).
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"
cd "$R"

# ── Зелёный контроль: своя пара, приземление переходом + снос сразу ───────────
mk_wip "$R" wip/010/implementer "$WORK/wt-010"
commit_in "$WORK/wt-010" implementer implementer@dev-harness.local 'предмет зелёной ветки'
mb="$(git -C "$R" rev-parse main)"
tip="$(git -C "$R" rev-parse refs/heads/wip/010/implementer)"
"$BARRIER" --branch wip/010/implementer --worktree "$WORK/wt-010" --root "$R" || true
assert_landed "$R" "$mb" "$tip" wip/010/implementer
if git -C "$R" worktree list --porcelain | grep -q "^worktree ${WORK}/wt-010$"; then
  printf 'ОТКАЗ: worktree wt-010 пережил успешное приземление — снос не «сразу»\n' >&2
  exit 1
fi

# ── Построение красного входа: две ветки, каждая со своим предметом ───────────
mk_wip "$R" wip/020/implementer "$WORK/wt-020"
commit_in "$WORK/wt-020" implementer implementer@dev-harness.local 'предмет второй ветки'
mk_wip "$R" wip/030/implementer "$WORK/wt-030"
commit_in "$WORK/wt-030" implementer implementer@dev-harness.local 'предмет третьей ветки'
tip20="$(git -C "$R" rev-parse refs/heads/wip/020/implementer)"
tip30="$(git -C "$R" rev-parse refs/heads/wip/030/implementer)"
wt20_head="$(git -C "$WORK/wt-020" rev-parse HEAD)"
# Охранные сверки построения: вход — именно ЧУЖОЙ worktree (не пустая и не своя ветка).
if [ "$tip20" = "$tip30" ]; then
  printf 'ОТКАЗ: tip-ы веток совпали — вход «чужой предмет» не построен\n' >&2
  exit 1
fi
if [ "$wt20_head" != "$tip20" ]; then
  printf 'ОТКАЗ: wt-020 стоит не на своём tip — вход построен неверно\n' >&2
  exit 1
fi

# ── Красное: заявлена wip/030, передан worktree ЧУЖОЙ ветки wt-020 ────────────
mb_red="$(git -C "$R" rev-parse main)"
out_land="$("$BARRIER" --branch wip/030/implementer --worktree "$WORK/wt-020" --root "$R" || true)"
if ! printf '%s\n' "$out_land" | grep -q 'предмет не в worktree'; then
  printf 'ОТКАЗ: land на чужом worktree не назвал И-8 «предмет не в worktree»: %s\n' "$out_land" >&2
  exit 1
fi
# Сохранность main: отказ ДО merge — main не сдвинут (фикс R016-1 держится).
if [ "$(git -C "$R" rev-parse main)" != "$mb_red" ]; then
  printf 'ОТКАЗ: main мутирован на отказе И-8 — merge успел исполниться до отказа\n' >&2
  exit 1
fi
# Сохранность веток: обе живы — сноса без приземления не бывает.
for br in wip/020/implementer wip/030/implementer; do
  if ! git -C "$R" for-each-ref --format='%(refname)' 'refs/heads/wip/' | grep -q "^refs/heads/${br}\$"; then
    printf 'ОТКАЗ: ветка %s снесена на отказе — отказ не был ДО merge\n' "$br" >&2
    exit 1
  fi
done
# Сохранность worktree: оба живы — чистка только при приземлении.
for wt in wt-020 wt-030; do
  if ! git -C "$R" worktree list --porcelain | grep -q "^worktree ${WORK}/${wt}\$"; then
    printf 'ОТКАЗ: worktree %s снесён на отказе — чистка должна быть только при приземлении\n' "$wt" >&2
    exit 1
  fi
done
