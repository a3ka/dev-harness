#!/usr/bin/env bash
# Обманный стаб s1 (vsegda_zelenyj, guard): не читает вход, rc 0 всегда.
# Точка лжи — ST114_LIE=s1 каркаса _karkas_staba.py; вне точки лжи каркас
# честен. Привязка к клетке — KARTA red_114.sh (по коду, Н-39).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ST114_LIE=s1
exec python3 "$HERE/_karkas_staba.py" guard "$@"
