#!/usr/bin/env bash
# verify-coding-standards.sh — воспроизводимая сверка «правило стандарта ↔ носитель»
# для docs/CODING-STANDARDS.md (контракт харнесса 162; заменяет неотслеживаемые
# tmp/verify-standard.sh + tmp/claims.tsv, 123/123 которых — исходный замер).
#
# Запуск из любого cwd:  bash mobile/scripts/verify-coding-standards.sh
# Корень продукта — на два уровня выше каталога скрипта. Дерево скрипт только читает.
#
# Таблица — mobile/scripts/coding-standards-claims.tsv (первая строка — заголовок).
# Поля через TAB, один id = одно проверяемое утверждение:
#   id TAB раздел TAB утверждение TAB тип TAB путь-или-глоб TAB шаблон
#   раздел     — номер раздела «## N.» стандарта, в котором живёт правило;
#   утверждение— ДОСЛОВНЫЙ фрагмент непустой строки стандарта в этой секции
#                (≥ 12 знаков); без него правило не найдено;
#   тип        — exists | grep | grep-none | json | goal (семантика — ниже);
#   путь       — носитель: существующий ОТСЛЕЖИВАЕМЫЙ git-файл (или глоб/каталог);
#   шаблон     — PCRE (grep, grep-none, goal), «.a.b=значение» (json), «-» (exists).
# Типы:
#   exists    — путь (файл или каталог) существует и отслеживается;
#   grep      — шаблон встречается ≥1 раза в файлах носителя;
#   grep-none — шаблон НЕ встречается ни в одном файле глоба (пустой глоб — отказ);
#   json      — в JSON-файле путь `.a.b` равен значению;
#   goal      — «ЦЕЛЬ (код не соответствует: …)»: строка стандарта несёт слово ЦЕЛЬ, а
#               каждый перечисленный файл (для глоба — хотя бы один) нарушает шаблон.
#
# Именованные отказы (rc 1, каждый называет id; «носитель без правила» — путь):
#   правило без носителя  — пуст путь или шаблон носителя (и правило не цель);
#   носитель без правила  — объявлен носитель, а формулировки нет в секции стандарта;
#   носитель отсутствует / пустой глоб / шаблон не найден / нарушения нет — по типу;
#   невозможная проверка  — неизвестный тип, битый шаблон, json без «=»;
#   пустая выборка        — ноль утверждений в таблице (rc 0 на нуле невозможен).
# Двусторонность — по ОБЪЯВЛЕННОМУ множеству таблицы; полноту всех норм §§1–16
# судит независимый ревьюер, а не этот скрипт.
#
# Коды возврата: 0 — все объявленные утверждения подтверждены; 1 — именованный отказ;
#                2 — нечем проверить (нет git/jq/grep -P, стандарта, таблицы, аргумент).

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
STANDARD_REL="docs/CODING-STANDARDS.md"
CLAIMS="$SCRIPT_DIR/coding-standards-claims.tsv"
HEADER=$'id\tраздел\tутверждение\tтип\tпуть-или-глоб\tшаблон'
MIN_WORDING=12

# Кириллица в шаблонах: локаль UTF-8, иначе grep по байтам и не найдёт.
export LC_ALL=C.UTF-8

GREP="command grep"
JQ="command jq"

nope() { printf 'ОШИБКА (нечем проверить): %s\n' "$*" >&2; exit 2; }

[ "$#" -eq 0 ] || nope "аргументов нет; путь таблицы и корень не переопределяются (получено: $*)"
command -v git >/dev/null 2>&1 || nope "нет git"
command -v jq >/dev/null 2>&1 || nope "нет jq"
printf 'Проверка\n' | $GREP -P -q 'Проверка' || nope "grep не ищет многобайтные шаблоны (LC_ALL=$LC_ALL)"
[ -f "$ROOT/$STANDARD_REL" ] || nope "нет стандарта: $STANDARD_REL"
[ -f "$CLAIMS" ] || nope "нет таблицы утверждений: ${CLAIMS#"$ROOT/"}"
git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || nope "корень продукта не git-дерево: отслеживаемость носителей не проверить"

shopt -s nullglob dotglob globstar

