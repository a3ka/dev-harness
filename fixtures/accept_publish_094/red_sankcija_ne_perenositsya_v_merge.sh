#!/usr/bin/env bash
# Клетка санкц-переноса 065 И-10 (контракт 094, architect-пачка А-393): кандидат
# несёт строку «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: …» в телах коммитов диапазона BASE..CAND
# (дважды — точный повтор). Merge-коммит ленда обязан нести её ДОСЛОВНО
# собственной строкой (grep -Fx; механизм субъекта :232-250), точные повторы
# дедуплицируются — ровно один экземпляр (065 И-2), первая строка тела —
# «land: <task>». Позитивный контроль: publish публикует этот merge, и тело
# мердж-коммита ленда на refs/heads/main несёт санкцию. Обман (s21: порча
# t94-m21 — перенос выкусан) строит merge-тело «land: …» без санкции → клетка
# красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: sankcija-ne-perenositsya: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t94_world sankcpere)" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"; J="$W/journal.tsv"
BASE="$(git -C "$R" rev-parse main)"
SAN='РАЗРЕШИЛ-ВЛАДЕЛЕЦ: санкция-альфа для 094'
git -C "$R" checkout -q cand
printf 'three\n' >>"$R/file.txt"
git -C "$R" add -A && git -C "$R" commit -qm 'санкция один' -m "$SAN"
printf 'four\n' >>"$R/file.txt"
git -C "$R" add -A && git -C "$R" commit -qm 'санкция два (точный повтор)' -m "$SAN"
CAND="$(git -C "$R" rev-parse cand)"
# мир не сломан: строка санкции есть в телах диапазона дважды
n="$(git -C "$R" log --format=%B "$BASE..$CAND" | grep -Fxc "$SAN")"
[ "$n" -eq 2 ] || { printf 'КРАСНО: sankcija: мир сломан — строк санкции в диапазоне %s, ожидалось 2\n' "$n" >&2; exit 1; }

# предъявление 1: prepare переносит санкцию в merge-тело дословно и один раз
M="$(bash "$SUBJ" prepare --repo "$R" --task T-21 --base "$BASE" --candidate "$CAND" 2>&1)"; prc=$?
if [ "$prc" -ne 0 ]; then
  printf 'КРАСНО: sankcija: prepare отказал (rc=%s, вывод: %s)\n' "$prc" "$M" >&2
  exit 1
fi
body="$(git -C "$R" show -s --format=%B "$M")"
printf '%s\n' "$body" | grep -Fxq "$SAN" \
  || { printf 'КРАСНО: sankcija: merge-тело не несёт строку санкции дословно (тело: %s)\n' "$body" >&2; exit 1; }
n="$(printf '%s\n' "$body" | grep -Fxc "$SAN")"
[ "$n" -eq 1 ] || { printf 'КРАСНО: sankcija: дедупликация точных повторов сломана — экземпляров %s, ожидался 1\n' "$n" >&2; exit 1; }
[ "$(printf '%s\n' "$body" | sed -n 1p)" = "land: T-21" ] \
  || { printf 'КРАСНО: sankcija: первая строка merge-тела не «land: T-21» (тело: %s)\n' "$body" >&2; exit 1; }

# предъявление 2 (позитив): публикация несёт санкцию в теле ленда на main
O="$(bash "$SUBJ" object --repo "$R" --task T-21 --target main --base "$BASE" --candidate "$CAND" --merge "$M")" || exit 1
_t94_verdict "$J" 1 T-21 "$O" accept
_t94_green "$R" "$BASE" "$J" "$O" "$M"
out="$(bash "$SUBJ" publish --repo "$R" --task T-21 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'PUBLISHED target=main'; then
  printf 'КРАСНО: sankcija: merge с санкцией не опубликован (rc=%s, вывод: %s)\n' "$rc" "$out" >&2
  exit 1
fi
[ "$(git -C "$R" rev-parse main)" = "$M" ] || { printf 'КРАСНО: sankcija: публикация не двинула main на merge\n' >&2; exit 1; }
printf '%s\n' "$(git -C "$R" show -s --format=%B refs/heads/main)" | grep -Fxq "$SAN" \
  || { printf 'КРАСНО: sankcija: тело мердж-коммита ленда на main не несёт санкцию\n' >&2; exit 1; }
exit 0
