#!/usr/bin/env bash
# scripts/make_task.sh - СБОРЩИК КОНТЕКСТА (контракт 095, путь Г шаг 4).
# ОДИН субъект на два режима: --kind task (задачный пак по контракту) и
# --kind brief (orch_brief, только оркестратору). Потребляет ПРОФИЛЬ через
# scripts/profile_resolver.sh (Решение 1). ГРАММАТИКА CLI/отказов/секций
# закреплена честной моделью fixtures/context_pack_095/model/dover.sh.
# КОНТРАКТ 103 (Решение 1): три чтения harness-layout (черновик, заморозка,
# бриф) берут каталоги контрактов/реестра из эффективного workflowPaths профиля
# (MERGED profile_resolver) с гардом И-5 против побега пути за корень репо.
# НЕ БАРЬЕР: субъект контракта 095 — зелёный контроль и стаб-детект собственной именованной батареи fixtures/context_pack_095/ (раннер fixtures/_krasnye_095.sh, стаб-пак battery_stubs.sh, 18 мутаций), не case_*.sh-глобом (прецедент drill_exit_marker.sh/drill_path_guard.sh, заморозка 025 И-7). Выходы: 0 — пак построен (stdout), 1 — именованный отказ «ОТКАЗ: ...», 2 — NOT_IMPLEMENTED.
set -uo pipefail
TAB="$(printf '\t')"
die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
ni()  { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }
command -v git >/dev/null 2>&1 || ni "нет git"
command -v jq >/dev/null 2>&1 || ni "нет jq"
command -v sha256sum >/dev/null 2>&1 || ni "нет sha256sum"
command -v awk >/dev/null 2>&1 || ni "нет awk"

usage() { printf 'usage: make_task.sh --repo R --role ROLE [--kind task|brief] [--contract NNN] [--task-file F] [--model-trace F] [--author-role R2] [--print-context]\n' >&2; exit 1; }

REPO=""; ROLE=""; KIND="task"; CONTRACT=""; TASKFILE=""; TRACE=""; AUTHOR_ROLE_ARG=""; PRINT_CONTEXT=0
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)        REPO="${2:?}"; shift 2 ;;
    --role)        ROLE="${2:?}"; shift 2 ;;
    --kind)        KIND="${2:?}"; shift 2 ;;
    --contract)    CONTRACT="${2:?}"; shift 2 ;;
    --task-file)   TASKFILE="${2:?}"; shift 2 ;;
    --model-trace) TRACE="${2:?}"; shift 2 ;;
    --author-role) AUTHOR_ROLE_ARG="${2:?}"; shift 2 ;;
    --print-context) PRINT_CONTEXT=1; shift ;;
    *) usage ;;
  esac
done
[ -n "$REPO" ] && [ -n "$ROLE" ] || usage
[ -d "$REPO" ] || die "репозитория нет: $REPO"
case "$ROLE" in orchestrator|architect|critic|implementer|adversary|reviewer|arbiter) ;; *) die "роль вне алфавита: $ROLE" ;; esac
case "$KIND" in task|brief) ;; *) die "kind вне алфавита: $KIND" ;; esac

REPO_ABS="$(cd "$REPO" && pwd -P)"

