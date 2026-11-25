#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2295,SC1010
# Писатель тега done/contracts/<NNN>/<v> (контракт 038, Н-116): единственный
# законный путь поставить done-тег. Проверяет ПРОВОДКА контракта через
# check_provodka.sh (шаг 6), ПОТРЕБИТЕЛЕЙ через check_consumers.sh (шаг 6а —
# после ПРОВОДКИ, до клапана), СОДЕРЖАТЕЛЬНУЮ сверку (шаг 6б, контракт 201:
# привязка accept к последней заморозке, влитость реализации, адверсарий
# рисковым, имя check-run arch), вердикт ревьюера, закоммиченность контракта
# и клапан владельца. Тег ставится аннотированный; реестр заморозок НЕ пишется
# (замер frontier §0; минт-строки пишет дверь 031).
#
# Грамматика — ЕДИНЫЙ источник контракт 038 §Инварианты 4; фразы отказов
# побайтово. Парсинг anchored `sed -nE` (канон check_spec_ready.sh:93–94).
#
# Контракт API:
#   вход: $1 = <отн-путь-контракта> (относительно cwd), $2 = "<причина>";
#   rc 0 — тег поставлен; stdout: v<N>;
#   rc 1 — отказ с ИМЕНОВАННОЙ причиной (stderr); тега нет.
#
#   bash scripts/done_contract.sh <отн-путь-контракта> "<причина>"
#
# Коды возврата: 0 — тег поставлен, 1 — отказ, 2 — нечем проверить.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export NEXT_ID_LIB=1
# shellcheck disable=SC1091
. "$SELF_DIR/next_id.sh"

die()  { printf '%s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

# ── Полный разбор ровно одного JSON-документа (канон jq -s) ────────────────
# Свидетельство принимается ТОЛЬКО после успешного ПОЛНОГО разбора входа:
# ровно ОДИН JSON-документ, корень — объект. Пустой ввод, синтаксическая
# ошибка в любом месте, ВТОРОЙ документ (в т.ч. `{}` после валидного первого)
# и поток документов документом НЕ являются; частичный stdout при ненулевом
# rc jq отбрасывается ЦЕЛИКОМ (rc проверяется ДО использования результата).
# Внешний whitespace вокруг одного документа допустим.
#
# ВЫЗОВ: _json_one_object <имя-переменной> [<файл>]
#   Без файла вход — stdin; он копируется в безопасный временный файл БЕЗ
#   прохода через bash-строку. С файлом jq читает именно этот файл. Сырые NUL
#   и любые другие байты поэтому не теряются и не мутируются до jq.
#   rc 0 — разобран ровно один JSON-объект: в переменной канонический JSON,
#          _JSON_ERR пуст;
#   rc 1 — отказ: переменная пуста, _JSON_ERR — правдивая причина.
#
# Временные файлы двери удаляются на ВСЕХ выходах через EXIT-trap.
_DONE_TMP_FILES=()
_DONE_TMP_LAST=""
_done_cleanup() {
  local __f
  for __f in "${_DONE_TMP_FILES[@]}"; do
    [ -n "$__f" ] && rm -f -- "$__f"
  done
}
trap '_done_cleanup' EXIT

_new_done_tmp() {
  local __f
  __f="$(mktemp "${TMPDIR:-/tmp}/done-contract.XXXXXXXX" 2>/dev/null || true)"
  if [ -z "$__f" ] || [ ! -f "$__f" ]; then
    return 1
  fi
  _DONE_TMP_FILES+=("$__f")
  _DONE_TMP_LAST="$__f"
  return 0
}

_JSON_ERR=""
_json_one_object() {
  local __var="${1:?имя переменной обязательно}" __file="${2:-}" __out="" __rc=0 __diag=""
  if [ -n "$__file" ]; then
    if [ ! -r "$__file" ]; then
      printf -v "$__var" '%s' ''
      _JSON_ERR="файл с JSON не читается"
      return 1
    fi
  else
    if ! _new_done_tmp; then
      printf -v "$__var" '%s' ''
      _JSON_ERR="временный файл для разбора JSON не создать"
      return 1
    fi
    __file="$_DONE_TMP_LAST"
    if ! cat > "$__file"; then
      printf -v "$__var" '%s' ''
      _JSON_ERR="вход JSON не скопирован во временный файл"
      return 1
    fi
  fi
  __out="$(jq -s -c 'if (length == 1 and (.[0] | type) == "object") then .[0] else error("ожидался ровно один JSON-документ-объект") end' "$__file" 2>/dev/null)" || __rc=$?
  if [ "$__rc" -eq 0 ]; then
    printf -v "$__var" '%s' "$__out"
    _JSON_ERR=""
    return 0
  fi
  printf -v "$__var" '%s' ''
  __diag="$(jq -s -r 'if length == 0 then "empty" elif length != 1 then "multiple" else "not-object" end' "$__file" 2>/dev/null)" || true
  case "$__diag" in
    empty)      _JSON_ERR="пустой ввод: JSON-документов нет" ;;
    multiple)   _JSON_ERR="в ответе несколько JSON-документов (ожидался ровно один)" ;;
    not-object) _JSON_ERR="ответ не JSON-объект" ;;
    *)          _JSON_ERR="синтаксическая ошибка JSON (jq rc=$__rc)" ;;
  esac
  return 1
}

