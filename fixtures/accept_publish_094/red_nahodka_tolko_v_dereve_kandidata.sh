#!/usr/bin/env bash
# Клетка И-3в «открытая находка в ДЕРЕВЕ кандидата топит его публикацию»
# (контракт 094, Б2 круга 1, Выход п.3). Вход: журнал честен (accept + зелёные
# проверки доверенной версии), на main открытых находок НЕТ, но ДЕРЕВО
# кандидата несёт .review/open.md со строкой «status: ready» — дефект живёт
# только в публикуемом дереве. Честная дверь читает git-объекты кандидата:
# «открытая находка в кандидате: .review/open.md», main не тронут. Закрытая
# находка (status: done) публикацию НЕ топит (положительный контроль).
# Обман (s11: скан дерева кандидата снят, дверь судит только журнал) публикует
# дефектное дерево → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: nahodka-tolko-v-dereve-kandidata: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

# ── половина (а): открытая находка в дереве кандидата ────────────────────────
W="$(_t94_world i3v-a)" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"; J="$W/journal.tsv"
BASE="$(git -C "$R" rev-parse main)"
git -C "$R" checkout -q cand
mkdir -p "$R/.review"
printf 'status: ready\nнаходка: дефект в кандидате\n' | tee "$R/.review/open.md" >/dev/null
git -C "$R" add -A && git -C "$R" commit -qm 'review finding'
git -C "$R" checkout -q main
CAND="$(git -C "$R" rev-parse cand)"
# на main .review нет — дефект существует ТОЛЬКО в кандидатном дереве
git -C "$R" cat-file -e "$BASE:.review/open.md" 2>/dev/null && { printf 'КРАСНО: i3v-a: мир сломан — находка на base\n' >&2; exit 1; }
M="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
O="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M")" || exit 1
_t94_verdict "$J" 1 T-1 "$O" accept
_t94_green "$R" "$BASE" "$J" "$O" "$M"
out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'открытая находка в кандидате: .review/open.md'; then
  printf 'КРАСНО: i3v-a: находка кандидатного дерева не отказана (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: i3v-a: отказ сдвинул main\n' >&2; exit 1; }
_t94_cleanup "$W"

# ── половина (б): закрытая находка (status: done) не топит ───────────────────
W2="$(_t94_world i3v-b)" || exit 2
trap '_t94_cleanup "$W2"' EXIT
R2="$W2/repo"; J2="$W2/journal.tsv"
BASE="$(git -C "$R2" rev-parse main)"
git -C "$R2" checkout -q cand
mkdir -p "$R2/.review"
printf 'status: done\nнаходка закрыта\n' | tee "$R2/.review/closed.md" >/dev/null
git -C "$R2" add -A && git -C "$R2" commit -qm 'review closed'
git -C "$R2" checkout -q main
CAND="$(git -C "$R2" rev-parse cand)"
M="$(bash "$SUBJ" prepare --repo "$R2" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
O="$(bash "$SUBJ" object --repo "$R2" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M")" || exit 1
_t94_verdict "$J2" 1 T-1 "$O" accept
_t94_green "$R2" "$BASE" "$J2" "$O" "$M"
out="$(bash "$SUBJ" publish --repo "$R2" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --candidate-ref cand --journal "$J2" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'PUBLISHED target=main'; then
  printf 'КРАСНО: i3v-b: закрытая находка утопила публикацию (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R2" rev-parse main)" = "$M" ] || { printf 'КРАСНО: i3v-b: main не на merge\n' >&2; exit 1; }
exit 0
