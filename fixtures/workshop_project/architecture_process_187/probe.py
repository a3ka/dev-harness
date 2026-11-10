#!/usr/bin/env python3
"""Architecture-process public-gate probes; isolated project git and in-memory oracle."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
TOOLS = HERE.parents[2]
CONTRACT = '.harness/contracts/777-work.md'
REVIEW = '.harness/verdicts/review/contracts-777-v1.md'


def run(*args, cwd=None, env=None):
    return subprocess.run([str(x) for x in args], cwd=cwd, env=env,
                          capture_output=True, text=True, timeout=35)


def git(root, *args):
    result = run('git', '-C', root, *args)
    if result.returncode:
        raise RuntimeError(result.stderr)
    return result.stdout.strip()


def put(root, name, text):
    path = root / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def world(base, name, kind='backend'):
    root = base / name
    root.mkdir()
    git(root, 'init', '-q', '-b', 'main')
    git(root, 'config', 'user.name', 'Fixture')
    git(root, 'config', 'user.email', 'fixture@local')
    git(root, 'config', 'commit.gpgsign', 'false')
    git(root, 'config', 'core.hooksPath', '/dev/null')
    remote = base / f'{name}-origin.git'
    git(root, 'init', '--bare', '-q', remote)
    git(root, 'remote', 'add', 'origin', remote)
    repo_id = {'backend': 'Complior-back', 'mobile': 'Complior-mob',
               'harness': 'dev-harness'}[kind]
    profile = {'schemaVersion': 1, 'repoId': repo_id, 'language': 'javascript',
               'projectLayer': {'version': '1', 'profilePath': '.harness/project-layer.json'},
               'workflowPaths': {'contracts': '.harness/contracts', 'verdicts': '.harness/verdicts',
                                 'registry': '.harness/registry', 'fixtures': '.harness/fixtures'},
               'git': {'canonicalRemote': str(remote)},
               'commands': dict.fromkeys(['test', 'build', 'typecheck', 'lint'], 'true'),
               'ci': {'workflow': '.github/workflows/toy.yml'},
               'barriers': {'mandatory': [], 'optional': []}}
    put(root, 'harness.project.json', json.dumps(profile))
    put(root, '.harness/project-layer.json', json.dumps({'schemaVersion': 1, 'version': '1',
                                                          'projectId': 'toy', 'workspaceId': 'toy',
                                                          'defaults': {}}))
    put(root, '.github/workflows/toy.yml', 'name: toy\non: push\njobs:\n  check:\n    runs-on: ubuntu-latest\n    steps:\n      - run: bash check.sh\n')
    put(root, 'package.json', '{"scripts":{"check:toy":"bash check.sh"}}\n')
    put(root, 'check.sh', '#!/usr/bin/env bash\ntest -s AGENTS.md\n')
    put(root, '.harness/registry/ci_parity_exceptions.txt', '# No exceptions.\n')
    put(root, '.harness/registry/contracts.tsv', '777 → ' + '0' * 40 + '\n')
    put(root, 'AGENTS.md', '# Fixture\n')
    put(root, 'app/identity/model.js', 'module.exports = 1;\n')
    if kind == 'backend':
        (root / 'architecture').mkdir()
        # This is a synthetic model/brief, never a dependency on CompliorOS-architecture.
        put(root, 'architecture/package.json', json.dumps({'scripts': {
            'brief': 'node cli.js brief', 'check': 'node cli.js check'}}))
        put(root, 'architecture/cli.js', '''const args=process.argv.slice(2);
const fs=require('fs');
if(args[0]==='brief') {
 const id=args[args.indexOf('--component')+1];
 if(id==='api.identity') console.log('# Identity\\n\\nElement: `api.identity` (component).\\n\\n## Module location\\n\\nProduct location: app/identity/\\n\\n## Contracts\\n\\n### contract.identity @ 1\\n\\n- `identity.lookup`: Lookup Input: `schema.query`. Output: `schema.record`.');
 else if(id==='api.billing') console.log('# Billing\\n\\nElement: `api.billing` (component).\\n\\n## Module location\\n\\nProduct location: app/billing/\\n\\n## Contracts\\n\\n### contract.billing @ 1\\n\\n- `billing.draft`: DRAFT (no schema; payload design required)');
 else process.exit(2);
} else if(args[0]==='check') {
 if(args[1]!=='--base'||args[2]!=='baseline/approved.json'||!fs.existsSync(args[2])) process.exit(2);
 process.exit(Number(fs.readFileSync('check-rc').toString().trim()));
}
else process.exit(2);
''')
        put(root, 'architecture/check-rc', '0\n')
        put(root, 'architecture/baseline/approved.json', '{}\n')
    put(root, CONTRACT, '# Work\nКЛАСС ЗАДАЧИ: кодовый.\n'
        'КОНТЕКСТ: AGENTS.md\n## Существующее\nThe brief is available.\n'
        '## Предмет\nWorking code\n'
        'АРХИТЕКТУРА: api.identity / identity.lookup / L1\n'
        'ЗОНА implementer: app/identity/model.js\n'
        'ПРОВОДКА:\n- guard=check.sh\nПРОВОДКА-ЭНФОРСМЕНТ: только механизм\n')
    put(root, '.harness/verdicts/critic/contracts-777-v1.md', 'accept\n')
    put(root, REVIEW, 'ACCEPT\nСВЕРКА-АРХИТЕКТУРЫ: identity.lookup; app/identity; привязки и долг проверены\n')
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', 'baseline')
    git(root, 'push', '-q', 'origin', 'main')
    return root


def model(root, action, defect=None):
    """Honest reference for the three architecture preconditions, not a fake git gate."""
    profile = json.loads((root / 'harness.project.json').read_text())
    contract = (root / CONTRACT).read_text()
    if profile['repoId'] != 'Complior-back' or 'КЛАСС ЗАДАЧИ: кодовый' not in contract:
        if defect == 'require-architecture' and 'АРХИТЕКТУРА:' not in contract:
            return 1, 'ARCH_DECLARATION'
        return 0, ''
    if action == 'precritic':
        if defect == 'no-check':
            return 0, ''
        check = run('npm', '--prefix', root / 'architecture', 'run', 'check', '--',
                    '--base', 'baseline/approved.json', cwd=root)
        rc = check.returncode
        if defect == 'ignore-check':
            return 0, ''
        return (1, 'ARCH_CHECK') if rc else (0, '')
    if action == 'done':
        if defect == 'ignore-review':
            return 0, ''
        verdict = (root / REVIEW).read_text().splitlines()
        return (0, '') if any(line.startswith('СВЕРКА-АРХИТЕКТУРЫ: ') and
                              line.split(':', 1)[1].strip() for line in verdict) else (1, 'ARCH_REVIEW')
    lines = contract.splitlines()
    arch = [line.removeprefix('АРХИТЕКТУРА: ').strip() for line in lines
            if line.startswith('АРХИТЕКТУРА:')]
    if defect == 'allow-blank':
        arch = ['api.identity / identity.lookup / L1']
    if len(arch) != 1 or len(arch[0].split(' / ')) != 3 or not all(arch[0].split(' / ')):
        return 1, 'ARCH_DECLARATION'
    component, operation, level = arch[0].split(' / ')
    brief = run('npm', '--prefix', root / 'architecture', 'run', 'brief', '--',
                '--compact', '--with-rules', '--component', component, cwd=root)
    if brief.returncode:
        return 1, 'ARCH_DECLARATION'
    section = brief.stdout.split('## Module location\n', 1)
    if len(section) != 2 or f'Element: `{component}` (component).' not in section[0]:
        return 1, 'ARCH_DECLARATION'
    location = section[1].split('## ', 1)[0]
    product_paths = [line.removeprefix('Product location: ') for line in location.splitlines()
                     if line.startswith('Product location: ')]
    if len(product_paths) != 1:
        return 1, 'ARCH_DECLARATION'
    contracts = section[1].split('## Contracts\n', 1)
    if len(contracts) != 2:
        return 1, 'ARCH_DECLARATION'
    operation_lines = [line for line in contracts[1].splitlines()
                       if line.startswith(f'- `{operation}`: ')]
    if len(operation_lines) != 1:
        return 1, 'ARCH_DECLARATION'
    if defect != 'allow-draft' and ('DRAFT' in operation_lines[0] or
                                    'Input: `' not in operation_lines[0] or
                                    'Output: `' not in operation_lines[0]):
        return 1, 'ARCH_DRAFT'
    if level not in ('L1', 'L2', 'L3'):
        return 1, 'ARCH_DECLARATION'
    if defect == 'allow-zone':
        return 0, ''
    zones = [line.split(': ', 1)[1].split() for line in lines
             if line.startswith('ЗОНА implementer: ')]
    if any(not path.startswith(product_paths[0]) for zone in zones for path in zone):
        return 1, 'ARCH_ZONE'
    return 0, ''


def subject(tools, root, action):
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    env['GIT_CONFIG_GLOBAL'] = '/dev/null'
    env['GIT_CONFIG_SYSTEM'] = '/dev/null'
    env['HARNESS_PROJECT_LAYER_ROOT'] = str(root)
    command = {
        'freeze': ['bash', tools / 'scripts/freeze_contract.sh', CONTRACT, 'toy reason', root],
        'precritic': ['bash', tools / 'scripts/pre_critic.sh', '--repo', root, CONTRACT],
        'done': ['bash', tools / 'scripts/done_contract.sh', CONTRACT, 'toy reason', root],
    }[action]
    return run(*command, cwd=root, env=env)


# Own observable coordinate for each decoy: neither shared first failure nor guessed source text.
CASES = (
    ('valid', 'backend', 'freeze', None, None),
    ('missing', 'backend', 'freeze', 'АРХИТЕКТУРА: api.identity / identity.lookup / L1\n', None),
    ('blank', 'backend', 'freeze', 'АРХИТЕКТУРА: api.identity / identity.lookup / L1\n', 'АРХИТЕКТУРА: \n'),
    ('foreign-zone', 'backend', 'freeze', 'app/identity/model.js', 'app/billing/foreign.js'),
    ('draft', 'backend', 'freeze', 'api.identity / identity.lookup / L1', 'api.billing / billing.draft / L1'),
    ('check-good', 'backend', 'precritic', None, None),
    ('check-red', 'backend', 'precritic', '0\n', '7\n'),
    ('review-good', 'backend', 'done', None, None),
    ('review-missing', 'backend', 'done', 'СВЕРКА-АРХИТЕКТУРЫ: identity.lookup; app/identity; привязки и долг проверены\n', ''),
    ('mobile', 'mobile', 'freeze', 'АРХИТЕКТУРА: api.identity / identity.lookup / L1\n', None),
    ('harness', 'harness', 'freeze', 'АРХИТЕКТУРА: api.identity / identity.lookup / L1\n', None),
)
STABS = {
    'missing-line': ('missing', 'allow-blank'),
    'placeholder-line': ('blank', 'allow-blank'),
    'foreign-zone': ('foreign-zone', 'allow-zone'),
    'draft-operation': ('draft', 'allow-draft'),
    'check-not-called': ('check-red', 'no-check'),
    'check-rc-ignored': ('check-red', 'ignore-check'),
    'reviewer-absent': ('review-missing', 'ignore-review'),
    'mobile-required': ('mobile', 'require-architecture'),
    'harness-required': ('harness', 'require-architecture'),
}


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--repo', type=Path)
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    args = parser.parse_args()
    tools = args.repo.resolve() if args.repo else TOOLS
    failures = []
    with tempfile.TemporaryDirectory(prefix='architecture-process-187-') as temp:
        base = Path(temp)
        results = {}
        for label, kind, action, old, new in CASES:
            root = world(base, label, kind)
            if old:
                path = root / ('architecture/check-rc' if label == 'check-red' else
                               REVIEW if label == 'review-missing' else CONTRACT)
                text = path.read_text()
                if old not in text:
                    raise RuntimeError(f'fixture prerequisite: {label}: {old}')
                path.write_text(text.replace(old, new or '', 1))
                if label == 'draft':
                    path.write_text(path.read_text().replace(
                        'ЗОНА implementer: app/identity/model.js',
                        'ЗОНА implementer: app/billing/model.js'))
                    put(root, 'app/billing/model.js', 'module.exports = 2;\n')
                git(root, 'add', '-A')
                git(root, 'commit', '-qm', f'case {label}')
                git(root, 'push', '-q', 'origin', 'main')
            expected_rc, reason = model(root, action)
            if args.model or args.stabs:
                result_rc, output = expected_rc, reason
            else:
                result = subject(tools, root, action)
                result_rc, output = result.returncode, result.stdout + result.stderr
            # Existing unrelated gate may reject a positive: this is a fixture error,
            # not proof that architecture rejected the negative.
            ok = result_rc == expected_rc and (not reason or reason in output)
            results[label] = (root, action, expected_rc, reason)
            print(f'{"GREEN" if ok else "RED"} {label}: rc={result_rc} expected={expected_rc}'
                  + (f' reason={reason}' if reason else '')
                  + (f' output={output[:900]!r}' if not ok else ''))
            if not ok:
                failures.append(label)
            # A failed writer must not mutate tags, even if it prints the right error.
            if not args.model and not args.stabs and expected_rc and action in ('freeze', 'done'):
                tag = 'frozen' if action == 'freeze' else 'done'
                if git(root, 'tag', '-l', f'{tag}/contracts/777/*'):
                    failures.append(label + '-tag')
        if args.stabs:
            caught = 0
            for name, (label, mutant) in STABS.items():
                root, action, honest_rc, _ = results[label]
                fake = model(root, action, mutant)
                if fake[0] != honest_rc:
                    caught += 1
                    print(f'STAB {name} caught @ {label}')
                else:
                    print(f'STAB {name} ZHIV @ {label}')
            print(f'STABS={len(STABS)} CAUGHT={caught}')
            return int(bool(failures) or caught != len(STABS))
        print(f'CELLS={len(CASES)} GREEN={len(CASES)-len(failures)}')
        return int(bool(failures))


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, OSError, subprocess.TimeoutExpired) as exc:
        print(f'INFRA: {exc}', file=sys.stderr)
        sys.exit(2)
