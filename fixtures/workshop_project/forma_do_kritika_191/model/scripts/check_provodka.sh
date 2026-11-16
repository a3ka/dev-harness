#!/usr/bin/env bash
# ЧЕСТНАЯ МОДЕЛЬ режима --grammar (предмет 191) + охраняемое подмножество
# обычного режима 038 (г1/г3/г5-существование — ровно то, что нужно клетке
# p04 «обычный режим на том же входе красен»).
#
# Грамматика — ЕДИНЫЙ источник контракт 038 §Инварианты 1-3; фразы причин
# несут ПОБАЙТОВО те же, что scripts/check_provodka.sh (фразы — из 038).
# Режим --grammar судит ТОЛЬКО форму: существование файлов, подключение и
# норма-строки НЕ проверяются (черновик до реализации ссылается на ещё
# не созданные цели — грамматика судима, существование — на done).
set -uo pipefail

GRAMMAR=0
if [ "${1:-}" = "--grammar" ]; then GRAMMAR=1; shift; fi

die()  { printf '%s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

ROOT="${1:?использование: $0 [--grammar] <корень-дерева> <отн-путь-контракта>}"
CONTRACT_PATH="${2:?использование: $0 [--grammar] <корень-дерева> <отн-путь-контракта>}"
ROOT="$(cd "$ROOT" 2>/dev/null && pwd -P)" || skip "корня нет: $ROOT"
case "$CONTRACT_PATH" in
  /*) CONTRACT_PATH="${CONTRACT_PATH#$ROOT/}" ;;
esac
CONTRACT_PATH="$(printf '%s' "$CONTRACT_PATH" | sed 's|^\./||; s|//|/|g')"
[ -f "$ROOT/$CONTRACT_PATH" ] || skip "контракта нет: $ROOT/$CONTRACT_PATH"
body="$(cat "$ROOT/$CONTRACT_PATH" 2>/dev/null || true)"
[ -n "$body" ] || skip "тело контракта пусто: $ROOT/$CONTRACT_PATH"

# ── г0: поле ПРОВОДКА + канальные строки ──
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
in_enf=0
for ((i=header_idx+1; i<${#all_lines[@]}; i++)); do
  ln="${all_lines[$i]}"
  if [ -z "${ln//[[:space:]]/}" ]; then
    [ "$in_enf" -eq 1 ] && in_enf=0
    continue
  fi
  case "$ln" in
    "#"*) break ;;
    \`\`\`*) break ;;
    "ПРОВОДКА-ЭНФОРСМЕНТ:"*) in_enf=1; continue ;;
    "- "*) in_enf=0; channel_lines+=("$ln") ;;
    *) [ "$in_enf" -eq 1 ] && continue
       die "проводка: строка вне грамматики: $ln" ;;
  esac
done

[ "${#channel_lines[@]}" -gt 0 ] || die "проводка: поле пусто"

# ── классификация каналов; в режиме --grammar guard-цель — одиночный токен ──
channel_kinds=()
channel_rests=()
channel_lns=()
for ((j=0; j<${#channel_lines[@]}; j++)); do
  ln="${channel_lines[$j]}"
  body_part="${ln#- }"
  kind=""
  case "$body_part" in
    guard=*)  kind="guard"  ;;
    role=*)   kind="role"   ;;
    charter=*) kind="charter" ;;
    *) die "проводка: строка вне грамматики: $ln" ;;
  esac
  rest="${body_part#*=}"
  if [ "$kind" = "guard" ] && [ "$GRAMMAR" -eq 1 ]; then
    # guard-цель — путь одним токеном: без пробельных символов и кавычек-лапок
    # (186 в3: `guard=путь «пояснение»` — вне грамматики и без обращения к ФС).
    case "$rest" in
      ''|*[[:space:]]*|*«*|*»*) die "проводка: строка вне грамматики: $ln" ;;
    esac
  fi
  channel_kinds+=("$kind")
  channel_rests+=("$rest")
  channel_lns+=("$ln")
done

# ── г0-доп (В1): guard-only без обоснования ──
has_role=0; has_charter=0
for ((i=0; i<${#channel_kinds[@]}; i++)); do
  case "${channel_kinds[$i]}" in
    role)    has_role=1 ;;
    charter) has_charter=1 ;;
  esac
done
enf_line="$(printf '%s\n' "$body" | sed -nE '/^ПРОВОДКА-ЭНФОРСМЕНТ:[[:space:]]*(.*)$/{s//\1/p;q}')"
case "$enf_line" in
  '') ;;
  *)  [ -n "${enf_line//[[:space:]]/}" ] && has_enf=1 ;;
esac
if [ "$has_role" -eq 0 ] && [ "$has_charter" -eq 0 ] && [ "${has_enf:-0}" -eq 0 ]; then
  die "проводка: guard-only поле без предметного канала и строки ПРОВОДКА-ЭНФОРСМЕНТ"
fi

# ── извлечение норма-строки: ровно «<содержимое>», вложенные пары запрещены ──
extract_quoted() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  case "$s" in
    «*) ;;
    *) printf ''; return 1 ;;
  esac
  case "$s" in
    *») ;;
    *) printf ''; return 1 ;;
  esac
  local content="${s#«}"
  content="${content%»}"
  case "$content" in
    *«*|*"»"*) printf ''; return 1 ;;
  esac
  printf '%s' "$content"
}

role_component_ok() {
  local r="$1"
  case "$r" in
    */*) return 1 ;;
  esac
  case "$r" in
    *.md) ;;
    *) return 1 ;;
  esac
  local base="${r%.md}"
  [ -n "$base" ]
}

