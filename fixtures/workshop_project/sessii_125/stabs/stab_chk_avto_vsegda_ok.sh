#!/usr/bin/env bash
# СТАБ 125 v2: автосверка молчит и всегда rc 0 (зелёная без сверки); файл-режим не тронут
# Привязка к клеткам — source.json:.stab_vhod["stab_chk_avto_vsegda_ok"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/check_project_session.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [("if [ -n \"$AVTO\" ]; then\n",
              "if [ -n \"$AVTO\" ]; then\n  exit 0  # СТАБ: авточеверка всегда зелёная\n")]:
    assert src.count(a) == 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
