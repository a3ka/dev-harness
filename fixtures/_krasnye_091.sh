#!/usr/bin/env bash
# Раннер красной/зелёной пачки 091 «ротация HANDOFF» — агрегатор ОДНОЙ семьи:
# fixtures/handoff_rotate/ (батарея red_rotate_091.sh + стаб-пак red_stuby_091.sh).
#
# Использование:
#   bash fixtures/_krasnye_091.sh              # прогон из корня worktree
#   bash fixtures/_krasnye_091.sh <корень>     # альтернативный корень дерева
#
# Семантика (контракт 091 §Приёмка):
#   1. Стаб-пак red_stuby_091.sh — НЕ требует субъекта (мини-субъекты свои): красный
#      стаб-пак = сломанный каркас → rc 2 NOT_IMPLEMENTED, предмет не судится.
#   2. Субъекта scripts/handoff_rotate.sh нет (список H91_SUBJECTS в _toy.sh —
#      единственный) → печать «красная: предмет отсутствует», rc 1, батарея НЕ
#      запускается (урок Н-198: без прогона батареи).
#   3. Субъект есть → батарея red_rotate_091.sh: rc 0 ⟺ все клетки зелёные, каждая
#      красная печатает свой код клетки.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${1:-$(cd "$HERE/.." && pwd)}" && pwd -P)" || { printf 'NOT_IMPLEMENTED: корень не каталог\n' >&2; exit 2; }
FAM="$HERE/handoff_rotate"
# shellcheck disable=SC1090
. "$FAM/_toy.sh"

bash "$FAM/red_stuby_091.sh" "$ROOT" || {
  printf 'NOT_IMPLEMENTED: стаб-пак 091 красен — каркас сломан, предмет не судится\n' >&2
  exit 2
}

miss="$(h91_missing_subjects "$ROOT")"
if [ -n "$miss" ]; then
  printf 'красная: предмет отсутствует\n'
  printf 'КРАСНОЕ 091: нет %s (корень %s)\n' "$miss" "$ROOT" >&2
  exit 1
fi

bash "$FAM/red_rotate_091.sh" "$ROOT"
exit $?
