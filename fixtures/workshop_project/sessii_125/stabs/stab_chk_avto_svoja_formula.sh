#!/usr/bin/env bash
# СТАБ 125 v2: сверка вычисляет базис PSTATE СВОЕЙ формулой ($HOME/.local/state),
# игнорируя env-цепочку лаунчера (HARNESS_SCRATCH → XDG_STATE_HOME) — факты не находит
# Привязка — source.json:.stab_vhod["stab_chk_avto_svoja_formula"] (Н-39).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = ("baza = (os.environ.get(\"HARNESS_SCRATCH\") or os.environ.get(\"XDG_STATE_HOME\")\n"
     "        or os.path.join(os.environ.get(\"HOME\", \"\"), \".local/state\"))\n")
b = "baza = os.path.join(os.environ.get(\"HOME\", \"\"), \".local/state\")  # СТАБ: своя формула\n"
assert src.count(a) == 1, "точка правки модели не найдена: базис PSTATE"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
