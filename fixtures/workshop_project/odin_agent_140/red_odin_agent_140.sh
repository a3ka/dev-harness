#!/usr/bin/env bash
# Контракт 140 (odin-agent-na-predmet): guard-канал §ПРОВОДКА — обёртка над
# probe.py; режим передаётся АРГУМЕНТОМ (до ленда реализации CI несёт --stabs
# явно; после ленда оркестратор переключает шаг на безфлаговый red-режим,
# где отсутствие субъекта даёт rc 1 SUBJECT_ABSENT с перечнем входов —
# зелень без субъекта невозможна):
#   (без флага)  — rc 1 SUBJECT_ABSENT + красные (перечень всех входов)
#   --model      — эталон model/zamok_predmeta.sh (контроль входов)
#   --stabs      — контроль + матрица обманных стабов (SVJAZI N, живых 0)
# Обёртка режим не подменяет и сама ничего не печатает; движок, оракул и
# перечень входов — probe.py и source.json рядом (единый источник).
# Коды возврата — коды probe.py: 0 — зелено; 1 — красный кейс либо стаб
# прошёл (STAB_ZHIV) либо субъекта нет (SUBJECT_ABSENT); 2 — нечем проверить
# (нет git/jq/bash, ORACLE_TAMPERED, дрейф стабов/модели).
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
