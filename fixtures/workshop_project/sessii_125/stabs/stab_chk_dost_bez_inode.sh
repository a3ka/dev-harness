#!/usr/bin/env bash
# СТАБ 125: нет сверки inode: жёсткая ссылка на пустой файл каталога агента dev не видна
# Привязка к клеткам — source.json:.stab_vhod["stab_chk_dost_bez_inode"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (правка модели check_project_session.sh).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [
    ('        if (st.st_dev, st.st_ino) in dev_ino: ssylka = True\n', ''),
]:
    assert src.count(a) == 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
