#!/usr/bin/env python3
"""054 v+1 (A10): the repo layer lives ONLY at <R>/.harness/harness.project.json.

Modes:
  (bare)    subject = real scripts/profile_resolver.sh; red before the A10 cutover,
            green after it (plus the station-self cell on the real station tree);
  --model   subject = independent in-memory model of the v+1 entry rules (I-1);
  --stabs   every deceptive stub must die on ITS bound cell (N-39 binding is here).

Every world is a disposable git repository.  Expectations (ids, phrases) are literals
taken into memory BEFORE the subject runs; the subject's disk is never the oracle.
"""
import argparse
import json
import os
from pathlib import Path
import secrets
import shutil
import subprocess
import sys
import tempfile

TOOLS = Path(__file__).resolve().parents[3]
RESOLVER = TOOLS / 'scripts/profile_resolver.sh'

# Phrases of contract 054 v+1 (P1, P2, P10) — prefixes, matched per stderr line.
P1 = 'profile ОТКАЗ: нет .harness/harness.project.json: '
P2 = 'profile ОТКАЗ: корень слоя проекта не задан/недоступен.'
P10 = 'profile ОТКАЗ: корневой harness.project.json рядом с .harness/harness.project.json: '
ANY_REFUSAL = 'profile ОТКАЗ: '

TOKEN = secrets.token_hex(4)
REPO_ID = f'toy-054-{TOKEN}'
PROJECT_ID = f'layer-054-{TOKEN}'
OUTSIDE_ID = f'outside-054-{TOKEN}'
STATION_ID = 'dev-harness'

# Pinned cell set (separate literal from CASES: dropping a cell is a CELLSET drift, rc 1).
EXPECTED_CELLS = ('internal-only', 'root-only', 'both', 'neither', 'root-only-no-layer',
                  'both-no-layer', 'internal-symlink-outside')
STATION_CELL = 'station-self'


def git(root, *args):
    return subprocess.run(['git', '-C', str(root), *args], text=True, capture_output=True,
                          check=True).stdout


def profile_bytes(repo_id):
    return json.dumps({
        'schemaVersion': 1, 'repoId': repo_id, 'language': 'typescript',
        'projectLayer': {'version': '1', 'profilePath': 'layer/project.json'},
        'workflowPaths': {'contracts': '.harness/contracts', 'verdicts': '.harness/verdicts',
                          'registry': '.harness/registry', 'fixtures': '.harness/fixtures'},
    })


def world(base, name, state):
    """state ∈ internal | root | both | neither | internal-symlink-outside."""
    root = base / name
    root.mkdir()
    git(root, 'init', '-q')
    git(root, 'config', 'user.name', 'architect')
    git(root, 'config', 'user.email', 'architect@dev-harness.local')
    (root / 'layer').mkdir()
    (root / 'layer/project.json').write_text(json.dumps({
        'schemaVersion': 1, 'version': '1', 'projectId': PROJECT_ID, 'workspaceId': PROJECT_ID}),
        encoding='utf-8')
    (root / '.harness').mkdir()
    (root / 'README.md').write_text('toy\n', encoding='utf-8')
    if state in ('internal', 'both'):
        (root / '.harness/harness.project.json').write_text(profile_bytes(REPO_ID), encoding='utf-8')
    if state in ('root', 'both'):
        (root / 'harness.project.json').write_text(profile_bytes(REPO_ID), encoding='utf-8')
    if state == 'internal-symlink-outside':
        outside = base / f'{name}-outside.json'
        outside.write_text(profile_bytes(OUTSIDE_ID), encoding='utf-8')
        os.symlink(outside, root / '.harness/harness.project.json')
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', name)
    return root


# (cell, world state, layer env, expectation)
CASES = (
    ('internal-only', 'internal', 'valid', ('ok',)),
    ('root-only', 'root', 'valid', ('refuse', P1)),
    ('both', 'both', 'valid', ('refuse', P10)),
    ('neither', 'neither', 'valid', ('refuse', P1)),
    ('root-only-no-layer', 'root', 'empty', ('refuse', P1)),
    ('both-no-layer', 'both', 'empty', ('refuse', P10)),
    ('internal-symlink-outside', 'internal-symlink-outside', 'valid', ('refuse', ANY_REFUSAL)),
)

