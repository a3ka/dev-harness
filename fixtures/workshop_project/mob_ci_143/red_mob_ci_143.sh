#!/usr/bin/env bash
# Контракт 143 (mob-ci-razdelenie): guard-канал §ПРОВОДКА — обёртка над
# probe.py; режим передаётся АРГУМЕНТОМ (до ленда cutover CI несёт --stabs
# явно; после ленда оркестратор переключает шаг на безфлаговый red-режим с
# --repo <корень продукта>, где отсутствие субъекта — rc 1 SUBJECT_ABSENT с
# поимённым перечнем клеток: зелень без субъекта невозможна):
#   (без флага, без --repo)  — rc 1 SUBJECT_ABSENT + все клетки красны поимённо
#   (без флага, --repo R)    — судится живой продукт R (до cutover красен)
#   --model                  эталон model/ (контроль входов)
#   --stabs                  контроль + матрица обманных стабов (SVJAZI N)
# Обёртка режим не подменяет и сама ничего не печатает; движок, оракул и
# перечень клеток — probe.py и source.json рядом (единый источник).
# Коды возврата — коды probe.py: 0 — зелено; 1 — красная клетка либо стаб
# прошёл (STAB_ZHIV) либо нет субъекта (SUBJECT_ABSENT); 2 — нечем проверять
# (нет node, ORACLE_TAMPERED, дрейф стабов/модели).
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
