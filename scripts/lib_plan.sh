#!/usr/bin/env bash
# НЕ БАРЬЕР: библиотека, вызывающий скрипт (check_plan.sh/gen_plan.sh/freeze_contract.sh/track_digest.sh) выносит вердикт.
# lib_plan.sh — единый разбор контракта 084 (Р2): грамматика plan.tsv (И-1), вычисление
# статусов из тегов репозитория (И-2), пар P0/P1 (И-3), рендер блоков ROADMAP (И-4),
# HANDOFF (И-5) и дайджеста трека (И-9). Дубликат разбора в каждом скрипте — класс
# расхождения «parse_artifact_basename», измеренный на freeze_contract.sh.
#
# Импортируют gen_plan.sh / check_plan.sh / track_digest.sh / freeze_contract.sh ОТ СВОЕГО
# каталога, а не от проверяемого дерева (прецедент next_id.sh, lib_registry.sh — иначе код
# барьера приходил бы из предмета).
#
# Контракт функций:
#   plan_parse <file>           — заполняет P84_* массивы; rc 0/1 + P84_PLAN_ERR.
#   plan_status <id> <root> [head] — печатает одно слово (статус И-2); rc 0.
#                                 head=1 — читать closed-without-done.tsv из HEAD (для freeze_contract).
#   p84_idx_of <id>             — P84_I (1-based индекс в массивах) | rc 1.
#   p84_closed_reason <id> <root> [head]— причина из closed-without-done.tsv.
#   p84_h1_title <id> <root>    — заголовок H1 файла contracts/<id>-*.md (HEAD-блоб) | rc 1.
#   p84_order                   — индексы в массиве P84_ORDER (1-based) в порядке (пара, файл).
#   p84_render_roadmap_block    — печатает строки между маркерами ROADMAP (И-4).
#   p84_render_handoff_block <root> — печатает строки HANDOFF (И-5).
#   p84_render_digest <track> <root> — печатает дайджест трека (И-9).
#   p84_p0p1 <root>             — P84_P0, P84_P1 («нет», если отсутствует; И-3, И-8).
#   p84_apply_block <f> <B> <E> <new> — заменяет строки строго между маркерами; rc 3, если
#                                    маркеры не по одному или перевёрнуты.
#   p84_check_block <f> <B> <E> <oracle> — сравнение содержимого блока с эталоном; rc 0/3.
#   p84_append_block <f> <B> <E> <new> — префикс + маркеры+блок; rc 3, если маркеры есть.
#   p84_split_tsv <line>        — заполняет P84_PARTS[] шестью полями через TAB; rc 1, если ≠ 6.
#
# Сравнения — `==`/`grep -Fx`, без regex/glob по значению (норма 037, измеренная на р5/з2/т2).
# «-» в enum-полях — литеральные значения (И-1: «зависит» = `-` или список id через `,`).
set -uo pipefail

# ── Константы грамматики (побайтово из контракта 084 §И-1, §И-4, §И-5, §И-8) ──────
P84_HDR=$'id\tпара\tэтап\tзависит\tисточник\tтрек'
P84_RM_BEGIN='<!-- BEGIN GENERATED PLAN -->'
P84_RM_END='<!-- END GENERATED PLAN -->'
P84_HO_BEGIN='<!-- BEGIN GENERATED NEXT SESSION -->'
P84_HO_END='<!-- END GENERATED NEXT SESSION -->'
P84_RM_TITLE='**Итоговый порядок** (генерируется из registry/plan.tsv: bash scripts/gen_plan.sh --write; правка — строкой плана)'
P84_RM_THEAD='| пара | id | этап | трек | зависит | источник |'
P84_RM_TSEP='|---|---|---|---|---|---|'
P84_HO_TITLE='## Следующая сессия (генерируется: bash scripts/gen_plan.sh --write)'
P84_HO_EMPTY='- нет пунктов: всё закрыто или зависимости открыты'
P84_ST_DONE='done'
P84_ST_CLOSED='закрыт без done'
P84_ST_FROZEN='заморожен'
P84_ST_ISSUED='номер выдан'
P84_ST_NEW='не начат'

