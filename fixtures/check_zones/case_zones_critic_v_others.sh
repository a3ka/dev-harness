# ПРИЧИНА: коммит вне зоны
#
# Совет круга 2 контракта 011 + закрытие обхода «critic вносит всё одним коммитом»:
# critic объявлен ЗОНА-строкой с ЕДИНСТВЕННЫМ путём verdicts/critic/contracts-010-v2.md —
# с этого момента его коммиты ПОДЛЕЖАТ проверке зон, и выход в AGENTS.md или
# contracts/010-* (зона implementer) красит check_zones: акт (ii) не может быть
# внесён тем же автором, что раннер и устав.
#
# Зелёный контроль: critic коммитит ТОЛЬКО свой вердикт → 0. Красное: он же
# добавляет AGENTS.md — коммит вне зоны.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_repo "$R" 'ЗОНА implementer: scripts/verify_antiplacebo.sh AGENTS.md contracts/010-x.md
ЗОНА critic: verdicts/critic/contracts-010-v2.md'
"$BARRIER" "$R"

mkdir -p "$R/verdicts/critic"
printf 'accept\nотдельный круг критика по закоммиченному блобу 010\n' \
  > "$R/verdicts/critic/contracts-010-v2.md"
commit_as "$R" critic 'вердикт 010-v2: accept — только своя зона'
"$BARRIER" "$R"

printf 'норма приёмки судьи v2 (обход круга 2: critic вносит устав одним коммитом с вердиктом)\n' \
  > "$R/AGENTS.md"
commit_as "$R" critic 'занёс норму и аннотацию тем же автором, что и вердикт'
"$BARRIER" "$R"
