#!/usr/bin/env bash
# Клетка red_huk_alfavit_ustanovki — инвариант И-2 контракта 104: алфавит ролей
# хук берёт из config/agent_models.json УСТАНОВЛЕННОГО харнеса (по расположению
# самого расширения), НЕ из cwd проекта и НЕ из окружения. Мир: toy-установка
# <мир>/inst (девять ролей живого конфига) + cwd проекта <мир>/proj с ПОДМЕНЁННЫМ
# config/agent_models.json (роли evil/reviewer/critic/orchestrator на дешёвом тире;
# architect/adversary/arbiter/implementer отсутствуют) + <мир>/pusto без config/. Входы:
#   (1) agent:"evil" (есть ТОЛЬКО в проектном конфиге) → block «тип агента вне алфавита: evil»;
#   (2) agent:"architect" (есть ТОЛЬКО в установочном) → pass;
#   (3) agent:"adversary" (только установочный) → pass;
#   (4) agent:"critic" (в обоих) → pass — различение несёт (1)/(2), не этот вход;
#   (5) agent:"task" → block «спавн без явного agent» (подменённый конфиг этого не меняет).
# Один оракул, ТРИ условия окружения драйвера (каждое — тот же cases.json):
#   (а) HARNESS_* стёрты;
#   (б) HARNESS_TOOLS_ROOT=<мир>/proj — ложный корень С чужим конфигом (роль evil);
#   (в) HARNESS_TOOLS_ROOT=<мир>/pusto — ложный корень БЕЗ конфига.
# Хук, читающий process.cwd()/config (дыра 099), на (а)(1) пропускает evil → КРАСНО;
# хук с приоритетом env (process.env.HARNESS_TOOLS_ROOT || корень расширения) на
# (б)(1) пропускает evil, на (б)(2)/(3) блокирует → КРАСНО; на (в) env-хук даёт
# «конфиг не читается» вместо суда по установке → КРАСНО.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z104_BASE/zashchita-104-alfavit-$$-${RANDOM}"
trap 'rm -rf "$W"' EXIT

if ! SRC="$(z104_guard)"; then
  printf 'КРАСНО: red_huk_alfavit_ustanovki: предмет отсутствует: .omp/extensions/spawn-guard.ts\n' >&2; exit 1
fi
command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }
mkdir -p "$W/proj/config"
z104_cfg_proekt "$W/proj/config/agent_models.json"
GUARD="$(z104_ustanovka "$W" "$SRC")"
z104_fab_driver "$W/fab_driver.mjs"

# Оракул в памяти ДО вызова (правило 8)
P_EVIL='ОТКАЗ: тип агента вне алфавита: evil'
P_TASK='ОТКАЗ: спавн без явного agent: task'
{
  printf '[\n'
  z104_ev 1-evil-tolko-proekt "$P_EVIL" '{"context":"p","tasks":[{"name":"E","agent":"evil","task":"ok"}]}'; printf ',\n'
  z104_ev 2-architect-tolko-ustanovka pass '{"context":"p","tasks":[{"name":"A","agent":"architect","task":"ok"}]}'; printf ',\n'
  z104_ev 3-adversary-tolko-ustanovka pass '{"context":"p","tasks":[{"name":"D","agent":"adversary","task":"ok"}]}'; printf ',\n'
  z104_ev 4-critic-oba pass '{"context":"p","tasks":[{"name":"C","agent":"critic","task":"ok"}]}'; printf ',\n'
  z104_ev 5-task-default "$P_TASK" '{"context":"p","tasks":[{"name":"T","agent":"task","task":"ok"}]}'; printf '\n]\n'
} > "$W/cases.json"

mkdir -p "$W/pusto"
rc=0
for envroot in '' "$W/proj" "$W/pusto"; do
  if [ -z "$envroot" ]; then
    node "$W/fab_driver.mjs" "$GUARD" "$W/cases.json" "$W/proj" || rc=1
  else
    node "$W/fab_driver.mjs" "$GUARD" "$W/cases.json" "$W/proj" "$envroot" || rc=1
  fi
done
if [ "$rc" -eq 0 ]; then printf 'ЗЕЛЕНО: red_huk_alfavit_ustanovki\n'; exit 0; fi
printf 'КРАСНО: red_huk_alfavit_ustanovki: проектный конфиг повлиял на алфавит (rc=%s)\n' "$rc" >&2
exit 1
