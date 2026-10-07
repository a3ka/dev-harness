#!/usr/bin/env bash
# track_digest.sh — сводка трека плана 084 (контракт 084 §И-9).
# Четыре раздела: done / заморожено-не-done / в работе / запланировано-не начато.
#
# Использование: bash scripts/track_digest.sh <трек> [--root <dir>]
#   <трек>           — имя трека, как в plan.tsv.
#   --root <dir>     — корень проверяемого дерева (по умолчанию — каталог скрипта).
#
# Коды возврата:
#   0 — сводка напечатана (раздел «нет», если трека нет в плане — нет, Р6; печатается «- нет»
#       в каждом разделе).
#   1 — трек не найден в plan.tsv.
#   2 — NOT_IMPLEMENTED (нет git/корня/плана).
set -uo pipefail
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SELF_DIR/lib_plan.sh"

die()  { printf '%s\n' "$*" >&2; exit 1; }
skip() { printf 'NOT_IMPLEMENTED: %s\n' "$*" >&2; exit 2; }

track=""
root="$SELF_DIR/.."
while [ $# -gt 0 ]; do
  case "$1" in
    --root) [ $# -ge 2 ] || die "--root требует путь"; root="$2"; shift 2 ;;
    --*)    die "флаг вне грамматики: $1"; shift ;;
    *)
      [ -z "$track" ] || die "трек задан дважды: $track и $1"
      track="$1"; shift ;;
  esac
done
[ -n "$track" ] || die "трек не задан: bash scripts/track_digest.sh <трек> [--root <dir>]"

command -v git >/dev/null 2>&1 || skip "нет git"
[ -d "$root" ] || skip "корня нет: $root"
root="$(cd "$root" && pwd)"
git -C "$root" rev-parse --git-dir >/dev/null 2>&1 || skip "корень не git-репозиторий: $root"

PLAN="$root/registry/plan.tsv"
[ -f "$PLAN" ] || skip "план недоступен: registry/plan.tsv отсутствует"
plan_parse "$PLAN" || die "$P84_PLAN_ERR"

# Трек вне плана: ни одно подстрокой/regex, литерально (д2: «.» в значении — литерал).
found=0
for t in "${P84_TRACK[@]}"; do
  if [ "$t" = "$track" ]; then found=1; break; fi
done
[ "$found" -eq 1 ] || die "трек не найден: ${track}"

p84_render_digest "$track" "$root"