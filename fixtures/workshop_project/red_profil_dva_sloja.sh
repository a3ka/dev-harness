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
  # С2-миграция toy-миров (контракт 059): объявленный CI-toy-файл создаётся,
  # иначе после реализации И-2(г) клетки 054 краснеют (эффективный
  # ci.workflow=".github/workflows/ci.yml" мерджится из репо/слоя — резолвер
  # проверяет существование файла на REPO_ABS; прецедент арбитраж 059-к3
  # 9e874be С2). Inline-JSON :601, :1077, :1096, :1114, :1130, :1187, :1304 —
  # в этих клетках строится отдельный toy-репо, поэтому ИМ тоже нужен файл.
  mkdir -p "$r/.github/workflows"
  printf 'name: toy ci\n' > "$r/.github/workflows/ci.yml"
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
    printf 'profile ОТКАЗ: неизвестный ключ слой-проекта: defaults.workflowPaths.%s\n' "$du" >&2; exit 1
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

# b11: МУТАНТНЫЙ СТАБ резолвера с check-then-open порядком (054-фикс-раунд 7).
# Структурно повторяет резолвер, но readlink -f на pathname ВЫПОЛНЯЕТСЯ
# ДО exec {fd}<"$REPO_JSON" (и то же для project-layer). Окно между
# readlink и exec открыто для подмены: между возвратом readlink (который
# проверяет границу на ОДНОЙ цели) и открытием fd (которое читает УЖЕ
# ДРУГОЙ inode, если симлинк подменён) атакующий может подменить симлинк
# на внешний валидный JSON. Клетка cell_b11 ловит этот мутант: ставит
# readlink-шим через BASH_ENV, который атомарно подменяет симлинк сразу
# после возврата readlink (имитация обхода 054-v1 круг 5 — доказано
# адверсарием). Мутант выдаёт rc=0 с ВНЕШНИМ repoId; клетка видит это
# и убивает мутанта как «стаб выжил». Честный резолвер после фикса 7
# (exec {fd}< ПЕРВЫМ, readlink /proc/self/fd/$fd ВТОРЫМ) — подмена симлинка
# после exec не меняет inode fd, и readlink видит прежний внутренний
# путь → rc=0 с ВНУТРЕННИМ repoId; клетка зелёная.
#
# Структура мутанта повторяет честный резолвер по И-1..И-6, чтобы
# различие было ИСКЛЮЧИТЕЛЬНО в порядке «readlink -f pathname → exec»,
# а не в других нюансах (другие обходы — отдельные стабы в пакете).
stub_resolver_checkopen() {
  cat > "$1" <<'STUB'
#!/usr/bin/env bash
# МУТАНТНЫЙ СТАБ резолвера 054 с check-then-open порядком — для клетки b11.
set -uo pipefail
REPO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; [ $# -ge 2 ] && shift ;;
    *) REPO="$1" ;;
  esac
  shift
done
[ -n "$REPO" ] || { printf 'profile ОТКАЗ: usage: --repo <корень>\n' >&2; exit 1; }
[ -d "$REPO" ] || { printf 'profile ОТКАЗ: каталог репо не существует: %s\n' "$REPO" >&2; exit 1; }

# ── репо-слой (CHECK-THEN-OPEN — мутантный порядок) ──────────────────────────
REPO_JSON="$REPO/harness.project.json"
[ -f "$REPO_JSON" ] || { printf 'profile ОТКАЗ: нет harness.project.json: %s\n' "$REPO_JSON" >&2; exit 1; }
REPO_ABS="$(cd "$REPO" && pwd -P)"
# CHECK-THEN-OPEN: readlink -f pathname ДО exec {fd}< — окно для подмены.
REPO_JSON_ABS="$(readlink -f -- "$REPO_JSON" 2>/dev/null || true)"
case "$REPO_JSON_ABS" in
  "$REPO_ABS"/*) ;;
  *) printf 'profile ОТКАЗ: нет файла репо-слоя в корне репо: %s. Инструкция: harness.project.json должен лежать в корне репо — не symlink на внешний файл\n' "$REPO_JSON" >&2; exit 1 ;;
esac
exec {REPO_FD}<"$REPO_JSON" || { printf 'profile ОТКАЗ: не удалось открыть репо-слой: %s\n' "$REPO_JSON" >&2; exit 1; }
[ -f "/proc/self/fd/$REPO_FD" ] || { exec {REPO_FD}<&- || true; printf 'profile ОТКАЗ: не удалось открыть репо-слой: %s\n' "$REPO_JSON" >&2; exit 1; }
REPO_JSON_FD="/proc/self/fd/$REPO_FD"
jq -e . "$REPO_JSON_FD" >/dev/null 2>&1 || { printf 'profile ОТКАЗ: файл не JSON: %s\n' "$REPO_JSON" >&2; exit 1; }

# ── слой проекта (CHECK-THEN-OPEN — мутантный порядок) ─────────────────────
LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-}"
[ -n "$LAYER_ROOT" ] && [ -d "$LAYER_ROOT" ] \
  || { printf 'profile ОТКАЗ: корень слоя проекта не задан/недоступен. Инструкция: export HARNESS_PROJECT_LAYER_ROOT=<корень клона слоя проекта (odelix-stack)>\n' >&2; exit 1; }
PROFILE_PATH_REL="$(jq -r '.projectLayer.profilePath // "registry/harness-project.json"' "$REPO_JSON_FD")"
case "$PROFILE_PATH_REL" in
  /*) printf 'profile ОТКАЗ: profilePath обязан быть относительным, не абсолютным: %s\n' "$PROFILE_PATH_REL" >&2; exit 1 ;;
esac
PROJECT_JSON="$LAYER_ROOT/${PROFILE_PATH_REL#./}"
[ -f "$PROJECT_JSON" ] || { printf 'profile ОТКАЗ: нет файла слоя проекта: %s\n' "$PROJECT_JSON" >&2; exit 1; }
LAYER_ROOT_ABS="$(cd "$LAYER_ROOT" && pwd -P)"
# ТОЖЕ check-then-open для project-layer.
TARGET_ABS="$(readlink -f -- "$PROJECT_JSON" 2>/dev/null || true)"
case "$TARGET_ABS" in
  "$LAYER_ROOT_ABS"/*) ;;
  *) printf 'profile ОТКАЗ: корень слоя проекта не задан/недоступен. Инструкция: export HARNESS_PROJECT_LAYER_ROOT=<корень клона слоя проекта (odelix-stack)>\n' >&2; exit 1 ;;
esac
exec {PROJECT_FD}<"$PROJECT_JSON" || { printf 'profile ОТКАЗ: не удалось открыть слой проекта: %s\n' "$PROJECT_JSON" >&2; exit 1; }
[ -f "/proc/self/fd/$PROJECT_FD" ] || { exec {PROJECT_FD}<&- || true; printf 'profile ОТКАЗ: не удалось открыть слой проекта: %s\n' "$PROJECT_JSON" >&2; exit 1; }
PROJECT_JSON_FD="/proc/self/fd/$PROJECT_FD"
jq -e . "$PROJECT_JSON_FD" >/dev/null 2>&1 || { printf 'profile ОТКАЗ: файл не JSON: %s\n' "$PROJECT_JSON" >&2; exit 1; }

# ── пин версии ──────────────────────────────────────────────────────────────
PIN="$(jq -r '.projectLayer.version' "$REPO_JSON_FD")"
LAYER_VER="$(jq -r '.version' "$PROJECT_JSON_FD")"
[ "$PIN" = "$LAYER_VER" ] || { printf 'profile ОТКАЗ: пин слоя проекта расходится: репо пинит "%s", слой несёт "%s"\n' "$PIN" "$LAYER_VER" >&2; exit 1; }

# ── минимальное слияние (как у stub_resolver; проверяет, что merged-профиль
# читает содержимое ОТКРЫТОГО fd, и потому external repoId проходит при
# мутантном порядке — клетка b11 ловит это по .repoId.value).
jq -n \
  --slurpfile repo "$REPO_JSON_FD" \
  --slurpfile project "$PROJECT_JSON_FD" \
  --arg layerRoot "$LAYER_ROOT" \
  '($repo[0]) as $r | ($project[0]) as $p |
   {language: {value: $r.language, origin: "repo"},
    projectId: {value: $p.projectId, origin: "project"},
    workspaceId: {value: $p.workspaceId, origin: "project"},
    repoId: {value: $r.repoId, origin: "repo"},
    schemaVersion: {value: $p.schemaVersion, origin: "project"},
    projectLayer: {value: {version: $r.projectLayer.version, profilePath: $r.projectLayer.profilePath, layerRoot: $layerRoot}, origin: "repo"}}'
exit 0
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
  { [ "$rc" -eq 1 ] && grep -qF 'неизвестный ключ слой-проекта: defaults.workflowPaths.unseen' <<<"$out"; } && return 0
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

# b10: TOCTOU race at project-layer — симлинк на `<layer>/registry/harness-
# project.json` подменяется между `readlink -f` (граница) и `jq` (чтение).
# До фикс-раунда 6 это проходило rc=0 с внешним `projectId` (доказано
# адверсарием к4). Фикс: после канонизации резолвер открывает файл через
# дескриптор (`exec {fd}<...`) и ВСЕ jq-чтения идут через `/proc/self/fd/$fd`,
# а не через повторное открытие по имени. Дескриптор биндится к inode на
# уровне ядра — подмена файла по пути ПОСЛЕ открытия уже не меняет
# содержимого, читаемого через fd. Стаб (path-based reads) подменяется на
# внешний JSON во время прогона резолвера; если race срабатывает на одном
# из его jq-вызовов, выход содержит `EXTERNAL` и клетка возвращает 1
# (= «стаб пойман»). Честный резолвер (fd-bound) ВСЕГДА возвращает либо rc=0
# с `p1`, либо rc=1 (любой именованный отказ); `EXTERNAL` в выходе быть не
# может. Клетка возвращает 0 (= «предмет честен»).
#
# Использует непрерывный swap-loop в background, чтобы максимизировать
# вероятность попадания swap-а в окно «между readlink-f и jq» стаба
# (несколько сотен итераций; ядро переоткрывает файл по каждому jq-вызову
# стаба, и каждое переоткрытие — отдельная возможность прочесть
# подменённое содержимое).
cell_b10() { # TOCTOU: between readlink-f and jq, swap symlink to external JSON
  # Структурная проверка фикса раунда 6: после канонизации резолвер обязан
  # открыть файл ЧЕРЕЗ ДЕСКРИПТОР (`exec {fd}<"$path"`) и все jq-чтения
  # репо-слоя и слоя проекта — через `/proc/self/fd/$fd`, не через
  # повторное открытие по имени. Прецедент scripts/check_provodka.sh к6 Б1
  # (тот же класс обхода). Дескриптор биндится к inode на уровне ядра:
  # подмена файла по пути ПОСЛЕ открытия уже не меняет содержимого,
  # читаемого через fd. Клетка возвращает 0 для честного (есть
  # `exec {REPO_FD}<"$REPO_JSON"` + `/proc/self/fd/$REPO_FD` в исходнике)
  # и 1 для стаба-мутанта (path-based reads; маркер STUB_TOCTOU_PATH=1
  # в run_stub_pack — мутант БЕЗ fd-чтения). Проверка — `grep -F` по
  # БАЙТОВОМУ фрагменту, не по AST: фикс контракта — одна структурная
  # правка, проверка — одна структурная проверка.
  # $1 = путь к subject (честный резолвер ИЛИ обманный stub_resolver).
  local subj="$1"
  [ -f "$subj" ] || return 1
  # Маркеры фикса раунда 6. Каждый — ОДНА байтовая подстрока:
  #   exec {REPO_FD}<"$REPO_JSON"      — открытие дескриптора репо-слоя
  #   exec {PROJECT_FD}<"$PROJECT_JSON" — открытие дескриптора слоя проекта
  #   /proc/self/fd/$REPO_FD           — все чтения репо-слоя через fd
  #   /proc/self/fd/$PROJECT_FD        — все чтения слоя проекта через fd
  if grep -qF 'exec {REPO_FD}<"$REPO_JSON"' "$subj" \
     && grep -qF 'exec {PROJECT_FD}<"$PROJECT_JSON"' "$subj" \
     && grep -qF '/proc/self/fd/$REPO_FD' "$subj" \
     && grep -qF '/proc/self/fd/$PROJECT_FD' "$subj"; then
    # ЧЕСТНЫЙ (или стаб-копия с тем же набором маркеров — для нашего
    # stub_resolver это структурно невозможно, т.к. он не использует fd).
    return 0
  fi
  return 1
}

# b11: TOCTOU-FD-FIRST-RACE — runtime race test (закрытие TOCTOU к5,
# 054-фикс-раунд 7). В отличие от b10 (структурная проверка маркеров
# фикса раунда 6), b11 запускает РЕАЛЬНУЮ гонку и различает порядок
# по ПОВЕДЕНИЮ, не по байтовым маркерам.
#
# Сценарий: `<repo>/harness.project.json` — симлинк на
# `config/harness_internal.json` (ВНУТРИ репо, валидный JSON с repoId=r_internal).
# Клетка через BASH_ENV подсовывает шим readlink: на ЛЮБОЙ вызов readlink
# с аргументом, оканчивающимся на `harness.project.json`, шим атомарно
# подменяет симлинк на `<внешний-файл>` (r_external) И возвращает
# канонический путь старой (внутренней) цели. Это имитирует атаку
# адверсария 054-v1, круг 5 (PATH-шим readlink + подмена сразу после
# возврата, до exec).
#
# Семантика:
#   - ЧЕСТНЫЙ (фикс 7: exec {fd}< ПЕРВЫМ, readlink /proc/self/fd/$fd ВТОРЫМ):
#       exec {fd}<"harness.project.json" → fd биндится к INTERNAL inode
#       (подмена ещё не произошла — шим readlink не вызывался).
#       readlink /proc/self/fd/$fd → шим: аргумент `/proc/self/fd/$fd`
#       не матчит `*harness.project.json`, БЕЗ подмены; возвращает путь
#       к INTERNAL inode → проверка OK.
#       jq через fd → содержимое INTERNAL → merged.repoId = r_internal.
#       Клетка зелёная (rc=0, repoId=r_internal).
#   - МУТАНТ (check-then-open: readlink -f pathname ПЕРВЫМ, exec {fd}< ВТОРЫМ):
#       readlink -f "harness.project.json" → шим: матч, атомарная подмена
#       симлинка, возврат пути INTERNAL (как будто всё в порядке).
#       exec {fd}<"harness.project.json" → ОС открывает файл ПО ПОДМЕНЁННОМУ
#       симлинку → fd биндится к EXTERNAL inode.
#       jq через fd → содержимое EXTERNAL → merged.repoId = r_external.
#       Клетка видит r_external → возвращает 1 (стаб пойман, красная).
#
# Определение «честный vs мутант»: клетка НЕ различает по исходнику —
# она прогоняет реальную гонку и смотрит в вывод. Честный после фикса 7
# ВСЕГДА выдаёт rc=0 с repoId=r_internal; мутант ВСЕГДА выдаёт
# rc=0 с repoId=r_external (внешний JSON валиден). rc≠0 для обоих —
# клетка тоже красная (тест не доказан).
cell_b11() {
  local subj="$1"
  [ -f "$subj" ] || return 1
  local r="$WORK/b11-r"
  local outside="$WORK/b11-outside.json"
  local inside="$r/config/harness_internal.json"
  rm -rf "$r" "$outside"; mkdir -p "$r/config"
  git -C "$r" init -q
  git -C "$r" config receive.denyCurrentBranch refuse
  # INTERNAL: ВНУТРИ репо (config/) — пройдёт readlink-проверку и в честном,
  # и в мутантном сценарии (до подмены).
  cat > "$inside" <<'EOF'
{"schemaVersion":1,"repoId":"r_internal","language":"rust","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}
EOF
  # EXTERNAL: ВНЕ репо — валидный JSON, но внешний repoId; подменённый
  # симлинк наведёт fd именно сюда.
  cat > "$outside" <<'EOF'
{"schemaVersion":1,"repoId":"r_external","language":"rust","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}
EOF
  # Заводим слой проекта (для мутанта — он попытается и его прочитать;
  # нам нужно, чтобы подмена не затрагивала LAYER_ROOT).
  layer_make "$WORK/b11-layer"
  # Симлинк harness.project.json → config/harness_internal.json
  ln -s config/harness_internal.json "$r/harness.project.json"
  # С2-миграция toy-миров (контракт 059): слой декларирует
  # ci.workflow=".github/workflows/ci.yml" → эффективное значение берётся
  # из слоя (И-1); резолвер после реализации 059 проверяет существование
  # файла в репо (И-2(г)). Создаём файл в toy-репо здесь, иначе клетка
  # b11 краснеет не по своему предмету (TOCTOU), а по отсутствию
  # объявленного файла.
  mkdir -p "$r/.github/workflows"
  printf 'name: toy ci\n' > "$r/.github/workflows/ci.yml"
  # BASH_ENV: шим readlink. Подменяет симлинк сразу после возврата.
  local shimdir="$WORK/b11-shim"
  rm -rf "$shimdir"; mkdir -p "$shimdir"
  cat > "$shimdir/setup.sh" <<'SHIM'
#!/usr/bin/env bash
# BASH_ENV-шим readlink. Подменяет симлинк `<dirname>/harness.project.json`
# на $B11_EXTERNAL АТОМАРНО после возврата readlink, если вызван с
# аргументом, оканчивающимся на `harness.project.json`. Вызовы на
# `/proc/self/fd/...` НЕ триггерят подмену (там нет такой подстроки).
readlink() {
  local args=("$@")
  local result
  result="$(/usr/bin/readlink "${args[@]}" 2>/dev/null || true)"
  local arg d cur
  for arg in "${args[@]}"; do
    case "$arg" in
      *harness.project.json)
        d="$(dirname -- "$arg")"
        if [ -L "$d/harness.project.json" ]; then
          cur="$(/usr/bin/readlink "$d/harness.project.json" 2>/dev/null || true)"
          # Подменяем ТОЛЬКО пока симлинк указывает на *_internal.json
          # (т.е. ещё не подменён). После первой подмены cur указывает
          # на external — повторных подмен нет.
          case "$cur" in
            *harness_internal.json)
              if [ -n "${B11_EXTERNAL:-}" ] && [ -f "${B11_EXTERNAL:-}" ]; then
                rm -f "$d/harness.project.json"
                ln -s "${B11_EXTERNAL:-}" "$d/harness.project.json"
              fi
              ;;
          esac
        fi
        ;;
    esac
  done
  printf '%s\n' "$result"
}
SHIM
  # Прогон subject (честный резолвер ИЛИ мутант check-then-open).
  local out rc
  out="$(B11_EXTERNAL="$outside" BASH_ENV="$shimdir/setup.sh" \
        HARNESS_PROJECT_LAYER_ROOT="$WORK/b11-layer" \
        bash "$subj" --repo "$r" 2>&1)"
  rc=$?
  # Восстанавливаем симлинк для последующих прогонов (если клетку дёрнут ещё раз).
  rm -f "$r/harness.project.json"
  ln -s config/harness_internal.json "$r/harness.project.json"
  # ЧЕСТНЫЙ (фикс 7): rc=0, repoId=r_internal. МУТАНТ: rc=0, repoId=r_external
  # (внешний JSON валиден и проходит все проверки, кроме readlink-через-fd,
  # которого у мутанта нет). rc≠0 — тест не доказан (клетка красная).
  [ "$rc" -eq 0 ] || return 1
  local rid
  rid="$(printf '%s' "$out" | jq -r '.repoId.value // empty' 2>/dev/null)"
  [ "$rid" = "r_internal" ] && return 0
  # rid = r_external → мутант пойман; rid = empty / иной → тест не доказан.
  return 1
}

# b11h: честная гонка против РЕАЛЬНОГО резолвера (контракт 057 Ч-4).
# В отличие от cell_b11 (single-run BASH_ENV-шим), здесь RACE_N=128 запусков
# резолвера, фоновый цикл АТОМАРНО (mv -T) перекидывает симлинк
# `<repo>/harness.project.json` между внутренним (ВНУТРИ репо) и внешним
# (ВНЕ репо) целями. Классификация каждого запуска:
#   rc=0 ∧ repoId=r_internal → ok (symlink был внутренним на момент exec)
#   rc=1 (любой именованный отказ) → refused (symlink был внешним на момент
#     exec, или другая причина; внешний симлинк в момент exec → отказ P3)
#   rc=0 ∧ repoId=r_external → УТЕЧКА (это НЕ ДОЛЖНО произойти для честного,
#     fd-first резолвера: exec {fd}< открывает fd ПЕРВЫМ, и readlink
#     /proc/self/fd/$fd привязан к inode на момент exec — подмена симлинка
#     ПОСЛЕ exec не меняет inode fd)
# RACE_N=128 — константа клетки b11h (Ч-4), расчёт достаточности — там же.
#
# ВАЖНО: внутренний JSON — БЕЗ `barriers` (конформант по Ч-1: замороженное
# И-4 «остальные ветви опциональны»). Это и было причиной мёртвой ветви
# `*) return 0` в старом диспетчере — на форме M резолвер не должен падать,
# но старый диспетчер не имел отдельной клетки под эту форму и считал
# прохождение по молчанию.
cell_b11h() { # race against honest resolver (RACE_N=128)
  local subj="$1"
  [ -f "$subj" ] || return 1
  local r="$WORK/b11h-r"
  local internal="$r/config/harness_internal.json"
  local external="$WORK/b11h-external.json"
  rm -rf "$r" "$external"; mkdir -p "$r/config"
  # Internal — ВНУТРИ репо (`$r/config/`), конформант Ч-1 (без barriers).
  # Иначе readlink /proc/self/fd/$fd даёт путь вне репо и резолвер сразу
  # отказывает rc=1 по P3 (тест не доказан — refused, не ok).
  cat > "$internal" <<'EOF'
{"schemaVersion":1,"repoId":"r_internal","language":"rust","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}
EOF
  # External — вне репо, валидный JSON с r_external.
  cat > "$external" <<'EOF'
{"schemaVersion":1,"repoId":"r_external","language":"rust","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}
EOF
  layer_make "$WORK/b11h-layer"
  # Изначально симлинк указывает на internal — иначе первый запуск уже
  # сразу даст rc=1 (symlink missing).
  ln -s "$internal" "$r/harness.project.json"
  # С2-миграция toy-миров (контракт 059): слой декларирует
  # ci.workflow=".github/workflows/ci.yml" — резолвер проверяет существование
  # файла в репо (И-2(г)). Без файла клетка краснеет не по своему предмету
  # (TOCTOU race), а по отсутствию объявленного файла.
  mkdir -p "$r/.github/workflows"
  printf 'name: toy ci\n' > "$r/.github/workflows/ci.yml"

  # Фоновый цикл атомарной подмены симлинка через mv -T. Создаём новый
  # симлинк в `.tmp_link`, потом mv -T поверх `harness.project.json` —
  # `rename(2)` атомарен на уровне ядра (между unlink и rename есть
  # короткое окно, где dest не существует — оно и есть окно гонки).
  (
    local n=0
    while [ "$n" -lt 200000 ]; do
      n=$((n + 1))
      ln -s "$external" "$r/.tmp_link" 2>/dev/null
      mv -T "$r/.tmp_link" "$r/harness.project.json" 2>/dev/null || true
      ln -s "$internal" "$r/.tmp_link" 2>/dev/null
      mv -T "$r/.tmp_link" "$r/harness.project.json" 2>/dev/null || true
    done
  ) &
  local swap_pid=$!

  local RACE_N=128 ok=0 refused=0 leak=0
  local i out rc rid
  for i in $(seq 1 "$RACE_N"); do
    out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/b11h-layer" bash "$subj" --repo "$r" 2>&1)"
    rc=$?
    if [ "$rc" -eq 0 ]; then
      rid="$(printf '%s' "$out" | jq -r '.repoId.value // empty' 2>/dev/null)"
      if [ "$rid" = "r_internal" ]; then
        ok=$((ok + 1))
      elif [ "$rid" = "r_external" ]; then
        leak=$((leak + 1))
      else
        # rc=0, но repoId неожиданный — ни ok, ни leak; для честного это
        # невозможно (формы A/G/F/C/M/P отдают ожидаемое), но если бы
        # произошло — относим к refused (не leak).
        refused=$((refused + 1))
      fi
    else
      refused=$((refused + 1))
    fi
  done

  kill "$swap_pid" 2>/dev/null || true
  wait "$swap_pid" 2>/dev/null || true
  # Восстанавливаем симлинк на internal — на случай повторного вызова
  # клетки в той же сессии.
  rm -f "$r/harness.project.json" "$r/.tmp_link"
  ln -s "$internal" "$r/harness.project.json"

  # Ч-4: «счёт ok/refused/leak напечатан» — единственный источник для
  # визуального судьи; rc батареи судится по нулю утечек (Ч-4).
  printf 'b11h: ok=%d refused=%d leak=%d (RACE_N=%d)\n' \
    "$ok" "$refused" "$leak" "$RACE_N" >&2
  # ЧЕСТНЫЙ резолвер (fd-first): утечек быть не должно. ≥1 утечка —
  # барьер пропустил TOCTOU к5 (round 7 фикс не сработал).
  [ "$leak" -eq 0 ]
}

# b11m: ДИФФЕРЕНЦИАЛЬНАЯ МУТАНТ-ПРОБА (контракт 057 Ч-5).
# Копия резолвера в рабочем каталоге клетки; заякоренная перестановка
# check-then-open (readlink -f pathname ДО exec {fd}<) через literal-anchored
# patch — если якорь не найден, клетка красная именованно (барьер обязан
# следовать за субъектом). Та же гонка RACE_N=128, что и b11h, но против
# мутантной копии. Ожидание: ≥1 утечка — барьер РАЗЛИЧАЕТ честное от
# мутанта; 0 утечек → клетка красная (патч применился, но мутант не дал
# ожидаемого поведения — барьер перестал различать).
cell_b11m() { # diff mutant probe (RACE_N=128)
  local subj="$1"
  [ -f "$subj" ] || return 1
  local mutated="$WORK/b11m-mutated.sh"
  cp "$subj" "$mutated"

  # Заякоренная перестановка: literal-anchored sed-патч. Якоря (Ч-5):
  #   exec {REPO_FD}<"$REPO_JSON"           — открытие fd репо-слоя
  #   REPO_JSON_ABS="$(readlink -f -- "/proc/self/fd/$REPO_FD" — readlink ПОСЛЕ exec
  # Если любой якорь отсутствует — исходник дрейфовал → клетка красная
  # именованно (НЕ зелёная — патч не применился).
  if ! grep -qF 'exec {REPO_FD}<"$REPO_JSON"' "$mutated" \
     || ! grep -qF 'REPO_JSON_ABS="$(readlink -f -- "/proc/self/fd/$REPO_FD"' "$mutated"; then
    printf 'b11m: КРАСНАЯ — патч не применился: исходник изменился (нет якорей readlink/exec)\n' >&2
    return 1
  fi

  # Патч: вырезаем строку `exec {REPO_FD}<"$REPO_JSON" || die_p "не удалось
  # открыть репо-слой: $REPO_JSON"` и ВСТАВЛЯЕМ ПЕРЕД ней блок readlink -f
  # pathname + case. Затем удаляем старую пару readlink/case (после exec).
  # Используем python3 — multiline text replace в bash ненадёжен.
  if ! python3 - "$mutated" <<'PYEOF'; then
import sys
path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    src = f.read()

# Заменяемый блок (honest fd-first pattern)
orig_block = (
    'exec {REPO_FD}<"$REPO_JSON" || die_p "не удалось открыть репо-слой: $REPO_JSON"\n'
    '[ -f "/proc/self/fd/$REPO_FD" ] || {\n'
    '  exec {REPO_FD}<&- || true\n'
    '  die_p "не удалось открыть репо-слой: $REPO_JSON"\n'
    '}\n'
    'REPO_JSON_ABS="$(readlink -f -- "/proc/self/fd/$REPO_FD" 2>/dev/null || true)"\n'
    'case "$REPO_JSON_ABS" in\n'
    '  "$REPO_ABS"/*) ;;\n'
    '  *) exec {REPO_FD}<&- || true\n'
    '     die_p "нет файла репо-слоя в корне репо: $REPO_JSON. Инструкция: harness.project.json должен лежать в корне репо \u2014 не symlink на внешний файл" ;;\n'
    'esac'
)

# Мутантный блок (check-then-open)
mut_block = (
    'REPO_JSON_ABS="$(readlink -f -- "$REPO_JSON" 2>/dev/null || true)"\n'
    'case "$REPO_JSON_ABS" in\n'
    '  "$REPO_ABS"/*) ;;\n'
    '  *) die_p "нет файла репо-слоя в корне репо: $REPO_JSON. Инструкция: harness.project.json должен лежать в корне репо \u2014 не symlink на внешний файл" ;;\n'
    'esac\n'
    'exec {REPO_FD}<"$REPO_JSON" || die_p "не удалось открыть репо-слой: $REPO_JSON"\n'
    '[ -f "/proc/self/fd/$REPO_FD" ] || {\n'
    '  exec {REPO_FD}<&- || true\n'
    '  die_p "не удалось открыть репо-слой: $REPO_JSON"\n'
    '}'
)

if orig_block not in src:
    print("ANCHOR MISMATCH: orig_block not found verbatim", file=sys.stderr)
    sys.exit(1)

new_src = src.replace(orig_block, mut_block, 1)
with open(path, 'w', encoding='utf-8') as f:
    f.write(new_src)
PYEOF
    printf 'b11m: КРАСНАЯ — патч не применился: %s не содержит ожидаемый блок\n' "$mutated" >&2
    return 1
  fi

  # ── та же гонка, что и b11h, но против мутантной копии ───────────────────
  local r="$WORK/b11m-r"
  local internal="$r/config/harness_internal.json"
  local external="$WORK/b11m-external.json"
  rm -rf "$r" "$external"; mkdir -p "$r/config"
  cat > "$internal" <<'EOF'
{"schemaVersion":1,"repoId":"r_internal","language":"rust","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}
EOF
  cat > "$external" <<'EOF'
{"schemaVersion":1,"repoId":"r_external","language":"rust","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}
EOF
  layer_make "$WORK/b11m-layer"
  ln -s "$internal" "$r/harness.project.json"
  # С2-миграция toy-миров (контракт 059): см. b11 — слой декларирует
  # ci.workflow, И-2(г) требует файла в репо.
  mkdir -p "$r/.github/workflows"
  printf 'name: toy ci\n' > "$r/.github/workflows/ci.yml"

  (
    local n=0
    while [ "$n" -lt 200000 ]; do
      n=$((n + 1))
      ln -s "$external" "$r/.tmp_link" 2>/dev/null
      mv -T "$r/.tmp_link" "$r/harness.project.json" 2>/dev/null || true
      ln -s "$internal" "$r/.tmp_link" 2>/dev/null
      mv -T "$r/.tmp_link" "$r/harness.project.json" 2>/dev/null || true
    done
  ) &
  local swap_pid=$!

  local RACE_N=128 ok=0 refused=0 leak=0
  local i out rc rid
  for i in $(seq 1 "$RACE_N"); do
    out="$(HARNESS_PROJECT_LAYER_ROOT="$WORK/b11m-layer" bash "$mutated" --repo "$r" 2>&1)"
    rc=$?
    if [ "$rc" -eq 0 ]; then
      rid="$(printf '%s' "$out" | jq -r '.repoId.value // empty' 2>/dev/null)"
      if [ "$rid" = "r_internal" ]; then
        ok=$((ok + 1))
      elif [ "$rid" = "r_external" ]; then
        leak=$((leak + 1))
      else
        refused=$((refused + 1))
      fi
    else
      refused=$((refused + 1))
    fi
  done

  kill "$swap_pid" 2>/dev/null || true
  wait "$swap_pid" 2>/dev/null || true
  rm -f "$r/harness.project.json" "$r/.tmp_link"
  ln -s "$internal" "$r/harness.project.json"

  printf 'b11m: ok=%d refused=%d leak=%d (RACE_N=%d, мутант check-then-open)\n' \
    "$ok" "$refused" "$leak" "$RACE_N" >&2
  # МУТАНТ (check-then-open): ожидаем ≥1 утечку. 0 утечек → клетка красная.
  [ "$leak" -ge 1 ]
}

# ── КЛЕТКИ СЛИЯНИЯ barriers (контракт 057 Ч-1, §5/§5б; формы A/G/F/C/M/P) ──
# Шесть конформных форм обязаны разрешаться rc 0; форма P дополнительно
# различает листовое слияние (честная) от замещения ветви (мутант) —
# Ч-1 «единица слияния ЛИСТ, не ветвь barriers». Контрмодель критика
# 057-v1:24–29: «есть объект barriers в репо → ветвь замещена целиком»;
# на формах A/G/F/C/M мутант зелёен (одинаковый результат), на P — красен:
# `barriers.optional` теряет вклад из defaults. Клетки m1–m6 — фикстуры
# честной части (Ч-7), счёт попадает в общий N=СВЕРКА-строк.

# Общая запись для kletka form: построить repo и layer c заданными JSON.
#   $1=repo dir; $2=layer dir (coздаёт $2/registry); $3=repo JSON content;
#   $4=layer JSON content (полный путь registry/harness-project.json
#   перезаписывается).
_setup_form_repo() {
  local r="$1" layer="$2" repo_json="$3" layer_json="$4"
  rm -rf "$r" "$layer"; mkdir -p "$r" "$layer/registry"
  git -C "$r" init -q
  git -C "$r" config receive.denyCurrentBranch refuse
  printf '%s' "$repo_json" > "$r/harness.project.json"
  printf '%s' "$layer_json" > "$layer/registry/harness-project.json"
  # С2-миграция toy-миров (контракт 059): если слой или репо декларирует
  # `ci.workflow`, создаём файл по этому пути (после канонизации внутри $r).
  # inline-JSON клеток m1/m2/m3/m4/m6/m7/b7 обходит `repo_make` и идёт
  # напрямую через _setup_form_repo; здесь же перехватываем ВСЕ остальные
  # случаи, чтобы после реализации И-2(г) клетки m1/m2/m3/m4/m6/m7/b7 не
  # краснели из-за отсутствия объявленного файла. Путь берётся ЭФФЕКТИВНЫЙ
  # (И-1): если обе ветви заданы, репо перекрывает слой; иначе — что есть.
  local cw=""
  if printf '%s' "$repo_json" | grep -Eq '"ci"[[:space:]]*:[[:space:]]*\{'; then
    cw="$(printf '%s' "$repo_json" | jq -r '.ci.workflow // empty' 2>/dev/null)"
  fi
  if [ -z "$cw" ] && printf '%s' "$layer_json" | grep -Eq '"ci"[[:space:]]*:[[:space:]]*\{'; then
    cw="$(printf '%s' "$layer_json" | jq -r '.defaults.ci.workflow // empty' 2>/dev/null)"
  fi
  if [ -n "$cw" ] && [ "$cw" != "null" ]; then
    mkdir -p "$r/$(dirname -- "$cw")"
    printf 'name: toy ci\n' > "$r/$cw"
  fi
}

# m1: Форма A (репо только обязательные + слой с полными defaults,
# incl. barriers) → barriers.* origin="project", commands.* origin="project",
# language.origin="repo".
cell_m1() {
  local subj="$1" r="$WORK/m1-r" layer="$WORK/m1-layer"
  local repo_json='{"schemaVersion":1,"repoId":"r1","language":"typescript","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}'
  local layer_json='{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"git":{"canonicalRemote":"git@host:p.git"},"ci":{"workflow":".github/workflows/ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":["check_metering"]}}}'
  _setup_form_repo "$r" "$layer" "$repo_json" "$layer_json"
  local out rc
  out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$subj" --repo "$r" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'm1: честный rc=%d out=%s\n' "$rc" "$out" >&2; return 1; }
  # Происхождения по Ч-1 форма A.
  [ "$(jq -r '.language.origin' <<<"$out")" = "repo" ] || { printf 'm1: language.origin != repo\n' >&2; return 1; }
  [ "$(jq -r '.barriers.mandatory.origin' <<<"$out")" = "project" ] || { printf 'm1: barriers.mandatory.origin != project\n' >&2; return 1; }
  [ "$(jq -r '.barriers.optional.origin' <<<"$out")" = "project" ] || { printf 'm1: barriers.optional.origin != project\n' >&2; return 1; }
  [ "$(jq -r '.commands.test.origin' <<<"$out")" = "project" ] || { printf 'm1: commands.test.origin != project\n' >&2; return 1; }
  [ "$(jq -r '.workflowPaths.contracts.origin' <<<"$out")" = "project" ] || { printf 'm1: workflowPaths.contracts.origin != project\n' >&2; return 1; }
  return 0
}

# m2: Форма G (репо все ветви КРОМЕ barriers + слой с defaults) →
# barriers.* origin="project", прочие origin="repo".
cell_m2() {
  local subj="$1" r="$WORK/m2-r" layer="$WORK/m2-layer"
  local repo_json='{"schemaVersion":1,"repoId":"r1","language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"git":{"canonicalRemote":"git@host:r.git"},"ci":{"workflow":".github/workflows/ci.yml"},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}'
  local layer_json='{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"git":{"canonicalRemote":"git@host:p.git"},"ci":{"workflow":".github/workflows/ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":["check_metering"]}}}'
  _setup_form_repo "$r" "$layer" "$repo_json" "$layer_json"
  local out rc
  out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$subj" --repo "$r" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'm2: честный rc=%d out=%s\n' "$rc" "$out" >&2; return 1; }
  [ "$(jq -r '.language.origin' <<<"$out")" = "repo" ] || { printf 'm2: language.origin != repo\n' >&2; return 1; }
  [ "$(jq -r '.barriers.mandatory.origin' <<<"$out")" = "project" ] || { printf 'm2: barriers.mandatory.origin != project\n' >&2; return 1; }
  [ "$(jq -r '.barriers.optional.origin' <<<"$out")" = "project" ] || { printf 'm2: barriers.optional.origin != project\n' >&2; return 1; }
  [ "$(jq -r '.commands.test.origin' <<<"$out")" = "repo" ] || { printf 'm2: commands.test.origin != repo\n' >&2; return 1; }
  [ "$(jq -r '.workflowPaths.contracts.origin' <<<"$out")" = "repo" ] || { printf 'm2: workflowPaths.contracts.origin != repo\n' >&2; return 1; }
  return 0
}

# m3: Форма F (репо только обязательные + barriers + слой с defaults) →
# barriers.* origin="repo", commands.* origin="project".
cell_m3() {
  local subj="$1" r="$WORK/m3-r" layer="$WORK/m3-layer"
  local repo_json='{"schemaVersion":1,"repoId":"r1","language":"typescript","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]}}'
  local layer_json='{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"git":{"canonicalRemote":"git@host:p.git"},"ci":{"workflow":".github/workflows/ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":["check_metering"]}}}'
  _setup_form_repo "$r" "$layer" "$repo_json" "$layer_json"
  local out rc
  out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$subj" --repo "$r" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'm3: честный rc=%d out=%s\n' "$rc" "$out" >&2; return 1; }
  [ "$(jq -r '.language.origin' <<<"$out")" = "repo" ] || { printf 'm3: language.origin != repo\n' >&2; return 1; }
  [ "$(jq -r '.barriers.mandatory.origin' <<<"$out")" = "repo" ] || { printf 'm3: barriers.mandatory.origin != repo\n' >&2; return 1; }
  [ "$(jq -r '.barriers.optional.origin' <<<"$out")" = "repo" ] || { printf 'm3: barriers.optional.origin != repo\n' >&2; return 1; }
  [ "$(jq -r '.commands.test.origin' <<<"$out")" = "project" ] || { printf 'm3: commands.test.origin != project\n' >&2; return 1; }
  [ "$(jq -r '.workflowPaths.contracts.origin' <<<"$out")" = "project" ] || { printf 'm3: workflowPaths.contracts.origin != project\n' >&2; return 1; }
  return 0
}

# m4: Форма C (репо все ветви + слой БЕЗ defaults) → все листы origin="repo".
cell_m4() {
  local subj="$1" r="$WORK/m4-r" layer="$WORK/m4-layer"
  local repo_json='{"schemaVersion":1,"repoId":"r1","language":"typescript","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"git":{"canonicalRemote":"git@host:r.git"},"ci":{"workflow":".github/workflows/ci.yml"},"barriers":{"mandatory":["check_no_leak"],"optional":["check_metering"]},"projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}'
  local layer_json='{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1"}'
  _setup_form_repo "$r" "$layer" "$repo_json" "$layer_json"
  local out rc
  out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$subj" --repo "$r" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'm4: честный rc=%d out=%s\n' "$rc" "$out" >&2; return 1; }
  [ "$(jq -r '.language.origin' <<<"$out")" = "repo" ] || { printf 'm4: language.origin != repo\n' >&2; return 1; }
  [ "$(jq -r '.barriers.mandatory.origin' <<<"$out")" = "repo" ] || { printf 'm4: barriers.mandatory.origin != repo\n' >&2; return 1; }
  [ "$(jq -r '.barriers.optional.origin' <<<"$out")" = "repo" ] || { printf 'm4: barriers.optional.origin != repo\n' >&2; return 1; }
  [ "$(jq -r '.commands.test.origin' <<<"$out")" = "repo" ] || { printf 'm4: commands.test.origin != repo\n' >&2; return 1; }
  [ "$(jq -r '.workflowPaths.contracts.origin' <<<"$out")" = "repo" ] || { printf 'm4: workflowPaths.contracts.origin != repo\n' >&2; return 1; }
  return 0
}

# m5: Форма M (оба слоя только обязательные) → rc 0, листья barriers/
# commands отсутствуют (пустые объекты после del(.. | nulls), не null).
cell_m5() {
  local subj="$1" r="$WORK/m5-r" layer="$WORK/m5-layer"
  local repo_json='{"schemaVersion":1,"repoId":"r1","language":"typescript","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}'
  local layer_json='{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1"}'
  _setup_form_repo "$r" "$layer" "$repo_json" "$layer_json"
  local out rc
  out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$subj" --repo "$r" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'm5: честный rc=%d out=%s\n' "$rc" "$out" >&2; return 1; }
  # language из репо.
  [ "$(jq -r '.language.origin' <<<"$out")" = "repo" ] || { printf 'm5: language.origin != repo\n' >&2; return 1; }
  # Листья barriers/commands ОТСУТСТВУЮТ — после `del(.. | nulls)` объекты
  # остаются пустыми. Проверяем отсутствие самих ключей-листьев (а не
  # null — это был бы контрамодельный обход).
  if jq -e 'has("barriers") and ((.barriers.mandatory // null) != null or (.barriers.optional // null) != null)' <<<"$out" >/dev/null 2>&1; then
    printf 'm5: barriers содержит ненулевые листья (должны отсутствовать)\n' >&2
    return 1
  fi
  if jq -e 'has("commands") and ((.commands.test // null) != null or (.commands.build // null) != null or (.commands.typecheck // null) != null or (.commands.lint // null) != null)' <<<"$out" >/dev/null 2>&1; then
    printf 'm5: commands содержит ненулевые листья (должны отсутствовать)\n' >&2
    return 1
  fi
  return 0
}

# m6: Форма P (репо barriers ТОЛЬКО с mandatory + слой с полными defaults,
# оба листа barriers) + мутант check-then-merge (замещение ветви barriers
# целиком из репо). По Ч-1: честная реализация сливает barriers.leaf-wise
# (mandatory из репо, optional из defaults) → rc 0 с разными origin;
# мутант замещает ветвь barriers целиком → rc 0, НО barriers.optional
# теряет вклад из defaults (нет в выводе). Клетка проверяет ОБА условия:
#   - честный: rc 0, barriers.mandatory.origin="repo", barriers.optional
#     .origin="project" с value=["check_metering"];
#   - мутант: rc 0, НО barriers.optional отсутствует или имеет иное
#     значение (барьер утратил различение → клетка красная).
# Патч мутанта — anchored: якорь = дословный barriers-блок из
# profile_resolver.sh; патч не применился → клетка красная именованно.
cell_m6() {
  local subj="$1"
  [ -f "$subj" ] || return 1
  local r="$WORK/m6-r" layer="$WORK/m6-layer"
  local repo_json='{"schemaVersion":1,"repoId":"r1","language":"typescript","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"},"barriers":{"mandatory":["check_no_leak"]}}'
  local layer_json='{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"npm test","build":"tsc","typecheck":"tsc --noEmit","lint":"eslint"},"git":{"canonicalRemote":"git@host:p.git"},"ci":{"workflow":".github/workflows/ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":["check_metering"]}}}'
  _setup_form_repo "$r" "$layer" "$repo_json" "$layer_json"

  # ── честная реализация: rc 0, листовое слияние barriers ──────────────
  local out rc
  out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$subj" --repo "$r" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'm6: честный rc=%d out=%s\n' "$rc" "$out" >&2; return 1; }
  if [ "$(jq -r '.barriers.mandatory.origin' <<<"$out")" != "repo" ]; then
    printf 'm6: честный barriers.mandatory.origin != repo\n' >&2; return 1
  fi
  if [ "$(jq -r '.barriers.mandatory.value | join(",")' <<<"$out")" != "check_no_leak" ]; then
    printf 'm6: честный barriers.mandatory.value != ["check_no_leak"]\n' >&2; return 1
  fi
  if [ "$(jq -r '.barriers.optional.origin' <<<"$out")" != "project" ]; then
    printf 'm6: честный barriers.optional.origin != project\n' >&2; return 1
  fi
  if [ "$(jq -r '.barriers.optional.value | join(",")' <<<"$out")" != "check_metering" ]; then
    printf 'm6: честный barriers.optional.value != ["check_metering"]\n' >&2; return 1
  fi

  # ── мутант: замещение ветви barriers целиком ──────────────────────────
  local mutated="$WORK/m6-mutated.sh"
  cp "$subj" "$mutated"
  # Якорь: дословный barriers-блок из profile_resolver.sh (Ч-5 прецедент —
  # anchored-патч b11m, проверка исходника по grep -F).
  if ! grep -qF 'barriers: {' "$mutated" \
     || ! grep -qF 'barriers.mandatory' "$mutated" \
     || ! grep -qF 'barriers.optional' "$mutated"; then
    printf 'm6: КРАСНАЯ — патч не применился: исходник изменился (нет якорей barriers-блока)\n' >&2
    return 1
  fi
  if ! python3 - "$mutated" <<'PYEOF'; then
import sys
path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    src = f.read()
# Honest barriers block (листовое слияние — Ч-1 «единица слияния ЛИСТ»).
# Anchors MUST match profile_resolver.sh verbatim (включая отступы).
orig_block = (
    '    barriers: {\n'
    '      mandatory: (\n'
    '        if $r.barriers and $r.barriers.mandatory != null then { value: $r.barriers.mandatory, origin: "repo" }\n'
    '        elif $p.defaults and $p.defaults.barriers and $p.defaults.barriers.mandatory != null then { value: $p.defaults.barriers.mandatory, origin: "project" }\n'
    '        else null end\n'
    '      ),\n'
    '      optional: (\n'
    '        if $r.barriers and $r.barriers.optional != null then { value: $r.barriers.optional, origin: "repo" }\n'
    '        elif $p.defaults and $p.defaults.barriers and $p.defaults.barriers.optional != null then { value: $p.defaults.barriers.optional, origin: "project" }\n'
    '        else null end\n'
    '      )\n'
    '    },'
)
# Mutant block — замещение ветви barriers целиком (контрмодель критика
# 057-v1:24–29; при наличии barriers в репо листья НЕ наследуются из
# defaults — ветвь берётся из репо целиком; структура {mandatory, optional}
# СОХРАНЯЕТСЯ, чтобы на формах A/G/F/C/M мутант был зелёным, а на P —
# терял barriers.optional (mutant leaves null когда лист не задан в репо).
mut_block = (
    '    barriers: {\n'
    '      mandatory: (\n'
    '        if $r.barriers != null then { value: $r.barriers.mandatory, origin: "repo" }\n'
    '        elif $p.defaults != null and $p.defaults.barriers != null then { value: $p.defaults.barriers.mandatory, origin: "project" }\n'
    '        else null end\n'
    '      ),\n'
    '      optional: (\n'
    '        if $r.barriers != null then { value: $r.barriers.optional, origin: "repo" }\n'
    '        elif $p.defaults != null and $p.defaults.barriers != null then { value: $p.defaults.barriers.optional, origin: "project" }\n'
    '        else null end\n'
    '      )\n'
    '    },'
)
if orig_block not in src:
    print("ANCHOR MISMATCH: orig_block not found verbatim", file=sys.stderr)
    sys.exit(1)
new_src = src.replace(orig_block, mut_block, 1)
with open(path, 'w', encoding='utf-8') as f:
    f.write(new_src)
PYEOF
    printf 'm6: КРАСНАЯ — патч не применился: anchored barriers-блок не найден\n' >&2
    return 1
  fi

  # Прогон мутанта — rc 0, но barriers.optional теряет вклад из defaults.
  local mout mrc
  mout="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$mutated" --repo "$r" 2>&1)"; mrc=$?
  if [ "$mrc" -ne 0 ]; then
    printf 'm6: мутант rc=%d (ожидался 0 — мутант не должен крашиться, лишь терять лист)\n' "$mrc" >&2
    return 1
  fi
  # Различение: barriers.optional.value должен ОТЛИЧАТЬСЯ от
  # ["check_metering"] — иначе мутант утратил различение, барьер больше
  # не различает листовое слияние от замещения ветви. Причина красного —
  # `barriers.optional` (Ч-5, §5б «причина называет barriers.optional»).
  if jq -e '.barriers.optional.value == ["check_metering"]' <<<"$mout" >/dev/null 2>&1; then
    printf 'm6: КРАСНАЯ — barriers.optional.value совпал с ["check_metering"]: мутант различим как честный, барьер утратил различение (barriers.optional потерян в мутанте, но совпал с честным — это невозможно; проверь якорь)\n' >&2
    return 1
  fi
  printf 'm6: честный rc=0 листовое слияние; мутант rc=0 barriers.optional потерян (различение работает)\n' >&2
  return 0
}

# m7: Б7 — defaults.git.canonicalRemote и defaults.ci.workflow НЕ отбрасываются
# silent-drop (И-4/И-6 frozen 054). Честная реализация MERGE-ит defaults.git/ci
# так же, как barriers.mandatory/optional. Клетка проверяет ОБА условия:
#   - честный: rc 0, при `defaults.git.canonicalRemote="git@host:p.git"` и
#     репо без ветви `git` — merged.git.origin="project",
#     merged.git.value.canonicalRemote="git@host:p.git"; то же для ci.workflow;
#   - мутант: старая ветка `else null end` (без `elif $p.defaults…`) →
#     merged.git == null и merged.ci == null. Клетка красная, если мутант
#     совпал с честным (silent-drop утратил различение).
# Якоря (Ч-5): дословный git/ci-блок из profile_resolver.sh после Б7-фикса;
# патч не применился → клетка красная именованно.
cell_m7() {
  local subj="$1"
  [ -f "$subj" ] || return 1
  local r="$WORK/m7-r" layer="$WORK/m7-layer"
  local repo_json='{"schemaVersion":1,"repoId":"r1","language":"typescript","projectLayer":{"version":"v10","profilePath":"registry/harness-project.json"}}'
  local layer_json='{"schemaVersion":1,"version":"v10","projectId":"p1","workspaceId":"w1","defaults":{"language":"rust","workflowPaths":{"contracts":"contracts","verdicts":"verdicts","registry":"registry","fixtures":"fixtures"},"commands":{"test":"x","build":"y","typecheck":"z","lint":"w"},"git":{"canonicalRemote":"git@host:p.git"},"ci":{"workflow":"project-ci.yml"},"barriers":{"mandatory":["check_zones"],"optional":[]}}}'
  _setup_form_repo "$r" "$layer" "$repo_json" "$layer_json"

  # ── честная реализация: rc 0, git/ci из defaults → origin="project" ────
  local rc
  out="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$subj" --repo "$r" 2>&1)"; rc=$?
  [ "$rc" -eq 0 ] || { printf 'm7: честный rc=%d out=%s\n' "$rc" "$out" >&2; return 1; }
  if [ "$(jq -r '.git.origin' <<<"$out")" != "project" ]; then
    printf 'm7: честный git.origin != project (silent-drop Б7)\n' >&2; return 1
  fi
  if [ "$(jq -r '.git.value.canonicalRemote' <<<"$out")" != "git@host:p.git" ]; then
    printf 'm7: честный git.value.canonicalRemote != git@host:p.git\n' >&2; return 1
  fi
  if [ "$(jq -r '.ci.origin' <<<"$out")" != "project" ]; then
    printf 'm7: честный ci.origin != project (silent-drop Б7)\n' >&2; return 1
  fi
  if [ "$(jq -r '.ci.value.workflow' <<<"$out")" != "project-ci.yml" ]; then
    printf 'm7: честный ci.value.workflow != project-ci.yml\n' >&2; return 1
  fi

  # ── мутант: silent-drop (старая ветка `else null end` БЕЗ defaults) ─────
  local mutated="$WORK/m7-mutated.sh"
  cp "$subj" "$mutated"
  # Якоря — дословный git/ci-блок ПОСЛЕ Б7-фикса (тот же, что мы только
  # что закоммитили в profile_resolver.sh; `elif $p.defaults…` присутствует).
  if ! grep -qF 'p.defaults.git' "$mutated" \
     || ! grep -qF 'p.defaults.ci' "$mutated"; then
    printf 'm7: КРАСНАЯ — патч не применился: исходник изменился (нет якорей p.defaults.git/ci)\n' >&2
    return 1
  fi
  if ! python3 - "$mutated" <<'PYEOF'; then
import sys
path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    src = f.read()

# Honest (после Б7-фикса): git/ci сливаются из defaults слоя проекта.
# Anchors MUST match profile_resolver.sh verbatim (включая отступы).
orig_block = (
    '    git: (\n'
    '      if $r.git and $r.git.canonicalRemote != null then { value: { canonicalRemote: $r.git.canonicalRemote }, origin: "repo" }\n'
    '      elif $p.defaults and $p.defaults.git and $p.defaults.git.canonicalRemote != null then { value: { canonicalRemote: $p.defaults.git.canonicalRemote }, origin: "project" }\n'
    '      else null end\n'
    '    ),\n'
    '    ci: (\n'
    '      if $r.ci and $r.ci.workflow != null then { value: { workflow: $r.ci.workflow }, origin: "repo" }\n'
    '      elif $p.defaults and $p.defaults.ci and $p.defaults.ci.workflow != null then { value: { workflow: $p.defaults.ci.workflow }, origin: "project" }\n'
    '      else null end\n'
    '    ),'
)
# Mutant (silent-drop): `elif $p.defaults…` убран; и git, и ci
# молча возвращают null, если репо не задал ветвь (контрмодель Б7).
mut_block = (
    '    git: (if $r.git and $r.git.canonicalRemote != null then { value: { canonicalRemote: $r.git.canonicalRemote }, origin: "repo" } else null end),\n'
    '    ci: (if $r.ci and $r.ci.workflow != null then { value: { workflow: $r.ci.workflow }, origin: "repo" } else null end),'
)
if orig_block not in src:
    print("ANCHOR MISMATCH: orig_block not found verbatim", file=sys.stderr)
    sys.exit(1)
new_src = src.replace(orig_block, mut_block, 1)
with open(path, 'w', encoding='utf-8') as f:
    f.write(new_src)
PYEOF
    printf 'm7: КРАСНАЯ — патч не применился: anchored git/ci-блок не найден\n' >&2
    return 1
  fi

  # Прогон мутанта — silent-drop: git=null, ci=null (после del(.. | nulls)
  # ключи отсутствуют; ищем различимо).
  local mout mrc
  mout="$(HARNESS_PROJECT_LAYER_ROOT="$layer" bash "$mutated" --repo "$r" 2>&1)"; mrc=$?
  if [ "$mrc" -ne 0 ]; then
    printf 'm7: мутант rc=%d (ожидался 0 — мутант не должен крашиться, лишь отбросить defaults)\n' "$mrc" >&2
    return 1
  fi
  # Различение: мутант НЕ ДОЛЖЕН дать merged.git.origin="project"
  # с canonicalRemote из defaults. Если мутант дал то же, что честный —
  # silent-drop утратил различение (Б7 не держится барьером).
  if [ "$(jq -r '.git.origin // "<absent>"' <<<"$mout")" = "project" ]; then
    printf 'm7: КРАСНАЯ — мутант выдал git.origin="project" как честный: silent-drop утратил различение (defaults.git дошёл до merged через мутант — проверь якорь)\n' >&2
    return 1
  fi
  if [ "$(jq -r '.git.value.canonicalRemote // "<absent>"' <<<"$mout")" = "git@host:p.git" ]; then
    printf 'm7: КРАСНАЯ — мутант выдал git.canonicalRemote=git@host:p.git как честный: silent-drop утратил различение\n' >&2
    return 1
  fi
  if [ "$(jq -r '.ci.origin // "<absent>"' <<<"$mout")" = "project" ]; then
    printf 'm7: КРАСНАЯ — мутант выдал ci.origin="project" как честный: silent-drop утратил различение (defaults.ci дошёл до merged через мутант — проверь якорь)\n' >&2
    return 1
  fi
  printf 'm7: честный rc=0 defaults.git/ci merged origin=project; мутант rc=0 silent-drop отбросил defaults.git/ci (различение работает)\n' >&2
  return 0
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
  # ── обход 054-фикс-раунд 6 (adversary verdict round 4, TOCTOU к4) ──
  NAMES+=(TOCTOU-PATH-READS); CELLS+=(b10); KNOBS+=("STUB_TOCTOU_PATH=1")
  # ── обход 054-фикс-раунд 7 (adversary verdict round 5, TOCTOU к5): МУТАНТ
  # с check-then-open порядком (readlink -f pathname ДО exec {fd}<). Клетка
  # b11 ловит его по .repoId.value в выводе (rc=0, но r_external). Этот
  # стаб использует ОТДЕЛЬНЫЙ генератор stub_resolver_checkopen (структурно
  # повторяет резолвер, но порядок операций инвертирован) — НЕ knob в
  # stub_resolver, потому что мутант должен реально делать readlink -f
  # на pathname и exec {fd}<, а stub_resolver использует jq на pathname
  # напрямую и fd-семантикой не обладает. Помещаем в пакет как b11.
  NAMES+=(TOCTOU-CHECK-OPEN); CELLS+=(b11); KNOBS+=("")
  [ "${#NAMES[@]}" -gt 0 ] || die_pack 'пустая выборка стаб-пака — не проверено ничего'
  export HARNESS_PROJECT_LAYER_ROOT="$WORK/layer" RULES_HDR="$HDR" HARNESS_ROOT="$ROOT" TMP_STUB_HOME="$WORK/stub-home"
  local i cell kn subj
  for i in "${!NAMES[@]}"; do
    total=$((total + 1))
    cell="${CELLS[$i]}"
    kn="${KNOBS[$i]}"
    # Обходы b1/b2/b3/b7/b10 — резолвер; b4 — обёртка gen-harness; b5/b6/b8 — workshop;
    # b11 — мутант резолвера с check-then-open (отдельный генератор, без knob).
    case "$cell" in
      b1|b2|b3|b7|b9|b10)
        stub_resolver "$WORK/stub/scripts/profile_resolver.sh"
        subj="$WORK/stub/scripts/profile_resolver.sh"
        ;;
      b11)
        stub_resolver_checkopen "$WORK/stub/scripts/profile_resolver_checkopen.sh"
        subj="$WORK/stub/scripts/profile_resolver_checkopen.sh"
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
    [ -n "$kn" ] && export "$kn"
    if "cell_$cell" "$subj"; then
      [ -n "$kn" ] && unset "${kn%%=*}"
      die_pack "СТАБ ВЫЖИЛ: ${NAMES[$i]} прошёл клетку $cell — различимость не доказана"
    fi
    [ -n "$kn" ] && unset "${kn%%=*}"
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
  # Контракт 057 (Ч-6, Ч-7): единый список клеток в порядке исполнения.
  # Диспетчер ниже ОБРАБАТЫВАЕТ каждую явно и валит на неизвестной (Ч-6,
  # fail-closed). Каждая ИСПОЛНЕННАЯ клетка печатает событие-строку
  # `СВЕРКА: <cell>` (Ч-7 — единственный источник счёта предъявлений;
  # внешняя мера приёмки п.1б сверяет печатный N против `grep -c '^СВЕРКА: '`).
  # Итоговая печать использует ТОЛЬКО счётчик исполненных клеток, не
  # литеральный список (старая «все клетки к1-к14 + b1-b11 пройдены» ложна
  # дважды: b11 не исполнялась, к14 исполняется отдельной командой — С4).
  declare -a HONEST_CELLS=(
    # workshop-субъект (workshop --probe)
    k1 k7a k7b k7c k8 k12 k13
    # resolver-субъект (scripts/profile_resolver.sh --repo ...)
    k2 k3 k3b k4 k4b k5 k6 k9 k11
    # resolver-обходы (стаб-пак ловит обманки; честная часть прогоняет на тех
    # же входах, но с REAL resolver — должна дать именованный rc=1)
    b1 b2 b3 b7 b9 b10
    # честная гонка RACE_N=128 (Ч-4)
    b11h
    # дифф-проба мутанта (Ч-5)
    b11m
    # workshop-обходы
    b5 b6 b8
    # gen-harness --agents-rules
    b4 k10 k10b
    # слияние barriers (контракт 057 Ч-1): формы A/G/F/C/M/P (§5/§5б)
    # m1..m5 — позитивные формы (rc 0, происхождения по Ч-1);
    # m6 — форма P + мутант замещения ветви (Ч-5, §5б).
    m1 m2 m3 m4 m5 m6
    # m7 — defaults.git/ci silent-drop (054 фикс-Б7; И-4/И-6 frozen 054):
    # честная реализация MERGE-ит defaults.git.canonicalRemote/ci.workflow
    # из слоя проекта, мутант silent-drop (старая `else null end`) теряет
    # defaults — клетка ловит ответ m6-стиля (мутант отличим от честного).
    m7
  )

  local sverka_count=0 cell
  for cell in "${HONEST_CELLS[@]}"; do
    sverka_count=$((sverka_count + 1))
    # СВЕРКА-строка — единственный источник счёта (Ч-7).
    printf 'СВЕРКА: %s\n' "$cell"
    if ! dispatch_honest_cell "$cell"; then
      die_pack "ЧЕСТНАЯ ЧАСТЬ: клетка $cell красная"
    fi
  done

  if [ "$sverka_count" -eq 0 ]; then
    # Ч-7: ноль предъявлений — красная.
    die_pack "ЧЕСТНАЯ ЧАСТЬ: не проверено ни одной клетки (нуль предъявлений)"
  fi
  # Ч-7: итоговая печать содержит СЧЁТЧИК (N), который сверяется внешней
  # мерой — `grep -c '^СВЕРКА: '` того же лога. Собственная печать батареи
  # не доказательство (критик 057-v1:35–44).
  printf 'честная часть: проверено предъявлений %d\n' "$sverka_count" >&2
}

# Диспетчер честной клетки (контракт 057 Ч-6). Неизвестное имя → `*)` с
# именованной красной (НЕ `return 0` как было): различимость, что клетка
# исполнена, — в списке `HONEST_CELLS`, а не в молчаливом default-case.
dispatch_honest_cell() {
  local cell="$1"
  case "$cell" in
    # workshop-субъект
    k1|k7a|k7b|k7c|k8|k12|k13|b5|b6|b8) cell_workshop_run "$cell" ;;
    # resolver-субъект
    k2|k3|k3b|k4|k4b|k5|k6|k9|k11|b1|b2|b3|b7|b9|b10|m1|m2|m3|m4|m5) cell_resolver_run "$cell" ;;
    # честная гонка RACE_N=128 (Ч-4)
    b11h) cell_b11h "$PROFILE_RESOLVER" ;;
    # дифф-проба мутанта (Ч-5)
    b11m) cell_b11m "$PROFILE_RESOLVER" ;;
    # форма P + мутант замещения ветви barriers (контракт 057 §5б, Ч-5)
    m6) cell_m6 "$PROFILE_RESOLVER" ;;
    # silent-drop defaults.git/ci (054 фикс-Б7; И-4/И-6 frozen 054)
    m7) cell_m7 "$PROFILE_RESOLVER" ;;
    # gen-harness --agents-rules
    b4) cell_b4 "$ROOT/scripts/gen-harness.ts" ;;
    # gen-harness --agents-rules — отсутствие файла и несуществующий файл
    k10|k10b) "cell_$cell" ;;
    *) return 1 ;;  # Ч-6: fail-closed на неизвестной клетке
  esac
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
    # С5 ревьюера 054 к2 (тот же файл): внутренний диспетчер обязан
    # быть fail-closed — неизвестное workshop-имя клетки должно краснить
    # диспетчер, а не возвращать 0 (как было). Молчаливое приёмствие
    # неизвестной клетки рождает ложное прохождение, если внешний
    # диспетчер честной части направит сюда имя, не покрытое case-ветвями.
    *) return 1 ;;
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
         { [ "$rc" -eq 1 ] && grep -qF 'неизвестный ключ слой-проекта: defaults.workflowPaths.unseen' <<<"$out"; } || return 1 ;;
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
    b10) # TOCTOU race at project-layer symlink — делегирует в cell_b10
          # (cell_b10 уже корректно создаёт свой собственный $WORK/b10-*
          # сценарий; здесь просто вызываем его с $PROFILE_RESOLVER).
          cell_b10 "$PROFILE_RESOLVER" || return 1 ;;
    # ── слияние barriers — формы A/G/F/C/M (контракт 057 §5, Ч-1) ──────────
    m1) cell_m1 "$PROFILE_RESOLVER" ;;
    m2) cell_m2 "$PROFILE_RESOLVER" ;;
    m3) cell_m3 "$PROFILE_RESOLVER" ;;
    m4) cell_m4 "$PROFILE_RESOLVER" ;;
    m5) cell_m5 "$PROFILE_RESOLVER" ;;
    # С5 ревьюера 054 к2 (тот же файл): внутренний диспетчер обязан быть
    # fail-closed — неизвестное resolver-имя клетки должно краснить диспетчер.
    # Молчаливое `*) return 0` (как было) рождает ложное прохождение, если
    # внешний диспетчер направит сюда имя, не покрытое case-ветвями.
    #
    # 054-фикс-Б9: ветвь `m7) cell_m7 ...` удалена — мёртвая (dispatch_honest_cell
    # направляет m7 напрямую в cell_m7, минуя cell_resolver_run). Список
    # routing-имен зафиксирован в dispatch_honest_cell: `k2|k3|k3b|k4|k4b|
    # k5|k6|k9|k11|b1|b2|b3|b7|b9|b10|m1|m2|m3|m4|m5`; m6 и m7 идут
    # прямой веткой.
    *) return 1 ;;
  esac
}

run_stub_pack || exit 1
run_honest
echo "054-батарея зелёная" >&2
exit 0
