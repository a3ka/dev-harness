#!/usr/bin/env bash
# СТАБ 142: в список значений попадает только дословная форма — значение в доме
# секретов в кавычках не совпадает с тем же значением без кавычек в файле.
# Привязка к клеткам — source.json:.stab_vhod["stab_formy-znachenija"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
pre = '    u=$(printf \'%s\' "$v" | sed '          # кавычный sed 125 — якорь по префиксу
assert src.count(pre) == 1, "точка правки модели не найдена: форма без кавычек"
j = src.index(pre)
k = src.index("\n", j) + 1                          # конец строки u=...
u_line = '    [ -n "$u" ] && printf'
assert src.count(u_line) == 1, "точка правки модели не найдена: печать u"
k2 = src.index(u_line, k)
k2 = src.index("\n", k2) + 1
open(sys.argv[2], "w", encoding="utf-8").write(src[:j] + src[k2:])
PY
