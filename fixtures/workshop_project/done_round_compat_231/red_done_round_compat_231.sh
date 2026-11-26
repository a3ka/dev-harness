#!/usr/bin/env bash
# 231: compatibility at the existing public done CLI.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec python3 -B "$here/probe.py" "$@"
