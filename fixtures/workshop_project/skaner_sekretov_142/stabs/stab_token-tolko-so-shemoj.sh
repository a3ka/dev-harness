#!/usr/bin/env bash
# СТАБ 142 v4 (арбитраж contracts-142-v4-arbitraz): токен-ветвь ТОЛЬКО со
# схемой (ровно токен-ветвь OBJECT 25bda098) — scheme-relative токен
# `//<токен>@host` (k114) пропускается (fail-open); двоеточие-ветвь
# честная строка v1/v3 — k113 судится ею, потому привязан только k114.
# Привязка к клеткам — source.json:.stab_vhod["stab_token-tolko-so-shemoj"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='(^[^/?#[:space:]]*://[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: токен-ветвь только со схемой"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old, new))
PY
