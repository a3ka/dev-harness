#!/usr/bin/env bash
# СТАБ 142: канон секретных маркеров изменён (голый KEY заменён на API_KEY) —
# единый источник расходится между субъектом и батареей.
# Привязка к клеткам — source.json:.stab_vhod["stab_kanon-izmenen"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = '  SEKRET_MARKERY="KEY TOKEN SECRET PASSWD PASSWORD PASSPHRASE PRIVATE AUTH COOKIE CREDENTIAL"\n'
assert src.count(a) == 1, "точка правки модели не найдена: канон маркеров"
b = '  SEKRET_MARKERY="API_KEY TOKEN SECRET PASSWD PASSWORD PASSPHRASE PRIVATE AUTH COOKIE CREDENTIAL"\n'
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, b))
PY
