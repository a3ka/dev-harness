#!/usr/bin/env bash
# 217: real Git histories, bounded empty window, byte-exact compatibility.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec python3 "$here/probe.py" "$@"
