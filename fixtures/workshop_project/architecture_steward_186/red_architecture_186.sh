#!/usr/bin/env bash
set -uo pipefail
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel) || exit 2
case "${1-}" in
  --model|--stabs) args=("$1") ;;
  --repo)
    if [ "$#" -ne 2 ]; then exit 2; fi
    args=(--repo "$2")
    ;;
  *) printf '%s\n' 'USAGE: red_architecture_186.sh --model|--stabs|--repo <root>' >&2; exit 2 ;;
esac
rc=0
python3 "$root/fixtures/workshop_project/architecture_steward_186/probe.py" "${args[@]}" || rc=1
python3 "$root/fixtures/workshop_project/architecture_steward_186/door_probe.py" "${args[@]}" || rc=1
exit "$rc"
