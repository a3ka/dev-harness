#!/usr/bin/env bash
# Коды возврата: 0 — проверка проектной раскладки зелёная, 1 — именованное нарушение,
# 2 — NOT_IMPLEMENTED: батарея ещё не установлена; до implementation дверь красная.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
if [ ! -f "$HERE/probe.py" ]; then
  printf 'NOT_IMPLEMENTED: батарея проектной раскладки 161 ещё не установлена: %s/probe.py\n' "$HERE" >&2
  exit 2
fi
exec python3 "$HERE/probe.py" "$@"
