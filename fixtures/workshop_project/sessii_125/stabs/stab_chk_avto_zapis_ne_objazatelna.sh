#!/usr/bin/env bash
# СТАБ 125-А1 (решение 6): неполная запись сева проходит — файл сева есть, записи
# для него нет, поле зелёное (И-10.4 «файл есть, записи нет — расхождение» нарушено)
# Привязка — source.json:.stab_vhod["stab_chk_avto_zapis_ne_objazatelna"] (Н-39).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = ("        if (os.path.islink(p) or not os.path.isfile(p) or pod(rp(p), mhome)\n"
     "                or os.path.samefile(p, m) or name not in SEVZAP\n"
     "                or SEVZAP[name][0] != SEVZAP[name][1]):\n")
b = ("        if (os.path.islink(p) or not os.path.isfile(p) or pod(rp(p), mhome)\n"
     "                or os.path.samefile(p, m) or (name in SEVZAP and SEVZAP[name][0] != SEVZAP[name][1])):  # СТАБ: записи может не быть\n")
assert src.count(a) == 1, "точка правки модели не найдена: обязательность записи"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