# ── 996 §Публичный шов без запуска omp: --print-context ────────────────────
# Стоит ДО любых внутренних vars (REPO_ABS и т.п.). Печатает один JSON и выходит.
# Используется workshop для передачи контекста в роль, а make_task — для печати
# из CLI. Никакого omp-launch, никакой валидации contextPack/lessons/ADR.
# ── 996 §Публичный шов без запуска omp: --print-context ────────────────────
# Стоит ДО любых внутренних vars (REPO_ABS и т.п.). Печатает один JSON и выходит.
# Используется workshop для передачи контекста в роль, а make_task — для печати
# из CLI. Никакого omp-launch, никакой валидации contextPack/lessons/ADR.
#
# КОНТРАКТ 996 круг 4 (закрытие оси): РАСЧЁТ ПУТЕЙ — ОДИН вызов
# `project_paths_resolve` (живёт в next_id.sh). Никаких собственных конкатенаций
# `$REPO_ABS/$STATE`, никаких копий гарда workflowPaths: иначе разные двери
# расходятся молча (находка Р3-1 круга 3 — make_task собирал state
# без segment-гарда, наблюдаемо на dotdot-state и state-symlink-*).
if [ "$PRINT_CONTEXT" -eq 1 ]; then
  # Библиотечный вход next_id.sh (контракт 996 Б-5/Б-9): подключаем функции
  # `parse_artifact_basename`, `project_paths_resolve` и др. через `NEXT_ID_LIB=1`,
  # а не через PATH/исполнение; единственный источник `project_paths_resolve`
  # живёт в next_id.sh, и импорт — единственный способ его получить, не
  # дублируя (так контролирует structure-one-paths-resolve).
  NEXT_ID_LIB=1
  # shellcheck disable=SC1091
  . "$(cd "$(dirname "$0")" && pwd)/next_id.sh"

  # Гард project_paths_resolve: rc 1 → отказ двери (Никакого JSON, никакого
  # startup вне корня). Тот же JSON, что у project_workflow.
  _PC_JSON="$(project_paths_resolve "$REPO_ABS")" \
    || die "workflowPaths вне репо"
  WP_C="$(printf '%s' "$_PC_JSON" | jq -r '.contracts')"
  WP_V="$(printf '%s' "$_PC_JSON" | jq -r '.verdicts')"
  WP_R="$(printf '%s' "$_PC_JSON" | jq -r '.registry')"
  WP_F="$(printf '%s' "$_PC_JSON" | jq -r '.fixtures')"
  WP_STATE_PREFIX_H="$(printf '%s' "$_PC_JSON" | jq -r '.handoff')"
  WP_STATE_PREFIX_O="$(printf '%s' "$_PC_JSON" | jq -r '.observations')"
  WP_STATE_PREFIX_AR="$(printf '%s' "$_PC_JSON" | jq -r '.architectObservations')"
  WP_STATE_PREFIX_RM="$(printf '%s' "$_PC_JSON" | jq -r '.roadmap')"
  WP_STATE_PREFIX_FK="$(printf '%s' "$_PC_JSON" | jq -r '.forks')"
  SC_OBJ="$(printf '%s' "$_PC_JSON" | jq -c '.sourceCanon')"
  unset _PC_JSON

  _verdict_suffix=""
  case "$ROLE" in
    critic)     _verdict_suffix="critic" ;;
    adversary)  _verdict_suffix="adversary" ;;
    reviewer)   _verdict_suffix="review" ;;
    arbiter)    _verdict_suffix="arbitration" ;;
  esac
  if [ -n "$_verdict_suffix" ]; then
    _verdict_canon="$WP_V/$_verdict_suffix"
  else
    _verdict_canon=""
  fi
  jq -n \
    --arg contracts    "$WP_C" \
    --arg verdicts     "$WP_V" \
    --arg registry     "$WP_R" \
    --arg fixtures     "$WP_F" \
    --arg handoff      "$WP_STATE_PREFIX_H" \
    --arg observations "$WP_STATE_PREFIX_O" \
    --arg arch_obs     "$WP_STATE_PREFIX_AR" \
    --arg roadmap      "$WP_STATE_PREFIX_RM" \
    --arg forks        "$WP_STATE_PREFIX_FK" \
    --argjson source_canon "$SC_OBJ" \
    --arg verdict_canon "$_verdict_canon" \
    --arg h "$WP_STATE_PREFIX_H" \
    --arg c "$WP_C" \
    --arg v "$WP_V" \
    --arg o "$WP_STATE_PREFIX_O" \
    --arg r "$WP_STATE_PREFIX_RM" \
    '{workflow: {contracts: $contracts, verdicts: $verdicts, registry: $registry, fixtures: $fixtures,
                  handoff: $handoff, observations: $observations, architectObservations: $arch_obs,
                  roadmap: $roadmap, forks: $forks},
      sourceCanon: $source_canon,
      verdict: (if ($verdict_canon | length) > 0 then $verdict_canon else null end),
      startup: [$h, $c, $v, $o, $r]}'
  exit 0
fi

SKIP_TASK=0
if [ "$KIND" = "brief" ]; then
  [ "$ROLE" = "orchestrator" ] || die "брифинг только оркестратору"
  SKIP_TASK=1
fi

AUTHOR_ROLE="$AUTHOR_ROLE_ARG"
if [ -z "$AUTHOR_ROLE" ]; then
  case "$ROLE" in
    reviewer) AUTHOR_ROLE="implementer" ;;
    critic)   AUTHOR_ROLE="architect"   ;;
    *)        AUTHOR_ROLE="" ;;
  esac
