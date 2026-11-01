#!/usr/bin/env python3
"""Exercise the real source gate on disposable project repositories and mutant tools."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

TOOLS = Path(__file__).resolve().parents[3]
GATE = 'scripts/check_project_sources.sh'
RESOLVER = 'scripts/profile_resolver.sh'


def put(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def run(argv, **kwargs):
    return subprocess.run([str(x) for x in argv], capture_output=True, text=True,
                          timeout=30, **kwargs)


def patch(path, old, new):
    text = path.read_text()
    if text.count(old) != 1:
        raise AssertionError(f'MUTANT_ANCHOR {path.name}: {text.count(old)}')
    path.write_text(text.replace(old, new, 1))


def project(base, kind):
    root = base / 'project'
    root.mkdir()
    subprocess.run(['git', 'init', '-q', root], check=True)
    p = {'schemaVersion': 1, 'repoId': 'source-probe', 'language': 'typescript',
         'projectLayer': {'version': '1', 'profilePath': 'project-layer.json'},
         'sourceCanon': {'sources': [], 'gate': ['sh', '-c', 'test "$HARNESS_STAGE" = pre_critic && printf "executed\\n" > gate-observed']}}
    put(root / 'project-layer.json', json.dumps({'schemaVersion': 1, 'version': '1',
        'projectId': 'probe', 'workspaceId': 'probe', 'defaults': {}}))
    put(root / 'contracts/probe.md', '# Probe\n')
    path = {'backend': 'migrations/001_core.sql', 'ten': '10.sql',
            'nested': 'a0b/0.md', 'nul': 'source\0.md',
            'absolute': str(root / 'inside.md'), 'dotdot': 'sub/../inside.md',
            'outside': 'link.md', 'directory': 'folder', 'fifo': 'pipe'}[kind]
    if kind in ('backend', 'ten', 'nested'):
        put(root / path, 'source\n')
    elif kind == 'absolute' or kind == 'dotdot':
        put(root / 'inside.md', 'source\n')
    elif kind == 'outside':
        put(base / 'outside.md', 'external\n')
        (root / path).symlink_to(base / 'outside.md')
    elif kind == 'directory':
        (root / path).mkdir()
    elif kind == 'fifo':
        os.mkfifo(root / path)
    p['sourceCanon']['sources'] = [{'path': path, 'priority': 0}]
    put(root / 'harness.project.json', json.dumps(p))
    subprocess.run(['git', '-C', str(root), 'add', '.'], check=True)
    env = dict(os.environ, GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null')
    subprocess.run(['git', '-C', str(root), '-c', 'user.name=Fixture',
                    '-c', 'user.email=fixture@local', 'commit', '-qm', 'probe'],
                   check=True, env=env)
    return root


# The model changes only the observed false-positive; the real resolver and all
# other gate branches remain the implementation under test.
MODEL_CHANGE = ('    *\\0*) die "SOURCE_CANON_INVALID: NUL в пути: $p" ;;\n', '')
STABS = {
    'false-zero': (GATE, None),
    'accept-all': (GATE, ('HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"',
                            'exit 0\nHERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"')),
    'skip-nul-json': (RESOLVER, ('and (($e.value.path | contains("\\u0000")) | not)',
                                 'and (($e.value.path | contains("\\u0001")) | not)')),
    'skip-absolute': ((RESOLVER, ('and (($e.value.path | startswith("/") | not))', 'and true')),
                      (GATE, ('    /*) die "SOURCE_CANON_INVALID: абсолютный путь источника: $p" ;;\n', ''))),
    'skip-dotdot': ((RESOLVER, ('and (($e.value.path | contains("..") | not))', 'and true')),
                    (GATE, ('    *..*) die "SOURCE_CANON_INVALID: .. в пути: $p" ;;\n', ''))),
    'skip-canonical': (GATE, ('"$REPO"/*) ;;        # внутри R — закон',
                                '*) ;;        # источник вне R пропущен')),
    'accept-directory': (GATE, ('if [ ! -f "$full" ]; then', 'if [ ! -e "$full" ]; then')),
    'accept-fifo': (GATE, ('if [ ! -f "$full" ]; then', 'if [ ! -e "$full" ]; then')),
}
# Each mutation must be observable on precisely its assigned conforming input.
STAB_CASE = {'false-zero': 'backend', 'accept-all': 'nul', 'skip-nul-json': 'nul',
             'skip-absolute': 'absolute', 'skip-dotdot': 'dotdot',
             'skip-canonical': 'outside', 'accept-directory': 'directory',
             'accept-fifo': 'fifo'}
CASES = {'backend': (0, ''), 'ten': (0, ''), 'nested': (0, ''),
         'nul': (1, 'SOURCE_CANON_INVALID:'), 'absolute': (1, 'SOURCE_CANON_INVALID:'),
         'dotdot': (1, 'SOURCE_CANON_INVALID:'), 'outside': (1, 'SOURCE_CANON_INVALID:'),
         'directory': (1, 'SOURCE_CANON_INVALID:'), 'fifo': (1, 'SOURCE_CANON_INVALID:')}
REASONS = {'nul': 'NUL', 'absolute': 'абсолютн', 'dotdot': '..',
           'outside': 'вне репозитория', 'directory': 'не regular file',
           'fifo': 'не regular file'}


def tools_for(base, mode):
    if mode == 'repo':
        return TOOLS
    tools = base / 'tools'
    (tools / 'scripts').mkdir(parents=True)
    for name in (GATE, RESOLVER):
        shutil.copy2(TOOLS / name, tools / name)
    gate = tools / GATE
    if mode == 'false-zero':
        if MODEL_CHANGE[0] not in gate.read_text():
            patch(gate, '  case "$p" in\n',
                  '  case "$p" in\n' + MODEL_CHANGE[0])
    elif MODEL_CHANGE[0] in gate.read_text():
        patch(gate, *MODEL_CHANGE)
    if mode in STABS and STABS[mode][1]:
        changes = STABS[mode] if isinstance(STABS[mode][0], tuple) else (STABS[mode],)
        for path, change in changes:
            patch(tools / path, *change)
    return tools


def exercise(case, mode, seed):
    with tempfile.TemporaryDirectory(prefix=f'nul153-{seed}-{case}-') as tmp:
        base = Path(tmp)
        root = project(base, case)
        tools = tools_for(base, mode)
        env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
        env.update(HARNESS_PROJECT_LAYER_ROOT=str(root), GIT_CONFIG_GLOBAL='/dev/null',
                   GIT_CONFIG_SYSTEM='/dev/null')
        r = run(['bash', tools / GATE, '--repo', root,
                 '--contract', 'contracts/probe.md', '--stage', 'pre_critic'],
                cwd=root, env=env)
        expected_rc, prefix = CASES[case]
        good = r.returncode == expected_rc and (not prefix or prefix in r.stderr)
        if case in REASONS:
            good = good and REASONS[case] in r.stderr
        observed = root / 'gate-observed'
        if expected_rc == 0:
            good = good and not r.stderr and not r.stdout and observed.is_file() and observed.read_text() == 'executed\n'
        else:
            good = good and not observed.exists()
        return good, f'{case}: rc={r.returncode} stderr={r.stderr.strip()!r} gate={observed.exists()}'


def main():
    p = argparse.ArgumentParser()
    group = p.add_mutually_exclusive_group()
    group.add_argument('--model', action='store_true')
    group.add_argument('--stabs', action='store_true')
    group.add_argument('--repo', action='store_true')
    p.add_argument('--seed', type=int, default=0)
    args = p.parse_args()
    if args.stabs:
        model = [exercise(case, 'model', args.seed) for case in CASES]
        if not all(ok for ok, _ in model):
            for ok, detail in model:
                if not ok:
                    print('MODEL_RED', detail, file=sys.stderr)
            return 1
        caught = 0
        for stab, case in STAB_CASE.items():
            good, detail = exercise(case, stab, args.seed)
            if good:
                print('STAB_SURVIVED', stab, detail, file=sys.stderr)
            else:
                caught += 1
                print('CAUGHT', stab, case)
        print(f'SVJAZI={len(STABS)} CAUGHT={caught} LIVE={len(STABS)-caught}')
        return 0 if caught == len(STABS) else 1
    mode = 'model' if args.model else 'repo'
    results = [exercise(case, mode, args.seed) for case in CASES]
    for good, detail in results:
        print(('GREEN ' if good else 'RED ') + detail)
    print(f'CELLS={len(CASES)} GREEN={sum(ok for ok, _ in results)}')
    return 0 if all(ok for ok, _ in results) else 1


if __name__ == '__main__':
    sys.exit(main())
