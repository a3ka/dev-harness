#!/usr/bin/env bash
# Клетка 11 — red_checkpoint_grammar.sh (И-2; контракт 092 §(2).11). Три под-входа,
# каждый — своё предъявление: неизвестный ключ foo, stage вне алфавита hot,
# next_step с \x01. Когда: put каждого. Тогда: каждый rc 1 «состояние вне
# грамматики: <ключ>»; файлы байт-в-байт до/после.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need checkpoint
K=red_checkpoint_grammar

kletka() {
  local keys=(foo stage next_step)
  local vals=(bar hot $'\x01')
  local i k v s1 s2 rc
  for i in 0 1 2; do
    k="${keys[$i]}"; v="${vals[$i]}"
    o92_world
    o92_toy "gr$i"
    o92_rnd_task; W_TASK="$O92_TASK"
    o92_write_state "$O92_STATE"
    o92_write_events "$O92_STATE"
    s1="$(o92_sha "$O92_STATE/state.tsv")"
    s2="$(o92_sha "$O92_STATE/events.tsv")"
    o92_probe checkpoint put "$k" "$v"
    rc=$?
    [ "$rc" -eq 1 ] || { o92_red "$K[$k]" "rc=$rc, ожидался 1"; continue; }
    o92_assert_err "$K[$k]" "$O92L_GRAMM_PRE$k" || continue
    [ "$(o92_sha "$O92_STATE/state.tsv")" = "$s1" ] \
      || { o92_red "$K[$k]" "state.tsv не байт-в-байт после отказа"; continue; }
    [ "$(o92_sha "$O92_STATE/events.tsv")" = "$s2" ] \
      || { o92_red "$K[$k]" "events.tsv не байт-в-байт после отказа"; continue; }
  done
  [ "$O92_RED" -eq 0 ] && o92_ok "$K"
  return 0
}
kletka
exit "$O92_RED"
