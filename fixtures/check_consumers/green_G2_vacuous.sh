#!/usr/bin/env bash
# G2 (C-семья) — vacuous: после границы окна НЕ тронут ни один зарегистрированный
# писатель (только черновик) → rc 0. Гейт не требует покрытия там, где правки
# писателя нет; вечно-красный гейт неотличим от работающего.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/cg2_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_crepo "$T" fixtures/reader.sh
put_draft "$T" '## Ispolniteli i zony
ЗОНА implementer: contracts/001-x.md'
run_gate "$T" contracts/001-x.md
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: CG2: vacuous-окно дало rc %s:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
printf 'CG2: писатель вне окна — vacuous rc 0\n' >&2
exit 0
