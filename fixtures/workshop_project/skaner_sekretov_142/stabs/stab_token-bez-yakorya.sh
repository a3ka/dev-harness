#!/usr/bin/env bash
# СТАБ 142 v4 (арбитраж contracts-142-v4-arbitraz): токен-ветвь БЕЗ
# якоря начала значения (`^` снят, схема необязательна как в каноне,
# классы прежние) — вложенный URL `://…@` в query/path/fragment внешнего
# адреса находится регэкспом как userinfo → честный адрес
# (`https://host?redirect=https://tok@other`) даёт ЛОЖНЫЙ отказ (возврат
# боли И-3); двоеточие-ветвь — строка v1/v3.
# Привязка к клеткам — source.json:.stab_vhod["stab_token-bez-yakorya"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='(([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: якорь начала значения"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old, new))
PY
