# ПРИЧИНА: имя вне реестра ролей
#
# Срез 3 контракта 016, И-9 (2): committer коммита диапазона обязан входить в реестр
# авторов ЗОНА-строк замороженных контрактов — ТОТ ЖЕ список, что собирает check_zones
# (единая реализация lib_zones; второй реестр запрещён).
#
# Различимость входа (Н-39): коммит СЦЕПЛЕН (committer==author==stranger) — ветвь
# расщепления на нём молчит; красит только реестр, где make_repo объявил одного
# implementer'а.
#
# Зелёный контроль: коммит от implementer (в реестре) → rc 0 и сверки И-1.
# Красное: коммит от stranger → rc 1 «имя вне реестра ролей: <sha> — committer stranger…».
# Воспроизводимо: stranger не становится implementer'ом.
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

# ── Красное: сцепленный коммит от имени, которого нет ни в одной ЗОНА-строке ──
mk_wip "$R" wip/002/stranger "$WORK/wt-stranger"
commit_in "$WORK/wt-stranger" stranger stranger@local 'предмет от имени вне реестра'
out_land="$("$BARRIER" --branch wip/002/stranger --worktree "$WORK/wt-stranger" --root "$R" || true)"
if ! printf '%s\n' "$out_land" | grep -q 'имя вне реестра ролей'; then
  printf 'ОТКАЗ: land на committer вне реестра не назвал реестр: %s\n' "$out_land" >&2
  exit 1
fi
