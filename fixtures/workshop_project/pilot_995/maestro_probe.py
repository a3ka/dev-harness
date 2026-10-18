#!/usr/bin/env python3
"""Run frozen Android flow without publishing the verification value.

Keep code-file outside repository/artifact paths. Only redacted text is published;
secureTextEntry and screenshot inspection remain required for binary artifacts.
"""
import argparse
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

HERE = Path(__file__).resolve().parent


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--device', required=True)
    p.add_argument('--code-file', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    secret = a.code_file.read_text().strip()
    if not secret or '\n' in secret:
        raise RuntimeError('INVALID_SECRET_INPUT')
    if a.out.exists():
        raise RuntimeError('OCCUPIED_OUTPUT')
    flow = (HERE / 'pilot.yaml').read_bytes()
    with tempfile.TemporaryDirectory(prefix='pilot995-native-') as tmp:
        private = Path(tmp)
        (private / 'pilot.yaml').write_bytes(flow)
        report = private / 'report.xml'
        result = subprocess.run(['maestro', '--device', a.device, 'test', '--format', 'junit', '--output', str(report), '--test-output-dir', str(private / 'debug'), str(private / 'pilot.yaml')], cwd=private, env=dict(os.environ, PILOT_DEMO_CODE=secret), capture_output=True, timeout=300)
        # Capture every publication candidate in memory; do not reread after sanitizing.
        files = [(f.relative_to(private), f.read_bytes()) for f in private.rglob('*') if f.is_file() and f.name != 'pilot.yaml']
        a.out.mkdir(parents=True)
        for path, raw in files:
            dest = a.out / path
            dest.parent.mkdir(parents=True, exist_ok=True)
            if path.suffix.lower() in ('.png', '.jpg', '.jpeg'):
                dest.write_bytes(raw)
            else:
                dest.write_bytes(raw.replace(secret.encode(), b'[REDACTED]'))
        log = (result.stdout + result.stderr).replace(secret.encode(), b'[REDACTED]')
        (a.out / 'maestro.log').write_bytes(log)
        if not report.exists(): raise RuntimeError('NATIVE_REPORT_MISSING')
        root = ET.fromstring(report.read_bytes())
        cases = list(root.iter('testcase'))
        if not cases: raise RuntimeError('NATIVE_EMPTY_ASSERTIONS')
        failures = [c for c in cases if c.find('failure') is not None or c.find('error') is not None or c.find('skipped') is not None]
        pngs = {path.stem for path, raw in files if path.suffix == '.png' and raw}
        if result.returncode == 0 and (failures or not {'pilot-first-run', 'pilot-welcome', 'pilot-restart'}.issubset(pngs)):
            print('995 NATIVE_EVIDENCE_INCOMPLETE'); return 1
        print(f'995 native rc={result.returncode} testcases={len(cases)} failed={len(failures)}')
        return 0 if result.returncode == 0 else 1


if __name__ == '__main__':
    try: sys.exit(main())
    except (OSError, RuntimeError, ET.ParseError, subprocess.TimeoutExpired) as error:
        # Exception messages from subprocess can contain command arguments; never include secret.
        print('995 INFRASTRUCTURE:', type(error).__name__, file=sys.stderr); sys.exit(2)
