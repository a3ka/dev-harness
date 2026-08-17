# ПРИЧИНА: реестр заморозок
#
# Без реестра зоны не читаются вовсе, и барьер стал бы ПУСТО-ЗЕЛЁНЫМ: «замороженных контрактов 0,
# проверять нечего». Молчаливо зелёный гейт хуже красного, потому что красному ищут причину, а
# зелёному верят. Поэтому код 1 с названной причиной и лечением, а не 2.
#
# Зелёный контроль: полное дерево → 0. Красное: shallow-клон того же дерева.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
S="$WORK/source"
make_repo "$S" 'ЗОНА agent-x: scripts/a.sh'
"$BARRIER" "$S"

GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git clone -q --depth 1 --single-branch "file://$S" "$WORK/shallow"
"$BARRIER" "$WORK/shallow"
