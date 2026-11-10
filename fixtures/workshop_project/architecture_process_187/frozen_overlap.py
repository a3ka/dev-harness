#!/usr/bin/env python3
"""Enumerate frozen-zone intersections independently of the first-error precision gate."""
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CONTRACT = ROOT / 'contracts/187-arhitektura-v-processe.md'

def git(*args):
    return subprocess.run(['git', '-C', str(ROOT), *args], capture_output=True,
                          text=True, check=True).stdout

def zones(text):
    return {(role, path) for role, body in re.findall(r'^ЗОНА (\w+): (.*)$', text, re.M)
            for path in body.split()}

def main():
    text = CONTRACT.read_text()
    target = zones(text)
    declared = set(re.findall(r'^ПЕРЕСЕЧЕНИЕ (\w+): ([^ ]+) — (\d{3}) ', text, re.M))
    tags = git('tag', '-l', 'frozen/contracts/*').splitlines()
    found = set()
    checked = 0
    for tag in tags:
        nnn = tag.split('/')[2]
        names = git('ls-tree', '-r', '--name-only', tag, 'contracts').splitlines()
        for name in names:
            if not name.removeprefix('contracts/').startswith(nnn + '-'):
                continue
            checked += 1
            frozen = git('show', tag + ':' + name)
            owners = zones(frozen)
            found.update((role, path, nnn) for role, path in target
                         if any(frozen_path == path and frozen_role != role
                                for frozen_role, frozen_path in owners) and nnn != '187')
    missing = sorted(found - declared)
    print(f'FROZEN_TAGS={len(tags)} CONTRACT_BLOBS={checked} OVERLAPS={len(found)} UNDECLARED={len(missing)}')
    for record in missing:
        print('UNDECLARED', *record)
    return int(bool(missing) or not checked)

if __name__ == '__main__':
    raise SystemExit(main())
