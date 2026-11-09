#!/usr/bin/env bash
# Every named input is checked independently; the default CI route also proves the model and mutants.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
case "${1:-}" in
  --repo|--model|--stabs) exec python3 "$here/probe.py" "$1" ;;
  '') python3 "$here/probe.py" --repo
      python3 "$here/probe.py" --model
      python3 "$here/probe.py" --stabs ;;
  *) printf 'usage: %s [--repo|--model|--stabs]\n' "$0" >&2; exit 2 ;;
esac
