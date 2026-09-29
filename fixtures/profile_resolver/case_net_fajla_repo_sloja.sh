# ПРИЧИНА: нет harness.project.json
# ОКРУЖЕНИЕ: HARNESS_PROJECT_LAYER_ROOT=$WORK/layer
#
# Контракт 057 (Ч-9, M4): зелёный контроль — форма M (оба слоя только
# обязательные), резолвер сливает без листьев barriers/commands. Красное —
# отсутствие harness.project.json в корне репо (P1 «нет harness.project.json»).
set -euo pipefail
LAYER="$WORK/layer"
# Каталог слоя создаём БЕЗ файла registry/harness-project.json — слой проекта
# для формы M: schemaVersion, version, projectId, workspaceId. mkdir -p
# поднимает только каталоги; файл пишем в $LAYER_OK.
LAYER_OK="$WORK/layer_ok"
mkdir -p "$LAYER_OK/registry"
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1"}\n' \
  > "$LAYER_OK/registry/harness-project.json"
ln -sfn "$LAYER_OK" "$WORK/layer"

# ── зелёный контроль: форма M (оба слоя только обязательные) → rc 0 ────────
G="$WORK/green/repo"; mkdir -p "$G"
# Репо — только обязательные ветви (без barriers, без commands и пр.).
printf '{"schemaVersion":1,"repoId":"r1","language":"rust","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$G/harness.project.json"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$G"

# ── красное: harness.project.json в репо отсутствует → rc 1 + P1 ────────────
R="$WORK/red/repo"; mkdir -p "$R"
# Явный git init не нужен — резолвер не валидирует git-состояние; достаточно пустого каталога.
rm -f "$R/harness.project.json"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$R"
