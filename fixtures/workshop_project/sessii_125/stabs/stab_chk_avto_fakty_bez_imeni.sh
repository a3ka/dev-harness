#!/usr/bin/env bash
# СТАБ 125 v2: отказы автосверки БЕЗ ИМЕНИ (молчаливый rc 1) — «отказ именованный
# и правдивый» (AGENTS.md п.7) нарушен
# Привязка — source.json:.stab_vhod["stab_chk_avto_fakty_bez_imeni"] (Н-39).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "def otkaz(p):\n    print(\"НЕЧЕМ-ПРОВЕРИТЬ \" + p); sys.exit(2)\n"
b = "def otkaz(p):\n    sys.exit(1)  # СТАБ: молчаливый отказ без имени\n"
assert src.count(a) == 1, "точка правки модели не найдена: otkaz"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
