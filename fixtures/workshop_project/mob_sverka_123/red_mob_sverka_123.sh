#!/usr/bin/env bash
# Контракт 123 (mob-sverka-maketa): guard-канал §ПРОВОДКА — обёртка над
# `python3 probe.py --matrix` (контроль модели 33/33 + каждый обманный стаб
# красен на каждом своём входе stab_vhod). Движок, оракул и перечень case —
# probe.py и source.json рядом (единый источник); обёртка режим не меняет и
# сама ничего не печатает. Шаг CI харнесса — `bash <этот файл>` (грамматика
# registry/ci-steps.tsv допускает `bash <путь>`, не `python3 <путь>`).
# Коды возврата: 0 — матрица зелёна, 1 — контроль красен либо стаб жив (STAB_ZHIV),
#                2 — нечем проверить (нет python3, ORACLE_TAMPERED, набор stubs/ ≠ stab_vhod).
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" --matrix
