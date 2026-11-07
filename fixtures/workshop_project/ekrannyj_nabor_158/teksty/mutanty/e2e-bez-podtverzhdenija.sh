#!/usr/bin/env bash
# МУТАНТ e2e-канона AVD набора ekrannyj_nabor_158 (клетка b07): 393 запускается
# БЕЗ подтверждения ухода 390 (канон И-4 нарушен).
#
# Отличие от эталона teksty/e2e-porjadok.sh — ровно одно: пропущена фаза
# подтверждения ухода 390. Батарея обязана ОТКЛОНИТЬ этот порядок: на
# залипшем 390 мутант поднимает 393, состояние песочницы это показывает.
#
# Песочница — фейковый adb (teksty/fake-adb/adb), переменные те же:
# FAKE_ADB_STATE, PORT_390, PORT_393.
set -uo pipefail

PORT_390="${PORT_390:-5570}"
PORT_393="${PORT_393:-5576}"
SOSTOYANIE="${FAKE_ADB_STATE:-}"
if [ -z "$SOSTOYANIE" ] || [ ! -d "$SOSTOYANIE" ]; then
  printf 'NOT_IMPLEMENTED: песочница adb отсутствует (FAKE_ADB_STATE)\n' >&2
  exit 2
fi
ADB="${FAKE_ADB:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/fake-adb/adb}"
export FAKE_ADB_STATE="$SOSTOYANIE"
export FAKE_ADB_PORT_393="$PORT_393"

zhivye() { "$ADB" devices | awk '$2 == "device" {print $1}'; }

# 1. Остановка 390 — БЕЗ подтверждения ухода (ДЕФЕКТ МУТАНТА).
"$ADB" -s emulator-390 emu kill >/dev/null 2>&1

# 2. Порт 393 не должен быть занят.
zanyat="$("$ADB" devices | awk -v p="port=$PORT_393" '$2 == "device" && $3 == p {print $1}')"
if [ -n "$zanyat" ]; then
  printf 'PORT_ZANJAT: порт %s занят устройством %s\n' "$PORT_393" "$zanyat" >&2
  exit 5
fi

# 3. Запуск 393 — даже если 390 ещё жив.
"$ADB" -s emulator-393 wait-for-device >/dev/null 2>&1
printf 'AVD 393 ЗАПУЩЕН port=%s\n' "$PORT_393"
exit 0
