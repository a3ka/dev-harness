#!/usr/bin/env bash
# Контракт 149 (gespraech-tekst-chat): guard-канал §ПРОВОДКА — обёртка над
# probe.py; режим передаётся АРГУМЕНТОМ (до ленда реализации CI несёт
# --stabs явно; после ленда оркестратор переключает шаг на безфлаговый
# red-режим: валидатор v3 в scripts/ и субъект в продукте дают зелень):
#   (без флага)  живое дерево: валидатор scripts/ekran_shablon.py (v3 в
#                main) против эталона на мирах пачки; машина/пачка в
#                продукте — клетки m-*/s-* красны поимённо до реализации
#                (SUBJECT_ABSENT: зелень без субъекта невозможна)
#   --model      эталон (контроль входов)
#   --stabs      контроль + обманные стабы (SVJAZI N, живых 0)
#   --repo R     живой продукт R (машина/канон/пачка)
#   --oracle-tamper  порча каждого носителя — ORACLE_TAMPERED rc 2
#   --seed N     seed сеяных входов (право судьи — перезапуск)
# Обёртка режим не подменяет и сама ничего не печатает; движок, оракул и
# перечень клеток — probe.py/source.json/osi.md рядом (единый источник).
# Самодостаточна: python + node, без сети/omp/эмулятора.
# Коды возврата — коды probe.py: 0 — зелено; 1 — красная клетка/живой
# стаб/нет субъекта; 2 — ORACLE_TAMPERED/рассинхрон/нечем проверять.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
command -v node >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет node' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
