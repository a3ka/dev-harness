#!/usr/bin/env bash
# Клетка 13 — red_rounds_count_events_not_files.sh (Выход-4, счёт событиями;
# контракт 092 §(2).13). Дано: файл вердикта V существует в ДВУХ блобах (FAIL-1,
# затем файл дополнен FAIL-2 — v1@sha1, v1@sha2) + отдельный файл W (v2@sha3).
# Файлов 2, событий 3. Когда: orch_status.sh. Тогда: «кругов: 3».
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need status
K=red_rounds_count_events_not_files

kletka() {
  o92_world
  o92_toy countE
  o92_rnd_task; W_TASK="$O92_TASK"; W_STAGE='judge'
  o92_story_dva_fajla   # V в двух блобах + W: файлов 2, событий 3
  o92_write_state "$O92_STATE"
  o92_write_events "$O92_STATE"
  o92_probe status
  o92_assert_rc "$K" 0 || return
  o92_assert_out "$K" "${O92L_KRUGOV_PRE}3" || return
  o92_ok "$K"
}
kletka
exit "$O92_RED"
