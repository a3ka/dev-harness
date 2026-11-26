#!/usr/bin/env python3
"""214 regression: real neighboring batteries on pinned and live door bytes."""
import os
import re
import subprocess
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = 'f82ff8c9d0d4ba45a53b7aa2e712c552141715f9'
FAMILIES = {
    '208': ROOT / 'fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh',
    '211': ROOT / 'fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh',
}


def run(family, root):
    command = ['bash', str(FAMILIES[family]), '--repo', str(root)]
    result = subprocess.run(command, cwd=ROOT, capture_output=True, timeout=600)
    print('REGRESSION', family, str(root), 'RC', result.returncode)
    print(result.stdout.decode('utf-8', 'replace'), end='')
    print(result.stderr.decode('utf-8', 'replace'), end='')
    if result.returncode not in (0, 1):
        raise RuntimeError('REGRESSION_UNAVAILABLE ' + family)
    # Existing family syntax: addressed case labels begin bNN/rNN. Preserve the
    # observed failed label set, not temp paths or broad substring diagnoses.
    labels = tuple(re.findall(rb'(?m)^([br][0-9]+-[^ :\r\n]+).*', result.stdout))
    if not re.search('(KLETKI|клеток)'.encode(), result.stdout):
        raise RuntimeError('EMPTY_REGRESSION ' + family)
    return result.returncode, labels


def main():
    scratch = ROOT / 'tmp/scratch-arch214'
    scratch.mkdir(parents=True, exist_ok=True)
    os.environ['TMPDIR'] = str(scratch)
    with tempfile.TemporaryDirectory(dir=scratch, prefix='regress214-') as tmp:
        base = Path(tmp) / 'base'
        model = Path(tmp) / 'model'
        (base / 'scripts').mkdir(parents=True)
        (model / 'scripts').mkdir(parents=True)
        pinned = subprocess.run(['git', '-C', str(ROOT), 'show', BASE + ':scripts/zamok_predmeta.sh'], capture_output=True, check=True).stdout
        (base / 'scripts/zamok_predmeta.sh').write_bytes(pinned)
        (model / 'scripts/zamok_predmeta.sh').write_bytes((HERE / 'model/zamok_predmeta.sh').read_bytes())
        for family in FAMILIES:
            before, after = run(family, base), run(family, ROOT)
            if before != after:
                raise RuntimeError('REGRESSION_RESULT_CHANGED ' + family)
        if run('208', model)[0] != 0:
            raise RuntimeError('MODEL208_REGRESSION')
    print('REGRESSION_FAMILIES', len(FAMILIES), 'MODEL208_RC', 0)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
