# ПРИЧИНА: коммит вне зоны
#
# И-2 контракта 021 (ветвь А): СВОЯ merge-дельта судится. Land-merge ветки 001
# (маркер `land: wip/001/…`) приносит коммит объявленного автора на путь ВНЕ зон
# его контракта → красный «вне зоны»; принесённое В зону → зелёный. Слабая
# реализация «теряет merge-принесённые» зелёна на красном входе — её держит эта
# пара (и фаза 4 probe_slabye_realizacii.sh).
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R" 'ЗОНА agent-x: scripts/'

# ── зелёный контроль: своя ветка приносит работу ВНУТРИ зоны ─────────────────
printf 'в зоне через ветку\n' >> "$R/scripts/a.sh"
g "$R" checkout -q -b wip/001/agent-x
commit_as "$R" agent-x 'свой коммит в зоне'
g "$R" checkout -q main
g "$R" merge --no-ff -q -m 'land: wip/001/agent-x' wip/001/agent-x
"$BARRIER" "$R"

# ── красное: своя ветка приносит коммит ВНЕ зоны ─────────────────────────────
mkdir -p "$R/docs"
printf 'вне зоны, принесено merge своей ветки\n' > "$R/docs/svoja-delta.md"
g "$R" checkout -q -b wip/001/agent-x-dva
commit_as "$R" agent-x 'нарушение в своей ветке'
g "$R" checkout -q main
g "$R" merge --no-ff -q -m 'land: wip/001/agent-x-dva' wip/001/agent-x-dva
"$BARRIER" "$R"
