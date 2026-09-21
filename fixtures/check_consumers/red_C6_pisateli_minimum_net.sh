#!/usr/bin/env bash
# C6 (v4→v5, арбитраж 038-Б3 / b0e4beb; вход v5 — закрытие к4 fe11b3b) —
# маппинг с ЗАМЕНЁННЫМ писателем-минимума: файл пары done_contract.sh→
# scripts/speccer.sh изъят, вместо него добавлена пара произвольного третьего
# писателя scripts/other.sh→fixtures/reader.sh — писателей ПО-ПРЕЖНЕМУ три
# (счёт честен, замер-строка несётся), обязательного состава нет → отказ п1
# «писатели-минимум не зарегистрированы: scripts/done_contract.sh».
# Вход v5 — различимость (к4, verdicts/critic/contracts-038-v4.md Б1): слабый
# п1 «любые ≥3 разных писателя» на ТРЁХ писателях даёт rc0 → проба КРАСНА
# отсутствием ожидаемого отказа; поимённый предикат отказывает недостающим
# именем. Вход v4 (пара просто изъята, писателей два) неотличим — слабый п1
# при <3 печатает те же недостающие имена, отвергнуто живым репро критика
# (critic038k4-c6.py: fixture_rc=0 на слабом стабе).
# Стаб-привязка (Н-39): стаб «состав = любые три разных писателя» ловится
# ТОЛЬКО здесь — на C1/C3/G1 тот же стаб честен (все три минимума на месте),
# на G2 честен (окно пусто, состав не судится); дискриминационная проба
# _v5_c6_discrim.sh прогоняет ЭТОТ вход через слабый и сильный стабы
# (слабый rc1 / сильный rc0), стабы — по коду-репро критика; замер несётся
# (п1 судит её наличие, не счёт — вход красит состав, не замер).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/c6_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_crepo "$T" fixtures/reader.sh
rm "$T/scripts/consumers.d/done_contract.sh__speccer_sh.tsv"
printf 'scripts/other.sh\tfixtures/reader.sh\n' > "$T/scripts/consumers.d/other.sh__reader_sh.tsv"
printf '#!/usr/bin/env bash\nexit 0\n' > "$T/scripts/other.sh"
commit_all "$T" 'zamenili pisatelja-minimuma proizvolnym tretim'
put_draft "$T" "$CENSUS"
run_gate "$T" contracts/001-x.md
refuse 'C6' 'потребители 116: писатели-минимум не зарегистрированы: scripts/done_contract.sh'
exit 0
