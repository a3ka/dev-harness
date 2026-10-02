#!/usr/bin/env bash
# Раннер красной/зелёной пачки 074 «серверная обвязка — единый источник в репо»
# — агрегатор ОДНОЙ семьи: fixtures/ops_server/red_server_obvjazka_074.sh
# (probe-only 034, см. .probe-only в каталоге семьи; имя каталога — вне чужих
# glob'ов раннеров, урок А-314).
#
# Использование:
#   bash fixtures/_krasnye_074.sh              # прогон из корня worktree
#   FIXSIM=1 bash fixtures/_krasnye_074.sh     # А-318: зелёное симуляцией
#                                             # честного install.sh (throwaway /tmp)
#   LANDSIM=1 bash fixtures/_krasnye_074.sh   # вердикт к1: зелёное на дереве
#                                             # с УЖЕ приземлёнными указателями
#   OPS_ROOT=<дерево-субъекта> bash fixtures/_krasnye_074.sh   # живое красное ДО
#
# Семантика: rc 0 — батарея зелёная (честные клетки + пойманные стабы);
# rc 1 — живое красное ДО реализации (г0 «предмет отсутствует»), красная
# клетка или живой стаб; rc 2 — нечем проверить.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATTERY="$HERE/ops_server/red_server_obvjazka_074.sh"
[ -f "$BATTERY" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY" >&2; exit 1; }
bash "$BATTERY" "$@"
exit $?
