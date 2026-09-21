#!/usr/bin/env bash
# R4 — guard есть, вызова нет (.githooks/.github чисты, г2) при ЖИВОМ role-канале.
# v3: г0-доп выигрывает только когда предметного канала нет ВОВСЕ; с role/charter
# per-channel г2 судит первый красный guard (guard существует, но не подключён).
# Стаб-привязка (Н-39): стаб «существование guard = подключён» ловится здесь —
# отказ обязан назвать путь и места подключения.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r4_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1
# pre-commit вызывает ДРУГОЙ скрипт, workflows нет — guard есть, но не подключён.
printf 'bash scripts/different_ok.sh\n' > "$T/.githooks/pre-commit"
rm -rf "$T/.github"
# role-канал живой, чтобы г0-доп НЕ фаерил и per-channel г2 судил первый.
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»'
commit_all "$T" 'kontrakt s osirotevshim guard i zhyvym role'
run_barrier "$T"
refuse 'R4' 'проводка: guard не подключён: scripts/check_ok.sh не вызывается в .githooks/ или .github/workflows/'
exit 0
