#!/usr/bin/env bash
# s7_kesh_linii.sh — ОБМАННЫЙ СТАБ: кеш сторонней линии (ветвь (в′) lib_incr)
# принимается на веру — окно base..HEAD вместо полного прогона. Наблюдаемая ложь:
# d7_kesh_linii — нарушение-предок чужой базы выпадает из окна (оракул: полный прогон).
st113_kesh_doverjajet() { INCR_WINDOW="$INCR_BASE..HEAD"; }
ST113_KESH=st113_kesh_doverjajet
. "$(dirname "${BASH_SOURCE[0]}")/../_karkas_staba.sh"
