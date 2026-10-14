#!/usr/bin/env bash
# Обманный стаб-пак 104 (контракт 104, Н-39/А-398): тринадцать обманных субъектов,
# каждый привязан к клетке и входу, на котором его дефект НАБЛЮДАЕМ (привязка
# живёт В ЭТОМ КОДЕ, не в прозе контракта).
# Пойман = связанная клетка против стаба даёт rc 1 (КРАСНО); rc 0 и rc 2 — НЕ пойман.
#
# # стаб   | дефект обмана                                        | ловящая клетка и вход
# t104-m1  хук: всегда undefined (не судит)                       red_huk_task_spavna (вход 1)
# t104-m2  хук: "task" В алфавите                                 red_huk_task_spavna (вход 1)
# t104-m3  хук: batch-элементы не судятся                         red_huk_task_spavna (вход 4)
# t104-m4  хук: битый input → undefined (fail-closed нет)         red_huk_task_spavna (вход 8)
# t104-m5  хук: алфавит из process.cwd()/config (дыра 099)        red_huk_alfavit_ustanovki (вход 1: evil прошёл)
# t104-m6  хук: нет установочного конфига → берёт cwd (bootstrap) red_huk_bez_ustanovochnogo_konfiga (вход 1)
# t104-m7  дверь судьи всегда rc 0                                red_sud_model_dver_spavna (вход 1)
# t104-m8  --verdict не сверяет session-id                        red_sud_model_materializatsija (вход 5)
# t104-m9  --verdict не сверяет объект                            red_sud_model_materializatsija (вход 4)
# t104-m10 --verdict: любой denied-фолбэк принят                  red_sud_model_materializatsija (вход 7)
# t104-m11 judge_gate: без --sud пишет строку (bootstrap-пропуск) red_judge_gate_svidetelstvo_sudi (вход 1)
# t104-m12 хук: корень — HARNESS_TOOLS_ROOT прежде расположения   red_huk_alfavit_ustanovki (условие б, вход 1: evil прошёл)
# t104-m13 хук: нет установочного конфига → фолбэк на HARNESS_TOOLS_ROOT red_huk_bez_ustanovochnogo_konfiga (условие б, вход 1)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAM="$HERE"
Z104_BASE="${Z104_BASE:-/tmp/dev-harness-verify}"
command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }

WORK="$Z104_BASE/zashchita-104-stubs-$$-${RANDOM}"
mkdir -p "$WORK" || { printf 'ОТКАЗ: мир стабов не строится\n' >&2; exit 2; }
# Z104_STUBS_KEEP=1 — мир стабов не вычищается (осмотр адверсарием: какой вход убил стаб).
if [ "${Z104_STUBS_KEEP:-0}" = 1 ]; then printf 'мир стабов: %s\n' "$WORK" >&2; else trap 'rm -rf "$WORK"' EXIT; fi
for m in 1 2 3 4 5 6 7 8 9 10 11 12 13; do mkdir -p "$WORK/t104-m$m"; done

