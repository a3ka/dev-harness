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
# Парсинг role/charter: путь + норма-строка. Кавычки «…» — от ПЕРВОЙ « до
# ПОСЛЕДНЕЙ » в строке поля (контракт §Инварианты 1).
extract_quoted() {
  local s="$1"
  case "$s" in *«*) ;; *) printf ''; return 1 ;; esac
  local rest="${s#*«}"
  case "$rest" in *»*) ;; *) printf ''; return 1 ;; esac
  printf '%s' "${rest%»*}"
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
      # Грамматика role= (замороженный контракт 038 §Инварианты 1):
      # ТОЛЬКО `roles/<роль>.md`, никаких `policies/r.txt` или иных путей.
      # Без этой проверки канал принимал ЛЮБОЙ существующий файл — обход
      # адверсария: `role=<произвольный/путь>.txt «норма»` с существующим
      # файлом проходил rc0, норма «подтверждалась» файлом, не привязанным к роли.
      case "$path" in
        roles/[^/]*.md) ;;
        *) die "проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: $path" ;;
      esac
      [ -f "$ROOT/$path" ] || die "проводка: role-файл не существует: $path"
      if ! grep -Fxq -- "$norm" "$ROOT/$path"; then
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
      norm="$(extract_quoted "$rest_after_section")" \
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
