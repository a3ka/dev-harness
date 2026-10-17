#!/usr/bin/env bash
# Direct contract-027 behavioral probe; bindings live in _doc027.py.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$HERE/fail_closed_992.py"
exec python3 "$HERE/../check_check_contract_ready/_doc027.py" lifecycle
