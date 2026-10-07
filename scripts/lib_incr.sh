#!/usr/bin/env bash
# НЕ БАРЬЕР: библиотека, вызывающий скрипт выносит вердикт.
# scripts/lib_incr.sh — общая грамматика `--incr <кеш>` для инкрементальных проверок истории.
# Контракт 083, инвариант 6: все четыре чека (check_charter, check_zones, check_ids,
# check_protected) принимают `--incr <кеш-файл>` через вызов библиотеки. Грамматика
# живёт ЗДЕСЬ, в одном источнике; переизобретение в чеке = провал. Кеш-файл — ровно
# одна строка `[0-9a-f]{40}` + перевод строки; полный режим (без `--incr`) — побайтово
# прежний, вызывающие в CI/freeze_contract/судьях не меняются.
#
# Использование (после установки INCR_NAME=<имя-чека> и source):
#
#   incr_parse "$@"        # отделяет --incr <кеш> из аргументов
#   [ "$INCR_RC" -eq 0 ] || { incr_fail; exit 1; }  # если кеш невалиден
#   set -- "${INCR_REST[@]}"  # оставшиеся позиционные аргументы
#   # ... основная логика (полная или окно cache..HEAD) ...
#   incr_finish $?  # при rc=0 атомарно записывает HEAD в кеш
#
# Переменные после incr_parse:
#   INCR_CACHE   — путь к кеш-файлу (если был --incr), иначе пусто
#   INCR_MODE    — "incr" (окно cache..HEAD) | "full" (полный режим; кеш отсутствует
#                  ИЛИ --incr не передан)
#   INCR_BASE    — sha из кеша (если валиден)
#   INCR_HEAD    — sha HEAD (если валиден)
#   INCR_N       — число коммитов в окне (если валиден)
#   INCR_REST    — массив оставшихся позиционных аргументов
#   INCR_RC      — 0 если ОК; 1 если кеш невалиден (вызывающий ОБЯЗАН сразу exit 1)
#
# Побочные эффекты:
#   — при валидном кеше печатает на stderr маркер `incr: <имя> судит <base>..<head> (N коммит…)`
#   — при отсутствующем кеше печатает на stderr маркер `incr: <имя> полный прогон (кеш отсутствует)`
#   — при кеше валидном, но sha НЕ предок HEAD (ветвь (в′)): печатает на stderr маркер
#     `incr: <имя> полный прогон (база <base> не предок HEAD <head> — кеш сторонней линии)`,
#     INCR_MODE остаётся "full", INCR_CACHE сохраняется — incr_finish на rc=0 атомарно
#     записывает HEAD (сеяние своей линии). Любой ненулевой исход merge-base трактуется
#     одинаково (rc 1 — коммит есть, не предок; rc 128 — объекта нет).
#   — incr_finish при rc=0 атомарно записывает HEAD в INCR_CACHE (tmp + mv).

# Защита от повторного source'а
[ -n "${LIB_INCR_LOADED:-}" ] && return 0 2>/dev/null || :
LIB_INCR_LOADED=1

# Защита от вызова без INCR_NAME
[ -n "${INCR_NAME:-}" ] || {
  printf 'lib_incr.sh: INCR_NAME не задан (вызывающий обязан задать до source: INCR_NAME=check_xxx . lib_incr.sh)\n' >&2
  return 1 2>/dev/null || exit 1
}

# Корень git-репозитория для rev-parse/merge-base/rev-list. По умолчанию cwd.
INCR_GIT_ROOT="${INCR_GIT_ROOT:-.}"

# Плюрализация «N коммит…»: 0 → «0 коммитов», 1/21/31 → «N коммит»,
# 2-4/22-24 → «N коммита», иначе → «N коммитов». Тест-батарея матчит
# «incr: ... судит ... (N коммит» — общая префиксная часть.
_incr_plural() {
  local n="$1" n10 n100
  n10=$((n % 10)); n100=$((n % 100))
  if [ "$n" -eq 0 ]; then
    printf '0 коммитов'
  elif [ "$n10" -eq 1 ] && [ "$n100" -ne 11 ]; then
    printf '%d коммит' "$n"
  elif [ "$n10" -ge 2 ] && [ "$n10" -le 4 ] && { [ "$n100" -lt 12 ] || [ "$n100" -gt 14 ]; }; then
    printf '%d коммита' "$n"
  else
    printf '%d коммитов' "$n"
  fi
}

