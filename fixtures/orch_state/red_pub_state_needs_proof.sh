#!/usr/bin/env bash
# Клетка 15 — red_pub_state_needs_proof.sh (И-8; контракт 092 §(2).15). ЧЕТЫРЕ входа,
# каждый — своё предъявление; клетка красна, если хотя бы один вход прошёл неправильно.
# Вход-а: candidate=-, журнал пуст, toy без refs/remotes/origin/main → put pub_state
# published rc 1 «публикация не доказана: -», sha256 state ДО=ПОСЛЕ.
# Вход-б: candidate 40-hex НЕ достижим из origin/main (o92_pub_git нет), журнал пуст
# → rc 1 «публикация не доказана: <candidate>», байт-в-байт.
# Вход-в (зелёная пара): candidate достижим (o92_pub_git да), журнал пуст → rc 0,
# get pub_state → published.
# Вход-г (зелёная пара): candidate НЕ достижим, журнал содержит pub-done <task>
# <cand>@refs/heads/main → rc 0, published.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need checkpoint
K=red_pub_state_needs_proof

kletka() {
  # Вход-а: candidate=-, git-факта нет (plain toy не создаёт refs/remotes/origin/main),
  # журнал пуст — голый put обязан отказать:
  o92_world
  o92_toy pnp_a
  W_PUB='pushed'
  o92_write_state "$O92_STATE"
  o92_write_events "$O92_STATE"
  local sa
  sa="$(o92_sha "$O92_STATE/state.tsv")"
  o92_probe checkpoint put pub_state published
  o92_assert_rc "$K[а]" 1 || return
  o92_assert_err "$K[а]" "$O92L_NEDOKAZ_PRE-" || return
  [ "$(o92_sha "$O92_STATE/state.tsv")" = "$sa" ] \
    || { o92_red "$K[а]" "state.tsv изменился при отказе без доказательства"; return; }

  # Вход-б: candidate 40-hex НЕ достижим из origin/main, журнал пуст:
  o92_world
  o92_toy pnp_b
  o92_pub_git нет
  W_CAND="$O92_CAND"; W_PUB='pushed'
  o92_write_state "$O92_STATE"
  o92_write_events "$O92_STATE"
  local sb
  sb="$(o92_sha "$O92_STATE/state.tsv")"
  o92_probe checkpoint put pub_state published
  o92_assert_rc "$K[б]" 1 || return
  o92_assert_err "$K[б]" "$O92L_NEDOKAZ_PRE$W_CAND" || return
  [ "$(o92_sha "$O92_STATE/state.tsv")" = "$sb" ] \
    || { o92_red "$K[б]" "state.tsv изменился при отказе без доказательства"; return; }

  # Вход-в (зелёная пара): candidate достижим из origin/main — git-факт доказывает:
  o92_world
  o92_toy pnp_v
  o92_pub_git да
  W_CAND="$O92_CAND"; W_PUB='pushed'
  o92_write_state "$O92_STATE"
  o92_write_events "$O92_STATE"
  o92_probe checkpoint put pub_state published
  o92_assert_rc "$K[в]" 0 || return
  o92_probe checkpoint get pub_state
  o92_assert_rc "$K[в]" 0 || return
  o92_assert_stdout_is "$K[в]" 'published' || return

  # Вход-г (зелёная пара): candidate НЕ достижим, но журнал содержит pub-done того же
  # candidate — событие доказывает (санкционированный путь повышения):
  o92_world
  o92_toy pnp_g
  o92_pub_git нет
  W_CAND="$O92_CAND"; W_PUB='pushed'
  o92_ev pub-done "$W_TASK" "$W_CAND@refs/heads/main"
  o92_write_state "$O92_STATE"
  o92_write_events "$O92_STATE"
  o92_probe checkpoint put pub_state published
  o92_assert_rc "$K[г]" 0 || return
  o92_probe checkpoint get pub_state
  o92_assert_rc "$K[г]" 0 || return
  o92_assert_stdout_is "$K[г]" 'published' || return
  o92_ok "$K"
}
kletka
exit "$O92_RED"
