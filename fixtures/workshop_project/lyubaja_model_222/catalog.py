#!/usr/bin/env python3
"""Read-only evidence: latest frozen blobs and declared overlapping owners."""
import argparse
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
CONTRACT = 'contracts/222-sudja-ljubaja-model.md'


def git(*args):
    p = subprocess.run(['git', '-C', str(ROOT), *args], capture_output=True, check=True)
    return p.stdout.decode()


def zones(text):
    for line in text.splitlines():
        match = re.fullmatch(r'ЗОНА ([^: ]+): (.+)', line)
        if match:
            for path in match[2].split():
                yield match[1], path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--overlaps', action='store_true')
    parser.add_argument('--frozen', action='store_true')
    args = parser.parse_args()
    latest = {}
    for ref in git('for-each-ref', '--format=%(refname)', 'refs/tags/frozen/contracts/').splitlines():
        match = re.fullmatch(r'refs/tags/frozen/contracts/(\d{3})/(\d+)', ref)
        if match and int(match[2]) > latest.get(match[1], 0):
            latest[match[1]] = int(match[2])
    own = list(zones((ROOT / CONTRACT).read_text()))
    seen = set()
    for number, version in sorted(latest.items()):
        ref = f'frozen/contracts/{number}/{version}'
        paths = git('ls-tree', '-r', '--name-only', ref + '^{commit}', '--', 'contracts/').splitlines()
        paths = [p for p in paths if re.fullmatch(f'contracts/{number}-[^/]+[.]md', p)]
        if len(paths) != 1:
            continue
        text = git('show', ref + '^{commit}:' + paths[0])
        if args.frozen and number in {'028', '099', '104', '129', '140', '166', '186', '198'}:
            print(ref + ' ' + paths[0])
            for lineno, line in enumerate(text.splitlines(), 1):
                if line.startswith('ЗОНА '):
                    print(f'  {lineno}:{line}')
        if args.overlaps:
            for role, path in own:
                for owner, existing in zones(text):
                    overlap = path == existing or (path.endswith('/') and existing.startswith(path)) or (existing.endswith('/') and path.startswith(existing))
                    key = role, path, number
                    if overlap and role != owner and key not in seen:
                        seen.add(key)
                        print(f'ПЕРЕСЕЧЕНИЕ {role}: {path} — {number} {owner}-зона; только дельта 222, прочие обязательства сохраняются.')
    if args.overlaps:
        print(f'OVERLAPS={len(seen)}')


if __name__ == '__main__':
    main()
