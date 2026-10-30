#!/usr/bin/env bash
# priemka.e2e пачки gespraech-vhod (контракт 147): настоящий Maestro на
# release APK в ОБОИХ theme-вариантах и ОБОИХ профилях (390 и 393 с
# вырезом/инсетами — нарезка И шаблона 132 v2: второй AVD внутри того же
# работника). Вызывается валидатором формы 132 v3 фактическим argv из
# корня репо: bash mobile/e2e-gespraech-vhod/e2e.sh gespraech-vhod
# Эмуляторы с установленным release APK готовит вызывающая сторона (шаг
# e2e экрана в .github/workflows/mobile.yml) и сообщает серийные номера
# в GESPRAECH_SERIAL (390) и GESPRAECH_SERIAL_393. Кадры кладутся в
# Maestro-раскладку mobile/maestro-out-gespraech/<тема>/…/takeScreenshot/
# <snimok>.png — их же читает сверка 123 (оба манифеста). Каталог
# очищается ДО прогона: каждый кадр создан этим запуском (свежесть судит
# валидатор). Нет эмулятора/флоу — rc 2/3.
set -eu
flow="${1:?imja floy}"
serial="${GESPRAECH_SERIAL:?GESPRAECH_SERIAL: серийный номер эмулятора 390}"
serial393="${GESPRAECH_SERIAL_393:?GESPRAECH_SERIAL_393: эмулятор 393 с вырезом}"
f="mobile/.maestro/$flow.yaml"
[ -f "$f" ] || exit 3
out=mobile/maestro-out-gespraech
rm -rf "$out"
mkdir -p "$out"
for tema in dark light; do
  if [ "$tema" = dark ]; then night=yes; else night=no; fi
  adb -s "$serial" shell cmd uimode night "$night"
  sleep 2
  maestro --device "$serial" test --format junit \
    --output "$out/report-$tema.xml" \
    --test-output-dir "$out/$tema" \
    "$f"
  adb -s "$serial393" shell cmd uimode night "$night"
  sleep 2
  maestro --device "$serial393" test --format junit \
    --output "$out/report-$tema-393.xml" \
    --test-output-dir "$out/$tema-393" \
    "mobile/.maestro/gespraech-vhod-393.yaml"
done
