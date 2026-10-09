#!/usr/bin/env bash
# Клетка И-14 «отказ отправки тега или закрытия issue не выдаётся за полный
# done» (контракт 096, В-4). Половина (а): done/contracts/096/1 есть, но
# issue-state показывает status=open → «issue не закрыт», done-тег
# НЕ УДАЛЯЕТСЯ, отказ. Половина (б): делаем issue закрытым + project-поле
# заполнено + контрактный тег поставлен → гард зелёный, оба тега на месте
# (анти-тавтология).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: teg-bez-issue-ne-polnyj: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): контрактный тег есть, issue открыт → отказ ───────────────
W="$(_t96_world i14a)" || exit 2
trap '_t96_cleanup "$W"' EXIT
R="$W/repo"
git -C "$R" checkout -q cand
mkdir -p "$R/scripts"
for n in lint build secrets; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$R/scripts/$n.sh"
  chmod +x "$R/scripts/$n.sh"
done
printf '# CODING-STANDARDS\n' >"$R/CODING-STANDARDS.md"
printf 'code change\n' >>"$R/fixtures/_krasnye_096.sh" 2>/dev/null || true
git -C "$R" add -A && git -C "$R" commit -qm 'cand: code change'
B="$(git -C "$R" rev-parse main)"
C="$(git -C "$R" rev-parse cand)"
TREE="$(git -C "$R" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i14a: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R/registry/candidates.tsv"
HEAD="$(git -C "$R" rev-parse HEAD)"
# Контрактный тег поставлен
git -C "$R" tag -f done/contracts/096/1 "HEAD^{}"
# Issue ОТКРЫТ
ISS="https://example.com/issue/14a"
printf '%s\t%s\t%s\t%s\n' "$ISS" "open" "doneStatus" "in-progress" >>"$R/harness/issue-state.tsv"
out="$(bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --issue "$ISS" --object-id "$OID" --commit-sha "$HEAD" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'issue не закрыт: open'; then
  printf 'КРАСНО: i14a: открытый issue не отказан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
# done/contracts/096/1 НЕ удалён
git -C "$R" rev-parse --verify --quiet done/contracts/096/1 >/dev/null || {
  printf 'КРАСНО: i14a: существующий тег удалён (должен оставаться)\n' >&2; exit 1
}
exit 0

# ── половина (б): зелёный сценарий (анти-тавтология) — issue закрыт, всё есть
W2="$(_t96_world i14b)" || exit 2
trap '_t96_cleanup "$W2"' EXIT
R2="$W2/repo"
git -C "$R2" checkout -q cand
mkdir -p "$R2/scripts"
for n in lint build secrets; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$R2/scripts/$n.sh"
  chmod +x "$R2/scripts/$n.sh"
done
printf '# CODING-STANDARDS\n' >"$R2/CODING-STANDARDS.md"
printf 'code change\n' >>"$R2/fixtures/_krasnye_096.sh" 2>/dev/null || true
git -C "$R2" add -A && git -C "$R2" commit -qm 'cand: code change'
B="$(git -C "$R2" rev-parse main)"
C="$(git -C "$R2" rev-parse cand)"
TREE="$(git -C "$R2" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i14b: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R2" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R2/registry/candidates.tsv"
HEAD2="$(git -C "$R2" rev-parse HEAD)"
git -C "$R2" tag -f done/contracts/096/1 "HEAD^{}"
ISS="https://example.com/issue/14b"
printf '%s\t%s\t%s\t%s\n' "$ISS" "closed:complete" "doneStatus" "completed" >>"$R2/harness/issue-state.tsv"
out="$(bash "$SUBJ" --repo "$R2" --task 96 --class code --project-id toy \
  --issue "$ISS" --object-id "$OID" --commit-sha "$HEAD2" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i14b: зелёный сценарий не зелёный (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
