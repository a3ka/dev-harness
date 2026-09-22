#!/usr/bin/env bash
# R15 — негативный контроль НЕ-ослабления фикса круга 11 (bare-channel-line):
# под честной `- role=` канальной строкой стоит БЕЗ-ПРЕФИКСНАЯ строка
# `role=…` (роль-файл НЕ существует, норма объективно не подключена),
# а ПОСЛЕ неё — markdown code-fence ```. До круга 15 цикл мог бы остановиться
# на fence; фикс круга 15 кладёт fence как терминатор, НО цикл ДОХОДИТ до
# без-префиксной строки РАНЬШЕ, чем до fence: catch-all `*![[:space:]]*`
# срабатывает на ней. Регресс остаётся красным — rc 1 на САМОЙ строке, не
# «поле вне грамматики» на fence. Доказывает: терминатор fence НЕ ослабляет
# круг 11 (R11) — без-префиксная строка перед fence всё равно краснит.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r15_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1

# Позитив-вход: fence В КОНЦЕ честного поля → rc 0 (доказывает, что фикс
# круга 15 не ломает зелёный путь).
put_contract "$T" 'ПРОВОДКА:
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
```
'
commit_all "$T" 'kontrakt chestnyj + fence v konce'
run_barrier "$T"
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: R15-control: честный вход + fence дал rc %s:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }

# Негатив-вход: без-префиксная строка `role=…` СТРОГО ПЕРЕД fence →
# rc 1 с поимённой причиной «вне грамматики» на САМОЙ голой строке, НЕ на
# fence. Доказывает, что catch-all срабатывает раньше, чем fence-терминатор.
BAD='role=roles/missing.md «Missing role norm.»
'
put_contract "$T" "ПРОВОДКА:
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
$BAD\`\`\`
"
commit_all "$T" 'kontrakt s goloj strokoj pered fence'
run_barrier "$T"
refuse 'R15-bare-before-fence' 'проводка: строка вне грамматики: role=roles/missing.md «Missing role norm.»'
exit 0
