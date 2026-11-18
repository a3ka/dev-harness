#!/usr/bin/env bash
# МУТАНТ (Н-39; v+1): честная модель ci_preflight минус ОДНА строка с маркером
# МУТАЦИЯ-122:granica-workspace — отображённый github.workspace-путь не проверяется на
# принадлежность внутренней копии: побег (..-хвост, симлинк) не отказывает vne-kopii,
# каталог realpath существует снаружи — шаг исполняется вовне и падает на run "false"
# как shag-upal (либо отказывает otsutstvuet), молчаливым зелёным побег не становится.
# Наблюдаемое расхождение (ровно эти клетки): p9-wd-dotdot-vne-kopii и p9-wd-simlink-pobeg
# (причина shag-upal/otsutstvuet вместо working-directory-vne-kopii).
# Маркер не ровно один раз — rc 2 ORACLE_TAMPERED (мутант не применён).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/ci_preflight.sh
MARK='МУТАЦИЯ-122:granica-workspace'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'ORACLE_TAMPERED: mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
bash <(grep -vF -- "$MARK" "$M") "$@"
