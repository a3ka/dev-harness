#!/usr/bin/env bash
# R11 — «голый канал» (verdicts/adversary/contracts-038-bare-channel-line.md):
# после ПРОВОДКА: под честной `- role=` канальной строкой стоит строка
# `role=…` БЕЗ literal-префикса `- `. До круга 11 цикл сбора channel_lines
# МОЛЧА её выбрасывал (case на префикс), из-за чего `roles/missing.md` так и не
# доходил до классификации, и барьер зеленел. Теперь любая НЕ-пустая строка
# поля без `- `-префикса (и не совпадающая с В1-маркером
# `ПРОВОДКА-ЭНФОРСМЕНТ:`) даёт отказ САМОЙ строкой; негативный контроль —
# честная роль остаётся зелёной.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r11_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1

# Негативный контроль: честный role-канал без голой строки → rc 0
put_contract "$T" 'ПРОВОДКА:
- role=roles/fixer.md «Norma stroki roli v igrushke R.»'
commit_all "$T" 'kontrakt chestnyj rol'
run_barrier "$T"
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: R11-control: честный role дал rc %s:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }

# Позитив-вход: под честной `- role=` стоит голая строка `role=…` без `- `
# (роль-файл НЕ существует, норма объективно не подключена) → rc 1 с поимённой
# причиной «вне грамматики» на САМОЙ голой строке.
BAD='role=roles/missing.md «Missing role norm.»'
put_contract "$T" "ПРОВОДКА:
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
$BAD"
commit_all "$T" 'kontrakt s goloj strokoj kanala'
run_barrier "$T"
refuse 'R11' 'проводка: строка вне грамматики: role=roles/missing.md «Missing role norm.»'
exit 0
