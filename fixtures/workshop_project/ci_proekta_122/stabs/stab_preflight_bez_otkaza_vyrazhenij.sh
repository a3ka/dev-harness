#!/usr/bin/env bash
# МУТАНТ (Н-39; v+1): честная модель ci_preflight минус ОДНА строка с маркером
# МУТАЦИЯ-122:otkaz-vyrazhenij — отказ vyrazhenie-ne-podderzhano не срабатывает: выражение
# вне вычисляемого алфавита уходит в bash (bad substitution → shag-upal) либо в env
# литералом (шаг зелёный — МОЛЧАЛИВЫЙ УСПЕХ), то есть отказ по контракту не предъявлен.
# Наблюдаемое расхождение (ровно эти клетки): p10-vyrazhenie-v-run
# (shag-upal bad substitution вместо vyrazhenie-ne-podderzhano), p10-vyrazhenie-v-env и
# p10-funkcija-tojson (rc 0 — МОЛЧАЛИВЫЙ УСПЕХ: выражение в кавычках/env ушло шагу литералом —
# вместо отказа), p10-otkaz-do-ispolnenija (падает первый шаг exit 3 — shag-upal
# раньше, чем судится выражение второго).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/ci_preflight.sh
MARK='МУТАЦИЯ-122:otkaz-vyrazhenij'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'ORACLE_TAMPERED: mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
bash <(grep -vF -- "$MARK" "$M") "$@"
