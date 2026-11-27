#!/usr/bin/env python3
"""Live highest-frozen source/zone census; exact paths, no historical-version inflation."""
from pathlib import Path
import fnmatch
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
CONTRACT = ROOT / 'contracts/226-arch-door-profile-key.md'


def git(*args):
    return subprocess.run(['git', '-C', str(ROOT), *args], check=True,
                          capture_output=True, text=True).stdout


def zones(text):
    return {(role, path) for role, body in re.findall(r'^ЗОНА (\w+): (.*)$', text, re.M)
            for path in body.split()}


def main():
    latest = {}
    for tag in git('tag', '-l', 'frozen/contracts/*').splitlines():
        match = re.fullmatch(r'frozen/contracts/(\d{3})/(\d+)', tag)
        if match:
            n, v = match.groups()
            if int(v) > latest.get(n, (0, ''))[0]:
                latest[n] = (int(v), tag)
    found, late, checked = set(), {}, 0
    own = zones(CONTRACT.read_text())
    for number, (_, tag) in sorted(latest.items()):
        if number == '226':
            continue
        names = [p for p in git('ls-tree', '-r', '--name-only', tag, 'contracts').splitlines()
                 if p.startswith('contracts/' + number + '-') and p.endswith('.md')]
        for name in names:
            checked += 1
            text = git('show', tag + '^{commit}:' + name)
            if '--sources' in sys.argv and number in {'203','187','188','170','186','193','184','996'}:
                print('SOURCE', tag, git('rev-parse', tag + '^{commit}').strip(), name)
                print('\n'.join(line for line in text.splitlines() if line.startswith(('ЗОНА', 'ПЕРЕСЕЧЕНИЕ'))))
            foreign = zones(text)
            commit = git('rev-parse', tag + '^{commit}').strip()
            ancestry = subprocess.run(
                ['git', '-C', str(ROOT), 'merge-base', '--is-ancestor', commit, 'frozen/contracts/226/1^{commit}'],
                capture_output=True)
            if ancestry.returncode not in (0, 1):
                raise RuntimeError('FROZEN_ANCESTRY ' + tag)
            overlaps = {(role, path, number) for role, path in own
                        if any((path == other or (other.endswith('/') and path.startswith(other)) or fnmatch.fnmatchcase(path, other))
                               and (role != author or role == 'implementer') for author, other in foreign)}
            if ancestry.returncode == 1:
                # Census still reads every live tag and reports exact paths.
                # Independent later freezes cannot amend the frozen 226 text.
                late.update({row: (tag, commit) for row in overlaps})
                continue
            found.update((role, path, number) for role, path in own
                         if any((path == other or (other.endswith('/') and path.startswith(other)) or fnmatch.fnmatchcase(path, other))
                                and (role != author or role == 'implementer') for author, other in foreign))
    if not checked:
        raise RuntimeError('EMPTY_FROZEN_SAMPLE')
    if '--emit' in sys.argv:
        for role, path, number in sorted(found):
            print(f'ПЕРЕСЕЧЕНИЕ {role}: {path} — {number} только профильная дельта 226; прочие обязательства сохранены.')
        return 0
    declared = set(re.findall(r'^ПЕРЕСЕЧЕНИЕ (\w+): ([^ ]+) — (\d{3}) ', CONTRACT.read_text(), re.M))
    missing = found - declared
    print('FROZEN', len(latest), 'BLOBS', checked, 'OVERLAPS', len(found), 'MISSING', len(missing))
    for row, (tag, commit) in sorted(late.items()):
        print('LATE_FROZEN', *row, tag, commit, 'поздний frozen: не предок заморозки 226/1')
    for row in sorted(missing):
        print('MISSING', *row)
    return int(bool(missing))


if __name__ == '__main__':
    raise SystemExit(main())