# 224: round numbers order verdicts; commit ancestry still binds OBJECT/F.
_select_round_verdict() {
  local files="$1" role="$2" f name text cid number call field day name_day key
  local version declared rest token denominator phase_version explicit count=0
  local best=0 seen=' ' metadata='' prior_n prior_d
  _rv_file='' _rv_cid='' _rv_first=''
  while IFS= read -r f; do
    [ -z "$f" ] || count=$((count + 1))
  done <<< "$files"
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    name="${f##*/}" version='' declared='' explicit=0
    if [[ "$name" =~ -impl-v([1-9][0-9]*)-vyzov([1-9][0-9]*)\.md$ ]]; then
      version="${BASH_REMATCH[1]}" number="${BASH_REMATCH[2]}" explicit=1
      declared="$number"
    elif [[ "$name" == *-impl-v*-vyzov*.md ]]; then
      die "done: VERDICT_ROUND_INVALID: $role: $f"
    elif [[ "$name" =~ -v([1-9][0-9]*)(-[A-Za-z0-9._-]+)?\.md$ ]]; then
      version="${BASH_REMATCH[1]}" number=0 declared="$version"
    elif [[ "$name" =~ -impl-a([1-9][0-9]*)\.md$ ]]; then
      version="${BASH_REMATCH[1]}" number=0 declared="$version"
    elif [[ "$name" =~ -(v|impl-v|impl-a)[0-9] ]]; then
      die "done: VERDICT_ROUND_INVALID: $role: $f"
    elif [ "$count" -eq 1 ]; then
      version=1 number=0
    else
      die "done: VERDICT_ROUND_MISSING: $role: $f"
    fi
    [ "${#version}" -le 9 ] && [ "${#number}" -le 9 ] \
      || die "done: VERDICT_ROUND_INVALID: $role: $f"
    text="$(git -C "$ROOT" cat-file -p "HEAD:$f")" \
      || die "done: VERDICT_ROUND_READ: $role: $f"
    text="${text//$'\r'/}"
    call='' day='' name_day='' phase_version=''
    if [[ "$name" =~ -([0-9]{4}-[0-9]{2}-[0-9]{2})(-|\.md$) ]]; then
      name_day="${BASH_REMATCH[1]}"
    fi
    while IFS= read -r field; do
      [[ "$field" == 'СУД: '* ]] || continue
      if [[ "$field" =~ (^|[\;\ ])фаза=реализация\ v([1-9][0-9]*)([\;\ ]|$) ]]; then
        [ -z "$phase_version" ] || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
        phase_version="${BASH_REMATCH[2]}"
      elif [[ "$field" =~ (^|[\;\ ])фаза=реализация[^\;]*круг\ ([1-9][0-9]*)([,\)\ ]|$) ]]; then
        [ -z "$phase_version" ] || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
        phase_version="${BASH_REMATCH[2]}"
      fi
      rest="${field#СУД: }"
      # Inspect every named call token, including repeated fields on one line.
      while [[ "$rest" =~ (^|[\;\ ])вызов=([^;\ ]*) ]]; do
        token="${BASH_REMATCH[2]}"
        rest="${rest#*"${BASH_REMATCH[0]}"}"
        [ -z "$call" ] || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
        if [[ "$token" =~ ^([1-9][0-9]*)(/([1-9][0-9]*))?$ ]]; then
          call="${BASH_REMATCH[1]}" denominator="${BASH_REMATCH[3]}"
          [ "${#call}" -le 9 ] && [ "${#denominator}" -le 9 ] \
            || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
        else
          die "done: VERDICT_ROUND_CONFLICT: $role: $f"
        fi
      done
      if [[ "$field" =~ (^|[\;\ ])дата=([0-9]{4}-[0-9]{2}-[0-9]{2})([\;\ ]|$) ]]; then
        [ -z "$day" ] || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
        day="${BASH_REMATCH[2]}"
      elif [[ "$field" == *'дата='* ]]; then
        die "done: VERDICT_ROUND_CONFLICT: $role: $f"
      fi
    done <<< "$text"
    if [ -n "$phase_version" ]; then
      [ "${#phase_version}" -le 9 ] && [ -n "$call" ] \
        || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
      if [ "$explicit" -eq 1 ]; then
        [ "$version" = "$phase_version" ] \
          || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
      else
        version="$phase_version" number="$call" declared="$call"
      fi
    fi
    [ -z "$call" ] || [ -z "$declared" ] || [ "$call" = "$declared" ] \
      || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
    # Two coordinates avoid confusing implementation generation and call.
    key=$((version * 1000000000 + number))
    case "$seen" in
      *" $key "*) : ;;
    esac
    seen="$seen$key "
    if [ -n "$name_day" ]; then
      [ -z "$day" ] || [ "$day" = "$name_day" ] \
        || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
      day="$name_day"
    fi
    if [ -n "$day" ]; then
      [ "$(date -u -d "$day" +%F 2>/dev/null)" = "$day" ] \
        || die "done: VERDICT_ROUND_CONFLICT: $role: $f"
      while read -r prior_n prior_d; do
        [ -n "$prior_d" ] || continue
        if { [ "$prior_n" -lt "$key" ] && [[ "$prior_d" > "$day" ]]; } \
          || { [ "$prior_n" -gt "$key" ] && [[ "$prior_d" < "$day" ]]; }; then
          die "done: VERDICT_ROUND_ORDER: $role: $f"
        fi
      done <<< "$metadata"
      metadata="${metadata}${key} ${day}"$'\n'
    fi
    cid="$(git -C "$ROOT" log --format=%H -1 -- "$f")" \
      || die "done: история вердикта не читается: $f — проверить невозможно"
    [ -n "$cid" ] || die "done: у вердикта на HEAD нет коммита в истории: $f — проверить невозможно"
    if [ "$key" -gt "$best" ]; then
      best="$key" _rv_file="$f" _rv_cid="$cid"
      _rv_first="${text%%$'\n'*}"
      _rv_first="${_rv_first#"${_rv_first%%[![:space:]]*}"}"
      _rv_first="${_rv_first%"${_rv_first##*[![:space:]]}"}"
    fi
  done <<< "$files"
}

TARGET="${1:?использование: $0 <contracts/NNN-*.md> \"<причина>\" [корень]}"
REASON="${2-}"  # пустая причина допустима — проверяется ниже отдельной веткой
# ROOT: 3-й аргумент ИЛИ (после env-гигиены) cwd-репозиторий — написатель ВДВОЙНЕ
# важна устойчивость к отравленному окружению.
if [ -n "${3:+x}" ]; then ROOT="${3}"; else ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; fi
# Причина пуста — отказ ДО всех остальных проверок (шаг 3)
if [ -z "${REASON//[[:space:]]/}" ]; then
  die "done: причина пуста"
fi

# 996 (Б-5/Б-9): ЕДИНЫЙ резолв workflowPaths через функцию project_paths_resolve
# из подключённой выше scripts/next_id.sh (пакет A/Б-5, исправление toy-миров —
# см. freeze_contract.sh:84-96). Дверь больше НЕ вызывает project_workflow.sh
# отдельным bash-процессом.
_pr_paths="$(project_paths_resolve "$ROOT" 2>/dev/null)" \
  || die "ОТКАЗ: профиль битый или workflowPaths вне репо: $(project_paths_resolve "$ROOT" 2>&1 >/dev/null)"
# Полный разбор ОДНОГО документа (jq -s): три пути workflowPaths берутся ТОЛЬКО
# из целого разобранного объекта. Повреждённый ответ или поток документов —
# именованный отказ ДО любых побочных эффектов (ни один путь не используется).
_pr_paths_obj=""
_json_one_object _pr_paths_obj <<<"$_pr_paths" \
  || die "ОТКАЗ: project_paths_resolve вернул не JSON-объект: $_JSON_ERR"
_PROFILE_VERDICTS_BASE="$(printf '%s' "$_pr_paths_obj" | jq -r '.verdicts' 2>/dev/null)" \
  || die "ОТКАЗ: project_paths_resolve: путь verdicts не извлечён"
_PROFILE_REGISTRY_PATH="$(printf '%s' "$_pr_paths_obj" | jq -r '.registry' 2>/dev/null)" \
  || die "ОТКАЗ: project_paths_resolve: путь registry не извлечён"
_PROFILE_CONTRACTS_BASE="$(printf '%s' "$_pr_paths_obj" | jq -r '.contracts' 2>/dev/null)" \
  || die "ОТКАЗ: project_paths_resolve: путь contracts не извлечён"
[ -n "$_PROFILE_VERDICTS_BASE" ] && [ -n "$_PROFILE_REGISTRY_PATH" ] && [ -n "$_PROFILE_CONTRACTS_BASE" ] \
  || die "ОТКАЗ: project_paths_resolve вернул пустой путь"
