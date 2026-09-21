#!/usr/bin/env bash
# R2 — строка вне грамматики: канал «- banana=…» не matches ни один канал (г0).
# Стаб-привязка (Н-39): стаб «пропускает неизвестные строки» ловится именно здесь —
# отказ обязан НЕСТИ САМУ СТРОКУ (именованный вход, не «поле невалидно»).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r2_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1
BAD='- banana=chto-to-postoronnee'
put_contract "$T" "ПРОВОДКА:
- guard=scripts/check_ok.sh
$BAD"
commit_all "$T" 'kontrakt so strokoj vne grammatiki'
run_barrier "$T"
refuse 'R2' 'проводка: строка вне грамматики: - banana=chto-to-postoronnee'
exit 0
