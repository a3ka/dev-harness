#!/usr/bin/env bash
# Клетка И-5 «изменение базы ИЛИ кандидата между проверкой и публикацией —
# отказ, не публикация» (контракт 094, Выход п.5).
# Половина (а): base ушла вперёд (новый коммит на main ПОСЛЕ проверки) — отказ
# «база изменилась», и дверь ОСТАВЛЯЕТ ветку на её новом месте (не откатывает).
# Половина (б): кандидат amend'нут после проверки (Н-78) — отказ «кандидат
# изменился» по --candidate-ref. Половина (в): publish БЕЗ --candidate-ref —
# именованный отказ даже на чистом кандидате: сверка движения кандидата не
# выключается молчанием CLI. Обман (s5: сверки/CAS сняты; s14: обязательность
# candidate-ref снята) публикует → красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: baza-ili-kandidat-izmenilsya: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

# ── половина (а): база изменилась ─────────────────────────────────────────────
W1="$(_t94_world i5a)" || exit 2
trap '_t94_cleanup "$W1"' EXIT
R1="$W1/repo"; J1="$W1/journal.tsv"
BASE="$(git -C "$R1" rev-parse main)"
CAND="$(git -C "$R1" rev-parse cand)"
M="$(bash "$SUBJ" prepare --repo "$R1" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
O="$(bash "$SUBJ" object --repo "$R1" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M")" || exit 1
_t94_verdict "$J1" 1 T-1 "$O" accept
_t94_green "$R1" "$BASE" "$J1" "$O" "$M"
# база ушла вперёд ПОСЛЕ проверки
printf 'moved\n' | tee "$R1/base-moved.txt" >/dev/null
git -C "$R1" add -A && git -C "$R1" commit -qm 'main moved'
NEWB="$(git -C "$R1" rev-parse main)"
out="$(bash "$SUBJ" publish --repo "$R1" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --journal "$J1" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "база изменилась: $BASE != $NEWB"; then
  printf 'КРАСНО: i5a: изменение базы не отказано (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R1" rev-parse main)" = "$NEWB" ] || { printf 'КРАСНО: i5a: дверь двинула/откатала чужую ветку\n' >&2; exit 1; }
_t94_cleanup "$W1"

# ── половина (б): кандидат изменён (amend) после проверки ────────────────────
W2="$(_t94_world i5b)" || exit 2
trap '_t94_cleanup "$W2"' EXIT
R2="$W2/repo"; J2="$W2/journal.tsv"
BASE="$(git -C "$R2" rev-parse main)"
CAND="$(git -C "$R2" rev-parse cand)"
M="$(bash "$SUBJ" prepare --repo "$R2" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
O="$(bash "$SUBJ" object --repo "$R2" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M")" || exit 1
_t94_verdict "$J2" 1 T-1 "$O" accept
_t94_green "$R2" "$BASE" "$J2" "$O" "$M"
git -C "$R2" checkout -q cand
printf 'amended\n' | tee -a "$R2/file.txt" >/dev/null
git -C "$R2" commit -q --amend -am 'cand amended'
git -C "$R2" checkout -q main
NEWC="$(git -C "$R2" rev-parse cand)"
out="$(bash "$SUBJ" publish --repo "$R2" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --candidate-ref cand --journal "$J2" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "кандидат изменился: cand $CAND != $NEWC"; then
  printf 'КРАСНО: i5b: amend кандидата не отказан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R2" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: i5b: отказ сдвинул main\n' >&2; exit 1; }
_t94_cleanup "$W2"

# ── половина (в): publish без --candidate-ref — именованный отказ ────────────
W3="$(_t94_world i5c)" || exit 2
trap '_t94_cleanup "$W3"' EXIT
R3="$W3/repo"; J3="$W3/journal.tsv"
BASE="$(git -C "$R3" rev-parse main)"
CAND="$(git -C "$R3" rev-parse cand)"
M="$(bash "$SUBJ" prepare --repo "$R3" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
O="$(bash "$SUBJ" object --repo "$R3" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M")" || exit 1
_t94_verdict "$J3" 1 T-1 "$O" accept
_t94_green "$R3" "$BASE" "$J3" "$O" "$M"
out="$(bash "$SUBJ" publish --repo "$R3" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --journal "$J3" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'candidate-ref обязателен для публикации'; then
  printf 'КРАСНО: i5c: publish без candidate-ref не отказан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R3" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: i5c: отказ сдвинул main\n' >&2; exit 1; }
exit 0
