#!/usr/bin/env bash
# Контракт 145 (faden-dvizok): guard-канал §ПРОВОДКА — обёртка над probe.py;
# режим передаётся АРГУМЕНТОМ (до ленда реализации CI несёт --stabs явно;
# после ленда оркестратор переключает шаг на безфлаговый red-режим с
# --repo <корень продукта>, где отсутствие субъекта — rc 1 SUBJECT_ABSENT
# с поимённым перечнем клеток: зелень без субъекта невозможна):
#   (без флага, без --repo)  — rc 1 SUBJECT_ABSENT + все клетки красны поимённо
#   (без флага, --repo R)    — судится живой продукт R (до реализации красен)
#   --model                  эталон model/ (контроль входов)
#   --stabs                  контроль + матрица обманных стабов (SVJAZI N)
#   --live-component --repo R  режим L: продуктовый live-протокол (jest-expo
#                            из R/mobile, изолированная копия, матрица B.8;
#                            без рантайма — rc 2 LIVE_PREDPOSYLKA, не skip)
#   --seed N                 seed сеяных входов p14/p15 (дефолт 145; право
#                           судьи — перезапуск с иным seed)
# Обёртка режим не подменяет и сама ничего не печатает; численный движок,
# оракул и перечень клеток — probe_runner.mjs/probe.py/source.json рядом
# (единый источник). Самодостаточна: node + python3, без сети/omp/эмулятора.
# Коды возврата — коды probe.py: 0 — зелено; 1 — красная клетка либо стаб
# прошёл (STAB_ZHIV) либо нет субъекта (SUBJECT_ABSENT); 2 — нечем проверять
# (нет node, ORACLE_TAMPERED, дрейф реестра/стабов/модели).
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
