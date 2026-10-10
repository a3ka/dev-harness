#!/usr/bin/env bash
# Клетка 5 — red_restart_no_dup_round.sh (Выход-3, круг; контракт 092 §(2).5).
# Дано: два round-fail (subject C, ref v1@sha1 и v2@sha2). Когда: повторная запись
# ТЕХ ЖЕ двух троек после «рестарта». Тогда: no-op; счёт кругов = 2 (не 4).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need checkpoint status
K=red_restart_no_dup_round

kletka() {
  o92_world
  o92_toy dupR
  o92_rnd_task; W_TASK="$O92_TASK"; W_STAGE='judge'
  # Два вердикт-файла — реальные blob-sha (ref-грамматика round-*):
  local d="$O92SCR/vf"; mkdir -p "$d"
  o92_rnd_line; printf 'FAIL-1: %s\n' "$O92_LINE" > "$d/a.md"
  local sa; sa="$(o92_blob_sha "$d/a.md")"
  o92_rnd_line; printf 'FAIL-2: %s\n' "$O92_LINE" > "$d/b.md"
  local sb; sb="$(o92_blob_sha "$d/b.md")"
  local r1="verdicts/092-a.md@$sa" r2="verdicts/092-b.md@$sb"
  o92_ev round-fail "$W_TASK" "$r1"
  o92_ev round-fail "$W_TASK" "$r2"
  o92_write_state "$O92_STATE"
  o92_write_events "$O92_STATE"
  # Повторная запись ТЕХ ЖЕ двух троек после «рестарта»:
  o92_probe checkpoint event round-fail "$W_TASK" "$r1"
  o92_assert_rc "$K" 0 || return
  o92_assert_out "$K" "$O92L_ZAPIS" || return
  o92_probe checkpoint event round-fail "$W_TASK" "$r2"
  o92_assert_rc "$K" 0 || return
  o92_assert_out "$K" "$O92L_ZAPIS" || return
  [ "$(o92_events_count round-fail "$W_TASK")" -eq 2 ] \
    || { o92_red "$K" "round-fail строк в журнале не 2 (дубль)"; return; }
  o92_probe status
  o92_assert_rc "$K" 0 || return
  o92_assert_out "$K" "${O92L_KRUGOV_PRE}2" || return
  o92_ok "$K"
}
kletka
exit "$O92_RED"
