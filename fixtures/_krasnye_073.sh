#!/usr/bin/env bash
# Раннер красной/зелёной пачки 073 «гейт зон на merge-HEAD» — агрегатор ОДНОЙ
# семьи: fixtures/zony_merge_head/red_invariant_form_073.sh (probe-only 034,
# см. .probe-only в каталоге семьи).
#
# Использование:
#   bash fixtures/_krasnye_073.sh              # прогон из корня worktree
#   FIXSIM=1 bash fixtures/_krasnye_073.sh     # А-318: зелёное симуляцией
#                                             # честной правки (throwaway /tmp)
#
# Семантика: rc 0 — батарея зелёная (пины И1–И5 держатся, стаб-пак 4/4
# пойман); rc 1 — живое красное ДО правки (И1/И2 нарушены) либо непойманный
# стаб. FIXSIM=1 — то же + симуляция обязана дать rc 0 на чистом дереве.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATTERY="$HERE/zony_merge_head/red_invariant_form_073.sh"
[ -f "$BATTERY" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY" >&2; exit 1; }
bash "$BATTERY" "$@"
exit $?
