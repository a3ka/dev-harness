#!/usr/bin/env bash
# Каркас миров 104 (контракт 104 — узкий доверенный гейт судьи): общие построители
# toy-миров клеток. Суждений не несёт; клетки зовут построители и держат оракул
# в своей памяти (правило 8).
set -uo pipefail

Z104_BASE="${Z104_BASE:-/tmp/dev-harness-verify}"

# z104_subject <имя-файла> — путь субъекта клетки: D104_SUBJECTS_DIR (стаб-пак) → ROOT/scripts.
# Отказ (rc 1) = «предмет отсутствует». ROOT — Z104_ROOT или дерево семьи.
z104_subject() {
  local n="$1" root="${Z104_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  if [ -n "${D104_SUBJECTS_DIR:-}" ] && [ -f "$D104_SUBJECTS_DIR/$n" ]; then
    printf '%s' "$D104_SUBJECTS_DIR/$n"; return 0
  fi
  if [ -f "$root/scripts/$n" ]; then printf '%s' "$root/scripts/$n"; return 0; fi
  return 1
}

# z104_guard — путь субъекта-хука: Z104_SPAWN_GUARD (стаб-пак) → ROOT/.omp/extensions/spawn-guard.ts.
# Отказ (rc 1) = «предмет отсутствует».
z104_guard() {
  local root="${Z104_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  if [ -n "${Z104_SPAWN_GUARD:-}" ] && [ -f "$Z104_SPAWN_GUARD" ]; then
    printf '%s' "$Z104_SPAWN_GUARD"; return 0
  fi
  if [ -f "$root/.omp/extensions/spawn-guard.ts" ]; then printf '%s' "$root/.omp/extensions/spawn-guard.ts"; return 0; fi
  return 1
}

# z104_cfg_ustanovka <файл> — config/agent_models.json УСТАНОВЛЕННОГО харнеса toy-мира:
# живая грамматика (models/tiers{model,fallback}/roles), девять ролей живого конфига;
# scout в конфиг НЕ пишем (харнесный тип несёт сам предмет).
z104_cfg_ustanovka() {
  cat > "$1" <<'JSON'
{"models":{"gpt-astra":"openai-codex/gpt-6-astra","gpt-terra":"openai-codex/gpt-5.6-terra","opus":"anthropic/claude-opus-5-5","gpt-sol":"openai-codex/gpt-6-sol","fable":"anthropic/claude-fable-5-1","glm":"zai/glm-5.3","sonnet":"anthropic/claude-sonnet-5","minimax-lightning":"minimax/MiniMax-M2.5-lightning","haiku":"anthropic/claude-haiku-4-5"},
"tiers":{"apex":{"model":"@gpt-astra","fallback":"@opus"},"advisor":{"model":"@gpt-terra","fallback":"@opus"},"audit":{"model":"@opus","fallback":"@gpt-sol"},"plan":{"model":"@opus","fallback":"@gpt-sol"},"slow":{"model":"@fable","fallback":"@opus"},"task":{"model":"@glm","fallback":"@sonnet"},"default":{"model":"@sonnet","fallback":"@glm"},"steward":{"model":"@haiku","fallback":null},"consultant":{"model":"@gpt-astra","fallback":"@opus"}},
"roles":{"orchestrator":"default","architect":"slow","implementer":"task","adversary":"advisor","critic":"apex","reviewer":"audit","arbiter":"plan","steward":"steward","consultant":"consultant"}}
JSON
}

# z104_cfg_proekt <файл> — config/agent_models.json cwd ПРОЕКТА (чужой, подменённый):
# роль «evil» на дешёвой модели, судьи reviewer/critic на модели автора, ролей
# architect/adversary/arbiter/implementer НЕТ — различим от установочного на любом из них.
z104_cfg_proekt() {
  cat > "$1" <<'JSON'
{"models":{"glm":"zai/glm-5.3"},"tiers":{"cheap":{"model":"@glm","fallback":null}},"roles":{"evil":"cheap","reviewer":"cheap","critic":"cheap","orchestrator":"cheap"}}
JSON
}

# z104_ustanovka <мир> <файл-хука> [без-конфига] — toy-УСТАНОВКА харнеса:
# <мир>/inst/.omp/extensions/spawn-guard.ts (копия субъекта) + <мир>/inst/config/agent_models.json
# (установочный конфиг; третий аргумент «1» — конфиг НЕ кладётся, вход И-5).
# Печатает путь установленного хука.
z104_ustanovka() {
  local w="$1" src="$2" nocfg="${3:-0}"
  mkdir -p "$w/inst/.omp/extensions" "$w/inst/config"
  cp "$src" "$w/inst/.omp/extensions/spawn-guard.ts"
  [ "$nocfg" = "1" ] || z104_cfg_ustanovka "$w/inst/config/agent_models.json"
  printf '%s' "$w/inst/.omp/extensions/spawn-guard.ts"
}

# z104_fab_driver <файл> — драйвер фабрики хука: import субъекта, синтетический pi
# собирает обработчики, события — из cases.json; cwd драйвера = каталог ПРОЕКТА
# (argv[4]); HARNESS_* и прочие подсказки корня в окружении драйвера СТЁРТЫ, затем
# — если дан argv[5] — выставлен ЛОЖНЫЙ HARNESS_TOOLS_ROOT=<argv[5]> (чужой корень:
# проект со своим конфигом либо каталог без конфига). Предмет обязан найти установку
# САМ (по своему расположению), не по cwd и не по env — ни как источник, ни как фолбэк.
z104_fab_driver() {
  cat > "$1" <<'MJS'
import { pathToFileURL } from 'node:url';
import { readFileSync } from 'node:fs';
const [guard, casesFile, cwd, envRoot] = process.argv.slice(2);
for (const k of Object.keys(process.env)) { if (k.startsWith('HARNESS_')) delete process.env[k]; }
if (envRoot !== undefined) process.env.HARNESS_TOOLS_ROOT = envRoot;
process.chdir(cwd);
const mod = await import(pathToFileURL(guard).href);
const reg = typeof mod.register === 'function' ? mod.register
  : (typeof mod.default === 'function' ? mod.default : null);
if (reg === null) { console.error('НЕТ register'); process.exit(2); }
const handlers = [];
const pi = { on: (_name, handler) => { handlers.push(handler); } };
reg(pi);
if (handlers.length < 1) { console.error('НЕТ обработчика'); process.exit(2); }
const handler = handlers[handlers.length - 1];
const cases = JSON.parse(readFileSync(casesFile, 'utf8'));
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
}

# z104_ev <имя> <want> <input-json> — одна строка cases.json (без запятой).
z104_ev() { printf '{"name":"%s","want":"%s","event":{"type":"tool_call","toolName":"task","toolCallId":"%s","input":%s}}' "$1" "$2" "$1" "$3"; }