# ---------------------------------------------------------------------------
# Отслеживаемые файлы: носитель — файл git-дерева, а не неотслеживаемая копия.
# ---------------------------------------------------------------------------
declare -A TRACKED=() TRACKED_DIR=()
while IFS= read -r -d '' p; do
  TRACKED["$p"]=1
  d="$p"
  while [[ "$d" == */* ]]; do
    d="${d%/*}"
    TRACKED_DIR["$d"]=1
  done
done < <(git -C "$ROOT" ls-files -z)
(( ${#TRACKED[@]} > 0 )) || nope "git ls-files пуст: нечего считать носителем"

is_tracked_file() { [[ -n "${TRACKED["$1"]+x}" ]]; }
is_tracked_any()  { [[ -n "${TRACKED["$1"]+x}" || -n "${TRACKED_DIR["${1%/}"]+x}" ]]; }

is_tracked_file "$STANDARD_REL" || nope "стандарт не отслеживается git: $STANDARD_REL"

# ---------------------------------------------------------------------------
# Стандарт: строки по секциям «## N.»
# ---------------------------------------------------------------------------
declare -a STD_LINES=() STD_SEC=()
declare -A SECTIONS=()
cur_sec=""
while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ ^##[[:space:]]+([0-9]+)\. ]]; then
    cur_sec="${BASH_REMATCH[1]}"
    SECTIONS["$cur_sec"]=1
  fi
  STD_LINES+=("$line")
  STD_SEC+=("$cur_sec")
done < "$ROOT/$STANDARD_REL"
(( ${#SECTIONS[@]} > 0 )) || nope "в стандарте нет секций «## N.»"

# ---------------------------------------------------------------------------
# Раскрытие путей (носитель — только отслеживаемые файлы)
# ---------------------------------------------------------------------------

# Фигурные скобки: баш не разворачивает `{a,b}` внутри переменной, поэтому
# список вариантов раскрываем сами.
brace_expand() {
  local s="$1"
  case "$s" in
    *'{'*) ;;
    *) printf '%s\n' "$s"; return 0 ;;
  esac
  local prefix="${s%%\{*}"
  local rest="${s#*\{}"
  local inner="${rest%%\}*}"
  local tail="${rest#*\}}"
  if [[ "$inner" != *','* ]]; then
    printf '%s\n' "$s"
    return 0
  fi
  local IFS=','
  local -a alts=()
  read -r -a alts <<<"$inner"
  unset IFS
  local alt
  for alt in "${alts[@]}"; do
    brace_expand "${prefix}${alt}${tail}"
  done
}

# Путь/глоб → существующие пути (файлы и каталоги). Буквальный путь имеет
# приоритет над глобом: в именах маршрутов есть метасимволы
# («(tabs)/[section].tsx»), которые глоб иначе исказил бы.
expand_paths() {
  local pat="$1" p m
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    if [[ -e "$ROOT/$p" ]]; then
      printf '%s\n' "$p"
      continue
    fi
    while IFS= read -r m; do
      [[ -n "$m" ]] && printf '%s\n' "$m"
    done < <(cd "$ROOT" && compgen -G "$p" 2>/dev/null)
  done < <(brace_expand "$pat")
}

# Путь/глоб → список ОТСЛЕЖИВАЕМЫХ ФАЙЛОВ (каталоги раскрываются рекурсивно).
expand_files() {
  local pat="$1" p m base
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    if [[ -d "$ROOT/$p" ]]; then
      base="${p%/}"                      # без хвостового слэша — иначе «//» в путях
      while IFS= read -r m; do
        [[ -n "$m" ]] && is_tracked_file "$m" && [[ -f "$ROOT/$m" ]] && printf '%s\n' "$m"
      done < <(cd "$ROOT" && compgen -G "$base/**" 2>/dev/null)
    elif [[ -f "$ROOT/$p" ]] && is_tracked_file "$p"; then
      printf '%s\n' "$p"
    fi
  done < <(expand_paths "$pat")
}

# Печатает первое совпадение «путь:строка:текст» и возвращает 0; 1 — совпадений
# нет; 2 — ошибка регулярного выражения.
first_hit() {
  local pattern="$1"; shift
  local p out rc
  for p in "$@"; do
    [[ -f "$ROOT/$p" ]] || continue
    # -H: имя файла печатается всегда (grep без него молчит о файле,
    # когда поиск идёт по одному файлу).
    out="$($GREP -H -P -I -n -m1 -e "$pattern" -- "$ROOT/$p" 2>&1)"
    rc=$?
    if (( rc == 0 )); then
      printf '%s\n' "${out#"$ROOT/"}"
      return 0
    fi
    if (( rc > 1 )); then
      printf '%s\n' "$out" >&2
      return 2
    fi
  done
  return 1
}

# ---------------------------------------------------------------------------
# Сторона носителя: одно утверждение → CARRIER_OK/CARRIER_DETAIL
# ---------------------------------------------------------------------------

CARRIER_OK=1
CARRIER_DETAIL=""
declare -a EVIDENCE_LINES=()

carrier_fail() { CARRIER_OK=0; CARRIER_DETAIL="${CARRIER_DETAIL:+$CARRIER_DETAIL; }$*"; }

check_carrier() {
  local type="$1" path="$2" pattern="$3"
  CARRIER_OK=1
  CARRIER_DETAIL=""
  EVIDENCE_LINES=()

  case "$type" in
    exists)
      if [[ ! -e "$ROOT/$path" ]]; then
        carrier_fail "носитель отсутствует: $path"
      elif ! is_tracked_any "$path"; then
        carrier_fail "носитель не отслеживается git: $path"
      else
        CARRIER_DETAIL="путь есть: $path"
      fi
      ;;

    grep)
      local -a files=()
      mapfile -t files < <(expand_files "$path")
      if (( ${#files[@]} == 0 )); then
        carrier_fail "пустой глоб/носитель отсутствует (нет отслеживаемых файлов): $path"
        return
      fi
      local hit rc
      hit="$(first_hit "$pattern" "${files[@]}")"
      rc=$?
      if (( rc == 0 )); then
        CARRIER_DETAIL="совпадение: ${hit%%:*}:$(cut -d: -f2 <<<"$hit")"
      elif (( rc == 2 )); then
        carrier_fail "невозможная проверка: ошибка регулярного выражения /$pattern/"
      else
        carrier_fail "шаблон не найден (${#files[@]} файл(ов), шаблон: $pattern)"
      fi
      ;;

    grep-none)
      local -a files=()
      mapfile -t files < <(expand_files "$path")
      if (( ${#files[@]} == 0 )); then
        carrier_fail "пустой глоб: нечего проверять ($path)"
        return
      fi
      local hit rc
      hit="$(first_hit "$pattern" "${files[@]}")"
      rc=$?
      if (( rc == 0 )); then
        carrier_fail "шаблон найден, а утверждение «нет»: $hit"
      elif (( rc == 2 )); then
        carrier_fail "невозможная проверка: ошибка регулярного выражения /$pattern/"
      else
        CARRIER_DETAIL="совпадений нет (${#files[@]} файл(ов) проверено)"
      fi
      ;;

    json)
      local file="$ROOT/$path"
      if [[ ! -f "$file" ]]; then
        carrier_fail "носитель отсутствует: JSON-файла нет: $path"
        return
      fi
      if ! is_tracked_file "$path"; then
        carrier_fail "носитель не отслеживается git: $path"
        return
      fi
      if [[ "$pattern" != *'='* ]]; then
        carrier_fail "невозможная проверка: json-шаблон без «=»: $pattern"
        return
      fi
      local jpath jval actual
      jpath="${pattern%%=*}"
      jpath="${jpath#.}"          # путь в TSV начинается с точки: `.a.b`
      jval="${pattern#*=}"
      actual="$($JQ -r --arg p "$jpath" '
        ($p | split(".")) as $k
        | (try getpath($k) catch null) as $a
        | if $a == null then "null"
          elif ($a | type) == "array" then ($a | map(tostring) | join(","))
          else ($a | tostring) end' "$file" 2>/dev/null)"
      if [[ "$actual" == "$jval" ]]; then
        CARRIER_DETAIL="$jpath = $actual"
      else
        carrier_fail "$jpath = ${actual:-<нет значения>}, ожидалось: $jval"
      fi
      ;;

    goal)
      # Пункт «ЦЕЛЬ»: перечисленные файлы должны нарушать шаблон. Доказательство
      # собираем по каждому нарушителю (файл + строка + текст).
      local -a entries=()
      local entry trimmed
      IFS=',' read -r -a entries <<<"$path"
      for entry in "${entries[@]}"; do
        trimmed="${entry#"${entry%%[![:space:]]*}"}"
        trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
        local -a files=()
        mapfile -t files < <(expand_files "$trimmed")
        if (( ${#files[@]} == 0 )); then
          carrier_fail "нет отслеживаемых файлов цели: $trimmed"
          continue
        fi
        local f viol=0 line
        for f in "${files[@]}"; do
          if $GREP -H -P -I -q -e "$pattern" -- "$ROOT/$f" 2>/dev/null; then
            viol=1
            # Все совпадения файла: по числу строк видно и величину замера.
            while IFS= read -r line; do
              [[ -n "$line" ]] && EVIDENCE_LINES+=("${line#"$ROOT/"}")
            done < <($GREP -H -P -I -n -e "$pattern" -- "$ROOT/$f" 2>/dev/null)
          fi
        done
        if (( viol == 0 )); then
          carrier_fail "нарушения нет: $trimmed"
        fi
      done
      (( CARRIER_OK == 1 )) && CARRIER_DETAIL="нарушения подтверждены: ${#EVIDENCE_LINES[@]} строк(и)"
      ;;

    *)
      carrier_fail "невозможная проверка: неизвестный тип «$type»"
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Сторона правила: формулировка — в непустой строке СВОЕЙ секции стандарта
# ---------------------------------------------------------------------------

RULE_LINE=0

find_rule_line() {
  local sec="$1" wording="$2" i
  RULE_LINE=0
  for i in "${!STD_LINES[@]}"; do
    [[ "${STD_SEC[$i]}" == "$sec" ]] || continue
    [[ -n "${STD_LINES[$i]//[[:space:]]/}" ]] || continue
    if [[ "${STD_LINES[$i]}" == *"$wording"* ]]; then
      RULE_LINE=$((i + 1))
      return 0
    fi
  done
  return 1
}

# ---------------------------------------------------------------------------
# Прогон
# ---------------------------------------------------------------------------

total=0
ok=0
fail=0
declare -A type_total=() type_ok=() seen_ids=()
declare -a fail_lines=() goal_id=() goal_claim=() goal_path=() goal_pattern=() goal_ev=()
declare -a table_problems=()

# Структура таблицы до разбора: заголовок и ровно 6 TAB-полей в каждой строке.
first_line="$(head -n 1 "$CLAIMS")"
if [[ "$first_line" != "$HEADER" ]]; then
  table_problems+=("таблица: первая строка не заголовок «$(tr '\t' '|' <<<"$HEADER")»")
fi
while IFS=: read -r lineno nf; do
  [[ -n "$lineno" ]] && table_problems+=("таблица: строка $lineno — полей $nf, ожидалось 6 (разделитель TAB)")
done < <(awk -F'\t' 'NR>1 && length($0)>0 && NF!=6 {print NR ":" NF}' "$CLAIMS")

USEP=$'\037'
rownum=1
while IFS="$USEP" read -r id razdel wording type path pattern; do
  rownum=$((rownum + 1))
  [[ -z "${id//[[:space:]]/}" ]] && continue
  total=$((total + 1))
  tkey="${type:-<пусто>}"
  type_total["$tkey"]=$(( ${type_total["$tkey"]:-0} + 1 ))

  declare -a row_fails=()
  row_fails=()
  rule_found=0
  rule_missing=0
  RULE_LINE=0

  # id: грамматика и уникальность.
  if [[ ! "$id" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]]; then
    row_fails+=("таблица: id вне грамматики [A-Za-z0-9][A-Za-z0-9_-]*: «$id» (строка $rownum)")
  elif [[ -n "${seen_ids["$id"]+x}" ]]; then
    row_fails+=("таблица: дубль id $id (строка $rownum): один id = одно утверждение")
  else
    seen_ids["$id"]=1
  fi

  # Правило: раздел существует, формулировка — в непустой строке этой секции.
  if [[ ! "$razdel" =~ ^[0-9]+$ ]] || [[ -z "${SECTIONS["$razdel"]+x}" ]]; then
    rule_missing=1
    row_fails+=("правило не найдено: id=$id — раздел «$razdel» не секция «## N.» стандарта")
  elif (( ${#wording} < MIN_WORDING )); then
    rule_missing=1
    row_fails+=("правило не найдено: id=$id §$razdel — формулировка короче $MIN_WORDING знаков: «$wording»")
  elif find_rule_line "$razdel" "$wording"; then
    rule_found=1
    if [[ "$type" == "goal" ]] && [[ "${STD_LINES[$((RULE_LINE - 1))]}" != *ЦЕЛЬ* ]]; then
      rule_found=0
      row_fails+=("цель не объявлена: id=$id §$razdel строка $RULE_LINE стандарта не несёт слова ЦЕЛЬ")
    fi
  else
    rule_missing=1
    row_fails+=("правило не найдено: id=$id §$razdel — формулировка не найдена ни в одной непустой строке секции: «$wording»")
  fi

  # Носитель: пустой носитель — «правило без носителя»; объявленный носитель без
  # правила — «носитель без правила» с путём.
  carrier_declared=1
  if [[ -z "${path//[[:space:]]/}" ]]; then
    carrier_declared=0
    row_fails+=("правило без носителя: id=$id §$razdel — путь носителя пуст и правило не объявлено целью")
  elif [[ -z "${pattern//[[:space:]]/}" ]]; then
    carrier_declared=0
    row_fails+=("правило без носителя: id=$id §$razdel — шаблон проверки носителя $path пуст")
  fi
  if (( carrier_declared == 1 )); then
    if (( rule_missing == 1 )); then
      row_fails+=("носитель без правила: $path — id=$id §$razdel: у носителя нет строки правила в этой секции стандарта")
    fi
    check_carrier "$type" "$path" "$pattern"
    if (( CARRIER_OK == 0 )); then
      row_fails+=("носитель не подтверждает правило: id=$id §$razdel — $CARRIER_DETAIL")
    fi
  fi

  if (( ${#row_fails[@]} == 0 )); then
    ok=$((ok + 1))
    type_ok["$tkey"]=$(( ${type_ok["$tkey"]:-0} + 1 ))
    printf 'OK %s §%s стандарт:строка %s носитель:%s — %s\n' "$id" "$razdel" "$RULE_LINE" "$path" "$CARRIER_DETAIL"
  else
    fail=$((fail + 1))
    printf 'FAIL %s\n' "$id"
    for f in "${row_fails[@]}"; do fail_lines+=("FAIL $id: $f"); done
  fi

  if [[ "$type" == "goal" ]]; then
    goal_id+=("$id")
    goal_claim+=("$wording")
    goal_path+=("$path")
    goal_pattern+=("$pattern")
    goal_ev+=("$(printf '%s\n' "${EVIDENCE_LINES[@]}")")
  fi
done < <(tail -n +2 "$CLAIMS" | tr '\t' "$USEP")

echo "--- ИТОГ ---"
echo "утверждений объявлено: $total; зелёных: $ok; красных: $fail"
while IFS= read -r t; do
  [[ -n "$t" ]] || continue
  printf 'тип %s: всего %s, ok %s, fail %s\n' \
    "$t" "${type_total["$t"]}" "${type_ok["$t"]:-0}" "$(( ${type_total["$t"]} - ${type_ok["$t"]:-0} ))"
done < <(printf '%s\n' "${!type_total[@]}" | sort)

problems=0
if (( ${#table_problems[@]} > 0 )); then
  problems=1
  echo "--- ТАБЛИЦА ---"
  printf 'FAIL %s\n' "${table_problems[@]}"
fi
if (( total == 0 )); then
  problems=1
  echo "FAIL пустая выборка: в таблице ${CLAIMS#"$ROOT/"} ноль утверждений — нулевой прогон не зелёный"
fi
if (( ${#fail_lines[@]} > 0 )); then
  echo "--- FAIL (id: причина) ---"
  printf '%s\n' "${fail_lines[@]}"
fi

if (( ${#goal_id[@]} > 0 )); then
  echo "--- goal-доказательства (файл:строка:текст) ---"
  for i in "${!goal_id[@]}"; do
    printf '%s (%s)\n' "${goal_id[$i]}" "${goal_claim[$i]}"
    printf '  перечень: %s\n' "${goal_path[$i]}"
    printf '  шаблон: %s\n' "${goal_pattern[$i]}"
    if [[ -z "${goal_ev[$i]}" ]]; then
      printf '  (совпадений нет)\n'
    else
      while IFS= read -r ev; do
        [[ -n "$ev" ]] && printf '  %s\n' "$ev"
      done <<<"${goal_ev[$i]}"
    fi
  done
fi

if (( fail == 0 && problems == 0 && total > 0 && ok == total )); then
  echo "РЕЗУЛЬТАТ: OK ($ok из $total объявленных утверждений)"
  exit 0
fi
echo "РЕЗУЛЬТАТ: FAIL"
exit 1
