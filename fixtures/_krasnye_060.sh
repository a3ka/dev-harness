#!/usr/bin/env bash
# Раннер красной/зелёной пачки 060 (workshop_project): прогоняет
# fixtures/workshop_project/red_samodostatochnost_repo_060.sh против живых
# workshop и scripts/ HEAD (честные клетки к1-к8: красны ДО реализации —
# предмет 060 отсутствует, зелёные после) И стаб-пак (11 обманных стабов,
# 11/11 + диффпробы), который зелёный ДО и ПОСЛЕ реализации — различимость
# батареи не зависит от честного кода (прецедент 045/054/058/059).
#
# Использование:
#   bash fixtures/_krasnye_060.sh              # прогон из корня worktree
#   bash fixtures/_krasnye_060.sh <корень>     # явный корень харнесса
#
# Семантика: rc 0 — все стабы пойманы + диффпробы чисты + честные клетки
# зелёные; rc 1 — расхождение есть (стаб прошёл клетку, честная упала или
# г0 «предмет отсутствует» — ДО реализации).
#
# ПРОВОДКА (контракт 060, guard-канал): раннер — единственный исполнитель
# семьи workshop_project для предмета 060 (семья probe-only 034: файлы
# red_* вне case_*-глоба шарда verify_antiplacebo, scripts/
# verify_antiplacebo.sh:585); подключается РЕАЛИЗАЦИОННОЙ пачкой вместе с
# предметом — прямой ci-шаг `bash fixtures/_krasnye_060.sh` после шага семьи
# 059 и ключ package.json `check:samodostatochnost-family-selftest`
# (прецеденты 058/059); до проводки предъявляется судьями каждого круга
# локально (прецедент 059 22d3faf: преждевременно вшитый шаг держал CI
# черновика красным — батарея красна по конструкции).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Пути — ОТ КОРНЯ РЕПОЗИТОРИЯ мастерской, не от каталога этой фикстуры.
REPO_ROOT="${REPO_ROOT:-$(cd "$HERE/.." && pwd)}"
BATTERY="$HERE/workshop_project/red_samodostatochnost_repo_060.sh"
[ -f "$REPO_ROOT/workshop" ] || { printf 'ОТКАЗ: нет лаунчера: %s/workshop\n' "$REPO_ROOT" >&2; exit 1; }
[ -f "$BATTERY" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY" >&2; exit 1; }

bash "$BATTERY" "$@"
BATTERY_RC=$?
echo "итог 060: rc=$BATTERY_RC"
# Контракт 057 (Ч-8, Б2; прецедент _krasnye_054/_058/_059): код возврата
# раннера = код батареи. Печать итога — для человека; `$?` после `echo` —
# всегда 0, поэтому снимок ДО `echo`.
exit "$BATTERY_RC"
