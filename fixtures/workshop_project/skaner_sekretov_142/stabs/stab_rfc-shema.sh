#!/usr/bin/env bash
# СТАБ 142 v4 (усиление по ревью R142v4-B1, contracts-142-impl-v4 krug1
# FAIL): дословное воспроизведение мутанта ревьюера mut-rfc-shema —
# канон-строка USERINFO_RE остаётся в файле НЕТРОНУТОЙ (r1 зелёная —
# литерал на месте), а ИСПОЛНИМЫЙ предикат заменён отдельным
# USERINFO_TEST_RE, где класс СХЕМЫ токен-ветви — учебный RFC 3986
# [A-Za-z][A-Za-z0-9+.-]*: значение в кавычках X_URL="https://<tok>@host"
# (k125/k126 — кавычка в позиции схемы, конформна канону) и адрес со
# схемой из байтов канон-класса вне RFC-алфавита (k127,
# ves_shema_vne_rfc) не распознаются как userinfo — fail-open, утечка
# запускает workshop. Статическая клетка r4 видит сам подменённый
# исполняемый блок (≠ модели байт в байт). На прочих клетках стаб ведёт
# себя как честная модель: схемы https/http входов k99–k123 —
# RFC-совместимы, scheme-relative `//` (k114/k118/k120/k122) — без схемы,
# двоеточие-ветвь не тронута (k123/k124), NUL-предпроверка не тронута.
# Привязка к клеткам — source.json:.stab_vhod["stab_rfc-shema"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
  # мутант R142v4-B1 (rev contracts-142-impl-v4): литерал выше не
  # исполняется — класс СХЕМЫ токен-ветви сужен до RFC 3986
  USERINFO_TEST_RE='(^([A-Za-z][A-Za-z0-9+.-]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: канон userinfo"
src = src.replace(old, new)
old2 = r'''      && adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_RE"; then'''
new2 = r'''      && adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_TEST_RE"; then'''
assert src.count(old2) == 1, "точка правки модели не найдена: исполняемый grep userinfo"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old2, new2))
PY
