#!/usr/bin/env python3
"""Reproduce Crit229b's exact enum deletion against the complete public battery."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EXPECTED_RED = {
    'policy-exhaustion-unknown', 'policy-exhaustion-empty', 'policy-exhaustion-null',
    'policy-exhaustion-number', 'policy-exhaustion-upper-stop',
    'policy-exhaustion-mixed-arbiter', 'policy-exhaustion-spaces', 'policy-exhaustion-padded',
}


def main():
    scratch = Path(os.environ.get('TMPDIR') or ROOT / 'tmp').resolve()
    scratch.mkdir(parents=True, exist_ok=True)
    value = json.loads((HERE / 'policy.json').read_bytes())['defaults']
    value['onExhaustion'] = 'unexpected'
    with tempfile.TemporaryDirectory(prefix='jp229-enum-', dir=scratch) as tmp:
        model = Path(tmp) / 'model'
        shutil.copytree(HERE / 'model', model)
        config = model / 'config/judges-policy.json'
        data = json.loads(config.read_bytes())
        del data['schema']['properties']['onExhaustion']['enum']
        config.write_text(json.dumps(data))
        direct = subprocess.run(['python3', str(model / 'scripts/judges_policy.py'), 'validate'],
                                input=json.dumps(value), text=True, capture_output=True, timeout=30)
        print('MUTANT_VALIDATE_RC', direct.returncode)
        if direct.returncode != 0 or json.loads(direct.stdout) != value:
            return 1
        result = subprocess.run(['bash', str(HERE / 'red_judges_policy_229.sh'), '--repo', str(model)],
                                text=True, capture_output=True, timeout=1200)
        print(result.stdout, end='')
        print(result.stderr, end='', file=sys.stderr)
        print('MUTANT_REPO_RC', result.returncode)
        red = {line.split()[0] for line in result.stdout.splitlines() if ' KRASNO ' in line}
        if result.returncode != 1 or red != EXPECTED_RED or 'KLETKI 133 KRASNYH 8' not in result.stdout.splitlines():
            return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
