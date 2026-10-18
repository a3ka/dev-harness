#!/usr/bin/env python3
"""Behavioral red probes: public CLI -> real files, commits, tags and gate exec.
Expected paths/statuses are held before the subject executes. Toy repos have their
own .git and no link to a workstation checkout. Models never read the oracle.
"""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
TOOLS = HERE.parents[2]


def run(argv, cwd=None, env=None):
    return subprocess.run([str(a) for a in argv], cwd=cwd, env=env, text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=35)


def git(root, *args):
    r = run(['git', '-C', root, *args])
    if r.returncode:
        raise RuntimeError(r.stderr)
    return r.stdout.strip()


def put(root, path, content):
    p = root / path
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(content)
    return p


def commit(root, message):
    git(root, 'add', '.')
    git(root, 'commit', '-qm', message)


def world(base):
    root = base / 'project'
    origin = base / 'origin.git'
    root.mkdir()
    git(root, 'init', '-q', '-b', 'main')
    git(root, 'config', 'user.name', 'Fixture')
    git(root, 'config', 'user.email', 'fixture@local')
    git(root, 'config', 'receive.denyCurrentBranch', 'refuse')
    git(root, 'init', '--bare', '-q', str(origin))
    git(root, 'remote', 'add', 'origin', str(origin))
    paths = {'contracts': '.harness/tasks', 'verdicts': '.harness/judgements',
             'registry': '.harness/ledger', 'fixtures': '.harness/probes'}
    p = {'schemaVersion': 1, 'repoId': 'toy-' + base.name, 'language': 'typescript',
         'projectLayer': {'version': '1', 'profilePath': 'project-layer.json'},
         'workflowPaths': paths,
         'git': {'canonicalRemote': str(origin)},
         'commands': dict.fromkeys(['test', 'lint', 'typecheck', 'build'], 'bash check.sh'),
         'ci': {'workflow': '.github/workflows/toy.yml'},
         'barriers': {'mandatory': [], 'optional': []}}
    put(root, 'harness.project.json', json.dumps(p))
    put(root, 'project-layer.json', json.dumps({'schemaVersion': 1, 'version': '1',
        'projectId': 'p', 'workspaceId': 'w', 'defaults': {}}))
    put(root, 'check.sh', '#!/bin/sh\ntest -s AGENTS.md\n')
    put(root, 'AGENTS.md', '# Toy project\n')
    put(root, '.github/workflows/toy.yml', 'name: toy\non: push\njobs:\n  check:\n    runs-on: ubuntu-latest\n    steps:\n      - run: bash check.sh\n')
    put(root, 'package.json', json.dumps({'private': True, 'scripts': {'check:toy': 'bash check.sh'}}))
    put(root, 'config/ci_parity_exceptions.txt', '# No exceptions: the sole command is executed in CI.\n')
    contract = paths['contracts'] + '/777-toy.md'
    put(root, contract, '# Toy\nКОНТЕКСТ: AGENTS.md\n## Существующее\nAGENTS.md\n## Предмет\nToy boundary\nЗОНА implementer: app/\nПРОВОДКА:\n- guard=check.sh\nПРОВОДКА-ЭНФОРСМЕНТ: чистый энфорсмент\n')
    put(root, paths['verdicts'] + '/critic/contracts-777-v1.md', 'accept\n')
    put(root, paths['verdicts'] + '/review/contracts-777-v1.md', 'ACCEPT\n')
    for directory in paths.values():
        (root / directory).mkdir(parents=True, exist_ok=True)
    commit(root, 'toy bootstrap')
    parity = run(['bash', TOOLS / 'scripts/verify_ci_parity.sh', root])
    if parity.returncode:
        raise RuntimeError('toy prerequisite CI parity: ' + parity.stdout + parity.stderr)
    return root, origin, p, contract


