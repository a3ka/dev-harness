#!/usr/bin/env bash
# B-13, subject 992: full check_ci_gate (both modes) and preflight land CLI.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$HERE/b13_token.py" "$@"
