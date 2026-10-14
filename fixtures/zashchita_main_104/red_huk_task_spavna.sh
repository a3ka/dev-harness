#!/usr/bin/env bash
# Клетка red_huk_task_spavna — инвариант И-1 контракта 104: точка перехвата
# РЕАЛЬНОГО запроса спавна — хук omp tool_call('task') расширения
# .omp/extensions/spawn-guard.ts УСТАНОВЛЕННОГО харнеса (граница арбитража
# verdicts/arbitration/contracts-099-spawn-trust-v1.md: spawn_agent запроса судей
# не несёт; omp резолвит дефолт agent:"task" ДО хука — замер 3).
# Мир: toy-УСТАНОВКА <мир>/inst (хук + config/agent_models.json девяти ролей);
# cwd драйвера — <мир>/proj БЕЗ config/ (внешний проект, у которого конфига нет):
# хук, читающий алфавит из cwd, здесь ломается на ВСЕХ входах — это и есть дыра 099.
# Входы (каждый красен/зелен СВОИМ предъявлением, Н-39):
#   (1) batch agent:"task" (= опущен) → block «спавн без явного agent»;
#   (2) flat agent:"m1" → block «тип агента вне алфавита: m1»;
#   (3) flat agent:"sonic" → block «тип агента вне алфавита: sonic»;
#   (4) batch [critic, sonic, arbiter]: один плохой заражает вызов → block;
#   (5) batch [task, critic] → block «спавн без явного agent»;
#   (6) валидные роли установочного конфига → pass: critic/adversary/reviewer/
#       arbiter/architect/implementer/scout (scout — харнесный тип предмета);
#   (7) toolName:'write' с agent:"task" → pass (чужие инструменты не трогаем);
#   (8) битый input: строка / tasks не массив / элемент не объект / agent не
#       строка → block fail-closed;
#   (9) flat БЕЗ ключа agent → block «спавн без явного agent».
# Субъект: Z104_SPAWN_GUARD (стаб-пак) → <корень>/.omp/extensions/spawn-guard.ts;
# до реализации красна «предмет отсутствует». Стаб-пак — battery_stubs.sh.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z104_BASE/zashchita-104-huk-$$-${RANDOM}"
trap 'rm -rf "$W"' EXIT

if ! SRC="$(z104_guard)"; then
  printf 'КРАСНО: red_huk_task_spavna: предмет отсутствует: .omp/extensions/spawn-guard.ts\n' >&2; exit 1
fi
command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }
mkdir -p "$W/proj"
GUARD="$(z104_ustanovka "$W" "$SRC")"
z104_fab_driver "$W/fab_driver.mjs"

# Оракул в памяти ДО вызова (правило 8)
P1='ОТКАЗ: спавн без явного agent: task'
P_M1='ОТКАЗ: тип агента вне алфавита: m1'
P_SONIC='ОТКАЗ: тип агента вне алфавита: sonic'
PFC='fail-closed'
{
  printf '[\n'
  z104_ev 1-task-default "$P1" '{"context":"p","tasks":[{"name":"A1","agent":"task","task":"ok"}]}'; printf ',\n'
  z104_ev 2-flat-m1 "$P_M1" '{"context":"p","name":"F1","agent":"m1","task":"ok"}'; printf ',\n'
  z104_ev 3-flat-sonic "$P_SONIC" '{"context":"p","name":"F2","agent":"sonic","task":"ok"}'; printf ',\n'
  z104_ev 4-batch-one-bad "$P_SONIC" '{"context":"p","tasks":[{"name":"B1","agent":"critic","task":"ok"},{"name":"B2","agent":"sonic","task":"ok"},{"name":"B3","agent":"arbiter","task":"ok"}]}'; printf ',\n'
  z104_ev 5-batch-task-first "$P1" '{"context":"p","tasks":[{"name":"C1","agent":"task","task":"ok"},{"name":"C2","agent":"critic","task":"ok"}]}'; printf ',\n'
  for r in critic adversary reviewer arbiter architect implementer scout; do
    z104_ev "6-$r" pass "{\"context\":\"p\",\"tasks\":[{\"name\":\"R\",\"agent\":\"$r\",\"task\":\"ok\"}]}"; printf ',\n'
  done
  printf '{"name":"7-other-tool","want":"pass","event":{"type":"tool_call","toolName":"write","toolCallId":"c7","input":{"path":"x.txt","agent":"task"}}},\n'
  z104_ev 8a-broken-string "$PFC" '"битый"'; printf ',\n'
  z104_ev 8b-tasks-not-array "$PFC" '{"context":"p","tasks":"не-массив"}'; printf ',\n'
  z104_ev 8c-element-not-object "$PFC" '{"context":"p","tasks":["строка"]}'; printf ',\n'
  z104_ev 8d-agent-not-string "$PFC" '{"context":"p","name":"X","agent":7,"task":"ok"}'; printf ',\n'
  z104_ev 9-flat-no-agent "$P1" '{"context":"p","name":"N1","task":"ok"}'; printf '\n]\n'
} > "$W/cases.json"

node "$W/fab_driver.mjs" "$GUARD" "$W/cases.json" "$W/proj"
rc=$?
if [ "$rc" -eq 0 ]; then printf 'ЗЕЛЕНО: red_huk_task_spavna\n'; exit 0; fi
printf 'КРАСНО: red_huk_task_spavna: провалено фабричным драйвером (rc=%s)\n' "$rc" >&2
exit 1
