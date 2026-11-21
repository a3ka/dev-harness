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
        command = ['bash', str(HERE / 'red_architecture_process_187.sh'), '--' + mode]
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
