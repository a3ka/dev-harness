#!/usr/bin/env bash
# СТАБ 142 v4: токен-ветвь без границы `?`/`#` — `@` в запросе/фрагменте
# СРАЗУ после authority (без `/` между `://` и `@`) считается userinfo →
# честный адрес с `@` в query/fragment даёт ЛОЖНЫЙ отказ (боль И-3).
# v4-правка (арбитраж contracts-142-v4-arbitraz): якорь перепривязан на
# канон-строку v4; дефект прежний — класс authority допускает `?`/`#`
# (`[^/@[:space:]]`), двоеточие-ветвь — строка v1/v3.
# Привязка к клеткам — source.json:.stab_vhod["stab_token-bez-granicy"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='(([^/?#[:space:]]*:)?//[^/@[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: канон userinfo без границы ?/#"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old, new))
PY
