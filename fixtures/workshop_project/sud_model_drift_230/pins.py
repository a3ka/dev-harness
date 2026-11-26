#!/usr/bin/env python3
"""Prove reference pins using only origin, without modifying the clean checkout."""
import os
from pathlib import Path
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = 'fcaff8bf2bc602bbe1fac7a6b7b507d84cc93041'


def command(args, cwd):
    result = subprocess.run(list(map(str, args)), cwd=cwd, timeout=240)
    if result.returncode:
        raise SystemExit(result.returncode)


with tempfile.TemporaryDirectory(prefix='arch230-origin-', dir=os.environ['TMPDIR']) as temp:
    clone = Path(temp) / 'repo'
    command(['bash', ROOT / 'scripts/gitw', 'clone', '--no-checkout',
             'ssh://git@github.com/a3ka/dev-harness.git', clone], ROOT)
    command(['git', '-C', clone, 'checkout', '--detach', BASE], ROOT)
    remotes = subprocess.check_output(['git', '-C', str(clone), 'remote'], text=True)
    if remotes != 'origin\n':
        raise SystemExit('NOT_IMPLEMENTED: clean clone has unexpected remotes')
    command(['git', '-C', clone, 'merge-base', '--is-ancestor', BASE, 'origin/main'], ROOT)
    for mode in ('--model', '--stabs'):
        command(['python3', HERE / 'probe.py', mode, '--source-root', clone], ROOT)
    dirty = subprocess.check_output(['git', '-C', str(clone), 'status', '--porcelain'])
    if dirty:
        raise SystemExit('NOT_IMPLEMENTED: clean source checkout changed')
    print('ORIGIN_ONLY_PIN=' + BASE + ' CLEAN=1', flush=True)
