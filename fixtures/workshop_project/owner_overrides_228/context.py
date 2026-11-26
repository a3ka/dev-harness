#!/usr/bin/env python3
"""Read live frozen blobs and the canonical zones_load; inventory, not a guard."""
import csv
import io
import os
from pathlib import Path
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
FAMILY = Path(__file__).resolve().parent
GATES = ('check_charter', 'check_zones', 'check_protected', 'check_contract_frozen')
OWN = {
    'architect': ['contracts/228-sh3-owner-overrides.md', 'fixtures/workshop_project/owner_overrides_228/'],
    'implementer': ['scripts/lib_owner.sh', 'registry/owner-overrides.tsv', *['scripts/' + g + '.sh' for g in GATES]],
    'orchestrator': ['registry/ci-steps.tsv', 'registry/ci-zamery.tsv', '.github/workflows/ci.yml'],
}
REQUIRED = ('065', '083', '200', '207', '210', '217', '218', '992', '071', '056', '031', '044')


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])


def records(verbose=True):
    tags = {}
    for ref in git('for-each-ref', '--format=%(refname)', 'refs/tags/frozen/contracts/').decode().splitlines():
        parts = ref.split('/')
        if len(parts) == 6 and re.fullmatch('[0-9]+', parts[-1]):
            n, version = parts[-2], int(parts[-1])
            if n not in tags or version > tags[n][0]:
                tags[n] = version, ref
    if any(n not in tags for n in REQUIRED):
        raise RuntimeError('CONTEXT_REQUIRED_TAG_ABSENT')
    for n in REQUIRED:
        v, ref = tags[n]
        names = [p for p in git('ls-tree', '-r', '--name-only', ref, '--', 'contracts/').decode().splitlines()
                 if p.startswith('contracts/' + n + '-') and p.endswith('.md') and p.count('/') == 1]
        if len(names) != 1:
            raise RuntimeError('CONTEXT_CONTRACT_NOT_UNIQUE: ' + n)
        command = f'git show frozen/contracts/{n}/{v}^{{commit}}:{names[0]}'
        text = git('show', ref + '^{commit}:' + names[0]).decode()
        if verbose:
            print(command + " | grep '^ЗОНА\\|^ПЕРЕСЕЧЕНИЕ'")
            print('FROZEN', n, v, git('rev-parse', ref + '^{commit}').decode().strip())
            print('\n'.join(line for line in text.splitlines() if line.startswith(('ЗОНА', 'ПЕРЕСЕЧЕНИЕ'))))
    scratch = ROOT / 'tmp/scratch-arch228'
    scratch.mkdir(parents=True, exist_ok=True)
    program = 'set -euo pipefail; . "$1/scripts/lib_zones.sh"; zdir="$(zones_load "$1")"; cat "$zdir/zones_scoped"; __lib_zones_cleanup "$1"'
    rows = subprocess.check_output(['bash', '-c', program, 'context228', str(ROOT)], cwd=ROOT,
                                   env=dict(os.environ, TMPDIR=str(scratch))).decode()
    foreign = list(csv.reader(io.StringIO(rows), delimiter='\t'))
    if not foreign or any(len(row) != 3 for row in foreign):
        raise RuntimeError('CONTEXT_EMPTY_OR_INVALID')
    result = set()
    for other_role, other_path, n in foreign:
        for role, paths in OWN.items():
            if role == other_role and n not in REQUIRED:
                continue
            for path in paths:
                if (path == other_path or other_path.endswith('/') and path.startswith(other_path)
                        or path.endswith('/') and other_path.startswith(path)):
                    result.add((role, path, n))
    return sorted(result)


def main():
    if sys.argv[1:] == ['--snapshot-refs']:
        dest = FAMILY / 'refs.json'
        if dest.exists():
            raise RuntimeError('REF_SNAPSHOT_ALREADY_EXISTS')
        refs = git('for-each-ref', '--format=%(refname) %(objectname)', 'refs/tags/').decode().splitlines()
        dest.write_text(json.dumps([line.split() for line in refs], indent=2) + '\n')
        print('SNAPSHOT_REFS=' + str(len(refs)))
        return
    if sys.argv[1:] == ['--intersections']:
        result = records(False)
        for role, path, n in result:
            print(f'ПЕРЕСЕЧЕНИЕ {role}: {path} — {n} только перенос данных исключений 228; прежние решения и окна сохраняются')
        return
    total = 0
    for gate in (*GATES, 'check_no_leak', 'check_staged'):
        text = (ROOT / 'scripts' / (gate + '.sh')).read_text()
        count = len(re.findall(r'\b[0-9a-f]{40}\b', text))
        code = '\n'.join(line for line in text.splitlines() if not line.lstrip().startswith('#'))
        count_code = len(re.findall(r'\b[0-9a-f]{40}\b', code))
        print(f'SHA40 {gate}: occurrences={count} noncomment={count_code}')
        if gate in GATES:
            total += count
    print('SHA40_TOTAL=' + str(total))
    result = records()
    print('INTERSECTIONS=' + str(len(result)))
    for role, path, n in result:
        print(f'ПЕРЕСЕЧЕНИЕ {role}: {path} — {n} только перенос данных исключений 228; прежние решения и окна сохраняются')


if __name__ == '__main__':
    main()
