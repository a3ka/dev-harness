#!/usr/bin/env python3
"""Exercise the real 224 suite, without the 231 installer adapter."""
import argparse
import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CASES = ('install224-checkout', 'install224-independent')
# The old installer is executable evidence, not a prose mutation/input link.
SCRIPTS_ONLY = '''import shutil
import subprocess


def install(work, carrier, tools_repo):
    tools = work / 'tools'
    shutil.copytree(tools_repo / 'scripts', tools / 'scripts')
    (tools / 'scripts/done_contract.sh').write_bytes(carrier)
    subprocess.run(['bash', '-n', tools / 'scripts/done_contract.sh'], check=True)
    return tools / 'scripts/done_contract.sh'
'''
STAB = 'stabs/scripts-only/install.py'
LINKS = ({'stab': STAB, 'case': 'install224-independent'},)


def check(case, carrier, tools_repo, installer=None):
    if case not in CASES:
        raise RuntimeError('NOT_IMPLEMENTED: UNKNOWN_INSTALL_CASE ' + case)
    spec = importlib.util.spec_from_file_location('installation224', HERE.parent / 'svezhest_verdikta_done_224/probe.py')
    prior = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(prior)
    if installer is not None:
        namespace = {}
        exec(compile(installer, STAB, 'exec'), namespace)
        prior.install = namespace['install']
    scratch = ROOT / 'tmp'
    scratch.mkdir(exist_ok=True)
    old_tmp = os.environ.get('TMPDIR')
    try:
        with tempfile.TemporaryDirectory(prefix=case + '-', dir=scratch) as temp:
            # Both roots remain inside our copy. An empty nested Git repository
            # blocks discovery of its parent's HEAD: no outside-tree writes.
            if case == 'install224-independent':
                prior.g(Path(temp), 'init', '-q', '-b', 'main')
            os.environ['TMPDIR'] = temp
            baseline = (HERE.parent / 'svezhest_verdikta_done_224/model/station.sh').read_bytes()
            # Independent memory oracle: both historical positive worlds must
            # finish done, including rc, pipes, tag target and unchanged HEAD.
            red = prior.suite(carrier, baseline, ['historic186', 'historic129'], case, tools_repo)
    finally:
        if old_tmp is None:
            os.environ.pop('TMPDIR', None)
        else:
            os.environ['TMPDIR'] = old_tmp
    print(case, 'RED', red, flush=True)
    return red


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--case', choices=CASES, required=True)
    parser.add_argument('--scripts-only', action='store_true')
    args = parser.parse_args()
    carrier = (HERE / 'model/done_contract.sh').read_bytes()
    return int(check(args.case, carrier, ROOT, SCRIPTS_ONLY if args.scripts_only else None) != 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError, ValueError, subprocess.SubprocessError) as error:
        print('NOT_IMPLEMENTED:', error, file=sys.stderr)
        sys.exit(2)
