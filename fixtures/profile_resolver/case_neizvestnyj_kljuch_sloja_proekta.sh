# ПРИЧИНА: неизвестный ключ слой-проекта: boguskey
# ОКРУЖЕНИЕ: HARNESS_PROJECT_LAYER_ROOT=$WORK/layer
#
# Контракт 057 (Ч-9, M4): зелёный контроль — форма F (репо только обязательные
# + `barriers` + слой с `defaults` → `barriers.*.origin="repo"`,
# `commands.*.origin="project"`). Красное — лишний верхнеуровневый ключ
# `boguskey` в слое проекта, P4 «неизвестный ключ слой-проекта: <путь>».
#
# Двухслойная семантика: контент слоя лежит в $WORK/green_layer и $WORK/red_layer;
# $WORK/layer — симлинк, переключаемый ПЕРЕД каждым вызовом. Запрет на
# `mkdir -p $WORK/layer/registry`: `ln -sfn` НЕ умеет замещать непустой
# каталог, симлинк оказывается ВНУТРИ исходного каталога и контент не меняется
# (замерено 2026-09-29: первый прогон кейса получил «зелёный на обманном дереве»).
set -euo pipefail
GREEN_LAYER="$WORK/green_layer"
RED_LAYER="$WORK/red_layer"

# Зелёный слой — конформный (для формы F): полные defaults, без `boguskey`.
mkdir -p "$GREEN_LAYER/registry"
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":[]}}}\n' \
  > "$GREEN_LAYER/registry/harness-project.json"

# ── зелёный контроль: форма F → rc 0 ────────────────────────────────────────
G_REPO="$WORK/green/repo"; mkdir -p "$G_REPO"
printf '{"schemaVersion":1,"repoId":"r1","language":"rust","barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$G_REPO/harness.project.json"
ln -sfn "$GREEN_LAYER" "$WORK/layer"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$G_REPO"

# ── красное: лишний ключ boguskey в верхнем уровне слоя проекта → rc 1 + P4 ─
mkdir -p "$RED_LAYER/registry"
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","boguskey":"x","defaults":{"language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":[]}}}\n' \
  > "$RED_LAYER/registry/harness-project.json"
R_REPO="$WORK/red/repo"; mkdir -p "$R_REPO"
# Репо — конформное (только обязательные); красное — на слое.
printf '{"schemaVersion":1,"repoId":"r1","language":"rust","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$R_REPO/harness.project.json"
ln -sfn "$RED_LAYER" "$WORK/layer"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$R_REPO"
