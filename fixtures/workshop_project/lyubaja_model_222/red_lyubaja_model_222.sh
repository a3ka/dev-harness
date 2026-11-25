#!/usr/bin/env bash
# 222: real public gates; mode is an argument, never an environment override.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
