#!/usr/bin/env bash
# Клетка А-6 «принятая база без targetBranches отказывает именованно» (живая
# сторона Н4-1, контракт 097; арбитраж contracts-097-refs-v1 п.5в):
# harness.project.json на base БЕЗ ключа targetBranches → подготовка
# отказывает rc 1 именованным отказом И-0, НИ ОДНОЙ транзакции над refs и
# снимок refs равен — критерий А-8 на отказном вызове (оба наблюдателя).
# Якоря литеральные, оба допустимы: модель dover.sh — «политика: грамматика»;
# реальный субъект — «политика: нет targetBranches в harness.project.json на
# base». Парный зелёный сценарий (050): та же пара с ключом на базе →
# prepare rc 0 под теми же наблюдателями. Привязка ловящих стабов — в
# battery_stubs.sh (Н-39), не здесь.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t97_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: politika-bez-targetbranches: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t97_world_harness a6)" || exit 2
trap '_t97_cleanup "$W"' EXIT
R="$W/repo"

# база без ключа targetBranches (живая сторона Н4-1)
git -C "$R" checkout -q main
printf '{\n  "repoId": "toy-harness-097"\n}\n' >"$R/harness.project.json"
_t97_regen "$R"
git -C "$R" add -A && git -C "$R" commit -qm 'base without targetBranches'
BASE="$(git -C "$R" rev-parse main)"
CAND="$(git -C "$R" rev-parse cand)"
MAIN_BEFORE="$(git -C "$R" rev-parse refs/heads/main)"

_t97_refs_arm "$R" || exit 2
refs_before="$(_t97_refs_snap "$R")" || exit 2
o="$(bash "$SUBJ" prepare --repo "$R" --task T-97 --base "$BASE" --candidate "$CAND" 2>&1)"; rc=$?
_t97_refs_check "$R" "$refs_before"; crc=$?; [ "$crc" -eq 0 ] || exit "$crc"
if { [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'политика: грамматика'; } \
  || { [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'политика: нет targetBranches в harness.project.json на base'; }; then
  :
else
  printf 'КРАСНО: a6: база без targetBranches не отказана именованно (rc=%s, вывод=%s)\n' "$rc" "$o" >&2; exit 1
fi
[ "$(git -C "$R" rev-parse refs/heads/main)" = "$MAIN_BEFORE" ] || { printf 'КРАСНО: a6: отказ двинул main ДО решения по политике\n' >&2; exit 1; }

# парный зелёный: та же пара, ключ на базе есть → prepare rc 0
W2="$(_t97_world_harness a6g)" || exit 2
trap '_t97_cleanup "$W"; _t97_cleanup "$W2"' EXIT
R2="$W2/repo"
_t97_refs_arm "$R2" || exit 2
refs_before="$(_t97_refs_snap "$R2")" || exit 2
out="$(bash "$SUBJ" prepare --repo "$R2" --task T-97 --base "$(git -C "$R2" rev-parse main)" --candidate "$(git -C "$R2" rev-parse cand)")"; rc=$?
_t97_refs_check "$R2" "$refs_before"; crc=$?; [ "$crc" -eq 0 ] || exit "$crc"
case "$out" in ''|*[!0-9a-f]*)
  printf 'КРАСНО: a6: парный зелёный упал — база с targetBranches не готовит (rc=%s, вывод=%s)\n' "$rc" "$out" >&2; exit 1 ;; esac
[ "${#out}" -eq 40 ] || { printf 'КРАСНО: a6: парный зелёный напечатал не 40 hex: %s\n' "$out" >&2; exit 1; }
exit 0
