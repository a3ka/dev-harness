#!/usr/bin/env bash
# 204: реальные двери 193 и выбранная библиотека; --repo ROOT, --model, --stabs.
# Данные миров и ожидания принадлежат probe.py, а не проверяемой библиотеке.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec python3 "$here/probe.py" "$@"
