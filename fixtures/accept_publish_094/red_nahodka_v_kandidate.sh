#!/usr/bin/env bash
# Клетка И-3 «находка привязана к объекту» (контракт 094, Выход п.3).
# Половина (а): открытая находка кандидата (fail@2 последним по своему предмету)
# отказывает публикацию ЭТОГО кандидата — именованный отказ, main не тронут.
# Половина (б): находка, живущая только в ДРУГОМ кандидате (задача T-1 на той же
# базе), НЕ топит публикацию задачи T-2 на этой базе: дверь публикует.
# Обман (s3: fail-строки без фильтра задачи топят всех) роняет половину (б) —
# клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: nahodka-v-kandidate: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

# ── половина (а): свой fail топит свою публикацию ─────────────────────────────
W1="$(_t94_world i3a)" || exit 2
trap '_t94_cleanup "$W1"' EXIT
R1="$W1/repo"; J1="$W1/journal.tsv"
BASE1="$(git -C "$R1" rev-parse main)"
CAND1="$(git -C "$R1" rev-parse cand)"
M1="$(bash "$SUBJ" prepare --repo "$R1" --task T-1 --base "$BASE1" --candidate "$CAND1")" || exit 1
O1="$(bash "$SUBJ" object --repo "$R1" --task T-1 --target main --base "$BASE1" --candidate "$CAND1" --merge "$M1")" || exit 1
_t94_verdict "$J1" 1 T-1 "$O1" accept
_t94_verdict "$J1" 2 T-1 "$O1" fail
_t94_green "$R1" "$BASE1" "$J1" "$O1" "$M1"
out="$(bash "$SUBJ" publish --repo "$R1" --task T-1 --target main --base "$BASE1" --candidate "$CAND1" --merge "$M1" --journal "$J1" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'более новый отказ по предмету: T-1'; then
  printf 'КРАСНО: i3a: своя находка не отказала публикацию (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R1" rev-parse main)" = "$BASE1" ] || { printf 'КРАСНО: i3a: отказ сдвинул main\n' >&2; exit 1; }
_t94_cleanup "$W1"

# ── половина (б): чужая находка (T-1) не топит публикацию T-2 на той же базе ──
W2="$(_t94_world i3b)" || exit 2
trap '_t94_cleanup "$W2"' EXIT
R2="$W2/repo"; J2="$W2/journal.tsv"
BASE="$(git -C "$R2" rev-parse main)"
CAND="$(git -C "$R2" rev-parse cand)"
# второй кандидат (задача T-1) со СВОИМ изменением — дефект живёт только в нём
git -C "$R2" checkout -qb cand2 main
printf 'defect\n' | tee "$R2/other.txt" >/dev/null
git -C "$R2" add -A && git -C "$R2" commit -qm 'cand2 T-1'
git -C "$R2" checkout -q main
CAND2="$(git -C "$R2" rev-parse cand2)"
M2T1="$(bash "$SUBJ" prepare --repo "$R2" --task T-1 --base "$BASE" --candidate "$CAND2")" || exit 1
O_T1="$(bash "$SUBJ" object --repo "$R2" --task T-1 --target main --base "$BASE" --candidate "$CAND2" --merge "$M2T1")" || exit 1
M2="$(bash "$SUBJ" prepare --repo "$R2" --task T-2 --base "$BASE" --candidate "$CAND")" || exit 1
O_T2="$(bash "$SUBJ" object --repo "$R2" --task T-2 --target main --base "$BASE" --candidate "$CAND" --merge "$M2")" || exit 1
_t94_verdict "$J2" 1 T-2 "$O_T2" accept
_t94_verdict "$J2" 2 T-1 "$O_T1" fail
_t94_green "$R2" "$BASE" "$J2" "$O_T2" "$M2"
out="$(bash "$SUBJ" publish --repo "$R2" --task T-2 --target main --base "$BASE" --candidate "$CAND" --merge "$M2" --candidate-ref cand --journal "$J2" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'PUBLISHED target=main'; then
  printf 'КРАСНО: i3b: находка чужого кандидата утопила публикацию T-2 (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R2" rev-parse main)" = "$M2" ] || { printf 'КРАСНО: i3b: main не на merge\n' >&2; exit 1; }
exit 0
