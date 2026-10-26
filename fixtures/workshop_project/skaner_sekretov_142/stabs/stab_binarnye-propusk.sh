#!/usr/bin/env bash
# СТАБ 142: бинарные файлы пропускаются (grep -I) — секрет в бинарном носителе
# перестаёт ловиться.
# Привязка к клеткам — source.json:.stab_vhod["stab_binarnye-propusk"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = 'grep -lsF -f "$ZNACH"'
assert src.count(a) == 1, "точка правки модели не найдена: сам grep сканера"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, 'grep -lsIF -f "$ZNACH"'))
PY
