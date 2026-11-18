#!/usr/bin/env bash
# СТАБ 125-А1 (решение 4): базис PSTATE принимается ТОЛЬКО в буквальном написании —
# честный эквивалентный абсолютный путь (ссылка-алиас на тот же каталог) отказан
# Привязка — source.json:.stab_vhod["stab_chk_avto_baza_strogo"] (Н-39).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = 'pdir = os.path.join(baza, "dev-harness-projects", pid, "session-exec")\n'
b = ('if os.path.realpath(baza) != baza:\n'
     '    otkaz("fakty-proekta-net")  # СТАБ: только буквальный базис\n'
     'pdir = os.path.join(baza, "dev-harness-projects", pid, "session-exec")\n')
assert src.count(a) == 1, "точка правки модели не найдена: pdir"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
