#!/usr/bin/env bash
# СТАБ 125: вариант А (отклонён): дом сессии проекта = дом зоны dev
# Привязка к клеткам — source.json:.stab_vhod["stab_lnch_obshij_dom"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (одна правка модели workshop.sh).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [('export HARNESS_SESSION_HOME="$PSTATE/home"\nexport HOME="$PSTATE/home"\n', 'export HARNESS_SESSION_HOME="$ZONE"\nexport HOME="$ZONE"\n')]:
    assert src.count(a) >= 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
