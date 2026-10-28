#!/usr/bin/env bash
# СТАБ 142 v4: токен-ветвь только у схемы https (канон судит ЛЮБУЮ схему
# с `://` и scheme-relative) — токен `http://<токен>@host` под адресным
# именем пропускается.
# v4-правка (арбитраж contracts-142-v4-arbitraz): якорь перепривязан на
# канон-строку v4; дефект прежний — литерал `https://` вместо
# `^([^/?#…]*:)?//`, двоеточие-ветвь — строка v1/v3.
# Привязка к клеткам — source.json:.stab_vhod["stab_token-tolko-https"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='(^https://[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: канон userinfo только https"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old, new))
PY
