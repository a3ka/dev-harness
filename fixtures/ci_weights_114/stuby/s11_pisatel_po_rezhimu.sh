#!/usr/bin/env bash
# Обманный стаб s11 (pisatel_po_rezhimu, measure): честный TSV на любом входе;
# побочная запись ФАЙЛА registry/measure-debug.log (не lanes — г0 --base её не
# ловит) ТОЛЬКО когда вызов сетевой (без --logs) ИЛИ --out задан явно; в ячейке
# «корпус, default --out» побочной записи нет (арбитраж 114, П3; класс обходов
# writer-extra/writer-explicit — мера ветвится на объявленной оси интерфейса).
# Точка лжи — ST114_LIE=s11 каркаса _karkas_staba.py. Привязка к клеткам —
# KARTA red_114.sh (по коду, Н-39): ложь наблюдаема в клетках-носителях
# т19 (сеть, default --out), т20 (сеть, явный --out), т21 (корпус, явный
# --out); т18 (корпус, default --out) зелёная — честность по TSV наблюдаема
# на конформном корпусе (побочный файл вне TSV, класс как у s10).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ST114_LIE=s11
exec python3 "$HERE/_karkas_staba.py" measure "$@"
