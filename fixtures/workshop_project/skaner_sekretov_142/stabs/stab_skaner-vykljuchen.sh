#!/usr/bin/env bash
# СТАБ 142: сканер отключён целиком (страж sekret-v-dereve удалён из двери).
# Привязка к клеткам — source.json:.stab_vhod["stab_skaner-vykljuchen"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a0 = '  ZNACH=$(mktemp) || otkaz "нет mktemp"'
a1 = '  unset ZNACH _need _ku _kt\n'
assert src.count(a0) == 1 and src.count(a1) == 1, "точка правки модели не найдена: блок sekret-v-dereve"
i, j = src.index(a0), src.index(a1) + len(a1)
open(sys.argv[2], "w", encoding="utf-8").write(src[:i] + '  HIT=""\n' + src[j:])
PY
