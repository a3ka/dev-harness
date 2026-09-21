#!/usr/bin/env bash
# C4 — путь маппинга не существует: пара
# freeze_contract.sh→fixtures/ghost_reader.sh (писатель-минимум настоящий,
# арбитраж 038-Б3) ссылается на несуществующий путь → отказ п1 (грамматика
# путей; имя файла пары выведено из consumer-аргумента каркасом — согласовано
# с парой, красит именно ветвь пути). Три писателя-минимума при этом сидят
# (пара-призрак — одна из трёх).
# Стаб-привязка (Н-39): стаб «маппинг читается = грамматика ок» ловится здесь;
# на C1 тот же стаб честен (там пути существуют).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/c4_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_crepo "$T" fixtures/ghost_reader.sh
put_draft "$T" "$CENSUS"
run_gate "$T" contracts/001-x.md
refuse 'C4' 'потребители 116: путь маппинга не существует: fixtures/ghost_reader.sh'
exit 0
