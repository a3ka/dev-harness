#!/usr/bin/env bash
# Раннер красной/зелёной пачки 084 «реестр плана: registry/plan.tsv — единственный источник
# порядка» — агрегатор ОДНОЙ семьи: fixtures/plan_084/red_plan_084.sh (probe-only 034, см.
# .probe-only в каталоге семьи; имя каталога — вне чужих glob'ов раннеров).
#
# Использование:
#   bash fixtures/_krasnye_084.sh              # прогон из корня worktree
#   bash fixtures/_krasnye_084.sh <корень>     # альтернативный корень дерева
#
# Семантика (контракт 084 §Приёмка): нет любого из субъектов P84_SUBJECTS
# (fixtures/plan_084/_toy.sh — единственный список: scripts/lib_plan.sh, gen_plan.sh,
# check_plan.sh, track_digest.sh) → печать «красная: предмет отсутствует», rc 1 БЕЗ запуска
# батареи (<1 с — урок Н-198: проба спек-гейта 036 живёт под timeout 60); иначе — батарея,
# rc 0 ⟺ все клетки зелёные, каждая красная печатает свой код клетки. rc 2 — нечем
# проверить (нет батареи/каркаса, нет git/python3). Подключение в CI — пачка Б контракта 084
# (строка registry/ci-steps.tsv `step plan-family-084 …`, И-11).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$(cd "$HERE/.." && pwd)}"
TOY="$HERE/plan_084/_toy.sh"
BATTERY="$HERE/plan_084/red_plan_084.sh"
[ -f "$TOY" ] || { printf 'NOT_IMPLEMENTED: нет каркаса семьи: %s\n' "$TOY" >&2; exit 2; }
[ -f "$BATTERY" ] || { printf 'NOT_IMPLEMENTED: нет батареи: %s\n' "$BATTERY" >&2; exit 2; }
# shellcheck disable=SC1090
. "$TOY"
missing="$(p84_missing_subjects "$ROOT")"
if [ -n "$missing" ]; then
  printf 'красная: предмет отсутствует\n'
  printf 'КРАСНОЕ 084: нет %s (корень %s)\n' "$missing" "$ROOT" >&2
  exit 1
fi
bash "$BATTERY" "$ROOT"
exit $?
