#!/usr/bin/env bash
# priemka.prokhod пачки gespraech-tekst (контракт 149 v+1 цикл 2):
# проход Maestro по ВИДИМЫМ pressable (правило проходимости, слово
# владельца 2026-10-27): цель-флою передаётся argv (валидатор судит
# форму), каждое нажатие даёт наблюдаемое изменение либо кнопка
# помечена неактивной. Проход идёт на эмуляторе РАБОТНИКА лекала
# (порт 5580 — серийный номер выводится из порта, как в e2e.sh пачки;
# env-серийники сняты вместе с параллельным вторым AVD — слово
# владельца 2026-10-31).
set -eu
flow="${1:?cel-flou maestro}"
PORT_390=5580
serial="emulator-${PORT_390}"
[ -f "$flow" ] || exit 3
maestro --device "$serial" test --format junit \
  --output mobile/maestro-out-gespraech-tekst/prokhod.xml \
  "$flow"
