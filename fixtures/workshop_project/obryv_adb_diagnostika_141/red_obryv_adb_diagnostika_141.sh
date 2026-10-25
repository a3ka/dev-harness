#!/usr/bin/env bash
# Контракт 141 (obryv-adb-diagnostika): guard-канал §ПРОВОДКА — обёртка над
# probe.py; режим передаётся АРГУМЕНТОМ (до ленда реализации CI несёт --stabs
# явно; после ленда оркестратор переключает шаг на безфлаговый red-режим с
# --repo <корень продукта>, где отсутствие правки шагов 135/118/995 даёт
# rc 1 с красным перечнем входов — зелень без субъекта невозможна):
#   (без флага, без --repo/MOB_REPO)  — rc 1 SUBJECT_ABSENT + красные
#   (без флага, --repo R | MOB_REPO)   — судится живой .github/workflows/
#                                        mobile.yml продукта (тела шагов
#                                        135/118/995 против модели)
#   --model      эталон model/mobile.yml (контроль входов)
#   --stabs      контроль + матрица обманных стабов (SVJAZI N)
# Обёртка режим не подменяет и сама ничего не печатает; движок, оракул и
# перечень входов — probe.py и source.json рядом (единый источник).
# Коды возврата — коды probe.py: 0 — зелено; 1 — красный кейс либо стаб
# прошёл (STAB_ZHIV) либо нет субъекта (SUBJECT_ABSENT); 2 — нечем проверить
# (нет python3/pyyaml, ORACLE_TAMPERED, дрейф стабов/модели).
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
