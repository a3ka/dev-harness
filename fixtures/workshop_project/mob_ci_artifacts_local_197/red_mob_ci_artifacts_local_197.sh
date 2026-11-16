#!/usr/bin/env bash
# Контракт 197: guard-канал §ПРОВОДКА — обёртка над probe.py.
# Без флагов — rc 1 SUBJECT_ABSENT (реализация — правка ПРОДУКТА Complior-mob,
# дерево харнесса её не несёт); --model судит замкнутую модель (все клетки
# зелёны), --stabs — кодовые мутации копии модели (каждая красна своей
# именованной причиной, привязки в source.json:.stab_vhod), --repo R судит
# живое дерево продукта (.github/workflows/mobile.yml, package.json,
# mobile/scripts/ci-artefakty.cjs).
# Коды возврата probe.py: 0 — все входы зелёны/все стабы пойманы;
# 1 — красная клетка/пропущенный стаб/нет субъекта; 2 — ORACLE_TAMPERED или
# нет python3/pyyaml/node (replay-клетки исполняют скрипт-канон).
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
command -v node >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет node (replay скрипта-канона)' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
