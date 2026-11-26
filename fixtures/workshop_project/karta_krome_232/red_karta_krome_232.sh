#!/usr/bin/env bash
# 232: standalone reference suffixes through the committed-map CLI and API.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec python3 -B "$here/probe.py" "$@"
