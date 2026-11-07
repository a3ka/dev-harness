#!/usr/bin/env python3
"""Reference for the narrow merge-main exception; exit 0 only when safe."""
import subprocess
import sys
import re

ROW = re.compile(rb'(?P<key>[0-9]{3}) \xe2\x86\x92 [0-9a-f]{40}')


def registry_row(key, digit):
    return f'{key} → {digit * 40}\n'


def git(repo, *args):
    return subprocess.run(['git', '-C', repo, *args], capture_output=True)


def changed(repo, base, tip):
    result = git(repo, 'diff', '--name-only', '-z', base, tip)
    if result.returncode:
        raise RuntimeError('DIFF_UNAVAILABLE')
    return set(result.stdout.rstrip(b'\0').split(b'\0')) if result.stdout else set()


def rows(blob):
    result = {}
    for line in blob.splitlines():
        if not line:
            continue
        match = ROW.fullmatch(line)
        if not match:
            raise ValueError('INVALID_REGISTRY_ROW')
        key = match.group('key')
        if key in result:
            raise ValueError('DUPLICATE_REGISTRY_KEY')
        result[key] = line
    return result


def allow(repo, merge, main):
    parents = git(repo, 'rev-list', '--parents', '-n', '1', merge)
    if parents.returncode or len(parents.stdout.split()) != 3:
        return False
    _, p1, p2 = parents.stdout.split()
    p1, p2 = p1.decode(), p2.decode()
    if p2 != main or git(repo, 'merge-base', '--is-ancestor', p1, p2).returncode == 0:
        return False
    base = git(repo, 'merge-base', p1, p2)
    if base.returncode:
        return False
    base = base.stdout.strip().decode()
    overlap = changed(repo, base, p1) & changed(repo, base, p2)
    if overlap - {b'registry/contracts.tsv'}:
        return False
    auto = git(repo, 'merge-tree', '--write-tree', p1, p2)
    tree = git(repo, 'rev-parse', merge + '^{tree}')
    if tree.returncode:
        return False
    if not overlap:
        return auto.returncode == 0 and auto.stdout.splitlines()[0] == tree.stdout.strip()
    # Conflicts only in registry: every parent row survives unchanged, no duplicate keys,
    # no edits to unrelated paths in the merge result.  No `-s ours` partial merge.
    registry = b'registry/contracts.tsv'
    for parent in (p1, p2, merge):
        if git(repo, 'show', parent + ':' + registry.decode()).returncode:
            return False
    left = rows(git(repo, 'show', p1 + ':' + registry.decode()).stdout)
    right = rows(git(repo, 'show', p2 + ':' + registry.decode()).stdout)
    merged = rows(git(repo, 'show', merge + ':' + registry.decode()).stdout)
    if any(key in right and right[key] != val for key, val in left.items()):
        return False
    if merged != left | right:
        return False
    # An independent three-way merge of all other paths must match their final tree.
    # For the registry-conflict case merge-tree returns conflicted tree; compare
    # every non-registry path to the simulated tree instead of trusting its status.
    if not auto.stdout:
        return False
    expected = auto.stdout.splitlines()[0].decode(errors='replace')
    paths = changed(repo, p1, merge) | changed(repo, p2, merge)
    for path in paths - {registry}:
        name = path.decode()
        ours = git(repo, 'rev-parse', merge + ':' + name)
        base_blob = git(repo, 'rev-parse', expected + ':' + name)
        if ours.returncode != base_blob.returncode or ours.stdout != base_blob.stdout:
            return False
    return True


if __name__ == '__main__':
    try:
        sys.exit(0 if allow(*sys.argv[1:]) else 1)
    except (RuntimeError, ValueError, IndexError):
        sys.exit(1)
