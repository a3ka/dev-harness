#!/usr/bin/env python3
"""Rebuild a real ten-hex collision; --search deterministically finds its salts.

Only a salt is retained, never synthetic object SHA literals or a Git pack.
The search is offline; ordinary cells import a bounded ancestor chain and one
winning head. Seed, author, trees and messages are independent of scratch paths.
"""
import hashlib
import json
from pathlib import Path
import tempfile
import time

PARAMETERS = json.loads((Path(__file__).resolve().parent / 'source.json').read_bytes())['prefix10']
COUNT = PARAMETERS['ancestors']
SEED = PARAMETERS['seed']
SALTS = {False: PARAMETERS['denied_salt'], True: PARAMETERS['allowed_salt']}
IDENTITY = b'architect <architect@dev-harness.local> 1700000000 +0000\n'


def construct(root, base, git, allowed=False, search=False):
    start = time.monotonic()
    stream = bytearray()
    for n in range(COUNT):
        message = f'prefix10 seed {SEED} ancestor {n}\n'.encode()
        stream += (b'commit refs/heads/main\ncommitter ' + IDENTITY +
                   f'data {len(message)}\n'.encode() + message)
        if n == 0:
            stream += f'from {base}\n'.encode()
        stream += b'\n'
    git(root, 'fast-import', '--quiet', data=bytes(stream))
    parent = git(root, 'rev-parse', 'HEAD').decode().strip()
    prefixes = {sha[:10]: sha for sha in git(root, 'rev-list', 'HEAD').decode().splitlines()}
    (root / 'AGENTS.md').write_bytes(b'prefix10 collision forbidden edit\n')
    git(root, 'add', '--', 'AGENTS.md')
    tree = git(root, 'write-tree').decode().strip()
    salt = SALTS[allowed]
    attempts = range(500_000_000) if search else (salt,)
    for attempt in attempts:
        message = f'prefix10 seed {SEED} head {attempt}\n'
        if allowed:
            message += '\nРАЗРЕШИЛ-ВЛАДЕЛЕЦ: AGENTS.md synthetic fixture only\n'
        body = (f'tree {tree}\nparent {parent}\n'.encode() +
                b'author ' + IDENTITY + b'committer ' + IDENTITY + b'\n' + message.encode())
        sha = hashlib.sha1(f'commit {len(body)}\0'.encode() + body).hexdigest()
        if sha[:10] in prefixes:
            base = prefixes[sha[:10]]
            written = git(root, 'hash-object', '-t', 'commit', '-w', '--stdin', data=body).decode().strip()
            if written != sha:
                raise RuntimeError('PREFIX10_GIT_HASH_MISMATCH')
            git(root, 'reset', '--hard', '-q', sha)
            resolved = git(root, 'rev-parse', base, 'HEAD').decode().splitlines()
            if resolved != [base, sha] or base == sha or base[:10] != sha[:10]:
                raise RuntimeError('PREFIX10_WORLD_INVALID')
            git(root, 'merge-base', '--is-ancestor', base, sha)
            count = int(git(root, 'rev-list', '--count', f'{base}..HEAD'))
            print(f'PREFIX10 seed={SEED} ancestors={COUNT} allowed={allowed} salt={attempt} '
                  f'base={base} head={sha} window={count} seconds={time.monotonic()-start:.3f}', flush=True)
            return base
    raise RuntimeError('PREFIX10_SEARCH_EXHAUSTED')


if __name__ == '__main__':
    import argparse
    from probe import git, seed
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--search', action='store_true', required=True)
    ap.add_argument('--allowed', action='store_true')
    args = ap.parse_args()
    with tempfile.TemporaryDirectory(prefix='prefix10-search-') as temporary:
        root = Path(temporary) / 'world'
        seed(root, 1, 1)
        initial = git(root, 'rev-parse', 'HEAD').decode().strip()
        construct(root, initial, git, allowed=args.allowed, search=True)
