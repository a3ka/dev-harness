# ПРИЧИНА: контекстные ключи contextPack — ЮНИТОМ-слияние
# ОКРУЖЕНИЕ: HARNESS_PROJECT_LAYER_ROOT=$WORK/layer
#
# Контракт 095 (Решение 3, ПЕРЕСЕЧЕНИЕ-строка 054/055 дельта 095): новый
# ключ contextPack{rows,adrPath,lessonsPath} живёт В ДЕЙСТВУЮЩЕЙ схеме
# profile_resolver. Семантика слияния ЮНИТОМ (массив rows: репо-rows
# замещает defaults-rows ЦЕЛИКОМ, прецедент barriers.mandatory 054;
# скаляры adrPath/lessonsPath: репо замещает defaults). Этот case-файл
# проверяет, что profile_resolver корректно объединяет оба слоя для
# contextPack.
set -euo pipefail
LAYER="$WORK/layer"
mkdir -p "$LAYER/registry"
# Слой проекта: defaults.contextPack с одной строкой и путями.
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"bash","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"true","build":"true","typecheck":"true","lint":"true"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]},"contextPack":{"rows":[{"kind":"map","path":"DEFAULTS.md","roles":"orchestrator,architect","mandatory":true,"why":"проектный дефолт"}],"adrPath":"decisions","lessonsPath":"registry/lessons-harness.tsv"}}}\n' \
  > "$LAYER/registry/harness-project.json"

# ── зелёный контроль (а): репо-rows замещают defaults-rows ЦЕЛИКОМ ─────────
# Репо несёт contextPack.rows с ДВУМЯ строками; defaults-rows (DEFAULTS.md)
# НЕ ДОЛЖЕН просочиться в merged (ЮНИТОМ-семантика). adrPath репо
# замещает слой-проекта.
G1="$WORK/green_unit/repo"; mkdir -p "$G1"
printf '{"schemaVersion":1,"repoId":"r1","language":"bash","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"true","build":"true","typecheck":"true","lint":"true"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"},"contextPack":{"rows":[{"kind":"map","path":"PROJECT.md","roles":"orchestrator,architect","mandatory":true,"why":"проектная карта"},{"kind":"rules","path":"RULES.md","roles":"implementer","mandatory":false,"why":"правила кодинга"}],"adrPath":"decisions_repo","lessonsPath":"registry/lessons.tsv"}}\n' \
  > "$G1/harness.project.json"
: > "$G1/ci.yml"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$G1"

# ── зелёный контроль (б): репо БЕЗ contextPack → defaults заполняют ────────
G2="$WORK/green_defaults/repo"; mkdir -p "$G2"
printf '{"schemaVersion":1,"repoId":"r1","language":"bash","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"true","build":"true","typecheck":"true","lint":"true"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$G2/harness.project.json"
: > "$G2/ci.yml"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$G2"

# ── красное: kind вне алфавита {map,rules,reuse} → rc 1 + P6 ───────────────
R="$WORK/red_kind/repo"; mkdir -p "$R"
printf '{"schemaVersion":1,"repoId":"r1","language":"bash","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"true","build":"true","typecheck":"true","lint":"true"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"},"contextPack":{"rows":[{"kind":"bogus","path":"BOGUS.md","roles":"architect","mandatory":true,"why":"неверный kind"}],"adrPath":"decisions","lessonsPath":"registry/lessons.tsv"}}\n' \
  > "$R/harness.project.json"
: > "$R/ci.yml"
BARRIER_ROOT="$WORK" "$BARRIER" --repo "$R"