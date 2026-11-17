#!/usr/bin/env bash
# СТАБ 125 v2: факты проекта пишутся В ДЕРЕВО проекта (<корень>/session-exec),
# а не в $PSTATE вне дерева (Граница-7 054, И-9)
# Привязка — source.json:.stab_vhod["stab_lnch_fakty_v_dereve"] (Н-39).
set -eu
python3 - "$1/workshop.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = '_125v2_zapisi_fakty "$PSTATE/session-exec" project "$PROJECT_ID_VAL" "$PSTATE/home" "$PROJECT" "$_SEVJSON" \\\n'
b = '_125v2_zapisi_fakty "$PROJECT/session-exec" project "$PROJECT_ID_VAL" "$PSTATE/home" "$PROJECT" "$_SEVJSON" \\\n'
assert src.count(a) == 1, "точка правки модели не найдена: место фактов проекта"
src = src.replace(a, b)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
