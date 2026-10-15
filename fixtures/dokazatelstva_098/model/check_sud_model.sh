#!/usr/bin/env bash
# Честная модель двери сверки модели судьи (контракты 098+104) — носитель
# ГРАММАТИКИ субъекта scripts/check_sud_model.sh для ноги --verdict, которой
# зовёт model/judge_gate.sh (миграция 104: --verdict-row --sud). Живёт в семье
# батареи 098, используется режимом --model раннера и стаб-паком
# battery_stubs.sh (честная дверь в sd-каталоге стаба). Конфиг назначений —
# $SELF/../config/agent_models.json (копия установочного, ставит _mir.sh).
#
# CLI: check_sud_model.sh --verdict <роль> --trace <tsv> --object <sha> --session <id>
# Трасса — строки «роль TAB модель TAB allowed|denied TAB session TAB object»
# (грамматика 104: единый источник models_actual.sh --tsv --bind).
# Коды возврата: 0 — вердикт материализуется; 1 — именованный отказ (чужая
# трасса / не об объекте суда / модель не тира / фолбэк вне списка тира /
# трасса без строки роли); 2 — нечем проверять (битая грамматика, конфиг
# не читается, --object/--session не переданы).
set -uo pipefail
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SELF/.." && pwd)"

die1() { printf 'ОТКАЗ: %s\n' "$*" >&2; exit 1; }
ni()   { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

mode=""; role=""; trace=""; object=""; session=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --verdict) mode=verdict; role="${2:-}"; shift 2 ;;
    --trace)   trace="${2:-}"; shift 2 ;;
    --object)  object="${2:-}"; shift 2 ;;
    --session) session="${2:-}"; shift 2 ;;
    --root)    ROOT="${2:-}"; shift 2 ;;
    *) ni "неизвестный аргумент: $1" ;;
  esac
done
[ "$mode" = verdict ] || ni "поддержана только нога --verdict (миграция 104)"
[ -n "$role" ] || ni "роль не передана"
[ -n "$object" ] && [ -n "$session" ] || ni "--object и --session обязательны"
[ "${#object}" -eq 40 ] || ni "объект суда не 40 hex: $object"

command -v jq >/dev/null 2>&1 || ni "нет jq"
CFG="$ROOT/config/agent_models.json"
[ -f "$CFG" ] || ni "конфиг назначений не читается: $CFG"
tier="$(jq -r --arg r "$role" '.roles[$r] // ""' "$CFG")"; [ -n "$tier" ] || ni "тир роли не читается: $role"
expected="$(jq -r ".models[.tiers[\"$tier\"].model | ltrimstr(\"@\")] // \"\"" "$CFG")"; [ -n "$expected" ] || ni "модель тира не разрешается"
fbexpected="$(jq -r "if .tiers[\"$tier\"].fallback == null then \"\" else .models[.tiers[\"$tier\"].fallback | ltrimstr(\"@\")] // \"\" end" "$CFG")"

[ -f "$trace" ] || ni "трасса не читается: ${trace:-не передана}"
role_lines="$(awk -F'\t' -v r="$role" '$1 == r' "$trace")"
[ -n "$role_lines" ] || die1 "трасса без строки роли: $role"
bad="$(awk -F'\t' -v r="$role" '$1 == r && (NF != 5 || $2 == "" || $3 == "" || $4 == "" || $5 == "" || ($3 != "allowed" && $3 != "denied"))' "$trace")"
[ -z "$bad" ] || ni "трасса без привязки (нужно 5 полей)"
while IFS=$'\t' read -r r m fb s o; do
  [ -n "$r" ] || continue
  [ "$s" = "$session" ] || die1 "чужая трасса: сессия $s, суд $session"
  [ "$o" = "$object" ] || die1 "трасса не об объекте суда: $o, суд $object"
  case "$fb" in
    allowed) [ "$m" = "$expected" ] || die1 "вердикт не материализуется: судья $role на модели $m, тир $tier (Н-270)" ;;
    denied)  { [ -n "$fbexpected" ] && [ "$m" = "$fbexpected" ]; } || die1 "фолбэк вне списка тира: $role на $m, тир $tier (Н-270)" ;;
  esac
done <<< "$role_lines"
printf 'СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт %s материализуется\n' "$role"
exit 0
