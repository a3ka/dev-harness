#!/usr/bin/env bash
# s1_okno.sh — ОБМАННЫЙ СТАБ: «быстрый» режим судит только последние 40 коммитов.
# Наблюдаемая ложь: d1_staroe — нарушение на глубине ~46 выпадает из окна.
# Честен там, где вся история моложе окна (d0_chistoe).
st113_log_args_okno() { printf '%s\n' -n 40; }
ST113_LOG_ARGS=st113_log_args_okno
. "$(dirname "${BASH_SOURCE[0]}")/../_karkas_staba.sh"
