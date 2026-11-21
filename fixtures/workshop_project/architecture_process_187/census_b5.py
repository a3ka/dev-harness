#!/usr/bin/env python3
"""Record all existing 187 modes without stopping on an expected red door."""
import os
from pathlib import Path
import subprocess
import tempfile
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def main():
    stage = sys.argv[1]
    modes = sys.argv[2:] or ['model', 'stabs', 'repo', 'wiring']
    logs = Path(os.environ.get('TMPDIR', tempfile.gettempdir()))
    failed = False
    for mode in modes:
        if mode in ('signals', 'signals-base', 'signals-control'):
            tools = ROOT
            if mode == 'signals-base':
                tools = logs / (stage + '-base')
                (tools / 'scripts').mkdir(parents=True, exist_ok=True)
                source = subprocess.check_output(
                    ['git', '-C', str(ROOT), 'show',
                     'a4f87d04a1:scripts/check_architecture_contract.sh'])
                (tools / 'scripts/check_architecture_contract.sh').write_bytes(source)
            command = [sys.executable, str(HERE / 'brief_signals.py'), '--repo', str(tools)]
            if mode == 'signals-control':
                command.append('--control')
        else:
            command = ['bash', str(HERE / 'red_architecture_process_187.sh'), '--' + mode]
        # Signal modes intentionally accept an isolated library snapshot.
        if mode in ('repo', 'wiring'):
            command.append(str(ROOT))
        result = subprocess.run(command, cwd=ROOT, capture_output=True, timeout=300)
        (logs / f'{stage}-{mode}.stdout').write_bytes(result.stdout)
        (logs / f'{stage}-{mode}.stderr').write_bytes(result.stderr)
        sys.stdout.buffer.write(result.stdout)
        sys.stderr.buffer.write(result.stderr)
        print(f'CENSUS {stage} --{mode} rc={result.returncode}', flush=True)
        failed = failed or result.returncode != 0
    return int(failed)


if __name__ == '__main__':
    raise SystemExit(main())
