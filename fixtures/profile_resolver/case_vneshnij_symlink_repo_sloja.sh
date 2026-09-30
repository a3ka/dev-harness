# ПРИЧИНА: не symlink на внешний файл
# ОКРУЖЕНИЕ: HARNESS_PROJECT_LAYER_ROOT=$WORK/layer
#
# Контракт 057 (Ч-9, M4): зелёный контроль — внутренний JSON (harness.project.json
# физически лежит в корне репо). Красное — `<repo>/harness.project.json` —
# симлинк на ВНЕШНИЙ валидный файл, P3 «нет файла репо-слоя в корне репо» +
# инструкция «не symlink на внешний файл». Закрывает обход №9 054-фикс-раунд 5
# (адверсарий круг 3): симлинк на внешний файл проходил и merged-профиль нёс
# значения внешнего владельца.
set -euo pipefail
LAYER="$WORK/layer"
mkdir -p "$LAYER/registry"
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]}}}\n' \
  > "$LAYER/registry/harness-project.json"

# ── зелёный контроль: внутренний JSON (harness.project.json — обычный файл) ─
G="$WORK/green/repo"; mkdir -p "$G"
printf '{"schemaVersion":1,"repoId":"r1","language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$G/harness.project.json"
# С2-миграция toy-миров (арбитраж 059 п.4): объявленный CI-toy-файл `ci.yml`.
: > "$G/ci.yml"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$G"

# ── красное: симлинк harness.project.json → внешний файл → rc 1 + P3 ───────
OUTSIDE="$WORK/outside.json"
printf '{"schemaVersion":1,"repoId":"r_external","language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"ci":{"workflow":".github/workflows/ci.yml"},"git":{"canonicalRemote":"git@host:r_external.git"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}' > "$OUTSIDE"
R="$WORK/red/repo"; mkdir -p "$R"
rm -f "$R/harness.project.json"
ln -s "$OUTSIDE" "$R/harness.project.json"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$R"
