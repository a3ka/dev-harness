#!/usr/bin/env bash
set -u
HERE="$(cd -- "${BASH_SOURCE[0]%/*}" && pwd -P)" || exit 2
if ! command -v python3 >/dev/null 2>&1; then
  printf 'NOT_IMPLEMENTED: python3 unavailable\n' >&2
  exit 2
fi
PYTHONDONTWRITEBYTECODE=1 python3 "$HERE/probe.py" "$@"
exit $?
