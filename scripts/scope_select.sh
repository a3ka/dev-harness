#!/usr/bin/env bash
# НЕ БАРЬЕР: юнит-селектор, тестируется через check_scope_select.sh
#
# Селектор scoped-режима для контракта 006 (быстрый изолированный гейт, поток A).
# Состояние дерева + флаги → множество ключей + режим + код возврата.
#
# ОБЯЗАТЕЛЬСТВО (контракт §Предмет, шапка check_scope_select.sh):
#   SCOPED: маркер печатается И на scoped, И на needs-full — иначе потребитель не отличит
#   scoped-выборку от полного прогона по машинному маркеру, а только по MODE:.
#   На «нет git» и «база не резолвится» тоже MODE: needs-full + SCOPED: (fail-closed код 2).
#
# Контракт вывода (закреплён шапкой check_scope_select.sh):
#   stdout: `MODE: full|scoped|needs-full`, затем строки `KEY: <ключ>` (для scoped, 0+);
#   stderr: `SCOPED: … — не для приёмки` на scoped И needs-full;
#   код 0 — выборка готова (full|scoped), 1 — ошибка использования (неизвестный ключ/case,
#        пустой --scope), 2 — нужен полный прогон (needs-full: 0 задетых, нет git, база не
#        резолвится).
#
# Консервативный откат (контракт §2, fail-closed):
#   add/delete/rename/copy, смена роли барьера, правка библиотеки, любой файл scripts/ без
#   валидной шапки → MODE: full. Сужение до ключа только если файл — барьер (`Коды возврата:`)
#   в ОБОИХ концах диффа и роль не менялась.
#
# Использование:
#   scope_select.sh <корень> --scope <ключ>[/<case>]…   явные ключи
#   scope_select.sh <корень> --changed <база>            задетое из git diff
set -uo pipefail
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

root="${1:?корень}"; shift
flag="${1:-}"

