# ПРИЧИНА: коммит вне зоны
#
# И-1 контракта 021 (ветвь А): чужое открытое окно не судится ПО ПОСТРОЕНИЮ.
# Два открытых контракта 001 и 002; agent-x объявлен в ОБОИХ (cross-track касание
# тем же именем — измеренный случай Н-66). Land-merge ветки 002 (маркер
# `land: wip/002/…`) приносит коммит agent-x на путь зоны 002, ВНЕ зон 001 —
# коммит лежит внутри старого линейного хвоста 001.
#   зелёный: чужой land-merge на путь зоны чужого окна → 0 (линейная модель
#   здесь краснела — это и была боль Н-66);
#   красное: тот же маркер приносит коммит ВНЕ зон ОБОИХ окон → 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R" 'ЗОНА agent-x: scripts/'
add_contract "$R" 002 'ЗОНА agent-x: plans/'

# ── зелёный контроль: чужой land-merge на путь зоны чужого окна ───────────────
mkdir -p "$R/plans"
printf 'работа окна 002 в своей зоне\n' > "$R/plans/chuzhoe-okno.md"
g "$R" checkout -q -b wip/002/agent-x
commit_as "$R" agent-x 'работа окна 002'
g "$R" checkout -q main
g "$R" merge --no-ff -q -m 'land: wip/002/agent-x' wip/002/agent-x
"$BARRIER" "$R"

# ── красное: принесённое — вне зон ОБОИХ окон ────────────────────────────────
mkdir -p "$R/docs"
printf 'вне зон обоих окон\n' > "$R/docs/vne-oboih.md"
g "$R" checkout -q -b wip/002/agent-x-dva
commit_as "$R" agent-x 'вне зон обоих окон'
g "$R" checkout -q main
g "$R" merge --no-ff -q -m 'land: wip/002/agent-x-dva' wip/002/agent-x-dva
"$BARRIER" "$R"
