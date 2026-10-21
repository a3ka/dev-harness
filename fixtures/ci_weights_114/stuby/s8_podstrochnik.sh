#!/usr/bin/env bash
# Обманный стаб s8 (podstrochnik, measure): «замер:» ищется ПОДСТРОКОЙ где
# угодно в строке лога — приманки середины строки («info позже замер: …»)
# засчитываются замерами. Точка лжи — ST114_LIE=s8 каркаса _karkas_staba.py;
# агрегация/порог/ceil честны. Привязка к клетке — KARTA red_114.sh
# (по коду, Н-39).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ST114_LIE=s8
exec python3 "$HERE/_karkas_staba.py" measure "$@"
