# ПРИЧИНА: не несёт коммитов относительно main
#
# Срез 3 контракта 016, И-1: агентский коммит не достижим из main минуя merge-коммит.
# Здесь предъявлена ЛЕВАЯ ветвь вилки И-1: агентский коммит уже уехал в main МИМО merge
# (fast-forward главного чекаута), и приземлять нечего — задним числом легитимировать
# ушедший коммит вызов не может, он отказывает и main НЕ двигает.
#
# Различимость входа (Н-39): диапазон main..tip ПУСТ при живой ветке, живом worktree с
# HEAD != main, чистом главном дереве и сцепленной identity в реестре — все прочие ветви
# отказа на этом входе молчат.
#
# Зелёный контроль: приземление наблюдается ПЕРЕХОДОМ — main сдвинут вызовом, main^1 ==
# main_before, main^2 == tip, committer merge-коммита == orchestrator (assert_landed).
# Красное: коммит ветки влит в main через `merge --ff-only` (merge-коммита НЕТ), сверху
# ещё один агентский коммит прямо на main; вызов → rc 1 «ветка … не несёт коммитов
# относительно main». Воспроизводимо: журнал не откатывается.
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

# ── Красное: агентский коммит попал в main мимо merge ─────────────────────────
mk_wip "$R" wip/002/implementer "$WORK/wt-mimo"
commit_in "$WORK/wt-mimo" implementer implementer@dev-harness.local 'агентский предмет'
g "$R" merge --ff-only wip/002/implementer >/dev/null 2>&1
commit_in "$R" implementer implementer@dev-harness.local 'ещё один агентский коммит прямо на main'
if git -C "$R" rev-parse --verify --quiet 'main^2' >/dev/null; then
  printf 'ОТКАЗ: main оказался merge-коммитом — вход «мимо merge» не построен\n' >&2
  exit 1
fi
main_before_red="$(git -C "$R" rev-parse main)"
out_land="$("$BARRIER" --branch wip/002/implementer --worktree "$WORK/wt-mimo" --root "$R" || true)"
if ! printf '%s\n' "$out_land" | grep -q 'не несёт коммитов относительно main'; then
  printf 'ОТКАЗ: land на ушедшем мимо merge коммите не назвал пустой диапазон: %s\n' "$out_land" >&2
  exit 1
fi
if [ "$(git -C "$R" rev-parse main)" != "$main_before_red" ]; then
  printf 'ОТКАЗ: отказавший вызов сдвинул main — приземления на отказе не бывает\n' >&2
  exit 1
fi
