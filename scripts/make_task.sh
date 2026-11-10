#!/usr/bin/env bash
# scripts/make_task.sh - СБОРЩИК КОНТЕКСТА (контракт 095, путь Г шаг 4).
# ОДИН субъект на два режима: --kind task (задачный пак по контракту) и
# --kind brief (orch_brief, только оркестратору). Потребляет ПРОФИЛЬ через
# scripts/profile_resolver.sh (Решение 1). ГРАММАТИКА CLI/отказов/секций
# закреплена честной моделью fixtures/context_pack_095/model/dover.sh.
# КОНТРАКТ 103 (Решение 1): три чтения harness-layout (черновик, заморозка,
# бриф) берут каталоги контрактов/реестра из эффективного workflowPaths профиля
# (MERGED profile_resolver) с гардом И-5 против побега пути за корень репо.
# КОНТРАКТ 161a: профиль/контекст/контракты — своего git-проекта (слой станции
# или чужой проект → отказ LAYER_FOREIGN); манифест пака пишется во ВНЕШНЕЕ
# state проекта (вне чекаута и его .git) — его читает spawn_agent до создания
# worktree; пропущенная строка contextPack.rows (в том числе optional) —
# именованный отказ PROFILE_PATH_MISSING, а не молчаливое усечение карты.
# ОТКАЗЫ внешнего state (поимённо, rc 1, до записи и без stdout пака):
#   * TMPDIR_UNAVAILABLE — TMPDIR непригоден (нет каталога);
#   * TMPDIR_INSIDE_MAIN — база state или ИТОГОВЫЙ каталог манифеста (с учётом
#     компонента dev-harness-project-state, каталога ключа и context) лежит
#     внутри checkout'а проекта или его общего .git;
#   * STATE_PATH_UNRESOLVABLE — каталог манифеста неразреним (битая ссылка);
#   * HASH_TOOL_UNUSABLE — инструмент sha256 непригоден.
# КОНТРАКТ 170: бриф компонента архитектуры в паке задания. Флаг
# --arch-component <id[,id...]> — список компонентов архитектуры проекта; для
# каждого ID вызывается ПРОЕКТНАЯ команда `npm --prefix <R>/architecture run
# brief -- --compact [--with-rules] --component <id>` (--with-rules — роли
# architect/critic/arbiter), её stdout ложится в пак отдельной секцией, в
# порядке входных ID. Применимость — каталог <R>/architecture/ и кодовый
# предмет («КЛАСС ЗАДАЧИ: кодовый» в выбранном контракте): без флага такой
# предмет отказывает ARCH_COMPONENT_NET, с флагом вне architecture/ —
# ARCHITECTURE_NET, неконформный список — ARCH_COMPONENT_ID, отказ npm —
# ARCH_BRIEF_OTKAZ. Без architecture/ и без флага прежняя выдача сохранена.
# НЕ БАРЬЕР: субъект контракта 095 — зелёный контроль и стаб-детект собственной именованной батареи fixtures/context_pack_095/ (раннер fixtures/_krasnye_095.sh, стаб-пак battery_stubs.sh, 18 мутаций), не case_*.sh-глобом (прецедент drill_exit_marker.sh/drill_path_guard.sh, заморозка 025 И-7). Выходы: 0 — пак построен (stdout), 1 — именованный отказ «ОТКАЗ: ...», 2 — NOT_IMPLEMENTED.
set -uo pipefail
TAB="$(printf '\t')"
die() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
ni()  { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

# Идентичность проекта выводится из общего .git САМОГО целевого корня, поэтому
# переменные GIT_* из окружения не должны подменять это обнаружение:
# GIT_DIR/GIT_COMMON_DIR уводят git в чужой репозиторий (иначе ключ внешнего
# state считался бы по чужому пути). Прецедент — spawn_agent.sh.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES \
      GIT_COMMON_DIR
command -v git >/dev/null 2>&1 || ni "нет git"
command -v jq >/dev/null 2>&1 || ni "нет jq"
command -v awk >/dev/null 2>&1 || ni "нет awk"

# ── ДОВЕРЕННЫЙ GIT (идентичность внешнего state) ───────────────────────────
# Ключ внешнего state — общий .git проекта, и его значение приходит из
# `git rev-parse --git-common-dir`. Брать этот ответ у git из PATH вызывающей
# стороны нельзя: подмена git, подменяющая ровно этот вызов, склеивает ключ
# двух РАЗНЫХ проектов — второй spawn принимает чужой манифест и создаёт ветку
# и worktree чужого проекта (адверсарий 161 r3: GIT_PATH_COLLISION). Поэтому
# ВСЕ вызовы git в этом скрипте идут исполняемым файлом из закрытого списка
# доверенных системных каталогов — то же правило, что у sha256sum ниже
# (/usr/bin → /bin → /usr/local/bin; значение берётся из доверенного
# инструмента, а не из PATH вызывающей стороны). Доверенного git нет —
# именованный отказ NOT_IMPLEMENTED ДО любой записи.
#
# Аудит прочих утилит в вычислении ключа и базы state: ключ = sha256(общий
# .git), база = канонический TMPDIR. Из PATH в этой цепочке шли только git и
# sha256sum; pwd/cd/printf/case — встроенники bash. python3/awk/sed/grep/
# readlink/mktemp в вычислении ключа и базы НЕ участвуют (jq — профиль, его
# PATH-разрешение закреплено клеткой 136 «jq нет»), поэтому правило
# доверенных каталогов к ним не применяется. Канонизация ИТОГОВОГО пути
# манифеста (_state_path_canonical) — тоже только встроенники bash.
GIT_BIN=""
for _git_dir in /usr/bin /bin /usr/local/bin; do
  if [ -f "$_git_dir/git" ] && [ -x "$_git_dir/git" ]; then
    GIT_BIN="$_git_dir/git"
    break
  fi
done
[ -n "$GIT_BIN" ] || ni "нет git в доверенных системных каталогах"

# ── ДОВЕРЕННЫЙ SHA-256 ─────────────────────────────────────────────────────
# Идентичность внешнего state нельзя строить на результате `sha256sum`, найденной
# в PATH вызывающей стороны: подмена с корректным 64-hex склеила бы два разных
# проекта (адверсарий 161 r2). Поэтому вывод инструмента из PATH проверяется
# ТОЛЬКО на rc и форме (сбойный/нестандартный инструмент — отказ), а значение
# ключа берётся из системного инструмента закрытого списка каталогов.
# Сбой инструмента отказывает ДО записи пакета и манифеста.
HASH_CALLER_SHA256SUM=""
HASH_TRUSTED_SHA256SUM=""
HASH_TOOL_ERROR=""
HASH_OUT=""
for _hash_dir in /usr/bin /bin /usr/local/bin; do
  if [ -x "$_hash_dir/sha256sum" ]; then
    HASH_TRUSTED_SHA256SUM="$_hash_dir/sha256sum"
    break
  fi
done
[ -n "$HASH_TRUSTED_SHA256SUM" ] || ni "нет sha256sum в доверенных системных каталогах"
HASH_CALLER_SHA256SUM="$(type -P sha256sum 2>/dev/null || true)"
[ -n "$HASH_CALLER_SHA256SUM" ] && [ -x "$HASH_CALLER_SHA256SUM" ] || ni "нет sha256sum"
_hash_digest_is_stdout() { [[ "$1" =~ ^[0-9a-f]{64}[[:blank:]]+-$ ]]; }
_hash_sha256_text() {  # <строка> → HASH_OUT; сбой → HASH_TOOL_ERROR
  local input="$1" caller_out trusted_out
  HASH_TOOL_ERROR=""; HASH_OUT=""
  if ! caller_out="$(printf '%s' "$input" | "$HASH_CALLER_SHA256SUM" 2>/dev/null)"; then
    HASH_TOOL_ERROR="sha256sum из PATH завершился с ошибкой"; return 1
  fi
  _hash_digest_is_stdout "$caller_out" || {
    HASH_TOOL_ERROR="нестандартный вывод sha256sum из PATH"; return 1; }
  if ! trusted_out="$(printf '%s' "$input" | "$HASH_TRUSTED_SHA256SUM" 2>/dev/null)"; then
    HASH_TOOL_ERROR="доверенный sha256sum завершился с ошибкой"; return 1
  fi
  _hash_digest_is_stdout "$trusted_out" || {
    HASH_TOOL_ERROR="нестандартный вывод доверенного sha256sum"; return 1; }
  HASH_OUT="${trusted_out%% *}"
}
_hash_sha256_file() {  # <файл> → HASH_OUT; сбой → HASH_TOOL_ERROR
  local path="$1" caller_out trusted_out
  HASH_TOOL_ERROR=""; HASH_OUT=""
  if ! caller_out="$("$HASH_CALLER_SHA256SUM" < "$path" 2>/dev/null)"; then
    HASH_TOOL_ERROR="sha256sum из PATH завершился с ошибкой"; return 1
  fi
  _hash_digest_is_stdout "$caller_out" || {
    HASH_TOOL_ERROR="нестандартный вывод sha256sum из PATH"; return 1; }
  if ! trusted_out="$("$HASH_TRUSTED_SHA256SUM" < "$path" 2>/dev/null)"; then
    HASH_TOOL_ERROR="доверенный sha256sum завершился с ошибкой"; return 1
  fi
  _hash_digest_is_stdout "$trusted_out" || {
    HASH_TOOL_ERROR="нестандартный вывод доверенного sha256sum"; return 1; }
  HASH_OUT="${trusted_out%% *}"
}

usage() { printf 'usage: make_task.sh --repo R --role ROLE [--kind task|brief] [--contract NNN] [--task-file F] [--model-trace F] [--author-role R2] [--arch-component id[,id...]] [--print-context]\n' >&2; exit 1; }

REPO=""; ROLE=""; KIND="task"; CONTRACT=""; TASKFILE=""; TRACE=""; AUTHOR_ROLE_ARG=""; PRINT_CONTEXT=0
# КОНТРАКТ 170: --arch-component <id[,id...]> — список компонентов архитектуры
# проекта, брифы которых кладутся в пак задания. ПРИЗНАК ЗАДАНИЯ ФЛАГА отделён
# от его значения: пустой список — неконформный вход (ARCH_COMPONENT_ID), а НЕ
# «флага нет» (ARCH_COMPONENT_NET).
ARCH_COMPONENT=""; ARCH_COMPONENT_SET=0
# КОНТРАКТ 169: признак ЯВНОГО --model-trace. Явный аргумент (путь к TSV
# трассы) и незаданный аргумент (проектный fallback 136) — разные входы с
# разными отказами; сам факт задания аргумента решает, какой диагноз.
TRACE_EXPLICIT=0
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)        REPO="${2:?}"; shift 2 ;;
    --role)        ROLE="${2:?}"; shift 2 ;;
    --kind)        KIND="${2:?}"; shift 2 ;;
    --contract)    CONTRACT="${2:?}"; shift 2 ;;
    --task-file)   TASKFILE="${2:?}"; shift 2 ;;
    --model-trace) TRACE="${2:?}"; TRACE_EXPLICIT=1; shift 2 ;;
    --author-role) AUTHOR_ROLE_ARG="${2:?}"; shift 2 ;;
    --print-context) PRINT_CONTEXT=1; shift ;;
    --arch-component) [ "$#" -ge 2 ] || die "ARCH_COMPONENT_ID: требуется значение: список id через запятую"; ARCH_COMPONENT="${2-}"; ARCH_COMPONENT_SET=1; shift 2 ;;
    *) usage ;;
  esac