# ── честный каркас хука 104 (источник алфавита — расположение САМОГО расширения,
# <ext>/../../config/agent_models.json; cwd/env не читаются). Каждый стаб — этот
# каркас с ОДНОЙ помеченной «ПОРЧА» мутацией, чтобы дефект был наблюдаем только на
# своём входе (Н-39). Маркеры: __ALPHA_SRC__ __TASK_BRANCH__ __BATCH__ __CATCH__ __NOCFG__
HOOK_TPL='import { readFileSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
const HERE = dirname(fileURLToPath(import.meta.url));
const HARNESS_TYPES = ["scout"];
const NO_AGENT = "ОТКАЗ: спавн без явного agent";
const OUT_OF_ALPHABET = "ОТКАЗ: тип агента вне алфавита";
const NOCFG = "ОТКАЗ: конфиг установленного харнеса не читается";
const BROKEN = "ОТКАЗ: спавн-страж сломан (fail-closed, Н-270)";
function isObject(v) { return typeof v === "object" && v !== null && !Array.isArray(v); }
function cfgPath() {
  const inst = join(HERE, "..", "..", "config", "agent_models.json"); // __ALPHA_SRC__
  if (!existsSync(inst)) { __NOCFG__ }
  return inst;
}
function loadAlphabet() {
  const cfg = JSON.parse(readFileSync(cfgPath(), "utf8"));
  if (!isObject(cfg) || !isObject(cfg.roles)) throw new Error("нет roles");
  const set = new Set(Object.keys(cfg.roles));
  for (const t of HARNESS_TYPES) set.add(t);
  set.delete("task"); // __TASK_BRANCH__
  return set;
}
function judge(input, alphabet) {
  let items;
  if (isObject(input) && "tasks" in input) {
    if (!Array.isArray(input.tasks)) throw new Error("tasks не массив");
    items = input.tasks; // __BATCH__
  } else { items = [input]; }
  for (const item of items) {
    if (!isObject(item)) throw new Error("битый элемент");
    const agent = item.agent;
    if (agent === undefined) return { block: true, reason: `${NO_AGENT}: task` };
    if (typeof agent !== "string") throw new Error("agent не строка");
    if (agent === "task") return { block: true, reason: `${NO_AGENT}: ${agent}` };
    if (!alphabet.has(agent)) return { block: true, reason: `${OUT_OF_ALPHABET}: ${agent}` };
  }
  return undefined;
}
export default function register(pi) {
  if (!isObject(pi) || typeof pi.on !== "function") return;
  pi.on("tool_call", (call) => {
    try {
      if (!isObject(call)) return undefined;
      if (call.toolName !== "task") return undefined;
      return judge(call.input, loadAlphabet());
    } catch (e) {
      if (e && e.nocfg) return { block: true, reason: NOCFG };
      return { block: true, reason: BROKEN }; // __CATCH__
    }
  });
}'
NOCFG_HONEST='const e = new Error(NOCFG); e.nocfg = true; throw e;'
hook() { # <стаб> <sed-выражение>
  printf '%s\n' "$HOOK_TPL" | sed -e "s|__NOCFG__|$NOCFG_HONEST|" -e "$2" -e 's| // __[A-Z_]*__$||' > "$WORK/$1/spawn-guard.ts"
}
# t104-m1: обработчик ничего не судит
printf 'export default function register(pi){ if(pi&&typeof pi.on==="function") pi.on("tool_call",()=>undefined); }\n' > "$WORK/t104-m1/spawn-guard.ts"
# t104-m2: ПОРЧА — task остаётся в алфавите и ветки явного отказа нет
hook t104-m2 's|set.delete("task"); // __TASK_BRANCH__|set.add("task");|; s|if (agent === "task") return.*$||'
# t104-m3: ПОРЧА — batch не судится
hook t104-m3 's|items = input.tasks; // __BATCH__|return undefined;|'
# t104-m4: ПОРЧА — fail-closed нет
hook t104-m4 's|return { block: true, reason: BROKEN }; // __CATCH__|return undefined;|'
# t104-m5: ПОРЧА — алфавит из cwd проекта (источник 099)
hook t104-m5 's|const inst = join(HERE, "..", "..", "config", "agent_models.json"); // __ALPHA_SRC__|const inst = join(process.cwd(), "config", "agent_models.json");|'
# t104-m6: ПОРЧА — установочного конфига нет → bootstrap: берём cwd проекта
printf '%s\n' "$HOOK_TPL" | sed -e 's|if (!existsSync(inst)) { __NOCFG__ }|if (!existsSync(inst)) return join(process.cwd(), "config", "agent_models.json");|' -e 's| // __[A-Z_]*__$||' > "$WORK/t104-m6/spawn-guard.ts"
# t104-m12: ПОРЧА — корень из окружения прежде расположения расширения
hook t104-m12 's|const inst = join(HERE, "..", "..", "config", "agent_models.json"); // __ALPHA_SRC__|const inst = join(process.env.HARNESS_TOOLS_ROOT \|\| join(HERE, "..", ".."), "config", "agent_models.json");|'
# t104-m13: ПОРЧА — установочного конфига нет → фолбэк на корень из окружения
printf '%s\n' "$HOOK_TPL" | sed -e 's|if (!existsSync(inst)) { __NOCFG__ }|if (!existsSync(inst)) { if (process.env.HARNESS_TOOLS_ROOT) return join(process.env.HARNESS_TOOLS_ROOT, "config", "agent_models.json"); const e = new Error(NOCFG); e.nocfg = true; throw e; }|' -e 's| // __[A-Z_]*__$||' > "$WORK/t104-m13/spawn-guard.ts"
for m in 2 3 4 5 6 12 13; do
  grep -q '__' "$WORK/t104-m$m/spawn-guard.ts" && { printf 'ОТКАЗ: стаб t104-m%s: маркер не заменён\n' "$m" >&2; exit 2; }
