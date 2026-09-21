#!/usr/bin/env bash
# D5 — повторный done без РАЗРЕШИЛа: тег done/contracts/001/1 уже жив (история
# игрушки), попытка v2 причиной без строки «РАЗРЕШИЛ-ВЛАДЕЛЕЦ:» → отказ, v2 нет
# (боль Н-117: несанкционированный дубль-тег).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/d5_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_drepo "$T" "$GREEN_PROVODKA"
g "$T" tag -a done/contracts/001/1 -m 'istorija: pervoe prizemlenie'
run_writer "$T" 'povtornoe prizemlenie po inertcii'
refuse 'D5' 'done: v>1 требует строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в причине'
[ -z "$(g "$T" tag -l 'done/contracts/001/2')" ] || { printf 'ОТКАЗ: D5: тег v2 записан после отказа\n' >&2; exit 1; }
exit 0
