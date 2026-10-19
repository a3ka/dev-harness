#!/usr/bin/env bash
# 998: красный прогонатель пробы правил моделей. До предмета rc 1 (названные
# причины), на собранном дереве rc 0; обманные реализации различимы матрицей.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec python3 "$HERE/probe.py" --cases
