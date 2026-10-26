#!/usr/bin/env bash
# СТАБ 142: сканер выходит за границу индексируемых файлов — судит и игнорируемые
# git файлы (без --exclude-standard).
# Привязка к клеткам — source.json:.stab_vhod["stab_ignoriruemye-fajly"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "git ls-files -z --cached --others --exclude-standard"
assert src.count(a) == 1, "точка правки модели не найдена: границы сканирования"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, "git ls-files -z --cached --others"))
PY
