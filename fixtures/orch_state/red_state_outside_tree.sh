#!/usr/bin/env bash
# Клетка 12 — red_state_outside_tree.sh (И-1/И-9; контракт 092 §(2).12).
# Дано: чистое toy-дерево (снимок sha256 в памяти). Когда: серия init/put/event/
# status ×N. Тогда: все rc 0; git status --porcelain пуст; дерево байт-в-байт.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need checkpoint status
K=red_state_outside_tree

kletka() {
  o92_world
  o92_toy outside
  o92_rnd_task; W_TASK="$O92_TASK"
  o92_rnd_line; local next="$O92_LINE"
  # round-ref — реальный blob-sha скратч-файла:
  printf 'verdict toy\n' > "$O92SCR/v12.md"
  local ref="verdicts/092-v12.md@$(o92_blob_sha "$O92SCR/v12.md")"
  o92_tree_snap "$O92_TOY" > "$O92SCR/snap_do"
  # Серия ×N — состояние, журнал, сводка, чтение:
  o92_probe checkpoint init "$W_TASK" -
  o92_assert_rc "$K" 0 || return
  o92_probe checkpoint put stage spec
  o92_assert_rc "$K" 0 || return
  o92_probe checkpoint put next_step "$next"
  o92_assert_rc "$K" 0 || return
  o92_probe checkpoint event round-fail "$W_TASK" "$ref"
  o92_assert_rc "$K" 0 || return
  o92_probe status
  o92_assert_rc "$K" 0 || return
  o92_probe checkpoint get task
  o92_assert_rc "$K" 0 || return
  o92_assert_stdout_is "$K" "$W_TASK" || return
  local porc; porc="$(o92_porcelain)"
  [ -z "$porc" ] || { o92_red "$K" "porcelain непуст: $porc"; return; }
  o92_tree_snap "$O92_TOY" > "$O92SCR/snap_posle"
  cmp -s "$O92SCR/snap_do" "$O92SCR/snap_posle" \
    || { o92_red "$K" "дерево toy не байт-в-байт после серии"; return; }
  o92_ok "$K"
}
kletka
exit "$O92_RED"
