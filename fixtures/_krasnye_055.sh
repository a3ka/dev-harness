#!/usr/bin/env bash
# Раннер красной/зелёной пачки 055 (workshop_project): прогоняет
# fixtures/workshop_project/red_izoljacija_projectid.sh против честной
# реализации (workshop --probe + scripts/profile_resolver.sh) И стаб-пак
# (9 обманных стабов, 9/9 + диффпроба), который остаётся зелёным ПОСЛЕ
# реализации — различимость батареи не зависит от честного кода (прецедент
# 045/054).
#
# Использование:
#   bash fixtures/_krasnye_055.sh              # прогон из корня worktree
#   WORKTREE=/path bash fixtures/_krasnye_055.sh
#
# Семантика: rc 0 — все стабы пойманы + честные клетки зелёные;
# rc 1 — расхождение есть (стаб прошёл клетку или честная упала).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Резолвер-путь — ОТ КОРНЯ РЕПОЗИТОРИЯ мастерской, не от каталога этой фикстуры.
REPO_ROOT="${REPO_ROOT:-$(cd "$HERE/.." && pwd)}"
PROFILE_RESOLVER="$REPO_ROOT/scripts/profile_resolver.sh"
WORKSHOP="$REPO_ROOT/workshop"
BATTERY="$HERE/workshop_project/red_izoljacija_projectid.sh"
[ -f "$PROFILE_RESOLVER" ] || { printf 'ОТКАЗ: нет резолвера: %s\n' "$PROFILE_RESOLVER" >&2; exit 1; }
[ -f "$WORKSHOP" ] || { printf 'ОТКАЗ: нет workshop: %s\n' "$WORKSHOP" >&2; exit 1; }
[ -f "$BATTERY" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY" >&2; exit 1; }

PROFILE_RESOLVER="$PROFILE_RESOLVER" WORKSHOP="$WORKSHOP" bash "$BATTERY" "$@"
echo "итог 055: rc=$?"