# incr_parse "$@" — отделяет --incr <кеш> из аргументов; заполняет INCR_*.
# Допустимые формы: --incr <кеш>, --incr=<кеш>. Иное — позиционный аргумент.
# ВАЖНО: после вызова ВЫЗЫВАЮЩИЙ ОБЯЗАН выполнить `set -- "${INCR_REST[@]}"` для
# передачи остатка в свой разбор позиционных аргументов. INCR_REST — массив.
incr_parse() {
  INCR_CACHE=""
  INCR_MODE="full"
  INCR_BASE=""
  INCR_HEAD=""
  INCR_N=0
  INCR_RC=0
  INCR_REST=()

  local skip_next=0
  while [ "$#" -gt 0 ]; do
    if [ "$skip_next" -eq 1 ]; then
      INCR_CACHE="$1"
      skip_next=0
      shift
      continue
    fi
    local arg="$1"
    case "$arg" in
      --incr)
        skip_next=1
        shift
        continue
        ;;
      --incr=*)
        INCR_CACHE="${arg#--incr=}"
        shift
        continue
        ;;
      *)
        INCR_REST+=("$arg")
        shift
        continue
        ;;
    esac
  done

  # Без --incr — полный режим, без маркера.
  if [ -z "$INCR_CACHE" ]; then
    return 0
  fi

  # С --incr — валидируем кеш. Три ветви инв. 6.
  if [ ! -f "$INCR_CACHE" ]; then
    # (б) кеш отсутствует → полный прогон С маркером «полный прогон (кеш отсутствует)»
    INCR_MODE="full"
    printf 'incr: %s полный прогон (кеш отсутствует)\n' "$INCR_NAME" >&2
    return 0
  fi

  local base head
  base="$(head -n1 "$INCR_CACHE" 2>/dev/null | tr -d '[:space:]')"
  if ! printf '%s' "$base" | grep -Eq '^[0-9a-f]{40}$'; then
    # (в) мусорная первая строка → именованный отказ rc 1
    printf 'incr: %s ОТКАЗ: кеш повреждён: %s — первая строка не sha\n' "$INCR_NAME" "$INCR_CACHE" >&2
    INCR_RC=1
    return 0
  fi

  head="$(git -C "$INCR_GIT_ROOT" rev-parse HEAD 2>/dev/null)" || {
    printf 'incr: %s ОТКАЗ: не удалось прочитать HEAD в %s\n' "$INCR_NAME" "$INCR_GIT_ROOT" >&2
    INCR_RC=1
    return 0
  }

# (в′) sha-не-предок — ЛЮБОЙ ненулевой исход merge-base трактуется одинаково:
  # rc 1 (коммит в репозитории ЕСТЬ — push-запись main у отстающей ветки) и
  # rc 128 (объекта НЕТ — sha постороннего репозитория либо неполная история).
  # Обе формы — один исход: громкий полный прогон с сеянием своей линии, не отказ.
  # INCR_MODE="full" (окно не сужается: такая база базой не становится);
  # INCR_CACHE сохраняется — incr_finish на rc=0 атомарно записывает HEAD.
  if ! git -C "$INCR_GIT_ROOT" merge-base --is-ancestor "$base" "$head" 2>/dev/null; then
    INCR_MODE="full"
    printf 'incr: %s полный прогон (база %s не предок HEAD %s — кеш сторонней линии)\n' \
      "$INCR_NAME" "${base:0:8}" "${head:0:8}" >&2
    return 0
  fi

  # (а) валидный кеш, sha — предок HEAD → incr-режим
  INCR_MODE="incr"
  INCR_BASE="$base"
  INCR_HEAD="$head"
  INCR_N="$(git -C "$INCR_GIT_ROOT" rev-list --count "${base}..${head}" 2>/dev/null || echo 0)"
  printf 'incr: %s судит %s..%s (%s)\n' \
    "$INCR_NAME" "${base:0:8}" "${head:0:8}" "$(_incr_plural "$INCR_N")" >&2
  return 0
}

# incr_fail — печатает итог отказа (для случая, когда вызывающий делает exit 1).
incr_fail() {
  printf 'incr: %s ИТОГ: отказ по кешу (см. причину выше)\n' "$INCR_NAME" >&2
}

# incr_finish <rc> — при rc=0 атомарно записывает HEAD в INCR_CACHE.
# Без --incr (INCR_CACHE пуст) — no-op. При кеш-отказе — no-op.
# ВАЖНО: пишется НЕЗАВИСО от INCR_MODE. Случай (б) incr_parse («--incr передан, но кеш
# отсутствует → полный прогон С маркером») оставляет INCR_MODE="full", и первый guard
# на INCR_CACHE уже отфильтровал «--incr не передан». Если бы incr_finish требовал
# INCR_MODE="incr", цикл «full → (должен стать) incr(0 коммитов)» вечно оставался бы
# «full → full», и actions/cache/save в CI сохранял бы несуществующий файл (no-op).
#
# Б-2 фикс (контракт 083 круг 2, ревьюер 9f83e78): incr_finish пишет HEAD
# судимого окна, а не текущий HEAD. Иначе коммит, пришедший ВО ВРЕМЯ
# локального `--incr` прогона, записывается в кеш как «проверенный», но
# реально проверка работала со старым HEAD — следующий incr-прогон молча
# считает несудимый диапазон судимым. Источник истины — INCR_HEAD,
# зафиксированный в incr_parse на старте (ветвь (а)). В полном режиме
# (ветвь (б) — кеш отсутствует, или без --incr) INCR_HEAD пуст, и мы
# перечитываем текущий HEAD: «полный прогон → вся история судима → кеш
# засеять текущим HEAD» (сеяние своей линии; в CI checkout неподвижен —
# старт == конец).
incr_finish() {
  local rc="$1"
  [ -n "${INCR_CACHE:-}" ] || return 0
  [ "$rc" -eq 0 ] || return 0
  local head
  if [ -n "${INCR_HEAD:-}" ]; then
    # incr-режим: пишем зафиксированный на старте HEAD (ветвь (а))
    head="$INCR_HEAD"
  else
    # полный режим: перечитываем текущий HEAD
    head="$(git -C "$INCR_GIT_ROOT" rev-parse HEAD 2>/dev/null)" || return 0
  fi
  mkdir -p -- "$(dirname -- "$INCR_CACHE")" 2>/dev/null || return 0
  local tmp
  tmp="$(mktemp "${INCR_CACHE}.tmp.XXXXXX" 2>/dev/null)" || return 0
  if printf '%s\n' "$head" > "$tmp" 2>/dev/null; then
    mv "$tmp" "$INCR_CACHE" 2>/dev/null || rm -f "$tmp"
  else
    rm -f "$tmp"
  fi
  return 0
}
