#!/usr/bin/env bash
# Зелёная case-клетка — case_checkpoint_roundtrip.sh (контракт 092 §(2), строка 150:
# put→get побайтово). Живёт в green/ — запускается ТОЛЬКО агрегатором семьи
# fixtures/_krasnye_092.sh (сам-тест семьи вне case_*-глоба раннера, прецедент
# 058/059/060; легальность probe-only каталога — см. .probe-only).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/../_toy.sh"
o92_need checkpoint
K=case_checkpoint_roundtrip

kletka() {
  o92_world
  o92_toy roundtrip
  o92_rnd_task; local t1="$O92_TASK"
  o92_rnd_task; local t2="$O92_TASK"
  o92_rnd_line; local next="$O92_LINE"
  o92_rnd_hex40; local cand="$O92_HEX"
  o92_rnd_hex40; local ci="ci:$O92_HEX"
  local pairs=(
    "task $t2"
    "stage frozen"
    "candidate $cand"
    "last_proven stage@3"
    "waiting $ci"
    "next_step $next"
    "pub_state pushed"
  )
  local p k v
  o92_probe checkpoint init "$t1" -
  o92_assert_rc "$K" 0 || return
  for p in "${pairs[@]}"; do
    k="${p%% *}"; v="${p#* }"
    o92_probe checkpoint put "$k" "$v"
    o92_assert_rc "$K" 0 || return
    o92_probe checkpoint get "$k"
    o92_assert_rc "$K" 0 || return
    o92_assert_stdout_is "$K" "$v" || return
    grep -Fxq "$(printf '%s\t%s' "$k" "$v")" "$O92_STATE/state.tsv" \
      || { o92_red "$K" "state.tsv без строки «$k<TAB>$v»"; return; }
  done
  o92_ok "$K"
}
kletka
exit "$O92_RED"
