#!/usr/bin/env bash
# Раннер красной/зелёной пачки 092 «возобновляемое состояние задачи» — агрегатор
# ОДНОЙ семьи: fixtures/orch_state/ (17 красных клеток red_*.sh + стаб-пак
# battery_stubs.sh + зелёные case-клетки приёмки green/case_*.sh).
#
# Использование:
#   bash fixtures/_krasnye_092.sh              # прогон из корня worktree
#   bash fixtures/_krasnye_092.sh <корень>     # альтернативный корень дерева
#
# Семантика (контракт 092 §Приёмочный критерий):
#   1. Стаб-пак battery_stubs.sh — НЕ требует субъектов (мини-субъекты свои):
#      красный стаб-пак = сломанный каркас → rc 2 NOT_IMPLEMENTED, предмет не
#      судится. Стаб-пак сам по себе: 18/18 обманных стабов поймано СВОИМИ
#      клетками, диффпроба честного тела зелёна на всех 21 клетках — различимость
#      не зависит от честного кода (прецедент 091/058).
#   2. Субъектов scripts/orch_checkpoint.sh, scripts/orch_status.sh,
#      scripts/ci_wait.sh нет (список O92_SUBJECTS в _toy.sh — единственный) →
#      печать «красная: предмет отсутствует», rc 1, клетки НЕ запускаются
#      (урок Н-198: без прогона батареи).
#   3. Субъекты есть → 17 красных клеток + 4 зелёных case-клетки: rc 0 ⟺ все
#      зелёные; каждая красная печатает «КРАСНО: <клетка> — <причина>».
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$(cd "$HERE/.." && pwd)}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
FAM="$HERE/orch_state"
export O92_ROOT
# shellcheck disable=SC1090
. "$FAM/_toy.sh"

bash "$FAM/battery_stubs.sh" "$O92_ROOT" || {
  printf 'NOT_IMPLEMENTED: стаб-пак 092 красен — каркас сломан, предмет не судится\n' >&2
  exit 2
}

miss="$(o92_missing_subjects "$O92_ROOT")"
if [ -n "$miss" ]; then
  printf 'красная: предмет отсутствует\n'
  printf 'КРАСНОЕ 092: нет %s (корень %s)\n' "$miss" "$O92_ROOT" >&2
  exit 1
fi

RC=0
for c in "${O92_RED_CELLS[@]}"; do
  bash "$FAM/$c" "$O92_ROOT" || RC=1
done
for c in "${O92_CASE_CELLS[@]}"; do
  bash "$FAM/green/$c" "$O92_ROOT" || RC=1
done
exit "$RC"
