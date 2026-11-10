#!/usr/bin/env bash
# 170: product, honest control, independent deceptive subjects.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(cd "$here/../../.." && pwd -P)"
mode="${1:---all}"
case "$mode" in --all|--repo|--model|--stabs) ;; *) printf 'NOT_IMPLEMENTED: mode %s\n' "$mode" >&2; exit 2 ;; esac
rc=0
if [ "$mode" = --all ] || [ "$mode" = --repo ]; then
  python3 "$here/probe.py" --repo "${2:-$root}" || rc=1
fi
if [ "$mode" = --all ] || [ "$mode" = --model ]; then
  python3 "$here/probe.py" --model || rc=1
fi
if [ "$mode" = --all ] || [ "$mode" = --stabs ]; then
  python3 "$here/probe.py" --stabs || rc=1
fi
exit "$rc"
