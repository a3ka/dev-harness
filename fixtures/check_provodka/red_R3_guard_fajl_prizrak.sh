#!/usr/bin/env bash
# R3 — guard-файл не существует: «- guard=scripts/ghost.sh» (г1) при ЖИВОМ
# role-канале. v3: г0-доп выигрывает только когда предметного канала нет ВОВСЕ;
# с role/charter г0-доп не фаерит, и per-channel г1 судит первый красный guard.
# Стаб-привязка (Н-39): стаб «проверяет только грамматику строки» мёртв здесь —
# честный предмет обязан сходить на диск/HEAD за файлом.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r3_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1
# role-канал живой (норма-строка дословно в fixer.md), чтобы г0-доп НЕ фаерил
# и per-channel г1 судил ghost-guard первым.
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/ghost.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»'
commit_all "$T" 'kontrakt s guard-prizrakom i zhyvym role'
run_barrier "$T"
refuse 'R3' 'проводка: guard-файл не существует: scripts/ghost.sh'
exit 0
