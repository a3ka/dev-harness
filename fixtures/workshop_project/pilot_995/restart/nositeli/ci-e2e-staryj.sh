#!/usr/bin/env bash
# android-e2e на серверном раннере: проверка памяти → AVD этого прогона → эмулятор без окна →
# установка release-APK → сценарии Maestro → скриншоты/отчёт в maestro-out. Эмулятор и AVD убираются всегда.
# Вызов из mobile/: bash scripts/ci-e2e.sh <путь к APK>
set -euo pipefail
APK="$1"
AVD="ci-${GITHUB_RUN_ID:-local}-${GITHUB_RUN_ATTEMPT:-1}"
PORT=5560
SERIAL="emulator-$PORT"
IMAGE="system-images;android-36;google_apis;x86_64"
MIN_FREE_GB=8

avail=$(awk '/MemAvailable/ {print int($2/1048576)}' /proc/meminfo)
if [ "$avail" -lt "$MIN_FREE_GB" ]; then
  echo "ОТКАЗ: на станции свободно ${avail} ГБ < ${MIN_FREE_GB} ГБ — эмулятор не запускаю" >&2
  exit 1
fi

cleanup() {
  adb -s "$SERIAL" emu kill >/dev/null 2>&1 || true
  sleep 3
  pkill -f "qemu-system-x86_64.*-avd $AVD" >/dev/null 2>&1 || true
  avdmanager delete avd -n "$AVD" >/dev/null 2>&1 || true
}
trap cleanup EXIT

AVDM="$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager"
avdmanager() { "$AVDM" "$@"; }
echo no | avdmanager create avd --force -n "$AVD" -k "$IMAGE" -d pixel_7 >/dev/null
sed -i 's/^hw.ramSize=.*/hw.ramSize=2048/' "$ANDROID_AVD_HOME/$AVD.avd/config.ini"

adb start-server >/dev/null
emulator -avd "$AVD" -port "$PORT" -no-window -no-audio -no-boot-anim -no-snapshot \
  -gpu swiftshader_indirect >"emulator-$AVD.log" 2>&1 &

adb -s "$SERIAL" wait-for-device
for _ in $(seq 1 130); do
  [ "$(adb -s "$SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ] && break
  sleep 3
done
[ "$(adb -s "$SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ] || {
  echo "ОТКАЗ: эмулятор не загрузился за 390 с" >&2; exit 1; }

for s in window_animation_scale transition_animation_scale animator_duration_scale; do
  adb -s "$SERIAL" shell settings put global "$s" 0
done
adb -s "$SERIAL" install -r "$APK" >/dev/null

# adb-транспорт эмулятора иногда кратко уходит в offline (замеры: PR #1 и PR #3 — «device offline»
# на launchApp, Maestro: DeviceServerDiedException). Ждём, пока устройство стабильно отвечает:
# пакет виден менеджеру пакетов три проверки подряд.
wait_stable() {
  local ok=0
  for _ in $(seq 1 40); do
    if [ "$(adb -s "$SERIAL" get-state 2>/dev/null)" = "device" ] &&
       adb -s "$SERIAL" shell pm path com.complior.mobile >/dev/null 2>&1; then
      ok=$((ok + 1)); [ "$ok" -ge 3 ] && return 0
    else
      ok=0
    fi
    sleep 2
  done
  echo "ОТКАЗ: эмулятор $SERIAL не стабилизировался (adb offline)" >&2
  return 1
}

run_flows() {
  rm -rf maestro-out
  maestro --device "$SERIAL" test --format junit --output maestro-out/report.xml \
    --test-output-dir maestro-out .maestro
}

wait_stable
set +e
run_flows
rc=$?
set -e
# Ровно один повтор и только при обрыве транспорта. Провал проверки (assert) не повторяется.
if [ "$rc" -ne 0 ] && grep -rqE 'device offline|DeviceServerDiedException' maestro-out 2>/dev/null; then
  echo "ПОВТОР: обрыв adb-транспорта эмулятора, не провал проверки — сценарии запускаются второй раз" >&2
  adb -s "$SERIAL" reconnect offline >/dev/null 2>&1 || true
  wait_stable
  run_flows
else
  exit "$rc"
fi
