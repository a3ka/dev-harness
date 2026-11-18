#!/usr/bin/env bash
# СТАБ 125-А1 (решение 3, зависимый регресс): режим выбирается унаследованными из
# окружения служебными переменными, а не только ключом CLI — файл-режим похищен
# Привязка — source.json:.stab_vhod["stab_chk_rezhim_iz_okruzhenija"] (Н-39).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "unset S125_AVTO S125_SEV_ZAPIS 2>/dev/null || true\n"
b = "# СТАБ: служебные переменные среды выбирают режим\n"
assert src.count(a) == 1, "точка правки модели не найдена: unset служебных переменных"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
