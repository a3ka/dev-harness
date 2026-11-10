#!/usr/bin/env python3
"""Isolated product git-fixture shared by 187's public-door probes."""
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent
TOOLS = HERE.parents[2]
CONTRACT = '.harness/contracts/777-work.md'
REVIEW = '.harness/verdicts/review/contracts-777-v1.md'

def run(*args, cwd=None, env=None):
    return subprocess.run([str(x) for x in args], cwd=cwd, env=env,
                          capture_output=True, text=True, timeout=45)

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
               'barriers': {'mandatory': [], 'optional': []},
               'contextPack': {'rows': [
                   {'kind': 'map', 'path': 'STRUCTURE.md', 'roles': 'orchestrator,architect,critic,arbiter,implementer,adversary,reviewer', 'mandatory': True, 'why': 'project structure'}
               ], 'adrPath': 'decisions', 'lessonsPath': '.harness/registry/lessons.tsv'}}
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
    put(root, 'STRUCTURE.md', '# STRUCTURE_KEEP_187\n')
    put(root, 'docs/ARCHITECTURE.md', '# STALE_ARCHITECTURE_DOC_187\n')
    put(root, '.harness/registry/lessons.tsv', 'Н-39\tapp/*\tby branch\n')
    put(root, 'app/identity/model.js', 'module.exports = 1;\n')
    if kind == 'backend':
        # Old in-project copy is deliberately stale; it cannot be treated as the pin.
        put(root, 'architecture/package.json', json.dumps({'scripts': {
            'brief': 'node cli.js brief', 'check': 'node cli.js check'}}))
        put(root, 'architecture/cli.js', "console.log('WRONG_LOCAL_BRIEF_187');\n")
        put(root, 'architecture/check-rc', '0\n')
        put(root, 'architecture/baseline/approved.json', '{}\n')
    put(root, CONTRACT, '# Work\nКЛАСС ЗАДАЧИ: кодовый.\n'
        'КОНТЕКСТ: AGENTS.md\n## Существующее\nThe brief is available.\n'
        '## Предмет\nWorking code\n'
        'АРХИТЕКТУРА: L1 api.identity\n'
        '## Архитектура\nОПЕРАЦИЯ: identity.lookup; вход schema.query; выход schema.record\n'
        'ЗОНА implementer: app/identity/model.js\n'
        'ПРОВОДКА:\n- guard=check.sh\nПРОВОДКА-ЭНФОРСМЕНТ: только механизм\n')
    put(root, '.harness/verdicts/critic/contracts-777-v1.md', 'accept\n')
    put(root, REVIEW, 'ACCEPT\nСВЕРКА-АРХИТЕКТУРЫ: identity.lookup; app/identity; привязки и долг проверены\n')
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', 'baseline')
    git(root, 'push', '-q', 'origin', 'main')
    return root
