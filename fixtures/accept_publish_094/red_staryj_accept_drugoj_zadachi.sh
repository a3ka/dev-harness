#!/usr/bin/env bash
# Клетка И-1 «старый accept другой задачи не принимается за текущую» (контракт 094,
# Выход п.1). Различимость: вход — журнал НЕСЁТ accept задачи T-1 (другой объект),
# проверок зелёные для объекта T-2; честная дверь отказывает «нет применимого
# accept для задачи: T-2» и НЕ двигает main; обман (s1: Task-фильтр/объект
# ослеплены) публикует → клетка красна (Н-39: привязка в коде стаб-пака).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: staryj-accept-drugoj-zadachi: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t94_world i1)" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"; J="$W/journal.tsv"
BASE="$(git -C "$R" rev-parse main)"
CAND="$(git -C "$R" rev-parse cand)"
MERGE2="$(bash "$SUBJ" prepare --repo "$R" --task T-2 --base "$BASE" --candidate "$CAND")" || { printf 'КРАСНО: i1: prepare не строит merge\n' >&2; exit 1; }
MERGE1="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
OID2="$(bash "$SUBJ" object --repo "$R" --task T-2 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE2")" || exit 1
OID1="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE1")" || exit 1

# журнал: accept ДРУГОЙ задачи (T-1), зелёные проверки — текущему объекту T-2
_t94_verdict "$J" 1 T-1 "$OID1" accept
_t94_green "$R" "$BASE" "$J" "$OID2" "$MERGE2"

out="$(bash "$SUBJ" publish --repo "$R" --task T-2 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE2" --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет применимого accept для задачи: T-2'; then
  printf 'КРАСНО: i1: чужой accept принят за текущий (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: i1: отказ сдвинул main\n' >&2; exit 1; }

# положительный контроль мира: свой accept той же задачи — публикация проходит
_t94_verdict "$J" 2 T-2 "$OID2" accept
out="$(bash "$SUBJ" publish --repo "$R" --task T-2 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE2" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'PUBLISHED target=main'; then
  printf 'КРАСНО: i1: мир сломан — свой accept не публикует (rc=%s, %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
