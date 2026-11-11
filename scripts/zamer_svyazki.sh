#!/usr/bin/env bash
# НЕ БАРЬЕР: субъект (SUBJECT) батареи fixtures/workshop_project/zamer_svyazki_190/red_zamer_svyazki_190.sh;
# её приёмка — красная проба на сам scripts/zamer_svyazki.sh (22 клетки; режимы --repo/--model/--stabs), не сам скрипт;
# контракт 190 §Проводка: guard=scripts/zamer_svyazki.sh (проводка 038 видит подключение по реестру ci-steps).
#
# Замер связки architect ↔ критик (контракт 190, Л6 — С16, часть «связка»):
# одна точка входа, читает реестр предметов, учётные СУД-строки вердиктов и
# HANDOFF, журналы сессий — и печатает таблицу мер связки (21 столбец канона).
#
#   bash scripts/zamer_svyazki.sh --repo <корень> --zhurnaly <корень-сессий> \
#       [--s ISO] [--do ISO] [--predmety ERE]
#
# Возвращает: 0 — таблица напечатана (stderr несёт «просмотрено: записей_журналов=N»,
# N>0); 1 — ПУСТАЯ_ВЫБОРКА; 2 — НЕТ_ЖУРНАЛОВ/НЕТ_РЕЕСТРА/НЕТ_РЕПО.
set -uo pipefail

SELF_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'НЕТ_PYTHON: python3 не найден' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$SELF_DIR/zamer_svyazki.py" "$@"
