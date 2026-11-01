#!/usr/bin/env bash
# Контракт 152 (oom-sessii-i-zamki): guard-обёртка над probe.py — режим
# передаётся АРГУМЕНТОМ (прецедент red_obryv_zamer_150.sh):
#   (без флага, без --repo)  — rc 1: субъект = дерево харнесса, носителей 152
#                              нет → клетки A/B красны SUBJECT_ABSENT, C/D —
#                              честный прогон поставленных zamok/orch-loop
#                              (веток pogib/факта OOM нет → красны)
#   (без флага, --repo R)    — судится дерево R (после ленда зелено)
#   --model                  — эталон model/ (контроль входов)
#   --stabs                  — контроль + матрица обманных стабов (SVJAZI N)
#   --oracle-tamper          — порча носителей ловится: ORACLE_TAMPER_PROVERENO
#   --seed N                 — тот же итог при другом порядке клеток
# Обёртка режим не подменяет и сама ничего не печатает; движок, оракул и
# перечень клеток — probe.py и source.json рядом (единый источник).
# Коды возврата — коды probe.py: 0 — зелено; 1 — красная клетка либо живой
# стаб (STAB_ZHIV) либо SUBJECT_ABSENT; 2 — нечем проверять / ORACLE_TAMPERED.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
