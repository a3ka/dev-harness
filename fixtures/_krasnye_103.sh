#!/usr/bin/env bash
# Раннер красной пачки 103 «профильные пути вместо harness-layout + стандарт
# проекта v1» — агрегатор семьи fixtures/project_paths_103/ (guard, ПРОВОДКА
# контракта 103).
#
# Использование:
#   bash fixtures/_krasnye_103.sh [корень]         # субъекты scripts/{make_task,pre_critic,spawn_agent,check_project_standard}.sh
#   bash fixtures/_krasnye_103.sh --model [корень] # субъекты — честные модели fixtures/project_paths_103/model/
#
# Семантика (контракт 103 §Приёмка): rc 0 ⟺ стаб-пак battery_stubs.sh rc 0 И
# каждая клетка семьи rc 0 (замер контракта: клеток ровно 11); rc 1 — есть
# красная клетка (до реализации — «предмет отсутствует»); rc 2 — нечем
# проверять. Guard подключается в CI ТОЛЬКО ПОСЛЕ landing предмета
# (прецедент 074/093/094/095).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="real"
case "${1:-}" in --model) MODE="model"; shift ;; esac
ROOT="${1:-$(cd "$HERE/.." && pwd)}"
FAM="$HERE/project_paths_103"
[ -d "$FAM" ] || { printf 'NOT_IMPLEMENTED: нет семьи %s\n' "$FAM" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v jq  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }

n="$(ls "$FAM"/red_*.sh 2>/dev/null | wc -l)"
if [ "$n" -ne 11 ]; then
  printf 'ОТКАЗ: клеток семьи %s, ожидалось 11 по замеру контракта 103\n' "$n" >&2; exit 2
fi

export PP103_ROOT="$ROOT"
if [ "$MODE" = "model" ]; then
  export PP103_MAKE_TASK="$FAM/model/kontrakt_po_profilju.sh"
  export PP103_PRE_CRITIC="$FAM/model/pre_critic_proekta.sh"
  export PP103_SPAWN="$FAM/model/dver_reestra.sh"
  export PP103_STANDARD="$FAM/model/check_project_standard.sh"
else
  export PP103_MAKE_TASK="$ROOT/scripts/make_task.sh"
  export PP103_PRE_CRITIC="$ROOT/scripts/pre_critic.sh"
  export PP103_SPAWN="$ROOT/scripts/spawn_agent.sh"
  export PP103_STANDARD="$ROOT/scripts/check_project_standard.sh"
fi
missing=""
for s in "$PP103_MAKE_TASK" "$PP103_PRE_CRITIC" "$PP103_SPAWN" "$PP103_STANDARD"; do
  [ -f "$s" ] || missing="$missing ${s#$ROOT/}"
done

itog=0
progon() {
  local f="$1" rc
  [ -f "$FAM/$f" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$FAM/$f" >&2; itog=2; return; }
  bash "$FAM/$f"; rc=$?
  printf -- '— %s: rc=%s\n' "$f" "$rc"
  if [ "$rc" -eq 1 ]; then itog=1; elif [ "$rc" -ne 0 ] && [ "$itog" -eq 0 ]; then itog=2; fi
}
progon battery_stubs.sh
for c in $(ls "$FAM"/red_*.sh | LC_ALL=C sort); do progon "$(basename "$c")"; done
[ -z "$missing" ] || printf 'красная: предмет отсутствует (%s, корень %s)\n' "$missing" "$ROOT"
printf 'ИТОГ 103: rc=%s\n' "$itog"
exit "$itog"
