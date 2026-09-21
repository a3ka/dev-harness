#!/usr/bin/env bash
# C2 (v3, анти-Б1) — потребитель В ЗОНА-строках черновика, пробы НЕТ: тот же
# отказ «нет ПОТРЕБИТЕЛЬ-пробы». Обход к2-Б1 (писатель меняет формат,
# потребитель перечислен в ЗОНА implementer, гейт даёт 0, потребитель ни разу
# не исполнен) обязан быть КРАСНЫМ: перечисление ≠ исполнение, зона назначает
# исполнителя, но не проверяет его.
# Стаб-привязка (Н-39): стаб «зона покрывает потребителя» ловится ТОЛЬКО здесь —
# на C1 он честен (там зоны потребителя тоже нет).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/c2z_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_crepo "$T" fixtures/reader.sh
touch_writer "$T"
commit_all "$T" 'pravka pisatelja v okne'
put_draft "$T" "$CENSUS

## Ispolniteli i zony
ЗОНА implementer: fixtures/reader.sh scripts/freeze_contract.sh"
run_gate "$T" contracts/001-x.md
refuse 'C2' 'потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/reader.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы'
exit 0
