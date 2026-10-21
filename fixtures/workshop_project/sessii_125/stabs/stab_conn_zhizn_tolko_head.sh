#!/usr/bin/env bash
# СТАБ 125: отказ env-v-indekse судит только HEAD (git cat-file HEAD:.harness/.env), не индекс
# Привязка к клеткам — source.json:.stab_vhod["stab_conn_zhizn_tolko_head"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (правка модели connect_project.sh).
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = 'git ls-files --error-unmatch -- .harness/.env >/dev/null 2>&1'
assert src.count(a) == 1, "точка правки модели не найдена: " + a
src = src.replace(a, 'git cat-file -e HEAD:.harness/.env >/dev/null 2>&1')
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
