#!/usr/bin/env bash
# М1 — резолвер профиля два слоя (контракт 054, В2 — слой проекта + слой репо).
#
#   bash scripts/profile_resolver.sh --repo <корень>
#
# Читает два слоя: <корень>/harness.project.json и
# ${HARNESS_PROJECT_LAYER_ROOT}/<projectLayer.profilePath> (умолчание
# registry/harness-project.json). Замкнутые алфавиты перечислены ниже ОДНИМ
# массивом; ключ вне алфавита любого уровня — rc 1, P4 с точным путём ключа.
# Слияние скалярное: ключ репо перекрывает defaults слоя проекта; вывод —
# {"<лист>": {"value": ..., "origin": "repo"|"project"}}. `projectId`/`workspaceId`
# всегда origin `project`, `repoId` — `repo`. Пин версии слоя проекта
# (`projectLayer.version` репо == `version` слоя) сверяется буквально (И-5).
#
# Возвращает:
#   0 — успех, JSON на stdout
#   1 — отказ с именованной причиной на stderr (P1..P7, дословно)
#
# Сообщения P1..P7 — строки контракта, и фикстуры сверяют их grep -F; любые
# сокращения/перефразирования ЗДЕСЬ ломают проверку. Байт-в-байт.
set -uo pipefail

# ── алфавиты И-3 — ОДИН массив (прецедент lib_zones/lib_registry) ────────────
# Структура: <уровень>:<ключ-верхнего>:<путь-внутри>:<обязательное:да/нет>
# Уровень «repo» сканирует репо-слой и обязательные поля И-4; уровень «project»
# сканирует слой проекта; уровень «defaults» сканирует defaults слоя проекта.
#
# ПАРСЕР — jq (И-7): разделители представления — синтаксис JSON, байты данных
# не переиспользуются как разделители. Точечный якорь терминатора — конец JSON
# (jq сам отказывает на мусоре).
#
# ОБЯЗАТЕЛЬНОСТЬ уровня «repo»: schemaVersion, repoId, language, projectLayer
# (без projectLayer И-5 не судить — репо-слой принимается как минимум по этим).
# Остальные ветви репо опциональны — умолчание из defaults слоя проекта.
#
# ОБЯЗАТЕЛЬНОСТЬ уровня «project»: schemaVersion, version, projectId, workspaceId.
# defaults — опциональная ветвь.
#
# Словарь `barriers.mandatory`/`barriers.optional` сливается как ЕДИНИЦА: ключ
# репо-слоя замещает массив целиком (поэлементное слияние — вне этапа 1, Граница-6).
SCHEMA_LEVELS='
  repo:schemaVersion:required
  repo:repoId:required
  repo:language:required
  repo:projectLayer:required
  repo:workflowPaths:optional
  repo:commands:optional
  repo:git:optional
  repo:ci:optional
  repo:barriers:optional

  repo:projectLayer:version:required
  repo:projectLayer:profilePath:required

  repo:workflowPaths:contracts:required
  repo:workflowPaths:verdicts:required
  repo:workflowPaths:registry:required
  repo:workflowPaths:fixtures:required

  repo:commands:test:required
  repo:commands:build:required
  repo:commands:typecheck:required
  repo:commands:lint:required

  repo:git:canonicalRemote:required

  repo:ci:workflow:required

  repo:barriers:mandatory:required
  repo:barriers:optional:required

  project:schemaVersion:required
  project:version:required
  project:projectId:required
  project:workspaceId:required
  project:defaults:optional

  project:defaults:language:required
  project:defaults:workflowPaths:required
  project:defaults:commands:required
  project:defaults:git:required
  project:defaults:ci:required
  project:defaults:barriers:required

  project:defaults:workflowPaths:contracts:required
  project:defaults:workflowPaths:verdicts:required
  project:defaults:workflowPaths:registry:required
  project:defaults:workflowPaths:fixtures:required

  project:defaults:commands:test:required
  project:defaults:commands:build:required
  project:defaults:commands:typecheck:required
  project:defaults:commands:lint:required

  project:defaults:git:canonicalRemote:required

  project:defaults:ci:workflow:required

  project:defaults:barriers:mandatory:required
  project:defaults:barriers:optional:required
'

die_p() { printf 'profile ОТКАЗ: %s\n' "$*" >&2; exit 1; }

# ── разбор argv ──────────────────────────────────────────────────────────────
REPO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; [ $# -ge 2 ] && shift ;;
    --) shift; break ;;
    *) REPO="$1" ;;
  esac
  shift
