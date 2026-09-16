#!/usr/bin/env bash
# Direct contract-027 probe; --self-test exercises honest/weak renderer controls.
# Н-39 bindings and independent formal-content oracle live in _doc027.py.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$HERE/../check_check_contract_ready/_doc027.py" status_render "$@"
