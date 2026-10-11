#!/usr/bin/env bash
# Клетка 6 — red_restart_no_dup_publish.sh (Выход-3, публикация; контракт 092 §(2).6).
# Дано: журнал содержит pub-done <X>@refs/heads/main. Когда: pub-start <X>
# refs/heads/main снова. Тогда: rc 1 «уже опубликовано: <X>»; вторая pub-запись
# НЕ создана; pub_state не изменился.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need checkpoint
K=red_restart_no_dup_publish

kletka() {
  o92_world
  o92_toy dupP
  o92_rnd_task; W_TASK="$O92_TASK"
  o92_rnd_hex40; local x="$O92_HEX"
  W_PUB='published'
  o92_ev pub-done "$W_TASK" "$x@refs/heads/main"
  o92_write_state "$O92_STATE"
  o92_write_events "$O92_STATE"
  # Повторный pub-start того же ключа (candidate, target):
  o92_probe checkpoint event pub-start "$W_TASK" "$x@refs/heads/main"
  o92_assert_rc "$K" 1 || return
  o92_assert_err "$K" "$O92L_OPUBL_PRE$x" || return
  [ "$(awk -F'\t' '$2=="pub-done"||$2=="pub-start"{n++} END{print n+0}' "$O92_STATE/events.tsv")" -eq 1 ] \
    || { o92_red "$K" "вторая pub-запись создана"; return; }
  o92_probe checkpoint get pub_state
  o92_assert_rc "$K" 0 || return
  o92_assert_stdout_is "$K" "$W_PUB" || return
  o92_ok "$K"
}
kletka
exit "$O92_RED"
