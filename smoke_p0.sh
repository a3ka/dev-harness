#!/usr/bin/env bash
# Smoke test for п0: мусорный worktree + push origin main
set -uo pipefail

WORK=$(mktemp -d /tmp/slob.XXXXXX)
B1=$(mktemp -d /tmp/b1.XXXXXX)
T=$(mktemp -d /tmp/t.XXXXXX)
git init --quiet --bare "$B1" 2>/dev/null
git init --quiet "$T"
cd "$T"
git config user.name t
git config user.email t@t.local
git config commit.gpgsign false
echo "x" > README
git add README
git commit -m initial --quiet
git remote add origin "$B1"
git push origin main --quiet 2>&1 || true

# Toy wrapper
TOY="$WORK/toyw"
mkdir -p "$TOY/scripts"
cp /tmp/dev-harness-verify/impl071r5/repo/scripts/gitw "$TOY/scripts/gitw"
cp /tmp/dev-harness-verify/impl071r5/repo/scripts/gitw_preflight_071.sh "$TOY/scripts/"

# Add a мусорный worktree (outside sanctioned root)
git worktree add -q --detach "$WORK/slob0" main

# Try push
echo "=== Try push ==="
env GIT_EXCHANGE_GUARD_CANONICAL="$B1" bash "$TOY/scripts/gitw" push origin main
RC=$?
echo "RC: $RC"
echo "=== stderr (gitw output) ==="
