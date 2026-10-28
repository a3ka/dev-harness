#!/usr/bin/env bash
# СТАБ 142: дубликат ключа пропускается (судится только первое вхождение) — второе
# значение того же ключа не попадает в список значений.
# Привязка к клеткам — source.json:.stab_vhod["stab_dubli-klyucha"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "    k=\"${k%% *}\"\n"
assert src.count(a) == 1, "точка правки модели не найдена: усечение ключа"
ins = a + "    case \" $_VIDENNYE \" in *\" $k \"*) continue ;; esac; _VIDENNYE=\"$_VIDENNYE $k\"\n"
# init ДО цикла (арбитраж 142-impl, сопутствующая правка): без него первая
# ссылка под set -u крашит дверь unbound _VIDENNYE на любой клетке — стаб
# «ловился» артефактом краша, а не своим дефектом
w = "  while IFS='=' read -r k v || [ -n \"$k\" ]; do\n"
assert src.count(w) == 1, "точка правки модели не найдена: цикл разбора дома"
src = src.replace(w, "  _VIDENNYE=\"\"\n" + w)
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, ins))
PY
