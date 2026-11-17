#!/usr/bin/env bash
# Красная батарея 201 — содержательная сверка done-двери (контракт 201).
# Режимы: голый (живая дверь из корня репо), --repo <корень>, --model, --stabs.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/dver_probe.py" "$@"