# ── Примитивы алфавита И-1 ────────────────────────────────────────────────────────
# Все сравнения литеральные: regex ниже СРАВНИВАЕТ С ЯКОРНЫМ РЕГЕКСЕНОМ ПО АЛФАВИТУ,
# а не по значению поля (норма 037).
# Локаль-независимость (Н3-2, измерено 2026-10-07, круг 3): bash `[[ =~ ]]` в диапазонах
# `[А-ЯЁа-яё]` ИСПОЛЬЗУЕТ КОЛЛЯЦИЮ активной локали — `éa` (U+00E9), `Ґанок` (U+0490+),
# `ßa` (U+00DF) матчатся под LC_ALL=en_US.UTF-8 (где collation range расширен extended
# Latin / extra Cyrillic), но не матчатся под LC_ALL=C/C.utf8 (побайтовый диапазон UTF-8
# D0/D1); и наоборот — валидная кириллица `цикл-перезапуска` (U+0446…) матчится под
# en_US.UTF-8, но не под C. РАНЕЕ фикс был `( export LC_ALL=en_US.UTF-8; [[ =~ … ]] )` —
# этого НЕДОСТАТОЧНО, потому что `LC_ALL=C` от вызывающего процесса всё равно влияет
# на `[A-Za-z]`-подобные диапазоны (`ß` под en_US.UTF-8 ложно матчит трек `p84_is_track`).
# Правильный фикс — `grep -P '(*UTF8)…'`: `(*UTF8)` — PCRE-внутренний режим UTF-8,
# НЕ зависит от LC_ALL вызывающего (проверено живьём: под LC_ALL=C и под en_US.UTF-8
# результат ИДЕНТИЧЕН на пуле ревьюера éa/Ґанок/ßa/тест/цикл/CI-А — `é`/`Ґ`/`ß` →
# NOMATCH, валидная кириллица → MATCH). Алфавит — буква в §И-1: A-Z, a-z, кириллица
# U+0401 (Ё), U+0410-U+042F (А-Я), U+0430-U+044F (а-я), U+0451 (ё). Никаких других.
# ASCII-цифры/hex (p84_is_num_id, p84_is_pair, p84_is_source_sha) локаль-независимы
# сами по себе (диапазон только из ASCII, collation его не расширяет) — оставляем bash.
p84_is_num_id() { [[ "$1" =~ ^[0-9]{3}$ ]]; }
p84_is_sym_id() {
  printf '%s\n' "$1" | LC_ALL=C grep -qP \
    '(*UTF8)^[\x{0041}-\x{005A}\x{0061}-\x{007A}\x{0401}\x{0410}-\x{042F}\x{0430}-\x{044F}\x{0451}][\x{0041}-\x{005A}\x{0061}-\x{007A}\x{0030}-\x{0039}\x{002E}\x{002D}\x{0401}\x{0410}-\x{042F}\x{0430}-\x{044F}\x{0451}]*$'
}
p84_is_pair()   { [[ "$1" =~ ^[1-9][0-9]*$ ]]; }
p84_is_stage()  { [ "$1" = "до V-2" ] || [ "$1" = "параллельно с V-2" ]; }
p84_is_track()  {
  # §И-1: трек — `[A-Za-z][A-Za-z0-9-]*`. Под en_US.UTF-8 bash regex `[[ =~ ^[A-Za-z]… ]]`
  # ложно матчит `ß` (U+00DF — лежит в collation-расширении диапазона a-z в en_US);
  # под LC_ALL=C — корректно NOMATCH. Фикс аналогичен p84_is_sym_id.
  printf '%s\n' "$1" | LC_ALL=C grep -qP '(*UTF8)^[A-Za-z][A-Za-z0-9-]*$'
}
# Источник: форма docs/owner/<путь>.md#<раздел> либо [0-9a-f]{7,40}. ЗАМКНУТЫЕ алфавиты И-1:
# TAB не пропустил p84_split_tsv (TAB = разделитель полей); «,» и «|» — ни в один байт
# значения (р10: `|` и `,` в разделе источника отвергаются как «строка N: источник»).
p84_is_source_sha() { [[ "$1" =~ ^[0-9a-f]{7,40}$ ]]; }
p84_is_source_doc() {
  local s="$1" path sec
  case "$s" in docs/owner/*) ;; *) return 1 ;; esac
  case "$s" in *\#*) ;; *) return 1 ;; esac
  path="${s%#*}"; sec="${s#*#}"
  [ "${path%.md}" != "$path" ] || return 1
  case "$path" in *","*|*"|"*) return 1 ;; esac
  case "$sec" in *","*|*"|"*) return 1 ;; esac
  return 0
}

# ── Globals plan_parse ────────────────────────────────────────────────────────────
declare -g P84_ID=()
declare -g P84_PAIR=()
declare -g P84_STAGE=()
declare -g P84_DEPS=()
declare -g P84_SRC=()
declare -g P84_TRACK=()
declare -g P84_LINE=()
declare -g P84_PLAN_ERR=''
declare -g P84_PARTS=()

# ── p84_split_tsv <line> ──────────────────────────────────────────────────────────
# Заполняет P84_PARTS шестью полями через TAB. Сохраняет пустые поля (IFS=… read -a
# их теряет; здесь — через `tr '\t' '\n'` + while-read). rc 0, если полей 6; rc 1 иначе.
p84_split_tsv() {
  local line="$1" p
  P84_PARTS=()
  while IFS= read -r p; do P84_PARTS+=("$p"); done < <(printf '%s\n' "$line" | tr '\t' '\n')
  [ "${#P84_PARTS[@]}" -eq 6 ]
}

# ── p84_nul_line_in <file> → номер первой строки с NUL | пусто ─────────────────
# N3-1 (измерено 2026-10-07, круг 3): NUL-байт ВНУТРИ файла обходит грамматику И-1.
# Bash-переменная — C-строка, NUL-терминатор обрезает значение; `read`/`mapfile -t`/
# `IFS= read` — тоже, и тогда `${var#...}`/`[[ =~ ]]`/`grep "$var"` видят укороченное
# (после NUL) значение. Контрпример ревьюера: `id⇥para⇥…⇥CI\0⇥1\n` (NUL внутри поля
# трека) → `mapfile` даёт строку `id⇥para⇥…⇥CI`, `p84_split_tsv` разбивает на 6 полей
# (последнее = `CI`), `p84_is_track` валидирует `CI` — OK; NUL проглочен. Единственный
# надёжный способ — искать NUL в СЫРЫХ БАЙТАХ ФАЙЛА через инструмент, читающий байты
# напрямую. Используем `grep -naP '\x00' | head -1 | cut -d: -f1` (PCRE `(*UTF8)` тут
# НЕ нужен: `\x00` — ASCII, в обоих режимах совпадает с байтом 0x00; главное — мы не
# кладём файл в bash-переменную). `head -1` гарантирует, что `cut -d: -f1` видит только
# первую строку grep (а не строку после NUL, если grep сам не отрезал). grep -P доступен
# на этом раннере; без него разбор отказывает на первом id (примитивы алфавита И-1
# используют grep -P без запасной ветви) — запасная ветвь не защищает ничего и
# даёт неверный номер строки на busybox awk.
p84_nul_line_in() {
  local file=$1
  LC_ALL=C grep -naP '\x00' "$file" 2>/dev/null | head -1 | cut -d: -f1
}

# ── p84_utf8_invalid_line_in <file> → номер первой строки с невалидным UTF-8 байтом | пусто ─
# N4-1 (измерено 2026-10-07, круг 4): произвольный не-UTF-8 байт ВНУТРИ файла (например, 0xFF
# в поле «источник» пятой колонки) обходит грамматику И-1, если она построчно-полевая.
# `p84_nul_line_in` ловит 0x00, идиоматичные `grep -P '(*UTF8)'` и `[[ =~ … ]]` валидируют
# конкретные поля (id/трек) — НО между полями, внутри поля «источник» и в произвольной
# позиции строки байт остаётся вне охвата. После разбора `mapfile -t`/`read`/`grep "$var"`
# показывают укороченное/подменённое значение, и файл проходит с rc=0.
# Третий класс байт-валидности (после trailing-LF и mid-field-NUL) требует ЕДИНОГО
# upfront-чека ВСЕГО сырого файла, прежде чем разбирать строки/поля. Используем python3 —
# его UTF-8-декодер строгий по построению, отвергает overlong/surrogates/код-точки >U+10FFFF/
# байты 0xFE/0xFF, и детерминирован относительно LC_ALL вызывающего (тот же python3-канал
# уже используется в check_staged.sh для control-символов). Конформный кириллический
# (`пара`, `трек`) и эмодзи в поле «источник» декодируются без ошибки и НЕ дают ложных
# срабатываний; 0xFF (сырой байт вне UTF-8) даёт UnicodeDecodeError с .start = байтовая
# позиция первого инвалидного байта. Переводим в 1-индексированный номер строки счётом
# '\n' до этой позиции + 1 (тот же приём, что awk END/NR ниже для trailing-LF). Без
# python3 — rc 1, но это та же fail-closed позиция, что N3-1: раннер `_krasnye_084.sh`
# проверяет наличие python3 ещё до прогона, и контрактные клетки 084 его предполагают
# (check_staged.sh:493 «нет python3 — fail-closed»). Возвращаем ПУСТО при валидном файле
# (как `p84_nul_line_in` — пусто, если NUL нет; «есть строка» — иначе).
p84_utf8_invalid_line_in() {
  local file=$1
  python3 - "$file" <<'PY' 2>/dev/null
import sys
with open(sys.argv[1], "rb") as f:
    data = f.read()
try:
    data.decode("utf-8")
except UnicodeDecodeError as e:
    pos = e.start
    if pos is None:
        pos = 0
    line = data[:pos].count(b"\n") + 1
    sys.stdout.write(str(line))
PY
}

# ── plan_parse <file> ─────────────────────────────────────────────────────────────
# Побайтово против файла. CRLF ловится сравнением заголовка (р7-подвход 3). Пустая строка
# в середине файла — р6 (отказ без имени столбца). 5 полей — р1 (отказ без столбца, иначе
# false-positive «нет трека» при чтении шести переменных). Уникальность id — р2 (имя столбца
# не печатаем; первое вхождение прошло, второе — отказ по строке). Без завершающего LF —
# р12/А-084-2 (mapfile -t стирает различие, ловим ДО него). Список «зависит» строгий —
# р11/А-084-1 (IFS=',' read -a отбрасывает хвостовой пустой элемент, ловим границы строки).
# NUL внутри файла — Н3-1: ловим ДО разбора на строки/поля, по СЫРЫМ байтам (см. p84_nul_line_in).
# Не-UTF-8 байт в произвольной позиции — Н4-1: ловим ДО разбора на строки/поля, единым
# upfront-чеком всего сырого файла (см. p84_utf8_invalid_line_in). Проверка стоит РАНЬШЕ
# NUL/LF: инвалидный UTF-8 в 0xFF-байте ОДНОВРЕМЕННО нарушает И-1, и единая грамматика
# отказа И-7 — `план не разбирается: строка <N>: <поле>`, <поле> = UTF8 (по аналогии с NUL
# для mid-field NUL и с LF для trailing-LF). Позиция — первая строка с первым инвалидным
# байтом (а не «строка, в которой поле» — поле тут может быть любым; «UTF8» — короткое имя
# причины, не путается с реальным столбцом).
plan_parse() {
  local file="$1" ln line id pair stage deps src track d2 nul_line utf8_line
  P84_ID=(); P84_PAIR=(); P84_STAGE=(); P84_DEPS=(); P84_SRC=(); P84_TRACK=(); P84_LINE=()
  P84_PLAN_ERR=''
  if [ ! -f "$file" ]; then
    P84_PLAN_ERR='план недоступен: registry/plan.tsv отсутствует'
    return 1
  fi
  # N4-1: не-UTF-8 байт в произвольной позиции файла (например, 0xFF в поле «источник»)
  # обходит грамматику И-1. Это третий класс байт-валидности (после trailing-LF ниже и
  # mid-field-NUL). Проверка РАНЬШЕ NUL и РАНЬШЕ разбора на строки/поля: И-1 требует,
  # чтобы ВЕСЬ файл был UTF-8/LF, и 0xFF — то же нарушение, что NUL или отсутствие \n.
  # p84_utf8_invalid_line_in читает СЫРЫЕ байты, не кладёт файл в bash-переменную, и
  # детерминирован относительно LC_ALL (python3-канал, тот же что в check_staged.sh).
  # Грамматика отказа И-7 — `план не разбирается: строка <N>: <поле>`, <поле> = UTF8.
  # Пустой файл идёт через mapfile в «план пуст»/«план не разбирается: строка 1:» — оставляем.
  if [ -s "$file" ]; then
    utf8_line="$(p84_utf8_invalid_line_in "$file")"
    if [ -n "$utf8_line" ]; then
      P84_PLAN_ERR="план не разбирается: строка ${utf8_line}: UTF8"
      return 1
    fi
  fi
  # N3-1: NUL внутри значения поля обходит грамматику И-1 (B-3: bash C-string обрезает
  # на NUL, любая проверка ПОСЛЕ разбора на строки/поля NUL уже не видит). Ищем NUL в
  # СЫРЫХ БАЙТАХ файла через p84_nul_line_in — инструмент читает байты, не кладёт файл
  # в bash-переменную. Проверка РАНЬШЕ разбора на строки/поля и РАНЬШЕ проверки
  # финального LF (ниже): NUL-байт в середине/начале файла — то же нарушение И-1, что
  # и NUL вместо LF; единая грамматика отказа И-7 — `план не разбирается: строка <N>: <поле>`,
  # <поле> = NUL (по аналогии с LF для случая «без завершающего \n»). Пустой файл идёт
  # через mapfile в «план пуст»/«план не разбирается: строка 1:» — оставляем.
  if [ -s "$file" ]; then
    nul_line="$(p84_nul_line_in "$file")"
    if [ -n "$nul_line" ]; then
      P84_PLAN_ERR="план не разбирается: строка ${nul_line}: NUL"
      return 1
    fi
  fi
  # И-1: файл — UTF-8/LF. mapfile -t снимает различие, ловим ДО него по последнему байту
  # (А-084-2: «registry/plan.tsv без завершающего LF»). Последний байт сравниваем HEX'ом
  # через `od -tx1`: bash-строка не хранит NUL (B-3: NUL на хвосте дал бы `$(tail -c 1)=""`,
  # `[ -n "" ]` ложно, и файл проходил бы как валидный — нарушение И-1 «UTF-8/LF»).
  # Пустой файл идёт через mapfile в «план пуст»/«план не разбирается: строка 1:» — оставляем.
  if [ -s "$file" ]; then
    last_byte="$(tail -c 1 "$file" | od -An -tx1 | tr -d ' \n')"
    if [ "$last_byte" != "0a" ]; then
      # Б-2: грамматика отказа — `план не разбирается: строка <N>: <поле>` (И-7 п.(2));
      # N — 1-индексированный номер последней фактически существующей строки файла (строки
      # без завершающего LF). Считаем по \n-разделителям (awk END/NR): для незавершённого
      # хвоста NR = N (а не N+1 — это был бы «следующий за последним \n», несуществующая
      # позиция). <поле> = LF: не из заголовка, не путается с реальным столбцом.
      last_line_n="$(awk 'END{print NR}' "$file")"
      P84_PLAN_ERR="план не разбирается: строка ${last_line_n}: LF"
      return 1
    fi
  fi
  local -a lines
  mapfile -t lines < "$file" || lines=()
  if [ "${#lines[@]}" -eq 0 ]; then
    P84_PLAN_ERR='план не разбирается: строка 1:'
    return 1
  fi
  if [ "${lines[0]}" != "$P84_HDR" ]; then
    P84_PLAN_ERR='план не разбирается: строка 1:'
    return 1
  fi
  local i
  declare -A seen_ids=()
  for ((i = 1; i < ${#lines[@]}; i++)); do
    ln=$((i + 1))
    line="${lines[$i]}"
    if [ -z "$line" ]; then
      P84_PLAN_ERR="план не разбирается: строка ${ln}:"
      return 1
    fi
    if ! p84_split_tsv "$line"; then
      P84_PLAN_ERR="план не разбирается: строка ${ln}:"
      return 1
    fi
    id="${P84_PARTS[0]}"; pair="${P84_PARTS[1]}"; stage="${P84_PARTS[2]}"
    deps="${P84_PARTS[3]}"; src="${P84_PARTS[4]}"; track="${P84_PARTS[5]}"
    if ! p84_is_num_id "$id" && ! p84_is_sym_id "$id"; then
      P84_PLAN_ERR="план не разбирается: строка ${ln}: id"
      return 1
    fi
    if [ -n "${seen_ids[$id]+x}" ]; then
      P84_PLAN_ERR="план не разбирается: строка ${ln}:"
      return 1
    fi
    seen_ids[$id]=1
    if ! p84_is_pair "$pair"; then
      P84_PLAN_ERR="план не разбирается: строка ${ln}: пара"
      return 1
    fi
    if ! p84_is_stage "$stage"; then
      P84_PLAN_ERR="план не разбирается: строка ${ln}: этап"
      return 1
    fi
    if [ "$deps" != "-" ]; then
      # И-1: «зависит» = `-` либо id(,id)* — СПИСОК без хвостового/ведущего разделителя,
      # без пустых элементов между запятыми (А-084-1). IFS=',' read -r -a отбрасывает
      # хвостовой пустой элемент («001,» → «001»), поэтому сначала проверяем границы
      # строки и пустоту литеральным сравнением (норма 037), и только потом — алфавит.
      if [ -z "$deps" ] || [ "${deps:0:1}" = "," ] || [ "${deps: -1}" = "," ]; then
        P84_PLAN_ERR="план не разбирается: строка ${ln}: зависит"
        return 1
      fi
      local -a da
      IFS=',' read -r -a da <<< "$deps"
      for d2 in "${da[@]}"; do
        if [ -z "$d2" ]; then
          P84_PLAN_ERR="план не разбирается: строка ${ln}: зависит"
          return 1
        fi
        if ! p84_is_num_id "$d2" && ! p84_is_sym_id "$d2"; then
          P84_PLAN_ERR="план не разбирается: строка ${ln}: зависит"
          return 1
        fi
      done
    fi
    if [ -z "$src" ]; then
      P84_PLAN_ERR="нет источника: ${id}"
      return 1
    fi
    if ! p84_is_source_sha "$src" && ! p84_is_source_doc "$src"; then
      P84_PLAN_ERR="план не разбирается: строка ${ln}: источник"
      return 1
    fi
    if [ -z "$track" ]; then
      P84_PLAN_ERR="нет трека: ${id}"
      return 1
    fi
    if ! p84_is_track "$track"; then
      P84_PLAN_ERR="план не разбирается: строка ${ln}: трек"
      return 1
    fi
    P84_ID+=("$id"); P84_PAIR+=("$pair"); P84_STAGE+=("$stage")
    P84_DEPS+=("$deps"); P84_SRC+=("$src"); P84_TRACK+=("$track")
    P84_LINE+=("$ln")
  done
  if [ "${#P84_ID[@]}" -eq 0 ]; then
    P84_PLAN_ERR='план пуст'
    return 1
  fi
  return 0
}

# ── plan_status <id> <root> [head] ───────────────────────────────────────────────
# И-2 в порядке «done → закрыт без done → заморожен → номер выдан» по тегам refs репозитория.
# По умолчанию closed-without-done.tsv читается из РАБОЧЕГО ДЕРЕВА (check_plan/gen: блок ITER);
# head=1 — из HEAD-блоба (freeze_contract: Р3 — заморозка видит план по HEAD).
# Теги — refs репозитория запуска (не ls-remote), согласно §Модель угроз.
plan_status() {
  local id="$1" root="$2" head="${3:-0}"
  if ! p84_is_num_id "$id"; then
    printf '%s\n' "$P84_ST_NEW"
    return 0
  fi
  local st=''
  # done: ∃ refs/tags/done/contracts/<id>/*
  if git -C "$root" for-each-ref --format='%(refname)' "refs/tags/done/contracts/${id}/" 2>/dev/null | grep -q .; then
    st="$P84_ST_DONE"
  else
    local blob=''
    if [ "$head" = "1" ]; then
      blob="$(git -C "$root" cat-file -p "HEAD:registry/closed-without-done.tsv" 2>/dev/null || true)"
    elif [ -f "$root/registry/closed-without-done.tsv" ]; then
      blob="$(cat "$root/registry/closed-without-done.tsv" 2>/dev/null || true)"
    fi
    if [ -n "$blob" ] && printf '%s\n' "$blob" | awk -F'\t' -v w="$id" '$1==w {f=1; exit} END{exit !f}'; then
      st="$P84_ST_CLOSED"
    elif git -C "$root" for-each-ref --format='%(refname)' "refs/tags/frozen/contracts/${id}/" 2>/dev/null | grep -q .; then
      st="$P84_ST_FROZEN"
    else
      st="$P84_ST_ISSUED"
    fi
  fi
  printf '%s\n' "$st"
}

# ── p84_idx_of <id> → P84_I (1-based) | rc 1 ─────────────────────────────────────
p84_idx_of() {
  local id="$1" i
  for i in "${!P84_ID[@]}"; do
    if [ "${P84_ID[$i]}" = "$id" ]; then
      P84_I=$((i + 1))
      return 0
    fi
  done
  return 1
}

# ── p84_closed_reason <id> <root> [head] ─────────────────────────────────────────
# Печатает второе поле строки closed-without-done.tsv для id (head=1 → HEAD-блоб).
p84_closed_reason() {
  local id="$1" root="$2" head="${3:-0}" blob
  if [ "$head" = "1" ]; then
    blob="$(git -C "$root" cat-file -p "HEAD:registry/closed-without-done.tsv" 2>/dev/null || true)"
  elif [ -f "$root/registry/closed-without-done.tsv" ]; then
    blob="$(cat "$root/registry/closed-without-done.tsv" 2>/dev/null || true)"
  fi
  [ -n "$blob" ] || return 1
  printf '%s\n' "$blob" | awk -F'\t' -v w="$id" '$1==w {sub("^[^\t]+\t",""); print; exit}'
}

# ── p84_h1_title <id> <root> — заголовок H1 файла contracts/<id>-*.md из HEAD ──
# Без «# »; печатает строку и rc 0; rc 1, если файла нет.
p84_h1_title() {
  local id="$1" root="$2" f
  f="$(git -C "$root" ls-tree -r --name-only HEAD -- 'contracts/' 2>/dev/null \
       | awk -v w="$id" 'index($0, "contracts/" w "-") == 1 {print; exit}')"
  [ -n "$f" ] || return 1
  git -C "$root" cat-file -p "HEAD:${f}" 2>/dev/null \
    | awk 'NR==1 { sub(/^#[[:space:]]*/, ""); print; exit }'
}

