#!/usr/bin/env bash
# Клетка 4 — red_restart_no_dup_task.sh (Выход-3, задача; контракт 092 §(2).4).
# Дано: журнал уже содержит task-init T1 <ref>; «рестарт». Когда: повторный
# orch_checkpoint.sh init T1. Тогда: rc 0 «уже записано»; в журнале ОДНА строка
# task-init T1; orch_status показывает одну задачу.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need checkpoint status
K=red_restart_no_dup_task

kletka() {
  o92_world
  o92_toy dupT
  o92_rnd_task; W_TASK="$O92_TASK"
  W_STAGE='judge'
  o92_ev task-init "$W_TASK" '-'
  o92_write_state "$O92_STATE"
  o92_write_events "$O92_STATE"
  # Повторный init после «рестарта»:
  o92_probe checkpoint init "$W_TASK" -
  o92_assert_rc "$K" 0 || return
  o92_assert_out "$K" "$O92L_ZAPIS" || return
  [ "$(o92_events_count task-init "$W_TASK")" -eq 1 ] \
    || { o92_red "$K" "в журнале не ОДНА строка task-init"; return; }
  o92_probe status
  o92_assert_rc "$K" 0 || return
  o92_assert_out "$K" "task: $W_TASK" || return
  o92_ok "$K"
}
kletka
exit "$O92_RED"
