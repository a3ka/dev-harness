#!/usr/bin/env bash
# СТАБ 142: алфавит адресных суффиксов в функции сокращён до _URL (строка
# канона ADRES_SUFFIKSY сохранена байт в байт, цикл больше не читает её целиком)
# — остальные суффиксы замкнутого алфавита (_HOST _PORT _ADDR _ENDPOINT _NAME
# и базовые URL HOST PORT ADDR ENDPOINT NAME) перестают распознаваться:
# ложный отказ на законных адресных именах.
# Привязка к клеткам — source.json:.stab_vhod["stab_suffiks-tolko-url"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = '  adresnyj_suffiks() { for _s in $ADRES_SUFFIKSY; do [ "$1" != "${1%$_s}" ] && return 0; done; return 1; }'
b = '  adresnyj_suffiks() { for _s in _URL; do [ "$1" != "${1%$_s}" ] && return 0; done; return 1; }'
assert src.count(a) == 1, "точка правки модели не найдена: adresnyj_suffiks"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, b))
PY
