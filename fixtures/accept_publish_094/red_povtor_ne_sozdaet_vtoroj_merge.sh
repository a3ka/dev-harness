#!/usr/bin/env bash
# Клетка И-9 «повтор после частичного успеха НЕ создаёт второй merge»
# (контракт 094, строка 350 докса; Astra §1.12 «done повторяет уже выполненный
# merge после частичного сбоя»). Половина (а): успешная публикация → повторный
# publish того же объекта — rc 0 «УЖЕ ОПУБЛИКОВАНО», main на том же sha,
# merge-коммитов land: ровно один. Половина (б): частичный успех — main УЖЕ на
# merge (строки published нет): повтор ЗАВЕРШАЕТ журнал, не создавая второго
# merge и не двигая ветку. Обман (s9: идемпотентность снята) отказывает (а)
# либо мержит снова → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: povtor-ne-sozdaet-vtoroj-merge: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

# ── половина (а): повтор после полного успеха ─────────────────────────────────
W1="$(_t94_world i9a)" || exit 2
trap '_t94_cleanup "$W1"' EXIT
R1="$W1/repo"; J1="$W1/journal.tsv"
BASE="$(git -C "$R1" rev-parse main)"
CAND="$(git -C "$R1" rev-parse cand)"
M="$(bash "$SUBJ" prepare --repo "$R1" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
O="$(bash "$SUBJ" object --repo "$R1" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M")" || exit 1
_t94_verdict "$J1" 1 T-1 "$O" accept
_t94_green "$R1" "$BASE" "$J1" "$O" "$M"
out="$(bash "$SUBJ" publish --repo "$R1" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --candidate-ref cand --journal "$J1" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || { printf 'КРАСНО: i9a: первая публикация не прошла (rc=%s, %s)\n' "$rc" "$out" >&2; exit 1; }
out="$(bash "$SUBJ" publish --repo "$R1" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --journal "$J1" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'УЖЕ ОПУБЛИКОВАНО'; then
  printf 'КРАСНО: i9a: повтор не идемпотентен (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R1" rev-parse main)" = "$M" ] || { printf 'КРАСНО: i9a: repeat двинул main\n' >&2; exit 1; }
n="$(git -C "$R1" log --format=%s main | grep -Fxc 'land: T-1')"
[ "$n" -eq 1 ] || { printf 'КРАСНО: i9a: land-коммитов %s, ожидался 1\n' "$n" >&2; exit 1; }
_t94_cleanup "$W1"

# ── половина (б): частичный успех (ref на merge, журнала нет) ────────────────
W2="$(_t94_world i9b)" || exit 2
trap '_t94_cleanup "$W2"' EXIT
R2="$W2/repo"; J2="$W2/journal.tsv"
BASE="$(git -C "$R2" rev-parse main)"
CAND="$(git -C "$R2" rev-parse cand)"
M="$(bash "$SUBJ" prepare --repo "$R2" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
O="$(bash "$SUBJ" object --repo "$R2" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M")" || exit 1
_t94_verdict "$J2" 1 T-1 "$O" accept
_t94_green "$R2" "$BASE" "$J2" "$O" "$M"
git -C "$R2" update-ref refs/heads/main "$M" "$BASE"   # ref ушёл, строка published НЕ записана
out="$(bash "$SUBJ" publish --repo "$R2" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --journal "$J2" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'УЖЕ ОПУБЛИКОВАНО'; then
  printf 'КРАСНО: i9b: частичный успех не завершён, а сломан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R2" rev-parse main)" = "$M" ] || { printf 'КРАСНО: i9b: main не на merge\n' >&2; exit 1; }
n="$(grep -c '^published	' "$J2")"
[ "$n" -eq 1 ] || { printf 'КРАСНО: i9b: строк published %s, ожидалась 1\n' "$n" >&2; exit 1; }
n="$(git -C "$R2" log --format=%s main | grep -Fxc 'land: T-1')"
[ "$n" -eq 1 ] || { printf 'КРАСНО: i9b: второй merge создан (%s)\n' "$n" >&2; exit 1; }
exit 0