done
[ -n "$REPO" ] && [ -n "$ROLE" ] || usage
[ -d "$REPO" ] || die "репозитория нет: $REPO"
case "$ROLE" in orchestrator|architect|critic|implementer|adversary|reviewer|arbiter) ;; *) die "роль вне алфавита: $ROLE" ;; esac
case "$KIND" in task|brief) ;; *) die "kind вне алфавита: $KIND" ;; esac

# Инструмент хеша обязан быть рабочим ДО любой выдачи: сбойный sha256sum из
# PATH обязан отказать, а не тихо выдать пакет без манифеста.
_hash_sha256_text "" || die "HASH_TOOL_UNUSABLE: $HASH_TOOL_ERROR"

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

# КОНТРАКТ 103 (Решение 1) / 996: пути — ЕДИНЫЙ вызов `project_paths_resolve`
# (живёт в next_id.sh). Ранний вызов — ТОЛЕРАНТНЫЙ (136, И-7/НАБЛ-П5): его
# результат нужен ТОЛЬКО дефолту трассы 136 (<workflowPaths.registry> профиля).
# Отказ резолвера здесь НЕ роняет дверь (toy-мир 095: ci.workflow ещё не
# создан placeholder'ом ниже) — дефолт трассы не применяется, дальше прежние
# отказы дословно; СТРОГИЙ вызов `|| die "workflowPaths вне репо"` — на
# старом месте, после placeholder/profile_resolver. Второго резолвера и
# конкатенаций `$REPO_ABS/$STATE` нет: ранний и строгий вызовы — один и тот
# же project_paths_resolve.
NEXT_ID_LIB=1
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")" && pwd)/next_id.sh"
[ "$(type -t project_paths_resolve)" = "function" ] \
  || die "next_id.sh без project_paths_resolve"
