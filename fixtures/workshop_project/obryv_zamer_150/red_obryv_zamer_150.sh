#!/usr/bin/env bash
# Контракт 150 (prichinnyy-zamer-obryva): guard-обёртка над probe.py — режим
# передаётся АРГУМЕНТОМ (прецедент red_mob_ci_143.sh; до подключения продукта
# CI-шаг харнесса несёт --stabs явно, после ленда обёртки оркестратор
# переключает шаг на безфлаговый суд продукта с --repo <корень продукта>):
#   (без флага, без --repo)  — rc 1 SUBJECT_ABSENT + все клетки красны поимённо
#   (без флага, --repo R)    — судится живой продукт R (до реализации красен)
#   --model                  — эталон model/ (контроль входов)
#   --stabs                  — контроль + матрица обманных стабов (SVJAZI N)
#   --oracle-tamper          — порча носителей ловится ORACLE_TAMPERED rc 2
#   --seed N                 — тот же итог при другом порядке клеток
# Обёртка режим не подменяет и сама ничего не печатает; движок, оракул и
# перечень клеток — probe.py и source.json рядом (единый источник).
# Коды возврата — коды probe.py: 0 — зелено; 1 — красная клетка либо стаб
# прошёл (STAB_ZHIV) либо нет субъекта (SUBJECT_ABSENT); 2 — нечем проверять
# (нет pyyaml, ORACLE_TAMPERED, дрейф стабов).
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
