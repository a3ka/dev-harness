# ПРИЧИНА: имя вне реестра ролей
#
# Срез 3 контракта 016, И-9 (2), закрытие находки 1 адверсария
# (verdicts/adversary/contracts-016.md): committer обязан ТОЧНО ВХОДИТЬ в реестр
# ролей замороженных контрактов. Старая проверка через case `*"$cn"*` ловила
# ПОДСТРОКУ — committer `imple` проходил против реестра `implementer` (только
# substring-матч, не точное равенство строк).
#
# Различимость входа (Н-39): committer==author==imple (СЦЕПКА выполнена — ветвь
# расщепления молчит). Красит ТОЛЬКО точное членство в реестре, где make_repo
# заявил ровно `implementer`. Старая case_imja_vne_reestra.sh этого не покрывает:
# имя `stranger` не является подстрокой `implementer`, и прежняя подстрочная
# альтернатива case на нём не срабатывала.
#
# Зелёный контроль: коммит от implementer (в реестре) → rc 0.
# Красное: коммит от imple (подстрока реестра, не равна никакой его строке) → rc 1
# «имя вне реестра ролей: <sha> — committer imple…».
# Воспроизводимо: строка `imple` не равна строке `implementer`.
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

# ── Красное: committer — подстрока реестра, не равная никакой его строке ─────
mk_wip "$R" wip/002/imple "$WORK/wt-imple"
commit_in "$WORK/wt-imple" imple imple@local 'предмет от имени-подстроки реестра'
out_land="$("$BARRIER" --branch wip/002/imple --worktree "$WORK/wt-imple" --root "$R" 2>&1 || true)"
if ! printf '%s\n' "$out_land" | grep -q 'имя вне реестра ролей'; then
  printf 'ОТКАЗ: land на подстрочный committer не назвал реестр: %s\n' "$out_land" >&2
  exit 1
fi
if ! printf '%s\n' "$out_land" | grep -q 'committer imple'; then
  printf 'ОТКАЗ: причина не назвала конкретное имя-подстроку: %s\n' "$out_land" >&2
  exit 1
fi
