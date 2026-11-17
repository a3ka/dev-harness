#!/usr/bin/env bash
# СТАБ 125 v2: в --avto сев судится ЖИВЫМИ байтами дома проекта (не записью старта) —
# перезапись omp-рантаймом (остаток R15) и честная запись с честными байтами расходятся с правдой
# Привязка — source.json:.stab_vhod["stab_chk_avto_sev_po_zhivym"] (Н-39).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = ("    if AVTO:\n"
     "        # сев судится записью старта: обычный файл в доме, запись обязательна, sha источника = sha копии\n"
     "        if os.path.islink(p) or not os.path.isfile(p) or name not in SEVZAP or SEVZAP[name][0] != SEVZAP[name][1]:\n"
     "            ras.add(pole)\n"
     "        continue\n")
b = ("    if AVTO:\n"
     "        # СТАБ: живые байты вместо записи старта\n"
     "        if os.path.islink(p) or not os.path.isfile(p) or sha(p) != sha(m):\n"
     "            ras.add(pole)\n"
     "        continue\n")
assert src.count(a) == 1, "точка правки модели не найдена: блок сева --avto"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
