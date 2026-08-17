# ПРИЧИНА: реестр заморозок
#
# На усечённой истории реестр заморозок недоступен, и барьер стал бы ПУСТО-ЗЕЛЁНЫМ: тегов нет,
# значит всё «черновики», значит проверять нечего. Молчаливо зелёный гейт хуже красного, потому
# что красному ищут причину, а зелёному верят. Поэтому код 1 с названной причиной и лечением, а
# не 2: лечится это одной строкой `fetch-depth: 0` в проводке.
#
# Зелёный контроль: полное дерево → 0. Красное: shallow-клон того же дерева.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
S="$WORK/source"
make_repo "$S"
g "$S" tag -a frozen/contracts/001/1 -m 'заморожен'
"$BARRIER" "$S"

GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git clone -q --depth 1 --single-branch "file://$S" "$WORK/shallow"
"$BARRIER" "$WORK/shallow"
