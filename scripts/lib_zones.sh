# НЕ БАРЬЕР: библиотека, а не гейт. Вердикт кодом возврата выносит тот, кто её подключил; сама
# она только читает замороженные контракты и выдаёт структурированное представление их зон.
#
# Заведено потому, что второй читатель ЗОНА-строк расходился бы молча: check_zones собирал зоны
# из refs/tags/frozen/contracts/ для суда коммитов, а check_staged (контракт 016) читал то же
# для суда staged-множества. Один формат — один читатель: иначе правка контракта меняла бы
# предмет одного барьера и молча не меняла другой, и приёмка зон была бы зелёной у одного и
# красной у другого по одному и тому же дереву. Прецедент — `lib_roles.sh`/`lib_registry.sh`,
# которые сделали то же самое для `verdict:` и тегов заморозок.
#
# КОНТРАКТ ФУНКЦИИ ОДИН — `zones_load <корень>`. Возвращает 0 при успехе (включая случай, когда
# замороженных контрактов нет — пустой результат не ошибка), 1 при отказе реестра, 2 при
# NOT_IMPLEMENTED. Результат — каталог, который функция СОЗДАЁТ и ПЕЧАТАЕТ В STDIO (путь
# единственным stdout-аргументом). Формат файлов внутри — TSV или NUL.
#
# Файлы:
#   zones_scoped    — все валидные ЗОНА-строки из блобов высших заморозок:
#                     автор<TAB>путь<TAB>контракт;
#   zones_violations — нарушения грамматики ЗОНА. NUL-разделённые поля в порядке:
#                     контракт, файл, причина, автор, путь, сырая_строка.
#                     NUL выбран потому, что в ЗОНА-строках он не встречается, а TAB —
#                     может (имя автора с табуляцией — отдельный класс нарушения, и
#                     табулированный сырая строка рвала бы TSV). Поставщик НЕ печатает
#                     текст — текст и формулировка остаются у потребителя (замороженная
#                     ветвь check_zones);
#   ranges          — диапазоны применения: контракт<TAB>frozen/contracts/<NNN>/1[..done/contracts/<NNN>/1];
#   contracts_list  — все NNN контрактов, для которых читан блоб.
#
# Поставщик ИМЯ АВТОРА НЕ ПРОВЕРЯЕТ — эту проверку делает потребитель, потому что у
# check_zones «необъявленные авторы не проверяются» (историческая норма), а у check_staged
# «author пуст → не судится», и обходятся они по-разному. Поставщик отдаёт копию —
# список ЗОНА-строк, — а правило «как с этим жить» выбирает вызвавший.
#
#   bash scripts/check_zones.sh            проверить это дерево (через lib_zones)
#   bash scripts/check_staged.sh <корень>  проверить другое (через lib_zones)
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

# Канонизация пути БЕЗ mkdir — спуск до существующего предка + pwd -P.
lib_zones_canon() {
  local p="$1" tail="" cur _c
  [ -n "$p" ] || return 1
  case "$p" in /*) ;; *) p="$PWD/$p" ;; esac
  cur="$p"
  while [ ! -d "$cur" ] && [ -n "$cur" ]; do
    tail="/${cur##*/}${tail}"
    cur="${cur%/*}"
  done
  [ -n "$cur" ] || return 1
  _c="$(cd "$cur" 2>/dev/null && pwd -P 2>/dev/null)" || return 1
  printf '%s%s' "$_c" "$tail"
}

