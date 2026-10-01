#!/usr/bin/env bash
# Раннер красной/зелёной пачки 071 (предполёт gitw push в main): прогоняет
# fixtures/gitw_predpolet/red_predpolet_071.sh (стаб-пак 10 стабов + честные клетки
# п0–п8) против судимой пары scripts/gitw + scripts/gitw_preflight_071.sh.
# До реализации батарея обязана быть красной ЕДИНСТВЕННОЙ причиной п0
# «предмет отсутствует» при зелёном стаб-паке 10/10 — rc 1; после реализации
# rc 0. Пустая выборка невозможна: батарея сама умирает на нуле клеток.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$HERE/gitw_predpolet/red_predpolet_071.sh" "${1:-$(cd "$HERE/.." && pwd)}"
