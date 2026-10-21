#!/usr/bin/env bash
# Обманный стаб s2 (odnostoronnij, guard): красит только завышение
# (вес > 3×замер), занижение молчит. Точка лжи — ST114_LIE=s2 каркаса
# _karkas_staba.py; вне точки лжи каркас честен (г1 и г3 на месте).
# Привязка к клетке — KARTA red_114.sh (по коду, Н-39).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ST114_LIE=s2
exec python3 "$HERE/_karkas_staba.py" guard "$@"