# Вынесение скратча НАРУЖУ корня (канон 014: scratch живёт вне стерегомого
# дерева в любом режиме — иначе чужой корень без .gitignore загрязняется
# при первом же zones_load, и пре-условие «главное дерево чисто» режет раньше
# ожидаемого отказа). Каталог скратча и маркер-файл лежат рядом под
# ${TMPDIR:-/tmp}/lib_zones.<hash8 корня>.XXXXXX (скратч) и тот же префикс
# + .active (маркер); LIB_ZONES_BASE позволяет потребителю указать иную базу.
#
# hash8 от КАНОНИЧЕСКОГО корня — лексические алиасы одного пути дают один
# и тот же каталог скратча (прецедент verify_antiplacebo HASH8).
__lib_zones_paths() {  # <корень>  →  stdout: canon\ntemplate\nmarker
  local canon h base
  canon="$(lib_zones_canon "$1")" || return 1
  h="$(printf '%s' "$canon" | sha256sum | cut -c1-8)"
  base="${LIB_ZONES_BASE:-${TMPDIR:-/tmp}}"
  printf '%s\n%s/lib_zones.%s.XXXXXX\n%s/lib_zones.%s.active\n' \
    "$canon" "$base" "$h" "$base" "$h"
}

# Уборка устаревших маркера и оболочек (от прошлых прогонов и крашей) при
# каждом zones_load — чтобы /tmp не копил мусор. Принимает три пути одной
# строкой: канон., шаблон mktemp, маркер.
__lib_zones_self_gc() {
  local marker="$1" scratch_tmpl="$2" base p d bn
  # 1) Маркер: подчистить указанный им скратч и сам файл.
  if [ -f "$marker" ]; then
    p="$(cat "$marker" 2>/dev/null || true)"
    [ -n "$p" ] && [ "$p" != "$marker" ] && [ -d "$p" ] && rm -rf -- "$p"
    rm -f -- "$marker"
  fi
  # 2) Сироты: каталоги с тем же префиксом (без финального .XXXXXX).
  base="${scratch_tmpl%.XXXXXX}"
  for d in "$base".*; do
    [ -e "$d" ] || continue
    bn="${d##*/}"
    case "$bn" in
      *.active) continue ;;   # marker — снят шагом 1
    esac
    [ -d "$d" ] && rm -rf -- "$d"
  done
}

# Уборка скратча zones_load из EXIT-ловушки потребителя: читает маркер по
# НОВОМУ пути (вне корня) и снимает скратч. Подробно: zones_load пишет маркер
# сразу после mktemp; маркер на диске переживает границу `$(zones_load ...)`
# (подshell выхода НЕ запускает EXIT-ловушку — проверено эмпирически, $BASHPID
# родителя и подshell'а различаются), и родительская ловушка читает маркер,
# удаляя каталог скратча уже после того, как потребитель прочитал файлы из него.
#
# Потребитель ОБЯЗАН задать `LIB_ZONES_ROOT=$root` (канонический) ДО первого
# вызова zones_load — иначе очистка no-op, и ответственность за скратч ложится
# на потребителя. check_zones.sh выставляет LIB_ZONES_ROOT сразу после
# вычисления ROOT и зовёт __lib_zones_cleanup из своего EXIT-ловушки совместно
# с `rm -rf "$TMP"` — так снимаются ОБА скратча скрипта (свой + lib_zones),
# без шанса на подмену `trap ... EXIT` в обход.
__lib_zones_cleanup() {
  if [ -n "${LIB_ZONES_ROOT:-}" ]; then
    local marker
    if ! marker="$(__lib_zones_paths "$LIB_ZONES_ROOT" 2>/dev/null | sed -n '3p')"; then
      return 0
    fi
    [ -n "$marker" ] || return 0
    [ -f "$marker" ] || return 0
    local p
    p="$(cat "$marker" 2>/dev/null || true)"
    [ -n "$p" ] && [ "$p" != "$marker" ] && rm -rf -- "$p"
    rm -f -- "$marker"
  fi
}

