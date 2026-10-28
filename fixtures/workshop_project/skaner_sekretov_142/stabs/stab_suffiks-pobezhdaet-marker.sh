#!/usr/bin/env bash
# СТАБ 142: адресный суффикс проверяется ПЕРВЫМ и пропускает ключ безусловно —
# секретный маркер в имени (API_KEY_URL) больше не сильнее суффикса.
# Привязка к клеткам — source.json:.stab_vhod["stab_suffiks-pobezhdaet-marker"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a0 = "    _ku=$(printf '%s' \"$k\" | tr 'a-z' 'A-Z')\n"
a1 = "    fi\n    printf '%s\\n' \"$v\"\n"
assert src.count(a0) == 1 and src.count(a1) == 1, "точка правки модели не найдена: предикат 142"
i, j = src.index(a0), src.index(a1) + len(a1)
# вычисление _ku СОХРАНЕНО в замене (арбитраж 142-impl, сопутствующая
# правка): вырезанный кусок содержал его, ссылка на $_ku под set -u крашила
# дверь unbound _ku на любой клетке — стаб «ловился» артефактом краша
open(sys.argv[2], "w", encoding="utf-8").write(src[:i] + "    _ku=$(printf '%s' \"$k\" | tr 'a-z' 'A-Z')\n    adresnyj_suffiks \"$_ku\" && continue\n    printf '%s\\n' \"$v\"\n" + src[j:])
PY
