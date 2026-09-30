# ПРИЧИНА: файл не JSON
# ОКРУЖЕНИЕ: HARNESS_PROJECT_LAYER_ROOT=$WORK/layer
#
# Контракт 057 (Ч-9, M4): зелёный контроль — полный профиль (форма C). Красное —
# битый JSON в harness.project.json, P7 «файл не JSON: <имя файла>».
set -euo pipefail
LAYER="$WORK/layer"
mkdir -p "$LAYER/registry"
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"cargo test","build":"cargo build","typecheck":"cargo check","lint":"cargo clippy"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]}}}\n' \
  > "$LAYER/registry/harness-project.json"

# ── зелёный контроль: полный профиль → rc 0 ─────────────────────────────────
G="$WORK/green/repo"; mkdir -p "$G"
printf '{"schemaVersion":1,"repoId":"r1","language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$G/harness.project.json"
# С2-миграция toy-миров (арбитраж 059 п.4): объявленный CI-toy-файл `ci.yml`.
: > "$G/ci.yml"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$G"

# ── красное: битый JSON → rc 1 + P7 ─────────────────────────────────────────
R="$WORK/red/repo"; mkdir -p "$R"
printf '%s' '{ NOT VALID' > "$R/harness.project.json"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$R"
