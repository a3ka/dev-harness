#!/usr/bin/env bash
# Раннер красной пачки 097 «доверенная основа и подготовка объекта» (контракт
# 097, часть А нарезки 094) — агрегатор семьи fixtures/prepare_object_097/
# (guard, ПРОВОДКА контракта 097).
#
# Использование:
#   bash fixtures/_krasnye_097.sh [корень]         # субъект scripts/accept_publish.sh
#   bash fixtures/_krasnye_097.sh --model [корень] # субъект fixtures/accept_publish_094/model/dover.sh
#
# Семантика (§Приёмка контракта 097): rc 0 ⟺ стаб-пак battery_stubs.sh rc 0 И
# каждая клетка семьи rc 0 (замер контракта: клеток ровно 8 — А-1…А-8); rc 1 —
# есть красная клетка (в том числе «предмет отсутствует» на дереве ДО
# реализации — вывод несёт строку «красная: предмет отсутствует»); rc 2 —
# нечем проверять (нет семьи/модели/раннера клетки, git). Guard подключается
# в CI ТОЛЬКО ПОСЛЕ landing предмета (прецедент 074/093 §ПРОВОДКА-ЭНФОРСМЕНТ).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="real"
case "${1:-}" in
  --model) MODE="model"; shift ;;
esac
ROOT="${1:-$(cd "$HERE/.." && pwd)}"
FAM="$HERE/prepare_object_097"
[ -d "$FAM" ] || { printf 'NOT_IMPLEMENTED: нет семьи %s\n' "$FAM" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

# Замер контракта §Приёмка: клеток ровно 8 (А-1…А-8; обход печатает число
# просмотренного и отказывает на расхождении — пустая выборка красна).
n="$(ls "$FAM"/red_*.sh 2>/dev/null | wc -l)"
if [ "$n" -ne 8 ]; then
  printf 'ОТКАЗ: клеток семьи %s, ожидалось 8 по замеру контракта 097\n' "$n" >&2
  exit 2
fi

SUBJ="$ROOT/scripts/accept_publish.sh"
if [ "$MODE" = "model" ]; then
  SUBJ="$HERE/accept_publish_094/model/dover.sh"
  [ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет модели %s\n' "$SUBJ" >&2; exit 2; }
fi
[ -f "$SUBJ" ] || SUBJ_MISSING=1 || SUBJ_MISSING=0
export AP097_ROOT="$ROOT"
export AP097_SUBJECT="$SUBJ"
export AP097_MODE="$MODE"

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
  printf 'красная: предмет отсутствует (субъект scripts/accept_publish.sh, корень %s)\n' "$ROOT"
fi
printf 'ИТОГ 097: rc=%s\n' "$itog"
exit "$itog"
