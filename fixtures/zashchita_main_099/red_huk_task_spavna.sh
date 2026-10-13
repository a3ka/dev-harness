#!/usr/bin/env bash
# Клетка red_huk_task_spavna — инвариант З-7 (Н-270) контракта 099: точка
# перехвата РЕАЛЬНОГО запроса спавна — хук omp tool_call('task') проектного
# расширения .omp/extensions/spawn-guard.ts (граница арбитража
# verdicts/arbitration/contracts-099-spawn-trust-v1.md, круг 3: spawn_agent
# запроса судей не несёт — за историю ни одной ветки wip/*/critic|...).
# Фабричный seam: register() + синтетические события ИЗМЕРЕННОЙ формы
# {type:'tool_call', toolName, toolCallId, input:{context, tasks:[{name,
# agent, task}]}} (прецеденты fixtures/path_guard/red_extract_pin_actual_066.sh,
# fixtures/qa_kanal_xd/red_kanal_qa_report_issue.sh).
# Входы (каждый красен/зелен СВОИМ предъявлением, Н-39):
#   (1) batch agent:"task" (= опущен, замер 3) → block «спавн без явного agent»;
#   (2) flat agent:"m1" → block «тип агента вне алфавита: m1»;
#   (3) flat agent:"sonic" → block «тип агента вне алфавита: sonic»;
#   (4) batch [critic, sonic, arbiter]: один плохой заражает вызов → block;
#   (5) batch [task, critic] → block «спавн без явного agent»;
#   (6) валидные роли → pass: critic/adversary/reviewer/arbiter/architect/
#       implementer/scout (scout — явно перечисленный харнесный тип);
#   (7) toolName:'write' с agent:"task" → pass (чужие инструменты не трогаем);
#   (8) битый input: строка / tasks не массив / элемент не объект / agent не
#       строка → block fail-closed;
#   (9) flat БЕЗ ключа agent → block «спавн без явного agent».
# Субъект: Z99_SPAWN_GUARD (стаб-пак) → <корень>/.omp/extensions/spawn-guard.ts.
# Стаб-пак — battery_stubs.sh (t99-m10 вход 1, t99-m11 вход 1, t99-m12 вход 4,
# t99-m13 вход 8; каждый к входу, где дефект наблюдаем).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z99_BASE/zashchita-099-huk-$$-${RANDOM}"
trap 'rm -rf "$W"' EXIT

ROOT="${Z99_099_ROOT:-$(cd "$HERE/../.." && pwd)}"
GUARD="${Z99_SPAWN_GUARD:-}"
if [ -z "$GUARD" ] || [ ! -f "$GUARD" ]; then GUARD="$ROOT/.omp/extensions/spawn-guard.ts"; fi
[ -f "$GUARD" ] || { printf 'КРАСНО: red_huk_task_spavna: предмет отсутствует: %s\n' "$GUARD" >&2; exit 1; }
command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }

# toy-корень алфавита: РОЛИ config/agent_models.json живой грамматики
# (roles — те же девять, что в живом конфиге; scout в конфиг НЕ пишем —
# харнесный тип несёт сам предмет, одно место перечисления в коде).
T="$W/toyroot"; mkdir -p "$T/config"
cat > "$T/config/agent_models.json" <<'JSON'
{"models":{"gpt-astra":"openai-codex/gpt-6-astra","gpt-terra":"openai-codex/gpt-5.6-terra","opus":"anthropic/claude-opus-5-5","fable":"anthropic/claude-fable-5-1","glm":"zai/glm-5.3","minimax-lightning":"minimax/MiniMax-M2.5-lightning"},"tiers":{"apex":{"model":"@gpt-astra"},"advisor":{"model":"@gpt-terra"},"audit":{"model":"@opus"},"plan":{"model":"@fable"},"slow":{"model":"@glm"},"task":{"model":"@glm"},"default":{"model":"@opus"},"steward":{"model":"@opus"},"consultant":{"model":"@gpt-astra"}},"roles":{"orchestrator":"default","architect":"slow","implementer":"task","adversary":"advisor","critic":"apex","reviewer":"audit","arbiter":"plan","steward":"steward","consultant":"consultant"}}
JSON

# Драйвер фабрики: import субъекта, синтетический pi собирает обработчики,
# события — из cases.json; cwd драйвера = toy-корень (алфавит по process.cwd()).
cat > "$W/fab_driver.mjs" <<'MJS'
import { pathToFileURL } from 'node:url';
import { readFileSync } from 'node:fs';
const [guard, casesFile, cwd] = process.argv.slice(2);
const mod = await import(pathToFileURL(guard).href);
// register — default-экспорт фабрики (та же форма, что path-guard); именной
// экспорт принят как запасной (честный предмет несёт оба).
const reg = typeof mod.register === 'function' ? mod.register
  : (typeof mod.default === 'function' ? mod.default : null);
