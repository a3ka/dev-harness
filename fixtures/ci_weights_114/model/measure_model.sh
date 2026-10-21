#!/usr/bin/env bash
# measure_model.sh — ЧЕСТНАЯ МОДЕЛЬ скрипта замера (контракт 114; реализация
# implementer — scripts/measure_ci_weights.sh той же грамматики). Два режима:
# корпус --logs и сетевой (без --logs): gh api ТОЛЬКО через PATH — клетка т17
# судит его против источника-двойника gh_dvoynik/gh (круг 2, Б1).
#   bash measure_model.sh --root <dir> --logs <dir> --out <TSV> \
#        [--min-obs N] [--okno <run-id>]
#   bash measure_model.sh --root <dir> --repo <o>/<r> [--out <TSV>] \
#        [--min-obs N] [--runs N]      (сеть; окно = старейший run-id)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$HERE/vesa_lib.py" measure "$@"
