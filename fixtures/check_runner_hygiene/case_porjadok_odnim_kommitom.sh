# ПРИЧИНА: ОДНИМ коммитом
# Ветвь (porjadok): барьер ловит обход, где раннер, AGENTS.md, аннотация 010 и
# заранее написанный вердикт 010-v2 (accept) вносятся ОДНИМ коммитом с автором
# critic (обход круга 2 критика: конечные проверки видели разрешение, вердикт и
# тег, но не порядок коммитов — критик не судил закоммиченный блоб отдельным
# кругом). Зелёный контроль — два акта: (i) implementer, (ii) critic.
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_porjadok_green "$G"
"$BARRIER" "$G" porjadok

R="$WORK/red"; mk_green_root "$R"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R"
mkdir -p "$R/verdicts/critic"
printf 'accept\nвердикт написан заранее, тем же коммитом (обход круга 2)\n' \
  > "$R/verdicts/critic/contracts-010-v2.md"
pgit_commit_as "$R" critic 'раннер + AGENTS.md + аннотация 010 + вердикт 010-v2 одним коммитом'
"$BARRIER" "$R" porjadok
