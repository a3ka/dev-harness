#!/usr/bin/env bash
# СТАБ 142 v4: токен-ветвь допускает ПУСТОЙ токен (`+` заменён на `*`) —
# вырожденный адрес `http://@host/…` считается несущим userinfo → значение
# сканируется, честный адрес даёт ЛОЖНЫЙ отказ (боль И-3).
# v4-правка (арбитраж contracts-142-v4-arbitraz): якорь перепривязан на
# канон-строку v4; дефект прежний — `*` вместо `+` в токен-ветви,
# двоеточие-ветвь — строка v1/v3.
# Привязка к клеткам — source.json:.stab_vhod["stab_pustoj-token"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='(([^/?#[:space:]]*:)?//[^/?#[:space:]]*@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: канон userinfo с пустым токеном"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old, new))
PY
