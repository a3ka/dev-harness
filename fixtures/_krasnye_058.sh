#!/usr/bin/env bash
# Раннер красной/зелёной пачки 058 (workshop_project): прогоняет
# fixtures/workshop_project/red_sharing_agentdb.sh против честной реализации
# (workshop --probe: шаг шаринга agent.db) И стаб-пак (9 обманных стабов,
# 9/9 + диффпроба 9/9), который остаётся зелёным ПОСЛЕ реализации —
# различимость батареи не зависит от честного кода (прецедент 045/054/055).
#
# Использование:
#   bash fixtures/_krasnye_058.sh              # прогон из корня worktree
#   WORKTREE=/path bash fixtures/_krasnye_058.sh
#
# Семантика: rc 0 — все стабы пойманы + честные клетки зелёные;
# rc 1 — расхождение есть (стаб прошёл клетку, честная упала или г0
# «предмет отсутствует» — ДО реализации).
#
# ПРОВОДКА (контракт 058, guard-канал): раннер — единственный исполнитель
# семьи workshop_project для предмета 058 (семья probe-only 034: файлы
# red_* вне case_*-глоба шарда verify_antiplacebo, scripts/
# verify_antiplacebo.sh:585); подключён прямым ci-шагом
# `bash fixtures/_krasnye_058.sh` и ключом package.json
# `check:sharing-family-selftest` (прецедент 045: gitw-family-selftest).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Пути — ОТ КОРНЯ РЕПОЗИТОРИЯ мастерской, не от каталога этой фикстуры.
REPO_ROOT="${REPO_ROOT:-$(cd "$HERE/.." && pwd)}"
WORKSHOP="$REPO_ROOT/workshop"
BATTERY="$HERE/workshop_project/red_sharing_agentdb.sh"
[ -f "$WORKSHOP" ] || { printf 'ОТКАЗ: нет workshop: %s\n' "$WORKSHOP" >&2; exit 1; }
[ -f "$BATTERY" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY" >&2; exit 1; }

WORKSHOP="$WORKSHOP" bash "$BATTERY" "$@"
BATTERY_RC=$?
echo "итог 058: rc=$BATTERY_RC"
# Контракт 057 (Ч-8, Б2; прецедент _krasnye_054.sh): код возврата раннера =
# код батареи. Печать итога — для человека; `$?` после `echo` — всегда 0,
# поэтому снимок ДО `echo`.
exit "$BATTERY_RC"
