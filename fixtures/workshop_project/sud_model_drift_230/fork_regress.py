#!/usr/bin/env python3
"""Run each existing fork_route public regression; no replacement oracle."""
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
cases = sorted((ROOT / 'fixtures/check_fork_route').glob('red_*.sh'))
if not cases:
    sys.exit('NOT_IMPLEMENTED: empty fork_route regression selection')
failed = 0
for case in cases:
    result = subprocess.run(['bash', str(case)], cwd=ROOT, timeout=60)
    print('FORK_REGRESS', case.name, 'rc=' + str(result.returncode), flush=True)
    failed += result.returncode != 0
print('FORK_CASES=' + str(len(cases)), 'FAILED=' + str(failed))
sys.exit(int(failed != 0))
