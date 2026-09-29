#!/usr/bin/env bash
# Раннер красной/зелёной пачки 059 (workshop_project): прогоняет
# fixtures/workshop_project/red_sverka_puti_profylja.sh против живого
# резолвера HEAD (честные клетки к1..к11: красны ДО реализации — предмет 059
# отсутствует, зелёные после) И стаб-пак (8 обманных стаб-резолверов,
# 8/8 + диффпроба 10/10), который зелёный ДО и ПОСЛЕ реализации —
# различимость батареи не зависит от честного кода (прецедент 045/054/058).
#
# Использование:
#   bash fixtures/_krasnye_059.sh              # прогон из корня worktree
#   WORKTREE=/path bash fixtures/_krasnye_059.sh
#
# Семантика: rc 0 — все стабы пойманы + диффпроба чиста + честные клетки
# зелёные; rc 1 — расхождение есть (стаб прошёл клетку, честная упала или
# г0 «предмет отсутствует» — ДО реализации).
#
# ПРОВОДКА (контракт 059, guard-канал): раннер — единственный исполнитель
# семьи workshop_project для предмета 059 (семья probe-only 034: файлы
# red_* вне case_*-глоба шарда verify_antiplacebo, scripts/
# verify_antiplacebo.sh:585); подключён прямым ci-шагом
# `bash fixtures/_krasnye_059.sh` и ключом package.json
# `check:declared-path-family-selftest` (прецедент 058: sharing-family-selftest).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Пути — ОТ КОРНЯ РЕПОЗИТОРИЯ мастерской, не от каталога этой фикстуры.
REPO_ROOT="${REPO_ROOT:-$(cd "$HERE/.." && pwd)}"
RESOLVER="$REPO_ROOT/scripts/profile_resolver.sh"
BATTERY="$HERE/workshop_project/red_sverka_puti_profylja.sh"
[ -f "$RESOLVER" ] || { printf 'ОТКАЗ: нет резолвера: %s\n' "$RESOLVER" >&2; exit 1; }
[ -f "$BATTERY" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY" >&2; exit 1; }

bash "$BATTERY" "$@"
BATTERY_RC=$?
echo "итог 059: rc=$BATTERY_RC"
# Контракт 057 (Ч-8, Б2; прецедент _krasnye_054.sh/_krasnye_058.sh): код
# возврата раннера = код батареи. Печать итога — для человека; `$?` после
# `echo` — всегда 0, поэтому снимок ДО `echo`.
exit "$BATTERY_RC"
