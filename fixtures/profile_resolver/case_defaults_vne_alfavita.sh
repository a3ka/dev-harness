# ПРИЧИНА: значение вне алфавита: defaults.barriers.mandatory
# ОКРУЖЕНИЕ: HARNESS_PROJECT_LAYER_ROOT=$WORK/layer
#
# Контракт 057 (Ч-9, M4): зелёный контроль — чистые defaults (форма A: репо
# только обязательные + слой с полными `defaults`). Красное — массив
# `defaults.barriers.mandatory` сломан (строка вместо массива), P6
# «значение вне алфавита: defaults.barriers.mandatory: <тип>». Закрывает
# контрмодель замещения ветви (критик 057-v1:16–33): слитое из defaults
# значение проходит ТЕ ЖЕ классы валидации, что и репо-слой (Ч-2).
#
# Двухслойная семантика: контент слоя лежит в $WORK/green_layer и $WORK/red_layer;
# $WORK/layer — симлинк, переключаемый ПЕРЕД каждым вызовом. `ln -sfn` НЕ умеет
# замещать непустой каталог — симлинк оказывается внутри (см. замер в
# case_neizvestnyj_kljuch_sloja_proekta.sh).
set -euo pipefail
GREEN_LAYER="$WORK/green_layer"
RED_LAYER="$WORK/red_layer"

mkdir -p "$GREEN_LAYER/registry"
# Слой с полными defaults, валидный (форма A берёт defaults в выход).
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"cargo test","build":"cargo build","typecheck":"cargo check","lint":"cargo clippy"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]}}}\n' \
  > "$GREEN_LAYER/registry/harness-project.json"

# ── зелёный контроль: форма A → rc 0 ────────────────────────────────────────
G_REPO="$WORK/green/repo"; mkdir -p "$G_REPO"
printf '{"schemaVersion":1,"repoId":"r1","language":"rust","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$G_REPO/harness.project.json"
# С2-миграция toy-миров (арбитраж 059 п.4): эффективный ci.workflow="ci.yml"
# наследуется из слоя (репо не объявляет); резолвер И-2(г) проверяет файл.
: > "$G_REPO/ci.yml"
ln -sfn "$GREEN_LAYER" "$WORK/layer"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$G_REPO"

# ── красное: defaults.barriers.mandatory — строка, не массив → rc 1 + P6 ───
mkdir -p "$RED_LAYER/registry"
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"cargo test","build":"cargo build","typecheck":"cargo check","lint":"cargo clippy"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":"BAD KEY!","optional":[]}}}\n' \
  > "$RED_LAYER/registry/harness-project.json"
R_REPO="$WORK/red/repo"; mkdir -p "$R_REPO"
printf '{"schemaVersion":1,"repoId":"r1","language":"rust","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$R_REPO/harness.project.json"
# С2-миграция toy-миров (арбитраж 059 п.4): красное P6 срабатывает раньше
# И-2(г), но объявленный файл всё равно создаётся — единообразие.
: > "$R_REPO/ci.yml"
ln -sfn "$RED_LAYER" "$WORK/layer"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$R_REPO"
