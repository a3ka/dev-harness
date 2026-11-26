#!/usr/bin/env bash
# 223: full done CLI, real Git merge deltas and addressed service-path mutants.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec python3 -B "$here/probe.py" "$@"
