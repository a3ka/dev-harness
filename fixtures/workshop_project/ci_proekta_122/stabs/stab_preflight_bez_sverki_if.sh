#!/usr/bin/env bash
# МУТАНТ (Н-39; FAIL адверсария 122 impl v1, п.2): честная модель ci_preflight минус ОДНА строка с
# маркером МУТАЦИЯ-122:sverka-if — сверка объявленности (--contract) обходит поля документа, минуя
# поле if (шага и джобы); прочие поля (run, env, with, …) сверяются, исполнение не меняется.
# Наблюдаемое расхождение: клетки p5-if-shag-sekret-ne-perechislen (необъявленный secrets.X только в
# if шага) и p5-if-dzhoba-var-ne-perechislena (необъявленный vars.X только в if джобы) обязаны дать
# rc 1 sekrety-ne-perechisleny — мутант даёт rc 0 CIPREFLIGHT_OK. Клетки p5, p5e, p5-with-* зелены —
# токен там не в поле if. Маркер не ровно один раз — rc 2 (мутант не применён).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/ci_preflight.sh
MARK='МУТАЦИЯ-122:sverka-if'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
bash <(grep -vF -- "$MARK" "$M") "$@"
