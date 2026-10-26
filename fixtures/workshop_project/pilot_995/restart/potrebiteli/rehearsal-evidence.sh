#!/usr/bin/env bash
# 991 (положительный PR, Д4): обязательная rehearsal evidence-проверка обоих workflows.
# Шаг `rehearsal_evidence` стоит сразу после нативного шага «Эмулятор API 36 + сценарии Maestro»,
# cwd = mobile/. Раскладка Maestro: maestro-out/report.xml (JUnit) и
# maestro-out/<ts>/<flow>/takeScreenshot/<имя>.png (живой замер артефакта прогона main).
# Каждый отказ именован и называет файл: EVIDENCE_MISSING/EVIDENCE_EMPTY, DUPLICATE_EVIDENCE,
# JUNIT_REHEARSAL_INVALID. Канонический каталог maestro-out/rehearsal-evidence/ исключён из
# поиска дублей: это собственная копия проверки, а не вывод Maestro.
set -euo pipefail

APK='android/app/build/outputs/apk/release/app-release.apk'
FLOW='.maestro/rehearsal.yaml'
JUNIT='maestro-out/report.xml'
EVIDENCE_DIR='maestro-out/rehearsal-evidence'

die() { printf '%s\n' "$1" >&2; exit 1; }

# --- APK: собранный release-артефакт обязателен и непуст ---
[ -f "$APK" ] || die "EVIDENCE_MISSING: $APK"
[ -s "$APK" ] || die "EVIDENCE_EMPTY: $APK"

# --- JUnit: непуст, разбираем, rehearsal-flow исполнен со статусом SUCCESS, ни одного
# failure/error/skipped ни в одном testcase/attrs testsuite ---
[ -f "$JUNIT" ] || die "EVIDENCE_MISSING: $JUNIT"
[ -s "$JUNIT" ] || die "EVIDENCE_EMPTY: $JUNIT"
python3 - "$JUNIT" <<'PYEOF' || die 'JUNIT_REHEARSAL_INVALID'
import sys
import xml.etree.ElementTree as ET

try:
    root = ET.parse(sys.argv[1]).getroot()
except ET.ParseError:
    sys.exit(1)
rehearsal_ok = False
for case in root.iter('testcase'):
    status = (case.get('status') or '').upper()
    if (case.find('failure') is not None or case.find('error') is not None
            or case.find('skipped') is not None or status not in ('', 'SUCCESS')):
        sys.exit(1)
    if case.get('file') == '.maestro/rehearsal.yaml' and status == 'SUCCESS':
        rehearsal_ok = True
for suite in root.iter('testsuite'):
    for attr in ('failures', 'errors', 'skipped'):
        if int(suite.get(attr) or 0) != 0:
            sys.exit(1)
sys.exit(0 if rehearsal_ok else 1)
PYEOF

# --- PNG: ровно один непустой файл каждого имени среди вывода Maestro ---
declare -A SOURCE_OF
for name in rehearsal-before.png rehearsal-after.png; do
  count=0
  while IFS= read -r -d '' hit; do
    count=$((count + 1))
    SOURCE_OF[$name]=$hit
  done < <(find maestro-out -path "$EVIDENCE_DIR" -prune -o -type f -name "$name" -print0)
  [ "$count" -le 1 ] || die "DUPLICATE_EVIDENCE: $name"
  [ "$count" -eq 1 ] || die "EVIDENCE_MISSING: $name"
  [ -s "${SOURCE_OF[$name]}" ] || die "EVIDENCE_EMPTY: $name"
done

# --- Канонический evidence-каталог: копии с каноническими именами + происхождение и хеши ---
rm -rf "$EVIDENCE_DIR"
mkdir -p "$EVIDENCE_DIR"
for name in rehearsal-before.png rehearsal-after.png; do
  cp "${SOURCE_OF[$name]}" "$EVIDENCE_DIR/$name"
done
python3 - "$APK" "$FLOW" "$JUNIT" "$EVIDENCE_DIR" \
  "${SOURCE_OF[rehearsal-before.png]}" "${SOURCE_OF[rehearsal-after.png]}" <<'PYEOF'
import hashlib
import json
import os
import subprocess
import sys

apk, flow, junit, evidence_dir, before_src, after_src = sys.argv[1:7]

def sha256(path):
    digest = hashlib.sha256()
    with open(path, 'rb') as handle:
        for chunk in iter(lambda: handle.read(1 << 20), b''):
            digest.update(chunk)
    return digest.hexdigest()

try:
    version = subprocess.run(['maestro', '--version'], capture_output=True, text=True)
    maestro_version = version.stdout.strip() if version.returncode == 0 else f'unavailable rc={version.returncode}'
except OSError:
    maestro_version = 'unavailable'
manifest = {
    'sha256': {
        'apk': sha256(apk),
        'flow': sha256(flow),
        'junit': sha256(junit),
        'rehearsal-before.png': sha256(f'{evidence_dir}/rehearsal-before.png'),
        'rehearsal-after.png': sha256(f'{evidence_dir}/rehearsal-after.png'),
    },
    'png_sources': {'rehearsal-before.png': before_src, 'rehearsal-after.png': after_src},
    'maestro_version': maestro_version,
    'context': {key: os.environ.get(key, 'unset') for key in (
        'GITHUB_SHA', 'GITHUB_RUN_ID', 'GITHUB_RUN_ATTEMPT', 'GITHUB_WORKFLOW')},
}
with open(f'{evidence_dir}/manifest.json', 'w', encoding='utf-8') as handle:
    json.dump(manifest, handle, ensure_ascii=False, indent=2)
    handle.write('\n')
PYEOF
echo "rehearsal evidence OK: $EVIDENCE_DIR/{rehearsal-before.png,rehearsal-after.png,manifest.json}"
