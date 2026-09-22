#!/usr/bin/env bash
# R13 — charter-heading-level (verdicts/adversary/contracts-038-charter-
# heading-level.md): в charter_section_body() awk-правило считало cur_lvl
# как `RLENGTH - 1` после match `^#+[[:space:]]+`, и RLENGTH ВКЛЮЧАЛ байты
# пробельного разделителя. `##  Next` (два пробела после `##`) давал
# cur_lvl=3 вместо верного 2 — заголовок ТОГО ЖЕ уровня не закрывал тело
# предыдущего, и норма из «следующей» секции (Foreign norm.) протекала
# внутрь тела целевой `§Target`. Круг 12 фикс: уровень — ТОЛЬКО байты `#`
# (`match($0, /^#+/)` → cur_lvl = RLENGTH); пробельный разделитель
# потребляется отдельным match для cur_text и в уровень НЕ входит ни
# байтом. Логика `cur_lvl <= start_lvl` не тронута.
#
# Покрытие: extra-space-same-level-boundary-red (vector 3 — основной вход
# адверсария) и single-space-positive-control (тот же заголовок с одним
# пробелом — зелёный; negative — оба «искусственных» соседних заголовка
# в одной секции с одинаковой нормой).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
require_absent_subject

WORK="$(mktemp -d "${TMPDIR:-/tmp}/r13_038.XXXXXX")"; trap 'rm -rf "$WORK"' EXIT
T="$WORK/toy"; make_toy "$T" 1 1

# 1. Negative control: single-space same-level heading — норма «Target
# norm.» в §Target зелёная (rc 0); «Foreign norm.» в §Next красная
# (rc 1) с поимённой причиной.
printf '# Ustav\n\n## Target\nTarget norm.\n\n## Next\nForeign norm.\n' > "$T/AGENTS.md"
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Target «Target norm.»'
commit_all "$T" 'kontrakt single-space ok'
run_barrier "$T"
[ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: R13-control-positive: честная §Target с одним пробелом дала rc %s:\n%s\n' "$LAST_RC" "$LAST_OUT" >&2; exit 1; }

put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Target «Foreign norm.»'
commit_all "$T" 'kontrakt single-space foreign'
run_barrier "$T"
refuse 'R13-control-negative' 'проводка: норма-строка не найдена в теле секции §Target'

# 2. Основной вход адверсария (vector 3): `##  Next` с ДВУМЯ пробелами.
# Без фикса: cur_lvl=3 → «Next» НЕ закрывал «Target» → «Foreign norm.»
# находилась в теле §Target → rc 0 (зелёный, БАГ).
# С фиксом: cur_lvl=2 → «Next» закрывает «Target» → «Foreign norm.» НЕ
# в §Target → rc 1 «норма-строка не найдена в теле секции §Target».
printf '# Ustav\n\n## Target\nTarget norm.\n\n##  Next\nForeign norm.\n' > "$T/AGENTS.md"
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Target «Foreign norm.»'
commit_all "$T" 'kontrakt extra-space-same-level'
run_barrier "$T"
refuse 'R13-extra-space' 'проводка: норма-строка не найдена в теле секции §Target'

# 3. Тот же вектор с большим числом пробелов (3+) — для гарантии, что
# счёт хешей строго отделён от ЛЮБОГО числа пробелов.
printf '# Ustav\n\n## Target\nTarget norm.\n\n##     Next\nForeign norm.\n' > "$T/AGENTS.md"
put_contract "$T" 'ПРОВОДКА:
- guard=scripts/check_ok.sh
- role=roles/fixer.md «Norma stroki roli v igrushke R.»
- charter=AGENTS.md §Target «Foreign norm.»'
commit_all "$T" 'kontrakt tri-probela'
run_barrier "$T"
refuse 'R13-many-spaces' 'проводка: норма-строка не найдена в теле секции §Target'

exit 0