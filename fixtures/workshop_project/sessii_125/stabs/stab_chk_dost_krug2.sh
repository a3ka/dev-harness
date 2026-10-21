#!/usr/bin/env bash
# СТАБ 125: сверщик круга 2: цель ссылки судится только против путей живого состояния и их потомков, обход не входит в каталоги-ссылки, без inode
# Привязка к клеткам — source.json:.stab_vhod["stab_chk_dost_krug2"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (правка модели check_project_session.sh).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [
    ('def k_dev(r): return predok(koren_dev, r) or predok(r, koren_dev)\n', 'def k_dev(r): return any(predok(z, r) for z in zhivoe)\n'),
    ('        if stat.S_ISDIR(st.st_mode): obhod.append(q); continue\n', '        if stat.S_ISDIR(st.st_mode):\n            if not os.path.islink(q): obhod.append(q)\n            continue\n'),
    ('        if (st.st_dev, st.st_ino) in dev_ino: ssylka = True\n', ''),
]:
    assert src.count(a) == 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
