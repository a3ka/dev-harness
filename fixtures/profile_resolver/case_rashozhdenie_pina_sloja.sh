# ПРИЧИНА: пин слоя проекта расходится
# ОКРУЖЕНИЕ: HARNESS_PROJECT_LAYER_ROOT=$WORK/layer
#
# Контракт 057 (Ч-9, M4): зелёный контроль — форма C (репо все ветви + слой
# БЕЗ `defaults` → все листы `origin="repo"`). Красное — расхождение
# `projectLayer.version` репо со `version` слоя проекта, P5 «пин слоя проекта
# расходится».
set -euo pipefail
LAYER="$WORK/layer"
mkdir -p "$LAYER/registry"
# Слой — БЕЗ defaults (форма C).
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1"}\n' \
  > "$LAYER/registry/harness-project.json"

# ── зелёный контроль: форма C → rc 0 ────────────────────────────────────────
G="$WORK/green/repo"; mkdir -p "$G"
# Репо — все ветви (включая barriers); слой без defaults → всё наследуется из репо.
printf '{"schemaVersion":1,"repoId":"r1","language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$G/harness.project.json"
# С2-миграция toy-миров (арбитраж 059 п.4): объявленный CI-toy-файл `ci.yml`.
: > "$G/ci.yml"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$G"

# ── красное: пин репо v9, слой v10 → rc 1 + P5 ──────────────────────────────
R="$WORK/red/repo"; mkdir -p "$R"
printf '{"schemaVersion":1,"repoId":"r1","language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v9","profilePath":"registry/harness-project.json"}}\n' \
  > "$R/harness.project.json"
# С2-миграция toy-миров (арбитраж 059 п.4): P5 срабатывает раньше, но файл
# всё равно создаётся — единообразие миграции.
: > "$R/ci.yml"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$R"
