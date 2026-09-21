#!/usr/bin/env bash
# C5 — контракт правит писателя, замер-строки маппинга нет: писатель тронут в
# окне, маппинг на дереве его frozen-тега ЕСТЬ (не регистратор), черновик несёт
# зелёную ПОТРЕБИТЕЛЬ-пробу, но БЕЗ census-строки → отказ п1 (наличие замера;
# исполнение и пересчёт — грамматика 036-В2 на заморозке носителя, ЗДЕСЬ
# проверяется НАЛИЧИЕ).
# Стаб-привязка (Н-39): стаб «гейт смотрит только п3» ловится здесь —
# дисциплина census вводится тем же гейтом.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/c5_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_crepo "$T" fixtures/reader.sh
touch_writer "$T"
printf '#!/usr/bin/env bash\nexit 0\n' > "$T/probe_green.sh"
commit_all "$T" 'pravka pisatelja s zelenoj probou'
put_draft "$T" "ПОТРЕБИТЕЛЬ fixtures/reader.sh: bash probe_green.sh"
run_gate "$T" contracts/001-x.md
refuse 'C5' 'потребители 116: замер маппинга отсутствует (контракт правит писателя scripts/freeze_contract.sh)'
exit 0
