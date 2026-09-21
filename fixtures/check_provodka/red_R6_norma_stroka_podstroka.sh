#!/usr/bin/env bash
# R6 — норма-строка ПОДСТРОКОЙ чужой строки: roles/fixer.md несёт норму только
# внутри более длинной строки (г4, якорь -x). Подстрочный матч НЕ засчитывается.
# Стаб-привязка (Н-39): стаб «grep без -x» ловится ровно здесь — на R5 он честен.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r6_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1
printf '# role fixture\n\nVnutri dlinnoj stroki sprjatana Norma stroki roli v igrushke R. dalshe tekst\n' > "$T/roles/fixer.md"
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»'
commit_all "$T" 'kontrakt s podstrochnoj normoj'
run_barrier "$T"
refuse 'R6' 'проводка: норма-строка не найдена в role-файле: roles/fixer.md'
exit 0