unset _pr_paths
# dir-суффиксы для роли ревьюера (done). Аналогия freeze: было — корневой
# `verdicts/review`, теперь профильный review.
# Relative form of verdicts (для cd-канонизации и `git -C $ROOT cat-file`):
case "$_PROFILE_VERDICTS_BASE" in
  "$ROOT"/*) _PROFILE_VERDICTS_REL="${_PROFILE_VERDICTS_BASE#"$ROOT"/}" ;;
  *)         _PROFILE_VERDICTS_REL="${_PROFILE_VERDICTS_BASE#/}" ;;
esac
_PROFILE_VERDICTS_DIR="${_PROFILE_VERDICTS_REL%/}/review"
unset _PROFILE_VERDICTS_REL _PROFILE_VERDICTS_BASE
# Контрактная форма: done/contracts/<NNN>/<v> — независимо от того, лежит ли
# contracts под `.harness/tasks` или в корне `contracts/`. Тег-каталог всегда
# `contracts` (прецедент freeze_contract.sh:139-141).
_PROFILE_CONTRACTS_DIR="${_PROFILE_CONTRACTS_BASE%/}"
( cd "$ROOT" 2>/dev/null && git rev-parse --verify HEAD >/dev/null 2>&1 ) || skip "в $ROOT нет ни одного коммита — done-писать нечего"

# ── 2. basename-грамматика NNN ────────────────────────────────────────────────
base="${TARGET##*/}"
# 996 (Б-6) К1: профильный путь предпочтителен; корневой contracts/ допустим
# ТОЛЬКО когда профиль не уводит workflowPaths в другую раскладку. План —
# plans/, всегда.
# Профильный путь от `project_paths_resolve` приходит в форме абсолютного
# (`<REPO_ABS>/<wp.contracts>`). Для сравнения с TARGET (относительным)
# получаем ПОСЛЕДНИЙ суффикс относительно ROOT.
case "$_PROFILE_CONTRACTS_BASE" in
  "$ROOT"/*) _PROFILE_CONTRACTS_REL="${_PROFILE_CONTRACTS_BASE#"$ROOT"/}" ;;
  *)         _PROFILE_CONTRACTS_REL="${_PROFILE_CONTRACTS_BASE#/}" ;;
esac
_PR_CONTRACTS="${_PROFILE_CONTRACTS_REL%/}/"
_ROOT_CONTRACTS_OK=0
case "${_PROFILE_CONTRACTS_REL:-contracts}" in
  contracts|"") _ROOT_CONTRACTS_OK=1 ;;
esac
_accepted=0
case "$TARGET" in
  plans/*) _accepted=1; dir="plans" ;;
  "${_PR_CONTRACTS}"*) _accepted=1; dir="contracts" ;;  # профильный — главный
  contracts/*)
    if [ "$_ROOT_CONTRACTS_OK" = "1" ]; then
      _accepted=1; dir="contracts"  # корневой только если профиль его и просит
    fi
    ;;
esac
[ "$_accepted" -eq 1 ] || die "done: имя контракта не по грамматике NNN: $TARGET"
unset _PROFILE_CONTRACTS_BASE _PROFILE_CONTRACTS_REL _PR_CONTRACTS _ROOT_CONTRACTS_OK
ARTIFACT_NUMBER=""
rc=0
parse_artifact_basename "$base" || rc=$?
if [ "$rc" -ne 0 ] || [ -z "${ARTIFACT_NUMBER:-}" ]; then
  die "done: имя контракта не по грамматике NNN: $base"
fi
NNN="$(printf '%03d' "$ARTIFACT_NUMBER")"

# ── 4. контракт закоммичен на HEAD ────────────────────────────────────────────
# TARGET: если абсолютный — отрезать ROOT-префикс.
case "$TARGET" in
  /*) TARGET_REL="${TARGET#$ROOT/}" ;;
  *)  TARGET_REL="$TARGET" ;;
esac
[ -f "$ROOT/$TARGET_REL" ] || die "done: контракт не закоммичен на HEAD: $TARGET_REL не существует"
head_blob="$(cd "$ROOT" && git rev-parse --verify --quiet "HEAD:$TARGET_REL" || true)"
[ -n "$head_blob" ] || die "done: контракт не закоммичен на HEAD: $TARGET_REL на HEAD отсутствует"
work_blob="$(cd "$ROOT" && git hash-object -- "$TARGET_REL")"
[ "$work_blob" = "$head_blob" ] || die "done: контракт не закоммичен на HEAD: $TARGET_REL в рабочем дереве отличается от HEAD (блобы $work_blob и $head_blob)"
# Файлы verdicts/review/contracts-<NNN>-*.md на HEAD; если несколько —
# свежий по коммит-истории. Первая строка → trim + case-fold → равенство
# `accept` (НЕ префикс; «Acceptance criteria met», «accepted» → вне грамматики).
# ОДНОВРЕМЕННО: первая строка ОБЯЗАНА быть `ACCEPT` | `FAIL` | `ESCALATE`.
vmax=0
vfiles="$(cd "$ROOT" && git ls-tree -r --name-only HEAD -- "${_PROFILE_VERDICTS_DIR%/}/" 2>/dev/null | grep -E "^${_PROFILE_VERDICTS_DIR%/}/contracts-$NNN-[^/]*\.md$" | sort -V || true)"
if [ -z "$vfiles" ]; then
  die "done: вердикт ревьюера не найден: ${_PROFILE_VERDICTS_DIR%/}/contracts-$NNN-*.md"
fi
_select_round_verdict "$vfiles" review
freshest="$_rv_file" freshest_cid="$_rv_cid" freshest_first="$_rv_first"
vcount=$(printf '%s\n' "$vfiles" | wc -l)

norm="$(printf '%s' "$freshest_first" | tr '[:upper:]' '[:lower:]')"
case "$norm" in
  accept) ;;
  fail)
    if [ "$vcount" -gt 1 ]; then
      die "done: несколько вердиктов, свежий $(basename "$freshest") не accept"
    fi
    die "done: вердикт ревьюера FAIL"
    ;;
  escalate)
    if [ "$vcount" -gt 1 ]; then
      die "done: несколько вердиктов, свежий $(basename "$freshest") не accept"
    fi
    die "done: вердикт ревьюера ESCALATE"
    ;;
  *)
    if [ "$vcount" -gt 1 ]; then
      die "done: несколько вердиктов, свежий $(basename "$freshest") не accept"
    fi
    die "done: вердикт вне грамматики: $freshest_first"
    ;;
esac

# ── КОНТРАКТ 187а: СВЕРКА-АРХИТЕКТУРЫ и check-run arch ───────────────────────
# Два свидетельства, оба до тега done (отказ не создаёт тег):
#   (1) вердикт ревьюера на OBJECT несёт САМОСТОЯТЕЛЬНУЮ непустую строку
#       «СВЕРКА-АРХИТЕКТУРЫ:» — упоминание внутри чужой строки (цитата,
#       приписка) свидетельством не является (ARCH_REVIEW). Содержательную
#       сверку судит предмет 188; 187а проверяет только наличие свидетельства.
#       План Fable Б-3 (ADR docs/owner/adr/2026-11-21-plan-fable.md): ARCH_REVIEW
#       — ПРЕДУПРЕЖДЕНИЕ в stderr, не отказ; отказом остаётся ARCH_CI (2).
#   (2) check-run `arch` проектного CI на ЭТОМ ЖЕ финальном SHA продукта main:
#       чужой SHA, отсутствующий, красный, skipped — ARCH_CI. Движок в done не
#       запускается (движок и CI проекта владеют этим свойством).
# Признак режима — эффективный repoId=Complior-back И пин модели; харнесс, mob
# и документальные предметы этих требований не получают.
if [ -x "$SELF_DIR/check_architecture_contract.sh" ]; then
  ARCH187_LIB=1
  # shellcheck disable=SC1091
  . "$SELF_DIR/check_architecture_contract.sh"
  if arch187_scope "$ROOT"; then
    _a187_txt="$(mktemp 2>/dev/null || true)"
    if [ -n "$_a187_txt" ] && [ -f "$_a187_txt" ]; then
      ( cd "$ROOT" && git cat-file -p "HEAD:$TARGET_REL" ) > "$_a187_txt" 2>/dev/null || true
      if arch187_code_subject "$_a187_txt"; then
        # (1) свидетельство ревьюера
        _a187_rev_ok=0
        ( cd "$ROOT" && git cat-file -p "HEAD:$freshest" ) 2>/dev/null \
          | tr -d '\r' \
          | while IFS= read -r _a187_line; do
              case "$_a187_line" in
                'СВЕРКА-АРХИТЕКТУРЫ:'*)
                  _a187_tail="${_a187_line#СВЕРКА-АРХИТЕКТУРЫ:}"
                  if [ -n "$(printf '%s' "$_a187_tail" | tr -d '[:space:]')" ]; then
                    printf 'ARCH_REVIEW_OK\n'
                    break
                  fi
                  ;;
              esac
            done > "$_a187_txt.flag" 2>/dev/null || true
        if [ -f "$_a187_txt.flag" ] && grep -q 'ARCH_REVIEW_OK' "$_a187_txt.flag" 2>/dev/null; then
          _a187_rev_ok=1
        fi
        rm -f "$_a187_txt.flag"
        if [ "$_a187_rev_ok" != "1" ]; then
          # План Fable Б-3 (ADR docs/owner/adr/2026-11-21-plan-fable.md):
          # ARCH_REVIEW — предупреждение с записью в stderr, не отказ: работа
          # двери продолжается; отказом остаётся ARCH_CI (2).
          printf 'ПРЕДУПРЕЖДЕНИЕ: ARCH_REVIEW: в вердикте ревьюера %s нет самостоятельной строки «СВЕРКА-АРХИТЕКТУРЫ:»; напиши самостоятельную строку «СВЕРКА-АРХИТЕКТУРЫ: <вывод>»\n' "$freshest" >&2
        fi
        # (2) check-run arch на ПРОДУКТОВОМ SHA линии поставки. Продуктовый
        # SHA — БЛИЖАЙШИЙ предок HEAD, после которого все изменения только
        # в `.harness/**` (служебный хвост: вердикты/реестр/HANDOFF проекта).
        # На таком хвосте CI `arch` пропускает (skipped) — зелёный run искать
        # надо на ближайшем продукте, а не на служебном коммите (слово
        # консультанта 23:52; контракт 187/2). Отставший tracking-ref
        # origin/main не берётся: зелёный run на старом/чужом SHA не
        # засчитывается за этот коммит. Тег done встаёт на HEAD, как прежде;
        # оба SHA (HEAD и SHA*) названы в диагностике ARCH_CI.
        _a187_sha="$(cd "$ROOT" && git rev-parse --verify --quiet HEAD 2>/dev/null || true)"
        [ -n "$_a187_sha" ] || die "ARCH_CI: финальный SHA продукта (HEAD) не читается"
        # SHA* — подъём по ПЕРВОМУ родителю, пока коммит меняет ТОЛЬКО пути
        # каталога `.harness/` (граница каталога: `.harnessx/…` — НЕ
        # `.harness`). Двухродительский PR-merge обходится: дельта merge —
        # итоговое состояние относительно ПЕРВОГО родителя (`git diff
        # <первый родитель> <merge>`); служебная дельта (только `.harness/**`)
        # — подъём по первому родителю, обход merge считается в пределе
        # глубины; продуктовая дельта — SHA* остаётся на самом merge.
        # Octopus (>2 родителей) — именованный отказ: произвольный merge не
        # выдаётся за проверенный PR-merge. Предел глубины: 50 служебных
        # коммитов разрешены, 51 — отказ с названной причиной; корневой
        # коммит — отказ с названной причиной.
        _a187_sel="$_a187_sha"
        _a187_why=""
        _a187_max=50
        _a187_skipped=0
        while :; do
          _a187_parents="$(cd "$ROOT" && git rev-list --parents -n 1 "$_a187_sel" 2>/dev/null || true)"
          _a187_rest="${_a187_parents#* }"
          [ "$_a187_rest" = "$_a187_parents" ] && _a187_rest=""
          _a187_np="$(printf '%s' "$_a187_rest" | wc -w | tr -d '[:space:]')"
          case "$_a187_np" in
            ''|*[!0-9]*) _a187_np=0 ;;
          esac
          if [ "$_a187_np" -eq 0 ]; then
            _a187_why="корневой коммит: родителей нет — подниматься некуда"
            break
          fi
          _a187_p1="${_a187_rest%% *}"
          if [ "$_a187_np" -gt 2 ]; then
            # Octopus (>2 родителей): произвольный merge не выдаётся за
            # проверенный PR-merge — именованный отказ до API.
            _a187_why="octopus: более двух родителей — подъём по первому родителю не определён"
            break
          fi
          # Двухродительский PR-merge судится тем же правилом, что и обычный
          # коммит: дельта — итоговое состояние относительно ПЕРВОГО
          # родителя (`git diff <первый родитель> <merge>`). Служебная дельта
          # (только `.harness/**`) — обход по первому родителю (обход merge
          # считается в пределе глубины); продуктовая — SHA* сам merge.
          _new_done_tmp || die "ARCH_CI: временный файл списка путей не создать"
          _a187_paths_file="$_DONE_TMP_LAST"
          # Список путей коммита ПОЛОН: обе стороны переименования и каждый
          # изменённый gitlink. `--no-renames` выключает rename-детект
          # (умолчание diff.renames=true скрывает старый путь), а
          # `--ignore-submodules=none` снимает и diff.ignoreSubmodules, и
          # `submodule.<name>.ignore` из .gitmodules: флаги команды сильнее
          # конфигурации пользователя и окружения.
          ( cd "$ROOT" && git diff --no-renames --ignore-submodules=none --name-only -z "$_a187_p1" "$_a187_sel" ) > "$_a187_paths_file" 2>/dev/null || true
          _a187_only=1
          _a187_npaths=0
          while IFS= read -r -d '' _a187_path; do
            _a187_npaths=$((_a187_npaths + 1))
            case "$_a187_path" in
              .harness/*) : ;;
              *) _a187_only=0 ;;
            esac
          done < "$_a187_paths_file"
          if [ "$_a187_npaths" -eq 0 ] || [ "$_a187_only" -ne 1 ]; then
            break
          fi
          if [ "$_a187_skipped" -ge "$_a187_max" ]; then
            _a187_why="лимит глубины подъёма ($_a187_max) исчерпан"
            break
          fi
          _a187_skipped=$((_a187_skipped + 1))
          _a187_sel="$_a187_p1"
        done
        if [ -n "$_a187_why" ]; then
          die "ARCH_CI: HEAD=$_a187_sha; SHA*=$_a187_sel; $_a187_why — успешного check-run arch нет"
        fi
        _a187_or=""
        if [ -f "$ROOT/harness.project.json" ]; then
          # Полный разбор профиля: ровно один JSON-документ-объект. Ошибка
          # разбора СУЩЕСТВУЮЩЕГО файла — отказ (не fallback на
          # GITHUB_REPOSITORY и не адрес из префикса); штатно отсутствующее
          # необязательное поле canonicalRemote — прежний допустимый fallback.
          _a187_profile=""
          _json_one_object _a187_profile < "$ROOT/harness.project.json" \
            || die "ОТКАЗ: профиль не читается (JSON не разобран: $_JSON_ERR): $ROOT/harness.project.json — canonicalRemote неизвестен; check-run arch не проверен (ARCH_CI)"
          _a187_remote="$(printf '%s' "$_a187_profile" | jq -r 'if (.git | type) == "object" then (.git.canonicalRemote // empty) else empty end' 2>/dev/null)" \
            || die "ОТКАЗ: профиль не читается (canonicalRemote не извлечён): $ROOT/harness.project.json"
          case "$_a187_remote" in
            *github.com[:/]*)
              _a187_or="$(printf '%s' "$_a187_remote" | sed -E 's#.*github\.com[:/]+##; s#\.git$##; s#/+$##')"
              ;;
          esac
        fi
        [ -n "$_a187_or" ] || _a187_or="${GITHUB_REPOSITORY:-unknown/unknown}"
        _a187_url="https://api.github.com/repos/$_a187_or/commits/$_a187_sel/check-runs?per_page=100"
        _a187_tok="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
        # --max-time: зависший API не должен hanging'ом держать done (совет С5).
        _a187_args=(-sS --max-time 30 -H 'Accept: application/vnd.github+json')
        [ -n "$_a187_tok" ] && _a187_args+=(-H "Authorization: Bearer $_a187_tok")
        _new_done_tmp || die "ARCH_CI: временный файл ответа check-runs не создать"
        _a187_body_file="$_DONE_TMP_LAST"
        _a187_crc=0
        curl "${_a187_args[@]}" "$_a187_url" > "$_a187_body_file" 2>/dev/null || _a187_crc=$?
        # Тот же класс (fail-open по rc): отказ транспорта (curl rc≠0) — ответ
        # недоступен независимо от stdout; доказательством check-run он не
        # является (контракт 187/2: «парные корректные входы rc 0»). rc
        # producer'а проверяется ДО разбора и ДО использования ответа.
        _a187_n=0
        if [ "$_a187_crc" -eq 0 ]; then
          # 201 (г): имя check-run arch — «arch», «arch …», «arch (…)».
          # «archive», «architecture…», «march», «arche» — НЕ принимаются:
          # живой зелёный run бэкенда называется «arch (пин внешней
          # архитектуры, model fitness + code-ratchet)» (ARCHCOL §5).
          # Полный разбор ответа: ровно один JSON-документ-объект. Ошибка
          # разбора — отказ семейства ARCH_CI (причина — РАЗБОР, не curl);
          # ошибочный stdout в счёт run не попадает. jq читает СЫРОЙ файл
          # ответа: NUL и прочие байты не проходят через bash-строку.
          _a187_obj=""
          if ! _json_one_object _a187_obj "$_a187_body_file"; then
            die "ARCH_CI: ответ check-runs не разобран ($_JSON_ERR): ожидался ровно один JSON-документ — успешного check-run arch нет (HEAD=$_a187_sha; SHA*=$_a187_sel)"
          fi
          # Зелёный run засчитывается на ПРОДУКТОВОМ SHA (SHA*) — правило
          # 187/2 (слово консультанта 23:52). Замороженное обязательство
          # 201/4(г) «head_sha == HEAD» НЕ отменяется: зелёный run на
          # финальном SHA линии поставки остаётся достаточным (на живой
          # GitHub-API SHA-адресованный ответ для SHA* несёт run только
          # этого SHA; HEAD совпадает с SHA*, когда служебного хвоста нет).
          _a187_n="$(printf '%s' "$_a187_obj" | jq -r --arg sha "$_a187_sel" --arg head "$_a187_sha" '[.check_runs[]? | select((((.name // "") == "arch") or ((.name // "") | startswith("arch ")) or ((.name // "") | startswith("arch ("))) and ((.head_sha == $sha) or (.head_sha == $head)) and (.status == "completed") and (.conclusion == "success"))] | length' 2>/dev/null)" \
            || _a187_n=""
        fi
        case "$_a187_n" in
          ''|*[!0-9]*) _a187_n=0 ;;
        esac
        [ "$_a187_n" -gt 0 ] || die "ARCH_CI: HEAD=$_a187_sha; SHA*=$_a187_sel; успешного check-run arch нет (curl rc=$_a187_crc)"
        printf 'ARCH_CI: HEAD=%s; SHA*=%s; успешный check-run arch засчитан\n' "$_a187_sha" "$_a187_sel" >&2
      fi
      rm -f "$_a187_txt"
    fi
    arch187_cleanup
  fi
fi

# ── 996: гейт сверки с источниками (ДО тега) ────────────────────────────────
# При объявленном sourceCanon — вызов check_project_sources.sh (stage=done).
# Отказ gate → rc 1 с маркером SOURCE_GATE_FAILED/INVALID/MISSING/UNAVAILABLE.
# Без канона — gate не запускается (К6 «без канона → rc 0 без запуска»).
# Гейт вооружён ТОЛЬКО при наличии harness.project.json в корне (режим проекта);
# в не-проектном режиме (харнес сам как проект, без harness.project.json) —
# действующее поведение двери НЕ меняется (К18/К19).
if [ -x "$SELF_DIR/check_project_sources.sh" ] && [ -f "$ROOT/harness.project.json" ]; then
  srcs_out="$(bash "$SELF_DIR/check_project_sources.sh" --repo "$ROOT" --contract "$TARGET_REL" --stage done 2>&1)" || die "source gate: $srcs_out"
fi
# ── 6. ПРОВОДКА через барьер check_provodka.sh ────────────────────────────────
# Барьер работает относительно КОРНЯ репозитория (не каталога контракта) —
# пути ПРОВОДКА даны относительно корня дерева (канон freeze_contract.sh:59).
# ROOT задан выше (3-й аргумент) или default к каталогу скрипта.
contract_rel="$TARGET"
contract_rel="$(printf '%s' "$contract_rel" | sed 's|^\./||; s|//|/|g')"
prov_rc=0
prov_out=""
prov_out="$(cd "$ROOT" && bash "$SELF_DIR/check_provodka.sh" "$ROOT" "$contract_rel" 2>&1)" || prov_rc=$?
if [ "$prov_rc" -ne 0 ]; then
  if [ "$prov_rc" = "2" ]; then
    die "done: ПРОВОДКА не проверена (rc 2)"
  fi
  first_prov_phrase="$(printf '%s' "$prov_out" | head -n 1)"
  die "done: ПРОВОДКА красна: $first_prov_phrase"
fi
# ── 6а. ПОТРЕБИТЕЛИ (после ПРОВОДКИ, ДО клапана)
# Окно = frozen/contracts/<NNN>/<v> .. HEAD на момент тега DONE.
# check_consumers.sh <root> <contract>.
cons_rc=0
cons_out=""
cons_out="$(bash "$SELF_DIR/check_consumers.sh" "$ROOT" "$contract_rel" 2>&1)" || cons_rc=$?
if [ "$cons_rc" -ne 0 ]; then
  if [ "$cons_rc" = "2" ]; then
    die "done: потребители не проверены (rc 2)"
  fi
  first_cons_phrase="$(printf '%s' "$cons_out" | head -n 1)"
  die "done: потребители 116 красны: $first_cons_phrase"
fi

# ── 6б. СОДЕРЖАТЕЛЬНАЯ СВЕРКА (контракт 201) ────────────────────────────────
# Порядок внутри 6б: (а) → (б) → (в) → (а²). Тождество деревьев при F==CID
# замыкает шаг: вычет адверсария определён лишь accept-файлом, выбранным в (в).
# Все отказы здесь — НОВЫЕ имена; отказы шагов 1–6а не тронуты.

# (а) ПРИВЯЗКА ACCEPT К ПОСЛЕДНЕЙ ЗАМОРОЗКЕ ──────────────────────────────────
# vmax — МАКСИМУМ по тегам refs/tags/frozen/contracts/<NNN>/* (не «первый
# попавшийся»: боль 991/999 — accept эры старшей заморозки). Ошибка
# перечисления — именованный отказ, версия не угадывается (канон 992).
froz_rc=0
froz_list="$(cd "$ROOT" && git for-each-ref --format='%(refname)' "refs/tags/frozen/contracts/$NNN/" 2>/dev/null)" || froz_rc=$?
[ "$froz_rc" -eq 0 ] || die "done: перечень заморозок не читается (git for-each-ref rc=$froz_rc): refs/tags/frozen/contracts/$NNN/ — проверить невозможно, версия не угадывается"
frozen_vmax=0
while IFS= read -r _fref; do
  [ -n "$_fref" ] || continue
  _fvn="$(printf '%s' "$_fref" | sed -nE 's@.*frozen/contracts/[0-9]+/([0-9]+)@\1@p')"
  [ -n "$_fvn" ] || continue
  [ "$_fvn" -gt "$frozen_vmax" ] 2>/dev/null && frozen_vmax="$_fvn"
done <<< "$froz_list"
[ "$frozen_vmax" -gt 0 ] || die "done: нет заморозки frozen/contracts/$NNN/* — привязка accept к последней версии невозможна"
frozen_tag="frozen/contracts/$NNN/$frozen_vmax"
froz_rc=0
frozen_commit="$(cd "$ROOT" && git rev-parse --verify --quiet "$frozen_tag^{commit}" 2>/dev/null)" || froz_rc=$?
[ "$froz_rc" -eq 0 ] && [ -n "$frozen_commit" ] || die "done: заморозка $frozen_tag не читается (git rev-parse rc=$froz_rc) — версия не угадывается"

# OBJECT-строка свежего accept-вердикта ревьюера: anchored ^OBJECT=<40 hex>$.
object_sha=""
object_sha="$(cd "$ROOT" && git cat-file -p "HEAD:$freshest" 2>/dev/null | tr -d '\r' | sed -nE 's/^OBJECT=([0-9a-f]{40})$/\1/p' | sed -n 1p)"
[ -n "$object_sha" ] || die "done: вердикт $freshest без строки OBJECT=<40 hex> — объект реализации не назван"

# Свежесть: коммит вердикта — потомок F (равенство проходит).
fresh_rc=0
( cd "$ROOT" && git merge-base --is-ancestor "$frozen_commit" "$freshest_cid" ) || fresh_rc=$?
case "$fresh_rc" in
  0) : ;;
  1) die "done: accept ревьюера $freshest предшествует последней заморозке $frozen_tag — accept старой версии не открывает done новой" ;;
  *) die "done: порядок заморозки и вердикта не читается (merge-base rc=$fresh_rc): $freshest — проверить невозможно" ;;
esac

# Связь ОБЪЕКТА с последней заморозкой — на самом OBJECT (датирование файла
# вердикта связи не доказывает). Для локально разрешимого OBJECT.
object_local=0
object_commit="$(cd "$ROOT" && git rev-parse --verify --quiet "$object_sha^{commit}" 2>/dev/null || true)"
[ -n "$object_commit" ] && object_local=1
if [ "$object_local" = "1" ]; then
  bind_rc=0
  if [ "$frozen_commit" = "$freshest_cid" ]; then
    # F == CID: OBJECT ⊆ F; тождество деревьев — в (а²), в конце 6б.
    ( cd "$ROOT" && git merge-base --is-ancestor "$object_sha" "$frozen_commit" ) || bind_rc=$?
  else
    # F ⊊ CID: реализация этой версии пишется ПОСЛЕ заморозки — F ⊆ OBJECT.
    ( cd "$ROOT" && git merge-base --is-ancestor "$frozen_commit" "$object_sha" ) || bind_rc=$?
  fi
  case "$bind_rc" in
    0) : ;;
    1) die "done: OBJECT $object_sha не связан с последней заморозкой $frozen_tag — вердикт судит объект старой версии" ;;
    *) die "done: связь OBJECT $object_sha с заморозкой $frozen_tag не читается (merge-base rc=$bind_rc) — проверить невозможно" ;;
  esac
fi

# ЗАМОРОЖЕННЫЙ текст версии vmax — источник объявления места реализации и
# строки класса риска (не рабочая копия, не индекс).
froz_rc=0
frozen_text="$(cd "$ROOT" && git cat-file -p "$frozen_tag:$TARGET_REL" 2>/dev/null)" || froz_rc=$?
[ "$froz_rc" -eq 0 ] && [ -n "$frozen_text" ] || die "done: замороженный текст контракта не читается (git show rc=$froz_rc): $frozen_tag:$TARGET_REL — проверить невозможно"
frozen_text="$(printf '%s' "$frozen_text" | tr -d '\r')"
frozen_blob="$(cd "$ROOT" && git rev-parse --verify --quiet "$frozen_tag:$TARGET_REL" 2>/dev/null || true)"

# Реестры — профильные пути (996), относительные к корню (git show HEAD:<путь>).
case "$_PROFILE_REGISTRY_PATH" in
  "$ROOT"/*) _REGISTRY_REL="${_PROFILE_REGISTRY_PATH#"$ROOT"/}" ;;
  *)         _REGISTRY_REL="${_PROFILE_REGISTRY_PATH#/}" ;;
esac

# (б) ВЛИТОСТЬ РЕАЛИЗАЦИИ ────────────────────────────────────────────────────
# Режим — по эффективному repoId корня (резолвер профиля; тот же канал
# чтения, что у arch187_scope). Ошибка резолвера — именованный rc 1.
repo_id=""
if [ -f "$ROOT/harness.project.json" ]; then
  prc_rc=0
  merged_profile="$(HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-$ROOT}" bash "$SELF_DIR/profile_resolver.sh" --repo "$ROOT" 2>/dev/null)" || prc_rc=$?
  [ "$prc_rc" -eq 0 ] || die "ОТКАЗ: профиль не читается (profile_resolver rc=$prc_rc): repoId неизвестен — режим двери не определён"
  # Полный разбор merged-профиля: ровно один JSON-документ-объект. Ошибка
  # разбора НЕ определяет режим и НЕ ведёт к legacy/station fallback.
  _merged_profile_obj=""
  _json_one_object _merged_profile_obj <<<"$merged_profile" \
    || die "ОТКАЗ: профиль не читается (JSON не разобран: $_JSON_ERR): repoId неизвестен — режим двери не определён"
  repo_id="$(printf '%s' "$_merged_profile_obj" | jq -r 'if (.repoId | type) == "object" then (.repoId.value // empty) else (.repoId // empty) end' 2>/dev/null)" \
    || repo_id=""
  [ -n "$repo_id" ] || die "ОТКАЗ: профиль без repoId — режим двери не определён"
else
  # Профиля нет — корневая раскладка станции (LEGACY-FALLBACK
  # project_paths_resolve); продуктовый режим без профиля неотличим от
  # станционного, и место реализации всё равно проверяется явным объявлением.
  repo_id="dev-harness"
fi

if [ "$repo_id" != "dev-harness" ]; then
  # РЕЖИМ ПРОДУКТА: OBJECT обязан разрешаться в репо продукта и быть
  # равен/предком HEAD (дверь работает на влитом main).
  [ "$object_local" = "1" ] || die "done: OBJECT $object_sha отсутствует в репо продукта — реализация не влита"
  anc_rc=0
  ( cd "$ROOT" && git merge-base --is-ancestor "$object_sha" HEAD ) || anc_rc=$?
  case "$anc_rc" in
    0) : ;;
    1) die "done: OBJECT $object_sha не предок HEAD — реализация не влита в main продукта" ;;
    *) die "done: влитость OBJECT $object_sha в main продукта не читается (merge-base rc=$anc_rc) — проверить невозможно" ;;
  esac
else
  # РЕЖИМ СТАНЦИИ: место реализации — ЯВНОЕ, три состояния (РЕШЕНИЕ 2
  # арбитража 1): объявление ПРОДУКТ: в замороженном тексте vmax, запись
  # реестра по (номер предмета, blob замороженного текста) — либо отказ.
  place=""
  plines=()
  while IFS= read -r _pl; do
    [ -n "$_pl" ] && plines+=("$_pl")
  done < <(printf '%s\n' "$frozen_text" | grep '^ПРОДУКТ:' || true)
  if [ "${#plines[@]}" -gt 1 ]; then
    _pvals=""
    for _pl in "${plines[@]}"; do
      _pv="$(printf '%s' "${_pl#ПРОДУКТ:}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      _pvals="${_pvals:+$_pvals; }$_pv"
    done
    die "done: строка ПРОДУКТ: неоднозначна: $_pvals"
  elif [ "${#plines[@]}" -eq 1 ]; then
    _pdecl="${plines[0]}"
    if [ "$_pdecl" = "ПРОДУКТ: станция" ]; then
      place="станция"
    elif printf '%s' "$_pdecl" | grep -Eq '^ПРОДУКТ: [A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$'; then
      place="$(printf '%s' "$_pdecl" | sed -nE 's/^ПРОДУКТ: ([A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+)$/\1/p')"
    else
      die "done: строка ПРОДУКТ: вне грамматики: $_pdecl"
    fi
  fi
  if [ -z "$place" ]; then
    # Нет объявления → реестр классификации. Источник — закоммиченный на
    # HEAD файл (рабочая копия и индекс — не свидетельство, п.8 AGENTS.md).
    _mreg="${_REGISTRY_REL}/mesto-legacy.tsv"
    _mrc=0
    _mtext="$(cd "$ROOT" && git show "HEAD:$_mreg" 2>/dev/null)" || _mrc=$?
    _mhits=0
    _mval=""
    if [ "$_mrc" -eq 0 ]; then
      _mhits="$(printf '%s\n' "$_mtext" | awk -F'\t' -v n="$NNN" -v b="$frozen_blob" 'NF>=3 && $1==n && $2==b {c++} END {print c+0}')"
      [ "$_mhits" -gt 0 ] && _mval="$(printf '%s\n' "$_mtext" | awk -F'\t' -v n="$NNN" -v b="$frozen_blob" 'NF>=3 && $1==n && $2==b {print $3; exit}')"
    fi
    if [ "$_mhits" -eq 0 ]; then
      die "done: место реализации предмета $NNN не установлено — нет объявления ПРОДУКТ: и нет применимой записи registry/mesto-legacy.tsv"
    elif [ "$_mhits" -gt 1 ]; then
      die "done: классификация места предмета $NNN в registry/mesto-legacy.tsv неоднозначна или вне грамматики — отказ до исправления записи"
    fi
    case "$_mval" in
      'станция') place="станция" ;;
      *) if printf '%s' "$_mval" | grep -Eq '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$'; then
           place="$_mval"
         else
           die "done: классификация места предмета $NNN в registry/mesto-legacy.tsv неоднозначна или вне грамматики — отказ до исправления записи"
         fi ;;
    esac
  fi
  if [ "$place" = "станция" ]; then
    [ "$object_local" = "1" ] || die "done: OBJECT $object_sha вне репо станции, а контракт объявил станционную реализацию — OBJECT обязан быть SHA станции"
  else
    if [ "$object_local" = "1" ]; then
      die "done: OBJECT $object_sha разрешается в репо станции, а контракт объявил продукт $place — OBJECT внешнего предмета обязан быть SHA продукта"
    fi
    # Влитость в main продукта — GitHub compare API приёмом 187а.
    _cmp_url="https://api.github.com/repos/$place/compare/main...$object_sha"
    _cmp_tok="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
    _cmp_args=(-sS --max-time 30 -H 'Accept: application/vnd.github+json')
    [ -n "$_cmp_tok" ] && _cmp_args+=(-H "Authorization: Bearer $_cmp_tok")
    _new_done_tmp || die "done: влитость в main продукта $place не проверена: временный файл ответа compare не создать"
    _cmp_body_file="$_DONE_TMP_LAST"
    _cmp_crc=0
    curl "${_cmp_args[@]}" "$_cmp_url" > "$_cmp_body_file" 2>/dev/null || _cmp_crc=$?
    # Отказ транспорта (curl rc≠0) — ответ НЕдоступен независимо от stdout:
    # частичный ответ при ошибке транспорта доказательством влитости не
    # является (контракт 201 §2(б): «ответ недоступен (curl rc≠0, …) →
    # не проверена»; позитивный ответ требует УСПЕШНОГО compare, rc 0).
    # Проверка rc — ДО разбора status: иначе behind|identical из ответа при
    # ошибке транспорта составили бы тег done.
    if [ "$_cmp_crc" -ne 0 ]; then
      die "done: влитость в main продукта $place не проверена: curl rc=$_cmp_crc"
    fi
    # Полный разбор ответа compare: ровно один JSON-документ-объект.
    # Повреждённый ответ или поток документов — не свидетельство влитости;
    # парсерная ошибка НЕ выдаётся за ahead/diverged и НЕ сводится к
    # «нет поля status», если поле было в префиксе. jq читает СЫРОЙ файл
    # ответа: NUL и прочие байты не проходят через bash-строку.
    _cmp_obj=""
    if ! _json_one_object _cmp_obj "$_cmp_body_file"; then
      die "done: влитость в main продукта $place не проверена: ответ API не разобран ($_JSON_ERR)"
    fi
    _cmp_status_kind=""
    _cmp_status_kind="$(printf '%s' "$_cmp_obj" | jq -r 'if (has("status") | not) then "absent" elif ((.status | type) == "string") and (.status == "identical") then "identical" elif ((.status | type) == "string") and (.status == "behind") then "behind" elif ((.status | type) == "string") and (.status == "ahead") then "ahead" elif ((.status | type) == "string") and (.status == "diverged") then "diverged" else "unsupported" end' 2>/dev/null)" \
      || _cmp_status_kind="unsupported"
    case "$_cmp_status_kind" in
      identical|behind) : ;;
      ahead|diverged) die "done: OBJECT $object_sha не в main продукта $place — реализация не влита" ;;
      absent) die "done: влитость в main продукта $place не проверена: ответ API без поля status" ;;
      *) die "done: влитость в main продукта $place не проверена: неподдерживаемое значение status" ;;
    esac
  fi
fi

# (в) АДВЕРСАРИЙ РИСКОВЫМ ────────────────────────────────────────────────────
# Класс — по ЗАМОРОЖЕННОМУ тексту vmax: все вхождения грамматики zamok
# обязаны соглашаться; нет строки → реестр risk-legacy.tsv по blob (только из
# закоммиченного на HEAD файла); нет записи → рисковый (норма оркестратора).
_risk_vals="$(printf '%s\n' "$frozen_text" | grep -E -o 'КЛАСС РИСКА:[[:blank:]]*(обычный|рисковый)([[:blank:].,;]|$)' | sed -E -e 's/^КЛАСС РИСКА:[[:blank:]]*//' -e 's/[[:blank:].,;]$//' | sort -u | sed '/^$/d' || true)"
_nrisk="$(printf '%s\n' "$_risk_vals" | sed '/^$/d' | wc -l | tr -d ' ')"
if [ "$_nrisk" -gt 1 ]; then
  die "done: класс риска контракта неоднозначен — судьи не определены"
