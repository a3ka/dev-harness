#!/usr/bin/env bash
# СТАБ 142 v4 (арбитраж contracts-142-v4-arbitraz): нижняя граница
# токен-ветви `{2,}` вместо `+` — односимвольный токен (`https://x@host`)
# под адресным именем пропускается (fail-open), дверь запускает workshop
# вместо отказа; клетка k107-odinosimvolnyj-token закрывает границу канона
# `+` (≥1 символа); двоеточие-ветвь — строка v1/v3.
# Привязка к клеткам — source.json:.stab_vhod["stab_min-dlina-tokena"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='(([^/?#[:space:]]*:)?//[^/?#[:space:]]{2,}@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: минимальная длина токена"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old, new))
PY
