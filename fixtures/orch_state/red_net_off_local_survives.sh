#!/usr/bin/env bash
# Клетка 1 — red_net_off_local_survives.sh (Выход-1; контракт 092 §(2).1).
# Дано: checkpoint-состояние task=T1 stage=judge next=«шаг А» (записано процессом №1);
# шов эндпоинта GitHub → 127.0.0.1:9 (connection refused). Когда: orch_status.sh
# (процесс №1) и повторно «после рестарта» (новый процесс). Тогда: оба rc 0; строки
# task/next_step/stage на месте; строка «удалённое состояние: неизвестно» литерально;
# НЕТ запрета локального восстановления (rc ≠ 1 по причине сети).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need checkpoint status
K=red_net_off_local_survives

kletka() {
  o92_world
  o92_toy netoff
  O92_API='http://127.0.0.1:9'
  o92_rnd_task; W_TASK="$O92_TASK"
  W_STAGE='judge'
  o92_rnd_line; W_NEXT="$O92_LINE"
  o92_rnd_hex40; W_CAND="$O92_HEX"
  # Процесс №1 — запись состояния субъектом (оракул — модель W_*):
  o92_probe checkpoint init "$W_TASK" -
  o92_assert_rc "$K" 0 || return
  o92_probe checkpoint put stage "$W_STAGE"
  o92_assert_rc "$K" 0 || return
  o92_probe checkpoint put next_step "$W_NEXT"
  o92_assert_rc "$K" 0 || return
  o92_probe checkpoint put candidate "$W_CAND"
  o92_assert_rc "$K" 0 || return
  # Статус дважды — «рестарт» = каждый вызов новый процесс:
  local i
  for i in 1 2; do
    o92_probe status
    o92_assert_rc "$K" 0 || return
    o92_assert_out "$K" "task: $W_TASK" || return
    o92_assert_out "$K" "stage: $W_STAGE" || return
    o92_assert_out "$K" "next_step: $W_NEXT" || return
    o92_assert_out "$K" "$O92L_NEIZV" || return
  done
  o92_ok "$K"
}
kletka
exit "$O92_RED"
