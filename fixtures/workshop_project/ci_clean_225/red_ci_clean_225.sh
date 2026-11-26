#!/usr/bin/env bash
# 225: --repo R | --model | --stabs | --sintaksis | --catalog.
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export PYTHONDONTWRITEBYTECODE=1
exec python3 "$HERE/probe.py" "$@"