# Deceptive stubs bound to the ONE cell where each is observable (N-39).
STUBS = (
    ('root-fallback', 'root-only'),
    ('no-p10', 'both'),
    ('legacy-root', 'internal-only'),
    ('layer-first', 'root-only-no-layer'),
    ('p10-after-layer', 'both-no-layer'),
    ('no-boundary', 'internal-symlink-outside'),
)


class Result:
    def __init__(self, rc, out, err):
        self.returncode, self.stdout, self.stderr = rc, out, err


def model(root, env, variant='honest'):
    """Independent oracle of 054 v+1 I-1/I-2 entry order; NOT a copy of the resolver."""
    def refuse(msg):
        return Result(1, '', msg + '\n')

    internal = root / '.harness/harness.project.json'
    legacy = root / 'harness.project.json'
    layer_root = env.get('HARNESS_PROJECT_LAYER_ROOT', '')
    layer_ok = bool(layer_root) and Path(layer_root).is_dir()
    if variant == 'layer-first' and not layer_ok:
        return refuse(P2 + ' Инструкция: export HARNESS_PROJECT_LAYER_ROOT=<...>')
    if variant == 'p10-after-layer' and not layer_ok:
        return refuse(P2 + ' Инструкция: export HARNESS_PROJECT_LAYER_ROOT=<...>')
    if variant not in ('no-p10', 'legacy-root', 'p10-after-layer') \
            and os.path.lexists(legacy) and os.path.lexists(internal):
        return refuse(P10 + f'{legacy}. Инструкция: удалите корневой профиль — fallback нет')
    if variant == 'p10-after-layer' and os.path.lexists(legacy) and os.path.lexists(internal):
        return refuse(P10 + f'{legacy}. Инструкция: удалите корневой профиль — fallback нет')
    path = internal
    if variant == 'legacy-root':
        path = legacy
        if not path.is_file():
            return refuse(f'profile ОТКАЗ: нет harness.project.json: {path}.')
    elif not os.path.lexists(internal):
        if variant == 'root-fallback' and legacy.is_file():
            path = legacy
        else:
            return refuse(P1 + f'{internal}. Инструкция: создайте .harness/harness.project.json в репо')
    real = os.path.realpath(path)
    if variant != 'no-boundary' and not real.startswith(os.path.realpath(root) + os.sep):
        return refuse(f'profile ОТКАЗ: нет файла репо-слоя в корне репо: {path}. не symlink на внешний файл')
    if not layer_ok:
        return refuse(P2 + ' Инструкция: export HARNESS_PROJECT_LAYER_ROOT=<...>')
    repo = json.loads(Path(real).read_text(encoding='utf-8'))
    layer_file = Path(layer_root) / repo['projectLayer']['profilePath']
    if not layer_file.is_file():
        return refuse(f'profile ОТКАЗ: нет файла слоя проекта: {layer_file}')
    layer = json.loads(layer_file.read_text(encoding='utf-8'))
    return Result(0, json.dumps({'repoId': {'value': repo['repoId'], 'origin': 'repo'},
                                 'projectId': {'value': layer['projectId'], 'origin': 'project'}}), '')


def real_resolver(root, env):
    r = subprocess.run(['bash', str(RESOLVER), '--repo', str(root)], text=True,
                       capture_output=True, env=env)
    return Result(r.returncode, r.stdout, r.stderr)