fi
[ -z "$AUTHOR_ROLE" ] || case "$AUTHOR_ROLE" in orchestrator|architect|critic|implementer|adversary|reviewer|arbiter) ;; *) die "автор вне алфавита: $AUTHOR_ROLE" ;; esac

# И-14: настоящий профиль — ДВА слоя 054 + contextPack контекстных ключей.
# Контракт 095 (Решение 1): profile_resolver.sh — единственный источник
# merge-логики. profile_resolver.sh требует (а) HARNESS_PROJECT_LAYER_ROOT
# (по умолчанию $REPO) и (б) реальное существование объявленного ci.workflow
# файла (Step G..I резолвера). Toy-мир семьи 095 (architect) не объявляет
# ci.yml на диске — создаём пустой placeholder, вызываем profile_resolver,
# вычищаем placeholder (EXIT-trap). На реальном репо (ci.yml присутствует)
# placeholder не создаётся; profile_resolver валидирует существующий файл.
PROFILE_RESOLVER="$(cd "$(dirname "$0")" && pwd)/profile_resolver.sh"
[ -x "$PROFILE_RESOLVER" ] || die "нет profile_resolver.sh: $PROFILE_RESOLVER"
[ -f "$REPO/harness.project.json" ] || die "профиль репо не найден: harness.project.json"
if [ -z "${HARNESS_PROJECT_LAYER_ROOT:-}" ]; then
  export HARNESS_PROJECT_LAYER_ROOT="$REPO"
fi

# HEALTH — СНИМАЕМ ДО создания placeholder ci.yml (он грязнит дерево).
# HEALTH описывает мир в момент ВХОДА, не в момент выхода. Это согласуется
# с контрактом 095: «HEALTH: branch=<живой git> dirty=<N>» — N считается по
# состоянию репо на момент сборки пакета, до наших локальных артефактов.
HEALTH_BRANCH="$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || printf '?')"
HEALTH_DIRTY="$(git -C "$REPO" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"

