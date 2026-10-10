#!/usr/bin/env bash
# Клетка 8 — red_pub_vs_close.sh (Выход-5; контракт 092 §(2).8). ДВА входа, каждый —
# своё предъявление; клетка красна, если хотя бы один вход прошёл неправильно.
# Вход-а: pub_state=close_incomplete, git-факт toy: кандидат достижим из
# origin/main, close-события нет → «опубликовано: да» И «закрытие: не завершено» —
# ОБЕ строки. Вход-б: pub_state=nothing → «опубликовано: нет».
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need status
K=red_pub_vs_close

kletka() {
  # Вход-а: достижимый кандидат + долг закрытия:
  o92_world
  o92_toy pvc_a
  o92_pub_git да
  W_CAND="$O92_CAND"; W_PUB='close_incomplete'
  # Эндпоинт живого toy-API — «опубликовано/закрытие» выводятся из git-факта и
  # pub_state, сеть не участница входа:
  o92_api_responses "$O92_RESP_SUCCESS"
  o92_write_state "$O92_STATE"
  o92_probe status
  o92_assert_rc "$K[а]" 0 || { o92_api_stop; return; }
  o92_assert_out "$K[а]" "$O92L_OPUBL_DA" || { o92_api_stop; return; }
  o92_assert_out "$K[а]" "$O92L_NEZAKR" || { o92_api_stop; return; }
  o92_api_stop
  # Вход-б: незапущенная публикация:
  o92_world
  o92_toy pvc_b
  o92_pub_git нет
  W_CAND="$O92_CAND"; W_PUB='nothing'
  o92_api_responses "$O92_RESP_SUCCESS"
  o92_write_state "$O92_STATE"
  o92_probe status
  o92_assert_rc "$K[б]" 0 || { o92_api_stop; return; }
  o92_assert_out "$K[б]" "$O92L_OPUBL_NET" || { o92_api_stop; return; }
  o92_assert_noout "$K[б]" "$O92L_OPUBL_DA" || { o92_api_stop; return; }
  o92_api_stop
  o92_ok "$K"
}
kletka
exit "$O92_RED"
