#!/usr/bin/env bash
# СТАБ 142: у адресных имён не проверяются учётные данные в значении —
# DATABASE_URL с user:pass@ и DSN без схемы пропускаются (fail-open по значению).
# Привязка к клеткам — source.json:.stab_vhod["stab_bez-userinfo"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "    elif adresnyj_suffiks \"$_ku\" && ! printf '%s' \"$v\" | grep -Eq -- \"$USERINFO_RE\"; then\n"
assert src.count(a) == 1, "точка правки модели не найдена: ветка userinfo"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, "    elif adresnyj_suffiks \"$_ku\"; then\n"))
PY
