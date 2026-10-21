#!/usr/bin/env bash
# МУТАНТ (Н-39; F-2 ревьюера 122, совет С-5): честная модель gen_project_workflow минус ОДНА строка с
# маркером МУТАЦИЯ-122:bajty — --check читает workflow в текстовом режиме (universal newlines):
# CRLF и одиночный CR сводятся к LF, сравнивается текст, а не байты.
# Наблюдаемое расхождение: клетки g8-crlf-ruchnoj (CRLF во всех строках сгенерированного файла) и
# g8-cr-ruchnoj (одиночный CR вместо первого LF) обязаны дать rc 1 workflow-ruchnoj — мутант даёт rc 0
# «gen OK: check». Клетка g3 (дописанная строка) зелена — различие не только в переводах строк.
# Маркер не ровно один раз — rc 2 (мутант не применён).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/gen_project_workflow.sh
MARK='МУТАЦИЯ-122:bajty'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
bash <(grep -vF -- "$MARK" "$M") "$@"
