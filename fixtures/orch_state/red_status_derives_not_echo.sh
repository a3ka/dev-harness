#!/usr/bin/env bash
# Клетка 9 — red_status_derives_not_echo.sh (производность; контракт 092 §(2).9).
# Дано: next_step состояния = «шаг А»; toy HANDOFF.md содержит «шаг Б» (последняя
# строка). Когда: orch_status.sh --next. Тогда: stdout = «шаг А» (не эхо HANDOFF,
# не конкатенация).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need status
K=red_status_derives_not_echo

kletka() {
  o92_world
  o92_toy derives
  W_NEXT='шаг А'   # литерал клетки; toy HANDOFF оканчивается «шаг Б» (o92_toy)
  o92_write_state "$O92_STATE"
  o92_probe status --next
  o92_assert_rc "$K" 0 || return
  o92_assert_stdout_is "$K" "$W_NEXT" || return
  o92_ok "$K"
}
kletka
exit "$O92_RED"
