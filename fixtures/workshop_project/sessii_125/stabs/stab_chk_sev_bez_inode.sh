#!/usr/bin/env bash
# СТАБ 125: сев судится по sha256 без inode: жёсткая ссылка файла сева на dev не видна
# Привязка к клеткам — source.json:.stab_vhod["stab_chk_sev_bez_inode"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (правка модели check_project_session.sh).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [
    (' or os.path.samefile(p, m) or sha(p) != sha(m):\n', ' or sha(p) != sha(m):\n'),
]:
    assert src.count(a) == 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
