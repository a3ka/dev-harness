#!/usr/bin/env bash
# Зелёная case-клетка — case_ciwait_green.sh (контракт 092 §(2), строка 150: rc 0
# при success с первого ответа — ровно 1 запрос). Живёт в green/ — запускается
# ТОЛЬКО агрегатором семьи fixtures/_krasnye_092.sh.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/../_toy.sh"
o92_need ciwait
K=case_ciwait_green

kletka() {
  o92_world
  o92_toy ciwg
  o92_api_responses "$O92_RESP_SUCCESS"
  o92_rnd_hex40
  o92_probe ciwait --sha "$O92_HEX" --interval 0.5 --attempts 5 --timeout 10
  o92_assert_rc "$K" 0 || { o92_api_stop; return; }
  [ "$(o92_api_count)" -eq 1 ] || { o92_red "$K" "запросов к API не 1"; o92_api_stop; return; }
  o92_api_stop
  o92_ok "$K"
}
kletka
exit "$O92_RED"
