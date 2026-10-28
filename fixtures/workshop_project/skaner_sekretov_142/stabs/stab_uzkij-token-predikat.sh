#!/usr/bin/env bash
# СТАБ 142 v4 (усиление по вердикту adv contracts-142-impl-v4 1/2, блокер
# B2): канон-строка USERINFO_RE остаётся в файле НЕТРОНУТОЙ (r1 зелёная —
# литерал на месте), а ИСПОЛНИМЫЙ предикат заменён отдельным узким
# USERINFO_TEST_RE '[A-Za-z0-9_-]+': токен authority с '.'/'%'/'~'
# (k117/k118 — проба адверсария) и с прочими символами канон-класса
# '!$&'()*+,;=' (k119/k120) пропускается как «адрес без учётных данных» —
# fail-open, утечка запускает workshop. Тот же узкий класс режет и
# двоеточие-ветвь: пароль с сырыми '#'/'?' (k115/k116) и пара порт+'@' в
# query/fragment (k111/k112) тоже пропускаются. R142v4-B1 (rev
# contracts-142-impl-v4): кавычка в позиции схемы и байты вне узкого
# класса (k125–k127) тоже пропускаются — привязаны k111/k112/k115/k116/
# k117–k123/k125–k127, всего 14 (Н-39, по замеру); на прочих 148 клетках
# стаб ведёт себя как честная модель — токены k99–k101/k107/k114 и
# user:pass-значения входят в узкий класс.
# Привязка к клеткам — source.json:.stab_vhod["stab_uzkij-token-predikat"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
old = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
'''
new = r'''  USERINFO_RE='(^([^/?#[:space:]]*:)?//[^/?#[:space:]]+@|[^/@[:space:]]*:[^/@[:space:]]*@)'
  # мутант B2 (adv contracts-142-impl-v4): литерал выше не исполняется —
  # рабочий предикат допускает только [A-Za-z0-9_-]+, не канон-класс
  USERINFO_TEST_RE='(^([A-Za-z0-9_-]+:)?//[A-Za-z0-9_-]+@|[A-Za-z0-9_-]*:[A-Za-z0-9_-]*@)'
'''
assert src.count(old) == 1, "точка правки модели не найдена: канон userinfo"
src = src.replace(old, new)
old2 = r'''      && adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_RE"; then'''
new2 = r'''      && adresnyj_suffiks "$_ku" && ! printf '%s' "$v" | grep -Eq -- "$USERINFO_TEST_RE"; then'''
assert src.count(old2) == 1, "точка правки модели не найдена: исполняемый grep userinfo"
open(sys.argv[2], "w", encoding="utf-8").write(src.replace(old2, new2))
PY