done

# ── дверь судьи ──
cat > "$WORK/t104-m7/check_sud_model.sh" <<'EOF'
#!/usr/bin/env bash
# t104-m7 порча: дверь судьи всегда зелёная (rc 0 на любом вызове)
printf 'СУДЬЯ СВОЕЙ МОДЕЛИ: ok\n'
exit 0
EOF

# Честный каркас ноги --verdict 104 (5 полей: роль модель allowed|denied session object);
# стабы m8/m9/m10 — одна помеченная ПОРЧА каждая. Прочие ноги (--spawn/--frontmatter)
# стабу не нужны: ловящая клетка зовёт только --verdict.
VERDICT_TPL='#!/usr/bin/env bash
set -uo pipefail
mode=""; role=""; trace=""; object=""; session=""; root=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --verdict) mode=verdict; role="${2:-}"; shift 2 ;;
    --trace) trace="${2:-}"; shift 2 ;;
    --object) object="${2:-}"; shift 2 ;;
    --session) session="${2:-}"; shift 2 ;;
    --root) root="${2:-}"; shift 2 ;;
    *) shift ;;
  esac
done
[ "$mode" = verdict ] || exit 2
[ -n "$object" ] && [ -n "$session" ] || { printf "использование: --object и --session обязательны\n" >&2; exit 2; }
CFG="$root/config/agent_models.json"; [ -f "$CFG" ] || exit 2
tier="$(jq -r --arg r "$role" ".roles[\$r] // \"\"" "$CFG")"; [ -n "$tier" ] || exit 2
fam="$(jq -r --arg t "$tier" ".tiers[\$t].model // \"\"" "$CFG")"; fam="${fam#@}"
expected="$(jq -r --arg f "$fam" ".models[\$f] // \"\"" "$CFG")"; [ -n "$expected" ] || exit 2
fbfam="$(jq -r --arg t "$tier" ".tiers[\$t].fallback // \"\"" "$CFG")"; fbfam="${fbfam#@}"
fbexp=""; [ -n "$fbfam" ] && fbexp="$(jq -r --arg f "$fbfam" ".models[\$f] // \"\"" "$CFG")"
[ -f "$trace" ] || exit 2
lines="$(awk -F"\t" -v r="$role" "\$1 == r" "$trace")"
[ -n "$lines" ] || { printf "ОТКАЗ: трасса без строки роли: %s\n" "$role" >&2; exit 1; }
while IFS=$'"'"'\t'"'"' read -r r m fb s o; do
  [ -n "$r" ] || continue
  [ -n "$s" ] && [ -n "$o" ] || { printf "ОТКАЗ: трасса без привязки (нужно 5 полей)\n" >&2; exit 2; }
  [ "$s" = "$session" ] || { printf "ОТКАЗ: чужая трасса: сессия %s, суд %s\n" "$s" "$session" >&2; exit 1; } # __SESSION__
  [ "$o" = "$object" ] || { printf "ОТКАЗ: трасса не об объекте суда: %s, суд %s\n" "$o" "$object" >&2; exit 1; } # __OBJECT__
  case "$fb" in
    allowed) [ "$m" = "$expected" ] || { printf "ОТКАЗ: вердикт не материализуется: судья %s на модели %s, тир %s (Н-270)\n" "$role" "$m" "$tier" >&2; exit 1; } ;;
    denied) [ -n "$fbexp" ] && [ "$m" = "$fbexp" ] || { printf "ОТКАЗ: фолбэк вне списка тира: %s на %s, тир %s (Н-270)\n" "$role" "$m" "$tier" >&2; exit 1; } ;; # __FALLBACK__
    *) exit 2 ;;
  esac
