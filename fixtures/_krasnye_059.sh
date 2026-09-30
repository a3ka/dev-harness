#!/usr/bin/env bash
# Раннер красной/зелёной пачки 059 (workshop_project): прогоняет
# fixtures/workshop_project/red_sverka_puti_profylja.sh против живого
# резолвера HEAD (честные клетки к1..к19: к1..к17 зелёные после реализации
# предмета 059; к18/к19 красные против резолвера, срезающего LF-хвост
# значения ci.workflow и рвущего P-фразу внутренним \n — вердикт ревьюера
# 059-к1 Р1/Р2, зелёные после фикса реализатора) И стаб-пак (9 обманных
# стаб-резолверов, 9/9 + диффпроба 15/15), который зелёный ДО и ПОСЛЕ
# реализации — различимость батареи не зависит от честного кода
# (прецедент 045/054/058).
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
# verify_antiplacebo.sh:585); подключается РЕАЛИЗАЦИОННОЙ пачкой вместе с
# предметом — прямой ci-шаг `bash fixtures/_krasnye_059.sh` и ключ
# package.json `check:declared-path-family-selftest` (прецедент 058:
# sharing-family-selftest); до проводки предъявляется судьями каждого круга
# локально (fix059w; арбитраж 059-к3 9e874be С3).
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
