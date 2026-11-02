#!/usr/bin/env bash
# priemka.e2e пачки gespraech-vhod (контракт 147): настоящий Maestro на
# release APK в ОБОИХ theme-вариантах и ОБОИХ профилях — ПОСЛЕДОВАТЕЛЬНО
# (слово владельца 2026-10-31): эмулятор 390 поднимает и останавливает
# экранный шаг job (lekalo 143 v2), пачка сама останавливает первый
# эмулятор после кадров 390 и запускает эмулятор профиля 393 (AVD/порт/
# APK — окружение шага GESPRAECH_AVD393/GESPRAECH_PORT393/GESPRAECH_APK);
# одновременно двух живых пачка не держит (Astra mob-ci-razdelenie п.342).
# Вызывается валидатором формы 132 v3 фактическим argv из корня репо:
# bash mobile/e2e-gespraech-vhod/e2e.sh gespraech-vhod
# Кадры кладутся в Maestro-раскладку mobile/maestro-out-gespraech/<тема>/…
# <snimok>.png — их же читает сверка 123 (оба манифеста). Каталог
# очищается ДО прогона: каждый кадр создан этим запуском (свежесть судит
# валидатор). Кадр GA-01 (вход) снимается флоу, но ПИКСЕЛЬНОЙ сверкой не
# судится (слово владельца 31.10 — Start D 2.4 отдельным предметом).
# Нет эмулятора/флоу — rc 2/3; неподтверждённая остановка первого — rc 4
# (различимая причина); отказы остановки/запуска не маскируются.
set -eu
flow="${1:?imja floy}"
serial="${GESPRAECH_SERIAL:?GESPRAECH_SERIAL: серийный номер эмулятора 390}"
serial393="${GESPRAECH_SERIAL_393:?GESPRAECH_SERIAL_393: серийный номер 393}"
avd393="${GESPRAECH_AVD393:?GESPRAECH_AVD393: имя AVD профиля 393}"
port393="${GESPRAECH_PORT393:?GESPRAECH_PORT393: порт эмулятора 393}"
apk="${GESPRAECH_APK:?GESPRAECH_APK: release APK}"
f="mobile/.maestro/$flow.yaml"
[ -f "$f" ] || exit 3
f393="mobile/.maestro/gespraech-vhod-393.yaml"
[ -f "$f393" ] || exit 3
out=mobile/maestro-out-gespraech
rm -rf "$out"
mkdir -p "$out"
dozhdatsja() {
  adb -s "$1" wait-for-device
  for _ in $(seq 1 130); do
    [ "$(adb -s "$1" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ] && return 0
    sleep 3
  done
  echo "ОТКАЗ: эмулятор $1 не загрузился за 390 с" >&2
  return 1
}
nastroit() {
  for s in window_animation_scale transition_animation_scale animator_duration_scale; do
    adb -s "$1" shell settings put global "$s" 0
  done
  adb -s "$1" install -r "$apk" >/dev/null
}
# (1) профиль 390: эмулятор уже поднят экранным шагом — обе темы
for tema in dark light; do
  if [ "$tema" = dark ]; then night=yes; else night=no; fi
  adb -s "$serial" shell cmd uimode night "$night"
  sleep 2
  maestro --device "$serial" test --format junit \
    --output "$out/report-$tema.xml" \
    --test-output-dir "$out/$tema" \
    "$f"
done
# (2) остановка ПЕРВОГО — до всякого запуска второго (не одновременно);
#     уход ПОДТВЕРЖДАЕТСЯ списком adb devices: emu kill с rc 0 ещё не
#     значит остановку (зависший/медленный эмулятор остаётся в списке —
#     вердикт Crit147k2b: исчерпание ожидания безусловно запускало 393,
#     rc 0 при живом 390 = два живых AVD). Исчерпание — rc 4 с
#     различимой причиной, запуск 393 при живом 390 запрещён.
adb -s "$serial" emu kill
for _ in $(seq 1 30); do adb devices | grep -q "$serial" || break; sleep 2; done
if adb devices | grep -q "$serial"; then
  echo "ОТКАЗ: эмулятор $serial не ушёл за 60 с после emu kill — запуск 393 запрещён (два живых)" >&2
  exit 4
fi
# (3) запуск ВТОРОГО (профиль 393) — после ПОДТВЕРЖДЁННОЙ остановки первого
"$ANDROID_HOME/emulator/emulator" -avd "$avd393" -port "$port393" \
  -no-window -no-audio -no-boot-anim -no-snapshot \
  -gpu swiftshader_indirect >"emulator-gespraech-393.log" 2>&1 &
dozhdatsja "$serial393"
nastroit "$serial393"
# (4) профиль 393: обе темы
for tema in dark light; do
  if [ "$tema" = dark ]; then night=yes; else night=no; fi
  adb -s "$serial393" shell cmd uimode night "$night"
  sleep 2
  maestro --device "$serial393" test --format junit \
    --output "$out/report-$tema-393.xml" \
    --test-output-dir "$out/$tema-393" \
    "$f393"
done