done <<< "$lines"
printf "СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт %s материализуется\n" "$role"
exit 0'
verdict_stub() { printf '%s\n' "$VERDICT_TPL" | sed -e "$2" -e 's| # __[A-Z_]*__$||' > "$WORK/$1/check_sud_model.sh"; }
verdict_stub t104-m8  's|^  \[ "\$s" = "\$session" \].*# __SESSION__$|  : # ПОРЧА: сессия не сверяется|'
verdict_stub t104-m9  's|^  \[ "\$o" = "\$object" \].*# __OBJECT__$|  : # ПОРЧА: объект не сверяется|'
verdict_stub t104-m10 's|^    denied) .*# __FALLBACK__$|    denied) : ;; # ПОРЧА: любой фолбэк принят|'
for m in 8 9 10; do
  grep -q '__' "$WORK/t104-m$m/check_sud_model.sh" && { printf 'ОТКАЗ: стаб t104-m%s: маркер не заменён\n' "$m" >&2; exit 2; }
done

# ── judge_gate: без --sud пишет строку (bootstrap-пропуск) ──
cat > "$WORK/t104-m11/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# t104-m11 порча: --verdict-row пишет строку, тройку --sud считает необязательной
set -uo pipefail
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
J="$SELF/../registry/candidates.tsv"
[ "${2:-}" = --verdict-row ] || exit 1
if [ "${6:-}" = --sud ]; then
  "$SELF/check_sud_model.sh" --verdict "$7" --trace "$8" --object "$1" --session "$9" || exit $?
fi
printf 'verdict\t%s\t%s\taccept\t1\n' "$3" "$4" >> "$J"
exit 0
EOF
chmod +x "$WORK"/t104-m*/*.sh 2>/dev/null

# прогон: стаб пойман ⟺ связанная клетка на стабе даёт rc 1
itog=0; caught=0; total=0
progon() { # <маркер> <клетка>
  local marker="$1" cell="$2" rc
  [ -d "$WORK/$marker" ] || { printf 'ОТКАЗ: стаб %s не построен\n' "$marker" >&2; itog=2; return; }
  [ -f "$FAM/$cell" ] || { printf 'ОТКАЗ: клетка %s не найдена\n' "$cell" >&2; itog=2; return; }
  total=$((total+1))
  D104_SUBJECTS_DIR="$WORK/$marker" Z104_SPAWN_GUARD="$WORK/$marker/spawn-guard.ts" \
    bash "$FAM/$cell" >/dev/null 2>&1
  rc=$?
  if [ "$rc" -eq 1 ]; then
    caught=$((caught+1)); printf -- '— %s пойман (%s)\n' "$marker" "$cell" >&2
  else
    printf '— %s НЕ ПОЙМАН (rc=%s, клетка %s) — дефект жив\n' "$marker" "$rc" "$cell" >&2
    itog=1
  fi
}

# Н-39: каждый стаб — к входу, где его дефект наблюдаем (таблица в шапке)
progon t104-m1  red_huk_task_spavna.sh
progon t104-m2  red_huk_task_spavna.sh
progon t104-m3  red_huk_task_spavna.sh
progon t104-m4  red_huk_task_spavna.sh
progon t104-m5  red_huk_alfavit_ustanovki.sh
progon t104-m6  red_huk_bez_ustanovochnogo_konfiga.sh
progon t104-m7  red_sud_model_dver_spavna.sh
progon t104-m8  red_sud_model_materializatsija.sh
progon t104-m9  red_sud_model_materializatsija.sh
progon t104-m10 red_sud_model_materializatsija.sh
progon t104-m11 red_judge_gate_svidetelstvo_sudi.sh
progon t104-m12 red_huk_alfavit_ustanovki.sh
progon t104-m13 red_huk_bez_ustanovochnogo_konfiga.sh

printf 'стаб-пак: %s/%s поймано\n' "$caught" "$total"
[ "$total" -eq 13 ] || { printf 'ОТКАЗ: стабов прогнано %s, ожидалось 13\n' "$total" >&2; exit 2; }
[ "$itog" -eq 0 ] || exit "$itog"
exit 0
