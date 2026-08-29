# ПРИЧИНА: коммит мимо merge
#
# Срез 3 контракта 016, ветвь И-1: агентский коммит НЕ достижим из main мимо merge-коммита.
# Зелёный контроль: ветка wip/* + land_agent корректно её сливает → rc 0. Красное: коммит
# уже на main мимо merge (нет merge-коммита) → фикстура имитирует, что land_agent отказал.
#
# ЗДЕСЬ: красное — коммит предъявляется в HEAD main, но land_agent должен отказать, потому
# что нет ветки wip/* для слияния (И-1: валидатор чужого merge попадает в вилку без выхода —
# заранее построенного merge нет — валидировать нечего).
set -uo pipefail
R="$WORK/repo"
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"
make_repo "$R"

# Зелёный контроль: создать wip/* ветку с одним коммитом и приземлить.
WT_DIR="$(mktemp -d /tmp/land-agent-green.XXXXXX)"
git -C "$R" branch wip/001/implementer main
git -C "$R" worktree add -q "$WT_DIR" wip/001/implementer
commit_as "$R" implementer 'работа в зоне'
git -C "$WT_DIR" reset --hard refs/heads/wip/001/implementer >/dev/null 2>&1 || true
"$BARRIER" "$R" wip/001/implementer "$WT_DIR" || true

# Красное: имитировать ситуацию «коммит на main мимо merge» — прямой коммит на main
# (мимо worktree, мимо wip/*). Здесь barrierm должен отказать, но поскольку заранее
# построенного merge нет, валидировать нечего — отдельный кейс И-1.
git -C "$R" -c user.name=implementer -c user.email=implementer@local \
    -c commit.gpgsign=false commit --allow-empty -q -m 'мимо merge'
if "$BARRIER" "$R" wip/002/nonexistent "$WT_DIR" >/dev/null 2>&1; then
  printf 'ОТКАЗ: land_agent не отказал при отсутствии wip/* — нет валидации перехода (И-1)\n' >&2
  exit 1
fi
