#!/usr/bin/env bash
# Раннер красной пачки 096 «завершение задачи харнеса и проекта — общее ядро
# использует доказательство контракта 3; проектные условия берёт из профиля»
# (круг 1) — агрегатор семьи fixtures/done_task_096/ (guard, ПРОВОДКА
# контракта 096).
#
# Использование:
#   bash fixtures/_krasnye_096.sh [корень]         # субъект scripts/done_project.sh
#   bash fixtures/_krasnye_096.sh --model [корень] # субъект fixtures/done_task_096/model/dover.sh
#
# Семантика (контракт 096 §Приёмка): rc 0 ⟺ стаб-пак battery_stubs.sh rc 0 И
# каждая клетка семьи rc 0 (замер контракта: клеток ровно 15); rc 1 — есть
# красная клетка (в том числе «предмет отсутствует» на дереве ДО реализации —
# вывод несёт строку «красная: предмет отсутствует»); rc 2 — нечем проверять
# (нет семьи/модели/раннера клетки, git). Guard подключается в CI ТОЛЬКО
# ПОСЛЕ landing предмета (прецедент 074/093/094/095 §ПРОВОДКА-ЭНФОРСМЕНТ):
# преждевременная строка держала бы CI красным до реализации.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="real"
case "${1:-}" in
  --model) MODE="model"; shift ;;
esac
ROOT="${1:-$(cd "$HERE/.." && pwd)}"
FAM="$HERE/done_task_096"
[ -d "$FAM" ] || { printf 'NOT_IMPLEMENTED: нет семьи %s\n' "$FAM" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

# Замер контракта §Приёмка: клеток ровно 15 (обход печатает число
# просмотренного и отказывает на расхождении — пустая выборка красна).
n="$(ls "$FAM"/red_*.sh 2>/dev/null | wc -l)"
if [ "$n" -ne 15 ]; then
  printf 'ОТКАЗ: клеток семьи %s, ожидалось 15 по замеру контракта 096\n' "$n" >&2
  exit 2
fi

SUBJ="$ROOT/scripts/done_project.sh"
[ "$MODE" = "model" ] && SUBJ="$FAM/model/dover.sh"
[ -f "$SUBJ" ] || SUBJ_MISSING=1 || SUBJ_MISSING=0
export DT096_ROOT="$ROOT"
export DT096_SUBJECT="$SUBJ"

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

if [ "${SUBJ_MISSING:-0}" = "1" ] && [ "$MODE" = "real" ]; then
  printf 'красная: предмет отсутствует (субъект scripts/done_project.sh, корень %s)\n' "$ROOT"
fi
printf 'ИТОГ 096: rc=%s\n' "$itog"
exit "$itog"
