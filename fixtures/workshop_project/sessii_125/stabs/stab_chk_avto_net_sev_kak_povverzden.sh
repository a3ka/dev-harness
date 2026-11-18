#!/usr/bin/env bash
# СТАБ 125-А1 (решение 6): отсутствующий/пустой sev.json даёт sev-fakty-povverzdeny
# вместо предусмотренного fakty-proekta-net (замер арбитра 3 — неверное имя отказа)
# Привязка — source.json:.stab_vhod["stab_chk_avto_net_sev_kak_povverzden"] (Н-39).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = ("    if nuzhen_sev:\n"
     "        fs = os.path.join(d, \"sev.json\")\n"
     "        if not os.path.isfile(fs) or os.path.getsize(fs) == 0:\n"
     "            return None\n")
b = "    pass  # СТАБ: отсутствующий/пустой sev.json — не непригодность комплекта\n"
assert src.count(a) == 1, "точка правки модели не найдена: пригодность комплекта с sev.json"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