# ── Классификация ────────────────────────────────────────────────────────────
# Шапка: первый непрерывный блок комментариев. Роль файла scripts/<name>.sh объявляет он сам —
# `Коды возврата:` (барьер) либо `НЕ БАРЬЕР:` (библиотека/support). Файл без маркера —
# неклассифицированный: verify_antiplacebo отказывает ему на сканировании области, а здесь он
# уходит в MODE: full через консервативный откат.
#
# `header_role <путь>` пишет «b» (barrier), «p» (passive/НЕ БАРЬЕР), «bp» (оба — двусмысленно)
# или «» (нет маркера). Принимает и файл, и «-» для stdin (чтобы классифицировать вывод
# `git show BASE:path`, не записывая его на диск).
header_role() {
  awk '
    /^[[:space:]]*(#|\/\/|\/\*|\*)/ || NR == 1 {
      if (/[[:space:]#*\/]*Коды возврата:/) b = 1
      if (/[[:space:]#*\/]*НЕ БАРЬЕР:/)     p = 1
      next
    }
    /^[[:space:]]*$/ { next }
    { exit }
    END { printf "%s%s\n", (b ? "b" : ""), (p ? "p" : "") }
  ' "${1:--}"
}

is_barrier() { [ "$(header_role "$root/scripts/$1.sh")" = b ]; }
is_library() { case "$(header_role "$root/scripts/$1.sh")" in *p*) true ;; *) false ;; esac; }

emit_marker() { printf 'SCOPED: %s\n' "$*" >&2; }

# `source_args <файл>` — печатает АРГУМЕНТ каждой `source`/`.` инструкции в файле (по одной
# строке). Используется находками 1 и 2 для статического разбора графа source (§2 «нет
# динамического source»/«не сорсит другой eligible-барьер»). Многострочные продолжения
# НЕ поддержаны: тестовые источники — однострочные `source PATH`/`. PATH`.
source_args() {
  awk '
    /^[[:space:]]*(source|\.)[[:space:]]+[^#]/ {
      arg = $0
      sub(/^[[:space:]]*/, "", arg)
      sub(/^(source|\.)[[:space:]]+/, "", arg)
      sub(/[[:space:]]*#.*$/, "", arg)
      print arg
    }
  ' "${1--}"
}

# `has_dynamic_source <файл>` — 0 если хоть одна source/`.` инструкция имеет аргумент, который
# после стриппинга кавычек НЕ оканчивается на `.sh` (резолвится в неизвестный файл — тот же
# контракт §2 «нет динамического source»). Файл без source/`.` — НЕ dynamic.
has_dynamic_source() {
  local arg base
  while IFS= read -r arg; do
    [ -z "$arg" ] && continue
    arg="${arg%\"}"; arg="${arg#\"}"
    arg="${arg%\'}"; arg="${arg#\'}"
    base="${arg##*/}"
    # Пустой basename или basename без суффикса .sh — динамический source.
    [ -n "$base" ] && [ "${base%.sh}" != "$base" ] || return 0
  done < <(source_args "$1")
  return 1
}

# `has_static_source_to <target.sh> <файл>` — 0 если хоть одна source/`.` инструкция имеет
# аргумент, basename которого ровно `<target.sh>` (после стриппинга кавычек). Используется
# находкой 1: «другой eligible-барьер сорсит scripts/X.sh».
has_static_source_to() {
  local target="$1" file="$2" arg base
  while IFS= read -r arg; do
    [ -z "$arg" ] && continue
    arg="${arg%\"}"; arg="${arg#\"}"
    arg="${arg%\'}"; arg="${arg#\'}"
    base="${arg##*/}"
    [ "$base" = "$target" ] && return 0
  done < <(source_args "$file")
  return 1
}

# ── Режимы ───────────────────────────────────────────────────────────────────
case "$flag" in
  --scope)
    shift
    [ "$#" -gt 0 ] || { echo "пустой --scope — ключи не заданы" >&2; exit 1; }
    for k in "$@"; do
      case "$k" in
        */*) bar="${k%%/*}"; cas="${k#*/}"
             # Существование файла НЕ достаточно: ключом --scope может быть ТОЛЬКО барьер
             # (находка 3: «НЕ БАРЬЕР»/support/неклассифицированный принимался как ключ).
             is_barrier "$bar" || { echo "неизвестный ключ $bar" >&2; exit 1; }
             [ -f "$root/fixtures/$bar/$cas.sh" ] || { echo "неизвестный case $k" >&2; exit 1; } ;;
        *)   is_barrier "$k" || { echo "неизвестный ключ $k" >&2; exit 1; } ;;
      esac
    done
    emit_marker "не для приёмки"
    printf 'MODE: scoped\n'
    for k in "$@"; do printf 'KEY: %s\n' "$k"; done
    exit 0 ;;

  --changed)
    base="${2:-}"
    # Нет git — fail-closed (контракт §3): НЕ «0 задетых успех», а явный отказ.
    command -v git >/dev/null 2>&1 || { emit_marker "нет git — fail-closed"; printf 'MODE: needs-full\n'; exit 2; }
    # База не резолвится — fail-closed тем же кодом 2 и тем же маркером (ветвь д барьера).
    git -C "$root" rev-parse --verify --quiet "${base}^{commit}" >/dev/null 2>&1 \
      || { emit_marker "база не резолвится: $base — fail-closed"; printf 'MODE: needs-full\n'; exit 2; }

    # `git diff --name-status -z BASE HEAD` — NUL-разделители, ОБА конца диффа (для R*/C* идут
    # пары путей: старое\0новое\0). Захват ЧЕРЕЗ process substitution (`< <(...)`), НЕ через
    # `$(...)`: command substitution обнуляет NUL, и вся выборка становится пустой → ложный
    # needs-full на ЛЮБОМ диффе. Это измерено на ветви е барьера при первой попытке.
    #
    # Формат `-z` ОТЛИЧАЕТСЯ от tab-варианта эталонa: статус и путь разделяются NUL, а НЕ табом,
    # и для R*/C* идут ДВА пути подряд. После `tr '\0' '\n'` одна «запись» становится 1–2 строками
    # (статус+путь для M/A/D; статус+old+new для R*/C*). Простой `read` с разбиением по табу (как
    # у эталонa без `-z`) на этой форме даёт st=M, p="" — измерено на ветви г.
    # Поэтому stateful-парсер с курсором `mode`: `status` ждёт статус, `need_path` — путь,
    # `need_path2` — второй путь для R*/C* (он всё равно даёт full=1).
    full=0; keys="" mode=status
    while IFS= read -r line; do
      case "$mode" in
        status)
          case "$line" in
            A|D|M)  st="$line"; mode=need_path ;;
            R*|C*)  st="$line"; mode=need_path2 ;;
            *)      continue ;;  # «голая» строка-путь после R*/C* — пропускаем
          esac
          case "$st" in A|D|R*|C*) full=1 ;; esac
          ;;
        need_path)
          p="$line"; mode=status
          case "$p" in
            scripts/*.sh)
              f="${p#scripts/}"; f="${f%.sh}"
              # Роль В ОБОИХ концах диффа. base_role — `git show BASE:path | header_role -`;
              # head_role — текущий файл в HEAD (= рабочее дерево после чекаута). Любая
              # библиотека, двусмысленная шапка или отсутствие маркера → full.
              base_role="$(git -C "$root" show "${base}:${p}" 2>/dev/null | header_role -)"
              head_role="$(header_role "$root/$p")"
              case "$base_role$head_role" in
                bb) keys="$keys $f" ;;            # барьер в обоих концах, роль не менялась
                *)   full=1 ;;                    # библиотека / bp / пустая / двусмысленная
              esac
              ;;
            fixtures/*/*)
              k="${p#fixtures/}"; k="${k%%/*}"; keys="$keys $k" ;;
          esac
          ;;
        need_path2)
          # Статус R*/C* уже дал full=1 (add/delete/rename/copy → полная выборка).
          mode=need_path ;;  # второй путь будет прочитан на следующей итерации, но он
                             # игнорируется: всё равно full.
      esac
    done < <(git -C "$root" diff --name-status -z "$base" HEAD | tr '\0' '\n')
    # Находки 1 и 2 (адверсарий): граф source между барьерами и динамический source.
    # Контракт §2 разрешает сужение до ключа ТОЛЬКО при выполнении ОБОИХ условий:
    #   (1) ИЗМЕНЁННЫЙ барьер (любой конец диффа) не имеет динамического source — иначе
    #       цель резолвится в рантайме и поведение чужих барьеров меняется непредсказуемо;
    #   (2) ни один ДРУГОЙ eligible-барьер статически не сорсит изменённый — иначе правка X
    #       меняет поведение других и выборка обязана быть полной.
    if [ "$full" = 0 ] && [ -n "$keys" ]; then
      # Находка 2: изменённый барьер с динамическим source — любой из концов диффа.
      for k in $keys; do
        if has_dynamic_source "$root/scripts/$k.sh"; then full=1; break; fi
        if git -C "$root" cat-file -e "${base}:scripts/${k}.sh" 2>/dev/null; then
          if git -C "$root" show "${base}:scripts/${k}.sh" 2>/dev/null | has_dynamic_source -; then
            full=1; break
          fi
        fi
      done
      # Находка 1: полнодеревный скан eligible-барьеров в HEAD на статический source <key>.sh
      # (роль фильтруется по header_role — библиотеки/support не считаются «другими барьерами»).
      if [ "$full" = 0 ]; then
        for k in $keys; do
          target="${k}.sh"
          while IFS= read -r f; do
            [ -z "$f" ] && continue
            rel="${f#"$root/scripts/"}"
            [ "$rel" = "$target" ] && continue
            [ "$(header_role "$f")" = b ] || continue
            if has_static_source_to "$target" "$f"; then full=1; break 2; fi
          done < <(find "$root/scripts" -type f -name '*.sh' 2>/dev/null | sort)
        done
      fi
    fi

    if [ "$full" = 1 ]; then
      emit_marker "не для приёмки"
      printf 'MODE: full\n'; exit 0
    fi
    keys="$(printf '%s\n' $keys | sort -u | grep -v '^$' || true)"
    if [ -z "$keys" ]; then
      emit_marker "0 задетых — scoped ничего не доказал, полный гейт в CI"
      printf 'MODE: needs-full\n'; exit 2
    fi
    emit_marker "не для приёмки"
    printf 'MODE: scoped\n'
    printf 'KEY: %s\n' $keys
    exit 0 ;;

  *) echo "неизвестный режим: $flag" >&2; exit 1 ;;
esac
