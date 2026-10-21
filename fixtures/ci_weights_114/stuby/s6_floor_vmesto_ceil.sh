#!/usr/bin/env bash
# Обманный стаб s6 (floor_vmesto_ceil, measure): округление медианы ВНИЗ —
# вес систематически меньше замера, timeout-бюджеты тихо съедаются.
# Точка лжи — ST114_LIE=s6 каркаса _karkas_staba.py. Привязка к клетке —
# KARTA red_114.sh (по коду, Н-39). Честность вне лжи не наблюдаема по
# классу: floor ≠ ceil на любом нечётно-медианном корпусе (оговорка в KARTA).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ST114_LIE=s6
exec python3 "$HERE/_karkas_staba.py" measure "$@"
