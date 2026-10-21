#!/usr/bin/env bash
# СТАБ 125: дверь не проверяет, отслеживается ли .harness/.env git проекта (сессия поверх секрета в истории)
# Привязка к клеткам — source.json:.stab_vhod["stab_conn_ne_sudit_indeks"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (одна правка модели connect_project.sh).
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = 'git ls-files --error-unmatch -- .harness/.env >/dev/null 2>&1 \\\n  && die "env-v-indekse:'
assert src.count(a) == 1, "точка правки модели не найдена: " + a[:60]
src = src.replace(a, 'false \\\n  && die "env-v-indekse:')
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
