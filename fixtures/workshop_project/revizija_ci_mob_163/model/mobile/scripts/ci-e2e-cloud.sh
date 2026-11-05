#!/usr/bin/env bash
set -euo pipefail
bash mobile/scripts/ci-maestro-version.sh
printf '991\n' >> "$CI163_MARKER"
