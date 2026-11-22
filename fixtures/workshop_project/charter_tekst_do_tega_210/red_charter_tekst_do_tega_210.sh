#!/usr/bin/env bash
# 210: реальные git-миры; --repo ROOT, --model, --stabs.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec python3 "$here/probe.py" "$@"
