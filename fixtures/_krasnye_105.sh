#!/usr/bin/env bash
# Раннер красной пачки 105 «лаунчер передаёт политику установки в сессию
# проекта» — агрегатор клеток red_*_105.sh семьи fixtures/workshop_project/
# (probe-only 034; guard, ПРОВОДКА контракта 105).
#
# Использование:
#   bash fixtures/_krasnye_105.sh [корень]         # субъект <корень>/workshop
#   bash fixtures/_krasnye_105.sh --model [корень] # субъект fixtures/workshop_project/model_105/workshop.sh
#
# Семантика (контракт 105 §Приёмка): rc 0 ⟺ стаб-пак battery_stubs_105.sh rc 0
# И каждая из клеток rc 0 (замер контракта: клеток ровно 5 — по одной на
# И-1..И-5); rc 1 — есть красная клетка (на дереве ДО реализации — все пять:
# предмет отсутствует, вывод несёт «105 И-N КРАСНО: …»); rc 2 — нечем
# проверять (нет семьи/модели/клетки/git/jq/node). Guard подключается в CI
# ТОЛЬКО ПОСЛЕ landing предмета (прецедент 074/093/098/104): преждевременная
# строка держала бы CI красным до реализации.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="real"
case "${1:-}" in
  --model) MODE="model"; shift ;;
esac
ROOT="${1:-$(cd "$HERE/.." && pwd)}"
ROOT="$(cd "$ROOT" 2>/dev/null && pwd)" || { printf 'NOT_IMPLEMENTED: корень не открывается: %s\n' "${1:-}" >&2; exit 2; }
FAM="$HERE/workshop_project"
[ -d "$FAM" ] || { printf 'NOT_IMPLEMENTED: нет семьи %s\n' "$FAM" >&2; exit 2; }
[ -f "$FAM/_mir_105.sh" ] || { printf 'NOT_IMPLEMENTED: нет каркаса %s/_mir_105.sh\n' "$FAM" >&2; exit 2; }
[ -f "$FAM/model_105/workshop.sh" ] || { printf 'NOT_IMPLEMENTED: нет модели %s/model_105/workshop.sh\n' "$FAM" >&2; exit 2; }
for t in git jq node sha256sum; do
  command -v "$t" >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет %s\n' "$t" >&2; exit 2; }
done

# Замер контракта §Приёмка: клеток ровно 5 (обход печатает число просмотренного
# и отказывает на расхождении — пустая выборка красна).
n="$(ls "$FAM"/red_*_105.sh 2>/dev/null | wc -l)"
if [ "$n" -ne 5 ]; then
  printf 'ОТКАЗ: клеток семьи %s, ожидалось 5 по замеру контракта 105\n' "$n" >&2
  exit 2
fi

SUBJ="$ROOT/workshop"
[ "$MODE" = "model" ] && SUBJ="$FAM/model_105/workshop.sh"
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ" >&2; exit 2; }
export W105_ROOT="$ROOT"
export W105_SUBJECT="$SUBJ"

itog=0
progon() {  # <файл семьи>
  local f="$1" rc
  bash "$FAM/$f"; rc=$?
  printf -- '— %s: rc=%s\n' "$f" "$rc"
  if [ "$rc" -eq 1 ]; then itog=1; elif [ "$rc" -ne 0 ] && [ "$itog" -eq 0 ]; then itog=2; fi
}

progon battery_stubs_105.sh
for c in $(ls "$FAM"/red_*_105.sh | LC_ALL=C sort); do
  progon "$(basename "$c")"
done

printf 'клеток просмотрено: %s; субъект: %s\n' "$n" "$SUBJ"
printf 'ИТОГ 105: rc=%s\n' "$itog"
exit "$itog"
