#!/usr/bin/env bash
# Клетка И-1б «объект доказательства различает ВЕСЬ свой состав» (контракт 094,
# Б1 круга 1 + арбитраж 094 Б1-остаток: состав = repoId+задача+ветка+base+
# candidate+merge+политика). Половина (а): глагол object обязан выдавать РАЗНЫЕ
# id при неизменной паре задача+кандидат и замене ОДНОЙ другой составляющей:
# целевой ветки; merge (при НЕИЗМЕННЫХ базе/кандидате/политике — иное дерево
# объединения при тех же родителях, `commit-tree <иное дерево> -p base -p
# candidate`); базы; версии политики. Половина (б): accept/check выписаны
# объекту (B,C,M1); публикация подаёт ТОТ ЖЕ base и кандидат, но merge M2 с
# чужим, никем не проверенным деревом при тех же родителях (Замер 3 арбитража):
# честная дверь «accept не этого объекта: T-1», main остаётся на B. Обман
# (s10: id = «семь полей минус merge», ровно nomerge Замера 1 арбитража)
# публикует непринятый результат → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: obekt-drugoj-sostav: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

# alt_merge <repo> <candidate> <base> — merge-коммит с ИНЫМ деревом (дерево
# кандидата + backdoor.txt) при литеральных родителях base+candidate (Замер 3)
alt_merge() {
  local bk alt_tree
  bk="$(printf 'backdoor\n' | git -C "$1" hash-object -w --stdin)"
  alt_tree="$( { git -C "$1" ls-tree "$2"; printf '100644 blob %s\tbackdoor.txt\n' "$bk"; } | git -C "$1" mktree)"
  printf 'alt merge\n' | git -C "$1" commit-tree "$alt_tree" -p "$3" -p "$2"
}

# ── половина (а): id различает состав при той же задаче и кандидате ──────────
W="$(_t94_world i1b-a "main,dev")" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"
B1="$(git -C "$R" rev-parse main)"
C="$(git -C "$R" rev-parse cand)"
M1="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$B1" --candidate "$C")" || exit 1
O1="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$B1" --candidate "$C" --merge "$M1")" || exit 1
# та же задача+кандидат, ДРУГАЯ целевая ветка (обе в allowlist мира)
O_dev="$(bash "$SUBJ" object --repo "$R" --task T-1 --target dev --base "$B1" --candidate "$C" --merge "$M1")" || exit 1
[ "$O1" != "$O_dev" ] || { printf 'КРАСНО: i1b-a: id не различает целевую ветку\n' >&2; exit 1; }
# та же задача+кандидат+ветка+base+политика, ДРУГОЙ merge: id обязан различить
# merge ОТДЕЛЬНО от базы (Б1-остаток арбитража: nomerge-стаб Замера 1 ловится здесь)
M1_alt="$(alt_merge "$R" "$C" "$B1")" || exit 1
O1_alt="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$B1" --candidate "$C" --merge "$M1_alt")" || exit 1
[ "$O1" != "$O1_alt" ] || { printf 'КРАСНО: i1b-a: id не различает merge при неизменной базе\n' >&2; exit 1; }
# та же задача+кандидат, ДРУГАЯ база (политика байт-в-байт та же)
printf 'unrelated\n' | tee "$R/unrelated.txt" >/dev/null
git -C "$R" add -A && git -C "$R" commit -qm 'base moves'
B2="$(git -C "$R" rev-parse main)"
M2="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$B2" --candidate "$C")" || exit 1
O2="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$B2" --candidate "$C" --merge "$M2")" || exit 1
[ "$O1" != "$O2" ] || { printf 'КРАСНО: i1b-a: id не различает базу\n' >&2; exit 1; }
# та же задача+кандидат, ДРУГАЯ версия политики (правка harness/policy на base)
printf 'repoId=toy-094-v2\nmandatory=ci-a,ci-b\ntargetBranches=main,dev\n' | tee "$R/harness/policy" >/dev/null
git -C "$R" add -A && git -C "$R" commit -qm 'policy edits'
B3="$(git -C "$R" rev-parse main)"
M3="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$B3" --candidate "$C")" || exit 1
O3="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$B3" --candidate "$C" --merge "$M3")" || exit 1
[ "$O2" != "$O3" ] || { printf 'КРАСНО: i1b-a: id не различает версию политики\n' >&2; exit 1; }
_t94_cleanup "$W"

# ── половина (б): доказательства объекту (B,C,M1); publish подаёт (B,C,M2) ───
# той же базы: M2 — merge с ЧУЖИМ деревом при тех же родителях (Замер 3)
W2="$(_t94_world i1b-b)" || exit 2
trap '_t94_cleanup "$W2"' EXIT
R2="$W2/repo"; J="$W2/journal.tsv"
B1="$(git -C "$R2" rev-parse main)"
C="$(git -C "$R2" rev-parse cand)"
M1="$(bash "$SUBJ" prepare --repo "$R2" --task T-1 --base "$B1" --candidate "$C")" || exit 1
O1="$(bash "$SUBJ" object --repo "$R2" --task T-1 --target main --base "$B1" --candidate "$C" --merge "$M1")" || exit 1
_t94_verdict "$J" 1 T-1 "$O1" accept
_t94_green "$R2" "$B1" "$J" "$O1" "$M1"
M2="$(alt_merge "$R2" "$C" "$B1")" || exit 1
[ "$M2" != "$M1" ] || { printf 'КРАСНО: i1b-b: мир сломан — merge совпал с проверенным\n' >&2; exit 1; }
out="$(bash "$SUBJ" publish --repo "$R2" --task T-1 --target main --base "$B1" --candidate "$C" --merge "$M2" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'accept не этого объекта: T-1'; then
  printf 'КРАСНО: i1b-b: непринятый состав объекта опубликован (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R2" rev-parse main)" = "$B1" ] || { printf 'КРАСНО: i1b-b: отказ сдвинул main\n' >&2; exit 1; }
exit 0
