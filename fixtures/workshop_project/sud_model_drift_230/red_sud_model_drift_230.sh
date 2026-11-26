#!/usr/bin/env bash
# Коды возврата: 0 — клетки зелены/живых мутантов нет; 1 — предмет красен;
# 2 — NOT_IMPLEMENTED: нет среды, пина или валидного носителя.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$HERE/probe.py" "$@"
