#!/usr/bin/env bash
# Контракт 190 (Л6 — замер связки): guard-обёртка над probe.py — режим передаётся
# АРГУМЕНТОМ (прецедент red_obryv_zamer_150.sh):
#   (без флага)          — rc 1 SUBJECT_ABSENT + все клетки красны поимённо
#                         (субъект scripts/zamer_svyazki.* ещё не реализован;
#                         после реализации тем же входом — суд настоящего инструмента)
#   --repo R             — суд живого дерева R
#   --model              — эталон model/zamer_model.py (контроль честности миров)
#   --stabs              — контроль + матрица обманных стабов (СВЯЗИ 8)
#   --oracle-tamper      — сверка sha256 носителей оракула (rc 2 ORACLE_TAMPERED)
# Обёртка режим не подменяет и сама ничего не печатает; движок, оракул и перечень
# клеток — probe.py и dannye/ рядом (единый источник — source.json).
# Коды возврата — коды probe.py: 0 — зелено; 1 — красная клетка либо живой стаб
# либо нет субъекта; 2 — ORACLE_TAMPERED.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
