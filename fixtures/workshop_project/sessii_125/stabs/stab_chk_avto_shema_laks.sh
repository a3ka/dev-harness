#!/usr/bin/env bash
# СТАБ 125-А1 (решение 6): схема sev-записи не судится — значения вне алфавита
# и поля не ровно {sha-istochnik, sha-kopija} проходят молча
# Привязка — source.json:.stab_vhod["stab_chk_avto_shema_laks"] (Н-39).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = ("    shema = isinstance(zap, dict) and all(\n"
     "        isinstance(v, dict) and set(v) == {\"sha-istochnik\", \"sha-kopija\"}\n"
     "        and all(re.fullmatch(r\"[0-9a-f]{64}\", str(x)) for x in v.values())\n"
     "        for v in zap.values())\n")
b = "    shema = isinstance(zap, dict)  # СТАБ: схема не судится\n"
assert src.count(a) == 1, "точка правки модели не найдена: схема sev-записи"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
