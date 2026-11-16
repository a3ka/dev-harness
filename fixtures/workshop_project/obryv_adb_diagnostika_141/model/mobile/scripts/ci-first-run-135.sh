set -euo pipefail
APK='mobile/android/app/build/outputs/apk/release/app-release.apk'
AVD="ci135-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}"
PORT=5564
SERIAL="emulator-${PORT}"
AVDM="$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager"
cleanup135() {
  adb -s "$SERIAL" emu kill >/dev/null 2>&1 || true
  sleep 3
  pkill -f "qemu-system-x86_64.*-avd $AVD" >/dev/null 2>&1 || true
  "$AVDM" delete avd -n "$AVD" >/dev/null 2>&1 || true
}
trap cleanup135 EXIT
echo no | "$AVDM" create avd --force -n "$AVD" \
  -k "system-images;android-36;google_apis;x86_64" -d pixel_7 >/dev/null
sed -i 's/^hw.ramSize=.*/hw.ramSize=2048/' "$ANDROID_AVD_HOME/$AVD.avd/config.ini"
adb start-server >/dev/null
# Н-407: обрыв adb-транспорта после «готовности» эмулятора — не провал
# проверки. Канон шага 117/ci-e2e.sh (слово владельца 25.10): ровно
# один повтор, и только по сигнатуре обрыва транспорта; провал
# сверки/проверки происхождения НЕ повторяется.
boot135() {
  adb -s "$SERIAL" emu kill >/dev/null 2>&1 || true
  sleep 3
  pkill -f "qemu-system-x86_64.*-avd $AVD" >/dev/null 2>&1 || true
  emulator -avd "$AVD" -port "$PORT" -no-window -no-audio -no-boot-anim -no-snapshot \
    -gpu swiftshader_indirect >"emulator-$AVD.log" 2>&1 &
  adb -s "$SERIAL" wait-for-device
  for _ in $(seq 1 130); do
    [ "$(adb -s "$SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ] && break
    sleep 3
  done
  [ "$(adb -s "$SERIAL" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ] || {
    echo "ОТКАЗ: эмулятор 135 не загрузился за 390 с" >&2; return 1; }
  local ok=0
  for _ in $(seq 1 40); do
    if [ "$(adb -s "$SERIAL" get-state 2>/dev/null)" = "device" ] &&
       adb -s "$SERIAL" shell pm path android >/dev/null 2>&1; then
      ok=$((ok + 1)); [ "$ok" -ge 3 ] && break
    else
      ok=0
    fi
    sleep 2
  done
  if [ "$ok" -lt 3 ]; then
    echo "ОТКАЗ: эмулятор $SERIAL не стабилизировался (adb offline)" >&2
    return 1
  fi
  for s in window_animation_scale transition_animation_scale animator_duration_scale; do
    adb -s "$SERIAL" shell settings put global "$s" 0
  done
  adb -s "$SERIAL" install -r "$APK" >/dev/null
}
# Н-407: диагностика ВНЕ эха — обрыв adb обязан быть виден в логе шага,
# а не только в артефакте (иначе не работает ни триаж, ни признак
# повтора 139, который читает лог мимо ##[group]-эха скрипта).
diag135() {
  echo "ДИАГНОСТИКА 135: adb devices" >&2
  adb devices >&2 || true
  echo "ДИАГНОСТИКА 135: сигнатуры Maestro в mobile/maestro-out-first-run" >&2
  grep -rnE 'device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException' \
    mobile/maestro-out-first-run >&2 2>/dev/null || true
  echo "ДИАГНОСТИКА 135: хвост emulator-$AVD.log" >&2
  tail -n 40 "emulator-$AVD.log" >&2 || true
}
run_priemka135() {
  rm -rf mobile/maestro-out-first-run
  mkdir -p mobile/maestro-out-first-run
  python3 .harness135/scripts/ekran_shablon.py --pack mobile/e2e-first-run --repo . --harness .harness135
}
if ! boot135; then diag135; exit 1; fi
export FIRST_RUN_SERIAL="$SERIAL"
set +e
run_priemka135
rc=$?
set -e
if [ "$rc" -ne 0 ]; then
  diag135
  if grep -rqE 'device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException' \
    mobile/maestro-out-first-run 2>/dev/null; then
    echo "ПОВТОР: обрыв adb-транспорта эмулятора 135 — перезапуск эмулятора и валидатора" >&2
    if ! boot135; then diag135; exit 1; fi
    set +e
    run_priemka135
    rc=$?
    set -e
    if [ "$rc" -ne 0 ]; then diag135; fi
  fi
fi
[ "$rc" -eq 0 ] || exit "$rc"
cmp mobile/e2e-first-run/batareja/proverka_proiskhozdenija.py .harness135/fixtures/workshop_project/first_run_ekran_135/teksty/proverka_text.py
python3 mobile/e2e-first-run/batareja/proverka_proiskhozdenija.py --pack mobile/e2e-first-run --repo . --harness .harness135
