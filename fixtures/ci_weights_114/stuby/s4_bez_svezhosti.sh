#!/usr/bin/env bash
# Обманный стаб s4 (bez_svezhosti, guard): г1/г2 честные, ветка свежести г3
# отсутствует — устаревший/незакоммиченный TSV проходит зелёным.
# Точка лжи — ST114_LIE=s4 каркаса _karkas_staba.py. Привязка к клетке —
# KARTA red_114.sh (по коду, Н-39).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ST114_LIE=s4
exec python3 "$HERE/_karkas_staba.py" guard "$@"