TRACE_LINE=""; AUTHOR_MODEL=""
if [ "$PRINT_CONTEXT" -ne 1 ]; then
# 136 (НАБЛ-П5): проектный режим — трасса по умолчанию
# <workflowPaths.registry>/trace.tsv профиля (сеет дверь; путь — из ЕДИНОГО
# project_paths_resolve мягким ранним вызовом, не вторая конкатенация);
# явный --model-trace переопределяет. Вне проекта (резолвер отказал или
# файла нет) — прежний отказ дословно.
#
# КОНТРАКТ 169: ЯВНЫЙ --model-trace и незаданный аргумент — РАЗНЫЕ входы.
# Явный аргумент — ПУТЬ к TSV-файлу трассы (роль TAB модель TAB allowed|denied):
# строка модели или несуществующий путь отказывают НОВЫМ диагнозом, и проектный
# fallback их НЕ маскирует (подложенный <registry>/trace.tsv не превращает
# ошибочный явный аргумент в успех). Незаданный аргумент — проектный fallback
# 136; трассы нет нигде — прежний отказ 095 дословно.
if [ "$TRACE_EXPLICIT" = "1" ]; then
  [ -f "$TRACE" ] || die "--model-trace ожидает путь к TSV-файлу трассы (роль<TAB>модель<TAB>allowed); в проектном корне аргумент можно опустить — берётся <registry>/trace.tsv"
