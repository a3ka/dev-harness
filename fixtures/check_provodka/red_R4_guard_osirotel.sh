#!/usr/bin/env bash
# R4 — guard есть, вызова нет: .githooks вызывает ДРУГОЙ скрипт, workflows нет (г2).
# Стаб-привязка (Н-39): стаб «существование guard = подключён» ловится здесь —
# отказ обязан назвать путь и места подключения.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r4_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1
printf 'bash scripts/different_ok.sh\n' > "$T/.githooks/pre-commit"
rm -rf "$T/.github"
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh'
commit_all "$T" 'kontrakt s osirotevshim guard'
run_barrier "$T"
refuse 'R4' 'проводка: guard не подключён: scripts/check_ok.sh не вызывается в .githooks/ или .github/workflows/'
exit 0
