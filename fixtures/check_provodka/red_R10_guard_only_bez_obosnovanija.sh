#!/usr/bin/env bash
# R10 (В1) — guard-only без строки ПРОВОДКА-ЭНФОРСМЕНТ: guard существует и
# подключён, но ни одной role/charter-строки и ни одной непустой строки
# «ПРОВОДКА-ЭНФОРСМЕНТ:» в контракте (г0-доп).
# Стаб-привязка (Н-39): стаб «guard подключён = проводка честна» ловится здесь;
# на G2 (с обоснованием) тот же стаб честен — ветвление по В1, не по вкусу.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r10_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh'
commit_all "$T" 'kontrakt guard-only bez obosnovanija'
run_barrier "$T"
refuse 'R10' 'проводка: guard-only поле без предметного канала и строки ПРОВОДКА-ЭНФОРСМЕНТ'
exit 0