fi
if [ "$_nrisk" -eq 1 ]; then
  risk_class="$_risk_vals"
else
  _lreg="${_REGISTRY_REL}/risk-legacy.tsv"
  _lrc=0
  _ltext="$(cd "$ROOT" && git show "HEAD:$_lreg" 2>/dev/null)" || _lrc=$?
  risk_class=""
  [ "$_lrc" -eq 0 ] && risk_class="$(printf '%s\n' "$_ltext" | awk -F'\t' -v b="$frozen_blob" 'b!="" && $1==b {print $2; exit}')"
  case "$risk_class" in
    'обычный'|'рисковый') : ;;
    '') risk_class="рисковый" ;;   # нет записи — рисковый (норма оркестратора)
    *) die "done: класс риска контракта неоднозначен — судьи не определены" ;;
  esac
fi
afresh=""
if [ "$risk_class" = "рисковый" ]; then
  _adir="${_PROFILE_VERDICTS_DIR%/review}/adversary"
  _afiles="$(cd "$ROOT" && git ls-tree -r --name-only HEAD -- "$_adir/" 2>/dev/null | grep -E "^${_adir}/contracts-$NNN-[^/]*\.md$" | sort -V || true)"
  if [ -z "$_afiles" ]; then
    die "done: предмет рисковый, accept адверсария не найден: $_adir/contracts-$NNN-*.md"
  fi
  _select_round_verdict "$_afiles" adversary
  afresh="$_rv_file" _afresh_cid="$_rv_cid" _afresh_first="$_rv_first"
  _anorm="$(printf '%s' "$_afresh_first" | tr '[:upper:]' '[:lower:]')"
  [ "$_anorm" = "accept" ] || die "done: свежий вердикт адверсария $afresh не accept"
  _aobject="$(cd "$ROOT" && git cat-file -p "HEAD:$afresh" 2>/dev/null | tr -d '\r' | sed -nE 's/^OBJECT=([0-9a-f]{40})$/\1/p' | sed -n 1p)"
  [ -n "$_aobject" ] || die "done: вердикт адверсария $afresh без строки OBJECT=<40 hex> — объект не назван"
  [ "$_aobject" = "$object_sha" ] || die "done: accept адверсария $afresh на объект $_aobject, ревьюера — на $object_sha: требуется тот же объект"
