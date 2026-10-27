#!/usr/bin/env bash
# СТАБ 142 v2: предпроверка NUL смотрит ТОЛЬКО первую строку дома секретов —
# NUL во второй и далее строках не замечается (sed -n 1p), парсер удаляет NUL,
# строка получает исключение И-3 или пропускается — сессия поднимается.
# Привязка к клеткам — source.json:.stab_vhod["stab_predproverka-pervaya-stroka"]
# (Н-39, по коду): n9, n10 — первая строка чистая, NUL во второй (пустая
# строка с NUL / порождённое адресное имя с NUL).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a0 = '''  if LC_ALL=C grep -qaP '\\x00' -- "$DOM_SEKRETOV"; then
'''
b0 = '''  if LC_ALL=C grep -qaP '\\x00' -- <(sed -n 1p "$DOM_SEKRETOV"); then
'''
assert src.count(a0) == 1, "точка правки модели не найдена: строка NUL-предпроверки"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a0, b0))
PY
