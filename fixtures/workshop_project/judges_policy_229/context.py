#!/usr/bin/env python3
"""Exact latest-frozen overlap census, consumed by contract preflight."""
from pathlib import Path
import fnmatch
import re
import subprocess
import sys
ROOT = Path(__file__).resolve().parents[3]
CONTRACT = ROOT / 'contracts/229-g1-g9-judges-policy.md'


def git(*args):
    return subprocess.run(['git', '-C', str(ROOT), *args], check=True, capture_output=True, text=True).stdout


def zones(text):
    return {(role, path) for role, body in re.findall(r'^ЗОНА (\w+): (.*)$', text, re.M) for path in body.split()}


def main():
    latest = {}
    for tag in git('tag', '-l', 'frozen/contracts/*').splitlines():
        match = re.fullmatch(r'frozen/contracts/(\d{3})/(\d+)', tag)
        if match:
            number, version = match.groups()
            if int(version) > latest.get(number, (0, ''))[0]:
                latest[number] = (int(version), tag)
    own, found, checked = zones(CONTRACT.read_text()), set(), 0
    for number, (_, tag) in sorted(latest.items()):
        if number == '229':
            continue
        names = [p for p in git('ls-tree', '-r', '--name-only', tag, 'contracts').splitlines()
                 if p.startswith('contracts/' + number + '-') and p.endswith('.md')]
        for name in names:
            checked += 1
            foreign = zones(git('show', tag + '^{commit}:' + name))
            found.update((role, path, number) for role, path in own
                         if any((path == other or (other.endswith('/') and path.startswith(other)) or fnmatch.fnmatchcase(path, other))
                                and role != author for author, other in foreign))
    if not checked:
        raise RuntimeError('EMPTY_FROZEN_SAMPLE')
    if '--emit' in sys.argv:
        for role, path, number in sorted(found):
            print(f'ПЕРЕСЕЧЕНИЕ {role}: {path} — {number} только judges.policy 229; прочие обязательства сохранены.')
        return 0
    declared = set(re.findall(r'^ПЕРЕСЕЧЕНИЕ (\w+): ([^ ]+) — (\d{3}) ', CONTRACT.read_text(), re.M))
    missing = found - declared
    print('FROZEN', len(latest), 'BLOBS', checked, 'OVERLAPS', len(found), 'MISSING', len(missing))
    for row in sorted(missing):
        print('MISSING', *row)
    return int(bool(missing))


if __name__ == '__main__':
    raise SystemExit(main())
