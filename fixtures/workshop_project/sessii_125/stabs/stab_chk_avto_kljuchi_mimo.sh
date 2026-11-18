#!/usr/bin/env bash
# СТАБ 125-А1 (решение 6): файл-ключи рядом с --avto принимаются молча —
# единственность ключа автосверки (И-10.1) нарушена
# Привязка — source.json:.stab_vhod["stab_chk_avto_kljuchi_mimo"] (Н-39).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "  [ -z \"$MA$ME$PA$PE\" ] || { printf 'НЕЧЕМ-ПРОВЕРИТЬ kljuch-neizvesten\\n'; exit 2; }\n"
b = "  : # СТАБ: файл-ключи рядом с --avto принимаются\n"
assert src.count(a) == 1, "точка правки модели не найдена: отказ файл-ключа при --avto"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
