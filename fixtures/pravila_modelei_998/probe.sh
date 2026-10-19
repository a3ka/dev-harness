#!/usr/bin/env bash
# 998 pravila-modelei: правила моделей в одном месте — красная проба.
# rc 0: ожидания совпали; 1: расхождение; 2: нет входа.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
if [ "$#" -gt 0 ]; then
  exec python3 "$HERE/probe.py" "$@"
fi
python3 "$HERE/probe.py" --cases || exit "$?"
exec python3 "$HERE/probe.py" --matrix
