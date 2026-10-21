#!/usr/bin/env bash
# СТАБ 125: лаунчер после сева кладёт в дом проекта ссылку на каталог агента dev (ln -sfn "$SEV_SRC" "$PSTATE/home/dev-profile" — обход критика круга 2)
# Привязка к клеткам — source.json:.stab_vhod["stab_lnch_ssylka_na_profil"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (одна правка модели workshop.sh).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = 'unset _sf\nprintf \'SEV: %s\\n\' "$SEV_SRC"\n'
assert src.count(a) == 1, "точка правки модели не найдена: " + a[:60]
src = src.replace(a, 'ln -sfn -- "$SEV_SRC" "$PSTATE/home/dev-profile"\n' + a)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
