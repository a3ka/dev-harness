#!/usr/bin/env bash
# МУТАНТ (Н-39; обход Б3 критика 122): честная модель ci_preflight минус ОДНА строка с маркером
# МУТАЦИЯ-122:workflow-defaults — defaults.run.working-directory читается только у джобы и шага,
# верхнеуровневый (workflow) игнорируется: наследуемый каталог подменяется корнем.
# Наблюдаемое расхождение: клетки p7-wd-workflow-otsutstvuet (отсутствующий наследуемый каталог
# обязан дать отказ с его именем) и p7-wd-workflow-est (шаг обязан исполниться В наследуемом
# каталоге). Маркер не ровно один раз — rc 2 (мутант не применён).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/ci_preflight.sh
MARK='МУТАЦИЯ-122:workflow-defaults'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
bash <(grep -vF -- "$MARK" "$M") "$@"
