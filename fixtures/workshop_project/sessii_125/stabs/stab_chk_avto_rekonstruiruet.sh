#!/usr/bin/env bash
# СТАБ 125 v2: сверка судит РЕКОНСТРУКЦИЮ (фактам основной приписываются проекту),
# а не запись лаунчера — расхождение в записи не видно
# Привязка — source.json:.stab_vhod["stab_chk_avto_rekonstruiruet"] (Н-39).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [("  PA=$(printf '%s\\n' \"$FAKTY5\" | sed -n 3p)\n",
              "  PA=\"$MA\"  # СТАБ: реконструкция — проекту приписаны факты основной\n"),
             ("  PE=$(printf '%s\\n' \"$FAKTY5\" | sed -n 4p)\n",
              "  PE=\"$ME\"  # СТАБ\n")]:
    assert src.count(a) == 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