def subject(mode, op, root, *args, mutant=''):
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    env.update(HARNESS_TOOLS_ROOT=str(TOOLS), HARNESS_WORKFLOW_ROOT=str(root),
               HARNESS_PROJECT_LAYER_ROOT=str(root), MUTANT_996=mutant,
               GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               PYTHONDONTWRITEBYTECODE='1')
    if mode == 'model':
        cmd = [sys.executable, HERE / 'model.py', op, root, *args]
    else:
        commands = {
            'paths': ['bash', TOOLS / 'scripts/project_workflow.sh', '--repo', root],
            'gitw': ['bash', TOOLS / 'scripts/gitw', '-C', root, *args],
            'freeze': ['bash', TOOLS / 'scripts/freeze_contract.sh', *args, '996 probe', root],
            'done': ['bash', TOOLS / 'scripts/done_contract.sh', *args, '996 probe', root],
            'pre_critic': ['bash', TOOLS / 'scripts/pre_critic.sh', '--repo', root, *args],
            'sources': ['bash', TOOLS / 'scripts/check_project_sources.sh', '--repo', root,
                        '--contract', *args, '--stage', 'pre_critic'],
            'reserve': ['bash', TOOLS / 'scripts/reserve_project_contract.sh', '--repo', root],
        }
        cmd = commands[op]
    return run(cmd, cwd=root, env=env)


def expect(condition, reason, result=None):
    if not condition:
        detail = '' if result is None else f' rc={result.returncode} stdout={result.stdout!r} stderr={result.stderr!r}'
        raise AssertionError(reason + detail)


def canon(root, p, gate_exit=0):
    # Gate observes actual cwd, HEAD, stage and literal argv in its own output.
    put(root, 'SOURCE.md', '# Requirement\nNo bypass.\n')
    put(root, 'source_gate.py', 'import json,os,subprocess,sys\nfrom pathlib import Path\n'
        'head=subprocess.check_output(["git","rev-parse","HEAD"],text=True).strip()\n'
        'data={"cwd":str(Path.cwd()),"head":head,"contract":os.environ.get("HARNESS_CONTRACT"),'
        '"stage":os.environ.get("HARNESS_STAGE"),"arg":sys.argv[1]}\n'
        'Path("gate-observed.json").write_text(json.dumps(data))\n'
        'assert os.environ.get("HARNESS_HEAD")==head\n'
        f'sys.exit({gate_exit})\n')
    p['sourceCanon'] = {'sources': [{'path': 'SOURCE.md', 'priority': 0}],
                        'gate': [sys.executable, 'source_gate.py', 'literal ; $(not-shell)']}
    put(root, 'harness.project.json', json.dumps(p))
    commit(root, 'source canon')