def judge(expect, r, want_repo, want_project):
    """Return None when the outcome matches the in-memory expectation, else a named reason."""
    if expect[0] == 'ok':
        if r.returncode != 0:
            return f'expected rc 0, got rc {r.returncode}: {first(r.stderr)}'
        try:
            got = json.loads(r.stdout)
            repo, proj = got['repoId'], got['projectId']
        except (ValueError, KeyError, TypeError):
            return 'expected resolver JSON on stdout'
        if repo != {'value': want_repo, 'origin': 'repo'} or proj.get('value') != want_project:
            return f'identity mismatch: repoId={repo} projectId={proj}'
        return None
    prefix = expect[1]
    if r.returncode != 1:
        return f'expected rc 1 refusal, got rc {r.returncode}'
    if r.stdout.strip():
        return 'refusal printed profile values on stdout'
    if not any(line.startswith(prefix) for line in r.stderr.splitlines()):
        return f'expected phrase {prefix!r}, got: {first(r.stderr)}'
    return None


def first(text):
    lines = [line for line in text.splitlines() if line.strip()]
    return lines[0][:240] if lines else '<empty>'


def env_for(root, layer):
    env = os.environ.copy()
    env['HARNESS_PROJECT_LAYER_ROOT'] = str(root) if layer == 'valid' else ''
    return env


def run_cells(subject):
    red = examined = 0
    seen = []
    with tempfile.TemporaryDirectory(prefix='a10-054-') as tmp:
        base = Path(tmp)
        for name, state, layer, expect in CASES:
            root = world(base, name, state)
            reason = judge(expect, subject(root, env_for(root, layer)), REPO_ID, PROJECT_ID)
            examined += 1
            seen.append(name)
            if reason is None:
                print(f'CELL {name}: ok')
            else:
                red += 1
                print(f'CELL {name}: RED ({reason.replace(str(base), "<tmp>")})')
    return examined, red, seen


def station_cell():
    """Station profile after A10: the SAME rule as for products, no self exception."""
    tracked = git(TOOLS, 'ls-files', '--', 'harness.project.json', '.harness/harness.project.json').split()
    if tracked != ['.harness/harness.project.json']:
        return f'station tracks {tracked or "nothing"}, expected only .harness/harness.project.json'
    env = os.environ.copy()
    env['HARNESS_PROJECT_LAYER_ROOT'] = str(TOOLS)
    r = real_resolver(TOOLS, env)
    if r.returncode != 0:
        return f'station resolver rc {r.returncode}: {first(r.stderr)}'
    if json.loads(r.stdout).get('repoId', {}).get('value') != STATION_ID:
        return 'station repoId is not dev-harness'
    return None


def check_cellset(seen):
    if tuple(seen) != EXPECTED_CELLS:
        print(f'CELLSET drift: ran {seen}, pinned {list(EXPECTED_CELLS)}')
        return False
    return True


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    args = ap.parse_args()
    if args.stabs:
        caught = 0
        with tempfile.TemporaryDirectory(prefix='a10-054-stab-') as tmp:
            base = Path(tmp)
            cells = {c[0]: c for c in CASES}
            for stub, cell in STUBS:
                name, state, layer, expect = cells[cell]
                root = world(base, f'{stub}--{name}', state)
                env = env_for(root, layer)
                honest = judge(expect, model(root, env), REPO_ID, PROJECT_ID)
                deceived = judge(expect, model(root, env, stub), REPO_ID, PROJECT_ID)
                if honest is None and deceived is not None:
                    caught += 1
                    print(f'STAB {stub}@{cell}: caught')
                else:
                    print(f'STAB {stub}@{cell}: ALIVE (honest={honest}, stub={deceived})')
        print(f'054-a10 stabs: examined={len(STUBS)} caught={caught}')
        return 0 if STUBS and caught == len(STUBS) else 1
    subject = model if args.model else real_resolver
    examined, red, seen = run_cells(subject)
    if not args.model:
        reason = station_cell()
        examined += 1
        if reason is None:
            print(f'CELL {STATION_CELL}: ok')
        else:
            red += 1
            print(f'CELL {STATION_CELL}: RED ({reason})')
    ok_set = check_cellset(seen)
    mode = 'model' if args.model else 'red'
    print(f'054-a10 ({mode}): examined={examined} red={red}')
    if examined == 0:
        return 1
    return 0 if red == 0 and ok_set else 1


if __name__ == '__main__':
    sys.exit(main())
