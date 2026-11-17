#!/usr/bin/env bash
# Безаргументный вход — тот же предметный прогон, что и «--repo <корень харнесса>»:
# раннер обязан исполнить клетки и напечатать итог (К-07), а не выйти молча до проб.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(cd "$here/../../.." && pwd -P)"
case "${1:---repo}" in
  --repo) python3 "$here/probe.py" --repo "${2:-$root}" ;;
  --model) python3 "$here/probe.py" --model ;;
  --stabs) python3 "$here/probe.py" --stabs ;;
  *) printf 'NOT_IMPLEMENTED: invalid mode\n' >&2; exit 2 ;;
esac
