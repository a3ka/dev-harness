#!/usr/bin/env bash
# Раннер красной/зелёной пачки 054 (workshop_project): прогоняет
# fixtures/workshop_project/red_profil_dva_sloja.sh против честной
# реализации (scripts/profile_resolver.sh + workshop --probe) И стаб-пак
# (9 обманных стабов), который остаётся зелёным ПОСЛЕ реализации —
# различимость батареи не зависит от честного кода (прецедент 045).
#
# Использование:
#   bash fixtures/_krasnye_054.sh              # прогон из корня worktree
#   WORKTREE=/path bash fixtures/_krasnye_054.sh
#
# Семантика: rc 0 — все стабы пойманы + честные клетки зелёные;
# rc 1 — расхождение есть (стаб прошёл клетку или честная упала).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Резолвер-путь — ОТ КОРНЯ РЕПОЗИТОРИЯ мастерской, не от каталога этой фикстуры.
REPO_ROOT="${REPO_ROOT:-$(cd "$HERE/.." && pwd)}"
PROFILE_RESOLVER="$REPO_ROOT/scripts/profile_resolver.sh"
WORKSHOP="$REPO_ROOT/workshop"
BATTERY="$HERE/workshop_project/red_profil_dva_sloja.sh"
[ -f "$PROFILE_RESOLVER" ] || { printf 'ОТКАЗ: нет резолвера: %s\n' "$PROFILE_RESOLVER" >&2; exit 1; }
[ -f "$WORKSHOP" ] || { printf 'ОТКАЗ: нет workshop: %s\n' "$WORKSHOP" >&2; exit 1; }
[ -f "$BATTERY" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY" >&2; exit 1; }

PROFILE_RESOLVER="$PROFILE_RESOLVER" WORKSHOP="$WORKSHOP" bash "$BATTERY" "$@"
BATTERY_RC=$?
echo "итог 054: rc=$BATTERY_RC"
# Контракт 057 (Ч-8, Б2): код возврата раннера = код батареи.
# `echo` раннее «зелёное дерево → rc=0, красная батарея → rc=1» измеряется
# только кодом процесса; печать итога — для человека. Прямой проброс `$?`
# не работает, потому что `$?` после `echo` — это 0; нужен снимок ДО `echo`.
exit "$BATTERY_RC"
