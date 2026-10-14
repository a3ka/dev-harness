#!/usr/bin/env bash
# Клетка red_huk_bez_ustanovochnogo_konfiga — инвариант И-5 контракта 104:
# отсутствие config/agent_models.json в УСТАНОВКЕ — именованный отказ каждого
# task-спавна (fail-closed), НЕ bootstrap-пропуск и НЕ подхват проектного конфига.
# Мир: toy-установка <мир>/inst БЕЗ config/; cwd проекта <мир>/proj С валидным
# (установочной грамматики, девять ролей) config/agent_models.json — соблазн
# «взять из cwd» максимален. Входы:
#   (1) agent:"critic" → block «конфиг установленного харнеса не читается»;
#   (2) agent:"scout" (харнесный тип, конфиг не нужен) → block той же причиной —
#       без установочного конфига хук не судит НИЧЕГО;
#   (3) toolName:'write' → pass (чужие инструменты не трогаем).
# Один оракул, ДВА условия окружения драйвера (тот же cases.json):
#   (а) HARNESS_* стёрты;
#   (б) HARNESS_TOOLS_ROOT=<мир>/proj — ложный корень С валидным конфигом: env не
#       спасает установку без конфига (фолбэк на env — та же дыра, что bootstrap на cwd).
# Хук «нет установочного → берём cwd» падает на (а)(1); хук «нет установочного →
# берём env» падает на (б)(1): critic пропущен вместо отказа → КРАСНО.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z104_BASE/zashchita-104-nocfg-$$-${RANDOM}"
trap 'rm -rf "$W"' EXIT

if ! SRC="$(z104_guard)"; then
  printf 'КРАСНО: red_huk_bez_ustanovochnogo_konfiga: предмет отсутствует: .omp/extensions/spawn-guard.ts\n' >&2; exit 1
fi
command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }
mkdir -p "$W/proj/config"
z104_cfg_ustanovka "$W/proj/config/agent_models.json"
GUARD="$(z104_ustanovka "$W" "$SRC" 1)"
[ -f "$W/inst/config/agent_models.json" ] && { printf 'ОТКАЗ: мир построен с конфигом установки\n' >&2; exit 2; }
z104_fab_driver "$W/fab_driver.mjs"

# Оракул в памяти ДО вызова (правило 8)
P_NOCFG='ОТКАЗ: конфиг установленного харнеса не читается'
{
  printf '[\n'
  z104_ev 1-critic "$P_NOCFG" '{"context":"p","tasks":[{"name":"C","agent":"critic","task":"ok"}]}'; printf ',\n'
  z104_ev 2-scout "$P_NOCFG" '{"context":"p","tasks":[{"name":"S","agent":"scout","task":"ok"}]}'; printf ',\n'
  printf '{"name":"3-other-tool","want":"pass","event":{"type":"tool_call","toolName":"write","toolCallId":"c3","input":{"path":"x.txt","agent":"task"}}}\n]\n'
} > "$W/cases.json"

rc=0
node "$W/fab_driver.mjs" "$GUARD" "$W/cases.json" "$W/proj" || rc=1
node "$W/fab_driver.mjs" "$GUARD" "$W/cases.json" "$W/proj" "$W/proj" || rc=1
if [ "$rc" -eq 0 ]; then printf 'ЗЕЛЕНО: red_huk_bez_ustanovochnogo_konfiga\n'; exit 0; fi
printf 'КРАСНО: red_huk_bez_ustanovochnogo_konfiga: без установочного конфига спавн не отказан именованно (rc=%s)\n' "$rc" >&2
exit 1