if (reg === null) { console.error('НЕТ register'); process.exit(2); }
const handlers = [];
const pi = { on: (_name, handler) => { handlers.push(handler); } };
reg(pi);
if (handlers.length < 1) { console.error('НЕТ обработчика'); process.exit(2); }
const handler = handlers[handlers.length - 1];
const cases = JSON.parse(readFileSync(casesFile, 'utf8'));
process.chdir(cwd);
let bad = 0;
for (const c of cases) {
  const got = handler(c.event);
  const gotBlock = got !== undefined && got.block === true && typeof got.reason === 'string';
  const wantBlock = c.want !== 'pass';
  const ok = wantBlock ? (gotBlock && got.reason.includes(c.want)) : got === undefined;
  if (!ok) bad++;
  console.log(`${ok ? 'ok' : 'FAIL'} ${c.name} got=${JSON.stringify(got)}`);
}
console.log(`случаев ${cases.length}, провалено ${bad}`);
process.exit(bad > 0 ? 1 : 0);
MJS

# Оракул в памяти ДО вызова (правило 8): случаи и ожидания — здесь, не в предмете.
P1='ОТКАЗ: спавн без явного agent: task'
P_M1='ОТКАЗ: тип агента вне алфавита: m1'
P_SONIC='ОТКАЗ: тип агента вне алфавита: sonic'
PFC='fail-closed'
cat > "$W/cases.json" <<JSON
[
{"name":"1-task-default","want":"$P1","event":{"type":"tool_call","toolName":"task","toolCallId":"c1","input":{"context":"p","tasks":[{"name":"A1","agent":"task","task":"Скажи ok"}]}}},
{"name":"2-flat-m1","want":"$P_M1","event":{"type":"tool_call","toolName":"task","toolCallId":"c2","input":{"context":"p","name":"F1","agent":"m1","task":"Скажи ok"}}},
{"name":"3-flat-sonic","want":"$P_SONIC","event":{"type":"tool_call","toolName":"task","toolCallId":"c3","input":{"context":"p","name":"F2","agent":"sonic","task":"Скажи ok"}}},
{"name":"4-batch-one-bad","want":"$P_SONIC","event":{"type":"tool_call","toolName":"task","toolCallId":"c4","input":{"context":"p","tasks":[{"name":"B1","agent":"critic","task":"ok"},{"name":"B2","agent":"sonic","task":"ok"},{"name":"B3","agent":"arbiter","task":"ok"}]}}},
{"name":"5-batch-task-first","want":"$P1","event":{"type":"tool_call","toolName":"task","toolCallId":"c5","input":{"context":"p","tasks":[{"name":"C1","agent":"task","task":"ok"},{"name":"C2","agent":"critic","task":"ok"}]}}},
{"name":"6a-critic","want":"pass","event":{"type":"tool_call","toolName":"task","toolCallId":"c6a","input":{"context":"p","tasks":[{"name":"R1","agent":"critic","task":"ok"}]}}},
{"name":"6b-adversary","want":"pass","event":{"type":"tool_call","toolName":"task","toolCallId":"c6b","input":{"context":"p","tasks":[{"name":"R2","agent":"adversary","task":"ok"}]}}},
{"name":"6c-reviewer","want":"pass","event":{"type":"tool_call","toolName":"task","toolCallId":"c6c","input":{"context":"p","tasks":[{"name":"R3","agent":"reviewer","task":"ok"}]}}},
{"name":"6d-arbiter","want":"pass","event":{"type":"tool_call","toolName":"task","toolCallId":"c6d","input":{"context":"p","tasks":[{"name":"R4","agent":"arbiter","task":"ok"}]}}},
{"name":"6e-architect","want":"pass","event":{"type":"tool_call","toolName":"task","toolCallId":"c6e","input":{"context":"p","tasks":[{"name":"R5","agent":"architect","task":"ok"}]}}},
{"name":"6f-implementer","want":"pass","event":{"type":"tool_call","toolName":"task","toolCallId":"c6f","input":{"context":"p","tasks":[{"name":"R6","agent":"implementer","task":"ok"}]}}},
{"name":"6g-scout","want":"pass","event":{"type":"tool_call","toolName":"task","toolCallId":"c6g","input":{"context":"p","tasks":[{"name":"R7","agent":"scout","task":"ok"}]}}},
{"name":"7-other-tool","want":"pass","event":{"type":"tool_call","toolName":"write","toolCallId":"c7","input":{"path":"x.txt","agent":"task"}}},
{"name":"8a-broken-string","want":"$PFC","event":{"type":"tool_call","toolName":"task","toolCallId":"c8a","input":"битый"}},
{"name":"8b-tasks-not-array","want":"$PFC","event":{"type":"tool_call","toolName":"task","toolCallId":"c8b","input":{"context":"p","tasks":"не-массив"}}},
{"name":"8c-element-not-object","want":"$PFC","event":{"type":"tool_call","toolName":"task","toolCallId":"c8c","input":{"context":"p","tasks":["строка-вместо-объекта"]}}},
{"name":"8d-agent-not-string","want":"$PFC","event":{"type":"tool_call","toolName":"task","toolCallId":"c8d","input":{"context":"p","name":"X","agent":7,"task":"ok"}}},
{"name":"9-flat-no-agent","want":"$P1","event":{"type":"tool_call","toolName":"task","toolCallId":"c9","input":{"context":"p","name":"N1","task":"Скажи ok"}}}
]
JSON

node "$W/fab_driver.mjs" "$GUARD" "$W/cases.json" "$T"
rc=$?
if [ "$rc" -eq 0 ]; then
  printf 'ЗЕЛЕНО: red_huk_task_spavna\n'
  exit 0
fi
printf 'КРАСНО: red_huk_task_spavna: провалено фабричным драйвером (rc=%s)\n' "$rc" >&2
exit 1
