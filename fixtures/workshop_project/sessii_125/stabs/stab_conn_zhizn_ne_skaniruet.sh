#!/usr/bin/env bash
# СТАБ 125: дверь не ищет значения секретов в индексируемых файлах под другими именами (модель круга 2)
# Привязка к клеткам — source.json:.stab_vhod["stab_conn_zhizn_ne_skaniruet"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (правка модели connect_project.sh).
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a0 = "# значения дома секретов — ни в одном файле"
a1 = 'сессия не запускается"\nfi\n'
assert src.count(a0) == 1 and src.count(a1) == 1, "точка правки модели не найдена: блок sekret-v-dereve"
i, j = src.index(a0), src.index(a1) + len(a1)
open(sys.argv[2], "w", encoding="utf-8").write(src[:i] + src[j:])
PY
