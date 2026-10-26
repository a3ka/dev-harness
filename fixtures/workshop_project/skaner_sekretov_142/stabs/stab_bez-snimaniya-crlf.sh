#!/usr/bin/env bash
# СТАБ 142: CRLF не снимается — \r остаётся частью значения, совпадения с чистым
# значением в файле нет.
# Привязка к клеткам — source.json:.stab_vhod["stab_bez-snimaniya-crlf"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = '    v="${v%$\'\\r\'}"\n'
assert src.count(a) == 1, "точка правки модели не найдена: снятие CRLF"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, "    :\n"))
PY
