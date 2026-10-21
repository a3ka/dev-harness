#!/usr/bin/env bash
# СТАБ 125: значения секретов печатаются в вывод подключения
# Привязка к клеткам — source.json:.stab_vhod["stab_conn_sekrety_vyvod"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (одна правка модели connect_project.sh).
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [("grep -qxF '.harness/.env' .git/info/exclude", "cat .harness/.env; grep -qxF '.harness/.env' .git/info/exclude")]:
    assert src.count(a) >= 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
