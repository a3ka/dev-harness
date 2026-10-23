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

# ЛЕНИВО подключаем next_id.sh как источник project_paths_resolve (контракт 996
# круг 4 — см. комментарий выше и в scripts/next_id.sh). В production-дереве
# next_id.sh всегда рядом (подключается раньше или позже — неважно: функция
# одна и та же). В toy-мире check_hooks/sh next_id.sh отсутствует; source
# неудачен, set -e НЕ установлен — текущий файл продолжает загрузку, и
# zones_load ниже делает declare -F project_paths_resolve, видит «нет
# функции», не открывает ветку вызова. `_self_dir` нужен только потому, что
# BASH_SOURCE[0] в этом блоке — сам lib_zones.sh и мог быть sourced через
# симлинк; собственный каталог надёжнее.
_self_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || true
if [ -n "${_self_dir:-}" ] && [ -x "$_self_dir/next_id.sh" ]; then
  NEXT_ID_LIB=1
  # shellcheck disable=SC1091
  . "$_self_dir/next_id.sh" || true
fi
unset _self_dir

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

# zones_declare_rows <контракт> <файл> <каталог-результата> — ЕДИНСТВЕННЫЙ парсер
# ЗОНА-строк (грамматика — заголовок файла). Читает строки тела контракта из stdin
# (уже отфильтрованные `^ЗОНА `) и ДОБАВЛЯЕТ валидные строки в
# <каталог>/zones_scoped (автор<TAB>путь<TAB>контракт), нарушения — в
# <каталог>/zones_violations (6 полей через NUL: контракт, файл, причина, автор,
# путь, сырая_строка — формат заголовка zones_load).
#
# Вынесено из zones_load кодовой правкой «цикл v+1» (слово владельца 2026-10-22
# ~21:20 UTC): переопределение «предстоящее v+1» в check_zones перечитывает
# ЗОНА-строки из РАБОЧЕГО файла ветки ТЕМ ЖЕ парсером — второй читатель формата
# расходился бы молча (та же причина, по которой библиотека заведена, контракт 016).
zones_declare_rows() {  # <nnn> <file> <outdir>; ЗОНА-строки — stdin
  local nnn="$1" file="$2" out="$3"
  local line rest author paths p
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    rest="${line#ЗОНА }"
    author="${rest%%:*}"
    paths="${rest#*:}"
    if [ "$author" = "$rest" ] || [ -z "${author//[[:space:]]/}" ]; then
      printf '%s\0%s\0%s\0%s\0%s\0%s\n' \
        "$nnn" "$file" "bad_author" "$author" "" "$line" >> "$out/zones_violations"
      continue
    fi
    # ТАБУЛЯЦИЯ В ИМЕНИ АВТОРА ЗАПРЕЩЕНА (адверсарий: TSV-сериализация рвёт имя надвое).
    if [[ "$author" == *$'\t'* ]]; then
      printf '%s\0%s\0%s\0%s\0%s\0%s\n' \
        "$nnn" "$file" "tab_in_author" "$author" "" "$line" >> "$out/zones_violations"
      continue
    fi
    if [ -z "${paths//[[:space:]]/}" ]; then
      printf '%s\0%s\0%s\0%s\0%s\0%s\n' \
        "$nnn" "$file" "no_paths" "$author" "" "$line" >> "$out/zones_violations"
      continue
    fi
    # РАСЩЕПЛЕНИЕ БЕЗ ПОДСТАНОВКИ ИМЁН ФАЙЛОВ (Н-39: `for p in $paths` без set -f раскрывает
    # `scripts/*` в реальные файлы каталога, и зона становится тотальной).
    set -f
    # shellcheck disable=SC2086
    for p in $paths; do
      case "$p" in
        *'"'*)
          printf '%s\0%s\0%s\0%s\0%s\0%s\n' \
            "$nnn" "$file" "quote_in_path" "$author" "$p" "$line" >> "$out/zones_violations"
          continue ;;
      esac
      case "$p" in
        *\*) printf '%s\0%s\0%s\0%s\0%s\0%s\n' \
               "$nnn" "$file" "bad_prefix" "$author" "$p" "$line" >> "$out/zones_violations"; continue ;;
        *)  ;;
      esac
      printf '%s\t%s\t%s\n' "$author" "$p" "$nnn" >> "$out/zones_scoped"
    done
    set +f
  done
}

# zones_load <корень-репо>
# stdout: каталог с файлами zones_scoped, zones_violations, ranges, contracts_list.
# rc 0 при успехе (включая «нет контрактов»); 1 при отказе реестра; 2 при NOT_IMPLEMENTED.
#
# Пути — ИЗ БЛОБА ВЫСШЕЙ ЗАМОРОЗКИ, не из рабочего дерева (иначе правка контракта расширяла бы
# зону без заморозки). Диапазон применения — от ПЕРВОЙ заморозки контракта до done-тега, если
# он есть, иначе до HEAD (Н-14).
# project_paths_resolve <REPO> — ЕДИНЫЙ резолвер путей профиля (контракт 996
# пакет Б-5/Б-9, исправление toy-миров). ДОМ определения перенесён в
# scripts/next_id.sh (круг 4 реализации 996, BR-см. frozen/contracts/996/1):
# структурная клетка `structure-one-paths-resolve` следит, чтобы в scripts/*.sh
# было РОВНО одно объявление `project_paths_resolve()`, и тело держится в
# next_id.sh. lib_zones.sh подключает next_id.sh ЛЕНИВО (см. ниже), чтобы
# параллельный вход (читатель зон — check_zones, check_staged, land_agent,
# check_no_leak, zones_load этого файла) получил функцию для подключаемого
# скрипта в обоих порядках: сначала lib_zones.sh (check_staged) и сначала
# next_id.sh (check_zones).
#
# Toy-мир check_hooks/sh копирует lib_zones.sh БЕЗ next_id.sh — функция
# остаётся неопределённой, и zones_load ниже делает `declare -F project_paths_resolve
# > /dev/null` ПЕРЕД вызовом: false → вызов не открывается, CONTRACTS_PATH
# остаётся дефолтным «contracts/». Именно это поведение прежней редакции
# закрывало check_hooks (свой сценарий без профиля), и его сохранение —
# единственная причина, по которой функция не подтягивается жадно.

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

    zones_declare_rows "$nnn" "$file" "$out" \
      < <(printf '%s\n' "$body" | grep '^ЗОНА ' || true)

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
