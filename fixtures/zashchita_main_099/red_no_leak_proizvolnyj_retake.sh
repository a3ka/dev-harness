#!/usr/bin/env bash
# Клетка red_no_leak_proizvolnyj_retake — инвариант З-9 контракта 099 (doc §2,
# check_no_leak): «Не разрешать произвольный retake ради зелени». Два входа:
#   (а) произвольный локальный коммит ahead (пути вне судейских зон, автор не
#       владелец зоны) → --retake-ahead обязан ОТКАЗАТЬ именованной фразой
#       семейства «переснятие-ahead не доказано» (зонная нога 031/044,
#       распространённая на ahead-режим 056 — не вторая конвенция);
#   (в) 024 не ослаблена: незакоммиченная утечка → --check отказ «основной чекаут загрязнён».
# Замер пачки 2026-10-12 (живой прогон): вход (а) сегодня ПРОХОДИТ
# («базлайн переснят: ahead-дельта junk-099.txt … путей 1, вне диффа 0» rc 0) —
# клетка КРАСНА на старом поведении. Субъект — ЖИВОЙ scripts/check_no_leak.sh.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z99_BASE/zashchita-099-noleak-$$-${RANDOM}"
trap 'rm -rf "$W"' EXIT

ROOT="${Z99_099_ROOT:-$(cd "$HERE/../.." && pwd)}"
NL="$ROOT/scripts/check_no_leak.sh"
[ -f "$NL" ] || { printf 'КРАСНО: red_no_leak_proizvolnyj_retake: предмет отсутствует: scripts/check_no_leak.sh\n' >&2; exit 1; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }

rm -rf "$W"; mkdir -p "$W/repo"
git init -q -b main "$W/repo"
git init -q --bare "$W/origin.git"
git -C "$W/repo" remote add origin "$W/origin.git"
git -C "$W/repo" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
git -C "$W/repo" push -q origin main
git -C "$W/repo" fetch -q origin

# Оракул в памяти ДО вызова (правило 8)
want_a='переснятие-ahead не доказано'
want_v='основной чекаут загрязнён'

# снимок ДО дельты
snap_out="$(bash "$NL" --snapshot "$W/repo" 2>&1)"; snap_rc=$?
if [ "$snap_rc" -ne 0 ]; then
  printf 'КРАСНО: red_no_leak_proizvolnyj_retake: снимок не строится (rc=%s): %s\n' \
    "$snap_rc" "$(printf '%s' "$snap_out" | head -c 200)" >&2
  exit 1
fi

# (в) 024 жива: незакоммиченная утечка видна --check
touch "$W/repo/untracked-099.txt"
check_out="$(bash "$NL" --check "$W/repo" 2>&1)"; check_rc=$?
rm -f "$W/repo/untracked-099.txt"
if [ "$check_rc" -ne 1 ] || ! printf '%s' "$check_out" | grep -Fq "$want_v"; then
  printf 'КРАСНО: red_no_leak_proizvolnyj_retake: вход в: 024 ослаблена — --check не поймал утечку (rc=%s): %s\n' \
    "$check_rc" "$(printf '%s' "$check_out" | head -c 200)" >&2
  exit 1
fi

# (а) произвольный локальный коммит ahead: путь вне судейских зон, автор не владелец зоны
touch "$W/repo/junk-099.txt"
git -C "$W/repo" add junk-099.txt
git -C "$W/repo" -c user.name=t -c user.email=t@t commit -q -m "произвольная дельта ради зелени"
out="$(env -u CHECK_NO_LEAK_TRUSTED bash "$NL" --retake-ahead "$W/repo" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ]; then
  printf 'КРАСНО: red_no_leak_proizvolnyj_retake: вход а: старое поведение — произвольный retake-ahead прошёл (rc=0): %s\n' \
    "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi
if ! printf '%s' "$out" | grep -Fq "$want_a"; then
  printf 'КРАСНО: red_no_leak_proizvolnyj_retake: вход а: отказ без именованной фразы «%s»: %s\n' \
    "$want_a" "$(printf '%s' "$out" | head -c 200)" >&2
  exit 1
fi

printf 'ЗЕЛЕНО: red_no_leak_proizvolnyj_retake\n'
exit 0
