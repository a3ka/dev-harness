#!/usr/bin/env python3
"""Run frozen Android flow without publishing the verification value.

Keep code-file outside repository/artifact paths. Only redacted text is published;
secureTextEntry and screenshot inspection remain required for binary artifacts.

Maestro substitutions require explicit -e arguments, not plain process environment.
For ci-e2e, a private PATH adapter supplies the code to `test` without changing the
snapshotted product script; other Maestro commands pass through unchanged.
"""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

HERE = Path(__file__).resolve().parent


def main():
    p = argparse.ArgumentParser()
    target = p.add_mutually_exclusive_group(required=True)
    target.add_argument('--device')
    target.add_argument('--repo', type=Path)
    p.add_argument('--apk', type=Path)
    p.add_argument('--code-file', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    secret = a.code_file.read_text().strip()
    if not secret or '\n' in secret:
        raise RuntimeError('INVALID_SECRET_INPUT')
    if a.out.exists():
        raise RuntimeError('OCCUPIED_OUTPUT')
    flow = (HERE / 'pilot.yaml').read_bytes()
    if a.repo and not a.apk:
        raise RuntimeError('APK_REQUIRED')
    # Existing CI owns emulator lifetime. Snapshot its script/flows before execution;
    # run them in private cwd so its hardcoded maestro-out never becomes raw artifacts.
    ci_script = (a.repo / 'mobile/scripts/ci-e2e.sh').read_bytes() if a.repo else None
    ci_flows = [(f.relative_to(a.repo / 'mobile/.maestro'), f.read_bytes())
                for f in (a.repo / 'mobile/.maestro').rglob('*') if f.is_file()] if a.repo else []
    with tempfile.TemporaryDirectory(prefix='pilot995-native-') as tmp:
        private = Path(tmp)
        env = dict(os.environ, PILOT_DEMO_CODE=secret)
        if a.repo:
            for path, raw in ci_flows:
                dest = private / '.maestro' / path
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_bytes(raw)
            (private / '.maestro').mkdir(exist_ok=True)
            (private / '.maestro/pilot.yaml').write_bytes(flow)
            (private / 'ci-e2e.sh').write_bytes(ci_script)
            maestro = shutil.which('maestro')
            if maestro is None:
                raise RuntimeError('MAESTRO_REQUIRED')
            binary_dir = private / 'bin'
            binary_dir.mkdir()
            adapter = binary_dir / 'maestro'
            adapter.write_text(
                '#!' + sys.executable + '\n'
                'import os, sys\n'
                'args = sys.argv[1:]\n'
                'if "test" in args:\n'
                '    i = args.index("test") + 1\n'
                '    args[i:i] = ["-e", "PILOT_DEMO_CODE=" + os.environ["PILOT_DEMO_CODE"]]\n'
                f'os.execv({os.path.abspath(maestro)!r}, [{os.path.abspath(maestro)!r}, *args])\n')
            adapter.chmod(0o700)
            env['PATH'] = str(binary_dir) + os.pathsep + os.environ.get('PATH', os.defpath)
            publication = private / 'maestro-out'
            report = publication / 'report.xml'
            command = ['bash', str(private / 'ci-e2e.sh'), str(a.apk.resolve())]
        else:
            (private / 'pilot.yaml').write_bytes(flow)
            publication = private
            report = private / 'report.xml'
            command = ['maestro', '--device', a.device, 'test', '-e', 'PILOT_DEMO_CODE=' + secret, '--format', 'junit', '--output', str(report), '--test-output-dir', str(private / 'debug'), str(private / 'pilot.yaml')]
        result = subprocess.run(command, cwd=private, env=env, capture_output=True, timeout=1800 if a.repo else 300)
        # Capture every publication candidate in memory; do not reread after sanitizing.
        files = [(f.relative_to(publication), f.read_bytes()) for f in publication.rglob('*') if f.is_file() and f.name != 'pilot.yaml']
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
