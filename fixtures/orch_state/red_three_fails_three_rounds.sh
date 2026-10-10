#!/usr/bin/env bash
# Клетка 7 — red_three_fails_three_rounds.sh (Выход-4; контракт 092 §(2).7).
# Дано: три round-fail subject C с ref v1@sha1, v1@sha2 (записан «после рестарта»,
# в файле вердикта была правка — второй блоб того же файла), v2@sha3; файлов 2,
# событий 3. Когда: orch_status.sh. Тогда: строки «кругов: 3» и «предел: арбитр»
# литерально.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need status
K=red_three_fails_three_rounds

kletka() {
  o92_world
  o92_toy triF
  o92_rnd_task; W_TASK="$O92_TASK"; W_STAGE='judge'
  o92_story_dva_fajla   # 2 файла, 3 круга (v1@sha1, v1@sha2 после правки, v2@sha3)
  o92_write_state "$O92_STATE"
  o92_write_events "$O92_STATE"
  o92_probe status
  o92_assert_rc "$K" 0 || return
  o92_assert_out "$K" "${O92L_KRUGOV_PRE}3" || return
  o92_assert_out "$K" "$O92L_PREDEL" || return
  o92_ok "$K"
}
kletka
exit "$O92_RED"
