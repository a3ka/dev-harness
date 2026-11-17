#!/usr/bin/env bash
# СТАБ 125-А1 (решение 6): поврежденная sev-запись судится РАНЬШЕ чужой
# принадлежности — объявленный порядок причин нарушен
# Привязка — source.json:.stab_vhod["stab_chk_avto_porjadok_sev_ranshe"] (Н-39).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = ('if tvoj[3].get("projectId") != pid:\n'
     '    otkaz("fakty-proekta-chuzhie")\n'
     'fsev = os.path.join(tvoj[0], "sev.json")\n')
b = ('fsev = os.path.join(tvoj[0], "sev.json")\n'
     '_s0 = False\n'
     'try:\n'
     '    _z0 = json.load(open(fsev)); _s0 = isinstance(_z0, dict)\n'
     'except Exception:\n'
     '    _s0 = False\n'
     'if not _s0:\n'
     '    otkaz("sev-fakty-povverzdeny")  # СТАБ: sev прежде принадлежности\n'
     'if tvoj[3].get("projectId") != pid:\n'
     '    otkaz("fakty-proekta-chuzhie")\n')
assert src.count(a) == 1, "точка правки модели не найдена: порядок chuzhie/sev"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
