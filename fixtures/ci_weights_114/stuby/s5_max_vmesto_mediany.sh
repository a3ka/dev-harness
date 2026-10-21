#!/usr/bin/env bash
# Обманный стаб s5 (max_vmesto_mediany, measure): вес ключа = max наблюдений,
# не медиана — выброс рантайма навсегда портит вес. Точка лжи —
# ST114_LIE=s5 каркаса _karkas_staba.py; грамматика/порог/атомарность честны.
# Привязка к клетке — KARTA red_114.sh (по коду, Н-39). Честность вне лжи
# не наблюдаема по классу: на любом корпусе с разбросом max ≠ медиане
# (класс тот же, что s6 — оговорка в KARTA).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ST114_LIE=s5
exec python3 "$HERE/_karkas_staba.py" measure "$@"
