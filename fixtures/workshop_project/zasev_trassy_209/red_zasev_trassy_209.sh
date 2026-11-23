#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
if [ "$#" -eq 0 ]; then
  exec python3 "$here/probe.py" --repo "$(cd "$here/../../.." && pwd -P)"
fi
case "$1" in
  --repo) [ "$#" -eq 2 ] || { printf 'NOT_IMPLEMENTED: --repo требует корень\n' >&2; exit 2; } ;;
  --model|--stabs) [ "$#" -eq 1 ] || { printf 'NOT_IMPLEMENTED: лишний аргумент\n' >&2; exit 2; } ;;
  *) printf 'NOT_IMPLEMENTED: неизвестный режим\n' >&2; exit 2 ;;
esac
exec python3 "$here/probe.py" "$@"
