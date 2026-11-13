#!/usr/bin/env bash
# Срез старой клетки 660d6d24: ТОЛЬКО implementer-glm. Нет автоматического
# допуска всех специализаций. TRACE физический, контекст implementer.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: specializacija: предмет отсутствует\n' >&2; exit 1; }
red() { printf 'КРАСНО: specializacija: %s\n' "$*" >&2; exit 1; }
W="$(_t95_world specializacija)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_adr "$R" 005 impl '' 'роль:implementer' 'семейная видимость implementer'
_t95_freeze "$R" 'scripts/frozen.sh' >/dev/null
# Расходим draft и frozen, чтобы не принять удачный draft за frozen.
printf '\nЗОНА implementer: scripts/draft-only.sh\n' >>"$R/contracts/777-toy.md"
_t95_trace "$W/trace.tsv" implementer minimax/MiniMax-M3 allowed
_t95_trace "$W/trace.tsv" implementer-glm zai/glm-5.3 allowed
_t95_trace "$W/trace.tsv" implementer-vision minimax/MiniMax-M3 allowed
_t95_trace "$W/trace.tsv" implementer-mini minimax/MiniMax-M3 allowed
out="$(bash "$SUBJ" --repo "$R" --role implementer-glm --contract 777 --model-trace "$W/trace.tsv" 2>"$W/err")"; rc=$?
[ "$rc" -eq 0 ] || red "GLM не получает пак rc=$rc: $(cat "$W/err")"
section() { awk -v name="$1" '$0=="=== "name" ===" {f=1;next} /^=== / {f=0} f {print}' <<<"$out"; }
[ "$(section TRACE)" = 'TRACE: role=implementer-glm model=zai/glm-5.3 fallback=allowed' ] || red 'TRACE не физической роли'
[ "$(section MAP)" = 'MAP: PROJECT.md :: карта проекта' ] || red 'rows не семейной роли'
[ "$(section RULES)" = 'RULES: DEVELOPMENT.md' ] || red 'rules не семейной роли'
[ "$(section REUSE)" = 'REUSE: MODULES.md' ] || red 'reuse не семейной роли'
[ "$(section SKILLS)" = $'SKILL: tdd\nSKILL: diagnosing-bugs' ] || red 'skills не семейного implementer'
grep -Fxq 'ADR: 005 :: семейная видимость implementer' <<<"$(section ADR)" || red 'роль ADR не семейная'
if grep -q '^ADR: 002 ::' <<<"$(section ADR)"; then red 'architect ADR утёк'; fi
grep -Fxq 'ЗОНА implementer: scripts/frozen.sh' <<<"$(section ZONES)" || red 'frozen-зона не выдана'
if grep -Fq 'scripts/draft-only.sh' <<<"$(section ZONES)"; then red 'выдан draft вместо frozen'; fi
printf 'implementer\tminimax/MiniMax-M3\tallowed\n' >"$W/family.tsv"
no="$(bash "$SUBJ" --repo "$R" --role implementer-glm --contract 777 --model-trace "$W/family.tsv" 2>"$W/err")"; rc=$?
[ "$rc" -eq 1 ] && [ -z "$no" ] || red 'семейный TRACE подменил физический'
grep -Fxq 'ОТКАЗ: свидетельство не той роли: implementer-glm' "$W/err" || red 'не та причина потери физической строки'
for role in implementer-vision implementer-mini; do
  no="$(bash "$SUBJ" --repo "$R" --role "$role" --contract 777 --model-trace "$W/trace.tsv" 2>"$W/err")"; rc=$?
  [ "$rc" -eq 1 ] && [ -z "$no" ] || red "лишний допуск $role"
  grep -Fxq "ОТКАЗ: роль вне алфавита: $role" "$W/err" || red "нет алфавитного отказа $role"
done
exit 0
