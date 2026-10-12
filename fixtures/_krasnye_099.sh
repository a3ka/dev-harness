#!/usr/bin/env bash
# Раннер красной пачки 099 «защищённый переходный маршрут в main + Н-270» —
# агрегатор семьи fixtures/zashchita_main_099/ (guard, ПРОВОДКА контракта 099).
#
# Использование:
#   bash fixtures/_krasnye_099.sh [корень]
#
# Семантика (контракт 099 §Приёмка): rc 0 ⟺ стаб-пак battery_stubs.sh rc 0 И
# каждая клетка семьи rc 0 (замер контракта: клеток ровно 10, из них
# red_no_leak_proizvolnyj_retake — регрессионная, зелёна на текущем дереве
# по построению); rc 1 — есть красная клетка (в том числе «предмет отсутствует»
# на дереве ДО реализации); rc 2 — нечем проверять (нет семьи/git/python3/curl).
# Guard подключается в CI ТОЛЬКО ПОСЛЕ landing предмета (прецедент 074/093/098).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$(cd "$HERE/.." && pwd)}"
FAM="$HERE/zashchita_main_099"
[ -d "$FAM" ] || { printf 'NOT_IMPLEMENTED: нет семьи %s\n' "$FAM" >&2; exit 2; }
[ -f "$FAM/_mir.sh" ] || { printf 'NOT_IMPLEMENTED: нет каркаса %s/_mir.sh\n' "$FAM" >&2; exit 2; }
command -v git      >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
command -v python3  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }
command -v curl     >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет curl\n' >&2; exit 2; }
command -v sha256sum >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет sha256sum\n' >&2; exit 2; }

# Замер контракта §Приёмка: клеток ровно 9 (обход печатает число просмотренного
# и отказывает на расхождении — пустая выборка красна).
n="$(ls "$FAM"/red_*.sh 2>/dev/null | wc -l)"
if [ "$n" -ne 10 ]; then
  printf 'ОТКАЗ: клеток семьи %s, ожидалось 10 по замеру контракта 099\n' "$n" >&2
  exit 2
fi

# Субъекты реализации (land_agent.sh существует; отсутствие его --pr-режима
# несёт сама клетка red_land_agent_pr_rezhim)
SUBJMISS=0
for f in pr_dopusk.sh check_sud_model.sh; do
  [ -f "$ROOT/scripts/$f" ] || SUBJMISS=1
done

itog=0
progon() {  # <файл семьи>
  local f="$1" rc
  [ -f "$FAM/$f" ] || { printf 'NOT_IMPLEMENTED: нет %s\n' "$FAM/$f" >&2; itog=2; return; }
  bash "$FAM/$f"; rc=$?
  printf -- '— %s: rc=%s\n' "$f" "$rc"
  if [ "$rc" -eq 1 ]; then itog=1; elif [ "$rc" -ne 0 ] && [ "$itog" -eq 0 ]; then itog=2; fi
}

progon battery_stubs.sh
for c in $(ls "$FAM"/red_*.sh | LC_ALL=C sort); do
  progon "$(basename "$c")"
done

if [ "${SUBJMISS:-0}" = "1" ]; then
  printf 'красная: предмет отсутствует (субъекты scripts/pr_dopusk.sh, scripts/check_sud_model.sh; корень %s)\n' "$ROOT"
fi
printf 'ИТОГ 099: rc=%s\n' "$itog"
exit "$itog"
