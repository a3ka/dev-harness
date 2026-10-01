#!/usr/bin/env bash
# Раннер красной/зелёной пачки 072 (perezapusk_sessii): прогоняет
# fixtures/perezapusk_sessii/red_dver_perezapuska_072.sh против дерева
# (г0 «предмет отсутствует» ДО реализации — носителя scripts/orch_restart.sh
# нет; стаб-пак 7 обманных стабов двери + диффпроба 7/7 зелёны в том же
# прогоне) И стаб-пак, который остаётся зелёным ПОСЛЕ реализации —
# различимость батареи не зависит от честного кода (прецеденты 058/070).
#
# Использование:
#   bash fixtures/_krasnye_072.sh              # прогон из корня worktree
#   WORKTREE=/path bash fixtures/_krasnye_072.sh
#
# Семантика: rc 0 — все стабы пойманы + честные клетки зелёные;
# rc 1 — расхождение (стаб прошёл клетку, честная упала или г0
# «предмет отсутствует» — ДО реализации, по конструкции).
#
# ПРОВОДКА (контракт 072, role-канал + раннер): норма предмета —
# поведенческая строка roles/orchestrator.md (touch → bash
# scripts/orch_restart.sh), судится role-каналом поля ПРОВОДКА;
# раннер — исполнитель семьи perezapusk_sessii (probe-only 034: файлы
# red_* вне case_*-глоба шарда verify_antiplacebo; каталог — НЕ барьерный
# ключ, см. fixtures/perezapusk_sessii/.probe-only). Подключение раннера
# ci-шагом/ключом package.json — ВНЕ зоны 072 (.github/workflows/ci.yml —
# зона 071 пары); до решения владельца/071 раннер — инструмент крёстной
# предъявки судьям и критику напрямую, ВНЕ поля ПРОВОДКА (контракт 072
# §ПРОВОДКА).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Пути — ОТ КОРНЯ РЕПОЗИТОРИЯ мастерской, не от каталога этой фикстуры.
REPO_ROOT="${REPO_ROOT:-$(cd "$HERE/.." && pwd)}"
BATTERY="$HERE/perezapusk_sessii/red_dver_perezapuska_072.sh"
[ -f "$BATTERY" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY" >&2; exit 1; }

bash "$BATTERY" "$@"
BATTERY_RC=$?
echo "итог 072: rc=$BATTERY_RC"
# Контракт 057 (Ч-8, Б2; прецедент _krasnye_058.sh/_krasnye_070.sh): код
# возврата раннера = код батареи. Печать итога — для человека; `$?` после
# `echo` — всегда 0, поэтому снимок ДО `echo`.
exit "$BATTERY_RC"
