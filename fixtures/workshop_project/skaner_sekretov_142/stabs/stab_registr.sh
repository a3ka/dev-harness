#!/usr/bin/env bash
# СТАБ 142: регистр имени не складывается к верхнему — адресный суффикс в нижнем
# регистре (metering_proxy_url) не распознаётся как параметр, ложный отказ остаётся.
# Привязка к клеткам — source.json:.stab_vhod["stab_registr"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "    _ku=$(printf '%s' \"$k\" | tr 'a-z' 'A-Z')\n"
assert src.count(a) == 1, "точка правки модели не найдена: складывание регистра"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, "    _ku=$(printf '%s' \"$k\")\n"))
PY
