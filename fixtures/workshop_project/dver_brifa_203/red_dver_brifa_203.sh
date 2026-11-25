#!/usr/bin/env bash
# Public entrypoint; no network, all writable worlds are under TMPDIR.
set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1
exec python3 "$(dirname "$0")/probe.py" "$@"
