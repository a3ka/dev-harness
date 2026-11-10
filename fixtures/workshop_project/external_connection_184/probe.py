#!/usr/bin/env python3
"""184: A10 cutover; every world is a disposable git repository, never a product checkout."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

TOOLS = Path(__file__).resolve().parents[3]
REF = re.compile(r"(?<![\w.-])(?:\.harness/|harness\.project\.json\b)")
PATHS = ('contracts', 'verdicts', 'registry', 'fixtures', 'state')


def git(root, *args):
    return subprocess.run(['git', '-C', str(root), *args], text=True, capture_output=True, check=True).stdout


def world(base, name, change=None):
    root = base / name
    root.mkdir()
    git(root, 'init', '-q')
    git(root, 'config', 'user.name', 'architect')
    git(root, 'config', 'user.email', 'architect@dev-harness.local')
    profile = {
        'schemaVersion': 1, 'repoId': 'toy-184', 'language': 'javascript',
        'projectLayer': {'version': '1', 'profilePath': '.harness/project-layer.json'},
        'workflowPaths': {key: f'.harness/{key}' for key in PATHS},
        'git': {'canonicalRemote': 'https://example.invalid/toy-184.git'},
        'ci': {'workflow': '.github/workflows/ci.yml'},
        'commands': {'test': 'npm --prefix backend test', 'build': 'npm --prefix backend run build',
                     'typecheck': 'npm --prefix backend run typecheck',
                     'lint': 'npm --prefix backend run lint'},
    }
    (root / '.harness').mkdir()
    (root / '.harness/harness.project.json').write_text(json.dumps(profile), encoding='utf-8')
    (root / '.harness/project-layer.json').write_text(json.dumps({
        'schemaVersion': 1, 'version': '1', 'projectId': 'toy-184', 'workspaceId': 'toy-184'
    }), encoding='utf-8')
    for key in PATHS:
        (root / '.harness' / key).mkdir()
        (root / '.harness' / key / '.gitkeep').touch()
    write(root / '.harness/ci.json', json.dumps({
        'schemaVersion': 1, 'projectId': 'toy-184',
        'jobs': {'check': {'class': 'local',
                           'steps': [{'key': 'test', 'run': 'npm --prefix backend test'}]}}}) + '\n')
    (root / '.github/workflows').mkdir(parents=True)
    (root / '.github/workflows/ci.yml').write_text('name: product\n', encoding='utf-8')
    (root / 'README.md').write_text('Independent product\n', encoding='utf-8')
    (root / '.gitignore').write_text('build/\n', encoding='utf-8')
    write(root / 'backend/package.json', json.dumps({'scripts': {
        'test': 'node --test', 'build': 'node build.js',
        'typecheck': 'node check.js', 'lint': 'node lint.js'}}) + '\n')
    git(root, 'remote', 'add', 'origin', 'https://example.invalid/toy-184.git')
    if change:
        change(root)
    git(root, 'add', '.')
    git(root, 'commit', '-qm', name)
    return root


def files(root, shallow=False, skip_ci=False, skip_readme=False, skip_config=False, skip_ignore=False,
          scan_internal=False):
    paths = git(root, 'ls-files', '-z').split('\0')
    for name in paths:
        if not name or (name.startswith('.harness/') and not scan_internal) or name.startswith('.git/'):
            continue
        if shallow and '/' in name:
            continue
        if skip_ci and name.startswith('.github/'):
            continue
        if skip_readme and name.endswith('.md'):
            continue
        if skip_config and name.endswith('.json'):
            continue
        if skip_ignore and name == '.gitignore':
            continue
        yield name


def model(root, mode='honest'):
    # Independent oracle: A10 profile lives ONLY in .harness; project tracked files have no pointer.
    opts = dict(shallow=mode == 'root-only', skip_ci=mode == 'no-ci',
                skip_readme=mode == 'no-docs', skip_config=mode == 'no-config',
                skip_ignore=mode == 'no-ignore', scan_internal=mode == 'scan-internal')
    if mode != 'root-profile' and (root / 'harness.project.json').exists():
        return 'profil'
    path = root / '.harness/harness.project.json'
    if mode == 'root-profile':
        path = root / 'harness.project.json'
    if not path.is_file():
        return 'profil'
    try:
        profile = json.loads(path.read_text(encoding='utf-8'))
        if mode != 'trust-any-profile' and (profile['repoId'] != 'toy-184' or profile['projectLayer']['profilePath'] != '.harness/project-layer.json'):
            return 'profil'
        if any(profile['workflowPaths'][key] != f'.harness/{key}' for key in PATHS):
            return 'profil'
    except (ValueError, KeyError, TypeError):
        return 'profil'
    if mode != 'ignore-all-links':
        for name in files(root, **opts):
            if mode == 'root-profile' and name == 'harness.project.json':
                continue
            if REF.search((root / name).read_text(encoding='utf-8', errors='replace')):
                return 'ssylka'
    return 'ok'


def actual(root):
    env = os.environ.copy()
    env['HARNESS_PROJECT_LAYER_ROOT'] = str(root)
    profile = subprocess.run(['bash', str(TOOLS / 'scripts/profile_resolver.sh'), '--repo', str(root)],
                             text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env)
    if profile.returncode:
        return 'profil', profile.stderr.strip()
    parsed = json.loads(profile.stdout)
    if parsed['repoId']['value'] != 'toy-184':
        return 'profil', 'wrong repoId'
    check = subprocess.run(['bash', str(TOOLS / 'scripts/check_project_connection.sh'), '--repo', str(root)],
                           text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env)
    if check.returncode:
        if any(line.startswith('ОТКАЗ: подключение: ssylka:') for line in check.stderr.splitlines()):
            return 'ssylka', check.stderr.strip()
        return 'profil', check.stderr.strip()
    return 'ok', check.stdout.strip()


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(value, encoding='utf-8')


def mutate(root, change):
    if change == 'ci':
        write(root / '.github/workflows/ci.yml', 'name: product\n# read .harness/fixtures now\n')
    elif change == 'docs':
        write(root / 'README.md', 'Independent product\nsee .harness/contracts/001.md\n')
    elif change == 'config':
        write(root / 'config/runtime.json', '{"bootstrap":".harness/ROADMAP.md"}\n')
    elif change == 'ignore':
        write(root / '.gitignore', 'build/\n.harness/registry/trace.tsv\n')
    elif change == 'nested':
        write(root / 'src/start.js', '// .harness/HANDOFF.md\n')
    elif change == 'root-profile':
        write(root / 'harness.project.json', (root / '.harness/harness.project.json').read_text(encoding='utf-8'))
    elif change == 'bad-profile':
        profile = json.loads((root / '.harness/harness.project.json').read_text(encoding='utf-8'))
        profile['repoId'] = 'other-project'
        write(root / '.harness/harness.project.json', json.dumps(profile))
    elif change == 'only-harness':
        write(root / '.harness/NEXT_TASK.md', 'Read .harness/ROADMAP.md\n')
    elif change == 'wrong-ci-identity':
        manifest = json.loads((root / '.harness/ci.json').read_text(encoding='utf-8'))
        manifest['projectId'] = 'other-project'
        write(root / '.harness/ci.json', json.dumps(manifest) + '\n')
    else:
        raise ValueError(change)

# Each mutant has ONE observable input. Expectations are literals recorded BEFORE subject invocation.
CASES = (
    ('clean', None, 'ok', ()),
    ('internal-reference', 'only-harness', 'ok', ('scan-internal',)),
    ('ci-reference', 'ci', 'ssylka', ('no-ci',)),
    ('readme-reference', 'docs', 'ssylka', ('no-docs',)),
    ('configuration-reference', 'config', 'ssylka', ('no-config',)),
    ('ignore-reference', 'ignore', 'ssylka', ('no-ignore',)),
    ('nested-code-reference', 'nested', 'ssylka', ('root-only',)),
    ('legacy-root-profile', 'root-profile', 'profil', ('root-profile',)),
    ('swapped-identity', 'bad-profile', 'profil', ('trust-any-profile',)),
)


def ci_generator(root, mode):
    manifest = json.loads((root / '.harness/ci.json').read_text(encoding='utf-8'))
    layer = json.loads((root / '.harness/project-layer.json').read_text(encoding='utf-8'))
    if mode == 'model':
        return ('ok' if manifest['projectId'] == layer['projectId'] else 'profil'), ''
    if mode == 'duplicate-profile':
        return 'profil', ''
    if mode == 'trust-manifest':
        return 'ok', ''
    result = subprocess.run(['bash', str(TOOLS / 'scripts/gen_project_workflow.sh'),
                             '--repo', str(root), '--write'], text=True,
                            capture_output=True)
    if result.returncode:
        return 'profil', result.stderr.strip()
    generated = (root / '.github/workflows/ci.yml').read_text(encoding='utf-8')
    return ('ssylka' if REF.search(generated) else 'ok'), result.stdout.strip()


def entrypoint(path, *, without_python=False):
    env = os.environ.copy()
    if without_python:
        env['PATH'] = '/nonexistent'
    result = subprocess.run(['/bin/bash', str(path), '--unknown-184'],
                            text=True, capture_output=True, env=env)
    if without_python:
        return result.returncode == 2 and 'NOT_IMPLEMENTED: python3 unavailable' in result.stderr
    return result.returncode == 2 and 'unrecognized arguments: --unknown-184' in result.stderr


def run(mode, source):
    failures = 0
    with tempfile.TemporaryDirectory(prefix='a10-184-') as tmp:
        base = Path(tmp)
        for name, change, expected, mutants in CASES:
            root = world(base, name, (lambda r, change=change: mutate(r, change)) if change else None)
            # Expected is frozen in the case declaration; never read the candidate's output as oracle.
            if mode == 'stabs':
                if not mutants:
                    continue
                for mutant in mutants:
                    got = model(root, mutant)
                    caught = got != expected
                    print(f'STAB {mutant}@{name}: {"caught" if caught else "ZHIV"} (expected={expected}, got={got})')
                    failures += not caught
            else:
                got, detail = (actual(root) if mode == 'repo' else (model(root), ''))
                ok = got == expected
                print(f'CELL {name}: {"ok" if ok else "RED"} (expected={expected}, got={got})')
                if not ok and detail:
                    print('  ' + detail.splitlines()[0])
                failures += not ok
        for name, change, expected, mutant in (
            ('generator-good', None, 'ok', 'duplicate-profile'),
            ('generator-wrong-id', 'wrong-ci-identity', 'profil', 'trust-manifest'),
        ):
            root = world(base, name, (lambda r, change=change: mutate(r, change)) if change else None)
            got, detail = ci_generator(root, mutant if mode == 'stabs' else mode)
            if mode == 'stabs':
                print(f'STAB {mutant}@{name}: {"caught" if got != expected else "ZHIV"} '
                      f'(expected={expected}, got={got})')
                failures += got == expected
            else:
                print(f'CELL {name}: {"ok" if got == expected else "RED"} '
                      f'(expected={expected}, got={got})')
                if got != expected and detail:
                    print('  ' + detail.splitlines()[0])
                failures += got != expected
        wrapper = Path(__file__).with_name('red_external_connection_184.sh')
        if mode == 'stabs':
            for name, path in (
                ('absent-entrypoint', base / 'missing-wrapper.sh'),
                ('invalid-entrypoint', base / 'invalid-wrapper.sh'),
                ('no-probe', base / 'no-probe.sh'),
                ('swallowed-rc', base / 'swallowed-rc.sh'),
            ):
                if name == 'invalid-entrypoint':
                    write(path, '#!/usr/bin/env bash\nif then\n')
                elif name == 'no-probe':
                    write(path, '#!/usr/bin/env bash\nexit 0\n')
                elif name == 'swallowed-rc':
                    write(path, '#!/usr/bin/env bash\n'
                                f'python3 "{Path(__file__).resolve()}" --unknown-184 >/dev/null 2>&1\n'
                                'exit 0\n')
                caught = not entrypoint(path)
                print(f'STAB {name}@ci-entrypoint: {"caught" if caught else "ZHIV"}')
                failures += not caught
        else:
            ok = entrypoint(wrapper) and entrypoint(wrapper, without_python=True)
            print(f'CELL ci-entrypoint: {"ok" if ok else "RED"}')
            failures += not ok
    return 1 if failures else 0


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--model', action='store_true')
    group.add_argument('--stabs', action='store_true')
    group.add_argument('--repo', metavar='PRODUCT_ROOT', type=Path)
    args = parser.parse_args()
    mode = 'model' if args.model else 'stabs' if args.stabs else 'repo'
    result = run(mode, args.repo)
    if args.repo:
        root = args.repo.resolve()
        if not (root / '.git').exists():
            parser.error('--repo требует git checkout со своим .git')
        # Additional live read-only audit; project and station are never modified.
        matches = [(name, ln) for name in files(root) for ln, line in enumerate(
            (root / name).read_text(encoding='utf-8', errors='replace').splitlines(), 1) if REF.search(line)]
        for name, line in matches[:12]:
            print(f'PRODUCT_REF {name}:{line}')
        print(f'PRODUCT_REF_COUNT {len(matches)}')
        result |= bool(matches)
        if (root / 'harness.project.json').exists():
            print('PRODUCT_ROOT_PROFILE harness.project.json')
            result = 1
    return result


if __name__ == '__main__':
    raise SystemExit(main())
