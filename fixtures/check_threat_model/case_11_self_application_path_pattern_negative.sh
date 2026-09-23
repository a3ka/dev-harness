#!/usr/bin/env bash
# ПРИЧИНА: модель угроз: список ЗАЩИЩАЕТ: пуст (нет буллета)
# Портирует в шардируемый протокол АРБИТРАЖНЫЙ-МАНДАТНЫЙ self-application-
# негатив (verdicts/arbitration/contracts-041-battery-example-based-predel.md,
# «Решение по существу» п.2; реализован в fixtures/parsing_hygiene_battery/
# profiles/check_threat_model.sh, battery_self_application_green часть «б»)
# — находка Н1 verdicts/review/contracts-041-k1.md, круг 1: живая
# glob-основанная негативная проверка («стаб, принимающий по path-паттерну
# contracts/041-*, иначе честно» — ловится) существовала ТОЛЬКО в
# fixtures/parsing_hygiene_battery/, которую CI шардовым анти-плацебо-путём
# не вызывал НИКЕМ (только npm run check:threat-model-selftest =
# fixtures/_krasnye_041.sh, который такой стаб НЕ ловит — измерено в
# ревью).
#
# Этот case НЕ зовёт саму battery-функцию (её мктемп-каталоги удаляются
# СИНХРОННО внутри каждой итерации `rm -rf "$w5"` — несовместимо с повторным
# прогоном verify_antiplacebo.sh: он реплеит ЗАПИСАННЫЙ корень байт-в-байт
# ПОСЛЕ выхода фикстуры, т.е. уже после чужого `rm -rf`), а воспроизводит
# ТОТ ЖЕ вход внутри $WORK — каталог фикстуры переживает её выход, чистит
# сам проверяющий (verify_antiplacebo.sh), а не trap этого процесса.
#
# Ядро сценария: ОДИН И ТОТ ЖЕ относительный путь «contracts/<реальное имя
# 041>.md» испытан на ДВУХ корнях — настоящем дереве (валидное содержимое,
# rc 0) и синтетическом $WORK (форженая пустая секция, rc 1). Путь-паттерн-
# стаб «contracts/041-* → accept» видит ТОЧНО совпадающий путь на ОБОИХ
# вызовах и на втором ошибочно принял бы форженое содержимое — единственный
# сигнал, отличающий стаб от честной реализации на этом входе.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"

if [ -z "${BARRIER:-}" ]; then
  BARRIER="$SUBJ"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/tm_case11.XXXXXX")"
  trap 'rm -rf "$WORK"' EXIT
fi

CONTRACT_REL="$(cd "$REPO/contracts" && ls 041-*.md 2>/dev/null | head -n1)"
[ -n "$CONTRACT_REL" ] || { printf 'ОТКАЗ: case_11: contracts/041-*.md не найден на дереве\n' >&2; exit 1; }

# ── зелёный контроль: self-application на РЕАЛЬНОМ валидном тексте 041 ──
run_barrier "$REPO" "contracts/$CONTRACT_REL"
[ "${BARRIER:-x}" = "$SUBJ" ] && accept 'case_11 (зелёный: self-application на реальном 041)'

# ── красное (candidate): ТОТ ЖЕ относительный путь, КОРЕНЬ — $WORK с
# форженым (пустым) списком ЗАЩИЩАЕТ: ──
mkdir -p "$WORK/contracts"
put_contract "$WORK/contracts/$CONTRACT_REL" '# forged kontrakt

## Predmet
p

## Модель угроз

ЗАЩИЩАЕТ:

НЕ ЗАЩИЩАЕТ:
- враждебное окружение вызывающего процесса за пределами базового PATH-экспорта'
run_barrier "$WORK" "contracts/$CONTRACT_REL"
[ "${BARRIER:-x}" = "$SUBJ" ] && refuse 'case_11 (красный: тот же путь contracts/041-*, форженое содержимое)' 'модель угроз: список ЗАЩИЩАЕТ: пуст (нет буллета)'

exit 0
