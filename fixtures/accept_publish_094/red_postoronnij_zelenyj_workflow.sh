#!/usr/bin/env bash
# Клетка И-4 «посторонний зелёный workflow при отсутствии обязательного —
# не зелёное» (контракт 094, Выход п.4). Вход: accept есть, зелёные строки
# deploy-docs (постороннее имя) и ci-b, обязательной ci-a НЕТ. Честная дверь:
# «нет обязательной проверки: ci-a», main не тронут. Обман (s4: любое зелёное
# имя закрывает весь перечень) публикует → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: postoronnij-zelenyj-workflow: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t94_world i4)" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"; J="$W/journal.tsv"
BASE="$(git -C "$R" rev-parse main)"
CAND="$(git -C "$R" rev-parse cand)"
MERGE="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
OID="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE")" || exit 1

_t94_verdict "$J" 1 T-1 "$OID" accept
_t94_check "$J" "$OID" deploy-docs ok 1 "$(_t94_anysha postoronnij-deploy-docs)" "$(_t94_tree "$R" "$MERGE")"   # посторонний зелёный workflow
_t94_check "$J" "$OID" ci-b ok 2 "$(_t94_wfsha "$R" "$BASE" ci-b)" "$(_t94_tree "$R" "$MERGE")"   # вторая обязательная — зелёная доверенной версии

out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE" --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет обязательной проверки: ci-a'; then
  printf 'КРАСНО: i4: посторонний зелёный засчитан обязательным (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: i4: отказ сдвинул main\n' >&2; exit 1; }

# положительный контроль: своё зелёное ci-a закрывает перечень
_t94_check "$J" "$OID" ci-a ok 3 "$(_t94_wfsha "$R" "$BASE" ci-a)" "$(_t94_tree "$R" "$MERGE")"
out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'PUBLISHED target=main'; then
  printf 'КРАСНО: i4: мир сломан — полный перечень не публикует (rc=%s, %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
