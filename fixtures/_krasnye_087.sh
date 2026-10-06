#!/usr/bin/env bash
# Раннер красной/зелёной пачки 087 «CI-Б: классы изменений и результат по хешу кодового
# дерева» — агрегатор ОДНОЙ семьи: fixtures/ci_b_087/red_ci_b_087.sh (probe-only 034, см.
# .probe-only в каталоге семьи; имя каталога — вне чужих glob'ов раннеров).
#
# Использование:
#   bash fixtures/_krasnye_087.sh              # прогон из корня worktree
#   bash fixtures/_krasnye_087.sh <корень>     # альтернативный корень дерева
#
# Семантика (контракт 087 §Приёмка): нет любого из субъектов г0 (t87_missing_subjects в
# fixtures/ci_b_087/_toy.sh — единственный список: scripts/ci_klass.sh, scripts/ci_vesa.sh,
# scripts/run_ci_lane.sh, registry/ci-steps.tsv со строками uchet) → печать «красная:
# предмет отсутствует», rc 1 БЕЗ запуска батареи (<1 с — проба спек-гейта 036 живёт под
# timeout 60, урок Н-198); иначе — батарея (клетки + стаб-пак), rc 0 ⟺ все клетки зелёные
# и стаб-пак пойман целиком. rc 2 — нечем проверить (нет батареи/каркаса, git, python3).
# Подключение в CI — строка step реестра registry/ci-steps.tsv пачкой implementer 087
# (после лендинга 083, §Зоны контракта).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${1:-$(cd "$HERE/.." && pwd)}"
TOY="$HERE/ci_b_087/_toy.sh"
BATTERY="$HERE/ci_b_087/red_ci_b_087.sh"
[ -f "$TOY" ] || { printf 'NOT_IMPLEMENTED: нет каркаса семьи: %s\n' "$TOY" >&2; exit 2; }
[ -f "$BATTERY" ] || { printf 'NOT_IMPLEMENTED: нет батареи: %s\n' "$BATTERY" >&2; exit 2; }
# shellcheck disable=SC1090
. "$TOY"
missing="$(t87_missing_subjects "$ROOT")"
if [ -n "$missing" ]; then
  printf 'красная: предмет отсутствует\n'
  printf 'КРАСНОЕ 087: нет %s (корень %s)\n' "$missing" "$ROOT" >&2
  exit 1
fi
bash "$BATTERY" "$ROOT"
exit $?
