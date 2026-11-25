#!/usr/bin/env bash
# 219: exact accounting paths through the real classifier CLI and Git trees.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec python3 "$here/probe.py" "$@"
