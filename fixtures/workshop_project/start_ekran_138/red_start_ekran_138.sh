#!/usr/bin/env bash
# Контракт 138 (start-ekran): guard-канал §ПРОВОДКА — обёртка над
# probe.py; режим передаётся АРГУМЕНТОМ. Рабочее самотестирование ДВУХ
# субъектов (валидатор 132 + проверка происхождения пачки) — --stabs, как
# self-test 135 (check:first-run-ekran-135-family-selftest). Безфлаговый
# режим — страж субъекта: в копии дерева без scripts/ekran_shablon.py
# даёт rc 1 SHABLON_ABSENT с перечнем входов (зелень без субъекта
# невозможна); на дереве С субъектом красен на входах происхождения —
# их судит второй субъект, не валидатор 132 (совет критика круга 1):
#   (без флага)  python3 probe.py        — red-режим: субъект судится живьём
#   --model      python3 probe.py --model — эталон 132 (контроль входов)
#   --stabs      python3 probe.py --stabs — контроль + матрица обманных
#                                           стабов (SVJAZI N)
# Обёртка режим не подменяет и сама ничего не печатает; движок, оракул и
# перечень входов — probe.py и source.json рядом (единый источник).
# Коды возврата — коды probe.py: 0 — зелено; 1 — красный вход либо стаб жив
# (STAB_ZHIV) либо нет субъекта (SHABLON_ABSENT); 2 — нечем проверить (нет
# python3, ORACLE_TAMPERED, SVERKA_123_ABSENT, набор stubs/ != stab_vhod).
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
