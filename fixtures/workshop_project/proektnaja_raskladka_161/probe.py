#!/usr/bin/env python3
"""161a: exercise the real project launch doors; model/stabs check the oracle."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[3]
NUMBER = '761'


def run(*argv, cwd=None, env=None):
    return subprocess.run([str(x) for x in argv], cwd=cwd, env=env,
                          text=True, capture_output=True, check=False)


def require(result, label):
    if result.returncode:
        raise RuntimeError(f'{label}: rc {result.returncode}: {result.stderr.strip()[:350]}')
    return result.stdout


class World:
    def __init__(self, base, name):
        self.base = base
        self.main = base / name
        self.origin = base / (name + '.git')
        self.home = base / (name + '-home')
        self.home.mkdir()
        self.env = dict(os.environ, HOME=str(self.home), TMPDIR=str(base),
                        GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null')
        require(run('git', 'init', '-q', '--bare', self.origin, env=self.env), 'bare init')
        require(run('git', 'init', '-q', '-b', 'main', self.main, env=self.env), 'git init')
        require(self.git('remote', 'add', 'origin', self.origin), 'origin')
        self.put('mobile/src/index.ts', 'export const mobile = true;\n')
        self.put('docs/map.md', f'MAP {name}\n')
        self.put('docs/rules.md', f'RULES {name}\n')
        self.put('docs/reuse.md', f'REUSE {name}\n')
        self.put('AGENTS.md', f'PROJECT {name}\n')
        self.put('.github/workflows/mobile.yml', 'name: mobile\non: [push]\njobs: {}\n')
        self.put('.harness/project-layer.json', json.dumps({
            'schemaVersion': 1, 'version': 'v1', 'projectId': name,
            'workspaceId': name + '-workspace', 'defaults': {}}, ensure_ascii=False))
        rows = [{'kind': kind, 'path': path, 'roles': 'architect',
                 'mandatory': mandatory, 'why': name + '-source'}
                for kind, path, mandatory in [('map', 'docs/map.md', True),
                                               ('rules', 'docs/rules.md', True),
                                               ('reuse', 'docs/reuse.md', False)]]
        self.rows = rows
        self.put('harness.project.json', json.dumps({
            'schemaVersion': 1, 'repoId': name, 'language': 'typescript',
            'projectLayer': {'version': 'v1', 'profilePath': '.harness/project-layer.json'},
            'workflowPaths': {'contracts': '.harness/contracts', 'verdicts': '.harness/verdicts',
                              'registry': '.harness/registry', 'fixtures': '.harness/fixtures',
                              'state': '.harness'},
            'commands': {'test': 'true', 'build': 'true', 'typecheck': 'true', 'lint': 'true'},
            'git': {'canonicalRemote': str(self.origin)},
            'ci': {'workflow': '.github/workflows/mobile.yml'},
            'barriers': {'mandatory': [], 'optional': []},
            'contextPack': {'rows': rows}
        }, ensure_ascii=False))
        self.put('.harness/registry/trace.tsv', 'architect\topenai-codex/gpt-6-sol\tdenied\n')
        self.put('.harness/registry/contracts.tsv', 'номер → sha\n')
        self.put('.harness/registry/pauzy.tsv', '')
        self.put('.harness/contracts/760-existing.md', '# Existing\nКЛАСС РИСКА: рисковый — личные данные.\n')
        require(self.git('add', '-A'), 'git add')
        require(self.git('commit', '-qm', 'project baseline'), 'baseline')
        require(self.git('push', '-q', '-u', 'origin', 'main'), 'origin main')
        self.draft = base / (name + '-draft')
        require(self.git('worktree', 'add', '-q', '-b', 'wip/761/architect', self.draft), 'draft worktree')
        self.draft_contract = self.draft / '.harness/contracts/761-launch.md'
        self.draft_contract.write_text('# Draft\nКОНТЕКСТ: запуск проекта\n'
                                       '## Существующее\n- проектный профиль\n'
                                       'ЗОНА architect: mobile/src/index.ts\n', encoding='utf-8')

    def put(self, rel, value):
        path = self.main / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(value, encoding='utf-8')

    def git(self, *args, where=None):
        return run('git', '-C', where or self.main, '-c', 'user.name=architect',
                   '-c', 'user.email=architect@dev-harness.local', *args, env=self.env)

    def snapshot(self):
        return (require(self.git('rev-parse', 'HEAD'), 'HEAD'),
                require(self.git('status', '--porcelain=v1'), 'status'),
                require(self.git('write-tree'), 'index'))

    def mint(self):
        tag = f'id/CONTRACT/{NUMBER}'
        require(self.git('tag', '-a', tag, '-m', 'mint'), 'mint')
        sha = require(self.git('rev-parse', tag), 'tag sha').strip()
        self.put('.harness/registry/contracts.tsv', f'{NUMBER} → {sha}\n')
        require(self.git('add', '.harness/registry/contracts.tsv'), 'mint manifest stage')
        require(self.git('commit', '-qm', 'mint manifest'), 'mint manifest commit')
        require(self.git('push', '-q', 'origin', 'main', tag), 'mint push')


def check(condition, reason, failures):
    if not condition:
        failures.append(reason)


def actual():
    failures = []
    with tempfile.TemporaryDirectory(prefix='fixture-161a-') as tmp:
        base = Path(tmp)
        mob, foreign = World(base, 'Complior-mob'), World(base, 'Complior-back')
        before = mob.snapshot()
        task_args = ['bash', ROOT / 'scripts/make_task.sh', '--repo', mob.draft,
                     '--role', 'architect', '--kind', 'task', '--contract', NUMBER]
        result = run(*task_args, env=mob.env)
        if result.returncode == 2:
            print('NOT_IMPLEMENTED: make_task environment: ' + result.stderr.strip(), file=sys.stderr)
            return 2
        # Each asserted branch is independent; a preceding red does not conceal the next one.
        check(result.returncode == 0, 'DRAFT_MAIN_REQUIRED: make_task ' + result.stderr.strip()[:180], failures)
        if result.returncode == 0:
            expected = [f'MAP: docs/map.md :: Complior-mob-source',
                        'RULES: docs/rules.md', 'REUSE: docs/reuse.md',
                        'ЗОНА architect: mobile/src/index.ts']
            for entry in expected:
                check(entry in result.stdout.splitlines(), 'CONTEXT_FOREIGN: missing exact ' + entry, failures)
            check('Complior-back-source' not in result.stdout, 'CONTEXT_FOREIGN: foreign row', failures)
        check(before == mob.snapshot(), 'MAIN_DIRTY: task pack changed HEAD/index/status of project main', failures)
        # Discover the actual manifest in controlled external state, never reread the project's
        # profile/contract to fabricate an expectation; record it before invoking spawn.
        manifests = [p for p in base.rglob(f'{NUMBER}.tsv')
                     if p.is_file() and '=== MANIFEST ===' in p.read_text(errors='replace')]
        external = [p for p in manifests if mob.main not in p.parents and mob.draft not in p.parents
                    and mob.main / '.git' not in p.parents]
        check(len(external) == 1, 'MANIFEST_MAIN_ONLY: no unique external manifest before spawn', failures)
        if external:
            body = external[0].read_text(encoding='utf-8').splitlines()
            for row in mob.rows:
                expected = f"{row['kind']}\t{row['path']}\t{'mandatory' if row['mandatory'] else 'optional'}\tprofile"
                check(expected in body, 'MANIFEST_ROW_MISSING: ' + row['path'], failures)
        # Every optional profile row remains required even when its mandatory flag is false.
        optional = mob.draft / 'docs/reuse.md'
        optional.unlink()
        no_optional = run(*task_args, env=mob.env)
        check(no_optional.returncode == 1 and 'docs/reuse.md' in no_optional.stderr,
              'PROFILE_PATH_MISSING: absent optional row accepted', failures)
        optional.write_text('REUSE Complior-mob\n', encoding='utf-8')
        mob.mint()
        before_spawn = mob.snapshot()
        spawn = ['bash', ROOT / 'scripts/spawn_agent.sh', '--root', mob.main,
                 '--nnn', NUMBER, '--author', 'architect']
        # Explicit conflict: unrelated main checkout has a valid profile at the SAME relative path.
        conflicted = dict(mob.env, HARNESS_PROJECT_LAYER_ROOT=str(foreign.main))
        mt_conflict = run(*task_args, env=conflicted)
        check((mt_conflict.returncode == 1 and 'LAYER_FOREIGN' in mt_conflict.stderr)
              or (mt_conflict.returncode == 0 and 'Complior-mob-source' in mt_conflict.stdout
                  and 'Complior-back-source' not in mt_conflict.stdout),
              'CONTEXT_FOREIGN: make_task accepted foreign layer', failures)
        sp_conflict = run(*spawn, env=conflicted)
        check((sp_conflict.returncode == 1 and 'LAYER_FOREIGN' in sp_conflict.stderr)
              or (sp_conflict.returncode == 0 and 'BRANCH=wip/761/architect' in sp_conflict.stdout),
              'CONTEXT_FOREIGN: spawn accepted foreign layer: ' + sp_conflict.stderr.strip()[:140], failures)
        if sp_conflict.returncode == 0:
            wt = next((line[9:] for line in sp_conflict.stdout.splitlines() if line.startswith('WORKTREE=')), '')
            check(bool(wt) and Path(wt).exists(), 'SPAWN_NO_WORKTREE', failures)
            check(mob.main not in Path(wt).parents, 'WORKTREE_IN_MAIN', failures)
            check(before_spawn == mob.snapshot(), 'MAIN_DIRTY: spawn changed main', failures)
        elif external:
            normal = run(*spawn, env=mob.env)
            check(normal.returncode == 0, 'MANIFEST_MAIN_ONLY: spawn ' + normal.stderr.strip()[:180], failures)
        # Negative spawn must run independently on a new number, prior to tag/dual-control.
        absent = run('bash', ROOT / 'scripts/spawn_agent.sh', '--root', mob.main,
                     '--nnn', '762', '--author', 'architect', env=mob.env)
        check(absent.returncode == 1 and ('нет манифеста make_task' in absent.stderr
              or 'MANIFEST_MISSING' in absent.stderr),
              'MANIFEST_MISSING: missing pack not rejected before mint: ' + absent.stderr.strip()[:180], failures)
        check('wip/762/architect' not in require(mob.git('branch', '--list'), 'branches'),
              'MANIFEST_MISSING: worktree branch created', failures)
        # Existing project lock (140) is exercised with the project root, not station root.
        state, journals = base / 'state', base / 'journals'
        state.mkdir(); journals.mkdir()
        lock_wt = base / 'lock-worktree'
        require(mob.git('worktree', 'add', '-q', '-b', 'wip/760/architect', lock_wt), 'lock worktree')
        event = base / 'pause-event.json'
        event.write_text(json.dumps({'tasks': [{'agent': 'architect', 'name': 'Arch760',
                          'task': f'SUBJECT=760\nOBJECT={"a" * 40}\nWORKTREE={lock_wt}\nBRANCH=wip/760/architect'}]}))
        mob.put('.harness/registry/pauzy.tsv', '760\t2026-11-05\tвладелец\tпозже\n')
        locked = run('bash', ROOT / 'scripts/zamok_predmeta.sh', '--sudit', '--sostojanie',
                     state, '--zhurnaly', journals, '--repo', mob.main, event, env=mob.env)
        check(locked.returncode == 1 and 'PAUZA_VLADELTSA' in locked.stderr,
              'PROJECT_LOCK_FOREIGN: ' + locked.stderr.strip()[:180], failures)
    for failure in failures:
        print(failure, file=sys.stderr)
    return int(bool(failures))


# Model is independent of the product scripts: mutate a single observable branch of the
# reference subject and assert the same consumer-facing condition as above, per case.
CASES = {
    'draft-main-only': ('make_task', 'DRAFT_MAIN_REQUIRED'),
    'optional-skipped': ('make_task', 'PROFILE_PATH_MISSING'),
    'manifest-in-main': ('make_task', 'MANIFEST_MAIN_ONLY'),
    'spawn-main-only': ('spawn_agent', 'MANIFEST_MAIN_ONLY'),
    'spawn-without-manifest': ('spawn_agent', 'MANIFEST_MISSING'),
    'make-foreign-layer': ('make_task', 'CONTEXT_FOREIGN'),
    'spawn-foreign-layer': ('spawn_agent', 'CONTEXT_FOREIGN'),
    'lock-station-risk': ('zamok_predmeta', 'PROJECT_LOCK_FOREIGN'),
}


def oracle(case, stub=None):
    # Control values are taken before invoking the selected subject branch.
    draft_only = True
    optional_exists = case != 'optional-skipped'
    external_manifest = case != 'spawn-without-manifest'
    foreign_layer = case in ('make-foreign-layer', 'spawn-foreign-layer')
    project_paused = case == 'lock-station-risk'
    if case == 'draft-main-only' and stub == case and draft_only:
        return 'DRAFT_MAIN_REQUIRED'
    if case == 'optional-skipped' and not optional_exists:
        return None if stub == case else 'PROFILE_PATH_MISSING'
    if case == 'manifest-in-main' and stub == case:
        return 'MANIFEST_MAIN_ONLY'
    if case == 'spawn-main-only' and stub == case:
        return 'MANIFEST_MAIN_ONLY'
    if case == 'spawn-without-manifest' and not external_manifest:
        return None if stub == case else 'MANIFEST_MISSING'
    if foreign_layer and stub == case:
        return 'CONTEXT_FOREIGN'
    if project_paused:
        return 'PROJECT_LOCK_FOREIGN' if stub == case else 'PAUZA_VLADELTSA'
    return None


def model(stabs):
    for mutant, (branch, reason) in CASES.items():
        expected = {'optional-skipped': 'PROFILE_PATH_MISSING',
                    'spawn-without-manifest': 'MANIFEST_MISSING',
                    'lock-station-risk': 'PAUZA_VLADELTSA'}.get(mutant)
        honest = oracle(mutant)
        if honest != expected:
            print(f'MODEL_RED: {branch} control {mutant}: {honest}', file=sys.stderr)
            return 1
        if stabs and oracle(mutant, mutant) != (reason if mutant == 'lock-station-risk' else (None if expected else reason)):
            print(f'STAB_ZHIV: {mutant} {branch}: expected {reason}', file=sys.stderr)
            return 1
    return 0


if __name__ == '__main__':
    if len(sys.argv) == 1:
        sys.exit(actual())
    if sys.argv[1:] == ['--model']:
        sys.exit(model(False))
    if sys.argv[1:] == ['--stabs']:
        sys.exit(model(True))
    print('NOT_IMPLEMENTED: unsupported mode', file=sys.stderr)
    sys.exit(2)
