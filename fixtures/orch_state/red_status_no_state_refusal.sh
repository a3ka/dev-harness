#!/usr/bin/env bash
# Клетка 16 — red_status_no_state_refusal.sh (И-4; вердикт adversary круг 1, находка 1:
# пустой ORCH_STATE_DIR маскировался УСПЕШНОЙ семиполевой сводкой rc 0 — выдуманное
# состояние при полном его отсутствии). Один вход — СВОЁ предъявление: каталог шва
# пуст (state.tsv/events.tsv НЕ существуют) → orch_status обязан rc 1 с именованной
# причиной «состояние отсутствует» (И-4: rc 1 у orch_status — только грамматика
# состояния/отсутствие состояния) и НЕ печатать выдуманную сводку (маркеры
# «task: -» / «pub_state: unknown»). Ожидания — в памяти ДО вызова (правило 8).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
O92_ROOT="$(cd "${1:-$HERE/../..}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
. "$HERE/_toy.sh"
o92_need status
K=red_status_no_state_refusal

kletka() {
  # Пустой шов: o92_toy создаёт repo и ПУСТОЙ каталог состояния, файлы не пишутся:
  o92_world
  o92_toy nsr
  if [ -e "$O92_STATE/state.tsv" ] || [ -e "$O92_STATE/events.tsv" ]; then
    printf 'NOT_IMPLEMENTED: предусловие — файлы состояния уже существуют\n' >&2
    exit 2
  fi
  o92_probe status
  o92_assert_rc "$K" 1 || return
  o92_assert_err "$K" "$O92L_NETSOST" || return
  o92_assert_noout "$K" 'task: -' || return
  o92_assert_noout "$K" 'pub_state: unknown' || return
  o92_ok "$K"
}
kletka
exit "$O92_RED"
