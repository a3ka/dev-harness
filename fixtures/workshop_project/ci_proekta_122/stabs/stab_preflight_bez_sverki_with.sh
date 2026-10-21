#!/usr/bin/env bash
# МУТАНТ (Н-39; FAIL адверсария 122 impl v1, «как минимум if и with»): честная модель ci_preflight минус
# ОДНА строка с маркером МУТАЦИЯ-122:sverka-with — сверка объявленности (--contract) обходит поля
# документа, минуя поле with шага; прочие поля (run, env, if, …) сверяются, исполнение не меняется.
# Наблюдаемое расхождение: клетка p5-with-sekret-ne-perechislen (необъявленный secrets.X только в with
# uses-шага) обязана дать rc 1 sekrety-ne-perechisleny — мутант даёт rc 0 CIPREFLIGHT_OK. Клетки p5,
# p5e, p5-if-* зелены — токен там не в поле with. Маркер не ровно один раз — rc 2 (мутант не применён).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/ci_preflight.sh
MARK='МУТАЦИЯ-122:sverka-with'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
bash <(grep -vF -- "$MARK" "$M") "$@"
