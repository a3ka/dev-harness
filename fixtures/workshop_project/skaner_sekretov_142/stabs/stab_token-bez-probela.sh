#!/usr/bin/env bash
# СТАБ 142 (усиление по РЕШЕНИЮ арбитра contracts-142-impl-v4-arbitraz,
# Q2, граница класса — РАСШИРЕНИЕ): канон-строка USERINFO_RE остаётся в
# файле НЕТРОНУТОЙ (r1 зелёная — литерал на месте), а ИСПОЛНИМЫЙ предикат
# заменён отдельным USERINFO_TEST_RE, где из класса токена снято
# [:space:] (→ [^/?#]+): пробельный байт в токене больше НЕ обрывает
# прогон до `@`, значение `https://tok<SP/TAB/VT/FF/CR>x@host` судится
# userinfo — адресный ключ НЕ пропускается, ложный отказ sekret-v-dereve
# на k124 (ждали сессию rc 0). Класс РАСШИРЕНИЕ, не сужение: на клетках
# k1–k123 значения канон-класса матчятся и у мутанта — стаб честен там.
# Привязка к клеткам — source.json:.stab_vhod["stab_token-bez-probela"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
  # мутант-расширение (арбитраж 142-impl): из класса токена снято [:space:]
  USERINFO_TEST_RE='(^([^/?#[:space:]]*:)?//[^/?#]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: канон userinfo"
src = src.replace(old, new)
old2 = r'''      && adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_RE"; then'''
new2 = r'''      && adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_TEST_RE"; then'''
assert src.count(old2) == 1, "точка правки модели не найдена: исполняемый grep userinfo"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old2, new2))
PY
