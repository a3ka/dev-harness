#!/usr/bin/env bash
# СТАБ 142 (усиление по РЕШЕНИЮ арбитра contracts-142-impl-v4-arbitraz,
# Q2, минимальная форма находки B3 адверсария 2/2): канон-строка USERINFO_RE
# остаётся в файле НЕТРОНУТОЙ (r1 зелёная — литерал на месте), а ИСПОЛНИМЫЙ
# предикат заменён отдельным USERINFO_TEST_RE, где класс токена — канон
# МИНУС ОДИН байт `"` ([^/?#"[:space:]]+): токен authority с кавычкой
# (k121/k122 — T полного класса порождён раннером) пропускается как «адрес
# без учётных данных» — fail-open, утечка запускает workshop. Двоеточие-
# ветвь не тронута: на k123 стаб ведёт себя как честная модель.
# Привязка к клеткам — source.json:.stab_vhod["stab_token-bez-kavychki"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
  # мутант B3 в минимальной форме (арбитраж 142-impl): класс токена минус `"`
  USERINFO_TEST_RE='(^([^/?#[:space:]]*:)?//[^/?#"[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: канон userinfo"
src = src.replace(old, new)
old2 = r'''      && adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_RE"; then'''
new2 = r'''      && adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_TEST_RE"; then'''
assert src.count(old2) == 1, "точка правки модели не найдена: исполняемый grep userinfo"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old2, new2))
PY
