#!/usr/bin/env python3
"""Behavioral red probes: public CLI -> real files, commits, tags and gate exec.
Expected paths/statuses are held before the subject executes. Toy repos have their
own .git and no link to a workstation checkout. Models never read the oracle.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor
import json
import os
import re
from pathlib import Path
import subprocess
import shutil
import sys
import tempfile
from threading import Lock

HERE = Path(__file__).resolve().parent
TOOLS = HERE.parents[2]
PARITY_CHECKED = False
PARITY_LOCK = Lock()


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
    global PARITY_CHECKED
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
    # The check.sh/workflow/package template is identical in every world.
    # Validate that prerequisite once, before the first subject, not per mutant.
    with PARITY_LOCK:
        if not PARITY_CHECKED:
            parity = run(['bash', TOOLS / 'scripts/verify_ci_parity.sh', root])
            if parity.returncode:
                raise RuntimeError('toy prerequisite CI parity: ' + parity.stdout + parity.stderr)
            PARITY_CHECKED = True
    return root, origin, p, contract


def subject(mode, op, root, *args, mutant='', tools=None, extra_env=None):
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    if tools is None and mutant in ('tools-leak', 'station-writes-tools') and op in ('freeze', 'done'):
        tools = installation(root.parent)
    tools = Path(tools or TOOLS)
    env.update(HARNESS_TOOLS_ROOT=str(tools), HARNESS_WORKFLOW_ROOT=str(root),
               HARNESS_PROJECT_LAYER_ROOT=str(root), MUTANT_996=mutant,
               GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               PYTHONDONTWRITEBYTECODE='1')
    env.update(extra_env or {})
    if mode == 'model':
        cmd = [sys.executable, tools / 'fixtures/workshop_project/rezhim_996/model.py', op, root, *args]
    else:
        commands = {
            'paths': ['bash', tools / 'scripts/project_workflow.sh', '--repo', root],
            'gitw': ['bash', tools / 'scripts/gitw', '-C', root, *args],
            'freeze': ['bash', tools / 'scripts/freeze_contract.sh', *args, '996 probe', root],
            'done': ['bash', tools / 'scripts/done_contract.sh', *args, '996 probe', root],
            'pre_critic': ['bash', tools / 'scripts/pre_critic.sh', '--repo', root, *args],
            'sources': ['bash', tools / 'scripts/check_project_sources.sh', '--repo', root,
                        '--contract', *args, '--stage', 'pre_critic'],
            'reserve': ['bash', tools / 'scripts/reserve_project_contract.sh', '--repo', root],
            'workshop': ['bash', tools / 'workshop', '--print-context', root],
            'make_task': ['bash', tools / 'scripts/make_task.sh', '--repo', root,
                          '--role', *args, '--print-context'],
            'make_task_pack': ['bash', tools / 'scripts/make_task.sh', '--repo', root,
                               '--role', 'reviewer', '--kind', 'task', '--contract', '777',
                               '--task-file', *args[:1], '--model-trace', *args[1:2]],
            'zones': ['bash', tools / 'scripts/check_zones.sh', root],
            'staged': ['bash', tools / 'scripts/check_staged.sh', root],
            'mint': ['bash', tools / 'scripts/mint_line.sh', '--root', root, '--nnn', *args],
            'lib_zones': ['bash', HERE / 'zones_adapter.sh', tools, root],
            'gitw-cwd': ['bash', tools / 'scripts/gitw', 'push', 'origin', *args],
            'gitw-envdir': ['bash', tools / 'scripts/gitw', 'push', 'origin', *args],
            'resolver': ['bash', tools / 'scripts/profile_resolver.sh', '--repo', root],
            'workshop_probe': ['bash', tools / 'workshop', '--probe', root],
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


def installation(base):
    """A real runnable installation, never the checkout under development."""
    install = base / 'install'
    install.mkdir()
    for name in git(TOOLS, 'ls-files').splitlines():
        # Ship all runtime code/config/roles, not historical judge evidence or
        # unrelated test worlds. No executable is stubbed. The detector still
        # sees the entire installed tree AND newly created (untracked) paths.
        if name.startswith(('contracts/', 'verdicts/', 'docs/')):
            continue
        if name.startswith('fixtures/') and not name.startswith('fixtures/workshop_project/rezhim_996/'):
            continue
        src = TOOLS / name
        if src.is_file():
            dst = install / name
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
    git(install, 'init', '-q', '-b', 'main')
    git(install, 'config', 'user.name', 'Fixture')
    git(install, 'config', 'user.email', 'fixture@local')
    commit(install, 'disposable installation')
    return install


def path_oracle(root, p):
    expected = {k: str(root / v) for k, v in p['workflowPaths'].items() if k != 'state'}
    state = root / p['workflowPaths'].get('state', '.harness')
    expected.update(handoff=str(state / 'HANDOFF.md'), observations=str(state / 'NABLIUDENIA.md'),
                    architectObservations=str(state / 'NABLIUDENIA_ARCHITECT.md'),
                    roadmap=str(state / 'ROADMAP.md'), forks=str(state / 'forks'))
    return expected


# Each door/gate has its own input; no aggregated case can hide a missed gate.
# Tuples are (door, defect, public refusal marker).
GATE_CASES = {
    'freeze-gate-preserved': ('freeze', 'spec', 'spec-preflight 036'),
    'freeze-consumers-preserved': ('freeze', 'consumers', 'потребители 116'),
    'freeze-precision-preserved': ('freeze', 'precision', 'precision-гейт 043'),
    'freeze-doc-preserved': ('freeze', 'doc', 'doc-preflight'),
    'freeze-doc-malformed': ('freeze', 'doc-malformed', 'doc-preflight'),
    'done-gate-preserved': ('done', 'provodka', 'ПРОВОДКА'),
    'done-consumers-preserved': ('done', 'consumers', 'потребители 116'),
    'precritic-spec-preserved': ('pre_critic', 'spec-probe', 'spec-ready'),
    'precritic-precision-preserved': ('pre_critic', 'precision', 'precision-gate'),
    'precritic-n39-preserved': ('pre_critic', 'n39', 'Н-39'),
    'precritic-context-preserved': ('pre_critic', 'context', 'форма:'),
    'precritic-existing-preserved': ('pre_critic', 'existing', 'форма:'),
    'freeze-plan-preserved': ('freeze', 'plan', 'контракт вне плана'),
    'freeze-committed-preserved': ('freeze', 'committed', 'закоммичен'),
    'done-committed-preserved': ('done', 'committed', 'закоммичен'),
    'freeze-closures-preserved': ('freeze', 'closures', 'контракт вне плана'),
    'freeze-head-plan-preserved': ('freeze', 'worktree-plan', 'контракт вне плана'),
}


def gate_test(case, mode, mutant, root, p, contract):
    op, defect, reason = GATE_CASES[case]
    original = (root / contract).read_text()
    changes = {}

    def change(path, text):
        file = root / path
        changes[path] = file.read_bytes() if file.exists() else None
        put(root, path, text)

    body = original
    if defect == 'spec':
        body = body.replace('app/', 'app/ fixtures/check_nosuchbarrier/')
        git(root, 'tag', '-a', 'id/CONTRACT/777', '-m', 'fixture mint')
    elif defect == 'spec-probe':
        body += '\n## Приёмочный критерий\n- `bash check.sh`\n'
        change('check.sh', '#!/bin/sh\nexit 7\n')
    elif defect == 'consumers':
        # Real registered mapping, not an injected failing gate executable.
        change('scripts/consumers.d/absent.sh__check_sh.tsv', 'scripts/absent.sh\tcheck.sh\n')
    elif defect == 'precision':
        package = json.loads((root / 'package.json').read_text())
        package['scripts']['check:unwired'] = 'bash omitted.sh'
        change('package.json', json.dumps(package))
        change('omitted.sh', '#!/bin/sh\nexit 0\n')
    elif defect.startswith('doc'):
        spec = {'type': 'documentation', 'version': 1, 'profile': 'product',
                'outputs': {'markdown': 'guide.md', 'evidence': 'guide.json'},
                'required': {'sections': [], 'scenarios': ['first']},
                'assertions': [], 'sources': [], 'questions': []}
        body += '\n## Док-приёмка\n```json\n' + (
            '{' if defect == 'doc-malformed' else json.dumps(spec)) + '\n```\n'
    elif defect == 'provodka':
        body = body.replace('guard=check.sh', 'guard=missing-guard.sh')
    elif defect == 'n39':
        body += '\nстаб s1 краснеет на входе case-one\n'
    elif defect in ('context', 'existing'):
        change(p['workflowPaths']['registry'] + '/contracts.tsv', '# registered project\n')
        body = body.replace('КОНТЕКСТ: AGENTS.md\n' if defect == 'context'
                            else '## Существующее\n', '')
    elif defect == 'plan':
        header = 'id\tпара\tэтап\tзависит\tисточник\tтрек\n'
        row = '\t1\tдо V-2\t-\tabcdef0\ttoy\n'
        change(p['workflowPaths']['registry'] + '/plan.tsv', header + '778' + row)
        # A valid root decoy must not override the project's rejecting plan.
        change('registry/plan.tsv', header + '777' + row)
        changes[p['workflowPaths']['registry'] + '/plan.tsv'] = (header + '777' + row).encode()
    elif defect == 'closures':
        # Plan 775/1 776/2 777/3; the closure of 775 lives ONLY in the root
        # registry decoy, so the profile plan keeps 777 outside P0/P1.
        header = 'id\tпара\tэтап\tзависит\tисточник\tтрек\n'
        row = '\t1\tдо V-2\t-\tabcdef0\ttoy\n'
        put(root, p['workflowPaths']['registry'] + '/plan.tsv',
            header + '775' + row + '776' + row.replace('\t1\t', '\t2\t')
            + '777' + row.replace('\t1\t', '\t3\t'))
        change('registry/closed-without-done.tsv', '775\tзакрыт владельцем без done\n')
    elif defect == 'worktree-plan':
        # Committed plan excludes 777; the uncommitted edit below adds it.
        header = 'id\tпара\tэтап\tзависит\tисточник\tтрек\n'
        row = '\t1\tдо V-2\t-\tabcdef0\ttoy\n'
        change(p['workflowPaths']['registry'] + '/plan.tsv', header + '778' + row)
    elif defect == 'committed':
        body += '\n## State\nCommitted baseline\n'
    change(contract, body)
    if defect.startswith('doc'):
        spec['required']['sections'] = ['overview']
        changes[contract] = (original + '\n## Док-приёмка\n```json\n' +
                             json.dumps(spec) + '\n```\n').encode()
    elif defect == 'spec-probe':
        changes[contract] = body.encode()
    elif defect in ('context', 'existing'):
        changes[p['workflowPaths']['registry'] + '/contracts.tsv'] = b'# registered project\n'
    commit(root, 'one defective gate input')
    if defect == 'committed':
        changes[contract] = body.encode()
        put(root, contract, body + '\nUncommitted contract change\n')
    if defect == 'worktree-plan':
        # Uncommitted plan edit: only the HEAD blob may be read by the door.
        header = 'id\tпара\tэтап\tзависит\tисточник\tтрек\n'
        row = '\t1\tдо V-2\t-\tabcdef0\ttoy\n'
        put(root, p['workflowPaths']['registry'] + '/plan.tsv',
            header + '778' + row + '777' + row.replace('\t1\t', '\t2\t'))
    before = (git(root, 'rev-parse', 'HEAD'),
              git(root, 'show-ref'), {str(f.relative_to(root)): f.read_bytes()
                                    for f in root.rglob('*') if f.is_file() and '.git' not in f.parts})
    # A refusal from an earlier unrelated gate must not count as this gate.
    r = subject(mode, op, root, contract, mutant=mutant)
    expect(r.returncode == 1 and reason in r.stderr, 'PROJECT_GATE_BYPASSED:' + defect, r)
    after = (git(root, 'rev-parse', 'HEAD'),
             git(root, 'show-ref'), {str(f.relative_to(root)): f.read_bytes()
                                   for f in root.rglob('*') if f.is_file() and '.git' not in f.parts})
    expect(after == before, 'PROJECT_GATE_REFUSAL_MUTATED:' + defect, r)
    # Repair the same input and exercise the same door (reject-all is not green).
    for path, contents in changes.items():
        if contents is None:
            (root / path).unlink()
        else:
            (root / path).write_bytes(contents)
    if defect == 'consumers':
        for writer in ('freeze_contract.sh', 'lib_registry.sh', 'done_contract.sh'):
            put(root, 'scripts/' + writer, (TOOLS / 'scripts' / writer).read_text())
            put(root, 'scripts/consumers.d/' + writer + '__check_sh.tsv',
                'scripts/' + writer + '\tcheck.sh\n')
    if defect == 'closures':
        # Repair of the same input: the closure of 775 moves into the PROFILE
        # registry, which must open P1 for 777 (arbiter П1б).
        put(root, p['workflowPaths']['registry'] + '/closed-without-done.tsv',
            '775\tзакрыт владельцем без done\n')
    if defect == 'worktree-plan':
        # Repair of the same input: committing the plan edit moves 777 into
        # the HEAD blob the door reads.
        header = 'id\tпара\tэтап\tзависит\tисточник\tтрек\n'
        row = '\t1\tдо V-2\t-\tabcdef0\ttoy\n'
        put(root, p['workflowPaths']['registry'] + '/plan.tsv',
            header + '778' + row + '777' + row.replace('\t1\t', '\t2\t'))
    if defect != 'committed':
        commit(root, 'repair gate input')
    r = subject(mode, op, root, contract, mutant=mutant)
    expect(r.returncode == 0, 'PROJECT_GATE_REPAIR_REFUSED:' + defect, r)
    if op != 'pre_critic':
        prefix = 'frozen' if op == 'freeze' else 'done'
        expect(git(root, 'tag', '-l', prefix + '/contracts/777/*') ==
               prefix + '/contracts/777/1', 'PROJECT_GATE_REPAIR_TAG_MISSING', r)


EXTRA_CASES = (
    'context-workshop', 'context-architect', 'context-implementer', 'context-critic',
    'context-adversary', 'context-reviewer', 'context-arbiter',
    'freeze-root-only', 'done-root-only', 'freeze-cap', 'freeze-root-arbitration',
    'freeze-project-arbitration', 'git-origin-drift', 'git-broken-profile',
    'paths-symlink', 'canon-precritic-green', 'canon-done-green', 'canon-stale-head',
    'canon-null', 'canon-empty', 'canon-bool', 'canon-duplicate', 'canon-missing',
    'canon-unavailable', 'canon-nul', 'reserve-race', 'reserve-unavailable',
    'zones-project', 'zones-green', 'staged-project', 'staged-green', 'lib-zones-project',
    'mint-project', 'mint-no-authority', 'self-canonical',
    'freeze-escalate', 'freeze-ungrammatical', 'done-escalate', 'done-ungrammatical',
    # Круг 1 (FAIL ×2): красные клетки по находкам Б-1…Б-8 и adversary-1.
    'resolver-canon-extra-key', 'resolver-canon-fraction', 'gate-path-argv0',
    'defaults-null-canon', 'source-symlink-escape', 'source-traversal-escape',
    'freeze-paths-escape', 'freeze-broken-profile', 'done-broken-profile',
    'freeze-root-contract', 'done-root-contract', 'gitw-cwd-canon',
    'probe-prompt-project',
    # Круг 2 (FAIL ×2): красные клетки по adversary-1/adversary-2 и Р2-1…Р2-3.
    'source-directory-not-file', 'resolver-source-relative', 'print-context-canon-escape',
    'print-context-escape', 'workshop-print-context-escape',
    'make-task-pack-project', 'make-task-pack-refusal',
    'structure-one-paths-resolve', 'structure-no-second-canon-validator',
)


def extra_test(case, mode, base, mutant, root, origin, p, contract):
    call = lambda op, *args, **kw: subject(mode, op, root, *args, mutant=mutant, **kw)
    if case == 'git-override':
        p['git']['canonicalRemote'] = 'ssh://git@example.invalid/not-this-project.git'
        put(root, 'harness.project.json', json.dumps(p))
        before = git(root, 'rev-parse', 'HEAD')
        r = call('gitw', 'push', 'origin', 'HEAD:refs/heads/probe',
                 extra_env={'GIT_EXCHANGE_GUARD_CANONICAL': str(origin)})
        expect(r.returncode == 0 and
               git(origin, 'rev-parse', 'refs/heads/probe') == before,
               'EXPLICIT_CANONICAL_OVERRIDE_IGNORED', r)
        return
    if case.startswith('context-'):
        p['workflowPaths']['state'] = '.harness/session'
        canon(root, p)
        expected = {'workflow': path_oracle(root, p), 'sourceCanon': p['sourceCanon']}
        role = case.removeprefix('context-')
        suffix = {'critic': 'critic', 'adversary': 'adversary',
                  'reviewer': 'review', 'arbiter': 'arbitration'}.get(role)
        expected['verdict'] = str(root / p['workflowPaths']['verdicts'] / suffix) if suffix else None
        expected['startup'] = [expected['workflow'][key] for key in
                               ('handoff', 'contracts', 'verdicts', 'observations', 'roadmap')]
        if role == 'workshop':
            # An older launcher may forward the unknown flag to omp. Never let
            # a red probe start a paid/live session or initialize the real install.
            tools = installation(base) if mode == 'product' else TOOLS
            trap = put(base, 'bin/omp', '#!/bin/sh\necho UNEXPECTED_OMP_LAUNCH >&2\nexit 97\n')
            trap.chmod(0o755)
            r = call('workshop', tools=tools,
                     extra_env={'PATH': str(trap.parent) + os.pathsep + os.environ['PATH']})
        else:
            r = call('make_task', role)
        expect(r.returncode == 0, 'ROLE_CONTEXT_UNAVAILABLE', r)
        got = json.loads(r.stdout)
        expect(all(got.get(k) == v for k, v in expected.items()), 'ROLE_CONTEXT_NOT_PROJECT_LOCAL', r)
        expect(str(TOOLS) not in r.stdout, 'ROLE_CONTEXT_LEAKS_INSTALLATION', r)
    elif case in ('freeze-root-only', 'done-root-only'):
        op = case.split('-')[0]
        role = 'critic' if op == 'freeze' else 'review'
        # Remove the profile verdict from ALL history, not just HEAD (review reads history).
        path = p['workflowPaths']['verdicts'] + f'/{role}/contracts-777-v1.md'
        (root / path).unlink()
        put(root, f'verdicts/{role}/contracts-777-v1.md', 'accept\n')
        git(root, 'add', '.')
        git(root, 'commit', '--amend', '-qm', 'root-only verdict')
        before = git(root, 'rev-parse', 'HEAD')
        r = call(op, contract)
        reason = 'критик' if op == 'freeze' else 'вердикт'
        expect(r.returncode == 1 and reason in r.stderr, 'ROOT_FALLBACK_ACCEPTED', r)
        expect(not git(root, 'tag', '-l') and git(root, 'rev-parse', 'HEAD') == before,
               'ROOT_FALLBACK_MUTATED')
    elif case in ('freeze-cap', 'freeze-root-arbitration', 'freeze-project-arbitration'):
        verdict = p['workflowPaths']['verdicts'] + '/critic/contracts-777-v1.md'
        for status in ('FAIL', 'accept'):
            put(root, verdict, status + '\n')
            commit(root, 'critic ' + status)
        if case != 'freeze-cap':
            directory = 'verdicts' if case == 'freeze-root-arbitration' else p['workflowPaths']['verdicts']
            put(root, directory + '/arbitration/toy.md', 'РЕШЕНИЕ (контракт 777)\nСохранить критерий.\n')
            commit(root, 'arbitration')
        before = git(root, 'rev-parse', 'HEAD')
        r = call('freeze', contract)
        if case == 'freeze-project-arbitration':
            expect(r.returncode == 0 and git(root, 'tag', '-l') == 'frozen/contracts/777/1',
                   'PROJECT_ARBITRATION_NOT_READ', r)
        else:
            expect(r.returncode == 1 and 'кап кругов' in r.stderr and not git(root, 'tag', '-l')
                   and git(root, 'rev-parse', 'HEAD') == before, 'PROJECT_CAP_BYPASSED', r)
    elif case in ('freeze-escalate', 'freeze-ungrammatical', 'done-escalate', 'done-ungrammatical'):
        # First-line grammar of profile verdicts (arbiter П3, K10). The refusal
        # marker is the door's own reason; a refusal from another gate would not
        # count. Amending keeps critic history single-event, so the cap logic
        # of the repair run stays out of this scenario's way.
        op = 'freeze' if case.startswith('freeze') else 'done'
        role = 'critic' if op == 'freeze' else 'review'
        path = p['workflowPaths']['verdicts'] + f'/{role}/contracts-777-v1.md'
        first = 'ESCALATE' if case.endswith('escalate') else 'утверждено вне грамматики'
        put(root, path, first + '\n')
        git(root, 'add', '.')
        git(root, 'commit', '--amend', '-qm', 'grammar refusal input')
        before = (git(root, 'rev-parse', 'HEAD'), git(root, 'show-ref'),
                  {str(f.relative_to(root)): f.read_bytes()
                   for f in root.rglob('*') if f.is_file() and '.git' not in f.parts})
        r = call(op, contract)
        marker = 'ESCALATE' if case.endswith('escalate') else 'грамматик'
        expect(r.returncode == 1 and marker in r.stderr, 'VERDICT_GRAMMAR_BYPASSED:' + case, r)
        after = (git(root, 'rev-parse', 'HEAD'), git(root, 'show-ref'),
                 {str(f.relative_to(root)): f.read_bytes()
                  for f in root.rglob('*') if f.is_file() and '.git' not in f.parts})
        expect(after == before, 'VERDICT_GRAMMAR_REFUSAL_MUTATED:' + case, r)
        put(root, path, 'accept\n')
        git(root, 'add', '.')
        git(root, 'commit', '--amend', '-qm', 'repair grammar input')
        r = call(op, contract)
        expect(r.returncode == 0, 'VERDICT_GRAMMAR_REPAIR_REFUSED:' + case, r)
        prefix = 'frozen' if op == 'freeze' else 'done'
        expect(git(root, 'tag', '-l', prefix + '/contracts/777/*') ==
               prefix + '/contracts/777/1', 'VERDICT_GRAMMAR_REPAIR_TAG_MISSING', r)
    elif case in ('git-origin-drift', 'git-broken-profile'):
        receiver = origin
        if case == 'git-origin-drift':
            receiver = base / 'foreign.git'
            git(root, 'init', '--bare', '-q', str(receiver))
            git(root, 'remote', 'set-url', 'origin', str(receiver))
        else:
            put(root, 'harness.project.json', '{broken')
        r = call('gitw', 'push', 'origin', 'HEAD:refs/heads/probe')
        expect(r.returncode == 1 and not git(receiver, 'for-each-ref', '--format=%(refname)'),
               'UNTRUSTED_ORIGIN_ACCEPTED', r)
    elif case == 'paths-symlink':
        outside = base / 'outside'
        outside.mkdir()
        (root / 'escape').symlink_to(outside, target_is_directory=True)
        p['workflowPaths']['state'] = 'escape'
        put(root, 'harness.project.json', json.dumps(p))
        r = call('paths')
        expect(r.returncode == 1 and 'workflowPaths' in r.stderr, 'SYMLINK_ESCAPE_ACCEPTED', r)
    elif case.startswith('canon-'):
        canon(root, p)
        op = 'done' if case in ('canon-done-green', 'canon-stale-head') else 'pre_critic'
        reason = None
        if case == 'canon-stale-head':
            r = call('pre_critic', contract)
            expect(r.returncode == 0, 'OLD_HEAD_GREEN_UNAVAILABLE', r)
            first = json.loads((root / 'gate-observed.json').read_text())
            canon(root, p, 7)
            expect(first['head'] != git(root, 'rev-parse', 'HEAD'), 'STALE_HEAD_NOT_CHANGED')
            reason = 'SOURCE_GATE_FAILED'
        invalid = {'canon-null': None, 'canon-empty': {}}
        if case in invalid:
            p['sourceCanon'] = invalid[case]
            reason = 'SOURCE_CANON_INVALID'
        if case == 'canon-bool':
            p['sourceCanon']['sources'][0]['priority'] = True
            reason = 'SOURCE_CANON_INVALID'
        if case == 'canon-duplicate':
            p['sourceCanon']['sources'] *= 2
            reason = 'SOURCE_CANON_INVALID'
        if case == 'canon-nul':
            p['sourceCanon']['gate'][2] = '\0'
            reason = 'SOURCE_CANON_INVALID'
        if case == 'canon-missing':
            (root / 'SOURCE.md').unlink()
            reason = 'SOURCE_CANON_MISSING'
        if case == 'canon-unavailable':
            p['sourceCanon']['gate'] = ['./missing-command']
            reason = 'SOURCE_GATE_UNAVAILABLE'
        put(root, 'harness.project.json', json.dumps(p))
        if git(root, 'status', '--porcelain'):
            commit(root, 'canon scenario')
        before = git(root, 'rev-parse', 'HEAD')
        expected = {'cwd': str(root), 'head': before, 'contract': contract,
                    'stage': 'done' if op == 'done' else 'pre_critic', 'arg': 'literal ; $(not-shell)'}
        r = call(op, contract)
        if reason:
            expect(r.returncode == 1 and reason in r.stderr, 'CANON_DOOR_REFUSAL_MISSING', r)
            expect(not git(root, 'tag', '-l') and git(root, 'rev-parse', 'HEAD') == before,
                   'CANON_DOOR_REFUSAL_MUTATED')
            if case == 'canon-stale-head':
                expect(json.loads((root / 'gate-observed.json').read_text()) == expected,
                       'CANON_STALE_HEAD_CACHED')
        else:
            expect(r.returncode == 0, 'CANON_DOOR_GREEN_REFUSED', r)
            expect(json.loads((root / 'gate-observed.json').read_text()) == expected,
                   'CANON_DOOR_EXEC_CONTEXT_WRONG')
            if op == 'done':
                expect(git(root, 'tag', '-l') == 'done/contracts/777/1', 'CANON_DONE_TAG_MISSING')
    elif case in ('zones-project', 'zones-green', 'staged-project', 'staged-green', 'lib-zones-project'):
        git(root, 'tag', '-a', 'frozen/contracts/777/1', '-m', 'freeze')
        if case == 'lib-zones-project':
            expected = 'implementer\tapp/\t777\n'
            r = call('lib_zones')
            expect(r.returncode == 0 and r.stdout == expected, 'FROZEN_PROFILE_ZONES_MISSING', r)
            return
        path = 'app/ok.txt' if case.endswith('green') else 'outside/zone.txt'
        put(root, path, 'implementation\n')
        git(root, 'add', '.')
        if case.startswith('zones'):
            git(root, '-c', 'user.name=implementer', '-c', 'user.email=i@x',
                'commit', '-qm', 'implementation')
        git(root, 'config', '--unset', 'user.name')
        git(root, 'config', '--unset', 'user.email')
        r = call('zones' if case.startswith('zones') else 'staged',
                 extra_env={'GIT_AUTHOR_NAME': 'implementer', 'GIT_AUTHOR_EMAIL': 'i@x'})
        if case.endswith('green'):
            expect(r.returncode == 0, 'IN_ZONE_CHANGE_REFUSED', r)
        else:
            expect(r.returncode == 1 and 'вне зоны' in r.stdout + r.stderr and path in r.stdout + r.stderr,
                   'PROJECT_ZONE_FAIL_OPEN', r)
    elif case in ('mint-project', 'mint-no-authority'):
        put(root, contract, (root / contract).read_text() + 'ЗОНА orchestrator: app/\n')
        commit(root, 'mint author is zoned')
        git(root, 'tag', '-a', 'frozen/contracts/777/1', '-m', 'freeze mint author')
        git(root, 'tag', '-a', 'id/CONTRACT/777', '-m', 'issued')
        git(root, 'push', '-q', 'origin', 'main')
        if case == 'mint-project':
            git(root, 'push', '-q', 'origin', 'refs/tags/id/CONTRACT/777')
        expected = '777 → ' + git(root, 'rev-parse', 'id/CONTRACT/777') + '\n'
        hook_command = ('exec python3 "$HARNESS_TOOLS_ROOT/fixtures/workshop_project/rezhim_996/model.py" staged "$HARNESS_WORKFLOW_ROOT"\n'
                        if mode == 'model' else
                        'exec bash "$HARNESS_TOOLS_ROOT/scripts/check_staged.sh" "$HARNESS_WORKFLOW_ROOT"\n')
        hook = put(root, '.git/hooks/pre-commit', '#!/bin/bash\n' + hook_command)
        hook.chmod(0o755)
        git(root, 'config', '--unset', 'user.name')
        git(root, 'config', '--unset', 'user.email')
        before = git(root, 'rev-parse', 'HEAD')
        r = call('mint', '777')
        reg = root / p['workflowPaths']['registry'] / 'contracts.tsv'
        if case == 'mint-no-authority':
            expect(r.returncode == 1 and 'не выдан авторитетом' in r.stderr
                   and not reg.exists() and git(root, 'rev-parse', 'HEAD') == before,
                   'MINT_SELF_AUTHORIZED', r)
        else:
            expect(r.returncode == 0, 'PROJECT_MINT_REFUSED', r)
            expect(reg.is_file() and reg.read_text() == expected and not (root / 'registry').exists(),
                   'MINT_NOT_PROJECT_LOCAL')
            expect(git(root, 'show', 'HEAD:' + str(reg.relative_to(root))) == expected.strip()
                   and git(root, 'log', '-1', '--format=%an') == 'orchestrator', 'MINT_NOT_COMMITTED')
    elif case in ('reserve-race', 'reserve-unavailable'):
        git(root, 'tag', '-a', 'id/CONTRACT/777', '-m', 'previous')
        git(root, 'push', '-q', 'origin', 'main', 'refs/tags/id/CONTRACT/777')
        extra = {}
        if case == 'reserve-race':
            # Prepare the competing tag OBJECT before the subject; publish it only
            # after next_id has chosen 778, immediately before git push advertises refs.
            git(origin, '-c', 'user.name=OtherStation', '-c', 'user.email=other@x',
                'tag', '-a', 'id/CONTRACT/778', 'main', '-m', 'other station reservation')
            expected = git(origin, 'rev-parse', 'refs/tags/id/CONTRACT/778')
            git(origin, 'update-ref', '-d', 'refs/tags/id/CONTRACT/778')
            real_git = shutil.which('git')
            wrapper = put(base, 'bin/git', f'#!{sys.executable}\n'
                'import os,subprocess,sys\n'
                f'real={real_git!r}\norigin={str(origin)!r}\nsha={expected!r}\n'
                'args=sys.argv[1:]\n'
                'if "push" in args and any("refs/tags/id/CONTRACT/778" in a for a in args):\n'
                ' subprocess.run([real,"-C",origin,"update-ref","refs/tags/id/CONTRACT/778",sha],check=True)\n'
                'os.execv(real,[real,*args])\n')
            wrapper.chmod(0o755)
            extra['PATH'] = str(wrapper.parent) + os.pathsep + os.environ['PATH']
        else:
            hook = put(origin, 'hooks/pre-receive', '#!/bin/sh\nexit 1\n')
            hook.chmod(0o755)
        r = call('reserve', extra_env=extra)
        expect(r.returncode == 1 and not r.stdout.strip(), 'RESERVATION_FAILURE_ANNOUNCED_NUMBER', r)
        remote = git(origin, 'for-each-ref', '--format=%(objectname)', 'refs/tags/id/CONTRACT/778')
        expect(remote == expected if case == 'reserve-race' else not remote, 'RESERVATION_REPLACED_COMPETITOR')
    elif case in ('resolver-canon-extra-key', 'resolver-canon-fraction'):
        # Б-2: grammar of the unit lives in the resolver itself, not in a
        # second validator of one consumer.
        canon(root, p)
        if case == 'resolver-canon-extra-key':
            p['sourceCanon']['evil'] = 1
        else:
            p['sourceCanon']['sources'][0]['priority'] = 0.5
        put(root, 'harness.project.json', json.dumps(p))
        commit(root, 'invalid canon unit')
        r = call('resolver')
        expect(r.returncode == 1 and 'SOURCE_CANON' in r.stderr,
               'RESOLVER_CANON_GRAMMAR_ABSENT:' + case, r)
        # Repair the same input: the honest resolver accepts a valid unit.
        if case == 'resolver-canon-extra-key':
            del p['sourceCanon']['evil']
        else:
            p['sourceCanon']['sources'][0]['priority'] = 0
        put(root, 'harness.project.json', json.dumps(p))
        commit(root, 'repair canon unit')
        r = call('resolver')
        expect(r.returncode == 0, 'RESOLVER_CANON_REPAIR_REFUSED:' + case, r)
    elif case == 'gate-path-argv0':
        # Б-1: gate argv[0] of the frozen contract form (["python3", ...]) is
        # resolved via PATH, not joined onto R.
        canon(root, p)
        p['sourceCanon']['gate'][0] = 'python3'
        put(root, 'harness.project.json', json.dumps(p))
        commit(root, 'gate argv0 via PATH')
        before = git(root, 'rev-parse', 'HEAD')
        r = call('pre_critic', contract)
        expected = {'cwd': str(root), 'head': before, 'contract': contract,
                    'stage': 'pre_critic', 'arg': 'literal ; $(not-shell)'}
        expect(r.returncode == 0, 'CANON_GATE_PATH_UNAVAILABLE', r)
        expect(json.loads((root / 'gate-observed.json').read_text()) == expected,
               'CANON_GATE_PATH_EXEC_CONTEXT_WRONG')
    elif case == 'defaults-null-canon':
        # Б-3: sourceCanon null in the defaults layer is NOT absence.
        canon(root, p)
        p.pop('sourceCanon')
        put(root, 'harness.project.json', json.dumps(p))
        layer = json.loads((root / 'project-layer.json').read_text())
        layer['defaults']['sourceCanon'] = None
        put(root, 'project-layer.json', json.dumps(layer))
        commit(root, 'defaults-layer null canon')
        before = git(root, 'rev-parse', 'HEAD')
        r = call('pre_critic', contract)
        expect(r.returncode == 1 and 'SOURCE_CANON' in r.stderr,
               'DEFAULTS_NULL_CANON_TREATED_ABSENT', r)
        expect(not git(root, 'tag', '-l') and git(root, 'rev-parse', 'HEAD') == before,
               'DEFAULTS_NULL_CANON_MUTATED')
    elif case in ('source-symlink-escape', 'source-traversal-escape'):
        # Б-4/adversary-1: a source resolving outside R (symlink or ..) is
        # refused even when the target file exists.
        outside = base / 'outside'
        outside.mkdir()
        (outside / 'outside.md').write_text('# External requirement\n')
        canon(root, p)
        if case == 'source-symlink-escape':
            (root / 'LINK.md').symlink_to(outside / 'outside.md')
            p['sourceCanon']['sources'][0]['path'] = 'LINK.md'
        else:
            p['sourceCanon']['sources'][0]['path'] = '../outside/outside.md'
        put(root, 'harness.project.json', json.dumps(p))
        commit(root, 'source outside repo')
        before = git(root, 'rev-parse', 'HEAD')
        r = call('pre_critic', contract)
        expect(r.returncode == 1 and 'SOURCE_CANON' in r.stderr,
               'CANON_SOURCE_ESCAPE_ACCEPTED:' + case, r)
        expect(not git(root, 'tag', '-l') and git(root, 'rev-parse', 'HEAD') == before,
               'CANON_SOURCE_ESCAPE_MUTATED:' + case)
    elif case == 'freeze-paths-escape':
        # Б-5: the freeze door refuses an escaped workflowPaths.registry
        # BEFORE any tag or write; nothing may land outside the project.
        outside = base / 'outside'
        outside.mkdir()
        header = 'id\tпара\tэтап\tзависит\tисточник\tтрек\n'
        row = '\t1\tдо V-2\t-\tabcdef0\ttoy\n'
        (outside / 'plan.tsv').write_text(header + '777' + row)
        (root / 'escape').symlink_to(outside, target_is_directory=True)
        p['workflowPaths']['registry'] = 'escape'
        put(root, 'harness.project.json', json.dumps(p))
        commit(root, 'registry escapes repo')
        before = git(root, 'rev-parse', 'HEAD')
        r = call('freeze', contract)
        expect(r.returncode == 1 and ('workflowPaths' in r.stderr or 'вне репо' in r.stderr),
               'DOOR_ESCAPE_REFUSAL_MISSING:freeze', r)
        expect(not git(root, 'tag', '-l') and git(root, 'rev-parse', 'HEAD') == before,
               'DOOR_ESCAPE_MUTATED:freeze', r)
        expect(not (outside / 'contracts.tsv').exists(), 'DOOR_ESCAPE_WROTE_OUTSIDE:freeze', r)
    elif case in ('freeze-broken-profile', 'done-broken-profile'):
        # Б-5: a broken profile is a named refusal, never a root-layout fallback.
        op = 'freeze' if case.startswith('freeze') else 'done'
        role = 'critic' if op == 'freeze' else 'review'
        decoy = 'contracts/777-toy.md'
        put(root, decoy, (root / contract).read_text())
        put(root, 'verdicts/' + role + '/contracts-777-v1.md', 'accept\n')
        put(root, 'harness.project.json', '{broken')
        commit(root, 'broken profile with root decoy')
        before = git(root, 'rev-parse', 'HEAD')
        r = call(op, decoy)
        expect(r.returncode == 1 and 'ОТКАЗ' in r.stderr,
               'BROKEN_PROFILE_ROOT_FALLBACK:' + op, r)
        expect(not git(root, 'tag', '-l') and git(root, 'rev-parse', 'HEAD') == before
               and not (root / 'registry' / 'contracts.tsv').exists(),
               'BROKEN_PROFILE_FALLBACK_MUTATED:' + op, r)
    elif case in ('freeze-root-contract', 'done-root-contract'):
        # Б-6: with a declared profile, root contracts/ is not a lifecycle
        # source even for a product contract of the project.
        op = 'freeze' if case.startswith('freeze') else 'done'
        decoy = 'contracts/777-toy.md'
        put(root, decoy, (root / contract).read_text())
        commit(root, 'product contract at root')
        before = git(root, 'rev-parse', 'HEAD')
        r = call(op, decoy)
        expect(r.returncode == 1, 'ROOT_CONTRACT_ACCEPTED:' + op, r)
        expect(not git(root, 'tag', '-l') and git(root, 'rev-parse', 'HEAD') == before
               and not (root / 'registry' / 'contracts.tsv').exists(),
               'ROOT_CONTRACT_MUTATED:' + op, r)
    elif case == 'gitw-cwd-canon':
        # Б-8: the profile canonical is taken from the cwd project context
        # and from GIT_DIR in the environment, without -C/--git-dir.
        before = git(root, 'rev-parse', 'HEAD')
        r = call('gitw-cwd', 'HEAD:refs/heads/probe-cwd')
        expect(r.returncode == 0 and
               git(origin, 'rev-parse', 'refs/heads/probe-cwd') == before,
               'GITW_CWD_CANON_IGNORED', r)
        r = call('gitw-envdir', 'HEAD:refs/heads/probe-envdir',
                 extra_env={'GIT_DIR': str(root / '.git'), 'GIT_WORK_TREE': str(root)})
        expect(r.returncode == 0 and
               git(origin, 'rev-parse', 'refs/heads/probe-envdir') == before,
               'GITW_ENVDIR_CANON_IGNORED', r)
    elif case == 'probe-prompt-project':
        # Б-7: the standard launch delivers project paths and the effective
        # sourceCanon into the real session prompt (workshop --probe), not
        # only into a separate --print-context calculation.
        canon(root, p)
        put(root, '.env', 'METERING_PROXY_URL=http://127.0.0.1:9\n')
        put(root, 'config/harness_pin.json', '{"version": "0.0.0-probe"}\n')
        commit(root, 'project metering env and pin')
        pstate = base / 'pstate'
        r = call('workshop_probe', extra_env={'HARNESS_SCRATCH': str(pstate)})
        expect(r.returncode == 0 and 'PROBE OK' in r.stdout, 'WORKSHOP_PROBE_FAILED', r)
        line = next((l for l in r.stdout.splitlines() if l.startswith('PROMPT: ')), '')
        prompt = line[len('PROMPT: '):]
        expect(bool(prompt) and Path(prompt).is_file(), 'PROBE_PROMPT_MISSING', r)
        text = Path(prompt).read_text()
        expect('sourceCanon' in text and 'SOURCE.md' in text,
               'PROBE_PROMPT_CANON_MISSING', r)
        expect(str(root / p['workflowPaths']['verdicts']) in text
               and str(root / p['workflowPaths']['contracts']) in text,
               'PROBE_PROMPT_PROJECT_PATHS_MISSING', r)
    elif case == 'source-directory-not-file':
        # adversary-1 (круг 2): каталог внутри R — не regular file — не является
        # источником; предикат существования (-e) слабее файлового (-f).
        canon(root, p)
        (root / 'directory-is-not-file').mkdir()
        p['sourceCanon']['sources'][0]['path'] = 'directory-is-not-file'
        put(root, 'harness.project.json', json.dumps(p))
        commit(root, 'directory declared as canonical source')
        before = git(root, 'rev-parse', 'HEAD')
        for op in ('sources', 'pre_critic'):
            r = call(op, contract)
            expect(r.returncode == 1 and 'SOURCE_CANON_INVALID' in r.stderr,
                   'SOURCE_DIRECTORY_ACCEPTED:' + op, r)
        expect(not git(root, 'tag', '-l') and git(root, 'rev-parse', 'HEAD') == before,
               'SOURCE_DIRECTORY_MUTATED')
        # Позитивный контроль: честный regular file на той же двери — зелёный.
        p['sourceCanon']['sources'][0]['path'] = 'SOURCE.md'
        put(root, 'harness.project.json', json.dumps(p))
        commit(root, 'regular source file restored')
        r = call('pre_critic', contract)
        expect(r.returncode == 0, 'SOURCE_DIRECTORY_REPAIR_REFUSED', r)
    elif case == 'resolver-source-relative':
        # adversary-2 (круг 2): замкнутая грамматика юнита действует в самом
        # resolver — неотносительный путь источника не доходит до ролей.
        (base / 'outside.md').write_text('# External requirement\n')
        canon(root, p)
        p['sourceCanon']['sources'][0]['path'] = '../outside.md'
        put(root, 'harness.project.json', json.dumps(p))
        commit(root, 'non-relative source path')
        r = call('resolver')
        expect(r.returncode == 1 and 'SOURCE_CANON' in r.stderr,
               'RESOLVER_SOURCE_PATH_LENIENT', r)
        p['sourceCanon']['sources'][0]['path'] = 'SOURCE.md'
        put(root, 'harness.project.json', json.dumps(p))
        commit(root, 'repair relative source path')
        r = call('resolver')
        expect(r.returncode == 0, 'RESOLVER_SOURCE_REPAIR_REFUSED', r)
    elif case == 'print-context-canon-escape':
        # adversary-2 (круг 2): make_task --print-context не доставляет ролям
        # канон с побегом источника из R.
        (base / 'outside.md').write_text('# External requirement\n')
        canon(root, p)
        p['sourceCanon']['sources'][0]['path'] = '../outside.md'
        put(root, 'harness.project.json', json.dumps(p))
        commit(root, 'canon escape for print-context')
        r = call('make_task', 'reviewer')
        expect(r.returncode == 1 and 'SOURCE_CANON' in r.stderr,
               'PRINT_CONTEXT_CANON_ESCAPE_ACCEPTED', r)
    elif case in ('print-context-escape', 'workshop-print-context-escape'):
        # Р2-2: режим печати контекста не отключает валидацию workflowPaths —
        # project_workflow отказывает, print-context обязан отказывать тоже.
        outside = base / 'outside'
        outside.mkdir()
        (root / 'escape').symlink_to(outside, target_is_directory=True)
        p['workflowPaths']['registry'] = 'escape'
        put(root, 'harness.project.json', json.dumps(p))
        commit(root, 'registry escapes repo')
        before = git(root, 'rev-parse', 'HEAD')
        op = 'workshop' if case.startswith('workshop-') else 'make_task'
        r = call(op, 'reviewer')
        expect(r.returncode == 1 and 'вне репо' in r.stderr,
               'PRINT_CONTEXT_ESCAPE_ACCEPTED:' + case, r)
        expect(git(root, 'rev-parse', 'HEAD') == before,
               'PRINT_CONTEXT_ESCAPE_MUTATED:' + case, r)
    elif case == 'make-task-pack-project':
        # Р2-1: штатное задание make_task (--kind task, не --print-context)
        # несёт effective sourceCanon, источники, каталог вердикта судьи и
        # tasks/HANDOFF-пути (шесть проверок X2 рецензента).
        p['contextPack'] = {'rows': [{'kind': 'map', 'path': 'AGENTS.md',
                                      'roles': 'reviewer,critic,orchestrator,implementer',
                                      'mandatory': True, 'why': 'toy'}]}
        canon(root, p)
        trace = put(base, 'trace.tsv',
                     'reviewer\topenai/gpt-5\tallowed\n'
                     'implementer\tanthropic/claude\tallowed\n')
        taskf = put(base, 'task.md', 'задание\n')
        r = call('freeze', contract)
        expect(r.returncode == 0, 'MAKE_TASK_PACK_FREEZE_FAILED', r)
        r = call('make_task_pack', taskf, trace)
        expect(r.returncode == 0, 'MAKE_TASK_PACK_FAILED', r)
        oracle = path_oracle(root, p)
        needles = ('sourceCanon', 'SOURCE.md', oracle['verdicts'],
                   oracle['verdicts'] + '/review', oracle['contracts'],
                   oracle['handoff'])
        missing = [n for n in needles if n not in r.stdout]
        expect(not missing, 'MAKE_TASK_PACK_CONTEXT_MISSING:' + ','.join(missing), r)
    elif case == 'make-task-pack-refusal':
        # Р2-1: отказ внутреннего расчёта контекста — rc!=0 штатного задания,
        # а не молчаливый успех выброшенного прогона (make_task.sh:50-52).
        # Мир: заморозка проходит на честном каноне, ПОТОМ канон ломается
        # побегом источника (adversary-2) — штатная ветвь HEAD принимает
        # задание молча и без контекста; честный расчёт — отказ.
        p['contextPack'] = {'rows': [{'kind': 'map', 'path': 'AGENTS.md',
                                      'roles': 'reviewer,critic,orchestrator,implementer',
                                      'mandatory': True, 'why': 'toy'}]}
        canon(root, p)
        trace = put(base, 'trace.tsv',
                     'reviewer\topenai/gpt-5\tallowed\n'
                     'implementer\tanthropic/claude\tallowed\n')
        taskf = put(base, 'task.md', 'задание\n')
        r = call('freeze', contract)
        expect(r.returncode == 0, 'MAKE_TASK_PACK_REFUSAL_FREEZE_FAILED', r)
        (base / 'outside.md').write_text('# External requirement\n')
        p['sourceCanon']['sources'][0]['path'] = '../outside.md'
        put(root, 'harness.project.json', json.dumps(p))
        commit(root, 'canon escape after freeze')
        r = call('make_task_pack', taskf, trace)
        expect(r.returncode != 0, 'MAKE_TASK_PACK_REFUSAL_SWALLOWED', r)
    elif case in ('structure-one-paths-resolve', 'structure-no-second-canon-validator'):
        # Р2-3: одна копия логики контекста/грамматики; судится по коду
        # (grep определения функции / характерный блок валидатора).
        if mode == 'model':
            r = call('structure')
            expect(r.returncode == 0, 'STRUCTURE_MODEL_REFUSED:' + case, r)
            return
        if case == 'structure-one-paths-resolve':
            defs = {s.name: len(re.findall(r'^project_paths_resolve\s*\(\s*\)',
                                           s.read_text(), re.M))
                    for s in (TOOLS / 'scripts').glob('*.sh')}
            expect(sum(defs.values()) == 1,
                   'STRUCTURE_DUPLICATE_PATHS_RESOLVE:' + json.dumps(defs))
        else:
            body = (TOOLS / 'scripts/check_project_sources.sh').read_text()
            markers = [m for m in ('_keys_ok', '_sources_uniq', '_gate_clean',
                                   'keys | sort') if m in body]
            expect(not markers,
                   'STRUCTURE_SECOND_CANON_VALIDATOR:' + ','.join(markers))
    elif case == 'self-canonical':
        # Product configuration is an input of its own resolver/paths CLI, not a text grep.
        install = installation(base)
        r = subject(mode, 'self_canonical', install, mutant=mutant, tools=install) if mode == 'model' else run(
            ['bash', install / 'scripts/profile_resolver.sh', '--repo', install],
            env=dict(os.environ, HARNESS_PROJECT_LAYER_ROOT=str(install)))
        expect(r.returncode == 0, 'SELF_PROFILE_UNAVAILABLE', r)
        got = json.loads(r.stdout)
        expect(got.get('git', {}).get('value', {}).get('canonicalRemote') ==
               'ssh://git@github.com/a3ka/dev-harness.git', 'SELF_CANONICAL_CUTOVER_BROKEN')


def test(case, mode, base, mutant):
    root, origin, p, contract = world(base)
    if case in GATE_CASES:
        return gate_test(case, mode, mutant, root, p, contract)
    if case in EXTRA_CASES:
        return extra_test(case, mode, base, mutant, root, origin, p, contract)
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
                # Arbiter П2б: the registry must be a committed HEAD blob
                # authored by orchestrator, not just working-tree bytes.
                relative = str(reg.relative_to(root))
                shown = run(['git', '-C', str(root), 'show', 'HEAD:' + relative])
                author = run(['git', '-C', str(root), 'log', '-1',
                              '--format=%an', '--', relative])
                expect(shown.returncode == 0 and shown.stdout.strip() == expected.strip()
                       and author.stdout.strip() == 'orchestrator',
                       'REGISTRY_NOT_COMMITTED_AS_ORCHESTRATOR', r)
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
        expect(git(root, 'cat-file', '-t', tag) == 'tag', 'RESERVATION_NOT_ANNOTATED')
    elif case == 'station-isolation':
        install = installation(base)
        scratch = base / 'leak-scratch'
        scratch.mkdir()
        env = dict(os.environ, TMPDIR=str(scratch))
        leak = lambda stage: run(['bash', install / 'scripts/check_no_leak.sh', stage, install], env=env)
        r = leak('--snapshot')
        expect(r.returncode == 0, 'LEAK_SNAPSHOT_FAILED', r)
        r = subject(mode, 'freeze', root, contract, mutant=mutant, tools=install)
        expect(r.returncode == 0, 'STATION_FREEZE_FAILED', r)
        r = leak('--check')
        expect(r.returncode == 0, 'STATION_POLLUTED_INSTALLATION', r)
        r = subject(mode, 'done', root, contract, mutant=mutant, tools=install)
        expect(r.returncode == 0, 'STATION_DONE_FAILED', r)
        r = leak('--check')
        expect(r.returncode == 0, 'STATION_DONE_POLLUTED_INSTALLATION', r)
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
EXTRA_CASES += ('git-override',)
CASES += EXTRA_CASES + tuple(GATE_CASES)
# Н-39: each mutation is challenged only where its defect is observable.
MUTANTS = {'hardcoded-origin': ('git-profile', 'git-layer'),
           'trust-target': ('git-reject',), 'root-layout': ('paths',),
           'root-verdict': ('freeze-profile', 'done-profile'),
           'ignore-critic': ('freeze-decoy',), 'ignore-review': ('done-decoy',),
           'old-review': ('done-fresh',), 'accept-escape': ('paths-escape',),
           'station-writes-tools': ('station-isolation',),
           'skip-canon': ('canon-fail', 'canon-done-fail', 'canon-precritic-fail'),
           'canon-tools-cwd': ('canon-green',),
           'ignore-canon-keys': ('canon-invalid',), 'require-canon': ('canon-absent',)}
MUTANTS.update({
    'root-context': tuple(case for case in EXTRA_CASES if case.startswith('context-')),
    'drop-context-canon': ('context-workshop', 'context-architect'),
    'root-startup': ('context-workshop',),
    'root-verdict-context': ('context-critic', 'context-adversary', 'context-reviewer', 'context-arbiter'),
    'fallback-root': ('freeze-root-only', 'done-root-only'),
    'ignore-project-cap': ('freeze-cap',),
    'root-arbitration': ('freeze-root-arbitration', 'freeze-project-arbitration'),
    'tools-leak': ('station-isolation',),
    'trust-origin-url': ('git-origin-drift',),
    'broken-profile-fallback': ('git-broken-profile', 'freeze-broken-profile', 'done-broken-profile'),
    'accept-symlink': ('paths-symlink',),
    'door-refuse': ('canon-precritic-green', 'canon-done-green'),
    'door-tools-cwd': ('canon-precritic-green', 'canon-done-green'),
    'stale-head-cache': ('canon-stale-head',),
    'canon-null-absent': ('canon-null', 'canon-empty', 'defaults-null-canon'),
    'ignore-canon-grammar': ('canon-bool', 'canon-duplicate', 'canon-missing', 'canon-unavailable', 'canon-nul'),
    'reserve-force': ('reserve-race',),
    'local-reservation': ('reserve-origin', 'reserve-unavailable'),
    'lightweight-reservation': ('reserve-origin',),
    'root-contracts-only': ('zones-project', 'staged-project', 'lib-zones-project'),
    'reject-all-zones': ('zones-green', 'staged-green'),
    'mint-root-registry': ('mint-project',),
    'mint-self-authority': ('mint-no-authority',),
    'old-self-canon': ('self-canonical',),
})
MUTANTS.update({'done-leak': ('station-isolation',),
                'profile-over-override': ('git-override',),
                'root-plan': ('freeze-plan-preserved',),
                'root-closures': ('freeze-closures-preserved',),
                'worktree-plan': ('freeze-head-plan-preserved',),
                'registry-uncommitted': ('freeze-profile',),
                'registry-author-architect': ('freeze-profile',),
                'critic-not-fail-is-accept': ('freeze-escalate', 'freeze-ungrammatical'),
                'review-grammar': ('done-escalate', 'done-ungrammatical')})
MUTANTS.update({
    # Круг 1 (FAIL ×2): обманные стабы к новым клеткам, каждый — к входу,
    # на котором его дефект наблюдаем (Н-39).
    'gate-argv0-repo-join': ('gate-path-argv0',),
    'resolver-canon-lenient': ('resolver-canon-extra-key', 'resolver-canon-fraction'),
    'canon-escape-source': ('source-symlink-escape', 'source-traversal-escape'),
    'doors-accept-escape': ('freeze-paths-escape',),
    'accept-root-contract': ('freeze-root-contract', 'done-root-contract'),
    'gitw-cwd-constant': ('gitw-cwd-canon',),
    'probe-prompt-static': ('probe-prompt-project',),
    # Круг 2 (FAIL ×2): обманные стабы к новым клеткам, каждый — к входу,
    # на котором его дефект наблюдаем (Н-39).
    'source-dir-accepted': ('source-directory-not-file',),
    'resolver-path-lenient': ('resolver-source-relative',),
    'context-canon-path-lenient': ('print-context-canon-escape',),
    'print-context-escape-lenient': ('print-context-escape',
                                     'workshop-print-context-escape'),
    'pack-static': ('make-task-pack-project',),
    'pack-swallows-context-refusal': ('make-task-pack-refusal',),
    'structure-duplicate': ('structure-one-paths-resolve',),
    'structure-second-validator': ('structure-no-second-canon-validator',),
})
MUTANTS['skip-gates'] = tuple(GATE_CASES)
for gate, defects in {'spec': ('spec', 'spec-probe'), 'consumers': ('consumers',),
                      'precision': ('precision',), 'doc': ('doc', 'doc-malformed'),
                      'provodka': ('provodka',), 'n39': ('n39',),
                      'form': ('context', 'existing'), 'plan': ('plan', 'closures', 'worktree-plan'),
                      'committed': ('committed',)}.items():
    MUTANTS['skip-' + gate] = tuple(case for case, (_, defect, _) in GATE_CASES.items()
                                   if defect in defects)


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
    # Each world owns its refs and worktree; parallelize green controls too.
    with ThreadPoolExecutor(max_workers=4) as pool:
        results = pool.map(lambda case: execute(case, mode, args.mutant or ''), cases)
        for case, (rc, detail) in zip(cases, results):
            print(f'{case}: rc={rc} {detail}')
            errors += rc
    if args.matrix:
        covered = {case for branches in MUTANTS.values() for case in branches}
        if covered != set(CASES):
            print('PROBE_ERROR: mutation coverage differs from scenarios')
            return 2
        # Mutation worlds have separate repos, origins and detector scratch.
        # Keep ordered results while staying inside spec-ready's 60-second door.
        presentations = [(mutant, case) for mutant, branches in MUTANTS.items() for case in branches]
        with ThreadPoolExecutor(max_workers=4) as pool:
            results = pool.map(lambda pair: execute(pair[1], 'model', pair[0]), presentations)
            for (mutant, case), (rc, detail) in zip(presentations, results):
                print(f'mutation {mutant}: {case}: rc={rc} {detail}')
                errors += rc != 1
    print(f'996: examined={len(cases)} mutants={len(MUTANTS) if args.matrix else 0} mismatches={errors}')
    if errors:
        print('996: проектный цикл не замкнут')
    return int(errors != 0)


if __name__ == '__main__':
    sys.exit(main())
