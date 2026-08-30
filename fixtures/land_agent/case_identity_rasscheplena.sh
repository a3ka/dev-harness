# ПРИЧИНА: identity расщеплена
#
# Срез 3 контракта 016, И-9 (1): если у какого-либо коммита приземляемого диапазона
# committer != author, приземление отказывает rc 1 ДО merge поимённо. Проверка живёт в
# land_agent, а не в хуке — `--no-verify` её не обходит.
#
# Различимость входа (Н-39): коммит диапазона с author=implementer (имя В реестре) и
# committer=stranger. Судья, читающий только author, на этом входе зелен; судья,
# читающий только реестр, тоже зелен — красит ровно СЦЕПКА ПАРЫ ПОЛЕЙ.
#
# Зелёный контроль: коммит с committer==author==implementer → rc 0 и сверки И-1.
# Красное: расщеплённый коммит → rc 1 «identity расщеплена: <sha> author=… committer=…».
# Воспроизводимо: расщеплённый коммит остаётся в ветке.
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

# ── Красное: коммит диапазона с committer != author ──────────────────────────
mk_wip "$R" wip/002/implementer "$WORK/wt-split"
GIT_AUTHOR_NAME=implementer GIT_AUTHOR_EMAIL=implementer@dev-harness.local \
GIT_COMMITTER_NAME=stranger GIT_COMMITTER_EMAIL=stranger@local \
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$WORK/wt-split" -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      commit --allow-empty -q -m 'предмет с расщеплённой identity'
out_land="$("$BARRIER" --branch wip/002/implementer --worktree "$WORK/wt-split" --root "$R" || true)"
if ! printf '%s\n' "$out_land" | grep -q 'identity расщеплена'; then
  printf 'ОТКАЗ: land на расщеплённой identity не назвал расщепление: %s\n' "$out_land" >&2
  exit 1
fi
