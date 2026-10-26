#!/usr/bin/env bash
# СТАБ 142: ключи с латиницей в нижнем регистре пропускаются целиком — секретный
# ключ zai_api_key перестаёт судиться (fail-open на доме секретов в нижнем регистре).
# Привязка к клеткам — source.json:.stab_vhod["stab_tolko-verhnie-imena"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = "    k=\"${k%% *}\"\n"
assert src.count(a) == 1, "точка правки модели не найдена: усечение ключа"
ins = a + "    case \"$k\" in *[a-z]*) continue ;; esac\n"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, ins))
PY