else
  if [ -z "$TRACE" ]; then
    _PP_JSON="$(project_paths_resolve "$REPO_ABS" 2>/dev/null)" || _PP_JSON=""
    if [ -n "$_PP_JSON" ] && [ -f "$(printf '%s' "$_PP_JSON" | jq -r '.registry')/trace.tsv" ]; then
      TRACE="$(printf '%s' "$_PP_JSON" | jq -r '.registry')/trace.tsv"
    fi
    unset _PP_JSON
  fi
  [ -n "$TRACE" ] || die "нет свидетельства модели: $ROLE"
fi
  while IFS="$TAB" read -r r m fb; do
    [ -z "${r:-}" ] && continue
    case "$fb" in allowed|denied) ;; *) die "трасса: грамматика" ;; esac
    if [ "$r" = "$ROLE" ]; then TRACE_LINE="TRACE: role=$r model=$m fallback=$fb"; fi
    [ -n "$AUTHOR_ROLE" ] && [ "$r" = "$AUTHOR_ROLE" ] && AUTHOR_MODEL="$m"
  done < "$TRACE"
  [ -n "$TRACE_LINE" ] || die "свидетельство не той роли: $ROLE"
fi

# КОНТРАКТ 166: выбор модели роли не зависит от модели, провайдера и семейства
# автора или другого судьи — совпадение моделей не причина отказа (слово
# владельца 2026-11-07). Обязательным остаётся авторский след трассы (протокол
# 095): без свидетельства автора пак не строится.
if [ "$ROLE" = "reviewer" ] || [ "$ROLE" = "critic" ]; then
  [ -n "$AUTHOR_MODEL" ] || die "свидетельство не той роли: $AUTHOR_ROLE"
fi

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

