# ПРИЧИНА: не несёт коммитов относительно main
#
# Срез 3 контракта 016, И-1: merge приземления исполняет САМ ВЫЗОВ land_agent, и committer
# результата — orchestrator. Здесь предъявлена ПРАВАЯ ветвь вилки И-1: merge-коммит
# построен ЧУЖОЙ рукой (architect) мимо вызова — и вызов его не легитимирует: диапазон
# main..tip пуст, приземлять нечего, rc 1. Провенанс чужого merge журналом не различим
# (committer подделываем `-c`, cognitive-only предел названного контрактом), потому
# судится ПЕРЕХОД: отказавший вызов main НЕ сдвинул, а подпись оставшегося merge —
# architect, не orchestrator.
#
# Различимость входа (Н-39): главное дерево чисто, ветка жива, worktree жив и HEAD в нём
# != main, identity сцеплена и в реестре — красит ровно чужой merge, уже уложивший ветку
# в main.
#
# Зелёный контроль: merge строит сам вызов — main сдвинут, main^1 == main_before,
# main^2 == tip, committer == orchestrator (assert_landed).
# Красное: architect делает `merge --no-ff` руками, затем вызов → rc 1. Воспроизводимо:
# чужой merge остаётся в журнале.
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

# ── Красное: merge построен чужой рукой мимо вызова ───────────────────────────
mk_wip "$R" wip/002/implementer "$WORK/wt-chuzhoj"
commit_in "$WORK/wt-chuzhoj" implementer implementer@dev-harness.local 'предмет второй ветки'
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=architect -c user.email=architect@dev-harness.local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      merge --no-ff -m 'merge, построенный architect мимо land_agent' wip/002/implementer >/dev/null 2>&1
main_before_red="$(git -C "$R" rev-parse main)"
out_land="$("$BARRIER" --branch wip/002/implementer --worktree "$WORK/wt-chuzhoj" --root "$R" || true)"
if ! printf '%s\n' "$out_land" | grep -q 'не несёт коммитов относительно main'; then
  printf 'ОТКАЗ: land на чужом merge не отказал по пустому диапазону: %s\n' "$out_land" >&2
  exit 1
fi
if [ "$(git -C "$R" rev-parse main)" != "$main_before_red" ]; then
  printf 'ОТКАЗ: отказавший вызов сдвинул main\n' >&2
  exit 1
fi
if [ "$(git -C "$R" log -1 --format='%cn' main)" = "orchestrator" ]; then
  printf 'ОТКАЗ: чужой merge подписан orchestrator — вход не построен\n' >&2
  exit 1
fi
