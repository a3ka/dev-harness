#!/usr/bin/env bash
# D7 — контракт не закоммичен: файл есть только в рабочем дереве → отказ ДО
# разбора вердиктов и ПРОВОДКИ (шаг 4; незакоммиченность клапаном НЕ отпирается).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/d7_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_drepo "$T" "$GREEN_PROVODKA"
printf '# kontrakt 002 ne zakommichen\n' > "$T/contracts/002-draft.md"
LAST_OUT="$(cd "$T" && bash "$SUBJ" contracts/002-draft.md 'prizemlenie' 2>&1)"; LAST_RC=$?
refuse 'D7' 'done: контракт не закоммичен на HEAD'
[ -z "$(done_tags "$T")" ] || { printf 'ОТКАЗ: D7: после отказа записаны done-теги\n' >&2; exit 1; }
exit 0
