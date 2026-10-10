#!/usr/bin/env bash
# Клетка И-7 «недопустимая целевая ветка отвергается» (контракт 094, Выход п.7).
# Вход: полностью зелёный объект (accept + проверки) для target=feature/x —
# ветки feature/x НЕТ в allowlist доверенной политики (main). Честная дверь:
# «недопустимая целевая ветка: feature/x» ДО любых движений refs — ref
# feature/x не создаётся, main не тронут. Обман (s7: allowlist-чек снят)
# создаёт/двигает refs → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: nedopustimaja-celevaja-vetka: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t94_world i7)" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"; J="$W/journal.tsv"
BASE="$(git -C "$R" rev-parse main)"
CAND="$(git -C "$R" rev-parse cand)"
MERGE="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
OID="$(bash "$SUBJ" object --repo "$R" --task T-1 --target feature/x --base "$BASE" --candidate "$CAND" --merge "$MERGE")" || exit 1
_t94_verdict "$J" 1 T-1 "$OID" accept
_t94_green "$R" "$BASE" "$J" "$OID" "$MERGE"

out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target feature/x --base "$BASE" --candidate "$CAND" --merge "$MERGE" --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'недопустимая целевая ветка: feature/x'; then
  printf 'КРАСНО: i7: недопустимая ветка не отвергнута (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
if git -C "$R" rev-parse --verify --quiet 'refs/heads/feature/x' >/dev/null; then
  printf 'КРАСНО: i7: дверь создала ref недопустимой ветки\n' >&2; exit 1
fi
[ "$(git -C "$R" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: i7: отказ сдвинул main\n' >&2; exit 1; }
exit 0
