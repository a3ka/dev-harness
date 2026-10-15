#!/usr/bin/env bash
# Раннер красной пачки 104 «узкий доверенный гейт судьи для внешнего проекта» —
# агрегатор семьи fixtures/zashchita_main_104/ (guard, ПРОВОДКА контракта 104).
#
# Использование:
#   bash fixtures/_krasnye_104.sh [корень]
#
# Семантика (контракт 104 §Приёмка): rc 0 ⟺ стаб-пак battery_stubs.sh rc 0 И
# каждая клетка семьи rc 0 (замер контракта: клеток ровно 6); rc 1 — есть
# красная клетка (в том числе «предмет отсутствует» на дереве ДО реализации);
# rc 2 — нечем проверять (нет семьи/node/jq). Guard подключается в CI ТОЛЬКО
# ПОСЛЕ landing предмета (прецедент 074/093/098).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$(cd "$HERE/.." && pwd)}"
FAM="$HERE/zashchita_main_104"
[ -d "$FAM" ] || { printf 'NOT_IMPLEMENTED: нет семьи %s\n' "$FAM" >&2; exit 2; }
[ -f "$FAM/_mir.sh" ] || { printf 'NOT_IMPLEMENTED: нет каркаса %s/_mir.sh\n' "$FAM" >&2; exit 2; }
command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }
command -v jq   >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }
export Z104_ROOT="$ROOT"

# Замер контракта §Приёмка: клеток ровно 6 (обход печатает число просмотренного
# и отказывает на расхождении — пустая выборка красна).
n="$(ls "$FAM"/red_*.sh 2>/dev/null | wc -l)"
if [ "$n" -ne 6 ]; then
  printf 'ОТКАЗ: клеток семьи %s, ожидалось 6 по замеру контракта 104\n' "$n" >&2
  exit 2
fi

SUBJMISS=0
[ -f "$ROOT/scripts/check_sud_model.sh" ] || SUBJMISS=1
[ -f "$ROOT/.omp/extensions/spawn-guard.ts" ] || SUBJMISS=1

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

if [ "$SUBJMISS" = "1" ]; then
  printf 'красная: предмет отсутствует (субъекты scripts/check_sud_model.sh, .omp/extensions/spawn-guard.ts; корень %s)\n' "$ROOT"
fi
printf 'клеток просмотрено: %s\n' "$n"
printf 'ИТОГ 104: rc=%s\n' "$itog"
exit "$itog"
