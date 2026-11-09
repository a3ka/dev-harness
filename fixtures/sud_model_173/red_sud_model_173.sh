#!/usr/bin/env bash
# 173: public check_sud_model CLI, pinned honest control and code-tied impostors.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(cd "$here/../.." && pwd -P)"
mode="${1:---all}"
case "$mode" in --all|--repo|--model|--stabs) ;; *) printf 'NOT_IMPLEMENTED: mode %s\n' "$mode" >&2; exit 2 ;; esac
if [ "$mode" = --all ] || [ "$mode" = --repo ]; then
  python3 "$here/probe.py" --repo "$root"
fi
if [ "$mode" = --all ] || [ "$mode" = --model ]; then
  python3 "$here/probe.py" --model
fi
if [ "$mode" = --all ] || [ "$mode" = --stabs ]; then
  python3 "$here/probe.py" --stabs
fi
