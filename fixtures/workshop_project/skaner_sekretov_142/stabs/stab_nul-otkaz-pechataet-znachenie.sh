#!/usr/bin/env bash
# СТАБ 142 v2: именованный отказ NUL печатает ЗНАЧЕНИЕ (сырую первую строку
# дома секретов через sed -n 1p) вместо «имя файла и категория NUL, не
# значение» (слово владельца 2026-10-27; 125: в отказе — имя файла, не
# значение).
# Привязка к клеткам — source.json:.stab_vhod["stab_nul-otkaz-pechataet-znachenie"]
# (Н-39, по коду): n1–n7 — значение/токен первой строки обязан отсутствовать
# в stderr отказа (n8–n12 у первой строки нет проверяемого значения — там
# стаб от честной модели не отличим и не привязан).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a0 = '''    otkaz "sekret-v-dereve: NUL (байт 0x00) в доме секретов «$DOM_SEKRETOV» — файл не читается как KEY=VALUE; сессия не запускается"
'''
b0 = '''    otkaz "sekret-v-dereve: NUL (байт 0x00) в доме секретов «$DOM_SEKRETOV»: $(sed -n 1p "$DOM_SEKRETOV") — файл не читается как KEY=VALUE; сессия не запускается"
'''
assert src.count(a0) == 1, "точка правки модели не найдена: строка отказа NUL"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a0, b0))
PY
