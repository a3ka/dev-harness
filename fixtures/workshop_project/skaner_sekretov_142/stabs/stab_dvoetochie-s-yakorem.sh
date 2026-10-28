#!/usr/bin/env bash
# СТАБ 142 v4 (арбитраж contracts-142-v4-arbitraz): якорь `^` на
# ДВОЕТОЧИЕ-ветви (классы v1/v3) — сужение канона относительно v3:
# `X:Y@` судится только от НАЧАЛА значения, `https://host:80?u=a@b`
# (k111/k112, пара порт+`@`) и пароль с сырым `#` (k115) пропускаются
# (fail-open); токен-ветвь честная — k113 судится ею, k116 (DSN без схемы
# `user:p?…@`) — от начала значения, потому привязаны только k111/k112/k115.
# Привязка к клеткам — source.json:.stab_vhod["stab_dvoetochie-s-yakorem"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|^[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: якорь на двоеточие-ветви"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old, new))
PY
