#!/usr/bin/env bash
# СТАБ 142 v2: предпроверка NUL смотрит ТОЛЬКО часть строки до первого «=»
# (sed 's/=.*$//') — NUL в ЗНАЧЕНИИ не замечается, парсер удаляет его, имя
# получает исключение И-3 (адресное) или значение судится уже без NUL —
# строка с NUL уходит в разбор вместо именованного отказа.
# Привязка к клеткам — source.json:.stab_vhod["stab_predproverka-do-ravno"]
# (Н-39, по коду): n6 (NUL в значении адресного имени — И-3, запуск),
# n7 (NUL в значении секретного имени — значение без NUL не найдено, запуск).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a0 = '''  if LC_ALL=C grep -qaP '\\x00' -- "$DOM_SEKRETOV"; then
'''
b0 = '''  if LC_ALL=C grep -qaP '\\x00' -- <(sed 's/=.*$//' "$DOM_SEKRETOV"); then
'''
assert src.count(a0) == 1, "точка правки модели не найдена: строка NUL-предпроверки"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a0, b0))
PY