_CW_PLACEHOLDER=""
_CW_VALUE="$(jq -r '.ci.workflow // empty' "$REPO/harness.project.json" 2>/dev/null || true)"
if [ -n "$_CW_VALUE" ] && [ ! -e "$REPO/$_CW_VALUE" ]; then
  case "$_CW_VALUE" in
    /*)    die "ci.workflow обязан быть относительным: $_CW_VALUE" ;;
    *../*) die "ci.workflow содержит ..: $_CW_VALUE" ;;
  esac
  mkdir -p "$(dirname "$REPO/$_CW_VALUE")" || die "нет каталога для ci.workflow: $_CW_VALUE"
  : > "$REPO/$_CW_VALUE" || die "не удалось создать placeholder: $_CW_VALUE"
  _CW_PLACEHOLDER="$_CW_VALUE"
fi
_MT_ERR_FILE="$(mktemp 2>/dev/null || echo /tmp/mt_err.$$.$RANDOM)"
trap '[ -n "${_CW_PLACEHOLDER:-}" ] && [ -e "$REPO/$_CW_PLACEHOLDER" ] && rm -f "$REPO/$_CW_PLACEHOLDER"; rm -f "${_MT_ERR_FILE:-}"' EXIT

MERGED=""
if ! MERGED="$("$PROFILE_RESOLVER" --repo "$REPO" 2>"$_MT_ERR_FILE")"; then
  err="$(cat "$_MT_ERR_FILE" 2>/dev/null || true)"
  die "${err#profile ОТКАЗ: }"
fi
[ -n "$MERGED" ] || die "профиль пуст"
# CP — contextPack.value (без обёртки value/origin резолвера).
CP="$(printf '%s' "$MERGED" | jq -c '.contextPack.value // null' 2>/dev/null)" || die "контекст не извлечь"

# ── КОНТРАКТ 103 (Решение 1): профильные пути вместо harness-layout ──
# Расположение каталогов контрактов и реестра — из эффективного workflowPaths
# профиля (MERGED profile_resolver — единственный источник), не из зашитых
# корневых contracts/ и registry/ харнеса. Контракт 996 круг 4: пути и
# effective sourceCanon ОБЕИХ режимов считаются ЕДИНЫМ вызовом
# `project_paths_resolve` (живёт в next_id.sh) — без собственных копий
# гарда и без собственной конкатенации `$REPO_ABS/$STATE`. Иначе двери
# расходятся молча (находка Р3-1 круга 3).
NEXT_ID_LIB=1
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")" && pwd)/next_id.sh"
[ "$(type -t project_paths_resolve)" = "function" ] \
  || die "next_id.sh без project_paths_resolve"
# ЕДИНСТВЕННЫЙ вызов резолвера: rc 1 → отказ двери ДО построения PROJECT.
_PP_JSON="$(project_paths_resolve "$REPO_ABS")" \
  || die "workflowPaths вне репо"
WP_C="$(printf '%s' "$_PP_JSON" | jq -r '.contracts')"
WP_V="$(printf '%s' "$_PP_JSON" | jq -r '.verdicts')"
WP_G="$(printf '%s' "$_PP_JSON" | jq -r '.registry')"
WP_F="$(printf '%s' "$_PP_JSON" | jq -r '.fixtures')"
WP_H="$(printf '%s' "$_PP_JSON" | jq -r '.handoff')"
# Относительные формы (для ls-tree имени файла внутри frozen-блоба тега
# и для краткого листинга контрактов в брифе).
WP_C_REL="${WP_C#"$REPO_ABS"/}"
WP_V_REL="${WP_V#"$REPO_ABS"/}"
WP_G_REL="${WP_G#"$REPO_ABS"/}"
WP_F_REL="${WP_F#"$REPO_ABS"/}"
WP_SC="$(printf '%s' "$_PP_JSON" | jq -c '.sourceCanon')"
unset _PP_JSON

# ── трасса моделей ───────────────────────────────────────────────────────────
# Чтение ПОСЛЕ резолвера путей: дефолт 136 живёт в <workflowPaths.registry>
# профиля (WP_G — из ЕДИНОГО project_paths_resolve выше, не вторая
# конкатенация). Порядок: профиль → пути → трасса (дефолт требует путей).
TRACE_LINE=""; JUDGE_MODEL=""; AUTHOR_MODEL=""
if [ "$PRINT_CONTEXT" -ne 1 ]; then
# 136 (НАБЛ-П5): проектный режим — трасса по умолчанию
# <workflowPaths.registry>/trace.tsv профиля (сеет дверь); явный --model-trace
# переопределяет. Вне проекта (файла нет) — прежний отказ дословно.
if [ -z "$TRACE" ] && [ -f "$WP_G/trace.tsv" ]; then
  TRACE="$WP_G/trace.tsv"
fi
  if [ -z "$TRACE" ] || [ ! -f "$TRACE" ]; then die "нет свидетельства модели: $ROLE"; fi
  while IFS="$TAB" read -r r m fb; do
    [ -z "${r:-}" ] && continue
    case "$fb" in allowed|denied) ;; *) die "трасса: грамматика" ;; esac
    if [ "$r" = "$ROLE" ]; then TRACE_LINE="TRACE: role=$r model=$m fallback=$fb"; JUDGE_MODEL="$m"; fi
    [ -n "$AUTHOR_ROLE" ] && [ "$r" = "$AUTHOR_ROLE" ] && AUTHOR_MODEL="$m"
  done < "$TRACE"
  [ -n "$TRACE_LINE" ] || die "свидетельство не той роли: $ROLE"
fi

_t95_family() { local x="${1#*/}"; x="${x%%-*}"; x="${x%%.*}"; printf '%s' "$x"; }
if [ "$ROLE" = "reviewer" ] || [ "$ROLE" = "critic" ]; then
  [ -n "$AUTHOR_MODEL" ] || die "свидетельство не той роли: $AUTHOR_ROLE"
  fam_j="$(_t95_family "$JUDGE_MODEL")"
  fam_a="$(_t95_family "$AUTHOR_MODEL")"
  [ "$fam_j" != "$fam_a" ] || die "судья на модели автора: $fam_j"
fi

WP_VERDICT_SUFFIX=""
case "$ROLE" in
  critic)     WP_VERDICT_SUFFIX="critic" ;;
  adversary)  WP_VERDICT_SUFFIX="adversary" ;;
  reviewer)   WP_VERDICT_SUFFIX="review" ;;
  arbiter)    WP_VERDICT_SUFFIX="arbitration" ;;
esac
WP_VERDICT_CANON=""
[ -n "$WP_VERDICT_SUFFIX" ] && WP_VERDICT_CANON="$WP_V/$WP_VERDICT_SUFFIX"