fi

# (а²) ТОЖДЕСТВО ГИТ-ДЕРЕВЬЕВ ПРИ F == CID ─────────────────────────────────
# Канон — plumbing: git diff-tree -r --raw --no-renames (пути, моды, OID,
# удаления, gitlinks). Вычет — ТОЛЬКО точные файлы судебных свидетельств
# этого предмета: выбранный reviewer-файл и (для рискового) выбранный
# accept-файл адверсария. Ошибка Git — не доказанное равенство.
if [ "$frozen_commit" = "$freshest_cid" ] && [ "$object_local" = "1" ]; then
  _exempt="$freshest"
  if [ "$risk_class" = "рисковый" ] && [ -n "$afresh" ]; then
    _exempt="$_exempt
$afresh"
  fi
  _dt_rc=0
  _dt_out="$(cd "$ROOT" && git -c diff.renames=false diff-tree -r --raw --no-renames "$object_sha" "$frozen_commit" 2>/dev/null)" || _dt_rc=$?
  _residue=""
  [ "$_dt_rc" -eq 0 ] && _residue="$(printf '%s\n' "$_dt_out" | awk -F'\t' '/^:/ && NF>=2 {print $2}')"
  _bad=""
  while IFS= read -r _p; do
    [ -n "$_p" ] || continue
    _ok=0
    while IFS= read -r _e; do
      [ -n "$_e" ] || continue
      [ "$_p" = "$_e" ] && { _ok=1; break; }
    done <<< "$_exempt"
    [ "$_ok" -eq 1 ] || _bad="$_bad$_p"$'\n'
  done <<< "$_residue"
  if [ "$_dt_rc" -ne 0 ] || [ -n "$_bad" ]; then
    die "done: OBJECT $object_sha не связан с последней заморозкой $frozen_tag — вердикт судит объект старой версии"
  fi
