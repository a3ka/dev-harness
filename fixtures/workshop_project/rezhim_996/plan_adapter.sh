#!/usr/bin/env bash
# Reference seam for the 996 plan gate (arbiter П1а, K6).
# From the installed lib_plan we take ONLY the plan grammar: plan_parse and the
# P84_ID/P84_PAIR arrays. The closure source is the seam modelled for package C:
# HEAD:<workflowPaths.registry>/closed-without-done.tsv of the PROJECT profile.
# The root registry/closed-without-done.tsv decoy is never read, neither here
# nor through lib_plan plan_status/p84_p0p1 (which hardcode the root registry).
# P0/P1 below re-derive the same pair selection as p84_p0p1 over the profile
# closure blob: an id whose done tag exists or that is listed closed is skipped.
set -uo pipefail
tools=$1 root=$2 plan=$3 n=$4
source "$tools/scripts/lib_plan.sh"
mutant=${MUTANT_996:-}
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
if [ "$mutant" = worktree-plan ]; then
  # Decoy: plan membership read from the working tree, not the HEAD blob.
  cp "$root/$plan" "$tmp" 2>/dev/null || exit 0
elif ! git -C "$root" cat-file -p "HEAD:$plan" > "$tmp" 2>/dev/null; then
  exit 0
fi
if ! plan_parse "$tmp"; then
  printf 'план недоступен: %s\n' "$P84_PLAN_ERR" >&2
  exit 1
fi
closures="$(dirname "$plan")/closed-without-done.tsv"
if [ "$mutant" = root-closures ]; then
  # Decoy: closures taken from the root registry instead of the profile blob.
  closures='registry/closed-without-done.tsv'
fi
closed_ids="$(git -C "$root" cat-file -p "HEAD:$closures" 2>/dev/null | awk -F'\t' '{print $1}' || true)"

plan_open() {
  local id="$1"
  if git -C "$root" for-each-ref --format='%(refname)' \
      "refs/tags/done/contracts/${id}/" 2>/dev/null | grep -q .; then
    return 1
  fi
  if [ -n "$closed_ids" ] && printf '%s\n' "$closed_ids" | grep -Fxq "$id"; then
    return 1
  fi
  return 0
}

p0='' p1=''
for i in "${!P84_ID[@]}"; do
  plan_open "${P84_ID[$i]}" || continue
  pp="${P84_PAIR[$i]}"
  if [ -z "$p0" ] || [ "$pp" -lt "$p0" ]; then p0="$pp"; fi
done
if [ -n "$p0" ]; then
  for i in "${!P84_ID[@]}"; do
    plan_open "${P84_ID[$i]}" || continue
    pp="${P84_PAIR[$i]}"
    [ "$pp" -gt "$p0" ] || continue
    if [ -z "$p1" ] || [ "$pp" -lt "$p1" ]; then p1="$pp"; fi
  done
fi
for i in "${!P84_ID[@]}"; do
  if [ "${P84_ID[$i]}" = "$n" ] && { [ "${P84_PAIR[$i]}" = "$p0" ] || [ "${P84_PAIR[$i]}" = "$p1" ]; }; then
    exit 0
  fi
done
printf 'контракт вне плана: %s\n' "$n" >&2
exit 1
