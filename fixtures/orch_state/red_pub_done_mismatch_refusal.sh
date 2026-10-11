#!/usr/bin/env bash
# Клетка 17 — red_pub_done_mismatch_refusal.sh (И-8; вердикт adversary круг 1, находка 2:
# pub-done чужой задачи/кандидата безусловно повышал pub_state ТЕКУЩЕЙ задачи).
# ЧЕТЫРЕ входа, каждый — СВОЁ предъявление; клетка красна, если хотя бы один вход
# прошёл неправильно. И-8 разрешает доказательство журналом ТОЛЬКО для
# pub-done <ТЕКУЩИЙ task> <ТЕКУЩИЙ candidate>@<target>. Входы а/б/в — несовпадение
# subject И/ИЛИ candidate → rc 1 «pub-done чужой задачи или кандидата», state.tsv И
# events.tsv байт-в-байт (sha256 ДО=ПОСЛЕ, снимки в памяти — правило 8). Вход-г
# (зелёная пара) — совпадение обоих → rc 0, get pub_state → published (санкционированный
# путь не закрыт наглухо: отказ «всего подряд» клетку тоже краснит — вход-г).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need checkpoint
K=red_pub_done_mismatch_refusal

neizm() {  # <код> <sha-state> <sha-events> — оба файла байт-в-байт (снимки ДО — в памяти)
  [ "$(o92_sha "$O92_STATE/state.tsv")" = "$2" ] && [ "$(o92_sha "$O92_STATE/events.tsv")" = "$3" ] \
    || { o92_red "$1" "файлы изменились на чужом pub-done"; return 1; }
  return 0
}

kletka() {
  # Конформные случайные значения (демаркация §019: инвариантность к значениям):
  o92_rnd_task; local t="$O92_TASK"
  local chuzh=''
  while [ -z "$chuzh" ] || [ "$chuzh" = "$t" ]; do o92_rnd_task; chuzh="$O92_TASK"; done
  o92_rnd_hex40; local ca="$O92_HEX"
  o92_rnd_hex40; local cb="$O92_HEX"

  # Вход-а (оба чужие — вход вердикта дословно): pub-done <чужой task> <чужой cand>@target
  o92_world; W_TASK="$t"; W_CAND="$ca"; W_PUB='pushed'
  o92_toy pdr_a; o92_write_state "$O92_STATE"; o92_write_events "$O92_STATE"
  local sa sb; sa="$(o92_sha "$O92_STATE/state.tsv")"; sb="$(o92_sha "$O92_STATE/events.tsv")"
  o92_probe checkpoint event pub-done "$chuzh" "$cb@refs/heads/main"
  o92_assert_rc "$K[а]" 1 || return
  o92_assert_err "$K[а]" "$O92L_CHUZH_PUBDONE" || return
  neizm "$K[а]" "$sa" "$sb" || return

  # Вход-б (subject свой, candidate чужой): pub-done <task> <чужой cand>@target
  o92_world; W_TASK="$t"; W_CAND="$ca"; W_PUB='pushed'
  o92_toy pdr_b; o92_write_state "$O92_STATE"; o92_write_events "$O92_STATE"
  sa="$(o92_sha "$O92_STATE/state.tsv")"; sb="$(o92_sha "$O92_STATE/events.tsv")"
  o92_probe checkpoint event pub-done "$t" "$cb@refs/heads/main"
  o92_assert_rc "$K[б]" 1 || return
  o92_assert_err "$K[б]" "$O92L_CHUZH_PUBDONE" || return
  neizm "$K[б]" "$sa" "$sb" || return

  # Вход-в (subject чужой, candidate свой): pub-done <чужой task> <cand>@target
  o92_world; W_TASK="$t"; W_CAND="$ca"; W_PUB='pushed'
  o92_toy pdr_v; o92_write_state "$O92_STATE"; o92_write_events "$O92_STATE"
  sa="$(o92_sha "$O92_STATE/state.tsv")"; sb="$(o92_sha "$O92_STATE/events.tsv")"
  o92_probe checkpoint event pub-done "$chuzh" "$ca@refs/heads/main"
  o92_assert_rc "$K[в]" 1 || return
  o92_assert_err "$K[в]" "$O92L_CHUZH_PUBDONE" || return
  neizm "$K[в]" "$sa" "$sb" || return

  # Вход-г (зелёная пара): pub-done <task> <cand>@target — совпадение обоих → published:
  o92_world; W_TASK="$t"; W_CAND="$ca"; W_PUB='pushed'
  o92_toy pdr_g; o92_write_state "$O92_STATE"; o92_write_events "$O92_STATE"
  o92_probe checkpoint event pub-done "$t" "$ca@refs/heads/main"
  o92_assert_rc "$K[г]" 0 || return
  o92_probe checkpoint get pub_state
  o92_assert_rc "$K[г]" 0 || return
  o92_assert_stdout_is "$K[г]" 'published' || return
  o92_ok "$K"
}
kletka
exit "$O92_RED"
