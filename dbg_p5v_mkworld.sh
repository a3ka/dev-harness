#!/usr/bin/env bash
# Trace п5в: mk_world then add the мусорный worktree
set -uo pipefail

WORK=$(mktemp -d /tmp/gitw071.XXXXXX)
B1="$WORK/p5v/b1"
T="$WORK/p5v/t"
TREE=/tmp/dev-harness-verify/impl071r5/repo
WTROOT="${TMPDIR:-/tmp}/dev-harness-worktrees"

# === mk_world p5v ===
git init -q --bare "$B1"
git init -q -b main "$T"
( cd "$TREE" && tar -cf - . ) | tar -xf - -C "$T"
cd "$T"
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false add -A
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -q -m base
while IFS= read -r r; do
  git tag "${r#refs/tags/}" "$(git rev-parse HEAD)" 2>/dev/null || true
done < <(git -C "$TREE" for-each-ref --format='%(refname)' refs/tags)
git tag frozen/contracts/099/1 2>/dev/null || git tag -f frozen/contracts/099/1
git tag done/contracts/098/1 2>/dev/null || true
git remote add origin "$B1"
git push -q origin main --tags 2>&1 || true
# land-merge
git checkout -q -b wip/071/demo
printf "demo\n" > demo.txt
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false add demo.txt
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -q -m work
git checkout -q main
git -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false merge --no-ff -q -m "land: wip/071/demo" wip/071/demo
# sanctioned worktree
local_w="$WTROOT/abc12345"; mkdir -p "$local_w"
git worktree add -q -b wip/071/wtx "$local_w/wt" main

echo "=== worktree list after mk_world ==="
git -C "$T" worktree list --porcelain

# === п5в: add мусорный worktree ===
mkdir -p "$WTROOT-slob"
git -C "$T" worktree add -q -b wip/071/wtf "$WTROOT-slob/wt" main >/dev/null 2>&1
RC=$?
echo "rc of worktree add: $RC"
echo "=== worktree list after п5в add ==="
git -C "$T" worktree list --porcelain

# === run push (preflight + gitw) ===
echo "=== preflight call ==="
GIT_EXCHANGE_GUARD_CANONICAL="$B1" bash /tmp/dev-harness-verify/impl071r5/repo/scripts/gitw_preflight_071.sh "$B1" --pf-ctx-n 0 --pf-cfg-n 0 push origin main
RC2=$?
echo "preflight rc=$RC2"