done
[ -n "$REPO" ] || die_p "usage: bash scripts/profile_resolver.sh --repo <корень>"
[ -d "$REPO" ] || die_p "каталог репо не существует: $REPO"

# ── И-1: репо-слой ──────────────────────────────────────────────────────────
REPO_JSON="$REPO/harness.project.json"
[ -f "$REPO_JSON" ] || die_p "нет harness.project.json: $REPO_JSON. Инструкция: создайте harness.project.json в корне репо — состав ключей: scripts/profile_resolver.sh"

# ── И-2: слой проекта и его корень ─────────────────────────────────────────
LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-}"
[ -n "$LAYER_ROOT" ] && [ -d "$LAYER_ROOT" ] \
  || die_p "корень слоя проекта не задан/недоступен. Инструкция: export HARNESS_PROJECT_LAYER_ROOT=<корень клона слоя проекта (odelix-stack)>"

# Байтовая валидация JSON обоих слоёв ДО прочих чтений (И-7). jq сам отказывает
# на мусоре; отказ проксирован фразой P7 с именем файла.
jq -e . "$REPO_JSON" >/dev/null 2>&1 || die_p "файл не JSON: $REPO_JSON"
PROFILE_PATH_REL="$(jq -r '.projectLayer.profilePath // "registry/harness-project.json"' "$REPO_JSON")"
# Только относительный путь (граница-2: абсолютный путь в версионируемом файле
# запрещён). Здесь — отбрасываем ведущий слэш и принимаем как относительный
# от HARNESS_PROJECT_LAYER_ROOT.
case "$PROFILE_PATH_REL" in
  /*) die_p "profilePath обязан быть относительным, не абсолютным: $PROFILE_PATH_REL" ;;
esac
PROJECT_JSON="$LAYER_ROOT/${PROFILE_PATH_REL#./}"
[ -f "$PROJECT_JSON" ] || die_p "нет файла слоя проекта: $PROJECT_JSON"
jq -e . "$PROJECT_JSON" >/dev/null 2>&1 || die_p "файл не JSON: $PROJECT_JSON"

# ── И-7: проверка замкнутых алфавитов ДО прочих правил ──────────────────────
# Здесь же, рядом, ради структурного фикса класса «cap ниже длины поля»:
# цикл идёт по всему SCHEMA_LEVELS, а не по хардкоду ключей.
#
# Уровень «repo» — в $REPO_JSON; уровень «project» — в $PROJECT_JSON.
# Проверяет, что в $level:$parent_path:$key есть в SCHEMA_LEVELS. Если нет —
# die_p с ключом-точками. Сканирует ВСЕ вложенные объектные ключи по каждому
# известному пути верхнего уровня (корневой, projectLayer, defaults, плюс
# дочерние объектные ветви defaults).
# Тест наличия ключа в SCHEMA_LEVELS. Использовать только ВНУТРИ основного
# процесса (не через pipeline): subshell `(...| grep ...)` ловил бы exit 1
# внутри себя — die_p внутри под-шелла НЕ убивал бы родителя, и проверка
# молча проваливалась. Поэтому поиск — функцией с here-string.
_key_in_schema() {  # <искомая-строка>
  local needle="$1"
  printf '%s' "$SCHEMA_LEVELS" | grep -qF "$needle"
}

scan_levels() {
  local level="$1" file="$2"
  # Корневые ключи
  local roots
  roots="$(jq -r 'keys_unsorted[]' "$file" 2>/dev/null)" || die_p "файл не JSON: $file"
  while IFS= read -r k; do
    [ -z "$k" ] && continue
    _key_in_schema "  ${level}:${k}:" || die_p "неизвестный ключ ${level}: ${k}"
  done <<<"$roots"

  # Дочерние ветви корня. Здесь НЕЛЬЗЯ использовать `piped-while`: каждый
  # сегмент pipeline — subshell, и die_p внутри while-read выходил бы
  # ТОЛЬКО из него (родитель — scan_levels — продолжал бы работу молча; см.
  # отладочную историю). Поэтому обход — здесь же, через одну переменную-список.
  # Каждая ветвь — если она задана как объект, проверяются её ключи.
  local known_branches="projectLayer workflowPaths commands git ci barriers"
  if [ "$level" = "project" ]; then
    known_branches="$known_branches defaults.workflowPaths defaults.commands defaults.git defaults.ci defaults.barriers"
    # Ключи самой defaults-ветви (отдельно от дочерних)
    if jq -e 'has("defaults") and (.defaults|type)=="object"' "$file" >/dev/null 2>&1; then
      local dk
      dk="$(jq -r '.defaults | keys_unsorted[]' "$file" 2>/dev/null)"
      while IFS= read -r k; do
        [ -z "$k" ] && continue
        _key_in_schema "  project:defaults:${k}:" || die_p "неизвестный ключ project: defaults.${k}"
      done <<<"$dk"
    fi
  fi
  local branch branch_path bk k2
  for branch in $known_branches; do
    if [ "$branch" = "projectLayer" ] && [ "$level" = "project" ]; then
      continue  # projectLayer только в repo
    fi
    # Путь к ветви для jq (projectLayer — без префикса у project;
    # defaults.X — с префиксом).
    branch_path="$branch"
    [ "$level" = "project" ] && [[ "$branch" == defaults.* ]] && branch_path="$branch" || :
    if ! jq -e "has(\"$branch\") and (.${branch}|type)==\"object\"" "$file" >/dev/null 2>&1; then
      continue
    fi
    bk="$(jq -r ".${branch} | keys_unsorted[]" "$file" 2>/dev/null)"
    while IFS= read -r k2; do
      [ -z "$k2" ] && continue
      _key_in_schema "  ${level}:${branch}:${k2}:" || die_p "неизвестный ключ ${level}: ${branch}.${k2}"
    done <<<"$bk"
  done
}
scan_levels repo   "$REPO_JSON"
scan_levels project "$PROJECT_JSON"

# ── И-4: значения и обязательные поля ───────────────────────────────────────
# schemaVersion = 1 литерально в обоих слоях. language ∈ {rust, typescript}.
# repoId, projectId, workspaceId, canonicalRemote, version, profilePath,
# ci.workflow — непустые строки.
declare -A A
A[repo_schemaVersion]="$(jq -r '.schemaVersion' "$REPO_JSON")"
A[project_schemaVersion]="$(jq -r '.schemaVersion' "$PROJECT_JSON")"
[ "${A[repo_schemaVersion]}" = "1" ] || die_p "значение вне алфавита: schemaVersion: ${A[repo_schemaVersion]}"
[ "${A[project_schemaVersion]}" = "1" ] || die_p "значение вне алфавита: schemaVersion: ${A[project_schemaVersion]}"

A[repo_language]="$(jq -r '.language' "$REPO_JSON")"
case "${A[repo_language]}" in
  rust|typescript) ;;
  *) die_p "значение вне алфавита: language: ${A[repo_language]}" ;;
esac

# Обязательные строки репо-слоя
for fld in repoId; do
  v="$(jq -r --arg f "$fld" 'if has($f) and (.[$f] | type) == "string" and (.[$f] | length) > 0 then .[$f] else empty end' "$REPO_JSON")"
  [ -n "$v" ] || die_p "значение вне алфавита: $fld: пусто"
done

# Обязательные строки слоя проекта
for fld in version projectId workspaceId; do
  v="$(jq -r --arg f "$fld" '.[$f] // empty' "$PROJECT_JSON")"
  [ -n "$v" ] || die_p "значение вне алфавита: $fld: пусто"
done

# ci.workflow репо и canonicalRemote репо — непустые строки (если ветвь объявлена)
if jq -e '.ci | type == "object"' "$REPO_JSON" >/dev/null 2>&1; then
  cw="$(jq -r '.ci.workflow // empty' "$REPO_JSON")"
  [ -n "$cw" ] || die_p "значение вне алфавита: ci.workflow: пусто"
fi
if jq -e '.git | type == "object"' "$REPO_JSON" >/dev/null 2>&1; then
  cr="$(jq -r '.git.canonicalRemote // empty' "$REPO_JSON")"
  [ -n "$cr" ] || die_p "значение вне алфавита: canonicalRemote: пусто"
fi

# barriers элементы — непустые строки класса ^[a-z0-9][a-z0-9_-]*$
check_barrier_array() {
  local level="$1" path="$2"
  if jq -e ".$path | type == \"array\"" "$REPO_JSON" >/dev/null 2>&1 \
     || jq -e ".$path | type == \"array\"" "$PROJECT_JSON" >/dev/null 2>&1; then
    local file="$REPO_JSON"
    [ "$level" = "project" ] && file="$PROJECT_JSON"
    local arr
    arr="$(jq -r "if .$path | type == \"array\" then (.$path | join(\"\\n\")) else empty end" "$file" 2>/dev/null)"
    while IFS= read -r item; do
      [ -z "$item" ] && continue
      printf '%s' "$item" | grep -Eq '^[a-z0-9][a-z0-9_-]*$' \
        || die_p "значение вне алфавита: $path: $item"
    done <<<"$arr"
  fi
}
# Для репо-слоя — если barriers.mandatory/optional заданы
check_barrier_array repo    barriers.mandatory
check_barrier_array repo    barriers.optional
check_barrier_array project defaults.barriers.mandatory
check_barrier_array project defaults.barriers.optional

# ── И-5: пин версии слоя проекта ───────────────────────────────────────────
PIN="$(jq -r '.projectLayer.version' "$REPO_JSON")"
LAYER_VER="$(jq -r '.version' "$PROJECT_JSON")"
[ "$PIN" = "$LAYER_VER" ] || die_p "пин слоя проекта расходится: репо пинит '$PIN', слой несёт '$LAYER_VER'"

# ── И-6: слияние с происхождением ──────────────────────────────────────────
# Скалярный лист берётся из репо, если ключ там есть, иначе из defaults слоя
# проекта. projectId/workspaceId — всегда origin project, repoId — repo.
#
# СБОРКА В ОДИН БОЛЬШОЙ jq-вызов — чтобы грамматика алфавита оставалась
# зафиксированной в ОДНОМ месте (одна — иначе правило 7 «неизвестный ключ
# должен ругаться» получает двойной источник истины и расходится молча).
#
# Все значения ниже вынуты ПОТОКОВО из обоих файлов ключами; происхождение —
# JSON-литерал "repo" / "project" выводится из факта наличия ключа в источнике.
MERGED=$(jq -n \
  --slurpfile repo "$REPO_JSON" \
  --slurpfile project "$PROJECT_JSON" \
  --arg layerRoot "$LAYER_ROOT" \
  '
  ($repo[0]) as $r |
  ($project[0]) as $p |
  def v($path):
    (try ($r | getpath($path)) catch null) as $rv |
    (try (if ($p.defaults | type) == "object" then $p.defaults | getpath($path) else null end) catch null) as $pv |
    if $rv != null then { value: $rv, origin: "repo" }
    elif $pv != null and ($pv | type) != "null" then { value: $pv, origin: "project" }
    else null end;
  def vscal(p): v(p);

  {
    language:     (if $r.language != null then { value: $r.language, origin: "repo" } elif $p.defaults.language != null then { value: $p.defaults.language, origin: "project" } else null end),
    projectId:    { value: $p.projectId, origin: "project" },
    workspaceId:  { value: $p.workspaceId, origin: "project" },
    repoId:       { value: $r.repoId, origin: "repo" },
    schemaVersion:{ value: $p.schemaVersion, origin: "project" },
    projectLayer: { value: { version: $r.projectLayer.version, profilePath: $r.projectLayer.profilePath, layerRoot: $layerRoot }, origin: "repo" },
    workflowPaths: {
      contracts:  v(["workflowPaths","contracts"]),
      verdicts:   v(["workflowPaths","verdicts"]),
      registry:   v(["workflowPaths","registry"]),
      fixtures:   v(["workflowPaths","fixtures"])
    },
    commands: {
      test:      vscal(["commands","test"]),
      build:     vscal(["commands","build"]),
      typecheck: vscal(["commands","typecheck"]),
      lint:      vscal(["commands","lint"])
    },
    git:       (if $r.git and $r.git.canonicalRemote != null then { value: { canonicalRemote: $r.git.canonicalRemote }, origin: "repo" } else null end),
    ci:        (if $r.ci and $r.ci.workflow != null then { value: { workflow: $r.ci.workflow }, origin: "repo" } else null end),
    barriers: {
      mandatory: (
        if $r.barriers and $r.barriers.mandatory != null then { value: $r.barriers.mandatory, origin: "repo" }
        elif $p.defaults and $p.defaults.barriers and $p.defaults.barriers.mandatory != null then { value: $p.defaults.barriers.mandatory, origin: "project" }
        else { value: [], origin: "project" } end
      ),
      optional: (
        if $r.barriers and $r.barriers.optional != null then { value: $r.barriers.optional, origin: "repo" }
        elif $p.defaults and $p.defaults.barriers and $p.defaults.barriers.optional != null then { value: $p.defaults.barriers.optional, origin: "project" }
        else { value: [], origin: "project" } end
      )
    }
  }
  | del(.. | nulls)
  ')

printf '%s\n' "$MERGED"
