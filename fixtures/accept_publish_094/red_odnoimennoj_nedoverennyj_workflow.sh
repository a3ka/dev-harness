#!/usr/bin/env bash
# Клетка И-4б «происхождение обязательной проверки — доверенная версия
# определения» (контракт 094, Б3 круга 1, Выход п.4/п.6; Astra §1.4/1.5).
# Половина (а): кандидат ПОДМЕНИЛ одноимённый workflow (harness/checks/ci-a.cmd
# → true-заглушка); обвязка честно пишет check ok с wfsha ИСПОЛНЕННОЙ
# (подменённой) версии. Зелёное имя + чужой sha ≠ доверенный sha определения на
# base SHA. Честная дверь: «проверка не доверенной версии: ci-a», main не
# тронут. Обман (s12: сверка wfsha снята — любое зелёное имя проходит) публикует
# непроверенное → клетка красна.
# Половина (б): строки check идеально честны по имени/wfsha/статусу, но
# выписаны ДРУГОМУ объекту (кандидат C2); текущий объект C доказательств не
# имеет: «нет обязательной проверки: ci-a» — доказательство другого
# проверенного Git-объекта не переносится.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: odnoimennoj-nedoverennyj-workflow: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

# ── половина (а): одноимённый подменённый workflow ───────────────────────────
W="$(_t94_world i4b-a)" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"; J="$W/journal.tsv"
BASE="$(git -C "$R" rev-parse main)"
git -C "$R" checkout -q cand
printf 'true\n' | tee "$R/harness/checks/ci-a.cmd" >/dev/null   # имя то же, команды вырезаны
git -C "$R" add -A && git -C "$R" commit -qm 'tamper ci-a workflow'
git -C "$R" checkout -q main
CAND="$(git -C "$R" rev-parse cand)"
TRUSTED_A="$(_t94_wfsha "$R" "$BASE" ci-a)"
TAMPERED_A="$(_t94_wfsha "$R" "$CAND" ci-a)"
[ "$TRUSTED_A" != "$TAMPERED_A" ] || { printf 'КРАСНО: i4b-a: мир сломан — подмена не изменила sha\n' >&2; exit 1; }
M="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
O="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M")" || exit 1
_t94_verdict "$J" 1 T-1 "$O" accept
_t94_check "$J" "$O" ci-a ok 1 "$TAMPERED_A" "$(_t94_tree "$R" "$M")"   # обвязка записала sha исполненной подмены
_t94_check "$J" "$O" ci-b ok 2 "$(_t94_wfsha "$R" "$BASE" ci-b)" "$(_t94_tree "$R" "$M")"
out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'проверка не доверенной версии: ci-a'; then
  printf 'КРАСНО: i4b-a: одноимённый недоверенный workflow засчитан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: i4b-a: отказ сдвинул main\n' >&2; exit 1; }
_t94_cleanup "$W"

# ── половина (б): честные строки ДРУГОГО объекта не закрывают текущий ────────
W2="$(_t94_world i4b-b)" || exit 2
trap '_t94_cleanup "$W2"' EXIT
R2="$W2/repo"; J2="$W2/journal.tsv"
BASE="$(git -C "$R2" rev-parse main)"
CAND="$(git -C "$R2" rev-parse cand)"
git -C "$R2" checkout -qb cand2 main
printf 'other\n' | tee "$R2/other.txt" >/dev/null
git -C "$R2" add -A && git -C "$R2" commit -qm 'cand2'
git -C "$R2" checkout -q main
CAND2="$(git -C "$R2" rev-parse cand2)"
M2="$(bash "$SUBJ" prepare --repo "$R2" --task T-1 --base "$BASE" --candidate "$CAND2")" || exit 1
O2="$(bash "$SUBJ" object --repo "$R2" --task T-1 --target main --base "$BASE" --candidate "$CAND2" --merge "$M2")" || exit 1
M="$(bash "$SUBJ" prepare --repo "$R2" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
O="$(bash "$SUBJ" object --repo "$R2" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M")" || exit 1
_t94_verdict "$J2" 1 T-1 "$O" accept
_t94_green "$R2" "$BASE" "$J2" "$O2" "$M2"   # все доказательства — объекту кандидата C2
out="$(bash "$SUBJ" publish --repo "$R2" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --candidate-ref cand --journal "$J2" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет обязательной проверки: ci-a'; then
  printf 'КРАСНО: i4b-b: доказательство другого объекта перенесено (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R2" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: i4b-b: отказ сдвинул main\n' >&2; exit 1; }
exit 0