# ── КОНТРАКТ 161a: слой проекта — СВОЙ git-проект целевого корня ──────────
# Профиль, контракты и контекст определяются проектом ЦЕЛЕВОГО корня, а не
# HARNESS_PROJECT_LAYER_ROOT станции или другого проекта. Конфликт слоёв
# (корень слоя — чужой git-проект, у него свой репо-слой профиля
# harness.project.json) — именованный отказ LAYER_FOREIGN ДО любой выдачи:
# stdout пуст, дерево не меняется. Слой-клон 054 (корень без репо-слоя
# профиля) — не «другой проект»: прежнее поведение сохранено. Тот же
# git-проект (main ↔ его worktree) — не конфликт.
#
# Внешнее state проекта: каталог ВНЕ чекаута и его .git, общий для
# make_task (вызов из project-worktree) и spawn_agent (вызов из
# project-main). Ключ — общий .git проекта: один и тот же проект даёт один
# и тот же каталог из любого worktree и из main.
_git_common_dir() {  # <корень> — канонический общий .git проекта ("" — не git-репозиторий)
  local c
  c="$("$GIT_BIN" -C "$1" rev-parse --git-common-dir 2>/dev/null || true)"
  [ -n "$c" ] || return 0
  case "$c" in /*) ;; *) c="$1/$c" ;; esac
  ( cd "$c" 2>/dev/null && pwd -P 2>/dev/null ) || c=""
  printf '%s' "$c"
}
_git_dir_abs() {  # <корень> — канонический .git checkout'а ("" — не git-репозиторий)
  local d
  d="$("$GIT_BIN" -C "$1" rev-parse --git-dir 2>/dev/null || true)"
  [ -n "$d" ] || return 0
  case "$d" in /*) ;; *) d="$1/$d" ;; esac
  ( cd "$d" 2>/dev/null && pwd -P 2>/dev/null ) || d=""
  printf '%s' "$d"
}
# База внешнего state — канонизированный TMPDIR (симлинк разрешается в реальный
# путь); ключ — общий .git проекта, посчитанный ДОВЕРЕННЫМ sha256. База внутри
# любого checkout'а этого проекта или его .git — отказ ДО побочного эффекта.
_state_base_canonical() {  # → канонический TMPDIR (пусто — непригоден)
  local base="${TMPDIR:-/tmp}" canon
  [ -d "$base" ] || return 1
  canon="$(cd "$base" 2>/dev/null && pwd -P 2>/dev/null)" || return 1
  [ -n "$canon" ] || return 1
  printf '%s' "$canon"
}
# Канонизация ПРОИЗВОЛЬНОГО пути БЕЗ создания каталогов: каждый СУЩЕСТВУЮЩИЙ
# компонент разрешается (симлинк — в реальный путь), несуществующий хвост
# сохраняется буквально. Только встроенники bash (cd/pwd -P) — как у
# _state_base_canonical; readlink/awk/python3 в вычислении пути НЕ участвуют.
# Нужна для проверки ИТОГОВОГО каталога манифеста: компонент
# dev-harness-project-state, каталог ключа и context — элементы пути, и ссылка
# в любом из них уводит запись в checkout проекта или его .git.
_state_path_canonical() {  # <абсолютный путь> → канонический путь; 1 — непригоден
  local path="${1:-}" rest comp acc="" canon
  case "$path" in
    /*) rest="${path#/}" ;;
    *) return 1 ;;
  esac
  while [ -n "$rest" ]; do
    case "$rest" in
      */*) comp="${rest%%/*}"; rest="${rest#*/}" ;;
      *) comp="$rest"; rest="" ;;
    esac
    [ -n "$comp" ] || continue
    if [ -n "$acc" ]; then acc="$acc/$comp"; else acc="/$comp"; fi
    if [ -e "$acc" ] || [ -L "$acc" ]; then
      canon="$(cd "$acc" 2>/dev/null && pwd -P 2>/dev/null || true)"
      [ -n "$canon" ] || return 1
      acc="$canon"
    fi
  done
  [ -n "$acc" ] || return 1
  printf '%s' "$acc"
}
_state_worktree_paths() {  # <корень> → канонические пути checkout'ов проекта
  local line p
  while IFS= read -r line; do
    case "$line" in
      "worktree "*)
        p="${line#worktree }"
        p="$(cd "$p" 2>/dev/null && pwd -P 2>/dev/null || true)"
        [ -n "$p" ] && printf '%s\n' "$p"
        ;;
    esac
  done < <("$GIT_BIN" -C "$1" worktree list --porcelain 2>/dev/null || true)
}
_state_base_is_safe() {  # <корень> <база> → 0 да, 1 нет
  local root="$1" base="$2" common p
  common="$(_git_common_dir "$root")"
  for p in "$root" "$common"; do
    [ -n "$p" ] || continue
    case "$base" in "$p"|"$p"/*) return 1 ;; esac
  done
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    case "$base" in "$p"|"$p"/*) return 1 ;; esac
  done < <(_state_worktree_paths "$root")
  return 0
}
PROJECT_STATE_BASE=""; PROJECT_STATE_KEY=""; PROJECT_STATE_DIR=""; PROJECT_STATE_ERROR=""
PROJECT_STATE_CONTEXT=""; PROJECT_STATE_CONTEXT_CANON=""
_project_state_prepare() {  # <корень>; сбой → PROJECT_STATE_ERROR
  local root="$1" common base canon
  PROJECT_STATE_ERROR=""
  common="$(_git_common_dir "$root")"
  [ -n "$common" ] || common="$root"
  base="$(_state_base_canonical)" || {
    PROJECT_STATE_ERROR="TMPDIR_UNAVAILABLE: непригодный TMPDIR: ${TMPDIR:-/tmp}"; return 1; }
  _state_base_is_safe "$root" "$base" || {
    PROJECT_STATE_ERROR="TMPDIR_INSIDE_MAIN: TMPDIR внутри checkout проекта или его .git: $base"; return 1; }
  _hash_sha256_text "$common" || {
    PROJECT_STATE_ERROR="HASH_TOOL_UNUSABLE: $HASH_TOOL_ERROR"; return 1; }
  PROJECT_STATE_BASE="$base"
  PROJECT_STATE_KEY="${HASH_OUT:0:16}"
  PROJECT_STATE_DIR="$base/dev-harness-project-state/$PROJECT_STATE_KEY"
  # Безопасной БАЗЫ мало: элементами пути манифеста являются ещё компонент
  # dev-harness-project-state, каталог ключа и сам context. Ссылка в любом из
  # них ведёт запись в checkout проекта или его .git. Итоговый каталог
  # канонизируется ДО создания каталогов — отказ наступает до mkdir и до
  # записи манифеста, stdout пака не печатается.
  PROJECT_STATE_CONTEXT="$PROJECT_STATE_DIR/context"
  canon="$(_state_path_canonical "$PROJECT_STATE_CONTEXT")" || {
    PROJECT_STATE_ERROR="STATE_PATH_UNRESOLVABLE: каталог манифеста неразрешим: $PROJECT_STATE_CONTEXT"; return 1; }
  _state_base_is_safe "$root" "$canon" || {
    PROJECT_STATE_ERROR="TMPDIR_INSIDE_MAIN: каталог манифеста внутри checkout проекта или его .git: $canon"; return 1; }
  PROJECT_STATE_CONTEXT_CANON="$canon"
}
# Признак входа 161a: пак собирается из ПРОЕКТНОГО worktree — checkout не
# каноническое состояние проекта (--git-dir ≠ --git-common-dir). Legacy-flow
# (make_task --repo <main checkout> проекта) сохраняет семантику И-3
# контракта 095 (optional-источник может отсутствовать; строка фрагмента в
# паке не печатается) — её держат замороженные батареи 095 и ежедневный
# поток станции (профиль харнеса объявляет optional-источники, которых нет
# в дереве). Вход 161a (проектный worktree) требует полноты карты: молча
# усечённая карта выдала бы агенту неполный контекст проекта.
_PACK_FROM_WORKTREE=0
_gd_abs="$(_git_dir_abs "$REPO_ABS")"
_gc_abs="$(_git_common_dir "$REPO_ABS")"
if [ -n "$_gd_abs" ] && [ -n "$_gc_abs" ] && [ "$_gd_abs" != "$_gc_abs" ]; then
  _PACK_FROM_WORKTREE=1
fi
if [ "$_PACK_FROM_WORKTREE" = "1" ]; then
  # Внешнее state готовится ДО любой записи: канонический TMPDIR вне checkout'а
  # проекта и его .git, ключ — общий .git через доверенный sha256.
  _project_state_prepare "$REPO_ABS" || die "$PROJECT_STATE_ERROR"
fi
_layer_root_abs="$(cd "$HARNESS_PROJECT_LAYER_ROOT" 2>/dev/null && pwd -P 2>/dev/null || true)"
if [ -n "$_layer_root_abs" ] && [ "$_layer_root_abs" != "$REPO_ABS" ]; then
  _lc_repo="$(_git_common_dir "$REPO_ABS")"
  _lc_layer="$(_git_common_dir "$_layer_root_abs")"
  if [ -n "$_lc_repo" ] && [ -n "$_lc_layer" ] && [ "$_lc_layer" != "$_lc_repo" ] \
     && [ -f "$_layer_root_abs/harness.project.json" ]; then
    die "LAYER_FOREIGN: слой проекта из чужого git-проекта: $_layer_root_abs (целевой проект: $REPO_ABS)"
  fi
fi

# HEALTH — СНИМАЕМ ДО создания placeholder ci.yml (он грязнит дерево).
# HEALTH описывает мир в момент ВХОДА, не в момент выхода. Это согласуется
# с контрактом 095: «HEALTH: branch=<живой git> dirty=<N>» — N считается по
# состоянию репо на момент сборки пакета, до наших локальных артефактов.
HEALTH_BRANCH="$("$GIT_BIN" -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || printf '?')"
HEALTH_DIRTY="$("$GIT_BIN" -C "$REPO" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"

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
trap '[ -n "${_CW_PLACEHOLDER:-}" ] && [ -e "$REPO/$_CW_PLACEHOLDER" ] && rm -f "$REPO/$_CW_PLACEHOLDER"; rm -f "${_MT_ERR_FILE:-}"; if [ -n "${_NPM_ERR_FILE:-}" ]; then rm -f "$_NPM_ERR_FILE"; fi' EXIT

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
REPO_ABS="$(cd "$REPO" && pwd -P)"
if [ -z "${HARNESS_PROJECT_LAYER_ROOT:-}" ]; then
  export HARNESS_PROJECT_LAYER_ROOT="$REPO"
fi
NEXT_ID_LIB=1
# shellcheck disable=SC1091
. "$(cd "$(dirname "$0")" && pwd)/next_id.sh"
[ "$(type -t project_paths_resolve)" = "function" ] \
  || die "next_id.sh без project_paths_resolve"
# СТРОГИЙ вызов резолвера (старое место, как на origin/main — после
# placeholder ci.workflow и profile_resolver): rc 1 → отказ двери ДО
# построения PROJECT. Ранний мягкий вызов выше — тот же
# project_paths_resolve, его результат живёт только в дефолте трассы 136.
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
  # КОНТРАКТ 161a: пропущенная строка contextPack.rows — ИМЕНОВАННЫЙ отказ с
  # путём (PROFILE_PATH_MISSING) вместо частичного пака. Обязательный
  # источник отказывает всегда (фраза 095 «источник недоступен: <путь>»
  # дословно, имя — дописано); optional — отказывает во входе 161a
  # (проектный worktree), в legacy-flow (main checkout) сохраняется И-3
  # контракта 095: строка фрагмента не печатается, пак строится.
  if [ ! -f "$REPO/$path" ]; then
    if [ "$mnd" = "true" ] || [ "$_PACK_FROM_WORKTREE" = "1" ]; then
      die "источник недоступен: $path (PROFILE_PATH_MISSING)"
    fi
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
  TAG="$("$GIT_BIN" -C "$REPO" tag -l "frozen/contracts/$CONTRACT/*" | LC_ALL=C sort -V | tail -n 1)"
  ORIGIN="draft"
  if [ -n "$TAG" ]; then
    # (з) заморозка: путь контракта ВНУТРИ блоба тега — профильный
    # (<contracts>/), корень тега — НЕ фолбэк (Frontier И-1в/И-1г).
    _fz_esc="${WP_C_REL//./\\.}"
    CPATH="$("$GIT_BIN" -C "$REPO" ls-tree --name-only "$TAG" "$WP_C_REL/" | grep -E "^$_fz_esc/${CONTRACT}-[^/]+\.md$" | head -n 1)"
    [ -n "$CPATH" ] || die "заморозка без контракта: $TAG"
    CBYTES="$("$GIT_BIN" -C "$REPO" show "$TAG:$CPATH" 2>&1)"
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
    _hash_sha256_file "$TASKFILE" || die "HASH_TOOL_UNUSABLE: $HASH_TOOL_ERROR"
    TASK_SHA="$HASH_OUT"
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

# ── КОНТРАКТ 170: бриф компонента архитектуры в паке задания ────────────────
# Вход: --arch-component id[,id...] — НЕПУСТОЙ список ID через запятую, порядок
# входа сохраняется. Признак применимости — каталог <R>/architecture/ ПРОЕКТА
# (НЕ repoId: профиль есть и у самого харнесса) и кодовый предмет — строка
# «КЛАСС ЗАДАЧИ: кодовый» в ФАКТИЧЕСКИ выбранном контракте (CBYTES). Значение
# класса опознаётся по началу строки до разделителя (точка, «;», скобка, конец
# строки) — реальные формы: «кодовый.», «КОДОВЫЙ (реализация)», «КОДОВЫЙ; …»;
# регистр — двумя явными формами, БЕЗ -i (кириллица под LC_ALL=C не сворачивается).
# Отказы (rc 1, пустой stdout, до выдачи пака):
#   ARCHITECTURE_NET   — флаг задан, каталога architecture/ нет;
#   ARCH_COMPONENT_ID  — флаг задан, список неконформен (пустая запись, slash,
#                        «..», символ вне [A-Za-z0-9._-]); проверка ДО запуска npm;
#   ARCH_BRIEF_OTKAZ   — npm не отдал бриф (rc≠0 или пустой stdout);
#   ARCH_COMPONENT_NET — флаг НЕ задан, а предмет кодовый и каталог
#                        architecture/ есть: бриф компонента обязателен.
# Проектная команда (npm из PATH вызывающей стороны) — источник данных
# ПРОЕКТА: её stdout — бриф, её stderr — диагностика отказа (в пак не идёт и
# первой строки stderr не портит: первая строка — именованный отказ).
ARCH_SEC=""
if [ "$KIND" = task ]; then
  _arch_dir="$REPO/architecture"
  if [ "$ARCH_COMPONENT_SET" = "1" ]; then
    [ -d "$_arch_dir" ] || die "ARCHITECTURE_NET: нет каталога architecture/ в проекте: $_arch_dir"
    case "$ARCH_COMPONENT" in
      ''|,*|*,|*,,*) die "ARCH_COMPONENT_ID: непустой список id через запятую: $ARCH_COMPONENT" ;;
    esac
    # ФОРМАТ ВСЕХ id проверяется ОТДЕЛЬНЫМ циклом ДО первого вызова npm:
    # неконформный список отказывает, ни разу не исполнив проектную команду
    # (её побочные действия не наступают).
    _arch_rest="$ARCH_COMPONENT"
    while [ -n "$_arch_rest" ]; do
      _arch_id="${_arch_rest%%,*}"
      if [ "$_arch_rest" = "$_arch_id" ]; then _arch_rest=""; else _arch_rest="${_arch_rest#*,}"; fi
      case "$_arch_id" in
        ''|[!A-Za-z0-9_]*|*[^A-Za-z0-9._-]*|*..*) die "ARCH_COMPONENT_ID: неконформный id: $_arch_id" ;;
      esac
    done
    # stderr npm — в отдельный файл: в пак идёт только stdout брифа, а первая
    # строка stderr остаётся именованным отказом.
    _NPM_ERR_FILE="$(mktemp 2>/dev/null || true)"
    [ -n "$_NPM_ERR_FILE" ] && [ -f "$_NPM_ERR_FILE" ] || _NPM_ERR_FILE=""
    _NPM_ERR_REDIR="/dev/null"
    [ -n "$_NPM_ERR_FILE" ] && _NPM_ERR_REDIR="$_NPM_ERR_FILE"
    _arch_rest="$ARCH_COMPONENT"
    while [ -n "$_arch_rest" ]; do
      _arch_id="${_arch_rest%%,*}"
      if [ "$_arch_rest" = "$_arch_id" ]; then _arch_rest=""; else _arch_rest="${_arch_rest#*,}"; fi
      # Правила проекта — только ролям, которые их читают (architect/critic/
      # arbiter); implementer/adversary/reviewer получают бриф без них.
      _arch_rules=""
      case "$ROLE" in architect|critic|arbiter) _arch_rules="--with-rules" ;; esac
      _arch_rc=0
      if [ -n "$_arch_rules" ]; then
        _arch_text="$(npm --prefix "$_arch_dir" run brief -- --compact --with-rules --component "$_arch_id" 2>"$_NPM_ERR_REDIR")" || _arch_rc=$?
      else
        _arch_text="$(npm --prefix "$_arch_dir" run brief -- --compact --component "$_arch_id" 2>"$_NPM_ERR_REDIR")" || _arch_rc=$?
      fi
      if [ "$_arch_rc" -ne 0 ]; then
        _arch_hint="$(awk 'NR==1 { gsub(/[\r\n\t]/, " "); print substr($0, 1, 200) }' "$_NPM_ERR_REDIR" 2>/dev/null || true)"
        if [ -n "$_arch_hint" ]; then
          die "ARCH_BRIEF_OTKAZ: $_arch_id (npm rc=$_arch_rc): $_arch_hint"
        fi
        die "ARCH_BRIEF_OTKAZ: $_arch_id (npm rc=$_arch_rc)"
      fi
      [ -n "$_arch_text" ] || die "ARCH_BRIEF_OTKAZ: пустой бриф компонента: $_arch_id"
      ARCH_SEC="${ARCH_SEC}COMPONENT: $_arch_id
${_arch_text}
"
    done
  elif [ -d "$_arch_dir" ] && printf '%s\n' "$CBYTES" | grep -Eq '^КЛАСС ЗАДАЧИ:[[:space:]]*(кодовый|КОДОВЫЙ)([^[:alnum:]_]|$)'; then
    die "ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с architecture/)"
  fi
fi

TRACE_MAN="trace${TAB}${TRACE}${TAB}mandatory${TAB}trace
"
pack_body() {
  printf '=== make_task contract=%s role=%s kind=%s ===\n' "${CONTRACT:-none}" "$ROLE" "$KIND"
  printf '=== TRACE ===\n%s\n' "$TRACE_LINE"
  printf '=== MAP ===\n%s' "$MAP_LINES"
  printf '=== RULES ===\n%s' "$RULES_LINES"
  printf '=== REUSE ===\n%s' "$REUSE_LINES"
  [ -z "$ARCH_SEC" ] || printf '=== ARCHITECTURE BRIEF ===\n%s' "$ARCH_SEC"
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
MAN_BODY="=== MANIFEST ===
${MAP_MAN}${CTX_MAN}${ADR_MAN}${LESSONS_MAN}${TASK_MAN}${TRACE_MAN}"
# КОНТРАКТ 161a: манифест пака живёт во ВНЕШНЕМ state проекта — вне чекаута
# и его .git (живой main и его индекс не меняются). Тот же каталог читает
# spawn_agent ДО создания worktree. Запись идёт ДО печати пака: пак на
# stdout означает готовый манифест. База state — канонический TMPDIR (внутри
# checkout'а проекта или его .git — отказ), ключ — общий .git проекта,
# посчитанный доверенным sha256 (не результатом инструмента из PATH).
#
# Legacy-flow (make_task --repo <main checkout> проекта) сохраняет
# размещение 095 (<repo>/.omp/context/<NNN>.tsv) — его ждёт дверь 095
# (замороженная клетка red_dver_spawn_manifest.sh) и поток станции; во
# внешнее state в этом flow манифест НЕ дублируется. Вход 161a (проектный
# worktree) в checkout не пишет вовсе: рабочее дерево остаётся чистым.
if [ "$KIND" = "task" ] && [ -n "$CONTRACT" ]; then
  _man_num="$(printf '%03d' "$((10#$CONTRACT))")"
  if [ "$_PACK_FROM_WORKTREE" = "1" ]; then
    # Каталог манифеста — по КАНОНИЧЕСКОМУ пути (ссылка внутрь checkout'а
    # проекта или его .git отвергнута ещё на _project_state_prepare) и
    # повторно канонизируется ПОСЛЕ создания: свойство «каталог манифеста
    # вне checkout'а и его .git» проверяется на ИТОГОВОМ пути.
    _man_dir="$PROJECT_STATE_CONTEXT_CANON"
    mkdir -p "$_man_dir" || die "внешнее state проекта не создать: $_man_dir"
    _man_dir="$(_state_path_canonical "$_man_dir")" \
      || die "STATE_PATH_UNRESOLVABLE: каталог манифеста неразрешим: $_man_dir"
    _state_base_is_safe "$REPO_ABS" "$_man_dir" \
      || die "TMPDIR_INSIDE_MAIN: каталог манифеста внутри checkout проекта или его .git: $_man_dir"
    _man_file="$_man_dir/$_man_num.tsv"
    # Файл манифеста — тоже элемент пути: подложенная ссылка (в том числе на
    # каталог чужого checkout) удаляется КАК ССЫЛКА — цель не трогается, —
    # а запись идёт с noclobber: файл, подложенный после удаления, приводит к
    # отказу, а не к записи по ссылке.
    rm -f "$_man_file" || die "файл манифеста не удалить: $_man_file"
    ( set -C; printf '%s\n' "$MAN_BODY" >"$_man_file" ) \
      || die "манифест пака не записан: $_man_file"
  else
    mkdir -p "$REPO/.omp/context" || die "каталог манифеста не создать: $REPO/.omp/context"
    _man_file="$REPO/.omp/context/$_man_num.tsv"
    printf '%s\n' "$MAN_BODY" >"$_man_file" || die "манифест пака не записан: $_man_file"
  fi
fi
pack_body
printf '%s' "$MAN_BODY"
printf '=== BUDGET ===\nBUDGET: vklejka=%s/40000\n' "$VK"