#!/usr/bin/env bash
# СТАБ 125: сев один раз: существующая копия не перезаписывается (дрейф)
# Привязка к клеткам — source.json:.stab_vhod["stab_lnch_sev_odin_raz"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (одна правка модели workshop.sh).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [('  [ -f "$SEV_SRC/$_sf" ] || continue\n', '  [ -f "$SEV_SRC/$_sf" ] || continue\n  [ -e "$SEV_DST/$_sf" ] && continue\n')]:
    assert src.count(a) >= 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
