#!/usr/bin/env python3
"""214: unchanged 211 oracle and strict live/model neighboring regressions."""
import hashlib
import os
import re
import subprocess
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = 'f82ff8c9d0d4ba45a53b7aa2e712c552141715f9'
FAMILIES = {
    '208': ('zamok_object_predok_208/red_zamok_object_predok_208.sh', 35),
    '211': ('d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh', 59),
}
FROZEN_FAMILY = 'fixtures/workshop_project/d52_bootstrap_sudej_211/'
FROZEN_CONTRACT = 'contracts/211-d52-bootstrap-sudej.md'


def original_oracle():
    # Git objects, loaded BEFORE any subject, not the subject's modified disk.
    tree = subprocess.run(['git', '-C', str(ROOT), 'ls-tree', '-rz', BASE, '--', FROZEN_FAMILY, FROZEN_CONTRACT], capture_output=True, check=True).stdout
    expected = {}
    for record in tree.split(b'\0'):
        if not record:
            continue
        metadata, name = record.split(b'\t', 1)
        mode, kind, sha = metadata.split()
        if kind != b'blob' or mode not in (b'100644', b'100755'):
            raise RuntimeError('ORACLE_NOT_REGULAR ' + repr(name))
        expected[name.decode()] = sha.decode()
    if not expected:
        raise RuntimeError('EMPTY_ORACLE')
    return expected


def unchanged(expected):
    actual_paths = {str(p.relative_to(ROOT)) for p in (ROOT / FROZEN_FAMILY).rglob('*') if p.is_file()}
    actual_paths.add(FROZEN_CONTRACT)
    if actual_paths != set(expected):
        raise RuntimeError('FROZEN211_ORACLE_PATHS_CHANGED')
    for path, sha in expected.items():
        data = (ROOT / path).read_bytes()
        if hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest() != sha:
            raise RuntimeError('FROZEN211_ORACLE_CHANGED ' + path)
    print('FROZEN211_UNCHANGED', len(expected))


def run(family, root):
    script, count = FAMILIES[family]
    command = ['bash', str(HERE.parent / script), '--repo', str(root)]
    result = subprocess.run(command, cwd=ROOT, capture_output=True, timeout=600)
    print('REGRESSION', family, str(root), 'RC', result.returncode)
    print(result.stdout.decode('utf-8', 'replace'), end='')
    print(result.stderr.decode('utf-8', 'replace'), end='')
    census = re.findall(rb'SUBJEKT ' + family.encode() + rb': KLETKI ([0-9]+) KRASNYH ([0-9]+)', result.stdout)
    if result.returncode != 0 or census != [(str(count).encode(), b'0')]:
        raise RuntimeError('REGRESSION_RED_OR_EMPTY ' + family)


def main():
    scratch = ROOT / 'tmp/scratch-arch214'
    scratch.mkdir(parents=True, exist_ok=True)
    os.environ['TMPDIR'] = str(scratch)
    oracle = original_oracle()
    unchanged(oracle)
    with tempfile.TemporaryDirectory(dir=scratch, prefix='regress214-') as tmp:
        base = Path(tmp) / 'base'
        model = Path(tmp) / 'model'
        (base / 'scripts').mkdir(parents=True)
        (model / 'scripts').mkdir(parents=True)
        pinned = subprocess.run(['git', '-C', str(ROOT), 'show', BASE + ':scripts/zamok_predmeta.sh'], capture_output=True, check=True).stdout
        (base / 'scripts/zamok_predmeta.sh').write_bytes(pinned)
        (model / 'scripts/zamok_predmeta.sh').write_bytes((HERE / 'model/zamok_predmeta.sh').read_bytes())
        for family in FAMILIES:
            for subject in (base, ROOT, model):
                run(family, subject)
                unchanged(oracle)
    print('REGRESSION_FAMILIES', len(FAMILIES), 'SUBJECTS', 3, 'KRASNYH', 0)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
