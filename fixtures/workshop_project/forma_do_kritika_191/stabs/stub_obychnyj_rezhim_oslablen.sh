#!/usr/bin/env bash
# 191 — ОБМАННАЯ РЕЛИЗАЦИЯ (батарея): обычный режим ослаблен: существование guard-файла не судится (регресс г1 контракта 038).
# Дефект: обычный (038) режим на несуществующем guard-файле зелёный. Различающий вход: клетка p04.
set -uo pipefail
GRAMMAR=0
if [ "${1:-}" = "--grammar" ]; then GRAMMAR=1; shift; fi
die()  { printf '%s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }
ROOT="${1:?использование: $0 [--grammar] <корень> <контракт>}"
CONTRACT_PATH="${2:?использование: $0 [--grammar] <корень> <контракт>}"
ROOT="$(cd "$ROOT" 2>/dev/null && pwd -P)" || skip "корня нет: $ROOT"
case "$CONTRACT_PATH" in /*) CONTRACT_PATH="${CONTRACT_PATH#$ROOT/}" ;; esac
[ -f "$ROOT/$CONTRACT_PATH" ] || skip "контракта нет: $ROOT/$CONTRACT_PATH"
body="$(cat "$ROOT/$CONTRACT_PATH" 2>/dev/null || true)"
[ -n "$body" ] || skip "тело контракта пусто: $ROOT/$CONTRACT_PATH"

header_line="$(printf '%s\n' "$body" | sed -nE '/^ПРОВОДКА:[[:space:]]*$/ {p}' | head -n 1)"
[ -n "$header_line" ] || die "проводка: поле ПРОВОДКА отсутствует"
mapfile -t all_lines < <(printf '%s\n' "$body")
header_idx=-1
for ((i=0; i<${#all_lines[@]}; i++)); do
  [ "${all_lines[$i]}" = "$header_line" ] && { header_idx=$i; break; }
done
channel_lines=(); in_enf=0
for ((i=header_idx+1; i<${#all_lines[@]}; i++)); do
  ln="${all_lines[$i]}"
  if [ -z "${ln//[[:space:]]/}" ]; then [ "$in_enf" -eq 1 ] && in_enf=0; continue; fi
  case "$ln" in
    "#"*) break ;;
    \`\`\`*) break ;;
    "ПРОВОДКА-ЭНФОРСМЕНТ:"*) in_enf=1; continue ;;
    "- "*) in_enf=0; channel_lines+=("$ln") ;;
    *) [ "$in_enf" -eq 1 ] && continue; die "проводка: строка вне грамматики: $ln" ;;
  esac
done
[ "${#channel_lines[@]}" -gt 0 ] || die "проводка: поле пусто"
has_role=0; has_charter=0
for ln in "${channel_lines[@]}"; do
  body_part="${ln#- }"
  case "$body_part" in
    guard=*)
      guard="${body_part#guard=}"
      if [ "$GRAMMAR" -eq 1 ]; then
        case "$guard" in ''|*[[:space:]]*|*«*|*»*) die "проводка: строка вне грамматики: $ln" ;; esac
      fi
      # ДЕФЕКТ: существование guard-файла не судится ни в одном режиме
      ;;
    role=*)
      has_role=1
      rest="${body_part#role=}"
      path="${rest%% *}"; after="${rest#* }"
      norm="$(printf '%s' "$after" | sed -nE '^[[:space:]]*«(.*)»[[:space:]]*$/{s//\1/p;q}')"
      [ -n "$norm" ] || die "проводка: строка вне грамматики: $ln"
      case "$norm" in *«*|*»*) die "проводка: строка вне грамматики: $ln" ;; esac
      rlex="${path#roles/}"
      { [ "$path" = "$rlex" ] || case "$rlex" in */*|*.md) false;; *) [ -n "${rlex%.md}" ];; esac; } \
        || die "проводка: role-канал обязан ссылаться строго на roles/<роль>.md, получено: $path"
      [ "$GRAMMAR" -eq 1 ] || { [ -f "$ROOT/$path" ] || die "проводка: role-файл не существует: $path"; }
      ;;
    charter=*)
      has_charter=1
      rest="${body_part#charter=}"
      path="${rest%% *}"; after="${rest#* }"
      case "$after" in '§'*) ;; *) die "проводка: строка вне грамматики: $ln" ;; esac
      [ "$path" = "AGENTS.md" ] || die "проводка: строка вне грамматики: $ln"
      ;;
    *) die "проводка: строка вне грамматики: $ln" ;;
  esac
done
enf_line="$(printf '%s\n' "$body" | sed -nE '/^ПРОВОДКА-ЭНФОРСМЕНТ:[[:space:]]*(.*)$/{s//\1/p;q}')"
has_enf=0
case "$enf_line" in '') ;; *) [ -n "${enf_line//[[:space:]]/}" ] && has_enf=1 ;; esac
if [ "$has_role" -eq 0 ] && [ "$has_charter" -eq 0 ] && [ "$has_enf" -eq 0 ]; then
  die "проводка: guard-only поле без предметного канала и строки ПРОВОДКА-ЭНФОРСМЕНТ"
fi
exit 0
