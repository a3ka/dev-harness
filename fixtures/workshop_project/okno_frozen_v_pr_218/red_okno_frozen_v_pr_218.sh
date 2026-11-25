#!/usr/bin/env bash
# 218: real Git branch windows and addressed mutations.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec python3 "$here/probe.py" "$@"
