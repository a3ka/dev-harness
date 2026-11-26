#!/usr/bin/env bash
# БАРЬЕР-ГУАРД: 214, реальный --sudit и доверенный снимок риска.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec python3 -B "$here/probe.py" "$@"
