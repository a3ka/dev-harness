#!/usr/bin/env bash
# s4_bez_udalenija.sh — ОБМАННЫЙ СТАБ: фильтр только M — удаления (D) уставного
# документа не судятся. Наблюдаемая ложь: d4_udalenie.
st113_filter_bez_d() { printf '%s\n' --diff-filter=M; }
ST113_FILTER=st113_filter_bez_d
. "$(dirname "${BASH_SOURCE[0]}")/../_karkas_staba.sh"
