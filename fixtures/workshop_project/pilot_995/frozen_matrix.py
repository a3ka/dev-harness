#!/usr/bin/env python3
"""A checked-in CI suite must coexist with the independent frozen H probe."""
import argparse
import subprocess
import sys
from pathlib import Path
from runtime_probe import HERE, installed


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    args = parser.parse_args()
    repo = args.repo.resolve()
    if not repo.is_relative_to('/tmp/dev-harness-verify'): raise RuntimeError('DISPOSABLE_REQUIRED')
    bootstrap = repo / 'mobile/src/bootstrap'
    test = (HERE / 'pilot.test.tsx').read_bytes()
    source = (HERE / 'source.json').read_bytes()
    model = (HERE / 'model.tsx').read_bytes()
    checked = 0
    for name in ['pilot.test.tsx', 'pilot-995.test.tsx']:
        files = {bootstrap / 'pilot-app.tsx': model,
                 bootstrap / '__tests__' / name: test,
                 bootstrap / '__tests__/source.json': source}
        with installed(files):
            cmd = [sys.executable, str(HERE / 'probe.py'), '--repo', str(repo)]
            if name == 'pilot.test.tsx': cmd += ['--check-frozen']
            run = subprocess.run(cmd)
            if run.returncode: raise RuntimeError('FROZEN_COEXISTENCE:' + name)
            if any(path.read_bytes() != content for path, content in files.items()):
                raise RuntimeError('SUBJECT_FILES_CHANGED')
            print(f'995 frozen/{name}: rc={run.returncode} preserved=true', flush=True)
            checked += 1
    files = {bootstrap / '__tests__/pilot.test.tsx': test + b'\n// drift\n',
             bootstrap / '__tests__/source.json': source}
    with installed(files):
        run = subprocess.run([sys.executable, str(HERE / 'probe.py'), '--repo', str(repo), '--check-frozen'], capture_output=True, text=True)
        if run.returncode != 1 or 'FROZEN_BYTES_MISMATCH:pilot.test.tsx' not in run.stdout:
            raise RuntimeError('FROZEN_DRIFT_NOT_REJECTED')
        print('995 frozen/drift: rc=1 FROZEN_BYTES_MISMATCH:pilot.test.tsx', flush=True)
        checked += 1
    print(f'995 frozen checked={checked}')
    return 0


if __name__ == '__main__':
    try: sys.exit(main())
    except (OSError, RuntimeError) as error:
        print('995 INFRASTRUCTURE:', error, file=sys.stderr); sys.exit(2)
