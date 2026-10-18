#!/usr/bin/env bash
# Scoped contract-996 acceptance; no network and no shared checkout writes.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd -P)"
exec python3 "$HERE/probe.py" "$@"
