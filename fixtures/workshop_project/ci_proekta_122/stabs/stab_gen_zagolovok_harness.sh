#!/usr/bin/env bash
# МУТАНТ (Н-39; критик 122 v+1 А10, совет о заголовке): честная модель gen_project_workflow минус ОДНА строка с
# маркером МУТАЦИЯ-122:zagolovok — заголовок workflow снова называет путь вспомогательного
# каталога инструмента («источник — .harness/ci.json»).
# Наблюдаемое расхождение: клетка g11-bajty-bez-ssylki (байты генератора без пути .harness/ и
# имени harness.project.json) обязана дать rc 0 — мутант даёт rc 5 «ssylka v bajtah generatora».
# Клетки g3/g4/g8 зелены — меняется только содержимое заголовка, не детерминизм.
# Маркер не ровно один раз — rc 2 (мутант не применён).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/gen_project_workflow.sh
MARK='МУТАЦИЯ-122:zagolovok'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
bash <(grep -vF -- "$MARK" "$M") "$@"
