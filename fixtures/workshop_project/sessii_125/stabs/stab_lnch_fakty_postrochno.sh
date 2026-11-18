#!/usr/bin/env bash
# СТАБ Crit125V3: писатель теряет границы аргументов, записывая argv построчно.
# Привязки — только source.json:.stab_vhod (Н-39).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "  printf '%s\\0' \"$@\" > \"$_stage/argv\" || die \"запись argv фактов не удалась\"\n"
b = "  printf '%s\\n' \"$@\" > \"$_stage/argv\" || die \"запись argv фактов не удалась\"\n"
assert src.count(a) == 1, "точка правки модели не найдена: запись argv"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, b))
PY
