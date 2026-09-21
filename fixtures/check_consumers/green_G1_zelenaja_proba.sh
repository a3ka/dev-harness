#!/usr/bin/env bash
# G1 (C-семья, v3) — писатель в окне, ПОТРЕБИТЕЛЬ-проба зелёная, ЗОНА-строки
# потребителя НЕТ: rc 0. Позитив-контроль уточнён к2-Б1: покрытие даёт ТОЛЬКО
# проба исполнения; зона не нужна и не считается (парный красный C2 — зона без
# пробы красна).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/cg1_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_crepo "$T" fixtures/reader.sh
touch_writer "$T"
printf '#!/usr/bin/env bash\nexit 0\n' > "$T/probe_green.sh"
commit_all "$T" 'pravka pisatelja i zeljonaja proba'
put_draft "$T" "$CENSUS

ПОТРЕБИТЕЛЬ fixtures/reader.sh: bash probe_green.sh"
run_gate "$T" contracts/001-x.md
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: CG1: потребитель с зелёной пробой (без зоны) дал rc %s:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
printf 'CG1: писатель в окне, потребитель покрыт ТОЛЬКО зелёной пробой — rc 0\n' >&2
exit 0