# ── p84_order — индексы 1-based в порядке (пара числом, порядок файла) ──────────
p84_order() {
  local i
  P84_ORDER=()
  while IFS=$'\t' read -r p idx; do
    P84_ORDER+=("$idx")
  done < <(
    for i in "${!P84_ID[@]}"; do
      printf '%d\t%d\n' "${P84_PAIR[$i]}" "$((i + 1))"
    done | LC_ALL=C sort -t $'\t' -k1,1n -k2,2n
  )
}

# ── p84_render_roadmap_block — строки блока ROADMAP между маркерами (И-4) ───────
p84_render_roadmap_block() {
  local i
  p84_order
  printf '%s\n\n%s\n%s\n' "$P84_RM_TITLE" "$P84_RM_THEAD" "$P84_RM_TSEP"
  for i in "${P84_ORDER[@]}"; do
    printf '| %s | %s | %s | %s | %s | %s |\n' \
      "${P84_PAIR[$((i - 1))]}" "${P84_ID[$((i - 1))]}" "${P84_STAGE[$((i - 1))]}" \
      "${P84_TRACK[$((i - 1))]}" "${P84_DEPS[$((i - 1))]}" "${P84_SRC[$((i - 1))]}"
  done
}

# ── p84_render_handoff_block <root> — И-5 ────────────────────────────────────────
# A — строки со статусом «заморожен»; k = max(0, 2 − |A|); E — первые k строк со статусом
# «номер выдан» или «не начат», у которых каждая зависимость закрыта (И-2: done|закрыт без done);
# A и E — в порядке (пара, файл); вывод A, затем E. Пусто — единственная строка P84_HO_EMPTY.
p84_render_handoff_block() {
  local root="$1" i st k dep deps
  p84_order
  local -a A=() E=()
  for i in "${P84_ORDER[@]}"; do
    st="$(plan_status "${P84_ID[$((i - 1))]}" "$root")"
    [ "$st" = "$P84_ST_FROZEN" ] && A+=("$i")
  done
  k=$((2 - ${#A[@]}))
  [ "$k" -gt 0 ] || k=0
  for i in "${P84_ORDER[@]}"; do
    [ "${#E[@]}" -lt "$k" ] || break
    st="$(plan_status "${P84_ID[$((i - 1))]}" "$root")"
    case "$st" in "$P84_ST_ISSUED"|"$P84_ST_NEW") ;; *) continue ;; esac
    deps="${P84_DEPS[$((i - 1))]}"
    if [ "$deps" = "-" ]; then
      E+=("$i"); continue
    fi
    local -a da
    IFS=',' read -r -a da <<< "$deps"
    for dep in "${da[@]}"; do
      local ds; ds="$(plan_status "$dep" "$root")"
      case "$ds" in "$P84_ST_DONE"|"$P84_ST_CLOSED") ;; *) continue 2 ;; esac
    done
    E+=("$i")
  done
  printf '%s\n\n' "$P84_HO_TITLE"
  if [ "${#A[@]}" -eq 0 ] && [ "${#E[@]}" -eq 0 ]; then
    printf '%s\n' "$P84_HO_EMPTY"
    return 0
  fi
  for i in "${A[@]}" "${E[@]}"; do
    st="$(plan_status "${P84_ID[$((i - 1))]}" "$root")"
    printf -- '- %s · пара %s · %s · трек %s\n' \
      "${P84_ID[$((i - 1))]}" "${P84_PAIR[$((i - 1))]}" "$st" "${P84_TRACK[$((i - 1))]}"
  done
}

