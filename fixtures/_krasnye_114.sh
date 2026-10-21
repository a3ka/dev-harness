#!/usr/bin/env bash
# Раннер красной/зелёной пачки 114 «веса lane CI по замерам» — агрегатор
# ОДНОЙ семьи: fixtures/ci_weights_114/red_114.sh (probe-only каталог, см.
# .probe-only; имя каталога — вне чужих glob'ов раннеров).
#
# Использование:
#   bash fixtures/_krasnye_114.sh
#     RED114_GUARD / RED114_MEASURE — переопределение точек входа предмета
#     (по умолчанию scripts/check_ci_weights.sh, scripts/measure_ci_weights.sh);
#     приёмка на честной модели:
#       RED114_GUARD=$PWD/fixtures/ci_weights_114/model/guard_model.sh \
#       RED114_MEASURE=$PWD/fixtures/ci_weights_114/model/measure_model.sh \
#       bash fixtures/_krasnye_114.sh
#
# Семантика: rc 0 — батарея зелёная (веса по замерам: гвард судит покрытие,
# двустороннее расхождение > 3× и свежесть TSV ≤ 30 дней; мера — медиана-ceil
# последних ≥N наблюдений, атомарный отказ на «мало данных»; все обманные
# стабы пойманы поимённо); rc 1 — красное. ДО реализации (база) красны по
# умыслу Д1/Д2 и т1–т12 «нет инструмента» (предмет отсутствует); стаб-пак
# ловится уже на базе — доказательная сила батареи проверяема до реализации.
# Подключение в CI — оркестратор отдельным интеграционным коммитом (слово
# консультанта 01:15), НЕ реализационной пачкой.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATTERY="$HERE/ci_weights_114/red_114.sh"
[ -f "$BATTERY" ] || { printf 'ОТКАЗ: нет батареи: %s\n' "$BATTERY" >&2; exit 2; }
bash "$BATTERY" "$@"
exit $?
