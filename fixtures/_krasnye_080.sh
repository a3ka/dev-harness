#!/usr/bin/env bash
# Раннер красной/зелёной пачки 080 «бугфикс двери перезапуска» —
# агрегатор ОДНОЙ семьи:
#   fixtures/dver_bugfiks_080/red_dver_bugfiks_080.sh
# (probe-only 034, см. .probe-only в каталоге семьи; имя каталога —
# вне чужих glob'ов раннеров).
#
# Использование:
#   bash fixtures/_krasnye_080.sh              # прогон из корня worktree
#   bash fixtures/_krasnye_080.sh <корень>     # альтернативный корень дерева
#
# Семантика: rc 0 — батарея зелёная (стаб-пак 8/8 + диффпроба 8/8 +
# честные клетки 12/12); rc 1 — красное до/после (предмет отсутствует
# или расхождение в клетках). Подключение в ci — реализационной
# пачкой (контракт 080 §ПРОВОДКА; прецедент 071/078).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATTERY="$HERE/dver_bugfiks_080/red_dver_bugfiks_080.sh"
[ -f "$BATTERY" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY" >&2; exit 1; }
bash "$BATTERY" "$@"
exit $?