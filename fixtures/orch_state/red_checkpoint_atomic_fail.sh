#!/usr/bin/env bash
# Клетка 10 — red_checkpoint_atomic_fail.sh (И-1; контракт 092 §(2).10). ТРИ входа,
# каждый — своё предъявление; клетка красна, если хотя бы один вход прошёл неправильно.
# Вход-а: валидное состояние; ORCH_STATE_DIR → каталог только-для-чтения. Когда: put.
# Тогда: rc 1 «запись состояния не удалась»; sha256 state.tsv/events.tsv ДО/ПОСЛЕ
# равны (снимок в памяти).
# Вход-б: валидное состояние (случайный task), журнал пуст; chmod a-w events.tsv
# (каталог записываем). Когда: init <новый-task> -. Тогда: rc 1 «запись состояния
# не удалась»; sha256 state.tsv И events.tsv ДО=ПОСЛЕ; get task → прежний task.
# Вход-в: pub_state=pushed, candidate 40-hex, журнал пуст; запись state невозможна
# при записываемом журнале (.state.tsv.tmp занят непустым каталогом — конформный
# отказ класса EACCES/EEXIST). Когда: event pub-done <task> <cand>@refs/heads/main.
# Тогда: rc 1 «запись состояния не удалась»; sha256 обоих файлов ДО=ПОСЛЕ;
# повторный event pub-done после снятия отказа → rc 0 и get pub_state → published
# (не «уже записано» с pushed — ловит застревание полузаписи).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need checkpoint
K=red_checkpoint_atomic_fail

kletka() {
  # Вход-а: однофайловый put при read-only каталоге шва:
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
  [ "$rc" -eq 1 ] || { o92_red "$K[а]" "rc=$rc, ожидался 1"; return; }
  o92_assert_err "$K[а]" "$O92L_ZAPFAIL" || return
  [ "$(o92_sha "$O92_STATE/state.tsv")" = "$s1" ] \
    || { o92_red "$K[а]" "state.tsv изменился при отказе записи"; return; }
  [ "$(o92_sha "$O92_STATE/events.tsv")" = "$s2" ] \
    || { o92_red "$K[а]" "events.tsv изменился при отказе записи"; return; }

  # Вход-б: составная init при read-only events.tsv (каталог записываем) —
  # атомарность КАК ЦЕЛОЕ: отказ шага журнала не тянет за собой state:
  o92_world
  o92_toy atom_b
  o92_rnd_task; W_TASK="$O92_TASK"
  o92_rnd_line; W_NEXT="$O92_LINE"
  W_EVENTS=()
  o92_write_state "$O92_STATE"
  o92_write_events "$O92_STATE"
  local b1 b2 novy
  b1="$(o92_sha "$O92_STATE/state.tsv")"
  b2="$(o92_sha "$O92_STATE/events.tsv")"
  novy=''
  while :; do
    o92_rnd_task
    [ "$O92_TASK" != "$W_TASK" ] && { novy="$O92_TASK"; break; }
  done
  chmod a-w "$O92_STATE/events.tsv"
  o92_probe checkpoint init "$novy" -
  rc=$?
  chmod u+w "$O92_STATE/events.tsv"
  [ "$rc" -eq 1 ] || { o92_red "$K[б]" "rc=$rc, ожидался 1"; return; }
  o92_assert_err "$K[б]" "$O92L_ZAPFAIL" || return
  [ "$(o92_sha "$O92_STATE/state.tsv")" = "$b1" ] \
    || { o92_red "$K[б]" "state.tsv изменился при отказе составной init"; return; }
  [ "$(o92_sha "$O92_STATE/events.tsv")" = "$b2" ] \
    || { o92_red "$K[б]" "events.tsv изменился при отказе составной init"; return; }
  o92_probe checkpoint get task
  o92_assert_rc "$K[б]" 0 || return
  o92_assert_stdout_is "$K[б]" "$W_TASK" || return

  # Вход-в: составная pub-done при невозможности записи state (журнал записываем):
  o92_world
  o92_toy atom_v
  o92_rnd_task; W_TASK="$O92_TASK"
  o92_rnd_hex40; W_CAND="$O92_HEX"
  W_PUB='pushed'
  W_EVENTS=()
  o92_write_state "$O92_STATE"
  o92_write_events "$O92_STATE"
  local v1 v2
  v1="$(o92_sha "$O92_STATE/state.tsv")"
  v2="$(o92_sha "$O92_STATE/events.tsv")"
  mkdir -p "$O92_STATE/.state.tsv.tmp/x"   # отказ записи state: открытие tmp — OSError
  o92_probe checkpoint event pub-done "$W_TASK" "$W_CAND@refs/heads/main"
  rc=$?
  [ "$rc" -eq 1 ] || { o92_red "$K[в]" "rc=$rc, ожидался 1"; return; }
  o92_assert_err "$K[в]" "$O92L_ZAPFAIL" || return
  [ "$(o92_sha "$O92_STATE/state.tsv")" = "$v1" ] \
    || { o92_red "$K[в]" "state.tsv изменился при отказе составной pub-done"; return; }
  [ "$(o92_sha "$O92_STATE/events.tsv")" = "$v2" ] \
    || { o92_red "$K[в]" "events.tsv изменился при отказе составной pub-done"; return; }
  rm -rf "$O92_STATE/.state.tsv.tmp"       # снятие отказа
  o92_probe checkpoint event pub-done "$W_TASK" "$W_CAND@refs/heads/main"
  o92_assert_rc "$K[в]" 0 || return         # не «уже записано» с pushed
  o92_probe checkpoint get pub_state
  o92_assert_rc "$K[в]" 0 || return
  o92_assert_stdout_is "$K[в]" 'published' || return
  o92_ok "$K"
}
kletka
exit "$O92_RED"
