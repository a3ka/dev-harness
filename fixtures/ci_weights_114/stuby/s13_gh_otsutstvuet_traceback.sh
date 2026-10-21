#!/usr/bin/env bash
# Обманный стаб s13 (gh_otsutstvuet_traceback, measure): сетевой режим при
# отсутствии gh в PATH умирает traceback'ом rc 1 вместо именованного rc 2
# «gh api отказ…» (дефект Adv114 №2 живой реализации: FileNotFoundError из
# subprocess.run не перехвачен). Точка лжи — ST114_LIE=s13 каркаса
# _karkas_staba.py; gh ПРИСУТСТВУЮЩИЙ в PATH обрабатывается честно,
# корпус-режим честен. Привязка к клетке — KARTA red_114.sh (по коду,
# Н-39): ложь наблюдаема ровно на входе без gh (клетка т23) — там, где
# честная модель даёт именованный rc 2, стаб даёт rc 1/traceback.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ST114_LIE=s13
exec python3 "$HERE/_karkas_staba.py" measure "$@"
