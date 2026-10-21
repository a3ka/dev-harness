#!/usr/bin/env bash
# guard_model.sh — ЧЕСТНАЯ МОДЕЛЬ гварда весов (контракт 114; реализация
# implementer — scripts/check_ci_weights.sh с той же грамматикой).
#   bash guard_model.sh [--root <dir>]
# Судит <dir>/registry/ci-steps.tsv против <dir>/registry/ci-zamery.tsv:
# г1 покрытие → г2 расхождение > 3× (двусторонне) → г3 свежесть ≤ 30 дней
# (git log по пути TSV). rc 0 — зелёное НЕМОЛЧАЛИВОЕ (ok-строка с числом
# ключей); rc 1 — именованный отказ; rc 2 — нет инструмента/входа.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$HERE/vesa_lib.py" guard "$@"
