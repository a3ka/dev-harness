#!/usr/bin/env bash
# СТАБ 142 (усиление по РЕШЕНИЮ арбитра contracts-142-impl-v4-arbitraz,
# Q2): канон-строка USERINFO_RE остаётся в файле НЕТРОНУТОЙ (r1 зелёная —
# литерал на месте), а ИСПОЛНИМЫЙ предикат заменён отдельным
# USERINFO_TEST_RE, где из классов user/pass ДВОЕТОЧИЕ-ветви исключён один
# байт `"` ([^/@"[:space:]]*): userinfo полного класса (k123 — U:U@host,
# `"` есть и в user, и в pass) пропускается как «адрес без учётных
# данных» — fail-open, утечка запускает workshop. Токен-ветвь не тронута:
# на k121/k122 стаб ведёт себя как честная модель.
# Привязка к клеткам — source.json:.stab_vhod["stab_dvoetochie-bez-kavychki"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
  # мутант (арбитраж 142-impl): user/pass двоеточие-ветви минус байт `"`
  USERINFO_TEST_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@"[:space:]]*:[^/@"[:space:]]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: канон userinfo"
src = src.replace(old, new)
old2 = r'''      && adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_RE"; then'''
new2 = r'''      && adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_TEST_RE"; then'''
assert src.count(old2) == 1, "точка правки модели не найдена: исполняемый grep userinfo"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old2, new2))
PY
