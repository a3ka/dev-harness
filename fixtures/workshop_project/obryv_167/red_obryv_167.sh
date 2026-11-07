#!/usr/bin/env bash
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
mode="${1:---repo}"
case "$mode" in --repo|--model|--stabs) ;; *) exit 2 ;; esac
python3 "$here/probe.py" "$mode"
a=$?
python3 "$here/merge_probe.py" "$mode"
b=$?
if [ "$a" -eq 0 ] && [ "$b" -eq 0 ]; then exit 0; fi
exit 1
