#!/usr/bin/env bash
# 997: direct behavioral probe, never invokes real station systemd/omp.
# rc 0: expectations met; 1: mismatch; 2: unavailable/invalid input.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
if [ "$#" -gt 0 ]; then
  exec python3 "$HERE/probe.py" "$@"
fi
python3 "$HERE/probe.py" --cases || exit "$?"
exec python3 "$HERE/probe.py" --matrix