# zones_load <корень-репо>
# stdout: каталог с файлами zones_scoped, zones_violations, ranges, contracts_list.
# rc 0 при успехе (включая «нет контрактов»); 1 при отказе реестра; 2 при NOT_IMPLEMENTED.
#
# Пути — ИЗ БЛОБА ВЫСШЕЙ ЗАМОРОЗКИ, не из рабочего дерева (иначе правка контракта расширяла бы
# зону без заморозки). Диапазон применения — от ПЕРВОЙ заморозки контракта до done-тега, если
# он есть, иначе до HEAD (Н-14).
# project_paths_resolve <REPO> — ЕДИНЫЙ резолвер путей профиля (контракт 996
# пакет Б-5/Б-9, исправление toy-миров). Здесь — для двери freeze/done/
# check_zones/check_staged, копируемых в toy-мир scripts/next_id.sh
# (ap-фикстура fixtures/freeze_contract/fail_closed_992.py); те же строки
# (дословно) — в scripts/lib_zones.sh для сценария check_hooks.sh, чей
# toy_scratch несёт lib_zones.sh, но не next_id.sh. scripts/project_workflow.sh
# — тонкая обёртка над этой функцией (тот же JSON наружу).
#
#   stdout: JSON ОДНОГО документа с ключами contracts/verdicts/registry/
#           fixtures/handoff/observations/architectObservations/roadmap/
#           forks/sourceCanon (полный набор как у scripts/project_workflow.sh).
#   rc 0 — успех (LEGACY-FALLBACK на корне репо, либо резолв профиля).
#   rc 1 — отказ с именованной причиной на stderr (битый профиль,
#          workflowPaths вне репо, симлинк-побег, отсутствие git/jq/profile_resolver.sh).
#
# Каталог библиотеки (для поиска profile_resolver.sh) вычисляется из
# BASH_SOURCE[0] этой функции — own-раскладка, не переданный аргумент.
# HARNESS_PROJECT_LAYER_ROOT устанавливается равным REPO_ABS, чтобы
# profile_resolver нашёл слой проекта; env override (если выставлен
# вызывающей стороной) сохраняется.
project_paths_resolve() {
  local _lib_dir REPO_ABS MERGED STATE _STATE_ABS _STATE_PREFIX _wpk _wpv _wpcanon _err _pc_reason
  local CONTRACTS VERDICTS REGISTRY FIXTURES SOURCE_CANON
  _lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || {
    printf 'project_paths_resolve: каталог библиотеки не определён\n' >&2; return 1; }

  REPO_ABS="$(cd "$1" 2>/dev/null && pwd -P)" || {
    printf 'project_paths_resolve: каталог репо не существует: %s\n' "$1" >&2
    return 1
  }

  # LEGACY-FALLBACK (контракт 996 §Интерфейсы, К6 «корневые раскладки — не запасной
  # источник»): при ОТСУТСТВИИ harness.project.json — дефолтная корневая раскладка
  # репо. Это НЕ запасной источник для БИТОГО профиля: резолвер отказывает на
  # мусорном harness.project.json, и эта ветвь НЕ перехватывает отказ.
  # JSON строится БЕЗ jq (printf + ручное экранирование \" и \) — toy-миры
  # check_hooks / check_staged / check_zones / freeze_contract имеют PATH
  # БЕЗ /usr/bin (Н-333 verify_antiplacebo фикстуры), и падать на отсутствии
  # jq в LEGACY-FALLBACK — нарушение шва Б-9 (дверь судит профиль и при
  # «профиля нет»). Пути REPO_ABS НЕ содержат \" и \ в корректной среде.
  if [ ! -f "$REPO_ABS/harness.project.json" ]; then
    _jesc() { printf '%s' "$1" | sed 's/\\\\/\\\\\\\\/g; s/\\"/\\\\"/g'; }
    printf '{"contracts":"%s","verdicts":"%s","registry":"%s","fixtures":"%s","handoff":"%s","observations":"%s","architectObservations":"%s","roadmap":"%s","forks":"%s","sourceCanon":null}\n' \
      "$(_jesc "$REPO_ABS/contracts")" \
      "$(_jesc "$REPO_ABS/verdicts")" \
      "$(_jesc "$REPO_ABS/registry")" \
      "$(_jesc "$REPO_ABS/fixtures")" \
      "$(_jesc "$REPO_ABS/HANDOFF.md")" \
      "$(_jesc "$REPO_ABS/NABLIUDENIA.md")" \
      "$(_jesc "$REPO_ABS/NABLIUDENIA_ARCHITECT.md")" \
      "$(_jesc "$REPO_ABS/ROADMAP.md")" \
      "$(_jesc "$REPO_ABS/forks")"
    return 0
  fi

  command -v git >/dev/null 2>&1 || { printf 'project_paths_resolve: нет git\n' >&2; return 1; }
  command -v jq >/dev/null 2>&1  || { printf 'project_paths_resolve: нет jq\n' >&2;  return 1; }
  [ -x "$_lib_dir/profile_resolver.sh" ] || {
    printf 'project_paths_resolve: нет profile_resolver.sh (%s)\n' "$_lib_dir" >&2; return 1; }

  # env override (если выставлен вызывающей стороной — например, родительским
  # процессом через export) СОХРАНЯЕТСЯ. Иначе — равен REPO_ABS (как и в
  # scripts/project_workflow.sh:64-66).
  export HARNESS_PROJECT_LAYER_ROOT="${HARNESS_PROJECT_LAYER_ROOT:-$REPO_ABS}"

  _err="$(mktemp 2>/dev/null || echo /dev/null)"
  if ! MERGED="$(HARNESS_PROJECT_LAYER_ROOT="$REPO_ABS" bash "$_lib_dir/profile_resolver.sh" --repo "$REPO_ABS" 2>"$_err")"; then
    _pc_reason="$(cat "$_err" 2>/dev/null || true)"
    [ "$_err" != "/dev/null" ] && rm -f "$_err"
    printf '%s\n' "${_pc_reason#profile ОТКАЗ: }" >&2
    return 1
  fi
  [ "$_err" != "/dev/null" ] && rm -f "$_err"
  [ -n "$MERGED" ] || { printf 'project_paths_resolve: профиль пуст\n' >&2; return 1; }

  # Гард workflowPaths на относительность и реальность относительно REPO_ABS
  # (контракт 996 §Интерфейсы — симлинк вне, .. и абсолютный путь — отказ rc 1
  # ДО печати).
  for _wpk in contracts verdicts registry fixtures; do
    _wpv="$(printf '%s' "$MERGED" | jq -r --arg k "$_wpk" '.workflowPaths[$k].value // empty')"
    [ -n "$_wpv" ] || { printf 'project_paths_resolve: профиль без workflowPaths.%s\n' "$_wpk" >&2; return 1; }
    _wpcanon="$(readlink -f -- "$REPO_ABS/$_wpv" 2>/dev/null || true)"
    case "$_wpv" in /*) _wpcanon="/вне" ;; esac
    case "$_wpcanon" in
      "$REPO_ABS"/*) ;;
      *) printf 'project_paths_resolve: workflowPaths вне репо: %s=%s\n' "$_wpk" "$_wpv" >&2; return 1 ;;
    esac
  done

  STATE="$(printf '%s' "$MERGED" | jq -r '.workflowPaths.state.value // ".harness"')"
  [ -n "$STATE" ] || STATE=".harness"
  case "$STATE" in
    /*) printf 'project_paths_resolve: workflowPaths.state обязан быть относительным: %s\n' "$STATE" >&2; return 1 ;;
  esac
  case "$STATE" in
    *..*) printf 'project_paths_resolve: workflowPaths.state содержит ..: %s\n' "$STATE" >&2; return 1 ;;
  esac
  _STATE_ABS="$(cd "$REPO_ABS" && readlink -f -- "$STATE" 2>/dev/null || true)"
  case "$_STATE_ABS" in
    "$REPO_ABS") ;;
    "$REPO_ABS"/*) ;;
    *) printf 'project_paths_resolve: workflowPaths.state вне репо: %s\n' "$STATE" >&2; return 1 ;;
  esac

  _STATE_PREFIX="$REPO_ABS"
  [ "$STATE" != "." ] && _STATE_PREFIX="$REPO_ABS/${STATE%/}"

  CONTRACTS="$(printf '%s' "$MERGED" | jq -r '.workflowPaths.contracts.value')"
  VERDICTS="$(printf '%s' "$MERGED" | jq -r '.workflowPaths.verdicts.value')"
  REGISTRY="$(printf '%s' "$MERGED" | jq -r '.workflowPaths.registry.value')"
  FIXTURES="$(printf '%s' "$MERGED" | jq -r '.workflowPaths.fixtures.value')"
  SOURCE_CANON="$(printf '%s' "$MERGED" | jq -c '.sourceCanon.value // null')"

  jq -n \
    --arg contracts    "$REPO_ABS/$CONTRACTS" \
    --arg verdicts     "$REPO_ABS/$VERDICTS" \
    --arg registry     "$REPO_ABS/$REGISTRY" \
    --arg fixtures     "$REPO_ABS/$FIXTURES" \
    --arg handoff      "$_STATE_PREFIX/HANDOFF.md" \
    --arg observations "$_STATE_PREFIX/NABLIUDENIA.md" \
    --arg arch_obs     "$_STATE_PREFIX/NABLIUDENIA_ARCHITECT.md" \
    --arg roadmap      "$_STATE_PREFIX/ROADMAP.md" \
    --arg forks        "$_STATE_PREFIX/forks" \
    --argjson source_canon "$SOURCE_CANON" \
    '{contracts:$contracts,verdicts:$verdicts,registry:$registry,fixtures:$fixtures,
       handoff:$handoff,observations:$observations,architectObservations:$arch_obs,
       roadmap:$roadmap,forks:$forks,sourceCanon:$source_canon}'
}

zones_load() {
  local root="$1" self_dir out paths canon scratch_tmpl marker contracts nnn vmax vmax_tag body file
  self_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck disable=SC1091
  . "$self_dir/lib_registry.sh"

  root="$(lib_zones_canon "$root")" || {
    printf 'NOT_IMPLEMENTED: канонизация корня отказала\n' >&2; return 2; }
  command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; return 2; }
  git -C "$root" rev-parse --git-dir >/dev/null 2>&1 \
    || { printf 'NOT_IMPLEMENTED: %s не репозиторий\n' "$root" >&2; return 2; }

  # 996 (Б-5/Б-9): путь контрактов внутри замороженного тега — из
  # ЭФФЕКТИВНОГО профиля через функцию project_paths_resolve (определена ниже
  # в этой же библиотеке; дословный дубль есть в scripts/next_id.sh, откуда
  # импортируется freeze/done/check_zones/check_staged). Дубликат резолв-блока
  # лишний (контракт 996 §Интерфейсы «helper вызывает resolver один раз»).
  # Раньше здесь стоял `bash "$self_dir/project_workflow.sh"` — отдельный процесс,
  # который в toy-мире check_hooks.sh (toy_scratch несёт lib_zones.sh, но не
  # project_workflow.sh) падал rc 127 «No such file» и валил положительный контроль
  # antiplacebo. Функция доступна через source, отдельный процесс не нужен.
  local CONTRACTS_PATH="contracts/"
  if [ -f "$root/harness.project.json" ] && declare -F project_paths_resolve > /dev/null; then
    if _pp_out="$(project_paths_resolve "$root" 2>/dev/null)"; then
      _cpath="$(printf '%s' "$_pp_out" | jq -r '.contracts // empty' 2>/dev/null || true)"
      if [ -n "$_cpath" ]; then
        # Relative form (для `git ls-tree --name-only` через префикс-фильтр):
        case "$_cpath" in
          "$root"/*) _cpath="${_cpath#"$root"/}" ;;
          *)         _cpath="${_cpath#/}" ;;
        esac
        CONTRACTS_PATH="${_cpath%/}/"
      fi
    fi
    # Битый профиль / наружу-R → CONTRACTS_PATH остаётся дефолтным «contracts/»
    # как fallback для зон-либа (не делает записей, только читает frozen-теги).
    unset _pp_out _cpath
  fi

  local state
  state="$(registry_state "$root" 'frozen/')"
  case "$state" in
    full|unknown-remote) ;;
    *)
      printf 'NOT_IMPLEMENTED: реестр заморозок недоступен: %s\n' "$state" >&2
      return 2 ;;
  esac

  # Скратч и маркер живут ВНЕ корня (канон 014, см. __lib_zones_paths).
  # hash8 от канонического корня → лексические алиасы делят один скратч.
  paths="$(__lib_zones_paths "$root")" || {
    printf 'NOT_IMPLEMENTED: пути скратча не вычислить\n' >&2; return 2; }
  canon="$(printf '%s\n' "$paths" | sed -n '1p')"
  scratch_tmpl="$(printf '%s\n' "$paths" | sed -n '2p')"
  marker="$(printf '%s\n' "$paths" | sed -n '3p')"
  # Self-GC: подчищаем устаревшие маркер/оболочки от прошлых прогонов и крашей —
  # иначе /tmp копит мусор от однократного краша до перезагрузки.
  __lib_zones_self_gc "$marker" "$scratch_tmpl"
  out="$(mktemp -d "$scratch_tmpl")" || {
    printf 'NOT_IMPLEMENTED: mktemp не создал скратч по %s\n' "$scratch_tmpl" >&2; return 2; }
  # Регистрация скратча для очистки на EXIT родительской оболочки: маркер на диске
  # переживает `$(zones_load ...)` (подshell выхода НЕ запускает EXIT-ловушку —
  # проверено эмпирически, $BASHPID родителя и подshell'а различаются) и читается
  # __lib_zones_cleanup из ловушки потребителя (см. описание функции выше).
  printf '%s\n' "$out" > "$marker"
  : > "$out/zones_scoped"
  : > "$out/zones_violations"
  : > "$out/ranges"
  : > "$out/contracts_list"

  # Удобный испускатель нарушения: contract\0file\0reason\0author\0path\0raw_line\n
  # NUL защищает поля от внутренних табуляций в raw_line и author.
  emit_violation() {
    printf '%s\0%s\0%s\0%s\0%s\0%s\n' \
      "$1" "$2" "$3" "$4" "$5" "$6" >> "$out/zones_violations"
  }

  contracts=0
  while IFS= read -r nnn; do
    [ -n "$nnn" ] || continue
    contracts=$((contracts + 1))
    printf '%s\n' "$nnn" >> "$out/contracts_list"

    vmax=0
    while IFS= read -r t; do
      if [[ "$t" =~ ^refs/tags/frozen/contracts/${nnn}/([0-9]+)$ ]]; then
        local k=$((10#${BASH_REMATCH[1]}))
        [ "$k" -gt "$vmax" ] && vmax="$k"
      fi
    done < <(git -C "$root" for-each-ref --format='%(refname)' 'refs/tags/frozen/contracts/' 2>/dev/null | sort)
    [ "$vmax" -gt 0 ] || continue

    vmax_tag="refs/tags/frozen/contracts/$nnn/$vmax"
    file="$(git -C "$root" ls-tree -r --name-only "${vmax_tag}^{commit}" -- ":(literal)${CONTRACTS_PATH%/}" 2>/dev/null \
            | awk -v n="$nnn" -v cp="$CONTRACTS_PATH" 'index($0, cp n "-") == 1 { print; exit }')"
    [ -n "$file" ] || continue
    body="$(git -C "$root" cat-file -p "${vmax_tag}^{commit}:$file" 2>/dev/null || true)"

    while IFS= read -r line; do
      [ -n "$line" ] || continue
      local rest="${line#ЗОНА }"
      local author="${rest%%:*}"
      local paths="${rest#*:}"
      if [ "$author" = "$rest" ] || [ -z "${author//[[:space:]]/}" ]; then
        emit_violation "$nnn" "$file" "bad_author" "$author" "" "$line"
        continue
      fi
      # ТАБУЛЯЦИЯ В ИМЕНИ АВТОРА ЗАПРЕЩЕНА (адверсарий: TSV-сериализация рвёт имя надвое).
      if [[ "$author" == *$'\t'* ]]; then
        emit_violation "$nnn" "$file" "tab_in_author" "$author" "" "$line"
        continue
      fi
      if [ -z "${paths//[[:space:]]/}" ]; then
        emit_violation "$nnn" "$file" "no_paths" "$author" "" "$line"
        continue
      fi
      # РАСЩЕПЛЕНИЕ БЕЗ ПОДСТАНОВКИ ИМЁН ФАЙЛОВ (Н-39: `for p in $paths` без set -f раскрывает
      # `scripts/*` в реальные файлы каталога, и зона становится тотальной).
      set -f
      # shellcheck disable=SC2086
      for p in $paths; do
        case "$p" in
          *'"'*)
            emit_violation "$nnn" "$file" "quote_in_path" "$author" "$p" "$line"
            continue ;;
        esac
        case "$p" in
          *\*) emit_violation "$nnn" "$file" "bad_prefix" "$author" "$p" "$line"; continue ;;
          *)  ;;
        esac
        printf '%s\t%s\t%s\n' "$author" "$p" "$nnn" >> "$out/zones_scoped"
      done
      set +f
    done < <(printf '%s\n' "$body" | grep '^ЗОНА ' || true)

    # Конец диапазона — тег done/contracts/<NNN>/1 (Н-14).
    local done_ref="done/contracts/$nnn/1"
    if git -C "$root" rev-parse --verify --quiet "refs/tags/$done_ref" >/dev/null; then
      if git -C "$root" merge-base --is-ancestor "refs/tags/$done_ref" HEAD; then
        printf '%s\t%s..%s\n' "$nnn" "frozen/contracts/$nnn/1" "$done_ref" >> "$out/ranges"
      else
        printf '%s\tfrozen/contracts/%s/1\n' "$nnn" "$nnn" >> "$out/ranges"
      fi
    else
      printf '%s\tfrozen/contracts/%s/1\n' "$nnn" "$nnn" >> "$out/ranges"
    fi
  done < <(git -C "$root" for-each-ref --format='%(refname)' 'refs/tags/frozen/contracts/' 2>/dev/null \
           | awk -F/ '/^refs\/tags\/frozen\/contracts\// { print $5 }' | sort -u)

  printf '%s\n' "$out"
  return 0
}

# Проверка пути staged-файла против зон автора.
# Принимает каталог результата zones_load и имя автора; возвращает 0 если путь в зоне, иначе 1.
zones_match_path() {
  local out="$1" author="$2" path="$3" a pp inside
  inside=1
  while IFS=$'\t' read -r a pp _; do
    [ "$a" = "$author" ] || continue
    case "$pp" in
      */) case "$path" in "$pp"*) inside=0; printf '%s\n' "$pp"; break ;; esac ;;
      *)  [ "$path" = "$pp" ] && { inside=0; printf '%s\n' "$pp"; break; } ;;
    esac
  done < <(awk -F'\t' -v a="$author" '$1 == a { print $1 "\t" $2 }' "$out/zones_scoped" | sort -u)
  [ "$inside" -eq 0 ]
}

# Список ВСЕХ ЗОН указанного автора в каталоге результата zones_load.
zones_for_author() {
  local out="$1" author="$2"
  awk -F'\t' -v a="$author" '$1 == a { print $2 }' "$out/zones_scoped" | sort -u
}
