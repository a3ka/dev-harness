#!/usr/bin/env bash
# СТАБ 125: обход дома проекта не входит в каталоги-ссылки (os.walk без followlinks)
# Привязка к клеткам — source.json:.stab_vhod["stab_chk_dost_bez_obhoda"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (правка модели check_project_session.sh).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [
    ('        if stat.S_ISDIR(st.st_mode): obhod.append(q); continue\n', '        if stat.S_ISDIR(st.st_mode):\n            if not os.path.islink(q): obhod.append(q)\n            continue\n'),
]:
    assert src.count(a) == 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
