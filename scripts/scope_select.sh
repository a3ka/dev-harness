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

# `header_lines <файл|->` — печатает строки первого непрерывного головного блока комментариев.
# Сверка шапки BASE↔HEAD ловит смену объявленных кодов/роли ВНУТРИ шапки (§2 «шапка не менялась»).
header_lines() {
  awk '
    /^[[:space:]]*(#|\/\/|\/\*|\*)/ || NR == 1 { print; next }
    /^[[:space:]]*$/ { next }
    { exit }
  ' "${1--}"
}

# `source_arg_lines <файл|->` — печатает АРГУМЕНТ каждой `source`/`.` инструкции, по строке.
# Склеивает `\`-переносы (находка круга 2). Ищет source/`.` в НАЧАЛЕ логической строки: реальные
# барьеры и тестовые формы сорсят с начала. `;`/`&&`-разбор НЕ делаем — иначе `&&` ВНУТРИ
# `$(cd … && pwd)` (идиома реального next_id.sh) рвал бы аргумент.
source_arg_lines() {
  awk '
    { cur = cur $0 }
    /\\[[:space:]]*$/ { sub(/\\[[:space:]]*$/, " ", cur); next }
    {
      s = cur; cur = ""
      sub(/^[[:space:]]+/, "", s)
      if (s ~ /^(source|\.)[[:space:]]+[^[:space:]#]/) {
        sub(/^(source|\.)[[:space:]]+/, "", s)
        sub(/[[:space:]]*#.*$/, "", s)
        sub(/[[:space:]]+$/, "", s)
        if (length(s)) print s
      }
    }
  ' "${1--}"
}

# `is_static_source <арг>` — 0, если ИМЯ файла (basename) source — ЛИТЕРАЛ `.sh`. Порог (решение
# архитектора, круг 2; source в bash статически неразрешим): КАТАЛОГ может вычисляться ЛЮБОЙ идиомой
# (`$(dirname "$0")`, `$(cd … && pwd)`, `$SELF_DIR`, …) — важен литеральный basename. Голый `$var`,
# подстановка в ИМЕНИ файла, traversal `..`, пустой → динамика (код 1) → вызывающий делает full.
is_static_source() {
  local a="$1" bn
  a="${a%\"}"; a="${a#\"}"; a="${a%\'}"; a="${a#\'}"
  bn="${a##*/}"; bn="${bn%\"}"; bn="${bn%\'}"
  case "$bn" in
    ''|*..*)           return 1 ;;
    *[!A-Za-z0-9_.-]*) return 1 ;;
    *.sh)              return 0 ;;
    *)                 return 1 ;;
  esac
}

# ── Режимы ───────────────────────────────────────────────────────────────────
case "$flag" in
  --scope)
    shift
    [ "$#" -gt 0 ] || { echo "пустой --scope — ключи не заданы" >&2; exit 1; }
    for k in "$@"; do
      case "$k" in
        */*) bar="${k%%/*}"; cas="${k#*/}"
             is_barrier "$bar" || { echo "неизвестный ключ $bar" >&2; exit 1; }
             # case — ТОЛЬКО непосредственное имя `case_*` (находка круга 2: `b/../../scripts/b`
             # уходил traversal'ом из fixtures/ и давал успех с 0 фикстур).
             case "$cas" in
               case_*) ;;
               *) echo "неизвестный case $k — ожидается case_*" >&2; exit 1 ;;
             esac
             case "$cas" in
               */*|*..*) echo "неизвестный case $k — недопустимый путь в case" >&2; exit 1 ;;
             esac
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
    # ── §2: сужение ТОЛЬКО при неизменной шапке И доказуемо-статичном графе source ──
    # Находки адверсария кругов 1–2. Консервативно: любое непроверяемое → full. Порог идиом
    # source — в is_static_source (source в bash статически неразрешим — решение архитектора).
    if [ "$full" = 0 ] && [ -n "$keys" ]; then
      # (1) §2 «роль/коды/шапка не менялись»: сверяем ПОЛНУЮ шапку BASE↔HEAD изменённого барьера.
      for k in $keys; do
        if git -C "$root" cat-file -e "${base}:scripts/${k}.sh" 2>/dev/null; then
          if [ "$(git -C "$root" show "${base}:scripts/${k}.sh" 2>/dev/null | header_lines -)" \
             != "$(header_lines "$root/scripts/${k}.sh")" ]; then full=1; break; fi
        fi
      done
    fi
    if [ "$full" = 0 ] && [ -n "$keys" ]; then
      # (2) граф source: скан ВСЕХ eligible-барьеров HEAD. Не-статичный source где угодно → full
      #     (граф неизвестен); статичный source на ИЗМЕНЁННЫЙ барьер → тоже full.
      while IFS= read -r f; do
        [ -z "$f" ] && continue
        [ "$(header_role "$f")" = b ] || continue
        selfk="${f##*/}"; selfk="${selfk%.sh}"
        while IFS= read -r a; do
          [ -z "$a" ] && continue
          is_static_source "$a" || { full=1; break 2; }
          bn="${a%\"}"; bn="${bn#\"}"; bn="${bn%\'}"; bn="${bn#\'}"; bn="${bn##*/}"; bn="${bn%.sh}"
          for k in $keys; do
            [ "$bn" = "$k" ] && [ "$selfk" != "$k" ] && { full=1; break 3; }
          done
        done < <(source_arg_lines "$f")
      done < <(find "$root/scripts" -type f -name '*.sh' 2>/dev/null | sort)
    fi
    if [ "$full" = 0 ] && [ -n "$keys" ]; then
      # (3) BASE-версия изменённого барьера с не-статичным source — тоже full (прошлый конец диффа).
      for k in $keys; do
        if git -C "$root" cat-file -e "${base}:scripts/${k}.sh" 2>/dev/null; then
          while IFS= read -r a; do
            [ -z "$a" ] && continue
            is_static_source "$a" || { full=1; break; }
          done < <(git -C "$root" show "${base}:scripts/${k}.sh" 2>/dev/null | source_arg_lines -)
        fi
        [ "$full" = 1 ] && break
      done
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
