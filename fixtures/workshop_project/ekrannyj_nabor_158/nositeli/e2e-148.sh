#!/usr/bin/env bash
# 148 v2 (слово владельца 2026-10-31): эмуляторы ПОСЛЕДОВАТЕЛЬНО — второй
# (профиль 393 с вырезом/домашней полосой, порт 5576) запускается только
# ПОСЛЕ остановки первого (эмулятор работника лекала 143 v2, порт 5570);
# одновременно пачка 148 живых эмуляторов не держит (Astra
# mob-ci-razdelenie п.342: не более двух на станции; сосед 5571 занят
# adb-парой). produkt_sud запускает скрипт с двойниками SDK в песочнице:
# порядок — фактические KILL/START по журналу, не слова текста.
set -euo pipefail
PORT_390=5570
PORT_393=5576
SERIAL_390="emulator-${PORT_390}"
SERIAL_393="emulator-${PORT_393}"
AVD_393="ci148-tab393-${GITHUB_RUN_ID:-0}-${GITHUB_RUN_ATTEMPT:-0}"

dozhdatsja_zagruzki() {
  # хелпер ожидания: запуск/остановка — только через двойники
  adb -s "$1" wait-for-device
  for _ in $(seq 1 130); do
    [ "$(adb -s "$1" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ] && return 0
    sleep 3
  done
  echo "ОТКАЗ: эмулятор $1 не загрузился за 390 с" >&2
  return 1
}

# (1) профиль 390: эмулятор работника уже поднят лекалом (порт 5570) —
#     кадры основной темы кладёт флоу vkladki.yaml на нём
maestro --e2e-serial "$SERIAL_390" test mobile/.maestro/vkladki.yaml

# (2) остановка ПЕРВОГО — до всякого запуска второго (И-11: не одновременно)
adb -s "$SERIAL_390" emu kill
for _ in $(seq 1 30); do adb devices | grep -q "$SERIAL_390" || break; sleep 2; done

# (3) запуск ВТОРОГО (профиль 393, порт 5576) — после остановки первого
"$ANDROID_HOME/emulator/emulator" -avd "$AVD_393" -port "$PORT_393" \
  -no-window -no-audio -no-boot-anim -no-snapshot \
  -gpu swiftshader_indirect >"emulator-148-393.log" 2>&1 &
dozhdatsja_zagruzki "$SERIAL_393"

# (4) кадры второго профиля — собранный путь tabshell (И-9)
maestro --e2e-serial "$SERIAL_393" test mobile/.maestro/vkladki-tabshell-393.yaml

# (5) остановка второго — пачка не оставляет станции живых эмуляторов
adb -s "$SERIAL_393" emu kill
