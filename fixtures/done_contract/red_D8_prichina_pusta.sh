#!/usr/bin/env bash
# D8 — причина пуста: отказ ДО всех остальных проверок. Игрушка НАРОЧНО без
# вердикта ревьюера: если порядок нарушен, отказ назовёт вердикт, а не причину —
# вход различает порядок, а не только факт отказа.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/d8_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_drepo "$T" "$GREEN_PROVODKA"
rm -f "$T/verdicts/review/contracts-001-v1.md"
commit_all "$T" 'bez verdikta'
run_writer "$T" ''
refuse 'D8' 'done: причина пуста'
[ -z "$(done_tags "$T")" ] || { printf 'ОТКАЗ: D8: после отказа записаны done-теги\n' >&2; exit 1; }
exit 0
