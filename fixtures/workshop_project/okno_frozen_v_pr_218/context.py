#!/usr/bin/env python3
"""Canonical zones_load plus highest frozen provenance; no second zone grammar."""
import csv
import io
import os
from pathlib import Path
import subprocess
import sys

TREE = Path(__file__).resolve().parents[3]
OWN = {
    'architect': ['contracts/218-okno-frozen-v-pr.md', 'fixtures/workshop_project/okno_frozen_v_pr_218/'],
    'implementer': ['scripts/check_contract_frozen.sh', 'scripts/check_charter.sh', 'scripts/lib_incr.sh', 'scripts/lib_pr_window.sh'],
    'orchestrator': ['registry/ci-steps.tsv', 'registry/ci-zamery.tsv', '.github/workflows/ci.yml'],
}
REQUIRED = ('200', '207', '195', '083', '210', '217', '992', '071')


def git(*args):
    return subprocess.check_output(['git', '-C', str(TREE), *args])


def records():
    tags = {}
    for ref in git('for-each-ref', '--format=%(refname)', 'refs/tags/frozen/contracts/').decode().splitlines():
        parts = ref.split('/')
        if len(parts) == 6 and parts[-1].isascii() and parts[-1].isdigit():
            n, version = parts[-2], int(parts[-1])
            if n not in tags or version > tags[n][0]:
                tags[n] = (version, ref)
    if any(n not in tags for n in REQUIRED):
        raise RuntimeError('CONTEXT_REQUIRED_TAG_ABSENT')
    for n in REQUIRED:
        version, tag = tags[n]
        names = [p for p in git('ls-tree', '-r', '-z', '--name-only', tag, '--', 'contracts/').decode().split('\0')
                 if p.startswith('contracts/' + n + '-') and p.endswith('.md') and p.count('/') == 1]
        if len(names) != 1:
            raise RuntimeError('CONTEXT_CONTRACT_NOT_UNIQUE: ' + n)
        commit = git('rev-parse', tag + '^{commit}').decode().strip()
        text = git('show', tag + '^{commit}:' + names[0]).decode()
        print(f'FROZEN {n}/{version} {commit} {names[0]}')
        for line in text.splitlines():
            if line.startswith('ЗОНА '):
                print(line)
    program = '''set -euo pipefail
root="$1"
. "$root/scripts/lib_zones.sh"
zdir="$(zones_load "$root")"
cat "$zdir/zones_scoped"
'''
    env = dict(os.environ, TMPDIR=str(TREE / 'tmp/scratch-arch218'))
    rows = subprocess.check_output(['bash', '-c', program, 'context-218', str(TREE)], cwd=TREE, env=env).decode()
    foreign = list(csv.reader(io.StringIO(rows), delimiter='\t'))
    if not foreign or any(len(row) != 3 for row in foreign):
        raise RuntimeError('CONTEXT_EMPTY_OR_INVALID')
    result = set()
    for other_role, other_path, n in foreign:
        for role, paths in OWN.items():
            if role == other_role and n not in REQUIRED:
                continue
            for path in paths:
                match = path == other_path or other_path.endswith('/') and path.startswith(other_path)
                match |= path.endswith('/') and other_path.startswith(path)
                if match:
                    result.add((role, path, n))
    return sorted(result)


def main():
    rows = records()
    if not rows:
        raise RuntimeError('CONTEXT_EMPTY')
    print('INTERSECTIONS=' + str(len(rows)))
    for role, path, n in rows:
        print(f'ПЕРЕСЕЧЕНИЕ {role}: {path} — {n} только своя дельта 218; прежние обязательства сохраняются')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, subprocess.CalledProcessError) as exc:
        print('NOT_IMPLEMENTED: ' + str(exc), file=sys.stderr)
        sys.exit(2)
