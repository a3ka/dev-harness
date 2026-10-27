#!/usr/bin/env bash
# СТАБ 142 (adv contracts-142-impl-v1): «проверка только на дефис» — грамматика
# имени вырождена в «конформно ⟺ нет дефиса»: имена вне грамматики БЕЗ дефиса
# (точка, пробел в первом слове, цифра первой, нелатиница, «=-подобный»
# разделитель) признаются конформными и получают исключение И-3 — утечка не
# сканируется. Канон-строка IMYA_RE сохранена байт в байт.
# Привязка к клеткам — source.json:.stab_vhod["stab_grammatika-tolko-defis"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = '''printf '%s' "$k" | grep -Eqx -- "$IMYA_RE"'''
b = '''case "$k" in *-*) false ;; *) true ;; esac'''
assert src.count(a) == 1, "точка правки модели не найдена: проверка грамматики"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, b))
PY
