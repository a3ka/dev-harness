# ПРИЧИНА: неизвестный ключ репо-слой: workflowPaths.contrete
# ОКРУЖЕНИЕ: HARNESS_PROJECT_LAYER_ROOT=$WORK/layer
#
# Контракт 057 (Ч-9, M4): зелёный контроль — форма G (репо все ветви КРОМЕ
# `barriers` + слой с `defaults` → `barriers.*.origin="project"`, прочие листы
# `origin="repo"`). Красное — лишний ключ workflowPaths.contrete в репо-слое,
# P4 «неизвестный ключ репо-слой: <путь>» (замороженный блоб 054, дословно).
# P4 печатается ПОСЛЕ 057-M1: литерал `репо-слой`, не `repo`/`project`.
set -euo pipefail
LAYER="$WORK/layer"
mkdir -p "$LAYER/registry"
# Слой с полными defaults (для формы G).
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":[]}}}\n' \
  > "$LAYER/registry/harness-project.json"

# ── зелёный контроль: форма G → rc 0 ────────────────────────────────────────
G="$WORK/green/repo"; mkdir -p "$G"
# Репо — все ветви КРОМЕ `barriers`: schemaVersion, repoId, language, projectLayer,
# workflowPaths, commands, git, ci.
printf '{"schemaVersion":1,"repoId":"r1","language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$G/harness.project.json"
# С2-миграция toy-миров (арбитраж 059 п.4): объявленный CI-toy-файл `ci.yml`.
: > "$G/ci.yml"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$G"

# ── красное: лишний ключ workflowPaths.contrete → rc 1 + P4 ─────────────────
R="$WORK/red/repo"; mkdir -p "$R"
printf '{"schemaVersion":1,"repoId":"r1","language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures","contrete":"x"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$R/harness.project.json"
# С2-миграция toy-миров (арбитраж 059 п.4): P4 срабатывает раньше, но файл
# всё равно создаётся — единообразие миграции.
: > "$R/ci.yml"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$R"
