#!/usr/bin/env bash
# Клетка 10 — red_checkpoint_atomic_fail.sh (И-1; контракт 092 §(2).10).
# Дано: валидное состояние; ORCH_STATE_DIR → каталог только-для-чтения. Когда: put.
# Тогда: rc 1 «запись состояния не удалась»; sha256 state.tsv/events.tsv ДО/ПОСЛЕ
# равны (снимок в памяти).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need checkpoint
K=red_checkpoint_atomic_fail

kletka() {
  o92_world
  o92_toy atom
  o92_rnd_task; W_TASK="$O92_TASK"
  o92_rnd_line; W_NEXT="$O92_LINE"
  W_EVENTS=()
  o92_write_state "$O92_STATE"
  o92_write_events "$O92_STATE"
  local s1 s2
  s1="$(o92_sha "$O92_STATE/state.tsv")"
  s2="$(o92_sha "$O92_STATE/events.tsv")"
  chmod a-w "$O92_STATE"
  o92_rnd_line
  o92_probe checkpoint put next_step "$O92_LINE"   # значение отлично от записанного
  local rc=$?
  chmod u+w "$O92_STATE"
  [ "$rc" -eq 1 ] || { o92_red "$K" "rc=$rc, ожидался 1"; return; }
  o92_assert_err "$K" "$O92L_ZAPFAIL" || return
  [ "$(o92_sha "$O92_STATE/state.tsv")" = "$s1" ] \
    || { o92_red "$K" "state.tsv изменился при отказе записи"; return; }
  [ "$(o92_sha "$O92_STATE/events.tsv")" = "$s2" ] \
    || { o92_red "$K" "events.tsv изменился при отказе записи"; return; }
  o92_ok "$K"
}
kletka
exit "$O92_RED"
