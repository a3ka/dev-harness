#!/usr/bin/env bash
# СТАБ 142: пустое значение не отсеивается — пустой шаблон в grep -f матчит все
# файлы проекта, дверь отказывает на пустом значении ключа.
# Привязка к клеткам — source.json:.stab_vhod["stab_pustoj-shablon"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "    [ -n \"$v\" ] || continue\n"
assert src.count(a) == 1, "точка правки модели не найдена: отсев пустого значения"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, "    :\n"))
PY
