# ПРИЧИНА: нет файла слоя проекта
# ОКРУЖЕНИЕ: HARNESS_PROJECT_LAYER_ROOT=$WORK/layer
#
# Контракт 057 (Ч-9, M4): зелёный контроль — форма A (репо только обязательные
# + слой с полными `defaults`, вкл. `barriers`). Красное — отсутствие
# registry/harness-project.json в слое проекта (P3 «нет файла слоя проекта»).
# LAYER_ROOT в обоих прогонах указывает на $WORK/layer; подменой симлинка
# $WORK/layer → layer_ok (зелёный) или layer_bad (красный) обходим ограничение
# verify_antiplacebo: env-файл фиксирован на КЕЙС, не на вызов (механика раннера,
# контракт 006 §Предмет; смена LAYER_ROOT между прогонами внутри одного кейса
# возможна только через подмену содержимого каталога, не env).
#
# `ln -sfn` НЕ умеет замещать непустой каталог — симлинк оказывается внутри
# исходного каталога. Поэтому контент слоёв лежит в $WORK/layer_ok и
# $WORK/layer_bad, а $WORK/layer — симлинк, переключаемый перед каждым вызовом.
set -euo pipefail
LAYER_OK="$WORK/layer_ok"
LAYER_BAD="$WORK/layer_bad"
REPO="$WORK/repo"
mkdir -p "$REPO"

# Репо — только обязательные (форма A берёт остальное из defaults слоя).
printf '{"schemaVersion":1,"repoId":"r1","language":"rust","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$REPO/harness.project.json"

# ── зелёный контроль: форма A → rc 0 ────────────────────────────────────────
mkdir -p "$LAYER_OK/registry"
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":[]}}}\n' \
  > "$LAYER_OK/registry/harness-project.json"
ln -sfn "$LAYER_OK" "$WORK/layer"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$REPO"

# ── красное: пустой каталог слоя проекта (нет файла) → rc 1 + P3 ────────────
mkdir -p "$LAYER_BAD"
ln -sfn "$LAYER_BAD" "$WORK/layer"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$REPO"
