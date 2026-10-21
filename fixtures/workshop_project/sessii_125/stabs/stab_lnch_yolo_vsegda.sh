#!/usr/bin/env bash
# СТАБ 125: сессия проекта получает yolo без слова --yolo
# Привязка к клеткам — source.json:.stab_vhod["stab_lnch_yolo_vsegda"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (одна правка модели workshop.sh).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [('cd "$PROJECT"\nexec omp', 'cd "$PROJECT"\nYOLO_ARGS=(--approval-mode yolo)\nexec omp')]:
    assert src.count(a) >= 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
