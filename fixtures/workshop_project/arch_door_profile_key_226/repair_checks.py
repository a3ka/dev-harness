#!/usr/bin/env python3
"""226 reviewer delta: real Git census and real CLI status controls."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
FAMILY = HERE.relative_to(ROOT)
CONTEXT_CHECKS = ['before-late-freeze', 'after-late-freeze',
                  'old-head-ancestry-red', 'missing-older-overlap-red']
STATUS_CHECKS = ['honest', 'hooks-skip', 'hooks-invert', 'leaf-skip',
                 'string-check-skip', 'string-check-invert',
                 'honest-seam-failure', 'equivalent-guard']
# Literal reviewer mutations, independent of the generated historical carriers.
MUTATIONS = [
    ('hooks-skip', 'has("hooks")', 'has("hooks") and false'),
    ('hooks-invert', 'has("hooks")', 'has("hooks") | not'),
    ('leaf-skip', '.hooks | has("archBrief")', '.hooks | has("archBrief") and false'),
    ('string-check-skip', 'elif type == "string" then', 'elif 1 == 1 then'),
    ('string-check-invert', 'elif type == "string" then', 'elif (type == "string" | not) then'),
]


def catalog():
    return {'context': CONTEXT_CHECKS, 'status': STATUS_CHECKS}


def run(argv, cwd):
    return subprocess.run([str(x) for x in argv], cwd=cwd, capture_output=True,
                          text=True, timeout=240)


def expect(label, result, rc, token):
    print(label, 'rc=' + str(result.returncode), flush=True)
    if result.returncode != rc or token not in result.stdout + result.stderr:
        raise RuntimeError(label + repr((result.returncode, result.stdout, result.stderr)))


def replace(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError('ANCHOR ' + repr(old))
    return text.replace(old, new, 1)


def context_checks(base):
    repo = base / 'census'
    repo.mkdir()
    def git(*argv):
        result = run(['git', '-c', 'user.name=architect', '-c',
                      'user.email=architect@dev-harness.local', *argv], repo)
        if result.returncode:
            raise RuntimeError('GIT ' + result.stderr)
        return result.stdout.strip()
    git('init', '-q')
    contracts = repo / 'contracts'
    contracts.mkdir()
    (contracts / '201-fixture.md').write_text('ЗОНА implementer: scripts/done_contract.sh\n')
    git('add', '.')
    git('commit', '-qm', '226 fixture: older freeze')
    git('tag', 'frozen/contracts/201/1')
    own = contracts / '226-arch-door-profile-key.md'
    declared = ('ЗОНА implementer: scripts/done_contract.sh\n'
                'ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 201 fixture\n')
    own.write_text(declared)
    git('add', '.')
    git('commit', '-qm', '226 fixture: own freeze')
    git('tag', 'frozen/contracts/226/1')
    script = repo / FAMILY / 'context.py'
    script.parent.mkdir(parents=True)
    original = (HERE / 'context.py').read_text()
    script.write_text(original)
    expect(CONTEXT_CHECKS[0], run([sys.executable, '-B', script], repo), 0, 'MISSING 0')
    (contracts / '223-fixture.md').write_text('ЗОНА implementer: scripts/done_contract.sh\n')
    git('add', str(contracts))
    git('commit', '-qm', '226 fixture: later intersecting freeze')
    git('tag', 'frozen/contracts/223/1')
    git('merge-base', '--is-ancestor', 'frozen/contracts/223/1', 'HEAD')
    expect(CONTEXT_CHECKS[1], run([sys.executable, '-B', script], repo), 0,
           'LATE_FROZEN implementer scripts/done_contract.sh 223')
    script.write_text(replace(original, "commit, 'frozen/contracts/226/1^{commit}'",
                              "commit, 'HEAD'"))
    expect(CONTEXT_CHECKS[2], run([sys.executable, '-B', script], repo), 1,
           'MISSING implementer scripts/done_contract.sh 223')
    script.write_text(original)
    own.write_text('ЗОНА implementer: scripts/done_contract.sh\n')
    expect(CONTEXT_CHECKS[3], run([sys.executable, '-B', script], repo), 1,
           'MISSING implementer scripts/done_contract.sh 201')


def status_checks(base):
    spec = importlib.util.spec_from_file_location('repair_probe226', HERE / 'probe.py')
    probe = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(probe)
    source = json.loads((HERE / 'source.json').read_text())
    tools = probe.materialize(base, 'status', source)
    shutil.copytree(HERE, tools / FAMILY, ignore=shutil.ignore_patterns('__pycache__'))
    resolver = tools / 'scripts/profile_resolver.sh'
    original = (ROOT / 'scripts/profile_resolver.sh').read_text()
    checker = tools / FAMILY / 'probe.py'
    checker_text = checker.read_text()
    command = [sys.executable, '-B', checker, '--repo', tools, '--cell', 'grid-type-null']
    resolver.write_text(original)
    expect('honest', run(command, tools), 0, 'KRASNYH 0')
    for name, old, new in MUTATIONS:
        resolver.write_text(replace(original, old, new))
        expect(name, run(command, tools), 1, 'PUBLIC_COUNTEREXAMPLE:')
    resolver.write_text(original)
    # Break only the observer's argv recognizer, not the real resolver/jq.
    checker.write_text(replace(checker_text, "argv[1] == '-e'", "argv[1] == '--missing-seam-226'"))
    expect('honest-seam-failure', run(command, tools), 2, 'NOT_IMPLEMENTED: GRID_JQ_SEAM')
    checker.write_text(checker_text)
    resolver.write_text(replace(original, '.hooks | has("archBrief")',
                               '.hooks | (has("archBrief") == true)'))
    expect('equivalent-guard', run(command, tools), 0, 'KRASNYH 0')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--context', action='store_true')
    parser.add_argument('--status', action='store_true')
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix='repair226-') as temporary:
        base = Path(temporary)
        if args.context or not args.status:
            context_checks(base)
        if args.status or not args.context:
            status_checks(base)
    print('REPAIR_CONTROLS', len(CONTEXT_CHECKS) if args.context else
          len(STATUS_CHECKS) if args.status else len(CONTEXT_CHECKS) + len(STATUS_CHECKS))
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as exc:
        print('REPAIR_FAILURE:', exc, file=sys.stderr)
        raise SystemExit(1)