def test(case, mode, base, mutant):
    root, origin, p, contract = world(base)
    call = lambda op, *args: subject(mode, op, root, *args, mutant=mutant)
    if case in ('git-profile', 'git-layer', 'git-reject'):
        if case == 'git-layer':
            remote = p.pop('git')
            put(root, 'harness.project.json', json.dumps(p))
            layer = json.loads((root / 'project-layer.json').read_text())
            layer['defaults']['git'] = remote
            put(root, 'project-layer.json', json.dumps(layer))
            commit(root, 'layer canonical')
        destination = 'origin'
        if case == 'git-reject':
            foreign = base / 'foreign.git'
            git(root, 'init', '--bare', '-q', str(foreign))
            destination = str(foreign)
        before = git(root, 'rev-parse', 'HEAD')
        r = call('gitw', 'push', destination, 'HEAD:refs/heads/probe')
        receiver = origin if destination == 'origin' else Path(destination)
        refs = git(receiver, 'for-each-ref', '--format=%(objectname)', 'refs/heads/probe')
        if case == 'git-reject':
            expect(r.returncode == 1 and not refs, 'FOREIGN_ORIGIN_ACCEPTED', r)
        else:
            expect(r.returncode == 0 and refs == before, 'PROFILE_EXCHANGE_NOT_DELIVERED', r)
    elif case in ('freeze-profile', 'freeze-decoy', 'done-profile', 'done-decoy', 'done-fresh'):
        op = 'freeze' if case.startswith('freeze') else 'done'
        role = 'critic' if op == 'freeze' else 'review'
        if case.endswith('decoy'):
            put(root, p['workflowPaths']['verdicts'] + f'/{role}/contracts-777-v1.md', 'FAIL\n')
            put(root, f'verdicts/{role}/contracts-777-v1.md', 'accept\n')
            commit(root, 'profile refuses root decoy')
        if case == 'done-fresh':
            put(root, p['workflowPaths']['verdicts'] + '/review/contracts-777-v2.md', 'FAIL\n')
            commit(root, 'newer review refuses')
        before = git(root, 'rev-parse', 'HEAD')
        r = call(op, contract)
        prefix = 'frozen' if op == 'freeze' else 'done'
        tag = git(root, 'tag', '-l', f'{prefix}/contracts/777/*')
        negative = case.endswith('decoy') or case == 'done-fresh'
        if negative:
            expected_reason = 'критик' if op == 'freeze' else 'вердикт'
            expect(r.returncode == 1 and expected_reason in r.stderr and not tag
                   and git(root, 'rev-parse', 'HEAD') == before, 'VERDICT_REFUSAL_NOT_ATOMIC', r)
        else:
            expect(r.returncode == 0 and tag == f'{prefix}/contracts/777/1', 'PROFILE_LIFECYCLE_MISSING', r)
            if op == 'freeze':
                reg = root / p['workflowPaths']['registry'] / 'contracts.tsv'
                expected = '777 → ' + git(root, 'rev-parse', tag) + '\n'
                expect(reg.read_text() == expected and not (root / 'registry').exists(), 'REGISTRY_NOT_PROJECT_LOCAL')
    elif case in ('paths', 'paths-escape'):
        if case == 'paths-escape':
            p['workflowPaths']['verdicts'] = '../outside'
            put(root, 'harness.project.json', json.dumps(p))
        r = call('paths')
        if case == 'paths-escape':
            expect(r.returncode == 1 and 'workflowPaths' in r.stderr, 'ESCAPE_ACCEPTED', r)
        else:
            expect(r.returncode == 0, 'PATH_CONTEXT_MISSING', r)
            got = json.loads(r.stdout)
            expected = {k: str(root / v) for k, v in p['workflowPaths'].items()}
            expected.update(handoff=str(root / '.harness/HANDOFF.md'),
                observations=str(root / '.harness/NABLIUDENIA.md'),
                architectObservations=str(root / '.harness/NABLIUDENIA_ARCHITECT.md'),
                roadmap=str(root / '.harness/ROADMAP.md'), forks=str(root / '.harness/forks'))
            expect(all(got.get(k) == v for k, v in expected.items()), 'STATION_CONTEXT_WRONG_ROOT')
    elif case == 'reserve-origin':
        r = call('reserve')
        expect(r.returncode == 0, 'RESERVATION_UNAVAILABLE', r)
        n = r.stdout.strip().splitlines()[-1]
        expect(len(n) == 3 and n.isdecimal(), 'RESERVATION_NUMBER_NOT_CANONICAL', r)
        tag = 'refs/tags/id/CONTRACT/' + n
        local = git(root, 'rev-parse', tag)
        remote = git(origin, 'for-each-ref', '--format=%(objectname)', tag)
        expect(remote == local, 'RESERVATION_NOT_ON_PROJECT_ORIGIN')
    elif case == 'station-isolation':
        install = base / 'install'
        install.mkdir()
        git(install, 'init', '-q', '-b', 'main')
        git(install, 'config', 'user.name', 'Fixture')
        git(install, 'config', 'user.email', 'fixture@local')
        for name in ('HANDOFF.md', 'NABLIUDENIA.md', 'NABLIUDENIA_ARCHITECT.md',
                     'registry/contracts.tsv', 'forks/state.md'):
            put(install, name, 'installation state\n')
        commit(install, 'isolated installation')
        scratch = base / 'leak-scratch'
        scratch.mkdir()
        env = dict(os.environ, TMPDIR=str(scratch))
        leak = lambda stage: run(['bash', TOOLS / 'scripts/check_no_leak.sh', stage, install], env=env)
        r = leak('--snapshot')
        expect(r.returncode == 0, 'LEAK_SNAPSHOT_FAILED', r)
        r = call('freeze', contract)
        expect(r.returncode == 0, 'STATION_FREEZE_FAILED', r)
        r = leak('--check')
        expect(r.returncode == 0, 'STATION_POLLUTED_INSTALLATION', r)
        put(install, 'HANDOFF.md', 'intentional detector canary\n')
        r = leak('--check')
        expect(r.returncode == 1 and 'загрязнён' in r.stderr + r.stdout,
               'DETECTOR_BLIND_TO_INSTALLATION', r)
    elif case.startswith('canon-'):
        negative = case in ('canon-fail', 'canon-done-fail', 'canon-precritic-fail', 'canon-invalid')
        if case != 'canon-absent':
            canon(root, p, 7 if negative else 0)
        if case == 'canon-invalid':
            p['sourceCanon']['unknown'] = 1
            put(root, 'harness.project.json', json.dumps(p))
        op = 'done' if case == 'canon-done-fail' else 'sources'
        if case == 'canon-precritic-fail':
            op = 'pre_critic'
        before = git(root, 'rev-parse', 'HEAD')
        r = call(op, contract)
        if negative:
            reason = 'SOURCE_CANON_INVALID' if case == 'canon-invalid' else 'SOURCE_GATE_FAILED'
            expect(r.returncode == 1 and reason in r.stderr, 'CANON_REFUSAL_MISSING', r)
            expect(not git(root, 'tag', '-l', 'done/contracts/777/*') and
                   git(root, 'rev-parse', 'HEAD') == before, 'CANON_REFUSAL_NOT_ATOMIC')
        else:
            expect(r.returncode == 0, 'CANON_GREEN_REFUSED', r)
            if case == 'canon-absent':
                expect(not (root / 'gate-observed.json').exists(), 'ABSENT_CANON_EXECUTED')
            else:
                expected = {'cwd': str(root), 'head': before, 'contract': contract,
                            'stage': 'pre_critic', 'arg': 'literal ; $(not-shell)'}
                expect(json.loads((root / 'gate-observed.json').read_text()) == expected,
                       'CANON_EXEC_CONTEXT_WRONG')
    else:
        raise AssertionError('unknown case')


