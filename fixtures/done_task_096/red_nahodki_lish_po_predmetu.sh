#!/usr/bin/env bash
# Клетка И-6 «открытые находки ТОЛЬКО по предмету — вне ЗОНА-контракта
# НЕ блокирует (слово владельца: «весь backlog ≠ блокировка»)» (контракт
# 096, П-6). Половина (а): .review/subject.md со `status: ready` В
# ЗОНА-префиксе → блок «открытая находка по предмету». Половина (б):
# .review/other-team-backlog.md со `status: ready` ВНЕ ЗОНА — НЕ блокирует
# (success).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: nahodki-lish-po-predmetu: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): блокирующая находка в ЗОНА → отказ ───────────────────────
W="$(_t96_world i6a)" || exit 2
trap '_t96_cleanup "$W"' EXIT
R="$W/repo"
git -C "$R" checkout -q cand
mkdir -p "$R/scripts" "$R/.review" "$R/docs/external"
for n in lint build secrets; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$R/scripts/$n.sh"
  chmod +x "$R/scripts/$n.sh"
done
printf '# CODING-STANDARDS\n' >"$R/CODING-STANDARDS.md"
cat >"$R/.review/scripts-done_project.md" <<'NF'
# находка по предмету — имя scripts-done_project → ЗОНА scripts/
status: ready
NF
git -C "$R" add -A && git -C "$R" commit -qm 'cand: code + finding'
B="$(git -C "$R" rev-parse main)"
C="$(git -C "$R" rev-parse cand)"
TREE="$(git -C "$R" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i6a: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R/registry/candidates.tsv"
HEAD="$(git -C "$R" rev-parse HEAD)"
out="$(bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --issue https://example.com/issue/096 --object-id "$OID" --commit-sha "$HEAD" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'открытая находка по предмету'; then
  printf 'КРАСНО: i6a: блокирующая находка не отказана (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
_t96_cleanup "$W"

# ── половина (б): чужой backlog НЕ блокирует (зелёный) ──────────────────────
W2="$(_t96_world i6b)" || exit 2
trap '_t96_cleanup "$W2"' EXIT
R2="$W2/repo"
git -C "$R2" checkout -q cand
mkdir -p "$R2/scripts"
for n in lint build secrets; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$R2/scripts/$n.sh"
  chmod +x "$R2/scripts/$n.sh"
done
printf '# CODING-STANDARDS\n' >"$R2/CODING-STANDARDS.md"
# Чужая находка ВНЕ зон контракта (ЗОНА-stroki: scripts/* | fixtures/* | ...)
cat >"$R2/.review/docs-external.md" <<'NF'
# чужая находка вне зоны
status: ready
NF
git -C "$R2" add -A && git -C "$R2" commit -qm 'cand: code + outside finding'
B="$(git -C "$R2" rev-parse main)"
C="$(git -C "$R2" rev-parse cand)"
TREE="$(git -C "$R2" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i6b: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R2" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R2/registry/candidates.tsv"
HEAD2="$(git -C "$R2" rev-parse HEAD)"
out="$(bash "$SUBJ" --repo "$R2" --task 96 --class code --project-id toy \
  --issue https://example.com/issue/096 --object-id "$OID" --commit-sha "$HEAD2" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i6b: чужой backlog не должен блокировать (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
