#!/usr/bin/env bash
# Клетка И-2 «более новый отказ по тому же предмету перекрывает старый accept»
# (контракт 094, Выход п.2). Вход: verdict accept@1(OID) затем fail@2(OID) —
# повторный суд той же задачи нашёл дефект; проверки зелёные. Честная дверь:
# «более новый отказ по предмету: T-1», main не тронут. Обман (s2: отказ
# последнего круга игнорируется) публикует → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: novyj-otkaz-perekryvaet: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t94_world i2)" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"; J="$W/journal.tsv"
BASE="$(git -C "$R" rev-parse main)"
CAND="$(git -C "$R" rev-parse cand)"
MERGE="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
OID="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE")" || exit 1

_t94_verdict "$J" 1 T-1 "$OID" accept
_t94_verdict "$J" 2 T-1 "$OID" fail
_t94_green "$R" "$BASE" "$J" "$OID" "$MERGE"

out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE" --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'более новый отказ по предмету: T-1'; then
  printf 'КРАСНО: i2: новый отказ не перекрыл accept (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: i2: отказ сдвинул main\n' >&2; exit 1; }

# положительный контроль: ещё более новый accept возвращает публикацию
_t94_verdict "$J" 3 T-1 "$OID" accept
out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'PUBLISHED target=main'; then
  printf 'КРАСНО: i2: мир сломан — новейший accept не публикует (rc=%s, %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
