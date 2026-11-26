#!/usr/bin/env python3
"""Proposed 154 accounting seam, NOT a replacement for frozen 154/2.

Only positional warning + append-only diagnostic are modeled. This CLI does
not grant a judge, validate accept, create a START, run freeze or issue a tag.
"""
import argparse
import json
from pathlib import Path
import sys


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--ledger', type=Path, required=True)
    parser.add_argument('--repo-id', required=True)
    parser.add_argument('--subject', required=True)
    parser.add_argument('--phase', choices=('spawn', 'freeze'), required=True)
    args = parser.parse_args()
    rows = [json.loads(line) for line in args.ledger.read_bytes().splitlines() if line]
    starts = [row for row in rows if row.get('t') == 'START'
              and row.get('klass') == 'sudja'
              and row.get('rol') in ('critic', 'critic-sol')
              and row.get('repoId') == args.repo_id
              and row.get('subjectId') == args.subject]
    position = len(starts) + (args.phase == 'spawn')
    warning = position > 2
    record = {'t': 'schet154', 'repoId': args.repo_id, 'subjectId': args.subject,
              'phase': args.phase, 'count': len(starts), 'position': position,
              'warning': warning}
    with args.ledger.open('a') as stream:
        stream.write(json.dumps(record, ensure_ascii=False, sort_keys=True) + '\n')
    print(json.dumps(record, ensure_ascii=False, sort_keys=True))
    if warning:
        print(f'ПРЕДУПРЕЖДЕНИЕ: SCHET_154: phase={args.phase} position={position}', file=sys.stderr)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
