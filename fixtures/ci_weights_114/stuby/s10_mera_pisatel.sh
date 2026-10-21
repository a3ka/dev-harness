#!/usr/bin/env bash
# Обманный стаб s10 (mera_pisatel, measure): честно пишет TSV замеров, затем
# побочно правит lanes в реестре мира (обход критика Б3 «writer-changes-
# registry»: батарея была зелёной при изменённых lanes). Точка лжи —
# ST114_LIE=s10 каркаса _karkas_staba.py. Привязка к клетке — KARTA
# red_114.sh (по коду, Н-39): ложь наблюдаема сравнением деревьев миров
# (клетка т18); TSV-поведение честно на любом входе — оговорка по классу
# (как s5/s6 на константном корпусе): честность вне лжи наблюдаема только
# по байтам TSV.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ST114_LIE=s10
exec python3 "$HERE/_karkas_staba.py" measure "$@"
