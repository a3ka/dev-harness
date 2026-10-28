#!/usr/bin/env bash
# СТАБ 142 v4 (арбитраж contracts-142-v4-arbitraz): класс двоеточие-ветви
# БЕЗ `?`/`#` (без якоря) — сужение канона относительно v3: пароль с сырым
# `#` (k115) и `?` (k116, DSN без схемы) и пара порт+`@` в query/fragment
# (k111/k112) пропускаются (fail-open); токен-ветвь честная — k113 судится
# ею, потому привязаны k111/k112/k115/k116.
# Привязка к клеткам — source.json:.stab_vhod["stab_dvoetochie-bez-voprosa-reshetki"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/?#@[:space:]]*:[^/?#@[:space:]]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: двоеточие-ветвь без ?/#"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old, new))
PY
