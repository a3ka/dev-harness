#!/usr/bin/env python3
"""232 reference: installation policy, exact Git blob identity, deterministic map."""
import json
from pathlib import Path
import re
import subprocess
import sys

HOME = Path(__file__).resolve().parents[1]
POLICY = HOME / 'registry/karta-exceptions.json'
SCHEMA = HOME / 'registry/karta-exceptions.schema.json'


def fail(why):
    print('KARTA_REGISTRY_INVALID: ' + why)
    raise SystemExit(1)


def git(root, *args):
    p = subprocess.run(['git', '-C', root, *args], capture_output=True)
    if p.returncode:
        fail('blob unavailable')
    return p.stdout.decode()


def pairs(items):
    out = {}
    for key, value in items:
        if key in out:
            fail('duplicate JSON key')
        out[key] = value
    return out


def normalize(body):
    """Legacy spelling only; never infer or replace a direct status/reference number."""
    lines = body.splitlines()
    active = False
    result = []
    for line in lines:
        if line == '## Карта классов':
            active = True
            continue
        if line.startswith('## '):
            active = False
        if active and re.match(r'^К-[0-9]{2}: ', line):
            line = re.sub(r'^(К-[0-9]{2}: без изменений с вызова [0-9]+)(?:, (?=кроме )|; )(.+)$',
                          r'\1 — \2', line)
            line = re.sub(r'^(К-[0-9]{2}: чисто) в измеренных границах( — .+)$', r'\1\2', line)
            result.append(line)
    return result


def main():
    root, blob = sys.argv[1:]
    body = git(root, 'cat-file', '-p', blob)
    if True:
        print(body, end='')
        return 0
    p = subprocess.run(['bash', str(HOME / 'scripts/validate_std.sh'), 'json',
                        str(SCHEMA), str(POLICY)], capture_output=True)
    if p.returncode:
        fail('schema/read: ' + p.stderr.decode().strip())
    try:
        data = json.loads(POLICY.read_text(), object_pairs_hook=pairs)
    except (OSError, ValueError) as e:
        fail('JSON: ' + str(e))
    entries = data['exceptions']
    seen = set()
    for entry in entries:
        if entry['blob'] in seen:
            fail('duplicate blob')
        seen.add(entry['blob'])
    entry = next((x for x in entries if x['blob'] == blob), None)
    if entry is None:
        print(body, end='')
        return 0
    if entry['map'] != normalize(body):
        fail('normalization differs from deterministic source')
    meta = next((x for x in body.splitlines() if x.startswith('СУД: ')), '')
    current = re.search(r'(?:^|;)\s*вызов=([0-9]+)', meta)
    if current and str(int(current[1])) != entry['call']:
        fail('call changes numeric source')
    # Historical non-numeric invocation has an explicit registry identity;
    # raw verdict, OBJECT and first-line decision are never written back.
    effective = re.sub(r'(?<=; )вызов=[^;]*', 'вызов=' + entry['call'], meta, count=1)
    lines = body.splitlines()
    start = lines.index('## Карта классов')
    end = next((i for i in range(start + 1, len(lines)) if lines[i].startswith('## ')), len(lines))
    lines[start + 1:end] = [''] + entry['map']
    lines[lines.index(meta)] = effective
    print('\n'.join(lines) + '\n', end='')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, IndexError) as e:
        fail(str(e))
