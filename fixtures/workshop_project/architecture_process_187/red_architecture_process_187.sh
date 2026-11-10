#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "${1:-}" = --wiring ]; then
  [ "$#" -eq 2 ] || { printf 'usage: %s --wiring ROOT\n' "$0" >&2; exit 2; }
  PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/ci_wiring.py" "$2"
fi
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/workflow_probe.py" "$@"
