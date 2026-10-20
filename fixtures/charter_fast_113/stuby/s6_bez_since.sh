#!/usr/bin/env bash
# s6_bez_since.sh — ОБМАННЫЙ СТАБ: игнорирует точку первой заморозки — судит всю
# историю каждого уставного файла, включая ЗАКОННЫЕ черновые правки до заморозки.
# Наблюдаемая ложь: d0_chistoe — ложный FAIL на черновике (оракул зелёен).
st113_sudim_vsegda() { return 0; }
ST113_SUDIM=st113_sudim_vsegda
. "$(dirname "${BASH_SOURCE[0]}")/../_karkas_staba.sh"
