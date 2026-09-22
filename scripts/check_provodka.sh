#!/usr/bin/env bash
# Барьер проводки контракта (контракт 038, Н-116 ПРОВОДКА done-gate): читает поле
# ПРОВОДКА контракта, судит «каждый канал нормы существует и подключён» и
# возвращает rc 0/1/2. Правило 8: «то ли правило» судит ревьюер по целям поля;
# механика — наличие/грамматика/подключение/строка.
#
# Грамматика — ЕДИНЫЙ источник контракт 038 §Инварианты 1–3; реализация несёт
# фразы ПОБАЙТОВО (фикстуры сверяют дословно через grep -Fq). Маркеры ищутся по
# ВСЕМУ файлу контракта (канон 008), парсинг — anchored `sed -nE` (прецедент
# check_spec_ready.sh:93–94).
#
# ПОРЯДОК ДИАГНОСТИКИ (v3, контракт §Инварианты 3): г0 → г0-доп → г1..г6;
# строки поля судятся слева направо, побеждает ПЕРВАЯ красная строка своего
# канала. Вход «guard-only ∧ guard-призрак» краснеет г0-доп, а не г1.
#
# Валидация пути role= — двухстадийный белый список Л+К (решение арбитра
# 9cea9c3, круг 4). Блоклист-патчинг исчерпан на кругах 1–3; закрывает ВСЕ
# классы обхода ОДНИМ свойством канонической цели на ФС.
#
# Круг 5 — закрыты два дефекта исполнения Л+К (адверсарий круга 4, Б1/Б2):
#   Б1 (TOCTOU): г4 теперь читает норму из УЖЕ канонизированного `$resolved`,
#       а не заново из `$ROOT/$path` (тот же объект между К и г4 не гарантирован).
#   Б2 (parser-laxity): extract_quoted заякорен на ВСЮ входную строку после
#       тримминга — ровно `«<содержимое>»`, без мусора до/после и без вложенных
#       пар; общий для role и charter каналов.
#
# Контракт API:
#   вход: $1 = <отн-путь-контракта> (относительно cwd — канон барьеров дерева);
#   rc 0 — проводка зелёная;
#   rc 1 — отказ с ИМЕНОВАННОЙ причиной первой красной строки;
#   rc 2 — нечем проверить: контракта нет / нет git / пустое тело контракта.
#
#   bash scripts/check_provodka.sh <отн-путь-контракта>
#
# Коды возврата: 0 — проводка зелёная, 1 — отказ, 2 — нечем проверить.
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die()  { printf '%s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

ROOT="${1:?использование: $0 <корень-дерева> <отн-путь-контракта>}"
CONTRACT_PATH="${2:?использование: $0 <корень-дерева> <отн-путь-контракта>}"
ROOT="$(cd "$ROOT" 2>/dev/null && pwd -P)" || skip "корня нет: $ROOT"
# CONTRACT_PATH: если абсолютный — отрезать ROOT-префикс; иначе — относительно ROOT.
case "$CONTRACT_PATH" in
  /*) CONTRACT_PATH="${CONTRACT_PATH#$ROOT/}" ;;
esac
CONTRACT_PATH="$(printf '%s' "$CONTRACT_PATH" | sed 's|^\./||; s|//|/|g')"
[ -f "$ROOT/$CONTRACT_PATH" ] || skip "контракта нет: $ROOT/$CONTRACT_PATH"
body="$(cat "$ROOT/$CONTRACT_PATH" 2>/dev/null || true)"
[ -n "$body" ] || skip "тело контракта пусто: $ROOT/$CONTRACT_PATH"

# ── г0: поле ПРОВОДКА + канальные строки ──────────────────────────────────────
# Шапка `ПРОВОДКА:` обязательна; под ней — 1..N строк, начинающихся с `- ` и
# описывающих каналы. Каждая такая строка должна матчиться ровно одним из трёх
# каналов; иначе — «вне грамматики» с САМОЙ строкой.
header_line="$(printf '%s\n' "$body" | sed -nE '/^ПРОВОДКА:[[:space:]]*$/ {p}' | head -n 1)"
[ -n "$header_line" ] || die "проводка: поле ПРОВОДКА отсутствует"

mapfile -t all_lines < <(printf '%s\n' "$body")
header_idx=-1
for ((i=0; i<${#all_lines[@]}; i++)); do
  if [ "${all_lines[$i]}" = "$header_line" ]; then
    header_idx=$i
    break
  fi
done
[ "$header_idx" -ge 0 ] || die "проводка: поле ПРОВОДКА отсутствует"

channel_lines=()
for ((i=header_idx+1; i<${#all_lines[@]}; i++)); do
  ln="${all_lines[$i]}"
  case "$ln" in
    "#"*) break ;;
  esac
  case "$ln" in
    "- "*) channel_lines+=("$ln") ;;
  esac
done

[ "${#channel_lines[@]}" -gt 0 ] || die "проводка: поле пусто"

# ── Классификация каналов (г0 структура) ─────────────────────────────────────
# Каждая строка разбирается ровно один раз; неизвестный формат → отказ
# «строка вне грамматики» с САМОЙ строкой дословно.
channels=()
for ln in "${channel_lines[@]}"; do
  body_part="${ln#- }"
  kind=""
  case "$body_part" in
    guard=*)  kind="guard"  ;;
    role=*)   kind="role"   ;;
    charter=*) kind="charter" ;;
    *) die "проводка: строка вне грамматики: $ln" ;;
  esac
  rest="${body_part#*=}"
  channels+=("$kind|$rest|$ln")
done

# ── г0-доп (В1): guard-only без обоснования ──────────────────────────────────
# Без role/charter-канала и без непустой строки «ПРОВОДКА-ЭНФОРСМЕНТ:» —
# отказ ДО проверки каналов (контракт §Инварианты 3, В1).
has_role=0; has_charter=0; has_enf=0
for ch in "${channels[@]}"; do
  case "${ch%%|*}" in
    role)    has_role=1 ;;
    charter) has_charter=1 ;;
  esac
done
enf_line="$(printf '%s\n' "$body" | sed -nE '/^ПРОВОДКА-ЭНФОРСМЕНТ:[[:space:]]*(.*)$/{s//\1/p;q}')"
case "$enf_line" in
  '') ;;
  *)  [ -n "${enf_line//[[:space:]]/}" ] && has_enf=1 ;;
esac
if [ "$has_role" -eq 0 ] && [ "$has_charter" -eq 0 ] && [ "$has_enf" -eq 0 ]; then
  die "проводка: guard-only поле без предметного канала и строки ПРОВОДКА-ЭНФОРСМЕНТ"
fi

# ── г1..г6: проверка каналов (первая красная строка своего канала) ────────────
# Парсинг role/charter: путь + норма-строка. Кавычки «…» — СТРОГО обрамляют
# норма-строку ЦЕЛИКОМ (контракт §Инварианты 1, круг 5 Б2). Вход extract_quoted
# ОБЯЗАН после trim'а ведущих/хвостовых ASCII-пробелов быть ровно `«<содержимое>»`,
# где содержимое не содержит ни « ни ». Этим закрыты: мусор до первой «, мусор
# после последней » и вложенные «…» внутри норма-строки. Любое отклонение → rc 1
# «строка вне грамматики» с самой строкой канала (новую фразу причины НЕ вводим).
extract_quoted() {
  local s="$1"
  # Trim ведущих ASCII-пробелов.
  s="${s#"${s%%[![:space:]]*}"}"
  # Trim хвостовых ASCII-пробелов.
  s="${s%"${s##*[![:space:]]}"}"
  # Вход ОБЯЗАН начинаться на « и заканчиваться на » (после trim'а).
  case "$s" in
    «*) ;;
    *) printf ''; return 1 ;;
  esac
  case "$s" in
    *») ;;
    *) printf ''; return 1 ;;
  esac
  # Содержимое — между первой « и последней »; в нём НЕ должно быть ни « ни »
  # (вложенные пары запрещены, контракт §Инварианты 1).
  local content="${s#«}"
  content="${content%»}"
  case "$content" in
    *«*|*"»"*) printf ''; return 1 ;;
  esac
  printf '%s' "$content"
}

# Компонент role-пути после снятия литерального префикса `roles/` (Л) или
# `$ROOT/roles/` (К): остаток обязан быть НЕПУСТ, не содержать '/', иметь
# суффикс `.md`, и оставшаяся база — НЕПУСТА. Общий предикат Л+К (решение
# арбитра 9cea9c3); используется в обоих местах, чтобы поведение Л и К
# было ПОБАЙТОВО эквивалентно.
role_component_ok() {
  local r="$1"
  # «нет /» — ЛИТЕРАЛЬНЫЙ паттерн */* (безопасная форма, §3 Н-39: не
  # использовать `[...]`-классы в `case`-паттернах).
  case "$r" in
    */*) return 1 ;;
  esac
  # «суффикс .md снят» — требует НАЛИЧИЯ суффикса; путь типа `roles`
  # отсекается раньше (на стороне Л префикс `roles/` обязан сниматься).
  case "$r" in
    *.md) ;;
    *) return 1 ;;
  esac
  # «база непуста» — после снятия `.md` остаток ненулевой длины; закрывает
  # `roles/.md` (база = «»).
  local base="${r%.md}"
  [ -n "$base" ]
}

# Подключение guard-имени: имя скрипта (без .sh) матчится как СЛОВО в не-
# закомментированной строке вызова в `.githooks/*` или `.github/workflows/*.yml`.
# Комментарий sh (`#`-строки) и закомментированный yml-шаг (строки, чей
# первый не-пробельный символ `#`) НЕ считаются (контракт §Инварианты 3, г2).
guard_is_wired() {
  local root="$1" guard="$2"
  local bname="${guard##*/}"; bname="${bname%.sh}"
  local githooks_dir="$root/.githooks" wf_dir="$root/.github/workflows"
  local found=0
  if [ -d "$githooks_dir" ]; then
    while IFS= read -r -d '' f; do
      while IFS= read -r line; do
        trimmed="${line#"${line%%[![:space:]]*}"}"
        case "$trimmed" in '#'*) continue ;; esac
        case "$trimmed" in
          *"$bname"*)
            if printf '%s' "$line" | grep -Eq "(^|[^[:alnum:]_])${bname}([^[:alnum:]_]|$)"; then
              found=1
              break 2
            fi
            ;;
        esac
      done < "$f"
    done < <(find "$githooks_dir" -maxdepth 1 -type f -print0 2>/dev/null)
  fi
  if [ "$found" -eq 0 ] && [ -d "$wf_dir" ]; then
    while IFS= read -r -d '' f; do
      case "$f" in *.yml|*.yaml) ;; *) continue ;; esac
      while IFS= read -r line; do
        trimmed="${line#"${line%%[![:space:]]*}"}"
        case "$trimmed" in '#'*) continue ;; esac
        case "$trimmed" in
          *"$bname"*)
            if printf '%s' "$line" | grep -Eq "(^|[^[:alnum:]_])${bname}([^[:alnum:]_]|$)"; then
              found=1
              break 2
            fi
            ;;
        esac
      done < "$f"
    done < <(find "$wf_dir" -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null)
  fi
  [ "$found" -eq 1 ]
}

