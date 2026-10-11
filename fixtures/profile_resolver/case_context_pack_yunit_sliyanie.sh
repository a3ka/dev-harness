#!/usr/bin/env bash
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
set -uo pipefail
LAYER="$WORK/layer"
mkdir -p "$LAYER/registry"
# Слой проекта: defaults.contextPack с одной строкой и путями.
printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"bash","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"true","build":"true","typecheck":"true","lint":"true"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]},"contextPack":{"rows":[{"kind":"map","path":"DEFAULTS.md","roles":"orchestrator,architect","mandatory":true,"why":"проектный дефолт"}],"adrPath":"decisions","lessonsPath":"registry/lessons-harness.tsv"}}}\n' \
  > "$LAYER/registry/harness-project.json"

# ── зелёный контроль (а): репо-rows замещают defaults-rows ЦЕЛИКОМ ─────────
G1="$WORK/green_unit/repo"; mkdir -p "$G1"
printf '{"schemaVersion":1,"repoId":"r1","language":"bash","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"true","build":"true","typecheck":"true","lint":"true"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"},"contextPack":{"rows":[{"kind":"map","path":"PROJECT.md","roles":"orchestrator,architect","mandatory":true,"why":"проектная карта"},{"kind":"rules","path":"RULES.md","roles":"implementer","mandatory":false,"why":"правила кодинга"}],"adrPath":"decisions_repo","lessonsPath":"registry/lessons.tsv"}}\n' \
  > "$G1/harness.project.json"
: > "$G1/ci.yml"
# Захват rc из БАРЬЕРа без ловушки `set -e`: на время subshell отключаем -e,
# потом возвращаем.
set +e
out="$("$BARRIER" --repo "$G1" 2>&1)"
rc=$?
set -e
[ "$rc" -eq 0 ] || { printf 'FAIL G1: ожидался rc 0, получен %s: %s\n' "$rc" "$out" >&2; exit 1; }
# ЮНИТОМ: defaults-rows (DEFAULTS.md) НЕ ДОЛЖЕН просочиться в merged.
printf '%s\n' "$out" | grep -q 'DEFAULTS.md' \
  && { printf 'FAIL G1: ЮНИТОМ нарушен — DEFAULTS.md просочился из defaults-rows\n' >&2; exit 1; }
# Репо-rows ДОЛЖНЫ присутствовать.
printf '%s\n' "$out" | grep -q 'PROJECT.md' \
  || { printf 'FAIL G1: репо-rows не слились — PROJECT.md отсутствует\n' >&2; exit 1; }
printf '%s\n' "$out" | grep -q 'RULES.md' \
  || { printf 'FAIL G1: репо-rows не слились — RULES.md отсутствует\n' >&2; exit 1; }
echo "ok: G1 — ЮНИТОМ зелёный (repo-rows замещают defaults-rows; DEFAULTS.md не просочился)"

# ── зелёный контроль (б): репо БЕЗ contextPack → defaults заполняют ────────
G2="$WORK/green_defaults/repo"; mkdir -p "$G2"
printf '{"schemaVersion":1,"repoId":"r1","language":"bash","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"true","build":"true","typecheck":"true","lint":"true"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}\n' \
  > "$G2/harness.project.json"
: > "$G2/ci.yml"
set +e
out="$("$BARRIER" --repo "$G2" 2>&1)"
rc=$?
set -e
[ "$rc" -eq 0 ] || { printf 'FAIL G2: ожидался rc 0, получен %s: %s\n' "$rc" "$out" >&2; exit 1; }
# defaults-rows ДОЛЖНЫ заполнить карту при отсутствии репо-contextPack.
printf '%s\n' "$out" | grep -q 'DEFAULTS.md' \
  || { printf 'FAIL G2: defaults-rows не заполнили карту при отсутствии репо-contextPack\n' >&2; exit 1; }
echo "ok: G2 — defaults заполнили карту (DEFAULTS.md присутствует)"

# ── красное: kind вне алфавита {map,rules,reuse} → rc 1 + P6 ───────────────
R="$WORK/red_kind/repo"; mkdir -p "$R"
printf '{"schemaVersion":1,"repoId":"r1","language":"bash","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"true","build":"true","typecheck":"true","lint":"true"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":[],"optional":[]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"},"contextPack":{"rows":[{"kind":"bogus","path":"BOGUS.md","roles":"architect","mandatory":true,"why":"неверный kind"}],"adrPath":"decisions","lessonsPath":"registry/lessons.tsv"}}\n' \
  > "$R/harness.project.json"
: > "$R/ci.yml"
set +e
out="$("$BARRIER" --repo "$R" 2>&1)"
rc=$?
set -e
[ "$rc" -ne 0 ] || { printf 'FAIL R: ожидался rc 1 (kind вне алфавита), получен rc 0: %s\n' "$out" >&2; exit 1; }
# Именованная причина P6 (контракт 057, формат: «значение вне алфавита: <путь>»).
printf '%s\n' "$out" | grep -q 'значение вне алфавита' \
  || { printf 'FAIL R: ожидалась P6 «значение вне алфавита: …», не нашли: %s\n' "$out" >&2; exit 1; }
printf '%s\n' "$out" | grep -q 'kind' \
  || { printf 'FAIL R: ожидалась P6 с упоминанием kind, не нашли: %s\n' "$out" >&2; exit 1; }
echo "ok: R — именованный отказ (kind вне алфавита, P6)"

echo "ok: case_context_pack_yunit_sliyanie — все три сценария зелёные"