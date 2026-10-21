#!/usr/bin/env bash
# Обманный стаб s9 (set_bez_istochnika, measure): сетевой режим фабрикует TSV
# из весов реестра, НЕ обращаясь к источнику (gh не вызывается) — обход Б1
# круга 2. Точка лжи — ST114_LIE=s9 каркаса _karkas_staba.py; корпус-режим
# (--logs) честен. Привязка к клетке — KARTA red_114.sh (по коду, Н-39):
# ложь наблюдаема следом вызова gh (пуст) и TSV ≠ ожиданию из данных двойника.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ST114_LIE=s9
exec python3 "$HERE/_karkas_staba.py" measure "$@"
