#!/usr/bin/env bash
# Клетка И-6б «переход политики — отдельная санкция, обычный accept её не
# заменяет» (контракт 094, Б4 круга 1, Выход п.6; источник §1.5/1.6).
# Половина (а): кандидат меняет политику (mandatory=ci-a,ci-b → deploy-docs),
# все обязательные проверки СТАРОЙ политики честно зелёные (обвязка прогнала
# ci-a/ci-b доверенной версии), accept объекта есть — но разрешению на САМ
# ПЕРЕХОД политики взяться неоткуда: policy-строки в журнале нет. Честная
# дверь: «неавторизованный переход политики: <old> -> <new>», main не тронут
# (самовольное ослабление не становится доверенным за один publish).
# Половина (б): тот же объект + policy-строка (санкция судейского канала) —
# публикация проходит: разрешённый переход publishes. Обман (s13: проверка
# санкции снята) публикует без policy-строки → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: perehod-politiki-bez-sankcii: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t94_world i6b)" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"; J="$W/journal.tsv"
BASE="$(git -C "$R" rev-parse main)"
git -C "$R" checkout -q cand
printf 'repoId=toy-094\nmandatory=deploy-docs\ntargetBranches=main\n' | tee "$R/harness/policy" >/dev/null
git -C "$R" add -A && git -C "$R" commit -qm 'weaken policy'
git -C "$R" checkout -q main
CAND="$(git -C "$R" rev-parse cand)"
OLD_PV="$(_t94_anysha "$(git -C "$R" show "$BASE:harness/policy")")"
NEW_PV="$(_t94_anysha "$(git -C "$R" show "$CAND:harness/policy")")"
[ "$OLD_PV" != "$NEW_PV" ] || { printf 'КРАСНО: i6b: мир сломан — политика не сменилась\n' >&2; exit 1; }
M="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
O="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M")" || exit 1
_t94_verdict "$J" 1 T-1 "$O" accept
_t94_green "$R" "$BASE" "$J" "$O" "$M"   # обязательные СТАРОЙ политики честно зелёные

# ── половина (а): переход без санкции — отказ ────────────────────────────────
out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq "неавторизованный переход политики: $OLD_PV -> $NEW_PV"; then
  printf 'КРАСНО: i6b-a: неавторизованный переход политики опубликован (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: i6b-a: отказ сдвинул main\n' >&2; exit 1; }

# ── половина (б): policy-строка санкционирует переход — публикация проходит ──
_t94_policy "$J" "$O" "$OLD_PV" "$NEW_PV" 2
out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'PUBLISHED target=main'; then
  printf 'КРАСНО: i6b-b: санкционированный переход не опубликован (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R" rev-parse main)" = "$M" ] || { printf 'КРАСНО: i6b-b: main не на merge\n' >&2; exit 1; }
exit 0
