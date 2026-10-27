#!/usr/bin/env bash
# СТАБ 142: у адресных имён не проверяются учётные данные в значении —
# DATABASE_URL с user:pass@ и DSN без схемы пропускаются (fail-open по значению).
# Привязка к клеткам — source.json:.stab_vhod["stab_bez-userinfo"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
# якорь перепривязан к предикату с грамматикой имени (adv 142-impl-v1): дефект
# прежний — конъюнкт userinfo снят, адресное имя грамматики пропускается и с
# учётными данными в значении (fail-open по значению);
old = r'''    elif printf '%s' "$k" | grep -Eqx -- "$IMYA_RE" \
      && adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_RE"; then
'''
new = r'''    elif printf '%s' "$k" | grep -Eqx -- "$IMYA_RE" \
      && adresnyj_suffiks "$_ku"; then
'''
assert src.count(old) == 1, "точка правки модели не найдена: ветка userinfo"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old, new))
PY
