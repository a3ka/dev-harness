#!/usr/bin/env bash
# R12 — channel-pipe-truncation (verdicts/adversary/contracts-038-channel-
# pipe-truncation.md): классификация каналов сериализовала `kind|rest|ln`
# через литеральный `|`, и `rest="${ch#*|}"` обрубало норму/путь/имя на
# первом же `|`. Любой `|` в легитимном входе (норма-строка role/charter,
# имя guard-файла) встречается в данных — и до фикса норма/путь/имя
# обрезались до любых проверок грамматики; вся чёрная работа делалась
# уже обрубленной строкой. В варианте vector 2 целый второй role-канал
# (`role=roles/absent.md «…»`) прятался за `|` в одной строке и проходил
# зелёным. Круг 12 фикс: ТРИ ПАРАЛЛЕЛЬНЫХ индексированных массива
# (channel_kinds, channel_rests, channel_lns) — kind/rest/ln лежат в
# разных слотах, разделитель в данных невозможен по построению.
#
# Покрытие здесь: pipe-tailed guard-канал, pipe-tailed role-канал,
# pipe-tailed charter-канал, и pipe-с-вторым-каналом (vector 2). Каждый
# из них объективно красный и ОБЯЗАН давать rc=1 с поимённой причиной
# своей ветви; НЕ rc=0 (как было до фикса).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r12_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1

# 1. guard с мусором после `|` → красный (guard-файл не существует).
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh|trailing
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$T" 'kontrakt pipe-tailed guard'
run_barrier "$T"
refuse 'R12-guard' 'проводка: guard-файл не существует: scripts/check_ok.sh|trailing'

# 2. role с мусором после `|` → красный (extract_quoted отвергает норму
# с посторонним текстом после »: «Norma …»|trailing — ровно тот же
# класс «норма не выдерживает грамматику», что и круг 5 Б2/круг 9 Б3,
# формулируется как «строка вне грамматики» с самой строкой канала).
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»|trailing
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$T" 'kontrakt pipe-tailed role'
run_barrier "$T"
refuse 'R12-role' 'проводка: строка вне грамматики: - role=roles/fixer.md «Norma stroki roli v igrushke R.»|trailing'

# 3. charter с мусором после `|` → красный (extract_quoted отвергает норму
# с посторонним текстом после », как и role).
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»|trailing'
commit_all "$T" 'kontrakt pipe-tailed charter'
run_barrier "$T"
refuse 'R12-charter' 'проводка: строка вне грамматики: - charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»|trailing'

# 4. Vector 2 — спрятанный за `|` второй role-канал. До фикса второй
# канал исчезал за `|`, и done-gate зеленел. После фикса грамматика
# extract_quoted ловит «норму» с посторонним текстом после » (двойная
# пара «…»|…«…» — вложенные кавычки запрещены кругом 5 Б2) и краснеет
# «строка вне грамматики» на САМОЙ строке. Доступ к roles/absent.md не
# происходит (норма не извлечена), и речи о «role-файл не существует»
# нет — что и есть структурный фикс: вся строка-улика сохранена
# целиком и опознана как не-проходящая грамматику, без частичного
# исчезновения за разделителем.
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»|role=roles/absent.md «Nonexistent norm.»
- charter=AGENTS.md §Воркфлоу майлстоуна «Norma stroki ustava v igrushke R.»'
commit_all "$T" 'kontrakt sprjatannyj vtoroj role'
run_barrier "$T"
refuse 'R12-hidden-second-role' 'проводка: строка вне грамматики: - role=roles/fixer.md «Norma stroki roli v igrushke R.»|role=roles/absent.md «Nonexistent norm.»'

exit 0