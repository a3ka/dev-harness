#!/usr/bin/env python3
"""Exercise native runner publication/exit boundaries, NOT Android UI behavior."""
import argparse
import os
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
STUB = '''import os
from pathlib import Path
import sys
mode = os.environ['NATIVE_995_MODEL']
secret = os.environ['PILOT_DEMO_CODE']
args = sys.argv
report = Path(args[args.index('--output') + 1])
debug = Path(args[args.index('--test-output-dir') + 1])
debug.mkdir()
print('diagnostic ' + secret)
(debug / 'commands.json').write_text(secret)
if mode != 'missing-report':
    if mode == 'malformed':
        xml = '<broken'
    elif mode == 'empty':
        xml = '<testsuite/>'
    else:
        failure = '<failure/>' if mode == 'failed' else '<skipped/>' if mode == 'skipped' else ''
        xml = '<testsuite><testcase name="pilot">' + failure + '<system-out>' + secret + '</system-out></testcase></testsuite>'
    report.write_text(xml)
for name in ['pilot-first-run', 'pilot-welcome', 'pilot-restart']:
    if mode == 'missing-png' and name == 'pilot-welcome':
        continue
    (debug / (name + '.png')).write_bytes(b'synthetic-image-not-device-evidence')
sys.exit(1 if mode == 'nonzero' else 0)
'''
ROWS = [('honest', 0, 'native rc=0'), ('failed', 1, 'NATIVE_EVIDENCE_INCOMPLETE'),
        ('skipped', 1, 'NATIVE_EVIDENCE_INCOMPLETE'), ('missing-png', 1, 'NATIVE_EVIDENCE_INCOMPLETE'),
        ('nonzero', 1, 'native rc=1'), ('missing-report', 2, 'INFRASTRUCTURE'),
        ('empty', 2, 'INFRASTRUCTURE'), ('malformed', 2, 'INFRASTRUCTURE')]


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--scratch', type=Path, required=True)
    a = p.parse_args()
    secret = 'native-synthetic-private-value'
    with tempfile.TemporaryDirectory(prefix='native-matrix-', dir=a.scratch) as tmp:
        root = Path(tmp)
        binary = root / 'maestro'
        binary.write_text('#!' + sys.executable + '\n' + STUB)
        binary.chmod(0o700)
        code = root / 'private-code'
        code.write_text(secret)
        repo = root / 'subject'
        (repo / 'mobile/scripts').mkdir(parents=True)
        (repo / 'mobile/.maestro').mkdir()
        (repo / 'mobile/.maestro/rehearsal.yaml').write_text('synthetic-flow')
        (repo / 'mobile/scripts/ci-e2e.sh').write_text(
            'set -eu\n'
            'test -s .maestro/pilot.yaml\n'
            'test -s .maestro/rehearsal.yaml\n'
            'test -f "$1"\n'
            'maestro test --output maestro-out/report.xml --test-output-dir maestro-out .maestro\n')
        apk = root / 'synthetic.apk'
        apk.write_bytes(b'synthetic-not-an-apk')
        targets = [('device', ['--device', 'synthetic-no-device']),
                   ('ci', ['--repo', str(repo), '--apk', str(apk)])]
        for target, args in targets:
            for mode, expected, reason in ROWS:
                out = root / (target + '-' + mode)
                result = subprocess.run([sys.executable, str(HERE / 'maestro_probe.py'), *args, '--code-file', str(code), '--out', str(out)],
                                        env=dict(os.environ, PATH=str(root) + os.pathsep + os.environ['PATH'], NATIVE_995_MODEL=mode), capture_output=True)
                transcript = result.stdout + result.stderr
                assert result.returncode == expected and reason.encode() in transcript, (target, mode, result.returncode, transcript)
                published = [f.read_bytes() for f in out.rglob('*') if f.is_file()]
                assert published and all(secret.encode() not in raw for raw in published + [transcript]), (target, mode)
                assert b'[REDACTED]' in (out / 'maestro.log').read_bytes(), (target, mode)
                assert not (repo / 'mobile/maestro-out').exists(), 'RAW_OUTPUT_IN_CHECKOUT'
                print(f'995 native-runner/{target}/{mode}: rc={result.returncode} redacted=true reason={reason}')
    print(f'995 native-runner checked={len(targets) * len(ROWS)} Android=NOT_RUN')
    return 0


if __name__ == '__main__':
    sys.exit(main())
