#!/usr/bin/env bash
# СТАБ 142: отказ печатает значение секрета (утечка в stderr) вместо только имени
# файла (125: «в отказе — имя файла, не значение»).
# Привязка к клеткам — source.json:.stab_vhod["stab_otkaz-pechataet-znachenie"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a0 = "  rm -f \"$ZNACH\"\n"
a1 = "  unset ZNACH _need _ku _kt\n"
a2 = '  [ -z "$HIT" ] || otkaz "sekret-v-dereve: значение дома секретов в файле'
assert src.count(a0) == 1 and src.count(a1) == 1 and src.count(a2) == 1, \
    "точки правки модели не найдены: итог стража"
src = src.replace(a0, "")            # файл значений живёт до отказа
src = src.replace(a1, "  :\n")       # и переменная тоже
bad = '  [ -z "$HIT" ] || otkaz "sekret-v-dereve: значение дома секретов $(sed -n 1p "$ZNACH") в файле'
src = src.replace(a2, bad)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
