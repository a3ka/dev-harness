#!/usr/bin/env bash
# Раннер красной/зелёной пачки 070 (workshop_project): прогоняет
# fixtures/workshop_project/red_github_token_070.sh против живого workshop
# (probe + живой запуск со стаб-omp) И стаб-пак (7 обманных стабов
# лаунчер-шага GitHub-токена, 7/7 + диффпроба 7/7), который остаётся зелёным
# ПОСЛЕ реализации — различимость батареи не зависит от честного кода
# (прецедент 058).
#
# Использование:
#   bash fixtures/_krasnye_070.sh              # прогон из корня worktree
#   WORKTREE=/path bash fixtures/_krasnye_070.sh
#
# Семантика: rc 0 — все стабы пойманы + честные клетки зелёные;
# rc 1 — расхождение (стаб прошёл клетку, честная упала или г0
# «предмет отсутствует» — ДО реализации, по конструкции).
#
# ПРОВОДКА (контракт 070, guard-канал): раннер — единственный исполнитель
# семьи workshop_project для предмета 070 (семья probe-only 034: файлы
# red_* вне case_*-глоба шарда verify_antiplacebo,
# scripts/verify_antiplacebo.sh:585); подключается прямым ci-шагом
# `bash fixtures/_krasnye_070.sh` и ключом package.json
# `check:github-token-family-selftest` РЕАЛИЗАЦИОННОЙ пачкой вместе с
# предметом (прецедент 059/060: преждевременно вшитый шаг держал CI красным
# до реализации — батарея красна по конструкции).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Пути — ОТ КОРНЯ РЕПОЗИТОРИЯ мастерской, не от каталога этой фикстуры.
REPO_ROOT="${REPO_ROOT:-$(cd "$HERE/.." && pwd)}"
WORKSHOP="$REPO_ROOT/workshop"
BATTERY="$HERE/workshop_project/red_github_token_070.sh"
[ -f "$WORKSHOP" ] || { printf 'ОТКАЗ: нет workshop: %s\n' "$WORKSHOP" >&2; exit 1; }
[ -f "$BATTERY" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY" >&2; exit 1; }

WORKSHOP="$WORKSHOP" bash "$BATTERY" "$@"
BATTERY_RC=$?
echo "итог 070: rc=$BATTERY_RC"
# Контракт 057 (Ч-8, Б2; прецедент _krasnye_058.sh): код возврата раннера =
# код батареи. Печать итога — для человека; `$?` после `echo` — всегда 0,
# поэтому снимок ДО `echo`.
exit "$BATTERY_RC"
