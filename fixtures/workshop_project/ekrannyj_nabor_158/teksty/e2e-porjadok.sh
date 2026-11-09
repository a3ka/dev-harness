#!/usr/bin/env bash
# СКРИПТ-ДВОЙНИК e2e-канона AVD набора ekrannyj_nabor_158 (И-4).
#
# Канон (дословно): остановка профиля 390 С ПОДТВЕРЖДЕНИЕМ ухода ДО
# запуска 393; 393 — на своём порту; не более двух живых AVD на станции.
# Живой эмулятор в батарею НЕ входит (суд — песочница фейкового adb +
# пины канонических e2e.sh референсов).
#
# Песочница: фейковый adb (teksty/fake-adb/adb) держит состояние в
# каталоге $FAKE_ADB_STATE (по файлу на серийник). Переменные:
#   PORT_390/PORT_393 — порты профилей (канон пачек: 5570/5576);
#   FAKE_ADB_STATE    — каталог состояния песочницы (обязателен);
#   POLZOV            — число опросов подтверждения ухода (по умолчанию 5).
#
# Коды возврата:
#   0 — канон соблюдён (390 ушёл с подтверждением, 393 запущен на своём
#       порту, живых AVD не более двух);
#   4 — PODTVERZHDENIE_OSTANOVKI_NET (390 не ушёл; 393 НЕ запущен);
#   5 — PORT_ZANJAT (порт 393 занят; чужой порт не занимается);
#   6 — SLISHKOM_MNOGO_AVD (живых AVD уже два).
set -uo pipefail

PORT_390="${PORT_390:-5570}"
PORT_393="${PORT_393:-5576}"
POLZOV="${POLZOV:-5}"
SOSTOYANIE="${FAKE_ADB_STATE:-}"
if [ -z "$SOSTOYANIE" ] || [ ! -d "$SOSTOYANIE" ]; then
  printf 'NOT_IMPLEMENTED: песочница adb отсутствует (FAKE_ADB_STATE)\n' >&2
  exit 2
fi
ADB="${FAKE_ADB:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/fake-adb/adb}"
export FAKE_ADB_STATE="$SOSTOYANIE"
export FAKE_ADB_PORT_393="$PORT_393"

zhivye() { "$ADB" devices | awk '$2 == "device" {print $1}'; }

# 1. Остановка 390.
"$ADB" -s emulator-390 emu kill >/dev/null 2>&1

# 2. ПОДТВЕРЖДЕНИЕ ухода: опрос состояния, пока 390 жив.
podtverzhdeno=0
for _ in $(seq 1 "$POLZOV"); do
  if ! zhivye | grep -qx 'emulator-390'; then
    podtverzhdeno=1
    break
  fi
  sleep 0.1
done
if [ "$podtverzhdeno" -ne 1 ]; then
  printf 'PODTVERZHDENIE_OSTANOVKI_NET: 390 не ушёл; 393 не запущен\n' >&2
  exit 4
fi

# 3. Порт 393 не должен быть занят (чужой порт не занимается).
zanyat="$("$ADB" devices | awk -v p="port=$PORT_393" '$2 == "device" && $3 == p {print $1}')"
if [ -n "$zanyat" ]; then
  printf 'PORT_ZANJAT: порт %s занят устройством %s\n' "$PORT_393" "$zanyat" >&2
  exit 5
fi

# 4. Не более двух живых AVD.
schet=$(zhivye | wc -l | tr -d ' ')
if [ "$schet" -ge 2 ]; then
  printf 'SLISHKOM_MNOGO_AVD: живых AVD %s (максимум 2)\n' "$schet" >&2
  exit 6
fi

# 5. Запуск 393 на своём порту.
"$ADB" -s emulator-393 wait-for-device >/dev/null 2>&1
printf 'AVD 393 ЗАПУЩЕН port=%s\n' "$PORT_393"
exit 0
