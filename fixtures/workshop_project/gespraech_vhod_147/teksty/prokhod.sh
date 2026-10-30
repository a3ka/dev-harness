#!/usr/bin/env bash
# priemka.prokhod пачки gespraech-vhod (контракт 147): проход Maestro по
# ВИДИМЫМ pressable (правило проходимости, слово владельца 2026-10-27):
# цель-флою передаётся argv (валидатор судит форму), каждое нажатие
# даёт наблюдаемое изменение либо кнопка помечена неактивной.
# Эмулятор готовит вызывающая сторона (GESPRAECH_SERIAL).
set -eu
flow="${1:?cel-flou maestro}"
serial="${GESPRAECH_SERIAL:?GESPRAECH_SERIAL: серийный номер эмулятора}"
[ -f "$flow" ] || exit 3
maestro --device "$serial" test --format junit \
  --output mobile/maestro-out-gespraech/prokhod.xml \
  "$flow"
