#!/usr/bin/env bash
# Зелёная case-клетка — case_status_green.sh (контракт 092 §(2), строка 150: семь
# полей + нет «неизвестно» при живом toy-API). Живёт в green/ — запускается ТОЛЬКО
# агрегатором семьи fixtures/_krasnye_092.sh.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/../_toy.sh"
o92_need status
K=case_status_green

kletka() {
  o92_world
  o92_toy stgreen
  o92_rnd_task; W_TASK="$O92_TASK"
  W_STAGE='implement'
  o92_rnd_line; W_NEXT="$O92_LINE"
  o92_rnd_hex40; W_CAND="$O92_HEX"
  W_LASTP='stage@2'; W_WAITING='external'; W_PUB='nothing'
  o92_write_state "$O92_STATE"
  o92_api_responses "$O92_RESP_SUCCESS"
  o92_probe status
  o92_assert_rc "$K" 0 || { o92_api_stop; return; }
  o92_assert_out "$K" "task: $W_TASK" || { o92_api_stop; return; }
  o92_assert_out "$K" "stage: $W_STAGE" || { o92_api_stop; return; }
  o92_assert_out "$K" "candidate: $W_CAND" || { o92_api_stop; return; }
  o92_assert_out "$K" "last_proven: $W_LASTP" || { o92_api_stop; return; }
  o92_assert_out "$K" "waiting: $W_WAITING" || { o92_api_stop; return; }
  o92_assert_out "$K" "next_step: $W_NEXT" || { o92_api_stop; return; }
  o92_assert_out "$K" "pub_state: $W_PUB" || { o92_api_stop; return; }
  o92_assert_noout "$K" "$O92L_NEIZV" || { o92_api_stop; return; }
  [ "$(o92_api_count)" -eq 1 ] || { o92_red "$K" "обращений к API не 1"; o92_api_stop; return; }
  o92_api_stop
  o92_ok "$K"
}
kletka
exit "$O92_RED"
