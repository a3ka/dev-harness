#!/usr/bin/env bash
# СТАБ 125 v2: сверка берёт факты проекта из ДЕРЕВА проекта (<корень>/.harness/session-exec),
# когда они там есть, — диск проверяемого как источник истины (нарушение п.8 AGENTS.md)
# Привязка — source.json:.stab_vhod["stab_chk_avto_doveriaet_derevu"] (Н-39).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "pdir = os.path.join(baza, \"dev-harness-projects\", pid, \"session-exec\")\n"
b = ("pdir = os.path.join(baza, \"dev-harness-projects\", pid, \"session-exec\")\n"
     "_derevo = os.path.join(koren, \".harness\", \"session-exec\")  # СТАБ: дереву доверяет\n"
     "if os.path.isdir(_derevo):\n"
     "    pdir = _derevo\n")
assert src.count(a) == 1, "точка правки модели не найдена: pdir"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
