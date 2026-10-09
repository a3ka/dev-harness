#!/usr/bin/env bash
# Клетка 3 — red_ciwait_no_repoll.sh (Выход-2; контракт 092 §(2).3).
# Дано: toy-API отвечает in_progress на первые ДВА запроса, success на третий;
# счётчик запросов — в логе toy-API (оракул в памяти). Когда: ci_wait.sh --sha X —
# РОВНО один вызов. Тогда: rc 0 ∧ запросов к API ≥ 2 ∧ интервал между запросами > 0
# (времена из лога).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need ciwait
K=red_ciwait_no_repoll

kletka() {
  o92_world
  o92_toy ciw
  o92_api_responses "$O92_RESP_INPROG" "$O92_RESP_INPROG" "$O92_RESP_SUCCESS"
  o92_rnd_hex40
  # ОДИН вызов модели; поллинг — внутри процесса (И-5):
  o92_probe ciwait --sha "$O92_HEX" --interval 0.5 --attempts 10 --timeout 30
  o92_assert_rc "$K" 0 || { o92_api_stop; return; }
  local n; n="$(o92_api_count)"
  [ "$n" -ge 2 ] || { o92_red "$K" "запросов к API $n < 2 — повторного опроса нет"; o92_api_stop; return; }
  o92_api_gap_ok 0.2 || { o92_red "$K" "интервал между запросами ≤ 0 (времена из лога)"; o92_api_stop; return; }
  o92_api_stop
  o92_ok "$K"
}
kletka
exit "$O92_RED"
