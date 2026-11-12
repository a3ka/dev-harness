#!/usr/bin/env bash
# МУТАНТ (Н-39; критик 122 v+1 А10, блок Б-1): честная модель gen_project_workflow минус ОДНА строка с
# маркером МУТАЦИЯ-122:rezolver — projectId берётся raw-разбором .harness/harness.project.json
# и слоя по projectLayer.profilePath (операция прежней модели 122), резолвер не вызывается.
# Наблюдаемое расхождение: клетки g9-oba-profilja (корневой и внутренний профиль вместе —
# резолвер отказывает P10) и g10-profil-symlink-naruzhu (внутренний профиль — symlink на файл вне R —
# отказ FD-границы) обязаны дать rc 1 profil-rashozhdenie без записи; мутант пишет workflow (rc 3).
# Клетки g5/g6 (чужой/отсутствующий профиль) зелены — raw-разбор их различает.
# Маркер не ровно один раз — rc 2 (мутант не применён).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/gen_project_workflow.sh
MARK='МУТАЦИЯ-122:rezolver'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
bash <(grep -vF -- "$MARK" "$M") "$@"
