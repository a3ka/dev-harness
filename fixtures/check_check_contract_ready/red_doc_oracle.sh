#!/usr/bin/env bash
# Direct contract-027 probe; --self-test exercises real mutators in/out of isolation.
# Н-39 bindings and pre-mutation snapshot assertions live in _doc027.py.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$HERE/../check_check_contract_ready/_doc027.py" oracle "$@"
