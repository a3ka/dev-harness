#!/usr/bin/env bash
# Контракт 212 (REPLACE строки реестра после ленда PR): guard-канал §ПРОВОДКА —
# обёртка над probe212.py; режим передаётся АРГУМЕНТОМ (до ленда реализации CI
# несёт --model/--stabs/--sintaksis; после ленда оркестратор переключает шаг
# на безфлаговый red-режим):
#   (без флага) / --repo <корень> — субъект = scripts/replace_line.sh дерева:
#         до реализации rc 1 с перечнем красных клеток; нет субъекта —
#         rc 1 SUBJECT_ABSENT (зелень без субъекта невозможна)
#   --model  — эталон model/replace_line.sh (контроль входов)
#   --stabs  — контроль + матрица обманных стабов (SVJAZI N, живых 0)
# Обёртка режим не подменяет и итог не печатает: итог — код возврата probe212.py.
# Коды возврата: 0 — зелено; 1 — красная клетка либо STAB_ZHIV либо субъекта
# нет; 2 — нечем проверять (нет git/bash/python3/двери, ORACLE_TAMPERED).
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe212.py" "$@"
