#!/usr/bin/env bash
# МУТАНТ (Н-39; обход Б2 критика 122): честная модель ci_preflight минус ОДНА строка с маркером
# МУТАЦИЯ-122:podstanovka — объявленность имени проверяется, но выражение secrets.X / vars.X
# уходит в bash без замены заглушкой.
# Наблюдаемое расхождение: клетка p6-sekret-podstavlyaetsya (конформный local-шаг с объявленными
# DEMO_TOKEN/DEMO_URL обязан исполниться зелёным). Маркер не ровно один раз — rc 2 (мутант не
# применён; молчаливой копии модели не бывает).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/ci_preflight.sh
MARK='МУТАЦИЯ-122:podstanovka'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
bash <(grep -vF -- "$MARK" "$M") "$@"
