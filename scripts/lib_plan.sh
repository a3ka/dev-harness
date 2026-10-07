#!/usr/bin/env bash
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
# Все сравнения литеральные: [[ =~ ]] ниже СРАВНИВАЕТ С ЯКОРНЫМ РЕГЕКСЕНОМ ПО АЛФАВИТУ,
# а не по значению поля (норма 037).
p84_is_num_id() { [[ "$1" =~ ^[0-9]{3}$ ]]; }
p84_is_sym_id() { [[ "$1" =~ ^[A-Za-zА-ЯЁа-яё][A-Za-zА-ЯЁа-яё0-9.-]*$ ]]; }
p84_is_pair()   { [[ "$1" =~ ^[1-9][0-9]*$ ]]; }
p84_is_stage()  { [ "$1" = "до V-2" ] || [ "$1" = "параллельно с V-2" ]; }
p84_is_track()  { [[ "$1" =~ ^[A-Za-z][A-Za-z0-9-]*$ ]]; }
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

# ── plan_parse <file> ─────────────────────────────────────────────────────────────
# Побайтово против файла. CRLF ловится сравнением заголовка (р7-подвход 3). Пустая строка
# в середине файла — р6 (отказ без имени столбца). 5 полей — р1 (отказ без столбца, иначе
# false-positive «нет трека» при чтении шести переменных). Уникальность id — р2 (имя столбца
# не печатаем; первое вхождение прошло, второе — отказ по строке). Без завершающего LF —
# р12/А-084-2 (mapfile -t стирает различие, ловим ДО него). Список «зависит» строгий —
# р11/А-084-1 (IFS=',' read -a отбрасывает хвостовой пустой элемент, ловим границы строки).
plan_parse() {
  local file="$1" ln line id pair stage deps src track d2
  P84_ID=(); P84_PAIR=(); P84_STAGE=(); P84_DEPS=(); P84_SRC=(); P84_TRACK=(); P84_LINE=()
  P84_PLAN_ERR=''
  if [ ! -f "$file" ]; then
    P84_PLAN_ERR='план недоступен: registry/plan.tsv отсутствует'
    return 1
  fi
  # И-1: файл — UTF-8/LF. mapfile -t снимает различие, ловим ДО него по последнему байту
  # (А-084-2: «registry/plan.tsv без завершающего LF»). Пустой файл идёт через mapfile в
  # «план пуст»/«план не разбирается: строка 1:» — оставляем.
  if [ -s "$file" ] && [ -n "$(tail -c 1 "$file")" ]; then
    P84_PLAN_ERR='план не разбирается: registry/plan.tsv без завершающего LF'
    return 1
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
