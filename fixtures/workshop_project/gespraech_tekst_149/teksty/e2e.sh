#!/usr/bin/env bash
# priemka.e2e пачки gespraech-tekst (контракт 149 v+1 цикл 2): настоящий
# Maestro на release APK в ОБОИХ theme-вариантах и ОБОИХ профилях
# (390 и 393 с вырезом/инсетами). Эмуляторы ПОСЛЕДОВАТЕЛЬНО (слово
# владельца 2026-10-31, Astra mob-ci-razdelenie п.342: не более двух на
# станции): второй (профиль 393, порт 5582) запускается ТОЛЬКО ПОСЛЕ
# остановки первого (эмулятор работника лекала 143 v2, порт 5580);
# одновременно пачка живых эмуляторов не держит. Жизненный цикл пары —
# в ЭТОМ скрипте (прецедент 148 v2: суд остановки — исполнением, не
# текстом): батарея прогоняет скрипт с двойниками SDK в песочнице и
# судит порядок по журналу KILL/START (клетка s-emuljatory-posledovatelno;
# параллельный job — параллельный старт до остановки — красен).
# Кадры кладутся в Maestro-раскладку
# mobile/maestro-out-gespraech-tekst/<тема>/…/takeScreenshot/<snimok>.png
# — их же читает сверка 123 (оба манифеста). Каталог очищается ДО
# прогона: каждый кадр создан этим запуском (свежесть судит валидатор).
# Клавиатурные кадры GA-13/GA-17: системная клавиатура появляется вводом
# в поле (inputText); зона клавиатуры в сверкe маскирована (платформа).
# Нет флоу — rc 3; незагрузившийся эмулятор — rc 1.
set -euo pipefail
PORT_390=5580
PORT_393=5582
SERIAL_390="emulator-${PORT_390}"
SERIAL_393="emulator-${PORT_393}"
AVD_393="ci149-gespraech-393-${GITHUB_RUN_ID:-0}-${GITHUB_RUN_ATTEMPT:-0}"
f390="mobile/.maestro/gespraech-tekst.yaml"
f393="mobile/.maestro/gespraech-tekst-393.yaml"
[ -f "$f390" ] || exit 3
[ -f "$f393" ] || exit 3
out=mobile/maestro-out-gespraech-tekst
rm -rf "$out"
mkdir -p "$out"

dozhdatsja_zagruzki() {
  adb -s "$1" wait-for-device
  for _ in $(seq 1 130); do
    [ "$(adb -s "$1" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ] && return 0
    sleep 3
  done
  echo "ОТКАЗ: эмулятор $1 не загрузился за 390 с" >&2
  return 1
}

# (1) профиль 390: эмулятор работника уже поднят лекалом (порт 5580) —
#     кадры ОБЕИХ тем кладут флоу gespraech-tekst.yaml на нём
for tema in dark light; do
  if [ "$tema" = dark ]; then night=yes; else night=no; fi
  adb -s "$SERIAL_390" shell cmd uimode night "$night"
  sleep 2
  maestro --device "$SERIAL_390" test --format junit \
    --output "$out/report-$tema.xml" \
    --test-output-dir "$out/$tema" \
    "$f390"
done

# (2) остановка ПЕРВОГО — ДО всякого запуска второго (И-8: не одновременно)
adb -s "$SERIAL_390" emu kill
for _ in $(seq 1 30); do adb devices | grep -q "$SERIAL_390" || break; sleep 2; done
if adb devices | grep -q "$SERIAL_390"; then
  echo "ОТКАЗ: эмулятор $SERIAL_390 не остановился" >&2
  exit 1
fi

# (3) запуск ВТОРОГО (профиль 393 с вырезом, порт 5582) — после остановки
"$ANDROID_HOME/emulator/emulator" -avd "$AVD_393" -port "$PORT_393" \
  -no-window -no-audio -no-boot-anim -no-snapshot \
  -gpu swiftshader_indirect >"emulator-149-393.log" 2>&1 &
dozhdatsja_zagruzki "$SERIAL_393"

# (4) профиль 393: кадры ОБЕИХ тем — флоу gespraech-tekst-393.yaml
for tema in dark light; do
  if [ "$tema" = dark ]; then night=yes; else night=no; fi
  adb -s "$SERIAL_393" shell cmd uimode night "$night"
  sleep 2
  maestro --device "$SERIAL_393" test --format junit \
    --output "$out/report-$tema-393.xml" \
    --test-output-dir "$out/$tema-393" \
    "$f393"
done

# (5) остановка второго — пачка не оставляет станции живых эмуляторов
adb -s "$SERIAL_393" emu kill
