#!/usr/bin/env bash
# R8 — шапка «ПРОВОДКА:» без канальных строк (г0: поле пусто).
# Стаб-привязка (Н-39): стаб «шапка = поле есть» ловится здесь — пустое поле
# обязано краснеть само, а не падать на каналах (R1/R2 красят другое).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r8_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1
put_contract "$T" 'ПРОВОДКА:'
commit_all "$T" 'kontrakt s pustoj shapkoj polja'
run_barrier "$T"
refuse 'R8' 'проводка: поле пусто'
exit 0
