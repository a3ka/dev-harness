#!/usr/bin/env bash
# Зелёная case-клетка — case_events_idempotent_green.sh (контракт 092 §(2), строка
# 150: повтор тройки → no-op rc 0). Живёт в green/ — запускается ТОЛЬКО агрегатором
# семьи fixtures/_krasnye_092.sh.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/../_toy.sh"
o92_need checkpoint
K=case_events_idempotent_green

kletka() {
  o92_world
  o92_toy idem
  o92_rnd_task; W_TASK="$O92_TASK"
  local d="$O92SCR/vf"; mkdir -p "$d"
  o92_rnd_line; printf 'FAIL-1: %s\n' "$O92_LINE" > "$d/a.md"
  local r1="verdicts/092-a.md@$(o92_blob_sha "$d/a.md")"
  o92_rnd_line; printf 'FAIL-2: %s\n' "$O92_LINE" > "$d/b.md"
  local r2="verdicts/092-b.md@$(o92_blob_sha "$d/b.md")"
  o92_ev round-fail "$W_TASK" "$r1"
  o92_write_state "$O92_STATE"
  o92_write_events "$O92_STATE"
  # Повтор СНЯТОЙ тройки — no-op rc 0:
  o92_probe checkpoint event round-fail "$W_TASK" "$r1"
  o92_assert_rc "$K" 0 || return
  o92_assert_out "$K" "$O92L_ZAPIS" || return
  [ "$(o92_events_count round-fail "$W_TASK")" -eq 1 ] \
    || { o92_red "$K" "повтор снятой тройки не no-op"; return; }
  # Свежая тройка — запись; её немедленный повтор — no-op:
  o92_probe checkpoint event round-fail "$W_TASK" "$r2"
  o92_assert_rc "$K" 0 || return
  [ "$(o92_events_count round-fail "$W_TASK")" -eq 2 ] \
    || { o92_red "$K" "свежая тройка не записана"; return; }
  o92_probe checkpoint event round-fail "$W_TASK" "$r2"
  o92_assert_rc "$K" 0 || return
  o92_assert_out "$K" "$O92L_ZAPIS" || return
  [ "$(o92_events_count round-fail "$W_TASK")" -eq 2 ] \
    || { o92_red "$K" "повтор свежей тройки не no-op"; return; }
  o92_ok "$K"
}
kletka
exit "$O92_RED"
