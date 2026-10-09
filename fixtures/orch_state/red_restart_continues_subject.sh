#!/usr/bin/env bash
# Клетка 2 — red_restart_continues_subject.sh (Выход-1; контракт 092 §(2).2).
# Дано: состояние записано процессом №1; процесс №1 завершён. Когда: orch_status.sh
# процессом №2. Тогда: rc 0; task, stage, next_step побайтово равны записанным
# (предмет продолжен, стадия не сброшена).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need checkpoint status
K=red_restart_continues_subject

kletka() {
  o92_world
  o92_toy cont
  o92_rnd_task; W_TASK="$O92_TASK"
  W_STAGE='spec'
  o92_rnd_line; W_NEXT="$O92_LINE"
  # Процесс №1 (завершён — каждый o92_probe отдельный bash-процесс):
  o92_probe checkpoint init "$W_TASK" -
  o92_assert_rc "$K" 0 || return
  o92_probe checkpoint put stage "$W_STAGE"
  o92_assert_rc "$K" 0 || return
  o92_probe checkpoint put next_step "$W_NEXT"
  o92_assert_rc "$K" 0 || return
  # Процесс №2 — предмет продолжен тем же (candidate '-', remote-ветвь не зовётся):
  o92_probe status
  o92_assert_rc "$K" 0 || return
  o92_assert_out "$K" "task: $W_TASK" || return
  o92_assert_out "$K" "stage: $W_STAGE" || return
  o92_assert_out "$K" "next_step: $W_NEXT" || return
  o92_ok "$K"
}
kletka
exit "$O92_RED"
