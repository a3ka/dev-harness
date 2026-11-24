#!/usr/bin/env python3
"""Reference ONLY for the TSV projection of real model_change + recovery receipt.
The production consumer keeps its existing CLI and human report.
"""
import argparse
import json
import os
from pathlib import Path
import re
import sys


def rows(entries):
    receipts = [e.get('data', {}) for e in entries
                if e.get('type') == 'custom' and e.get('customType') == 'fallback-route-215'
                and e.get('data', {}).get('reason') == 'CONTENT_FALLBACK_SWITCH']
    for entry in entries:
        if entry.get('type') != 'model_change':
            continue
        recovery = any(r.get('modelChangeId') == entry.get('id') and r.get('target') == entry.get('model')
                       for r in receipts)
        yield entry['model'], 'denied' if entry.get('resolvedModelIsFallback') is True or recovery else 'allowed'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--tsv', action='store_true')
    parser.add_argument('--bind', action='store_true')
    parser.add_argument('--session', required=True)
    args = parser.parse_args()
    if not re.fullmatch('[A-Za-z0-9._-]+', args.session):
        return 2
    files = [p for p in Path(os.environ['HARNESS_SESSION_HOME']).rglob('*.jsonl') if p.stem == args.session]
    if not files:
        return 2
    count = 0
    for path in files:
        entries = [json.loads(line) for line in path.read_text().splitlines() if line]
        init = next((e for e in entries if e.get('type') == 'session_init'), {})
        role = init.get('agent', '')
        obj = '-'
        for entry in entries:
            if entry.get('type') == 'message' and entry.get('message', {}).get('role') == 'user':
                for part in entry['message'].get('content', []):
                    match = re.search(r'^OBJECT=([0-9a-f]{40})$', part.get('text', ''), re.M)
                    if match and obj == '-':
                        obj = match[1]
        for model, permission in rows(entries):
            values = [role, model, permission]
            if args.bind:
                values += [args.session, obj]
            print('\t'.join(values))
            count += 1
    return 0 if count else 2


if __name__ == '__main__':
    sys.exit(main())
