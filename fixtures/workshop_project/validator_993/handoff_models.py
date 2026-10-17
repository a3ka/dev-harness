#!/usr/bin/env python3
"""Proof-only readonly copies of the real CLI; never installs production code.

Bindings are executable: old count -> add-014, deletion-only -> missing-entry-001,
skipped hash -> corrupt-001. Each selected probe includes the full-tree baseline.
"""
import argparse
import json
from pathlib import Path
import subprocess
import sys

from handoff_probe import CLI

COUNT = "assert len(list((P/'db').glob('[0-9][0-9][0-9]_*.sql')))==13"
HASH = "assert hashlib.sha256((P/name).read_bytes()).hexdigest()==sha,name"
COVERAGE = """declared={line.split('  ',1)[1] for line in (P/'FILES.sha256').read_text().splitlines()}
for number in range(1,14):
 paths=list((P/'db').glob(f'{number:03d}_*.sql'))
 assert len(paths)==1,f'db/{number:03d}'
 name=paths[0].relative_to(P).as_posix()
 assert name in declared,name"""


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', required=True, type=Path)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    original = (repo / CLI).read_text()
    assert original.count(COUNT) == 1 and original.count(HASH) == 1, 'SOURCE_SEAM_CHANGED'
    corrected = original.replace(COUNT, COVERAGE)
    # The historical byte/existence check is retained verbatim in corrected.
    variants = [
        ('old', original, None, 1, 'add-014'),
        ('corrected', corrected, None, 0, None),
        ('deleted-count-only', original.replace(COUNT, ''), 'missing-entry-001', 1, 'missing-entry-001'),
        ('skipped-hash', corrected.replace(HASH, 'pass'), 'corrupt-001', 1, 'corrupt-001'),
    ]
    out.mkdir(parents=True, exist_ok=False)
    runner = Path(__file__).with_name('handoff_probe.py')
    summaries = []
    for name, source, selected, expected_rc, witness in variants:
        subject = out / (name + '.py')
        subject.write_text(source)
        subject.chmod(0o444)
        command = [sys.executable, str(runner), '--repo', str(repo), '--out', str(out / name), '--subject', str(subject)]
        if selected:
            command.extend(['--case', selected])
        completed = subprocess.run(command, capture_output=True, text=True, timeout=600)
        (out / (name + '.stdout')).write_text(completed.stdout)
        (out / (name + '.stderr')).write_text(completed.stderr)
        assert completed.returncode == expected_rc, (name, completed.returncode, completed.stderr)
        results = json.loads((out / name / 'raw.json').read_text())
        assert next(row for row in results if row['case'] == 'baseline')['matched'], name
        if witness:
            assert not next(row for row in results if row['case'] == witness)['matched'], (name, witness)
        summaries.append(dict(subject=name, rc=completed.returncode, cases=len(results),
                              mismatches=sum(not row['matched'] for row in results), witness=witness))
        print(json.dumps(summaries[-1]), flush=True)
    (out / 'summary.json').write_text(json.dumps(summaries, indent=2) + '\n')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, AssertionError, subprocess.TimeoutExpired) as error:
        print('993 HANDOFF_MODEL_UNMEASURABLE: ' + str(error), file=sys.stderr)
        sys.exit(2)
