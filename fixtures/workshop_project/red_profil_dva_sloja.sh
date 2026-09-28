#!/usr/bin/env bash
# 054-БАТАРЕЯ — workshop_project (контракт 054, М1+М2+М3).
#
# Переносная форма (прецедент 045: перенос red_gitw_obmen.sh → fixtures/gitw/,
# 9c37233). До-заморозочный адрес — fixtures/check_judge_gate/
# red_profil_dva_sloja_054.sh (зона architect); семейный дом —
# fixtures/workshop_project/ + раннер fixtures/_krasnye_054.sh.
#
# Структура:
#   1. СТАБ-ПАК (9 ручек обмана) — зелёный ДО и ПОСЛЕ реализации: каждый
#      обманный стаб умирает на СВОЕЙ клетке (привязка по коду, Н-39).
#   2. ЧЕСТНАЯ ЧАСТЬ (к1-к14) — красная ДО реализации (г0: предмет отсутствует),
#      зелёная ПОСЛЕ.
#
# Прогон: bash red_profil_dva_sloja.sh [корень worktree]
#   rc 0 — стаб-пак пойман И честные клетки зелёные.
#   rc 1 — расхождение.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# Корневой путь worktree: $1 (если --probe == ДОСЛОВНЫЙ корень worktree) или
# авто из расположения батареи. По умолчанию — `..` (parent of fixtures/).
ROOT="${1:-$(cd "$HERE/../.." && pwd -P)}"
PROFILE_RESOLVER="${PROFILE_RESOLVER:-$ROOT/scripts/profile_resolver.sh}"
WORKSHOP="${WORKSHOP:-$ROOT/workshop}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
[ -f "$ROOT/AGENTS.md" ] || { printf 'ОТКАЗ: нет AGENTS.md мастерской: %s\n' "$ROOT" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { printf 'ОТКАЗ: нет git\n' >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { printf 'ОТКАЗ: нет jq\n' >&2; exit 1; }

die_pack() { printf '054-батарея ОТКАЗ: %s\n' "$*" >&2; exit 1; }

HDR='## Правила, каждое из которых уже стоило времени'
TOY_HDR='## Правила проекта Odelix-toy'

# ── строители toy-мира ────────────────────────────────────────────────────────
layer_make() {
  mkdir -p "$1/registry"
  printf '{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"cargo test","build":"cargo build","typecheck":"cargo check","lint":"cargo clippy"},"git":{"canonicalRemote":"git@host:p1.git"},"ci":{"workflow":".github/workflows/ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":[]}}}' > "$1/registry/harness-project.json"
}
repo_make() {
  local r="$1" lang="$2" with_pin="${3:-1}" with_env="${4:-1}" pin="${5:-v10}"
  mkdir -p "$r/config"
  git -C "$r" init -q
  git -C "$r" config receive.denyCurrentBranch refuse
  printf '{"schemaVersion":1,"repoId":"r1","language":"%s","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"ci":{"workflow":".github/workflows/ci.yml"},"git":{"canonicalRemote":"git@host:r1.git"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}' "$lang" > "$r/harness.project.json"
  [ "$with_pin" = 1 ] && printf '{"version":"%s"}\n' "$pin" > "$r/config/harness_pin.json"
  [ "$with_env" = 1 ] && printf 'METERING_PROXY_URL=http://toy.invalid:1\n' > "$r/.env"
  printf '# Toy project AGENTS\n\n%s\n\nПравило toy-репо: не подмешиваться в системный промпт.\n' "$TOY_HDR" > "$r/AGENTS.md"
}
section_of() {
  awk -v h="$HDR" '$0 == h {f = 1; print; next} f && /^## / {exit} f {print}' "$1"
}

# ── обманные стабы (один скелет на тип, обман ручкой env STUB_*) ──────────────
stub_workshop() {
  cat > "$1" <<'STUB'
#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ лаунчера 054 — выглядит как режим проекта; обманывает
# ровно одной ручкой (STUB_*). Реализацией НЕ является.
set -uo pipefail
repo="${2:-}"
prompt="$TMP_STUB_HOME/prompt.md"
mkdir -p "$TMP_STUB_HOME"
# b5: STUB_GLOBAL_OK — читаем `--get` вместо `--local`, глобальный
# receive.denyCurrentBranch=refuse из HOME/.gitconfig удовлетворяет.
# b8: STUB_GITDIR_OK — НЕ санируем GIT_DIR/GIT_WORK_TREE/GIT_INDEX_FILE/
# GIT_COMMON_DIR перед `git config --local --get`. Это имитирует обход
# 054-фикс-раунд 4, круг 2: унаследованный GIT_DIR редиректит локальную
# настройку в чужой git-dir, и bare-репо с `receive.denyCurrentBranch=refuse`
# проходит проверку.
if [ -n "${STUB_GITDIR_OK:-}" ]; then
  v="$(git -C "$repo" config --local --get receive.denyCurrentBranch 2>/dev/null || true)"
elif [ -n "${STUB_GLOBAL_OK:-}" ]; then
  v="$(git -C "$repo" config --get receive.denyCurrentBranch 2>/dev/null || true)"
else
  # ЧЕСТНЫЙ workshop санирует GIT_* env и принудительно указывает --git-dir.
  v="$(git --git-dir="$repo/.git" -C "$repo" config --local --get receive.denyCurrentBranch 2>/dev/null || true)"
fi
if [ -n "${STUB_DENY_NONEMPTY:-}" ]; then
  [ -n "$v" ] || { printf "workshop ОТКАЗ: receive.denyCurrentBranch='' в %s, ожидается 'refuse'. Исправление: git -C %s config receive.denyCurrentBranch refuse\n" "$repo" "$repo" >&2; exit 1; }
else
  [ "$v" = "refuse" ] || { printf "workshop ОТКАЗ: receive.denyCurrentBranch='%s' в %s, ожидается 'refuse'. Исправление: git -C %s config receive.denyCurrentBranch refuse\n" "$v" "$repo" "$repo" >&2; exit 1; }
fi
[ -z "${STUB_SKIP_ENV:-}" ] && { [ -f "$repo/.env" ] || { printf 'profile ОТКАЗ: нет .env проекта: %s/.env. Инструкция: создайте .env в корне репо — METERING_PROXY_URL=<адрес прокси учёта проекта>\n' "$repo" >&2; exit 1; }; }
# STUB_SKIP_PIN (k13) — пропустить проверку наличия пина.
# STUB_ACCEPT_NUMERIC_PIN (b6) — принять любое значение version (включая число).
if [ -z "${STUB_SKIP_PIN:-}" ]; then
  [ -f "$repo/config/harness_pin.json" ] || { printf 'profile ОТКАЗ: нет пина версии omp: %s/config/harness_pin.json. Инструкция: создайте config/harness_pin.json в корне репо — {"version": "<версия omp>"}\n' "$repo" >&2; exit 1; }
  if [ -z "${STUB_ACCEPT_NUMERIC_PIN:-}" ]; then
    pt="$(jq -r '.version | type' "$repo/config/harness_pin.json" 2>/dev/null || echo null)"
    [ "$pt" = "string" ] || { printf 'profile ОТКАЗ: значение вне алфавита: version: <%s>\n' "$pt" >&2; exit 1; }
    [ -n "$(jq -r '.version // empty' "$repo/config/harness_pin.json")" ] || { printf 'profile ОТКАЗ: значение вне алфавита: version: пусто\n' >&2; exit 1; }
  fi
fi
[ -f "$repo/harness.project.json" ] || { [ -n "${STUB_AUTOCREATE:-}" ] || { printf 'profile ОТКАЗ: нет harness.project.json: %s/harness.project.json. Инструкция: создайте harness.project.json в корне репо — состав ключей: scripts/profile_resolver.sh\n' "$repo" >&2; exit 1; }
  printf '{"schemaVersion":1,"repoId":"stub","language":"typescript"}\n' > "$repo/harness.project.json"; }
node "$HARNESS_ROOT/scripts/gen-harness.ts" --prompt orchestrator > "$prompt" 2>/dev/null || { printf 'ОТКАЗ: gen-harness --prompt\n' >&2; exit 1; }
printf '\n' >> "$prompt"
if [ -n "${STUB_VIVISKA:-}" ]; then
  printf '%s\n' "$RULES_HDR" >> "$prompt"
else
  # b4: STUB_HEADER_ONLY_OK — печатаем ТОЛЬКО заголовок, без тела.
  if [ -n "${STUB_HEADER_ONLY_OK:-}" ]; then
    printf '%s\n' "$RULES_HDR" >> "$prompt"
  else
    awk -v h="$RULES_HDR" '$0 == h {f = 1; print; next} f && /^## / {exit} f {print}' "$HARNESS_ROOT/AGENTS.md" >> "$prompt"
  fi
fi
[ -n "${STUB_PODMESHENIE:-}" ] && cat "$repo/AGENTS.md" >> "$prompt"
printf 'workshop PROBE OK: %s\n' "$repo"
printf 'PROMPT: %s\n' "$prompt"
exit 0
STUB
  chmod +x "$1"
}
stub_resolver() {
  cat > "$1" <<'STUB'
#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ резолвера 054: без ручек честен на к4/к6/к9; одна ручка обманывает.
set -uo pipefail
repo="${3:-${2:-}}"
[ -n "$repo" ] || { printf 'profile ОТКАЗ: --repo пуст\n' >&2; exit 1; }
[ -f "$repo/harness.project.json" ] || { printf 'profile ОТКАЗ: нет harness.project.json: %s/harness.project.json. Инструкция: создайте harness.project.json в корне репо — состав ключей: scripts/profile_resolver.sh\n' "$repo" >&2; exit 1; }
# b9: STUB_REPO_SYMLINK_OK — не канонизируем harness.project.json относительно
# корня репо; симлинк на внешний файл проходит. Имитирует обход 054-фикс-раунд 5:
# адверсарий круг 3 нашёл, что `[ -f ]` следует по симлинке, и merged-профиль
# нёс значения внешнего владельца. Честный резолвер после раунда 5 канонизирует
# REPO_JSON через readlink -f и требует, чтобы цель лежала под каноническим
# REPO_ABS. Стаб отключает ровно ЭТУ проверку, оставляя всё остальное честным.
if [ -z "${STUB_REPO_SYMLINK_OK:-}" ]; then
  ra="$(cd "$repo" && pwd -P)"
  rja="$(readlink -f -- "$repo/harness.project.json" 2>/dev/null || true)"
  case "$rja" in
    "$ra"/*) ;;
    *) printf 'profile ОТКАЗ: нет файла репо-слоя в корне репо: %s/harness.project.json. Инструкция: harness.project.json должен лежать в корне репо — не symlink на внешний файл\n' "$repo" >&2; exit 1 ;;
  esac
fi
[ -n "${HARNESS_PROJECT_LAYER_ROOT:-}" ] || { printf 'profile ОТКАЗ: корень слоя проекта не задан/недоступен. Инструкция: export HARNESS_PROJECT_LAYER_ROOT=<корень клона слоя проекта (odelix-stack)>\n' >&2; exit 1; }
# b3: STUB_TRAVERSAL_OK — не канонизируем путь, ../escaped.json проходит.
if [ -z "${STUB_TRAVERSAL_OK:-}" ]; then
  pp="$(jq -r '.projectLayer.profilePath // "registry/harness-project.json"' "$repo/harness.project.json")"
  case "$pp" in /*) printf 'profile ОТКАЗ: profilePath обязан быть относительным, не абсолютным: %s\n' "$pp" >&2; exit 1 ;; esac
  lj="$(readlink -f "${HARNESS_PROJECT_LAYER_ROOT%/}/${pp#./}" 2>/dev/null || true)"
  la="$(cd "${HARNESS_PROJECT_LAYER_ROOT%/}" && pwd -P)"
  case "$lj" in "$la"/*) ;; *) printf 'profile ОТКАЗ: корень слоя проекта не задан/недоступен. Инструкция: export HARNESS_PROJECT_LAYER_ROOT=<корень клона слоя проекта (odelix-stack)>\n' >&2; exit 1 ;; esac
fi
[ -f "${HARNESS_PROJECT_LAYER_ROOT%/}/registry/harness-project.json" ] || { printf 'profile ОТКАЗ: нет файла слоя проекта: %s/registry/harness-project.json\n' "${HARNESS_PROJECT_LAYER_ROOT%/}" >&2; exit 1; }
unknown="$(jq -r '.workflowPaths // {} | keys[] | select(. != "contracts" and . != "verdicts" and . != "registry" and . != "fixtures")' "$repo/harness.project.json" | head -n 1)"
if [ -n "$unknown" ]; then
  [ -n "${STUB_IGNORE_UNKNOWN:-}" ] || { printf 'profile ОТКАЗ: неизвестный ключ репо-слой: workflowPaths.%s\n' "$unknown" >&2; exit 1; }
fi
# b1: STUB_DEFAULTS_SCAN_SHALLOW — не сканируем вложенные defaults.*
if [ -z "${STUB_DEFAULTS_SCAN_SHALLOW:-}" ]; then
  du="$(jq -r '.defaults.workflowPaths // {} | keys[] | select(. != "contracts" and . != "verdicts" and . != "registry" and . != "fixtures")' "${HARNESS_PROJECT_LAYER_ROOT%/}/registry/harness-project.json" 2>/dev/null | head -n 1)"
  if [ -n "$du" ]; then
    printf 'profile ОТКАЗ: неизвестный ключ project: defaults.workflowPaths.%s\n' "$du" >&2; exit 1
  fi
fi
if [ -z "${STUB_IGNORE_PIN:-}" ]; then
  rp="$(jq -r '.projectLayer.version' "$repo/harness.project.json")"
  pv="$(jq -r '.version' "${HARNESS_PROJECT_LAYER_ROOT%/}/registry/harness-project.json")"
  [ "$rp" = "$pv" ] || { printf "profile ОТКАЗ: пин слоя проекта расходится: репо пинит '%s', слой несёт '%s'\n" "$rp" "$pv" >&2; exit 1; }
fi
# b2: STUB_ACCEPT_EMPTY_CMD — не проверяем пустоту commands.*
if [ -z "${STUB_ACCEPT_EMPTY_CMD:-}" ]; then
  jq -e '.commands | type == "object"' "$repo/harness.project.json" >/dev/null 2>&1 || true
  for f in test build typecheck lint; do
    if jq -e --arg f "$f" '.commands | type == "object" and has($f)' "$repo/harness.project.json" >/dev/null 2>&1; then
      v="$(jq -r --arg f "$f" '.commands[$f] | if type == "string" and length > 0 then . else empty end' "$repo/harness.project.json")"
      [ -n "$v" ] || { printf 'profile ОТКАЗ: значение вне алфавита: commands.%s: пусто\n' "$f" >&2; exit 1; }
    fi
  done
fi
# b7: STUB_ACCEPT_NON_STRING — НЕ делаем type-gate для строковых полей и для
# barriers.mandatory/optional. Число/boolean/null/array для `projectId`/
# `workspaceId`/`version`/`projectLayer.version`/`projectLayer.profilePath`/
# `repoId`/`ci.workflow`/`canonicalRemote` проходит, и массив для barriers.*
# не проверяется. Имитация обхода 054-фикс-раунд 4, круг 2: резолвер
# принимает нестроковые JSON-значения.
if [ -z "${STUB_ACCEPT_NON_STRING:-}" ]; then
  # type-gate для строковых полей репо
  for fld in repoId; do
    ft="$(jq -r --arg f "$fld" 'if has($f) then (.[$f] | type) else "missing" end' "$repo/harness.project.json")"
    [ "$ft" = "string" ] || { printf 'profile ОТКАЗ: значение вне алфавита: %s: <%s>\n' "$fld" "$ft" >&2; exit 1; }
  done
  # type-gate для строковых полей слоя проекта
  for fld in version projectId workspaceId; do
    ft="$(jq -r --arg f "$fld" 'if has($f) then (.[$f] | type) else "missing" end' "${HARNESS_PROJECT_LAYER_ROOT%/}/registry/harness-project.json")"
    [ "$ft" = "string" ] || { printf 'profile ОТКАЗ: значение вне алфавита: %s: <%s>\n' "$fld" "$ft" >&2; exit 1; }
  done
  # type-gate для ci.workflow / git.canonicalRemote
  if jq -e '.ci | type == "object"' "$repo/harness.project.json" >/dev/null 2>&1; then
    cw_type="$(jq -r '.ci.workflow | type' "$repo/harness.project.json")"
    [ "$cw_type" = "string" ] || { printf 'profile ОТКАЗ: значение вне алфавита: ci.workflow: <%s>\n' "$cw_type" >&2; exit 1; }
  fi
  if jq -e '.git | type == "object"' "$repo/harness.project.json" >/dev/null 2>&1; then
    cr_type="$(jq -r '.git.canonicalRemote | type' "$repo/harness.project.json")"
    [ "$cr_type" = "string" ] || { printf 'profile ОТКАЗ: значение вне алфавита: canonicalRemote: <%s>\n' "$cr_type" >&2; exit 1; }
  fi
  # type-gate для projectLayer.version / projectLayer.profilePath
  pl_v_type="$(jq -r '.projectLayer.version | type' "$repo/harness.project.json")"
  [ "$pl_v_type" = "string" ] || { printf 'profile ОТКАЗ: значение вне алфавита: projectLayer.version: <%s>\n' "$pl_v_type" >&2; exit 1; }
  pl_p_type="$(jq -r '.projectLayer.profilePath | type' "$repo/harness.project.json")"
  [ "$pl_p_type" = "string" ] || { printf 'profile ОТКАЗ: значение вне алфавита: projectLayer.profilePath: <%s>\n' "$pl_p_type" >&2; exit 1; }
  # type-gate для schemaVersion (число, не строка)
  for f in repo_schema project_schema; do
    case "$f" in
      repo_schema) src="$repo/harness.project.json" ;;
      project_schema) src="${HARNESS_PROJECT_LAYER_ROOT%/}/registry/harness-project.json" ;;
    esac
    st="$(jq -r '.schemaVersion | type' "$src")"
    [ "$st" = "number" ] || { printf 'profile ОТКАЗ: значение вне алфавита: schemaVersion: <%s>\n' "$st" >&2; exit 1; }
  done
  # type-gate для barriers.mandatory / barriers.optional (должен быть массив)
  for path in barriers.mandatory barriers.optional defaults.barriers.mandatory defaults.barriers.optional; do
    if jq -e --arg p "$path" 'getpath($p | split(".")) | type' "$repo/harness.project.json" >/dev/null 2>&1 \
       || jq -e --arg p "$path" 'getpath($p | split(".")) | type' "${HARNESS_PROJECT_LAYER_ROOT%/}/registry/harness-project.json" >/dev/null 2>&1; then
      file="$repo/harness.project.json"
      [[ "$path" == defaults.* ]] && file="${HARNESS_PROJECT_LAYER_ROOT%/}/registry/harness-project.json"
      bt="$(jq -r --arg p "$path" 'getpath($p | split(".")) | type' "$file")"
      [ "$bt" = "array" ] || { printf 'profile ОТКАЗ: значение вне алфавита: %s: <%s>\n' "$path" "$bt" >&2; exit 1; }
    fi
  done
fi
lang="$(jq -r '.language // empty' "$repo/harness.project.json")"
[ -n "$lang" ] || lang="$(jq -r '.defaults.language // empty' "${HARNESS_PROJECT_LAYER_ROOT%/}/registry/harness-project.json")"
if [ -n "${STUB_ORIGIN_PROJECT:-}" ]; then o='project'; else o='repo'; fi
jq -cn --arg l "$lang" --arg o "$o" '{language: {value: $l, origin: $o}, projectId: {value: "p1", origin: "project"}, repoId: {value: "r1", origin: "repo"}}'
exit 0
STUB
  chmod +x "$1"
}

# b4: обманный стаб для gen-harness.ts — без ручки честен, с ручкой
# STUB_HEADER_ONLY_OK — печатает ТОЛЬКО заголовок секции (без тела) и
# считает это валидным. Используется в паке на клетке b4 — честный
# gen-harness.ts упадёт на header-only с G1, а стаб пройдёт, и пак его
# поймает.
stub_gen_harness() {
  cat > "$1" <<'STUB'
#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ gen-harness.ts --agents-rules: с ручкой печатает только
# заголовок секции (имитирует обход №4 «вывеска без тела»).
set -uo pipefail
if [ "${1:-}" = "--agents-rules" ]; then
  f="${2:-}"
  [ -f "$f" ] || { printf 'NOT_IMPLEMENTED: файла нет: %s\n' "$f" >&2; exit 2; }
  if [ -n "${STUB_HEADER_ONLY_OK:-}" ]; then
    awk -v h='## Правила, каждое из которых уже стоило времени' '$0 == h {print; exit}' "$f"
    exit 0
  fi
fi
exec node "$ROOT/scripts/gen-harness.ts" "$@"
STUB
  chmod +x "$1"
}

# ── клетки-предикаты ─────────────────────────────────────────────────────────
# 0 — испытуемый проходит клетку; 1 — пойман.
cell_k2() { # workshop: нет профиля → P1, файл НЕ создан (САМ-СОЗДАЁТ)
  local r="$WORK/k2-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10; rm -f "$r/harness.project.json"
  out="$(bash "$1" --probe "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'profile ОТКАЗ: нет harness.project.json:' <<<"$out" && [ ! -f "$r/harness.project.json" ]; } && return 0
  return 1
}
cell_k3() { # resolver: layer root пуст → P2
  local r="$WORK/k3-repo" out rc
  rm -rf "$r"; repo_make "$r" rust 1 1 v10
  out="$(env -u HARNESS_PROJECT_LAYER_ROOT bash "$1" --repo "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'корень слоя проекта не задан/недоступен' <<<"$out"; } && return 0
  return 1
}
cell_k3b() { # resolver: layer dir без файла → P3
  local r="$WORK/k3b-repo" out rc
  rm -rf "$r"; repo_make "$r" rust 1 1 v10; mkdir -p "$WORK/empty-layer"
  out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/empty-layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'нет файла слоя проекта:' <<<"$out"; } && return 0
  return 1
}
cell_k4() { # resolver: workflowPaths.contrete → P4 (ГЛУХОЙ-АЛФАВИТ)
  local r="$WORK/k4-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10
  jq '.workflowPaths.contrete = "x"' "$r/harness.project.json" > "$r/_n" && mv "$r/_n" "$r/harness.project.json"
  out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'неизвестный ключ' <<<"$out" && grep -qF 'workflowPaths.contrete' <<<"$out"; } && return 0
  return 1
}
cell_k4b() { # resolver: лишний ключ слоя проекта → P4
  local r="$WORK/k4b-repo" layer="$WORK/k4b-layer" out rc
  rm -rf "$r" "$layer"; repo_make "$r" rust 1 1 v10
  layer_make "$layer"
  jq '.boguskey = "x"' "$layer/registry/harness-project.json" > "$layer/_n" && mv "$layer/_n" "$layer/registry/harness-project.json"
  out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'неизвестный ключ' <<<"$out" && grep -qF 'boguskey' <<<"$out"; } && return 0
  return 1
}
cell_k5() { # resolver: language python → P6
  local r="$WORK/k5-repo" out rc
  rm -rf "$r"; repo_make "$r" rust 1 1 v10
  jq '.language = "python"' "$r/harness.project.json" > "$r/_n" && mv "$r/_n" "$r/harness.project.json"
  out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'значение вне алфавита: language:' <<<"$out"; } && return 0
  return 1
}
cell_k6() { # resolver: пин v9 vs v10 → P5 (ПИН-МОЛЧА)
  local r="$WORK/k6-repo" out rc
  rm -rf "$r"; repo_make "$r" rust 1 1 v10
  jq '.projectLayer.version = "v9"' "$r/harness.project.json" > "$r/_n" && mv "$r/_n" "$r/harness.project.json"
  out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'пин слоя проекта расходится' <<<"$out" && grep -qF "v9" <<<"$out" && grep -qF "v10" <<<"$out"; } && return 0
  return 1
}
cell_k7a() { # workshop: denyCurrentBranch не выставлен → W2
  local r="$WORK/k7a-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10
  git -C "$r" config --unset receive.denyCurrentBranch
  out="$(bash "$1" --probe "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "receive.denyCurrentBranch=" <<<"$out" && grep -qF "ожидается 'refuse'" <<<"$out" && grep -qF 'Исправление: git -C' <<<"$out"; } && return 0
  return 1
}
cell_k7b() { # workshop: updateInstead → W2 со значением
  local r="$WORK/k7b-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10
  git -C "$r" config receive.denyCurrentBranch updateInstead
  out="$(bash "$1" --probe "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "receive.denyCurrentBranch='updateInstead'" <<<"$out" && grep -qF 'ожидается' <<<"$out"; } && return 0
  return 1
}
cell_k7c() { # workshop: refuse → PROBE OK (POSITIVE контроль, отличается от к7a)
  local r="$WORK/k7c-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10
  out="$(bash "$1" --probe "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 0 ] && grep -qF "workshop PROBE OK:" <<<"$out"; } && return 0
  return 1
}
cell_k8() { # workshop: роли ЗАТЕМ правила ЦЕЛИКОМ (побайтово), без AGENTS репо
  local r="$WORK/k8-repo" out rc pmode first_role_line hdr_line
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10
  section_of "$ROOT/AGENTS.md" > "$WORK/k8-expected.section"
  first_role_line="$(node "$ROOT/scripts/gen-harness.ts" --prompt orchestrator 2>/dev/null | sed -n '/./{p;q}')"
  [ -s "$WORK/k8-expected.section" ] && grep -qFx "$HDR" "$WORK/k8-expected.section" || return 1
  [ -n "$first_role_line" ] || return 1
  out="$(bash "$1" --probe "$r" 2>&1)"; rc=$?
  pmode="$(grep -F 'PROMPT: ' <<<"$out" | sed 's/^PROMPT: //')"
  { [ "$rc" -eq 0 ] && [ -n "$pmode" ] && [ -f "$pmode" ]; } || return 1
  grep -qFx "$HDR" "$pmode" || return 1
  awk -v h="$HDR" '$0 == h {f = 1; next} f && /^## / {exit} f {print}' "$pmode" > "$WORK/k8-actual.body"
  awk 'NR > 1' "$WORK/k8-expected.section" > "$WORK/k8-expected.body"
  cmp -s "$WORK/k8-actual.body" "$WORK/k8-expected.body" || return 1
  hdr_line="$(grep -nFx "$HDR" "$pmode" | head -1 | cut -d: -f1)"
  [ "$(grep -nF -- "$first_role_line" "$pmode" | head -1 | cut -d: -f1)" -lt "$hdr_line" ] || return 1
  grep -qFx "$TOY_HDR" "$pmode" && return 1
  return 0
}
cell_k9() { # resolver: defaults.language переопределён репо → language.origin=repo
  local r="$WORK/k9-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10
  out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] || return 1
  [ "$(jq -r '.language.value' <<<"$out")" = "typescript" ] || return 1
  [ "$(jq -r '.language.origin' <<<"$out")" = "repo" ] || return 1
  [ "$(jq -r '.projectId.origin' <<<"$out")" = "project" ] || return 1
  return 0
}
cell_k10() { # gen-harness --agents-rules: файл без заголовка → G1
  printf '%s\n' '# hdr' '## Other' 'stuff' > "$WORK/no-rules.md"
  local out rc
  rc=0; out=$(node "$ROOT/scripts/gen-harness.ts" --agents-rules "$WORK/no-rules.md" 2>&1) || rc=$?
  if [ "$rc" -eq 1 ]; then
    # Используем -q без -F: -F ловит особый случай якорей в bash 5 с
    # двухбайтными UTF-8 после -uo pipefail; -q alone гарантированно находит
    # подстроку и не выдаёт rc=1 на ложноотрицательном разборе.
    printf '%s' "$out" | grep -q 'секции правил нет'
  else
    return 1
  fi
}
cell_k10b() { # gen-harness --agents-rules: несуществующий файл → NOT_IMPLEMENTED
  local out rc
  rc=0; out=$(node "$ROOT/scripts/gen-harness.ts" --agents-rules /no/such/file 2>&1) || rc=$?
  if [ "$rc" -eq 2 ]; then
    printf '%s' "$out" | grep -q 'NOT_IMPLEMENTED: файла нет'
  else
    return 1
  fi
}
cell_k11() { # resolver: битый JSON → P7
  local r="$WORK/k11-repo" out rc
  rm -rf "$r"; repo_make "$r" rust 1 1 v10
  printf '%s' '{ NOT VALID' > "$r/harness.project.json"
  out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'файл не JSON:' <<<"$out" && grep -qF 'harness.project.json' <<<"$out"; } && return 0
  return 1
}
cell_k12() { # workshop: нет .env (окружение экспортировано!) → P8
  local r="$WORK/k12-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 0 v10
  out="$(METERING_PROXY_URL=http://exported.invalid:1 bash "$1" --probe "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'нет .env проекта:' <<<"$out" && grep -qF 'Инструкция: создайте .env в корне репо' <<<"$out"; } && return 0
  return 1
}
cell_k13() { # workshop: нет config/harness_pin.json → P9 (МЯГКИЙ-ПИН)
  local r="$WORK/k13-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10; rm -f "$r/config/harness_pin.json"
  out="$(bash "$1" --probe "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'нет пина версии omp:' <<<"$out" && grep -qF '{"version": "<версия omp>"}' <<<"$out"; } && return 0
  return 1
}
cell_k1() { # workshop PROBE OK на rust и typescript
  local lang r out rc pmode
  for lang in rust typescript; do
    r="$WORK/honest-$lang"
    rm -rf "$r"; repo_make "$r" "$lang" 1 1 v10
    out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$1" --probe "$r" 2>&1)"; rc=$?
    pmode="$(grep -F 'PROMPT: ' <<<"$out" | sed 's/^PROMPT: //')"
    { [ "$rc" -eq 0 ] && grep -qF "workshop PROBE OK: $r" <<<"$out" && [ -n "$pmode" ] && [ -f "$pmode" ]; } || return 1
  done
  return 0
}
cell_g0() { # г0: предмет отсутствует — FAIL-FAST на отсутствии скрипта
  if [ ! -f "$ROOT/scripts/profile_resolver.sh" ]; then
    printf 'ОТКАЗ: предмет отсутствует: %s/scripts/profile_resolver.sh\n' "$ROOT" >&2
    return 1
  fi
  return 0
}

# ── КЛЕТКИ ОБХОДОВ (054-фикс-раунд 3) ──────────────────────────────────────
# Каждая клетка — воспроизведение обхода, найденного адверсарием в
# verdicts/adversary/contracts-054-v1.md. Честная реализация должна
# отказать с ИМЕНОВАННОЙ фразой; обманный стаб (соответствующая ручка в
# stub_workshop/stub_resolver) — пройти клетку, и тогда стаб-пак его
# убивает на этой клетке как СТАБ ВЫЖИЛ.

cell_b1() { # nested-defaults-unknown: ключ вне алфавита в defaults.workflowPaths.*
  local layer="$WORK/b1-layer" r="$WORK/b1-repo" out rc
  rm -rf "$layer" "$r"; mkdir -p "$layer/registry"
  cat > "$layer/registry/harness-project.json" <<EOF
{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"typescript","workflowPaths":{"contracts":"contracts","unseen":"BOGUS"}}}
EOF
  repo_make "$r" typescript 1 1 v10
  out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'неизвестный ключ project: defaults.workflowPaths.unseen' <<<"$out"; } && return 0
  return 1
}
cell_b2() { # empty-command-value: commands.test: "" принимался как валидная строка
  local r="$WORK/b2-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10
  jq '.commands.test = ""' "$r/harness.project.json" > "$r/_n" && mv "$r/_n" "$r/harness.project.json"
  out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'значение вне алфавита: commands.test: пусто' <<<"$out"; } && return 0
  return 1
}
cell_b3() { # profile-path-traversal: ../escaped.json уходил за корень слоя
  local r="$WORK/b3-repo" layer="$WORK/b3-layer" sibling="$WORK/b3-sibling.json" out rc
  rm -rf "$r" "$layer"; mkdir -p "$layer/registry"
  layer_make "$layer"
  cat > "$sibling" <<EOF
{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1"}
EOF
  repo_make "$r" typescript 1 1 v10
  jq --arg sib "../b3-sibling.json" '.projectLayer.profilePath = $sib' "$r/harness.project.json" > "$r/_n" && mv "$r/_n" "$r/harness.project.json"
  out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'корень слоя проекта не задан/недоступен' <<<"$out"; } && return 0
  return 1
}
cell_b4() { # empty-rules-section: файл из одной строки заголовка
  # $1 = путь к subject-скрипту (честный gen-harness.ts ИЛИ обманный stub_gen_harness).
  local subj="$1" hdrf="$WORK/b4-header-only.md" out rc
  printf '%s\n' "$HDR" > "$hdrf"
  out="$(node "$subj" --agents-rules "$hdrf" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'FAIL секции правил нет' <<<"$out"; } && return 0
  return 1
}
cell_b5() { # global-only-4.3: HOME/.gitconfig=refuse, но локально не выставлено
  local r="$WORK/b5-repo" home="$WORK/b5-home" out rc
  rm -rf "$r" "$home"; mkdir -p "$home"
  git config --file "$home/.gitconfig" receive.denyCurrentBranch refuse
  repo_make "$r" typescript 1 1 v10
  # Локально НЕ выставляем — обход и был в этом.
  out="$(HOME="$home" HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$1" --probe "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF "receive.denyCurrentBranch=" <<<"$out" && grep -qF "ожидается 'refuse'" <<<"$out" && grep -qF 'Исправление: git -C' <<<"$out"; } && return 0
  return 1
}
cell_b6() { # numeric-bootstrap-pin: {"version":7} принималось как «непустая» строка
  local r="$WORK/b6-repo" out rc
  rm -rf "$r"; repo_make "$r" typescript 1 1 v10
  printf '{"version":7}\n' > "$r/config/harness_pin.json"
  out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$1" --probe "$r" 2>&1)"; rc=$?
  { [ "$rc" -eq 1 ] && grep -qF 'значение вне алфавита: version:' <<<"$out"; } && return 0
  return 1
}
cell_b7() { # non-string-string-field: нестроковые JSON-значения в строковых полях
  # Проверяет 3 представительных подкейса из 6 контрмоделей адверсария 054
  # круг 2: projectId (число), ci.workflow (число), barriers.mandatory (строка
  # вместо массива). Полное покрытие — отдельные контрмодели, эта клетка —
  # минимально достаточная для различимости (каждая подкейс-контрмодель даёт
  # именованный отказ; общий обходной стаб с `STUB_ACCEPT_NON_STRING` ловится
  # здесь же, потому что отказ по подкейсу срабатывает раньше).
  local layer="$WORK/b7-layer" r="$WORK/b7-repo" out rc
  rm -rf "$layer" "$r"; mkdir -p "$layer/registry"
  # Слой проекта — projectId: 7 (число) и barriers.mandatory: "x" (строка)
  cat > "$layer/registry/harness-project.json" <<EOF
{"schemaVersion":1,"version":"v10","projectId":7,"workspaceId":"w1","defaults":{"language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":"x","optional":[]}}}
EOF
  repo_make "$r" typescript 1 1 v10
  # Репо — ci.workflow: 7 (число)
  jq '.ci.workflow = 7' "$r/harness.project.json" > "$r/_n" && mv "$r/_n" "$r/harness.project.json"
  out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  # Должен быть rc=1 и ОДНО из имён отказа (projectId/ci.workflow/barriers.*)
  { [ "$rc" -eq 1 ] && grep -qE 'значение вне алфавита: (projectId|ci.workflow|barriers\.[a-z]+): <' <<<"$out"; } && return 0
  return 1
}
cell_b8() { # GIT_DIR-redirects-local-4.3: GIT_DIR редиректит --local в чужой git-dir
  local r="$WORK/b8-repo" home="$WORK/b8-home" bare="$WORK/b8-bare" out rc
  rm -rf "$r" "$home" "$bare"
  mkdir -p "$home" "$bare"
  # Bare с настройкой refuse — именно оттуда GIT_DIR будет читать «refuse»
  (cd "$bare" && git init --bare -q)
  git config --file "$bare/config" receive.denyCurrentBranch refuse
  repo_make "$r" typescript 1 1 v10
  # Снять локальную настройку в репо — обход именно в этом: bare с refuse
  # подменяет отсутствующую локальную настройку через унаследованный GIT_DIR.
  git -C "$r" config --unset receive.denyCurrentBranch
  out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" GIT_DIR="$bare" bash "$1" --probe "$r" 2>&1)"; rc=$?
  # ЧЕСТНЫЙ workshop санирует GIT_DIR/GIT_WORK_TREE/GIT_INDEX_FILE/GIT_COMMON_DIR
  # и принудительно указывает --git-dir, поэтому deny_val берётся из
  # $r/.git/config (а там пусто) → отказ W2.
  { [ "$rc" -eq 1 ] && grep -qF "receive.denyCurrentBranch=" <<<"$out" && grep -qF "ожидается 'refuse'" <<<"$out" && grep -qF 'Исправление: git -C' <<<"$out"; } && return 0
  return 1
}

# b9: repo-layer-symlink-outside: `<repo>/harness.project.json` — симлинк на
# валидный файл вне корня репо. До фикс-раунда 5 это проходило rc=0, и merged
# нёс repoId/commands/CI/canonicalRemote/barriers/pin внешнего владельца.
# Честный резолвер после 054-фикс-раунд 5 канонизирует $REPO_JSON через
# readlink -f и требует, чтобы цель лежала физически под каноническим
# `--repo`. Контрмодель СТАБА: не канонизировать — симлинк проходит.
cell_b9() { # repo-layer-symlink-outside
  # $1 = путь к subject (честный резолвер ИЛИ обманный stub_resolver).
  local r="$WORK/b9-repo" outside="$WORK/b9-outside.json" out rc
  rm -rf "$r"; mkdir -p "$r/config"
  # Внешний файл — полноценный валидный профиль, который НЕ лежит под $r.
  printf '{"schemaVersion":1,"repoId":"r_external","language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"ci":{"workflow":".github/workflows/ci.yml"},"git":{"canonicalRemote":"git@host:r_external.git"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}' > "$outside"
  # repo_make без harness.project.json + заменяем на симлинк наружу.
  repo_make "$r" typescript 1 1 v10
  rm -f "$r/harness.project.json"
  ln -s "$outside" "$r/harness.project.json"
  out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$1" --repo "$r" 2>&1)"; rc=$?
  # ЧЕСТНЫЙ резолвер после раунда 5: rc=1 с именованной фразой «нет файла
  # репо-слоя в корне репо» + инструкция «не symlink на внешний файл».
  { [ "$rc" -eq 1 ] && grep -qF 'нет файла репо-слоя в корне репо' <<<"$out" && grep -qF 'не symlink на внешний файл' <<<"$out"; } && return 0
  return 1
}

# ── СТАБ-ПАК (ДО честной части; зелёный и ДО и ПОСЛЕ реализации) ────────────
# Каждый обманный стаб умирает на СВОЕЙ клетке именованно (Н-39, различимость
# не зависит от существования честного кода).
run_stub_pack() {
  layer_make "$WORK/layer"
  mkdir -p "$WORK/stub/scripts"
  local caught=0 total=0
  declare -a NAMES=() CELLS=() KNOBS=()
  NAMES+=(МОЛЧАЛИВЫЙ-ENV);    CELLS+=(k12); KNOBS+=("STUB_SKIP_ENV=1")
  NAMES+=(МЯГКИЙ-ПИН);        CELLS+=(k13); KNOBS+=("STUB_SKIP_PIN=1")
  NAMES+=(НЕПУСТОЕ-ПРОХОДИТ); CELLS+=(k7b); KNOBS+=("STUB_DENY_NONEMPTY=1")
  NAMES+=(ВЫВЕСКА-ПРАВИЛ);    CELLS+=(k8);  KNOBS+=("STUB_VIVISKA=1")
  NAMES+=(ПОДМЕШИВАНИЕ-РЕПО); CELLS+=(k8);  KNOBS+=("STUB_PODMESHENIE=1")
  NAMES+=(ГЛУХОЙ-АЛФАВИТ);    CELLS+=(k4);  KNOBS+=("STUB_IGNORE_UNKNOWN=1")
  NAMES+=(ПИН-МОЛЧА);         CELLS+=(k6);  KNOBS+=("STUB_IGNORE_PIN=1")
  NAMES+=(ПРОИСХОЖДЕНИЕ-ВРАСТЁТ); CELLS+=(k9); KNOBS+=("STUB_ORIGIN_PROJECT=1")
  NAMES+=(САМ-СОЗДАЁТ);       CELLS+=(k2);  KNOBS+=("STUB_AUTOCREATE=1")
  # ── обходы 054-фикс-раунд 3 (adversary verdict) ──
  NAMES+=(DEFAULTS-SHALLOW);  CELLS+=(b1);  KNOBS+=("STUB_DEFAULTS_SCAN_SHALLOW=1")
  NAMES+=(EMPTY-COMMAND);     CELLS+=(b2);  KNOBS+=("STUB_ACCEPT_EMPTY_CMD=1")
  NAMES+=(TRAVERSAL-OK);      CELLS+=(b3);  KNOBS+=("STUB_TRAVERSAL_OK=1")
  NAMES+=(HEADER-ONLY);       CELLS+=(b4);  KNOBS+=("STUB_HEADER_ONLY_OK=1")
  NAMES+=(GLOBAL-4.3);        CELLS+=(b5);  KNOBS+=("STUB_GLOBAL_OK=1")
  NAMES+=(NUMERIC-PIN);       CELLS+=(b6);  KNOBS+=("STUB_ACCEPT_NUMERIC_PIN=1")
  # ── обходы 054-фикс-раунд 4 (adversary verdict round 2) ──
  NAMES+=(NON-STRING-OK);     CELLS+=(b7);  KNOBS+=("STUB_ACCEPT_NON_STRING=1")
  NAMES+=(GITDIR-OK);         CELLS+=(b8);  KNOBS+=("STUB_GITDIR_OK=1")
  # ── обход 054-фикс-раунд 5 (adversary verdict round 3) ──
  NAMES+=(REPO-SYMLINK);      CELLS+=(b9);  KNOBS+=("STUB_REPO_SYMLINK_OK=1")
  [ "${#NAMES[@]}" -gt 0 ] || die_pack 'пустая выборка стаб-пака — не проверено ничего'
  export HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" RULES_HDR="$HDR" HARNESS_ROOT="$ROOT" TMP_STUB_HOME="$WORK/stub-home"
  local i cell kn subj
  for i in "${!NAMES[@]}"; do
    total=$((total + 1))
    cell="${CELLS[$i]}"
    kn="${KNOBS[$i]}"
    # Обходы b1/b2/b3/b7 — резолвер; b4 — обёртка gen-harness; b5/b6/b8 — workshop.
    case "$cell" in
      b1|b2|b3|b7|b9)
        stub_resolver "$WORK/stub/scripts/profile_resolver.sh"
        subj="$WORK/stub/scripts/profile_resolver.sh"
        ;;
      b4)
        stub_gen_harness "$WORK/stub/gen-harness.ts"
        subj="$WORK/stub/gen-harness.ts"
        ;;
      b5|b6|b8)
        stub_workshop "$WORK/stub/workshop"
        subj="$WORK/stub/workshop"
        ;;
      k4|k6|k9)
        stub_resolver "$WORK/stub/scripts/profile_resolver.sh"
        subj="$WORK/stub/scripts/profile_resolver.sh"
        ;;
      *)
        stub_workshop "$WORK/stub/workshop"
        subj="$WORK/stub/workshop"
        ;;
    esac
    export "$kn"
    if "cell_$cell" "$subj"; then
      unset "${kn%%=*}"
      die_pack "СТАБ ВЫЖИЛ: ${NAMES[$i]} прошёл клетку $cell — различимость не доказана"
    fi
    unset "${kn%%=*}"
    caught=$((caught + 1))
    printf 'стаб пойман: %s — клетка %s\n' "${NAMES[$i]}" "$cell"
  done
  unset HARNESS_PROJECT_LAYER_ROOT RULES_HDR HARNESS_ROOT TMP_STUB_HOME
  printf 'стаб-пак: просмотрено %s, поймано %s\n' "$total" "$caught" >&2
  [ "$caught" -eq "$total" ]
}

# ── ЧЕСТНАЯ ЧАСТЬ (red — прогоните ДО реализации; green — после) ───────────
run_honest() {
  cell_g0  || { echo "Г0 ПРЕДМЕТ ОТСУТСТВУЕТ (ожидалось до реализации)" >&2; exit 1; }
  layer_make "$WORK/layer"
  # Клетки разнесены по типу субъекта: workshop_cells — workshop --probe,
  # resolver_cells — резолвер; gen-harness_cells — отдельные.
  local FAIL=0
  local cell
  for cell in k1 k7a k7b k7c k8 k12 k13; do
    if ! cell_workshop_run "$cell"; then
      printf 'клетка %s (workshop): красная\n' "$cell" >&2
      FAIL=1
    fi
  done
  for cell in k2 k3 k3b k4 k4b k5 k6 k9 k11 b1 b2 b3 b7 b9; do
    if ! cell_resolver_run "$cell"; then
      printf 'клетка %s (resolver): красная\n' "$cell" >&2
      FAIL=1
    fi
  done
  for cell in b5 b6 b8; do
    if ! cell_workshop_run "$cell"; then
      printf 'клетка %s (workshop): красная\n' "$cell" >&2
      FAIL=1
    fi
  done
  # b4 — gen-harness test, не workshop.
  if ! cell_b4 "$ROOT/scripts/gen-harness.ts"; then
    printf 'клетка b4 (gen-harness): красная\n' >&2
    FAIL=1
  fi
  if ! cell_k10; then printf 'клетка k10: красная\n' >&2; FAIL=1; fi
  if ! cell_k10b; then printf 'клетка k10b: красная\n' >&2; FAIL=1; fi
  if [ "$FAIL" -ne 0 ]; then exit 1; fi
  printf '054-батарея зелёная: все клетки к1-к14 + b1-b9 пройдены\n' >&2
}

# Запустить клетку с workshop в качестве субъекта
cell_workshop_run() {
  local cell="$1" r out rc pmode lang
  case "$cell" in
    k1)
      for lang in rust typescript; do
        r="$WORK/honest-$lang"
        rm -rf "$r"; repo_make "$r" "$lang" 1 1 v10
        out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$WORKSHOP" --probe "$r" 2>&1)"; rc=$?
        pmode="$(grep -F 'PROMPT: ' <<<"$out" | sed 's/^PROMPT: //')"
        { [ "$rc" -eq 0 ] && grep -qF "workshop PROBE OK: $r" <<<"$out" && [ -n "$pmode" ] && [ -f "$pmode" ]; } || return 1
      done
      ;;
    k7a)
      r="$WORK/k7a-h"; repo_make "$r" typescript 1 1 v10
      git -C "$r" config --unset receive.denyCurrentBranch
      out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$WORKSHOP" --probe "$r" 2>&1)"; rc=$?
      { [ "$rc" -eq 1 ] && grep -qF "receive.denyCurrentBranch=" <<<"$out" && grep -qF "ожидается 'refuse'" <<<"$out" && grep -qF 'Исправление: git -C' <<<"$out"; } || return 1
      ;;
    k7b)
      r="$WORK/k7b-h"; repo_make "$r" typescript 1 1 v10
      git -C "$r" config receive.denyCurrentBranch updateInstead
      out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$WORKSHOP" --probe "$r" 2>&1)"; rc=$?
      { [ "$rc" -eq 1 ] && grep -qF "receive.denyCurrentBranch='updateInstead'" <<<"$out" && grep -qF 'ожидается' <<<"$out"; } || return 1
      ;;
    k7c)
      r="$WORK/k7c-h"; repo_make "$r" typescript 1 1 v10
      out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$WORKSHOP" --probe "$r" 2>&1)"; rc=$?
      { [ "$rc" -eq 0 ] && grep -qF "workshop PROBE OK:" <<<"$out"; } || return 1
      ;;
    k8)
      r="$WORK/k8-h"; repo_make "$r" typescript 1 1 v10
      section_of "$ROOT/AGENTS.md" > "$WORK/k8-expected.section"
      local first_role_line hdr_line
      first_role_line="$(node "$ROOT/scripts/gen-harness.ts" --prompt orchestrator 2>/dev/null | sed -n '/./{p;q}')"
      { [ -s "$WORK/k8-expected.section" ] && grep -qFx "$HDR" "$WORK/k8-expected.section"; } || return 1
      [ -n "$first_role_line" ] || return 1
      out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$WORKSHOP" --probe "$r" 2>&1)"; rc=$?
      pmode="$(grep -F 'PROMPT: ' <<<"$out" | sed 's/^PROMPT: //')"
      { [ "$rc" -eq 0 ] && [ -n "$pmode" ] && [ -f "$pmode" ]; } || return 1
      grep -qFx "$HDR" "$pmode" || return 1
      awk -v h="$HDR" '$0 == h {f = 1; next} f && /^## / {exit} f {print}' "$pmode" > "$WORK/k8-actual.body"
      awk 'NR > 1' "$WORK/k8-expected.section" > "$WORK/k8-expected.body"
      cmp -s "$WORK/k8-actual.body" "$WORK/k8-expected.body" || return 1
      hdr_line="$(grep -nFx "$HDR" "$pmode" | head -1 | cut -d: -f1)"
      [ "$(grep -nF -- "$first_role_line" "$pmode" | head -1 | cut -d: -f1)" -lt "$hdr_line" ] || return 1
      if grep -qFx "$TOY_HDR" "$pmode"; then return 1; fi
      ;;
    k12)
      r="$WORK/k12-h"; repo_make "$r" typescript 1 0 v10
      out="$(METERING_PROXY_URL=http://exported.invalid:1 HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$WORKSHOP" --probe "$r" 2>&1)"; rc=$?
      { [ "$rc" -eq 1 ] && grep -qF 'нет .env проекта:' <<<"$out" && grep -qF 'Инструкция: создайте .env в корне репо' <<<"$out"; } || return 1
      ;;
    k13)
      r="$WORK/k13-h"; repo_make "$r" typescript 1 1 v10; rm -f "$r/config/harness_pin.json"
      out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$WORKSHOP" --probe "$r" 2>&1)"; rc=$?
      { [ "$rc" -eq 1 ] && grep -qF 'нет пина версии omp:' <<<"$out" && grep -qF '{"version": "<версия omp>"}' <<<"$out"; } || return 1
      ;;
    b5)
      local home="$WORK/b5-h-home"; mkdir -p "$home"
      git config --file "$home/.gitconfig" receive.denyCurrentBranch refuse
      r="$WORK/b5-h"; repo_make "$r" typescript 1 1 v10
      # Снять ЛОКАЛЬНУЮ настройку — обход №5 был именно в этом (HOME-global
      # подменял локальную через --get, теперь --local не видит global).
      git -C "$r" config --unset receive.denyCurrentBranch
      out="$(HOME="$home" HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$WORKSHOP" --probe "$r" 2>&1)"; rc=$?
      { [ "$rc" -eq 1 ] && grep -qF "receive.denyCurrentBranch=" <<<"$out" && grep -qF "ожидается 'refuse'" <<<"$out" && grep -qF 'Исправление: git -C' <<<"$out"; } || return 1
      ;;
    b6)
      r="$WORK/b6-h"; repo_make "$r" typescript 1 1 v10
      printf '{"version":7}\n' > "$r/config/harness_pin.json"
      out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$WORKSHOP" --probe "$r" 2>&1)"; rc=$?
      { [ "$rc" -eq 1 ] && grep -qF 'значение вне алфавита: version:' <<<"$out"; } || return 1
      ;;
    b8)
      local bare="$WORK/b8-h-bare"
      rm -rf "$bare"; mkdir -p "$bare"
      (cd "$bare" && git init --bare -q)
      git config --file "$bare/config" receive.denyCurrentBranch refuse
      r="$WORK/b8-h"; repo_make "$r" typescript 1 1 v10
      git -C "$r" config --unset receive.denyCurrentBranch
      out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" GIT_DIR="$bare" bash "$WORKSHOP" --probe "$r" 2>&1)"; rc=$?
      { [ "$rc" -eq 1 ] && grep -qF "receive.denyCurrentBranch=" <<<"$out" && grep -qF "ожидается 'refuse'" <<<"$out" && grep -qF 'Исправление: git -C' <<<"$out"; } || return 1
      ;;
    *) return 0 ;;
  esac
}

# Запустить клетку с resolver в качестве субъекта
cell_resolver_run() {
  local cell="$1" r out rc
  case "$cell" in
    k2) r="$WORK/k2-r"; repo_make "$r" typescript 1 1 v10; rm -f "$r/harness.project.json"
        out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$PROFILE_RESOLVER" --repo "$r" 2>&1)"; rc=$?
        { [ "$rc" -eq 1 ] && grep -qF 'profile ОТКАЗ: нет harness.project.json:' <<<"$out"; } || return 1 ;;
    k3) r="$WORK/k3-r"; repo_make "$r" rust 1 1 v10
        out="$(env -u HARNESS_PROJECT_LAYER_ROOT bash "$PROFILE_RESOLVER" --repo "$r" 2>&1)"; rc=$?
        { [ "$rc" -eq 1 ] && grep -qF 'корень слоя проекта не задан/недоступен' <<<"$out"; } || return 1 ;;
    k3b) r="$WORK/k3b-r"; repo_make "$r" rust 1 1 v10; mkdir -p "$WORK/empty-layer3b"
          out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/empty-layer3b" bash "$PROFILE_RESOLVER" --repo "$r" 2>&1)"; rc=$?
          { [ "$rc" -eq 1 ] && grep -qF 'нет файла слоя проекта:' <<<"$out"; } || return 1 ;;
    k4) r="$WORK/k4-r"; repo_make "$r" typescript 1 1 v10
        jq '.workflowPaths.contrete = "x"' "$r/harness.project.json" > "$r/_n" && mv "$r/_n" "$r/harness.project.json"
        out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$PROFILE_RESOLVER" --repo "$r" 2>&1)"; rc=$?
        { [ "$rc" -eq 1 ] && grep -qF 'неизвестный ключ' <<<"$out" && grep -qF 'workflowPaths.contrete' <<<"$out"; } || return 1 ;;
    k4b) r="$WORK/k4b-r"; mkdir -p "$WORK/k4b-layer"
          repo_make "$r" rust 1 1 v10; layer_make "$WORK/k4b-layer"
          jq '.boguskey = "x"' "$WORK/k4b-layer/registry/harness-project.json" > "$WORK/k4b-layer/_n" && mv "$WORK/k4b-layer/_n" "$WORK/k4b-layer/registry/harness-project.json"
          out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/k4b-layer" bash "$PROFILE_RESOLVER" --repo "$r" 2>&1)"; rc=$?
          { [ "$rc" -eq 1 ] && grep -qF 'неизвестный ключ' <<<"$out" && grep -qF 'boguskey' <<<"$out"; } || return 1 ;;
    k5) r="$WORK/k5-r"; repo_make "$r" rust 1 1 v10
        jq '.language = "python"' "$r/harness.project.json" > "$r/_n" && mv "$r/_n" "$r/harness.project.json"
        out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$PROFILE_RESOLVER" --repo "$r" 2>&1)"; rc=$?
        { [ "$rc" -eq 1 ] && grep -qF 'значение вне алфавита: language:' <<<"$out"; } || return 1 ;;
    k6) r="$WORK/k6-r"; repo_make "$r" rust 1 1 v10
        jq '.projectLayer.version = "v9"' "$r/harness.project.json" > "$r/_n" && mv "$r/_n" "$r/harness.project.json"
        out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$PROFILE_RESOLVER" --repo "$r" 2>&1)"; rc=$?
        { [ "$rc" -eq 1 ] && grep -qF 'пин слоя проекта расходится' <<<"$out" && grep -qF "v9" <<<"$out" && grep -qF "v10" <<<"$out"; } || return 1 ;;
    k9) r="$WORK/k9-r"; repo_make "$r" typescript 1 1 v10
        out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$PROFILE_RESOLVER" --repo "$r" 2>&1)"; rc=$?
        [ "$rc" -eq 0 ] || return 1
        [ "$(jq -r '.language.value' <<<"$out")" = "typescript" ] || return 1
        [ "$(jq -r '.language.origin' <<<"$out")" = "repo" ] || return 1
        [ "$(jq -r '.projectId.origin' <<<"$out")" = "project" ] || return 1
        ;;
    k11) r="$WORK/k11-r"; repo_make "$r" rust 1 1 v10
          printf '%s' '{ NOT VALID' > "$r/harness.project.json"
          out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$PROFILE_RESOLVER" --repo "$r" 2>&1)"; rc=$?
          { [ "$rc" -eq 1 ] && grep -qF 'файл не JSON:' <<<"$out" && grep -qF 'harness.project.json' <<<"$out"; } || return 1 ;;
    b1) local layer="$WORK/b1-r-layer"; rm -rf "$layer"; mkdir -p "$layer/registry"
         cat > "$layer/registry/harness-project.json" <<EOF2
{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"typescript","workflowPaths":{"contracts":"contracts","unseen":"BOGUS"}}}
EOF2
         r="$WORK/b1-r"; repo_make "$r" typescript 1 1 v10
         out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$PROFILE_RESOLVER" --repo "$r" 2>&1)"; rc=$?
         { [ "$rc" -eq 1 ] && grep -qF 'неизвестный ключ project: defaults.workflowPaths.unseen' <<<"$out"; } || return 1 ;;
    b2) r="$WORK/b2-r"; repo_make "$r" typescript 1 1 v10
         jq '.commands.test = ""' "$r/harness.project.json" > "$r/_n" && mv "$r/_n" "$r/harness.project.json"
         out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$PROFILE_RESOLVER" --repo "$r" 2>&1)"; rc=$?
         { [ "$rc" -eq 1 ] && grep -qF 'значение вне алфавита: commands.test: пусто' <<<"$out"; } || return 1 ;;
    b3) local layer="$WORK/b3-r-layer" sibling="$WORK/b3-sibling.json"
         rm -rf "$layer"; mkdir -p "$layer/registry"
         layer_make "$layer"
         cat > "$sibling" <<EOF2
{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1"}
EOF2
         r="$WORK/b3-r"; repo_make "$r" typescript 1 1 v10
         jq --arg sib "../b3-sibling.json" '.projectLayer.profilePath = $sib' "$r/harness.project.json" > "$r/_n" && mv "$r/_n" "$r/harness.project.json"
         out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$PROFILE_RESOLVER" --repo "$r" 2>&1)"; rc=$?
         { [ "$rc" -eq 1 ] && grep -qF 'корень слоя проекта не задан/недоступен' <<<"$out"; } || return 1 ;;
    b7) local layer="$WORK/b7-r-layer"
         rm -rf "$layer"; mkdir -p "$layer/registry"
         cat > "$layer/registry/harness-project.json" <<EOF2
{"schemaVersion":1,"version":"v10","projectId":7,"workspaceId":"w1","defaults":{"language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git"},"ci":{"workflow":"ci.yml"},"barriers":{"mandatory":"x","optional":[]}}}
EOF2
         r="$WORK/b7-r"; repo_make "$r" typescript 1 1 v10
         jq '.ci.workflow = 7' "$r/harness.project.json" > "$r/_n" && mv "$r/_n" "$r/harness.project.json"
         out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$PROFILE_RESOLVER" --repo "$r" 2>&1)"; rc=$?
         { [ "$rc" -eq 1 ] && grep -qE 'значение вне алфавита: (projectId|ci.workflow|barriers\.[a-z]+): <' <<<"$out"; } || return 1 ;;
    b9) local r="$WORK/b9-r" outside="$WORK/b9-outside.json"
         rm -rf "$r"; mkdir -p "$r/config"
         printf '{"schemaVersion":1,"repoId":"r_external","language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"ci":{"workflow":".github/workflows/ci.yml"},"git":{"canonicalRemote":"git@host:r_external.git"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}' > "$outside"
         repo_make "$r" typescript 1 1 v10
         rm -f "$r/harness.project.json"
         ln -s "$outside" "$r/harness.project.json"
         out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" bash "$PROFILE_RESOLVER" --repo "$r" 2>&1)"; rc=$?
         { [ "$rc" -eq 1 ] && grep -qF 'нет файла репо-слоя в корне репо' <<<"$out" && grep -qF 'не symlink на внешний файл' <<<"$out"; } || return 1 ;;
    *) return 0 ;;
  esac
}

run_stub_pack || exit 1
run_honest
echo "054-батарея зелёная" >&2
exit 0
