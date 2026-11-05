#!/usr/bin/env bash
# Контракт 141 v3: guard-канал §ПРОВОДКА — обёртка над probe.py.
# Без --repo/MOB_REPO — rc 1 SUBJECT_ABSENT; --repo R проверяет workflow
# и три скрипта из R/mobile/scripts/ (пин байтов + replay из файлов R).
# --model проверяет пиненные модельные носители, --stabs — кодовые мутации.
# Коды возврата probe.py: 0 — все входы; 1 — красный/живой стаб/нет субъекта;
# 2 — ORACLE_TAMPERED или нет python3/pyyaml.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
