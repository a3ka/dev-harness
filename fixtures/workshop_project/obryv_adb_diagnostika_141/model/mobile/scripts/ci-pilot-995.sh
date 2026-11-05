set -e
python3 -m pip install -r .harness/fixtures/workshop_project/pilot_995/requirements.txt
# Н-407: диагностика ВНЕ эха — обрыв adb виден в логе шага, не только в
# артефакте maestro.log (транспорт эмулятора 995 живёт в приватном cwd
# maestro_probe → ci-e2e.sh; хвост emulator-лога шагу недоступен — доступны
# adb devices и сигнатуры из mobile/maestro-out). Шагового повтора НЕТ:
# повтор уже живёт внутри ci-e2e.sh (зона 995), уровень workflow — 139.
set +e
python3 .harness/fixtures/workshop_project/pilot_995/maestro_probe.py \
  --repo "$GITHUB_WORKSPACE" \
  --apk "$GITHUB_WORKSPACE"/mobile/android/app/build/outputs/apk/release/app-release.apk \
  --code-file /tmp/impl995-pilot-private-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}/code \
  --out "$GITHUB_WORKSPACE"/mobile/maestro-out
rc=$?
set -e
if [ "$rc" -ne 0 ]; then
  echo "ДИАГНОСТИКА 995: adb devices" >&2
  adb devices >&2 || true
  echo "ДИАГНОСТИКА 995: сигнатуры Maestro в mobile/maestro-out" >&2
  grep -rnE 'device offline|adb: device not found|device [^ ]* not found|DeviceServerDiedException' \
    mobile/maestro-out >&2 2>/dev/null || true
fi
[ "$rc" -eq 0 ] || exit "$rc"
