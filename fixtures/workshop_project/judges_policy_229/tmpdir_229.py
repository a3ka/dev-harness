#!/usr/bin/env python3
"""Replay K-01 and its neighboring environment failures through the public CLI."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def main():
    try:
        parent = Path(os.environ.get('TMPDIR') or ROOT / 'tmp').resolve()
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(prefix='jp229-portability-', dir=parent) as tmp:
            base = Path(tmp)
            cases = [('relocated', str(base / 'reviewer')),
                     ('spaces', str(base / 'another reviewer' / 'tmp')),
                     ('absent', None), ('empty', '')]
            blocked = base / 'not-a-directory'
            blocked.write_text('not writable storage\n')
            cases.append(('blocked', str(blocked)))
            for name, scratch in cases:
                env = dict(os.environ)
                env.pop('TMPDIR', None)
                if scratch is not None:
                    env['TMPDIR'] = scratch
                result = subprocess.run(
                    ['bash', str(HERE / 'red_judges_policy_229.sh'),
                     '--model', '--case', 'env-release'], cwd=ROOT, env=env,
                    capture_output=True, text=True, timeout=120)
                expected = 2 if name == 'blocked' else 0
                print(f'TMPDIR {name} rc={result.returncode} expected={expected}')
                if result.returncode != expected:
                    sys.stderr.write(result.stdout + result.stderr)
                    return 1
                if name == 'blocked':
                    if 'TMPDIR_UNWRITABLE' not in result.stderr or 'KRASNO' in result.stdout:
                        sys.stderr.write(result.stdout + result.stderr)
                        return 1
                elif 'env-release ok\nKLETKI 1 KRASNYH 0\n' not in result.stdout:
                    sys.stderr.write(result.stdout + result.stderr)
                    return 1
        return 0
    except (OSError, subprocess.SubprocessError) as error:
        print('NOT_IMPLEMENTED: ' + str(error), file=sys.stderr)
        return 2


if __name__ == '__main__':
    raise SystemExit(main())
