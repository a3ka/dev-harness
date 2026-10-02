#!/usr/bin/env bash
# Trace п5в scenario: $WTROOT-slob/wt with branch wip/071/wtf
set -uo pipefail

WORK=$(mktemp -d /tmp/slob.XXXXXX)
B1="$WORK/b1"
T="$WORK/t"
TREE=/tmp/dev-harness-verify/impl071r5/repo
WTROOT="${TMPDIR:-/tmp}/dev-harness-worktrees"
GITW=/tmp/dev-harness-verify/impl071r5/repo/scripts/gitw

# Build bare + tree
git init -q --bare "$B1"
git init -q -b main "$T"
( cd "$TREE" && tar -cf - . ) | tar -xf - -C "$T"
cd "$T"
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false add -A
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -q -m base
git remote add origin "$B1"
git push -q origin main --tags 2>&1 || true

# SANCTIONED worktree (from mk_world)
mkdir -p "$WTROOT/abc12345"
git worktree add -q -b wip/071/wtx "$WTROOT/abc12345/wt" main

# MYSORNY worktree at $WTROOT-slob/wt with branch wip/071/wtf
mkdir -p "$WTROOT-slob"
git worktree add -q -b wip/071/wtf "$WTROOT-slob/wt" main

echo "=== worktree list ==="
git worktree list --porcelain

echo "=== push ==="
GIT_EXCHANGE_GUARD_CANONICAL="$B1" bash "$GITW" push origin main 2>&1
RC=$?
echo "rc=$RC"

# Cleanup
git worktree remove --force "$WTROOT/abc12345/wt" 2>/dev/null
git worktree remove --force "$WTROOT-slob/wt" 2>/dev/null
git branch -D wip/071/wtx wip/071/wtf 2>/dev/null
rmdir "$WTROOT/abc12345" 2>/dev/null
rmdir "$WTROOT-slob" 2>/dev/null
rmdir "$WTROOT-slob/wt" 2>/dev/null