CASES = ('git-profile', 'git-layer', 'git-reject', 'freeze-profile', 'freeze-decoy',
         'done-profile', 'done-decoy', 'done-fresh', 'paths', 'paths-escape',
         'reserve-origin', 'canon-green', 'canon-fail', 'canon-done-fail',
         'canon-invalid', 'canon-absent', 'canon-precritic-fail', 'station-isolation')
# Н-39: each mutation is challenged only where its defect is observable.
MUTANTS = {'hardcoded-origin': ('git-profile', 'git-layer'),
           'trust-target': ('git-reject',), 'root-layout': ('paths',),
           'root-verdict': ('freeze-profile', 'done-profile'),
           'ignore-critic': ('freeze-decoy',), 'ignore-review': ('done-decoy',),
           'old-review': ('done-fresh',), 'accept-escape': ('paths-escape',),
           'local-reservation': ('reserve-origin',),
           'station-writes-tools': ('station-isolation',),
           'skip-canon': ('canon-fail', 'canon-done-fail', 'canon-precritic-fail'),
           'canon-tools-cwd': ('canon-green',),
           'ignore-canon-keys': ('canon-invalid',), 'require-canon': ('canon-absent',)}


def execute(case, mode, mutant=''):
    with tempfile.TemporaryDirectory(prefix='architect996-', dir='/tmp') as tmp:
        try:
            test(case, mode, Path(tmp), mutant)
            return 0, ''
        except AssertionError as error:
            return 1, str(error)
        except (RuntimeError, OSError, ValueError, subprocess.TimeoutExpired) as error:
            return 2, 'PROBE_ERROR: ' + str(error)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--model', action='store_true')
    parser.add_argument('--matrix', action='store_true')
    parser.add_argument('--case', choices=CASES)
    parser.add_argument('--mutant', choices=MUTANTS)
    args = parser.parse_args()
    mode = 'model' if args.model or args.matrix or args.mutant else 'product'
    cases = (args.case,) if args.case else CASES
    errors = 0
    for case in cases:
        rc, detail = execute(case, mode, args.mutant or '')
        print(f'{case}: rc={rc} {detail}')
        errors += rc
    if args.matrix:
        covered = {case for branches in MUTANTS.values() for case in branches}
        if covered != set(CASES):
            print('PROBE_ERROR: mutation coverage differs from scenarios')
            return 2
        for mutant, branches in MUTANTS.items():
            for case in branches:
                rc, detail = execute(case, 'model', mutant)
                print(f'mutation {mutant}: {case}: rc={rc} {detail}')
                errors += rc != 1
    print(f'996: examined={len(cases)} mutants={len(MUTANTS) if args.matrix else 0} mismatches={errors}')
    if errors:
        print('996: проектный цикл не замкнут')
    return int(errors != 0)


if __name__ == '__main__':
    sys.exit(main())