# ── p84_render_digest <track> <root> — И-9 ──────────────────────────────────────
# Четыре раздела: done / заморожено-не-done / в работе / запланировано-не начато; пустой —
# «- нет». В работе = «номер выдан»; запланировано = «не начат». done-id без файла контракта —
# «- <id> — файл контракта отсутствует».
p84_render_digest() {
  local track="$1" root="$2" i id st found
  p84_order
  printf '# трек %s\n' "$track"
  printf '## done\n'; found=0
  for i in "${P84_ORDER[@]}"; do
    [ "${P84_TRACK[$((i - 1))]}" = "$track" ] || continue
    id="${P84_ID[$((i - 1))]}"; st="$(plan_status "$id" "$root")"
    [ "$st" = "$P84_ST_DONE" ] || continue
    if title="$(p84_h1_title "$id" "$root")"; then
      printf -- '- %s — %s\n' "$id" "$title"
    else
      printf -- '- %s — файл контракта отсутствует\n' "$id"
    fi
    found=1
  done
  [ "$found" -eq 1 ] || printf -- '- нет\n'
  printf '## заморожено, не done\n'; found=0
  for i in "${P84_ORDER[@]}"; do
    [ "${P84_TRACK[$((i - 1))]}" = "$track" ] || continue
    id="${P84_ID[$((i - 1))]}"; st="$(plan_status "$id" "$root")"
    case "$st" in
        "$P84_ST_FROZEN") printf -- '- %s — заморожен\n' "$id"; found=1 ;;
        "$P84_ST_CLOSED")
          local reason; reason="$(p84_closed_reason "$id" "$root")"
          printf -- '- %s — закрыт без done: %s\n' "$id" "$reason"; found=1 ;;
        *) continue ;;
      esac
  done
  [ "$found" -eq 1 ] || printf -- '- нет\n'
  printf '## в работе\n'; found=0
  for i in "${P84_ORDER[@]}"; do
    [ "${P84_TRACK[$((i - 1))]}" = "$track" ] || continue
    id="${P84_ID[$((i - 1))]}"; st="$(plan_status "$id" "$root")"
    [ "$st" = "$P84_ST_ISSUED" ] || continue
    printf -- '- %s\n' "$id"; found=1
  done
  [ "$found" -eq 1 ] || printf -- '- нет\n'
  printf '## запланировано, не начато\n'; found=0
  for i in "${P84_ORDER[@]}"; do
    [ "${P84_TRACK[$((i - 1))]}" = "$track" ] || continue
    id="${P84_ID[$((i - 1))]}"; st="$(plan_status "$id" "$root")"
    [ "$st" = "$P84_ST_NEW" ] || continue
    printf -- '- %s\n' "$id"; found=1
  done
  [ "$found" -eq 1 ] || printf -- '- нет\n'
}

