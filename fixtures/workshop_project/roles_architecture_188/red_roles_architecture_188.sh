#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
case "${1:---repo}" in
  --repo) shift; python3 "$here/probe.py" --repo "${1:-$(cd "$here/../../.." && pwd -P)}" ;;
  --model) python3 "$here/probe.py" --model ;;
  --stabs) python3 "$here/probe.py" --stabs ;;
  *) printf 'NOT_IMPLEMENTED: invalid mode\n' >&2; exit 2 ;;
esac
