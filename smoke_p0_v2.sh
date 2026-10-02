#!/usr/bin/env bash
# Smoke test for п0: мусорный worktree + push origin main
# Mirrors what the battery does
set -uo pipefail

# Self-contained toy world
WORK=$(mktemp -d /tmp/slob.XXXXXX)
B1="$WORK/b1"
T="$WORK/t"
TREE=/tmp/dev-harness-verify/impl071r5/repo  # has all 4 check keys
WTROOT="${TMPDIR:-/tmp}/dev-harness-worktrees"

# Build bare + tree
git init -q --bare "$B1"
git init -q -b main "$T"
( cd "$TREE" && tar -cf - . ) | tar -xf - -C "$T"
cd "$T"
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false add -A
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -q -m base
git remote add origin "$B1"
git push -q origin main --tags 2>&1 || true

# Toy wrapper
TOY="$WORK/toyw"
mkdir -p "$TOY/scripts"
cp /tmp/dev-harness-verify/impl071r5/repo/scripts/gitw "$TOY/scripts/gitw"
cp /tmp/dev-harness-verify/impl071r5/repo/scripts/gitw_preflight_071.sh "$TOY/scripts/"

# Add мусорный worktree (outside $WTROOT)
git worktree add -q --detach "$WORK/slob0" main
echo "=== worktree list ==="
git worktree list --porcelain

# Try push
echo "=== push origin main ==="
env GIT_EXCHANGE_GUARD_CANONICAL="$B1" GITW_PREFLIGHT_071_API="" bash "$TOY/scripts/gitw" push origin main
RC=$?
echo "RC: $RC"
echo "=== stderr ==="
env GIT_EXCHANGE_GUARD_CANONICAL="$B1" GITW_PREFLIGHT_071_API="" bash "$TOY/scripts/gitw" push origin main 2>&1 || true