fi

# ── 7. клапан: РАЗРЕШИЛ-ВЛАДЕЛЕЦ на v>1 или на красную ПРОВОДКУ ─────────────
# (мы УЖЕ прошли ПРОВОДКА rc 0 — значит клапан НЕ открывает ничего; v>1 ещё
# не вычислили — вычислим ниже и проверим.)

# ── вычисляем v = max+1 по тегам done/contracts/<NNN>/ ────────────────────────
done_vmax=0
# Ошибка перечисления версий — именованный отказ, не v1 вслепую (992): при
# существующем v2 пустой перечень прежде молча выдумывал v1 и тег писался
# без чтения списка. rc process substitution родителем не наблюдался.
dfer_rc=0
dfer_out="$(cd "$ROOT" && git for-each-ref --format='%(refname)' "refs/tags/done/contracts/$NNN/" 2>/dev/null)" || dfer_rc=$?
[ "$dfer_rc" -eq 0 ] || die "done: перечень версий не читается (git for-each-ref rc=$dfer_rc): refs/tags/done/contracts/$NNN/ — проверить невозможно, версия не угадывается"
while IFS= read -r t; do
  [ -n "$t" ] || continue
  vn="$(printf '%s' "$t" | sed -nE 's@.*done/contracts/[0-9]+/([0-9]+)@\1@p')"
  [ -n "$vn" ] || continue
  [ "$vn" -gt "$done_vmax" ] 2>/dev/null && done_vmax="$vn"
