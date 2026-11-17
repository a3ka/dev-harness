#!/usr/bin/env bash
# СТАБ 125 v2: argv-факт пишется СКЛЕЙКОЙ аргументов одной строкой (второе вычисление
# вместо передачи ТЕХ ЖЕ элементов, А-918) — записи ≠ наблюдению стаб-omp
# Привязка — source.json:.stab_vhod["stab_lnch_fakty_vtorye"] (Н-39).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "  printf '%s\\n' \"$@\" > \"$_t\" && mv -f -- \"$_t\" \"$_d/argv\" || die \"запись argv фактов не удалась\"\n"
b = "  printf '%s\\n' \"$*\" > \"$_t\" && mv -f -- \"$_t\" \"$_d/argv\" || die \"запись argv фактов не удалась\"  # СТАБ: склейка\n"
assert src.count(a) == 1, "точка правки модели не найдена: запись argv"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
