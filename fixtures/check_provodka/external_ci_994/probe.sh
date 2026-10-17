#!/usr/bin/env bash
# Локальная приёмка 994: реальный CLI, прежняя семья, обманные формы и CI-проводка.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec python3 "$HERE/probe.py" "$@"
