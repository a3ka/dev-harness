#!/usr/bin/env bash
# Reference seam: installed grammar, project HEAD blob, no product replacement.
set -uo pipefail
tools=$1 root=$2 plan=$3 n=$4
source "$tools/scripts/lib_plan.sh"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
if ! git -C "$root" cat-file -p "HEAD:$plan" > "$tmp" 2>/dev/null; then
  exit 0
fi
if ! plan_parse "$tmp"; then
  printf 'план недоступен: %s\n' "$P84_PLAN_ERR" >&2
  exit 1
fi
p84_p0p1 "$root" 1
for i in "${!P84_ID[@]}"; do
  if [ "${P84_ID[$i]}" = "$n" ] && { [ "${P84_PAIR[$i]}" = "$P84_P0" ] || [ "${P84_PAIR[$i]}" = "$P84_P1" ]; }; then
    exit 0
  fi
done
printf 'контракт вне плана: %s\n' "$n" >&2
exit 1
