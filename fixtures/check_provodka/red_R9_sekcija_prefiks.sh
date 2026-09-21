#!/usr/bin/env bash
# R9 — префикс секции: charter ссылается на §Воркфлоу — строгий префикс живого
# полного заголовка «## Воркфлоу майлстоуна» (живой якорь, опечатка байт-в-байт;
# г5 — ТОЧНЫЙ матч заголовка, Б3). Префикс — вне грамматики.
# Стаб-привязка (Н-39): стаб «grep -F заголовка как подстроки» ловится здесь —
# префиксный матч обязан быть красным.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r9_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу «Norma stroki ustava v igrushke R.»'
commit_all "$T" 'kontrakt s prefiksom sekcii'
run_barrier "$T"
refuse 'R9' 'проводка: секция устава не найдена: §Воркфлоу'
exit 0
