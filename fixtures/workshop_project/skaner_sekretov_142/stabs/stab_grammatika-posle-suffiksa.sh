#!/usr/bin/env bash
# СТАБ 142 (adv contracts-142-impl-v1): «грамматика после суффикса (порядок)» —
# проверка грамматики есть, но стоит ПОСЛЕ решения о суффиксе: исключение И-3
# выдаётся внутри неконформной ветви (неконформное суффиксное имя уходит в
# continue), а конформное адресное имя без маркеров больше не исключается
# (ложный отказ на законных адресных именах k19–k30). Оба дефекта наблюдаемы
# на своих входах; три строки канона и IMYA_RE сохранены байт в байт.
# Привязка к клеткам — source.json:.stab_vhod["stab_grammatika-posle-suffiksa"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a = r'''    if sekretnyj_marker "$_kt"; then :
    elif printf '%s' "$k" | grep -Eqx -- "$IMYA_RE" \
      && adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_RE"; then
      continue # параметр дома секретов: адрес/порт/имя без учётных данных; исключение И-3 — только имени грамматики IMYA_RE (adv 142-impl-v1)
    fi
'''
b = r'''    if sekretnyj_marker "$_kt"; then :
    elif ! printf '%s' "$k" | grep -Eqx -- "$IMYA_RE"; then
      if adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_RE"; then
        continue # СТАБ: грамматика «после суффикса» — исключение выдано внутри неконформной ветви
      fi
    fi
'''
assert src.count(a) == 1, "точка правки модели не найдена: предикат с грамматикой"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(a, b))
PY
