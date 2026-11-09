#!/usr/bin/env bash
# ДВОЙНИК СТАБА st03: 393 запускается БЕЗ подтверждения ухода 390.
# Отличие от эталона teksty/e2e-porjadok.sh — пропущена фаза подтверждения.
set -uo pipefail

PORT_390="${PORT_390:-5570}"
PORT_393="${PORT_393:-5576}"
SOSTOYANIE="${FAKE_ADB_STATE:-}"
if [ -z "$SOSTOYANIE" ] || [ ! -d "$SOSTOYANIE" ]; then
  printf 'NOT_IMPLEMENTED: песочница adb отсутствует (FAKE_ADB_STATE)\n' >&2
  exit 2
fi
ADB="${FAKE_ADB:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../teksty" && pwd -P)/fake-adb/adb}"
export FAKE_ADB_STATE="$SOSTOYANIE"
export FAKE_ADB_PORT_393="$PORT_393"

"$ADB" -s emulator-390 emu kill >/dev/null 2>&1
"$ADB" -s emulator-393 wait-for-device >/dev/null 2>&1
printf 'AVD 393 ЗАПУЩЕН port=%s\n' "$PORT_393"
exit 0
