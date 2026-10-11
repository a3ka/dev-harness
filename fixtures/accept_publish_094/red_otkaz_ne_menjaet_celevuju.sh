#!/usr/bin/env bash
# Клетка И-8 «отказ публикации НЕ меняет локальную целевую ветку преждевременно»
# (контракт 094, строка 350 докса). Вход: stale accept — accept@1 выписан
# СТАРОМУ объекту (кандидат с тех пор amend'нут, id объекта другой), проверки
# нового объекта зелёные. Честная дверь: «accept не этого объекта: T-1», и
# побочных следов ноль: main байт-в-байт прежний, строк published нет, land-
# коммитов нет, рабочее дерево чисто. Обман (s8: объектная привязка accept
# снята, ветка двигается до проверок) оставляет след → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: otkaz-ne-menjaet-celevuju: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t94_world i8)" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"; J="$W/journal.tsv"
BASE="$(git -C "$R" rev-parse main)"
CAND_OLD="$(git -C "$R" rev-parse cand)"
M_OLD="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$BASE" --candidate "$CAND_OLD")" || exit 1
O_OLD="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND_OLD" --merge "$M_OLD")" || exit 1
# кандидат amend'нут: объект сменился, вердикт остался старым
git -C "$R" checkout -q cand
printf 'v2\n' | tee -a "$R/file.txt" >/dev/null
git -C "$R" commit -q --amend -am 'cand v2'
git -C "$R" checkout -q main
CAND="$(git -C "$R" rev-parse cand)"
MERGE="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
OID="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE")" || exit 1
[ "$O_OLD" != "$OID" ] || { printf 'КРАСНО: i8: мир сломан — объект не сменился\n' >&2; exit 1; }
_t94_verdict "$J" 1 T-1 "$O_OLD" accept
_t94_green "$R" "$BASE" "$J" "$OID" "$MERGE"

out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'accept не этого объекта: T-1'; then
  printf 'КРАСНО: i8: stale accept не опознан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
# отказ не оставляет следов: ветка байт-в-байт, журнала и merge-коммитов на main нет
[ "$(git -C "$R" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: i8: отказ сдвинул main\n' >&2; exit 1; }
n="$(grep -c '^published	' "$J")"
[ "$n" -eq 0 ] || { printf 'КРАСНО: i8: отказ записал published (%s)\n' "$n" >&2; exit 1; }
n="$(git -C "$R" log --format=%s main | grep -Fc 'land: ')"
[ "$n" -eq 0 ] || { printf 'КРАСНО: i8: на main есть land-коммиты (%s)\n' "$n" >&2; exit 1; }
[ -z "$(git -C "$R" status --porcelain)" ] || { printf 'КРАСНО: i8: рабочее дерево грязное\n' >&2; exit 1; }
exit 0
