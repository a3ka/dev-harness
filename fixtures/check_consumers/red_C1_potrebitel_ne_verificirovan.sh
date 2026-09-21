#!/usr/bin/env bash
# C1 — писатель в окне, ПОТРЕБИТЕЛЬ-пробы нет: registered writer
# scripts/freeze_contract.sh (настоящий путь писателя-минимума, арбитраж 038-Б3)
# тронут коммитом окна frozen/contracts/001/1..HEAD; черновик несёт замер-строку
# (п1 зелёный), но consumer fixtures/reader.sh не покрыт ПРОБОЙ (в ЗОНА-строках
# его тоже нет — чистый случай) → именованный отказ п3.
# Стаб-привязка (Н-39): стаб «гейт смотрит только дифф писателя» ловится здесь.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/c1_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_crepo "$T" fixtures/reader.sh
touch_writer "$T"
commit_all "$T" 'pravka pisatelja v okne'
put_draft "$T" "$CENSUS

## Ispolniteli i zony
ЗОНА implementer: scripts/other.sh"
run_gate "$T" contracts/001-x.md
refuse 'C1' 'потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель fixtures/reader.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы'
exit 0
