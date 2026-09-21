#!/usr/bin/env bash
# D2 — первая строка вердикта FAIL: ревьюер отказал → писатель отказывает,
# тега нет. Отказ ревьюера НЕ отпирается клапаном РАЗРЕШИЛ (риск-3 контракта).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/d2_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_drepo "$T" "$GREEN_PROVODKA"
put_verdict "$T" contracts-001-v1.md 'FAIL'
commit_all "$T" 'verdikt-fail'
run_writer "$T" 'prizemlenie mimo verdikta'
refuse 'D2' 'done: вердикт ревьюера FAIL'
[ -z "$(done_tags "$T")" ] || { printf 'ОТКАЗ: D2: после отказа записаны done-теги: %s\n' "$(done_tags "$T")" >&2; exit 1; }
exit 0
