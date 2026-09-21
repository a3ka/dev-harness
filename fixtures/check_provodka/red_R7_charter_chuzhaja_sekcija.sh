#!/usr/bin/env bash
# R7 — charter-строка в ДРУГОЙ секции устава: секция «Воркфлоу майлстоуна» ЖИВА
# (точный матч заголовка, г5 зелёный), но норма-строка лежит в теле ДРУГОЙ
# секции (г6: строка из чужой секции НЕ засчитывается).
# Стаб-привязка (Н-39): стаб «grep по всему файлу устава» ловится ровно здесь —
# на R5/R6 (role-ветвь) он честен, устав требует матч в теле своей секции.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r7_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1
# Секция жива, нормы в её теле НЕТ; норма — в чужой секции ниже.
printf '# Ustav\n\n## Воркфлоу майлстоуна\n\ntelo sekcii bez normy\n\n## Drugaja sekcija\n\nNorma stroki ustava v igrushke R.\ntelo\n' > "$T/AGENTS.md"
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$T" 'kontrakt s normoj v chuzhoj sekcii'
run_barrier "$T"
refuse 'R7' 'проводка: норма-строка не найдена в теле секции §Воркфлоу майлстоуна'
exit 0
