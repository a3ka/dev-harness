#!/usr/bin/env bash
# C3 — ПОТРЕБИТЕЛЬ-проба красна: черновик несёт строку
# «ПОТРЕБИТЕЛЬ fixtures/reader.sh: bash probe_red.sh», гейт ИСПОЛНЯЕТ пробу,
# она даёт rc 1 → отказ именем красной пробы (правило 8: оракул — сам
# потребитель, гейт исполняет пробу, а не читает её прозу).
# Стаб-привязка (Н-39): стаб «наличие строки = верифицирован» ловится здесь.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/c3_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_crepo "$T" fixtures/reader.sh
touch_writer "$T"
printf '#!/usr/bin/env bash\nexit 1\n' > "$T/probe_red.sh"
commit_all "$T" 'pravka pisatelja i krasnaja proba'
put_draft "$T" "$CENSUS

ПОТРЕБИТЕЛЬ fixtures/reader.sh: bash probe_red.sh"
run_gate "$T" contracts/001-x.md
refuse 'C3' 'потребители 116: ПОТРЕБИТЕЛЬ-проба красна: fixtures/reader.sh: rc 1'
exit 0
