#!/usr/bin/env bash
# СТАБ 125: дверь на ПОВТОРНОМ входе (.harness/.env уже был) делает git add -f .harness/.env перед exec (обход критика круга 2)
# Привязка к клеткам — source.json:.stab_vhod["stab_conn_zhizn_add_f_povtor"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба (правка модели connect_project.sh).
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
for a, b in [('cd "$ROOT" || die "нет корня: $ROOT"\n', 'cd "$ROOT" || die "нет корня: $ROOT"\nENV_BYL=0; [ -f .harness/.env ] && ENV_BYL=1\n'),
             ('export HARNESS_PROJECT_LAYER_ROOT=', '[ "$ENV_BYL" = 1 ] && git add -f .harness/.env\nexport HARNESS_PROJECT_LAYER_ROOT=')]:
    assert src.count(a) == 1, "точка правки модели не найдена: " + a[:60]
    src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
