#!/usr/bin/env bash
# СТАБ 142 (adv contracts-142-impl-v1): «неконформное имя исключается молча» —
# имя вне грамматики трактуется как «не ключ» и выкидывается из сканирования
# ДО предиката (fail-open на всём классе): утечка значения неконформного имени
# без суффикса и пустого имени не сканируется вовсе, сессия поднимается.
# Канон-строка IMYA_RE сохранена байт в байт; три строки канона не тронуты.
# Привязка к клеткам — source.json:.stab_vhod["stab_nekonformnoe-iskljuchaetsja-molcha"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = '''    [ -n "$v" ] || continue
'''
b = '''    [ -n "$v" ] || continue
    printf '%s' "$k" | grep -Eqx -- "$IMYA_RE" || continue # СТАБ: неконформное имя молча исключено из сканирования
'''
assert src.count(a) == 1, "точка правки модели не найдена: пропуск пустых значений"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, b))
PY
