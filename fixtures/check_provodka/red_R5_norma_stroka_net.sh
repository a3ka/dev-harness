#!/usr/bin/env bash
# R5 — role-файл есть, строки нет: roles/fixer.md существует, норма-строки в нём
# нет (г4). Файл создаётся НАД честной основой: г3 зелёный, красит именно г4.
# Стаб-привязка (Н-39): стаб «хватает существования role-файла» мёртв здесь.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r5_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 0 1
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»'
commit_all "$T" 'kontrakt s otvetstvennoj normoj bez stroki'
run_barrier "$T"
refuse 'R5' 'проводка: норма-строка не найдена в role-файле: roles/fixer.md'
exit 0
