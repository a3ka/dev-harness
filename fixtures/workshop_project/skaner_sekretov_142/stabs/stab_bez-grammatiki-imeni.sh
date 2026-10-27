#!/usr/bin/env bash
# СТАБ 142 (adv contracts-142-impl-v1, блокер 1): грамматика имени не
# проверяется — текущая реализация OBJECT f7eee4ba: `FOO.URL=…`/`FOO-URL=…`
# оканчиваются на URL, проходят ветку continue, значение не сканируется
# (rc 0 при утечке). Канон-строка IMYA_RE убрана, conjunct грамматики убран —
# предикат байт в байт как у двери-как-OBJECT; три строки канона сохранены.
# Привязка к клеткам — source.json:.stab_vhod["stab_bez-grammatiki-imeni"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a1 = "  IMYA_RE='[A-Za-z_][A-Za-z0-9_]*'\n"
a2 = r'''    if sekretnyj_marker "$_kt"; then :
    elif printf '%s' "$k" | grep -Eqx -- "$IMYA_RE" \
      && adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_RE"; then
      continue # параметр дома секретов: адрес/порт/имя без учётных данных; исключение И-3 — только имени грамматики IMYA_RE (adv 142-impl-v1)
    fi
'''
b2 = '''    if sekretnyj_marker "$_kt"; then :
    elif adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_RE"; then
      continue # параметр дома секретов: адрес/порт/имя без учётных данных
    fi
'''
assert src.count(a1) == 1, "точка правки модели не найдена: канон IMYA_RE"
assert src.count(a2) == 1, "точка правки модели не найдена: предикат с грамматикой"
src = src.replace(a1, "").replace(a2, b2)
open(sys.argv[2], "w", encoding="utf-8").write(src)
PY
