#!/usr/bin/env bash
# Probe-only family 228; real subject return codes are checked by probe.py.
set -euo pipefail
HERE="$(cd "${BASH_SOURCE[0]%/*}" && pwd -P)"
if [[ -z "$(type -P python3)" ]]; then
  printf '%s\n' 'NOT_IMPLEMENTED: python3 unavailable' >&2
  exit 2
fi
export PYTHONDONTWRITEBYTECODE=1
exec python3 "$HERE/probe.py" "$@"
