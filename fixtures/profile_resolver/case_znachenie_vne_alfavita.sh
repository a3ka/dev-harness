# ПРИЧИНА: значение вне алфавита: language
# ОКРУЖЕНИЕ: HARNESS_PROJECT_LAYER_ROOT=$WORK/layer
#
# Контракт 057 (Ч-9, M4): зелёный контроль — полный профиль (репо со всеми
# ветвями + слой с полными defaults, форма C). Красное — `language=python`
# в репо-слое, P6 «значение вне алфавита: language: <тип>».
set -euo pipefail
LAYER="$WORK/layer"
mkdir -p "$LAYER/registry"
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"cargo test","build":"cargo build","typecheck":"cargo check","lint":"cargo clippy"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]}}}\n' \
  > "$LAYER/registry/harness-project.json"

# ── зелёный контроль: полный профиль → rc 0 ─────────────────────────────────
G="$WORK/green/repo"; mkdir -p "$G"
printf '{"schemaVersion":1,"repoId":"r1","language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$G/harness.project.json"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$G"

# ── красное: language=python (вне алфавита rust/typescript) → rc 1 + P6 ──────
R="$WORK/red/repo"; mkdir -p "$R"
printf '{"schemaVersion":1,"repoId":"r1","language":"python","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$R/harness.project.json"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$R"