# ── p84_p0p1 <root> [head] — И-3, И-8 ──────────────────────────────────────────
# P0 — наименьшая пара открытых строк; P1 — наименьшая пара открытых строк > P0.
# «Открытые» = {id : status ∉ {done, закрыт без done}}. Отсутствие → «нет».
# head=1 — читать closed-without-done.tsv из HEAD (для freeze_contract §3а).
p84_p0p1() {
  local root="$1" head="${2:-0}" i st p p0='' p1=''
  for i in "${!P84_ID[@]}"; do
    st="$(plan_status "${P84_ID[$i]}" "$root" "$head")"
    case "$st" in "$P84_ST_DONE"|"$P84_ST_CLOSED") continue ;; esac
    p="${P84_PAIR[$i]}"
    if [ -z "$p0" ] || [ "$p" -lt "$p0" ]; then p0="$p"; fi
  done
  if [ -n "$p0" ]; then
    for i in "${!P84_ID[@]}"; do
      st="$(plan_status "${P84_ID[$i]}" "$root" "$head")"
      case "$st" in "$P84_ST_DONE"|"$P84_ST_CLOSED") continue ;; esac
      p="${P84_PAIR[$i]}"
      [ "$p" -gt "$p0" ] || continue
      if [ -z "$p1" ] || [ "$p" -lt "$p1" ]; then p1="$p"; fi
    done
  fi
  P84_P0="${p0:-нет}"
  P84_P1="${p1:-нет}"
}

