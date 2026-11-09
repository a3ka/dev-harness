#!/usr/bin/env bash
# НЕ БАРЬЕР: red-фаза контрактной пробы 175; субъект — ops/server/user/orch-tablo.
# Коды возврата: 0 — выбранная проверка зелена, 1 — расхождение, 2 — неисполнимый вход.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$HERE/probe.py" "$@"
