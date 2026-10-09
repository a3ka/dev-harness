#!/usr/bin/env bash
# Клетка И-8 «issue и проектные поля» (контракт 096, П-8). Половина (а):
# issue-state с status=open (не closed) → «issue не закрыт: open».
# Половина (б): issue-state с status=closed, но project-поле НЕ
# заполнено (отсутствует) → «project-поле не заполнено». Чужая половина —
# зелёный (issue закрыт, поле заполнено как doneStatus=completed).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: issue-i-proektnaya-polya: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): issue не закрыт → отказ ───────────────────────────────────
W="$(_t96_world i8a)" || exit 2
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
TREE="$(git -C "$R" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i8a: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R/registry/candidates.tsv"
ISS="https://example.com/issue/8a"
printf '%s\t%s\t%s\t%s\n' "$ISS" "open" "doneStatus" "completed" >>"$R/harness/issue-state.tsv"
HEAD="$(git -C "$R" rev-parse HEAD)"
out="$(bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --issue "$ISS" --object-id "$OID" --commit-sha "$HEAD" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'issue не закрыт: open'; then
  printf 'КРАСНО: i8a: открытый issue не отказан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
_t96_cleanup "$W"

# ── половина (б): поле не заполнено → отказ ─────────────────────────────────
W2="$(_t96_world i8b)" || exit 2
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
TREE="$(git -C "$R2" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i8b: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R2" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R2/registry/candidates.tsv"
ISS="https://example.com/issue/8b"
# closed, но БЕЗ project-поля: пустое значение
printf '%s\t%s\t%s\t%s\n' "$ISS" "closed:complete" "" "" >>"$R2/harness/issue-state.tsv"
HEAD2="$(git -C "$R2" rev-parse HEAD)"
out="$(bash "$SUBJ" --repo "$R2" --task 96 --class code --project-id toy \
  --issue "$ISS" --object-id "$OID" --commit-sha "$HEAD2" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'project-поле не заполнено'; then
  printf 'КРАСНО: i8b: project-поле не отказано (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