for ((i=0; i<${#channel_kinds[@]}; i++)); do
  kind="${channel_kinds[$i]}"
  rest="${channel_rests[$i]}"
  orig="${channel_lns[$i]}"
  case "$kind" in
    guard)
      guard="$rest"
      [ "$GRAMMAR" -eq 1 ] && continue
      [ -f "$ROOT/$guard" ] || die "проводка: guard-файл не существует: $guard"
      ;;
    role)
      path="${rest%% *}"
      rest_after_path="${rest#* }"
      norm="$(extract_quoted "$rest_after_path")" \
        || die "проводка: строка вне грамматики: $orig"
      [ -n "$norm" ] || die "проводка: строка вне грамматики: $orig"
      role_lex_rest="${path#roles/}"
      if [ "$path" = "$role_lex_rest" ] || ! role_component_ok "$role_lex_rest"; then
        die "проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: $path"
      fi
      [ "$GRAMMAR" -eq 1 ] && continue
      [ -f "$ROOT/$path" ] || die "проводка: role-файл не существует: $path"
      ;;
    charter)
      path="${rest%% *}"
      rest_after_path="${rest#* }"
      case "$rest_after_path" in
        '§'*) ;;
        *) die "проводка: строка вне грамматики: $orig" ;;
      esac
      rest_after_section="${rest_after_path#§}"
      header_text="${rest_after_section%%«*}"
      case "$header_text" in
        *[[:space:]]) ;;
        *) die "проводка: строка вне грамматики: $orig" ;;
      esac
      header_text="${header_text%"${header_text##*[![:space:]]}"}"
      norm_part="${rest_after_section#*«}"
      norm_part="«${norm_part}"
      norm="$(extract_quoted "$norm_part")" \
        || die "проводка: строка вне грамматики: $orig"
      [ -n "$norm" ] || die "проводка: строка вне грамматики: $orig"
      [ "$path" = "AGENTS.md" ] || die "проводка: строка вне грамматики: $orig"
      [ "$GRAMMAR" -eq 1 ] && continue
      [ -f "$ROOT/$path" ] || die "проводка: секция устава не найдена: §${header_text}"
      ;;
  esac
done

exit 0
