#!/usr/bin/env bash
# СТАБ 142: идиома последней строки убрана — значение ПОСЛЕДНЕЙ строки secrets.env
# (файл без хвостового LF) теряется из списка значений (125 Рв125b-2).
# Привязка к клеткам — source.json:.stab_vhod["stab_poslednyaya-stroka"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "  while IFS='=' read -r k v || [ -n \"$k\" ]; do\n"
assert src.count(a) == 1, "точка правки модели не найдена: цикл разбора дома"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, "  while IFS='=' read -r k v; do\n"))
PY
