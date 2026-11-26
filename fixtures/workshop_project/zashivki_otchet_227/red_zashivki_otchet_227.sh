#!/usr/bin/env bash
# 227 report-only CI: real Git worlds, honest control, addressed mutations.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec python3 -B "$here/probe.py" "$@"
