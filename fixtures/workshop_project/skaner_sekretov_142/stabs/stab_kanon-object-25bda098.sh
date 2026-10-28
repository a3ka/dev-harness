#!/usr/bin/env bash
# СТАБ 142 v4 (арбитраж contracts-142-v4-arbitraz): канон целиком =
# канон OBJECT 25bda098 ДОСЛОВНО — `(^[^/?#[:space:]]*://…|^[^/?#[:space:]]*:…@)`:
# якорь `^` и границы `?`/`#` на ДВОЕТОЧИЕ-ветви — мутант, который случился
# (двоеточие-ветвь переписана при слове владельца о РАСШИРЕНИИ токеном).
# Пропуски относительно v4: `//user:pass@host` (k113), `//<токен>@host`
# (k114), пароль с сырым `#` (k115) и `?` (k116), пара порт+`@` в
# query/fragment (k111/k112) — fail-open на учётных данных, которые v3
# защищала; ловится всеми шестью клетками правки арбитража.
# Привязка к клеткам — source.json:.stab_vhod["stab_kanon-object-25bda098"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='(^[^/?#[:space:]]*://[^/?#[:space:]]+@|^[^/?#[:space:]]*:[^/?#[:space:]]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: канон OBJECT 25bda098"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old, new))
PY
