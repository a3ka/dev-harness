#!/usr/bin/env bash
# СТАБ 142 v4: токен-ветвь БЕЗ привязки к `://` и началу значения — `@` в
# пути/запросе после первого `/` считается userinfo → значение адресного
# имени сканируется, честный адрес с `@` в пути даёт ЛОЖНЫЙ отказ (возврат
# боли И-3).
# v4-правка (арбитраж contracts-142-v4-arbitraz): якорь перепривязан на
# канон-строку v4; дефект прежний — альтернатива `[^/?#@[:space:]]+@` без
# `://` и без якоря, двоеточие-ветвь — строка v1/v3.
# Привязка к клеткам — source.json:.stab_vhod["stab_token-gde-ugodno"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='([^/?#@[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: канон userinfo без привязки к схеме"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old, new))
PY
