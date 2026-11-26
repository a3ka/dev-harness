#!/usr/bin/env bash
# Reference for 227, not a production installation.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
exec python3 - "$root" <<'PY'
import json
import subprocess
import sys
from pathlib import Path

root = Path(sys.argv[1])
try:
    config = json.loads((root / 'config/zashivki.json').read_text())
    paths = [':(literal)' + p for p in config['include']]
    paths += [':(exclude,literal)' + p for p in config['exclude']]
    result = subprocess.run(['git', '-c', 'core.quotepath=false', 'grep', '--no-color',
                             '-z', '-n', '-I', '-E', '-e', config['pattern'], '--', *paths],
                            cwd=root, capture_output=True)
    if result.returncode not in (0, 1):
        sys.stderr.buffer.write(result.stderr)
        raise RuntimeError('git grep unavailable')
    matches = []
    data = result.stdout
    while data:
        path, number, rest = data.split(b'\0', 2)
        text, _, data = rest.partition(b'\n')
        matches.append({'path': path.decode(), 'line': int(number), 'text': text.decode()})
    report = {'lines': len(matches), 'files': len({m['path'] for m in matches}),
              'matches': matches, 'baseline': {'lines': 89, 'files': 20, 'commit': '6565542c1'}}
    print(json.dumps(report, ensure_ascii=False))
except (OSError, ValueError, KeyError, RuntimeError) as error:
    print('NOT_IMPLEMENTED: ZASHIVKI_REPORT: ' + str(error), file=sys.stderr)
    sys.exit(2)
PY
