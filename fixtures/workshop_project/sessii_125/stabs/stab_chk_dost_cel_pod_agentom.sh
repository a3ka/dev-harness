#!/usr/bin/env bash
# СТАБ 125: цель ссылки судится только «под каталогом агента dev» (не предок), обход не входит в каталоги-ссылки
# Привязка к клеткам — source.json:.stab_vhod["stab_chk_dost_cel_pod_agentom"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (правка модели check_project_session.sh).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [
    ('def k_dev(r): return predok(koren_dev, r) or predok(r, koren_dev)\n', 'def k_dev(r): return predok(koren_dev, r)\n'),
    ('        if stat.S_ISDIR(st.st_mode): obhod.append(q); continue\n', '        if stat.S_ISDIR(st.st_mode):\n            if not os.path.islink(q): obhod.append(q)\n            continue\n'),
]:
    assert src.count(a) == 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