# PROJECT-секция — рабочий шов §D для ролей (шесть игл: sourceCanon,
# источник SOURCE.md (ПУТЬ, не тело — Р3-2 круг 3), каталог вердикта/
# role-suffix, каталог контрактов, реестр, фикстуры, HANDOFF). Тот же
# расчёт, что и --print-context выше; выходной формат — текстовый блок
# (в JSON-печать включается sourceCanon.value строкой).
PROJECT_SEC=""
if [ "$KIND" = "task" ]; then
  _psrc_path="$(printf '%s' "$WP_SC" | jq -r '.sources[0].path // ""' 2>/dev/null)"
  # Гард источника: symlink наружу репо (Р3-2 круг 3) — отказ ДО записи
  # PROJECT-секции. Тело источника НЕ вклеивается (роли получают ПУТЬ и
  # sourceCanon целиком, ровно так, как требует §D), здесь проверяется
  # лишь реальное расположение файла внутри REPO.
  if [ -n "$_psrc_path" ] && [ -e "$REPO/$_psrc_path" ]; then
    _psrc_real="$(readlink -f -- "$REPO/$_psrc_path" 2>/dev/null || true)"
    case "$_psrc_real" in
      "$REPO_ABS"/*) ;;
      *) die "источник вне репо: source=$_psrc_path" ;;
    esac
  fi
  PROJECT_SEC="=== PROJECT ===
"
  PROJECT_SEC="${PROJECT_SEC}sourceCanon: $WP_SC
"
  if [ -n "$_psrc_path" ]; then
    PROJECT_SEC="${PROJECT_SEC}source: $_psrc_path
"
  fi
  PROJECT_SEC="${PROJECT_SEC}verdicts: $WP_V
"
  PROJECT_SEC="${PROJECT_SEC}verdict: ${WP_VERDICT_CANON}
"
  PROJECT_SEC="${PROJECT_SEC}contracts: $WP_C
"
  PROJECT_SEC="${PROJECT_SEC}registry: $WP_G
"
  PROJECT_SEC="${PROJECT_SEC}fixtures: $WP_F
"
  PROJECT_SEC="${PROJECT_SEC}handoff: $WP_H
"
  PROJECT_SEC="${PROJECT_SEC}=== END PROJECT ===
"
fi

MAP_LINES=""; RULES_LINES=""; REUSE_LINES=""; MAP_MAN=""
NROWS="$(printf '%s' "$CP" | jq -r 'if . == null then 0 else (.rows // []) | length end')"
if [ "$NROWS" = "0" ]; then
  die "нет карты контекста: contextPack"
fi
ROWS_TSV="$(printf '%s' "$CP" | jq -r '(.rows // [])[]? | [.kind, .path, .roles, (.mandatory|tostring), (.why // "")] | @tsv')"
while IFS="$TAB" read -r kind path roles mnd why; do
  [ -z "${kind:-}" ] && continue
  case "$kind" in map|rules|reuse) ;; *) die "карта: грамматика: kind $kind" ;; esac
  case "$path" in ''|*[!A-Za-z0-9._/-]*) die "карта: грамматика: путь $path" ;; esac
  case "$mnd" in true|false) ;; *) die "карта: грамматика: обязательность $mnd" ;; esac
  for rr in ${roles//,/ }; do
    case "$rr" in
      orchestrator|architect|critic|implementer|adversary|reviewer|arbiter) ;;
      *) die "карта: грамматика: роль $rr" ;;
    esac
  done
  # 136 (НАБЛ-П17): бриф оркестратору несёт ВСЕ rows без фильтра ролей —
  # оркестратор раздаёт задания и обязан видеть всю карту контекста;
  # kind=task фильтр ролей несёт дословно (грамматика 095 не ослаблена).
  if [ "$KIND" != "brief" ]; then
    case ",$roles," in *",$ROLE,"*) ;; *) continue ;; esac
  fi
  if [ ! -f "$REPO/$path" ]; then
    if [ "$mnd" = "true" ]; then die "источник недоступен: $path"; fi
    continue
  fi
  case "$kind" in
    map)   MAP_LINES="${MAP_LINES}MAP: $path :: $why
" ;;
    rules) RULES_LINES="${RULES_LINES}RULES: $path
" ;;
    reuse) REUSE_LINES="${REUSE_LINES}REUSE: $path
" ;;
  esac
  om="mandatory"; [ "$mnd" = "false" ] && om="optional"
  MAP_MAN="${MAP_MAN}${kind}${TAB}${path}${TAB}${om}${TAB}profile
"
done <<<"$ROWS_TSV"

SKILLS=""
case "$ROLE" in
  architect)   SKILLS="SKILL: grilling
SKILL: writing-for-agents
SKILL: tdd
" ;;
  implementer) SKILLS="SKILL: tdd
SKILL: diagnosing-bugs
" ;;
  adversary)   SKILLS="SKILL: diagnosing-bugs
" ;;
esac

CONTEXT_SEC=""; ZONES_SEC=""; LESSONS_SEC=""; LESSONS_MAN=""; TASK_SEC=""; TASK_MAN=""; CTX_MAN=""
ZONE_PATHS=""
GOAL_SEC=""; WORK_SEC=""; DEC_SEC=""; HEALTH_SEC=""
ADRP="$(printf '%s' "$CP" | jq -r 'if . == null then "" else (.adrPath // "") end')"
LLP="$(printf '%s' "$CP" | jq -r 'if . == null then "" else (.lessonsPath // "") end')"
ADR_SEC=""; ADR_MAN=""
if [ -n "$ADRP" ] && [ -d "$REPO/$ADRP" ]; then
  ADR_MAN="adr${TAB}${ADRP}${TAB}optional${TAB}profile
"
fi

_adr_load() {
  local f id st area res line
  for f in $(LC_ALL=C ls "$REPO/$ADRP" 2>/dev/null | LC_ALL=C sort); do
    case "$f" in *.md) ;; *) continue ;; esac
    id="${f%%-*}"
    case "$id" in ''|*[!0-9]*) die "ADR: грамматика: $f" ;; esac
    st="принято"; area=""; res=""
    while IFS= read -r line; do
      case "$line" in
        'статус: '*) st="${line#статус: }" ;;
        'область: '*) area="${line#область: }" ;;
        'решение: '*) res="${line#решение: }" ;;
      esac
    done <"$REPO/$ADRP/$f"
    case "$st" in принято|предложено|заменено*) ;; *) die "ADR: грамматика: статус $st" ;; esac
    case "$st" in принято) ;; *) continue ;; esac
    [ -n "$res" ] || die "ADR: грамматика: решение пусто: $f"
    printf '%s\t%s\t%s\n' "$id" "$area" "$res"
  done
}

if [ "$SKIP_TASK" = "0" ]; then
  [ -n "$CONTRACT" ] || die "контракт не указан"
  case "$CONTRACT" in ''|*[!0-9]*) die "номер контракта вне алфавита: $CONTRACT" ;; esac
  TAG="$(git -C "$REPO" tag -l "frozen/contracts/$CONTRACT/*" | LC_ALL=C sort -V | tail -n 1)"
  ORIGIN="draft"
  if [ -n "$TAG" ]; then
    # (з) заморозка: путь контракта ВНУТРИ блоба тега — профильный
    # (<contracts>/), корень тега — НЕ фолбэк (Frontier И-1в/И-1г).
    _fz_esc="${WP_C_REL//./\\.}"
    CPATH="$(git -C "$REPO" ls-tree --name-only "$TAG" "$WP_C_REL/" | grep -E "^$_fz_esc/${CONTRACT}-[^/]+\.md$" | head -n 1)"
    [ -n "$CPATH" ] || die "заморозка без контракта: $TAG"
    CBYTES="$(git -C "$REPO" show "$TAG:$CPATH" 2>&1)"
    ORIGIN="frozen"
  else
    case "$ROLE" in architect|critic) ;; *) die "контракт не заморожен: $CONTRACT" ;; esac
    # (д) черновик: только <contracts>/<NNN>-*.md профиля (Frontier И-1а/И-1б).
    CPATH="$(cd "$REPO" && ls "$WP_C_REL"/${CONTRACT}-*.md 2>/dev/null | head -n 1)"
    [ -n "$CPATH" ] || die "черновик контракта не найден: $CONTRACT"
    CBYTES="$(cat "$REPO/$CPATH")"
  fi
  unset _fz_esc
  ZONES_SEC="$(printf '%s\n' "$CBYTES" | grep '^ЗОНА ' || true)"
  CONTEXT_SEC="$(printf '%s\n' "$CBYTES" | grep '^КОНТЕКСТ:' || true)"
  CONTEXT_SEC="${CONTEXT_SEC}
$(printf '%s\n' "$CBYTES" | awk '/^## Существующее$/{f=1;print;next} /^## /{f=0} f{print}')"
  ZONE_PATHS="$(printf '%s\n' "$ZONES_SEC" | sed -n 's/^ЗОНА [^:]*: //p' | tr ' ' '\n')"
  CTX_MAN="context${TAB}${CPATH}${TAB}mandatory${TAB}${ORIGIN}
zones${TAB}${CPATH}${TAB}mandatory${TAB}${ORIGIN}
"

  if [ -n "$ADRP" ] && [ -d "$REPO/$ADRP" ]; then
    an=0
    while IFS="$TAB" read -r aid aarea ares; do
      [ -z "${aid:-}" ] && continue
      m=0
      rest="$aarea"
      while [ -n "$rest" ]; do
        if [ "$rest" = "${rest%%,*}" ]; then lbl="$rest"; rest=""; else
          lbl="${rest%%,*}"; rest="${rest#*,}"
        fi
        lbl="${lbl#"${lbl%%[! ]*}"}"
        case "$lbl" in
          'роль:'*)
            ar="${lbl#роль:}"
            case "$ar" in orchestrator|architect|critic|implementer|adversary|reviewer|arbiter) ;; *) die "ADR: грамматика: роль $ar" ;; esac
            [ "$ar" = "$ROLE" ] && m=1 ;;
          *)
            case "$lbl" in ''|*[!A-Za-z0-9._/*?-]*) die "ADR: грамматика: метка $lbl" ;; esac
            for zp in $ZONE_PATHS; do case "$zp" in $lbl) m=1 ;; esac; done ;;
        esac
      done
      [ "$m" = "1" ] || continue
      an=$((an+1)); [ "$an" -le 8 ] || die "зона слишком широкая, режь задание"
      ADR_SEC="${ADR_SEC}ADR: ${aid} :: ${ares}
"
    done < <(_adr_load)
  fi

  if [ -n "$LLP" ] && [ -f "$REPO/$LLP" ]; then
    cnt=0
    while IFS="$TAB" read -r lid glob ltext; do
      [ -z "${lid:-}" ] && continue
      case "$glob" in ''|*[!A-Za-z0-9._/*?-]*) die "уроки: грамматика: $lid" ;; esac
      m=0
      for zp in $ZONE_PATHS; do case "$zp" in $glob) m=1 ;; esac; done
      [ "$m" = "1" ] || continue
      cnt=$((cnt+1)); [ "$cnt" -le 5 ] || break
      LESSONS_SEC="${LESSONS_SEC}LESSON: $lid :: $ltext
"
    done <"$REPO/$LLP"
    LESSONS_MAN="lessons${TAB}${LLP}${TAB}optional${TAB}profile
"
  fi

  if [ "$ROLE" = "reviewer" ]; then
    [ -n "$TASKFILE" ] || die "нет выданного задания: $CONTRACT"
    [ -f "$TASKFILE" ] || die "нет выданного задания: $CONTRACT"
    TASK_SHA="$(sha256sum < "$TASKFILE" | cut -d' ' -f1)"
    TASK_BYTES="$(cat "$TASKFILE")"
    TASK_SEC="TASK: sha256=$TASK_SHA
$TASK_BYTES"
    TASK_MAN="task${TAB}${TASKFILE}${TAB}mandatory${TAB}taskfile
"
  fi
else
  # (б) бриф (Frontier И-1д): план — <registry>/plan.tsv профиля, карта WORK —
  # контракты <contracts>/*.md профиля; корневые registry/ и contracts/
  # харнеса источниками не являются.
  if [ -f "$REPO/$WP_G_REL/plan.tsv" ]; then
    GOAL_SEC="$(cat "$REPO/$WP_G_REL/plan.tsv")"
  fi
  # ── (И-12-скоуп, А-387) карта WORK: каждый контракт — строкой ──
  # Якорь заголовка — ПРЕФИКС `^## Предмет` (суффикс-аннотации вида
  # «## Предмет (дословно из докса…)» предмет НЕСУТ: 092/094/095).
  # Отказ фразой И-12 дословно — ТОЛЬКО активным: NNN в колонке id
  # plan.tsv профиля (тот же реестр — GOAL брифа). Вне плана без
  # предмета — строка-маркер: не молчаливый пропуск (И-0) и не смерть
  # брифа на 6 legacy (Б4 круга 1 ревьюера). plan.tsv нет → план пуст.
  _plan_ids=""
  [ -f "$REPO/$WP_G_REL/plan.tsv" ] && _plan_ids="$(awk -F'\t' 'NR>1 && $1 ~ /^[0-9]+$/ {print $1}' "$REPO/$WP_G_REL/plan.tsv")" || true
  for cf in $(LC_ALL=C ls "$REPO/$WP_C_REL"/*.md 2>/dev/null | LC_ALL=C sort); do
    cnum="$(basename "$cf")"; cnum="${cnum%%-*}"
    csubj="$(awk '/^## Предмет/{f=1;next} /^## /{f=0} f&&NF{print;exit}' "$cf")"
    if [ -n "$csubj" ]; then
      WORK_SEC="${WORK_SEC}WORK: ${cnum} :: ${csubj}
"
    elif printf '%s\n' "$_plan_ids" | grep -Fxq -- "$cnum"; then
      die "брифинг: контракт без предмета: $cf"
    else
      WORK_SEC="${WORK_SEC}WORK: ${cnum} :: legacy-без-§Предмет (вне plan.tsv)
"
    fi
  done
  if [ -n "$ADRP" ] && [ -d "$REPO/$ADRP" ]; then
    while IFS="$TAB" read -r aid _aarea ares; do
      [ -z "${aid:-}" ] && continue
      DEC_SEC="${DEC_SEC}ADR: ${aid} :: ${ares}
"
    done < <(_adr_load)
  fi
  HEALTH_SEC="$(printf 'HEALTH: branch=%s dirty=%s' "$HEALTH_BRANCH" "$HEALTH_DIRTY")"
fi

TRACE_MAN="trace${TAB}${TRACE}${TAB}mandatory${TAB}trace
"
pack_body() {
  printf '=== make_task contract=%s role=%s kind=%s ===\n' "${CONTRACT:-none}" "$ROLE" "$KIND"
  printf '=== TRACE ===\n%s\n' "$TRACE_LINE"
  printf '=== MAP ===\n%s' "$MAP_LINES"
  printf '=== RULES ===\n%s' "$RULES_LINES"
  printf '=== REUSE ===\n%s' "$REUSE_LINES"
  if [ -n "$SKILLS" ]; then printf '=== SKILLS ===\n%s' "$SKILLS"; fi
if [ -n "$PROJECT_SEC" ]; then printf '%s' "$PROJECT_SEC"; fi
  if [ "$SKIP_TASK" = "0" ]; then
    printf '=== CONTEXT ===\n%s\n' "$CONTEXT_SEC"
    printf '=== ZONES ===\n%s\n' "$ZONES_SEC"
    if [ -n "$ADR_SEC" ]; then printf '=== ADR ===\n%s' "$ADR_SEC"; fi
    if [ -n "$LESSONS_SEC" ]; then printf '=== LESSONS ===\n%s' "$LESSONS_SEC"; fi
    if [ "$ROLE" = "reviewer" ]; then printf '=== TASK ===\n%s\n' "$TASK_SEC"; fi
  else
    if [ -n "$GOAL_SEC" ]; then printf '=== GOAL ===\n%s\n' "$GOAL_SEC"; fi
    if [ -n "$WORK_SEC" ]; then printf '=== WORK ===\n%s' "$WORK_SEC"; fi
    if [ -n "$DEC_SEC" ]; then printf '=== DECISIONS ===\n%s' "$DEC_SEC"; fi
    printf '=== HEALTH ===\n%s\n' "$HEALTH_SEC"
  fi
}
VK="$(pack_body | wc -c | tr -d ' ')"
[ "$VK" -le 40000 ] || die "режь задачу: $VK > 40000"
pack_body
MAN_BODY="=== MANIFEST ===
${MAP_MAN}${CTX_MAN}${ADR_MAN}${LESSONS_MAN}${TASK_MAN}${TRACE_MAN}"
printf '%s' "$MAN_BODY"
printf '=== BUDGET ===\nBUDGET: vklejka=%s/40000\n' "$VK"
if [ "$KIND" = "task" ] && [ -n "$CONTRACT" ]; then
  mkdir -p "$REPO/.omp/context"
  printf '%s\n' "$MAN_BODY" >"$REPO/.omp/context/${CONTRACT}.tsv"
fi