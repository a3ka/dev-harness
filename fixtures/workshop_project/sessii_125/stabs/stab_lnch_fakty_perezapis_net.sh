#!/usr/bin/env bash
# СТАБ 125 v2: повторный старт НЕ перезаписывает факты — существующий комплект
# остаётся от прошлого запуска (дрейф между стартами, хвосты старта)
# Привязка — source.json:.stab_vhod["stab_lnch_fakty_perezapis_net"] (Н-39).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = ("  # занятое КАТАЛОГОМ каноническое имя — убрать в сторону ДО публикации (не писать сквозь него)\n"
     "  if [ -d \"$_d\" ] && [ ! -L \"$_d\" ]; then\n"
     "    mv -f -- \"$_d\" \"$_base/.${_nm}.old.$$\" || { rm -rf -- \"$_stage\"; die \"занятое каноническое имя не освобождено: $_d\"; }\n"
     "  fi\n")
b = "  if [ -e \"$_d\" ] || [ -L \"$_d\" ]; then rm -rf -- \"$_stage\"; return 0; fi  # СТАБ: существующий комплект не перезаписывается\n"
assert src.count(a) == 1, "точка правки модели не найдена: блок освобождения имени"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
