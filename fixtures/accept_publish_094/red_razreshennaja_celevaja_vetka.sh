#!/usr/bin/env bash
# Клетка И-7 «положительная сторона allowlist» (контракт 094, требование adversary
# круга 1): ветка, литерально входящая в targetBranches ДОВЕРЕННОЙ политики (не
# только main), публикуется — allowlist читается из политики как ДАННЫЕ, литерал
# main не зашит. Вход: targetBranches=dev, полностью валидный объект (accept +
# обе зелёные проверки ci-a/ci-b), publish --target dev. Честная дверь: rc 0
# «PUBLISHED target=dev», refs/heads/dev на merge, main не тронут, published-строка
# одна. Обман (s16: зашитая константа main, порча t94-m16) отказывает
# «недопустимая целевая ветка: dev» → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: razreshennaja-celevaja-vetka: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t94_world i7razr dev)" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"; J="$W/journal.tsv"
BASE="$(git -C "$R" rev-parse main)"
CAND="$(git -C "$R" rev-parse cand)"
git -C "$R" branch dev "$BASE"   # целевая ветка существует на base (И-5: ref == base до публикации)
MERGE="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
OID="$(bash "$SUBJ" object --repo "$R" --task T-1 --target dev --base "$BASE" --candidate "$CAND" --merge "$MERGE")" || exit 1
_t94_verdict "$J" 1 T-1 "$OID" accept
_t94_green "$R" "$BASE" "$J" "$OID" "$MERGE"

out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target dev --base "$BASE" --candidate "$CAND" --merge "$MERGE" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'PUBLISHED target=dev'; then
  printf 'КРАСНО: i7+: разрешённая политикой ветка dev не опубликована (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R" rev-parse refs/heads/dev)" = "$MERGE" ] || { printf 'КРАСНО: i7+: dev не на merge\n' >&2; exit 1; }
[ "$(git -C "$R" rev-parse refs/heads/main)" = "$BASE" ] || { printf 'КРАСНО: i7+: публикация в dev тронула main\n' >&2; exit 1; }
n="$(grep -c '^published	' "$J")"
[ "$n" -eq 1 ] || { printf 'КРАСНО: i7+: строк published %s, ожидалась 1\n' "$n" >&2; exit 1; }
exit 0
