#!/usr/bin/env bash
# G3 — код-фикстура: контракт 038 предъявляет поле ПРОВОДКА, обёрнутое в
# markdown code-fence (3 бэктика открытие/закрытие). До круга 15 цикл сборки
# channel_lines падал на закрывающем fence catch-all'ом «строка вне грамматики:
# ```», и done-gate контракта 038 был заблокирован НАВСЕГДА (без фикса).
# После круга 15 fence-строка — терминатор цикла (как `#`-заголовок), цикл
# break'ит и идёт дальше с собранными каналами. Фикстура проверяет на toy-
# дереве: позитив-вход с fence-обёрткой → rc 0; негатив-контроль — fence
# без предшествующих каналов (поле пусто) → rc 1 «поле пусто», а не «вне
# грамматики».
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/g3_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1

# Позитив-вход: полное поле ПРОВОДКА внутри markdown code fence → rc 0.
put_contract "$T" 'ПРОВОДКА этого контракта (пример):

```
ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»
```

Дальнейший текст после fence без `#`-заголовка — прозой.'
commit_all "$T" 'kontrakt s provodka vnutri code fence'
run_barrier "$T"
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: G3-positive: fence-wrapped ПРОВОДКА дал rc %s:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
printf 'G3: fence-wrapped ПРОВОДКА rc 0\n' >&2

# Негатив-контроль: fence сразу после шапки без каналов → rc 1 «поле пусто».
# Доказывает, что fence-терминатор срабатывает КОРРЕКТНО (как `#`-заголовок),
# а не die'ит с «вне грамматики»: `поле пусто» — rc 1 на той же фразе, что и
# `#`-заголовок без каналов.
put_contract "$T" 'ПРОВОДКА этого контракта (пусто):

```
ПРОВОДКА:
```
'
commit_all "$T" 'kontrakt s pustym provodka v code fence'
run_barrier "$T"
refuse 'G3-empty-fence' 'проводка: поле пусто'
exit 0
