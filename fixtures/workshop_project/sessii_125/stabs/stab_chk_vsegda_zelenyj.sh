#!/usr/bin/env bash
# СТАБ 125: сверщик молчит и всегда rc 0 (зелёный без сверки)
# Привязка к клеткам — source.json:.stab_vhod["stab_chk_vsegda_zelenyj"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (одна правка модели check_project_session.sh).
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [('exec python3 - "$MA" "$ME" "$PA" "$PE" <<\'PY\'\n', 'exit 0; exec python3 - "$MA" "$ME" "$PA" "$PE" <<\'PY\'\n')]:
    assert src.count(a) >= 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
