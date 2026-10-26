#!/usr/bin/env bash
# СТАБ 142: сканируется только первое значение списка (первый шаблон grep -f) —
# секрет-подстрока и второе значение дубликата не ловятся.
# Привязка к клеткам — source.json:.stab_vhod["stab_tolko-pervyj-shablon"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = 'grep -lsF -f "$ZNACH"'
assert src.count(a) == 1, "точка правки модели не найдена: сам grep сканера"
b = 'grep -lsF -f <(sed -n 1p "$ZNACH")'
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, b))
PY
