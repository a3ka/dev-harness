#!/usr/bin/env bash
# Раннер красной/зелёной пачки 078 «лимит активных контрактов» — агрегатор ОДНОЙ
# семьи: fixtures/limit_aktivnyh/red_limit_aktivnyh_078.sh (probe-only 034, см.
# .probe-only в каталоге семьи; имя каталога — вне чужих glob'ов раннеров).
#
# Использование:
#   bash fixtures/_krasnye_078.sh              # прогон из корня worktree
#   bash fixtures/_krasnye_078.sh <корень>     # альтернативный корень дерева
#
# Семантика: rc 0 — батарея зелёная (честные клетки + пойманные стабы); rc 1 —
# живое красное ДО реализации (л0 «предмет отсутствует»), красная клетка или
# живой стаб; rc 2 — нечем проверить. Подключение в ci — реализационной пачкой
# (контракт 078 §ПРОВОДКА; прецедент 071).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATTERY="$HERE/limit_aktivnyh/red_limit_aktivnyh_078.sh"
[ -f "$BATTERY" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY" >&2; exit 1; }
bash "$BATTERY" "$@"
exit $?