# ── p84_block_index <f> <BEGIN> <END> → P84_B, P84_E (0-based) | rc 3 ──────────
# Единственные маркеры BEGIN/END в файле; иначе rc 3 (0 — BEGIN ≥ END).
P84_B=0; P84_E=0
p84_block_index() {
  local f="$1" B="$2" E="$3"
  local -a lines; mapfile -t lines < "$f" || return 3
  local -a bi=() ei=() i b=-1 e=-1
  for i in "${!lines[@]}"; do
    if [ "${lines[$i]}" = "$B" ]; then bi+=("$i"); fi
    if [ "${lines[$i]}" = "$E" ]; then ei+=("$i"); fi
  done
  if [ "${#bi[@]}" -ne 1 ] || [ "${#ei[@]}" -ne 1 ]; then return 3; fi
  b="${bi[0]}"; e="${ei[0]}"
  if [ "$b" -ge "$e" ]; then return 3; fi
  P84_B="$b"; P84_E="$e"
  return 0
}

# ── p84_block_content <f> <B> <E> — печатает строки СТРОГО между маркерами ──────
p84_block_content() {
  local f="$1" B="$2" E="$3"
  p84_block_index "$f" "$B" "$E" || return $?
  local -a lines; mapfile -t lines < "$f"
  local i
  for ((i = P84_B + 1; i < P84_E; i++)); do printf '%s\n' "${lines[$i]}"; done
}