done <<<"$dfer_out"
v=$((done_vmax + 1))

if [ "$v" -gt 1 ]; then
  # ASCII-дефис U+002D, grep -F литерал
  if ! printf '%s' "$REASON" | grep -Fq 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ:'; then
    die "done: v>1 требует строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в причине"
  fi
fi

# ── 8. тег done/contracts/<NNN>/<v> с причиной в аннотации ──────────────────
tag="done/contracts/$NNN/$v"
# Цель тега — финальный SHA линии поставки (HEAD), как прежде: правило
# 187/2 (слово консультанта 23:52) ищет check-run arch на ближайшем
# ПРОДУКТОВОМ предке (SHA*), но тег done остаётся на HEAD — служебный
# хвост `.harness/**` частью поставки не является. Пусто — предмет не
# backend: цель по умолчанию (HEAD), как прежде.
_a187_tag_target="${_a187_sha:-}"
if [ -n "$_a187_tag_target" ]; then
  if ! out="$(cd "$ROOT" && git -c user.name=Fixture -c user.email=fixture@local tag -a "$tag" -m "$REASON" "$_a187_tag_target" 2>&1)"; then
    printf 'ОТКАЗ: тег %s не создан: %s\n' "$tag" "$out" >&2
    exit 1
  fi
elif ! out="$(cd "$ROOT" && git -c user.name=Fixture -c user.email=fixture@local tag -a "$tag" -m "$REASON" 2>&1)"; then
  printf 'ОТКАЗ: тег %s не создан: %s\n' "$tag" "$out" >&2
  exit 1
fi
