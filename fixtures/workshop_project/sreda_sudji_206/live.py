#!/usr/bin/env python3
"""Observe the genuine lock ledger; this program never writes accounting events."""
import argparse
from datetime import datetime
import json
from pathlib import Path
import sys

ROLES = ('critic', 'adversary', 'reviewer')


def assess(rows, since, repo_id, subject):
    cutoff = datetime.fromisoformat(since.replace('Z', '+00:00'))
    selected = [r for r in rows if r.get('repoId') == repo_id and str(r.get('subjectId')) == subject
                and datetime.fromisoformat(r['at'].replace('Z', '+00:00')) >= cutoff]
    starts = [r for r in selected if r.get('t') == 'START' and r.get('klass') == 'sudja' and r.get('rol') in ROLES]
    if len(starts) != 3 or tuple(r['rol'] for r in starts) != ROLES or len({r['holder'] for r in starts}) != 3:
        return 1, 'TRI_SUDA_NE_PREDJAVLENY'
    if any(r.get('t') == 'RELEASE' and r.get('prichina') == 'obryv_bez_verdikta' for r in selected):
        return 1, 'OBRYV_BEZ_VERDIKTA'
    previous = -1
    for start in starts:
        i = selected.index(start)
        releases = [(n, r) for n, r in enumerate(selected) if r.get('t') == 'RELEASE' and r.get('holder') == start['holder']]
        if i <= previous or len(releases) != 1 or releases[0][0] <= i or releases[0][1].get('prichina') != 'verdikt_zakommiten':
            return 1, 'VERDIKT_NE_PODTVERZHDEN'
        previous = releases[0][0]
    return 0, 'SUDA=3 OBRYVOV=0 VERDIKTOV=3'


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--ledger', type=Path, required=True)
    p.add_argument('--since', required=True)
    p.add_argument('--repo-id', required=True)
    p.add_argument('--subject', required=True)
    args = p.parse_args()
    try:
        # Snapshot before assessment, never ask the judged project for expectations.
        rows = [json.loads(line) for line in args.ledger.read_bytes().splitlines()]
        rc, message = assess(rows, args.since, args.repo_id, args.subject)
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f'NOT_IMPLEMENTED: {error}', file=sys.stderr)
        return 2
    print(message)
    return rc


if __name__ == '__main__':
    sys.exit(main())