# ── p84_apply_block <файл> <BEGIN> <END> <новый_блок> ────────────────────────────
# Заменяет строки строго между единственными маркерами BEGIN/END; иначе rc 3.
# Маркеры — целые строки (И-4: «строка-маркер»; р7: пробел в END → отказ).
p84_apply_block() {
  local f="$1" B="$2" E="$3" new="$4"
  local -a lines; mapfile -t lines < "$f" || return 3
  local -a bi=() ei=() i b e
  for i in "${!lines[@]}"; do
    if [ "${lines[$i]}" = "$B" ]; then bi+=("$i"); fi
    if [ "${lines[$i]}" = "$E" ]; then ei+=("$i"); fi
  done
  if [ "${#bi[@]}" -ne 1 ] || [ "${#ei[@]}" -ne 1 ]; then return 3; fi
  b="${bi[0]}"; e="${ei[0]}"
  if [ "$b" -ge "$e" ]; then return 3; fi
  local -a out
  for ((i = 0; i <= b; i++)); do out+=("${lines[$i]}"); done
  if [ -n "$new" ]; then
    while IFS= read -r line; do out+=("$line"); done <<< "$new"
  fi
  for ((i = e; i < ${#lines[@]}; i++)); do out+=("${lines[$i]}"); done
  printf '%s\n' "${out[@]}" > "$f"
}

# ── p84_check_block <файл> <BEGIN> <END> <oracle> ────────────────────────────────
# Сравнение побайтово: содержимое блока == oracle. Маркеры — по одному, BEGIN<END; иначе rc 3.
# rc 0 — равны; rc 1 — расходятся (после успешного p84_block_index).
p84_check_block() {
  local f="$1" B="$2" E="$3" oracle="$4"
  p84_block_index "$f" "$B" "$E" || return 3
  local got
  got="$(p84_block_content "$f" "$B" "$E")"
  if [ "$got" = "$oracle" ]; then return 0; fi
  return 1
}

# ── p84_append_block <файл> <BEGIN> <END> <новый_блок> ───────────────────────────
# Префикс: прежние байты файла, затем маркеры+блок. rc 3 — маркеры уже есть (для HANDOFF И-5:
# «дописывается в конец» — только при их отсутствии).
p84_append_block() {
  local f="$1" B="$2" E="$3" new="$4"
  if [ -f "$f" ] && grep -Fqx "$B" "$f"; then
    return 3
  fi
  if [ -f "$f" ] && grep -Fqx "$E" "$f"; then
    return 3
  fi
  local tmp; tmp="$(mktemp)"
  {
    [ -f "$f" ] && cat "$f"
    printf '%s\n' "$B"
    if [ -n "$new" ]; then
      while IFS= read -r line; do printf '%s\n' "$line"; done <<< "$new"
    fi
    printf '%s\n' "$E"
  } > "$tmp"
  mv "$tmp" "$f"
}
