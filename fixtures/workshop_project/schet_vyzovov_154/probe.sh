#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd -P)"
case "${1:-}" in
  '')     exec python3 "$HERE/probe.py" repo ;;
  --repo) exec python3 "$HERE/probe.py" repo ;;
  --model) exec python3 "$HERE/probe.py" model ;;
  --stabs) exec python3 "$HERE/probe.py" stabs ;;
  --domain) exec python3 "$HERE/probe.py" domain ;;
  --domain-model) exec python3 "$HERE/probe.py" domain-model ;;
  *) printf 'NOT_IMPLEMENTED: unknown mode: %s\n' "$1" >&2; exit 2 ;;
esac
