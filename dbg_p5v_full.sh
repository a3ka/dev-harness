#!/usr/bin/env bash
# Trace п5в scenario with full mk_world setup
set -uo pipefail

WORK=$(mktemp -d /tmp/gitw071.XXXXXX)
B1="$WORK/p5v/b1"
T="$WORK/p5v/t"
TREE=/tmp/dev-harness-verify/impl071r5/repo
WTROOT="${TMPDIR:-/tmp}/dev-harness-worktrees"

# Build world (similar to mk_world p5v)
git init -q --bare "$B1"
git init -q -b main "$T"
( cd "$TREE" && tar -cf - . ) | tar -xf - -C "$T"
cd "$T"
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false add -A
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -q -m base
while IFS= read -r r; do
  git tag "${r#refs/tags/}" "$(git rev-parse HEAD)" 2>/dev/null || true
done < <(git -C "$TREE" for-each-ref --format='%(refname)' refs/tags)
git remote add origin "$B1"
git push -q origin main --tags 2>&1 || true

# Sanctioned worktree
mkdir -p "$WTROOT/abc12345"
git worktree add -q -b wip/071/wtx "$WTROOT/abc12345/wt" main

# MYSORNY worktree (the one п5в adds)
mkdir -p "$WTROOT-slob"
git worktree add -q -b wip/071/wtf "$WTROOT-slob/wt" main

echo "=== worktree list ==="
git worktree list --porcelain

# Now run the preflight
echo "=== preflight call ==="
GIT_EXCHANGE_GUARD_CANONICAL="$B1" bash /tmp/dev-harness-verify/impl071r5/repo/scripts/gitw_preflight_071.sh "$B1" --pf-ctx-n 0 --pf-cfg-n 0 push origin main
RC=$?
echo "RC=$RC"
