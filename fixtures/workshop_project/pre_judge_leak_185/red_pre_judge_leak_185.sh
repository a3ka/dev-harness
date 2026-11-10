#!/usr/bin/env bash
set -u

if ! command -v python3 >/dev/null 2>&1; then
  printf 'NOT_IMPLEMENTED: python3 is required\n' >&2
  exit 2
fi

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
PYTHONDONTWRITEBYTECODE=1 python3 "$HERE/probe.py" "$@"
