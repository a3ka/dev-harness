#!/usr/bin/env bash
# СТАБ Crit125V3: читатель --avto принимает строки MSG за отдельные argv.
# Файл-режим не меняется; привязки — только source.json:.stab_vhod (Н-39).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = '        with open(fa, newline="") as h: argv = h.read().split("\\0")\n'
b = '        with open(fa, newline="") as h: argv = h.read().split("\\n")\n'
assert src.count(a) == 1, "точка правки модели не найдена: чтение argv"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, b))
PY