# Тело секции устава: точный матч заголовка (`^#+ <текст>$`, побайтовое
# равенство); тело — от строки заголовка до следующего заголовка ТОГО ЖЕ или
# БОЛЕЕ высокого уровня (`#` или то же число `#` и менее).
charter_section_body() {
  local file="$1" header_text="$2"
  awk -v h="$header_text" '
    {
      if (match($0, /^#+[[:space:]]+/)) {
        cur_lvl = RLENGTH - 1
        cur_text = substr($0, RSTART+RLENGTH)
        if (cur_text == h && !in_body) { start_lvl = cur_lvl; in_body = 1; next }
        if (in_body && cur_lvl <= start_lvl) { in_body = 0; next }
      }
      if (in_body) print
    }
  ' "$file"
}

for ch in "${channels[@]}"; do
  kind="${ch%%|*}"
  rest="${ch#*|}"; rest="${rest%%|*}"
  orig="${ch##*|}"
  case "$kind" in
    guard)
      guard="$rest"
      [ -f "$ROOT/$guard" ] || die "проводка: guard-файл не существует: $guard"
      guard_is_wired "$ROOT" "$guard" \
        || die "проводка: guard не подключён: $guard не вызывается в .githooks/ или .github/workflows/"
      ;;
    role)
      path="${rest%% *}"
      rest_after_path="${rest#* }"
      norm="$(extract_quoted "$rest_after_path")" \
        || die "проводка: строка вне грамматики: $orig"
      [ -n "$norm" ] || die "проводка: строка вне грамматики: $orig"
      # Л — лексическая форма role-канала (контракт 038 §Инварианты 1, круг 4):
      # литеральный префикс `roles/` обязан сниматься, остаток не содержит '/',
      # суффикс `.md` обязан быть, база после снятия `.md` НЕПУСТА. Закрывает
      # круги 1 (не-roles/), 2 (traversal) и Б2 круга 3 (пустая база). Сравнение
      # `[ "$path" != "$role_lex_rest" ]` — безопасная проверка снятия
      # литерального префикса (без glob-ловушки §3 Н-39).
      role_lex_rest="${path#roles/}"
      if [ "$path" = "$role_lex_rest" ] || ! role_component_ok "$role_lex_rest"; then
        die "проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: $path"
      fi
      # г3 — существование. `[ -f ]` РАЗЫМЕНОВЫВАЕТ symlink: битый симлинк и
      # роль-призрак краснеют ЗДЕСЬ, до К (решение арбитра §Семантика 4).
      [ -f "$ROOT/$path" ] || die "проводка: role-файл не существует: $path"
      # К — канонизация цели на ФС (решение арбитра 9cea9c3). Резолв ОБЯЗАН
      # лежать ПЛОСКО строго под `$ROOT/roles/` И пройти ТОТ ЖЕ предикат
      # role_component_ok. Одним свойством закрывает: symlink наружу (круг 3,
      # Б1), symlink-каталог, вложенный резолв (`.../roles/sub/x.md` через
      # относительный таргет) и любые будущие варианты ФС-косвенности.
      # `$ROOT` уже канонизирован `pwd -P` в шапке скрипта — префикс
      # `$ROOT/roles/` снимаем параметр-экспансией (кавычки вокруг `"$ROOT"`
      # делают эту часть литеральной, §3 Н-39). Пустой/неуспешный readlink —
      # отказ (fail-closed).
      resolved="$(readlink -f -- "$ROOT/$path" 2>/dev/null || true)"
      [ -n "$resolved" ] || die "проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: $path (резолв: $resolved)"
      canon_tail="${resolved#"$ROOT"/roles/}"
      role_component_ok "$canon_tail" \
        || die "проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: $path (резолв: $resolved)"
      # г4 — норма-строка ИЩЕТСЯ В КАНОНИЧЕСКОЙ ЦЕЛИ (круг 5 Б1): `grep` читает
      # `$resolved` — путь, УЖЕ провалидированный стадией К на плоский резолв.
      # Повторное разыменование `$ROOT/$path` здесь НЕДОПУСТИМО: между К и этим
      # `grep` под `$ROOT/$path` мог подмениться другой объект (TOCTOU-окно),
      # норма из К-одобренной цели не была бы тогда найдена, но и норма из
      # подменённого файла прошла бы — это и был обход адверсария круга 4 Б1.
      # Читаем ровно тот байт-объект, который К одобрил.
      if ! grep -Fxq -- "$norm" "$resolved"; then
        die "проводка: норма-строка не найдена в role-файле: $path"
      fi
      ;;
    charter)
      path="${rest%% *}"
      rest_after_path="${rest#* }"
      case "$rest_after_path" in
        '§'*) ;;
        *) die "проводка: строка вне грамматики: $orig" ;;
      esac
      rest_after_section="${rest_after_path#§}"
      # header_text: от § до ПЕРВОГО « (норма-строка обрамлена кавычками; вложенные «»
      # внутри норма-строки запрещены, контракт §Инварианты 1).
      header_text="${rest_after_section%%«*}"
      # trim trailing whitespace — после норма-строки ничего быть не может
      header_text="${header_text%"${header_text##*[![:space:]]}"}"
      # norm-пара: от ПЕРВОГО « до конца строки (норма-строка обязан
      # заканчиваться на »). Здесь extract_quoted получает вход, который
      # после trim'а начинается с « — ровно та форма, которую ждёт строгая
      # грамматика «ровно «<содержимое>»». Без этого шага вход содержал бы
      # header_text ДО «, и строгая extract_quoted отказала бы легитимным
      # charter-строкам; канал и роль передают в extract_quoted одну форму.
      norm_part="${rest_after_section#*«}"
      norm_part="«${norm_part}"
      norm="$(extract_quoted "$norm_part")" \
        || die "проводка: строка вне грамматики: $orig"
      [ -n "$norm" ] || die "проводка: строка вне грамматики: $orig"
      [ -f "$ROOT/$path" ] || die "проводка: секция устава не найдена: §${header_text}"
      section_body="$(charter_section_body "$ROOT/$path" "$header_text")"
      [ -n "$section_body" ] || die "проводка: секция устава не найдена: §${header_text}"
      if ! printf '%s\n' "$section_body" | grep -Fxq -- "$norm"; then
        die "проводка: норма-строка не найдена в теле секции §${header_text}"
      fi
      ;;
  esac
done

exit 0
