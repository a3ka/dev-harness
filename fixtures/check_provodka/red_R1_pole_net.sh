#!/usr/bin/env bash
# R1 — поля нет: в контракте отсутствует строка «ПРОВОДКА:» (г0).
# Стаб-привязка (Н-39): вход различает барьер от заглушки «любой файл проходит» —
# честный предмет обязан отказать ДО разбора каналов, именем г0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r1_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1
put_contract "$T" ''
commit_all "$T" 'kontrakt bez polja PROVODKA'
run_barrier "$T"
refuse 'R1' 'проводка: поле ПРОВОДКА отсутствует'
exit 0
