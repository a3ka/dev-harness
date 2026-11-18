#!/usr/bin/env bash
# МУТАНТ (Н-39; v+1, круг Crit122V5 К-09): честная модель ci_preflight минус ОДНА строка
# с маркером МУТАЦИЯ-122:kavychki-vyrazhenija — кавычка строкового аргумента, открывшись
# внутри выражения, больше не закрывается: терминатор }} после кавычки не распознаётся,
# границы выражения не вычисляются, выражение со скобкой } в строковом аргументе функции
# (format('}', github.sha)) моделью не находится — значение env уходит шагу литералом,
# шаг зелен: МОЛЧАЛИВЫЙ УСПЕХ вместо отказа vyrazhenie-ne-podderzhano.
# Наблюдаемое расхождение (ровно эта клетка): p10-format-skobka-v-stroke
# (rc 0 CIPREFLIGHT_OK вместо rc 1 vyrazhenie-ne-podderzhano).
# Маркер не ровно один раз — rc 2 ORACLE_TAMPERED (мутант не применён).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/ci_preflight.sh
MARK='МУТАЦИЯ-122:kavychki-vyrazhenija'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'ORACLE_TAMPERED: mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
bash <(grep -vF -- "$MARK" "$M") "$@"
