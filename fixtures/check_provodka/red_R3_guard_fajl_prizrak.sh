#!/usr/bin/env bash
# R3 — guard-файл не существует: «- guard=scripts/ghost.sh» (г1), при этом имя
# ПОДКЛЮЧЕНО в .githooks — чтобы красное пришло именем г1, а не орфана (г2).
# Стаб-привязка (Н-39): стаб «проверяет только грамматику строки» мёртв здесь —
# честный предмет обязан сходить на диск/HEAD за файлом.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r3_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1
printf 'bash scripts/ghost.sh\n' >> "$T/.githooks/pre-commit"
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/ghost.sh'
commit_all "$T" 'kontrakt s guard-prizrakom'
run_barrier "$T"
refuse 'R3' 'проводка: guard-файл не существует: scripts/ghost.sh'
exit 0
