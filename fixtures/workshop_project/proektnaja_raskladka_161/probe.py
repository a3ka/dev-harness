#!/usr/bin/env python3
"""161a: exercise the real project launch doors and report named violations."""
import json
import hashlib
import os
from collections import Counter
from pathlib import Path
import subprocess
import sys
import shutil
import tempfile

ROOT = Path(os.environ.get('PROBE_161_ROOT', Path(__file__).resolve().parents[3])).resolve()
NUMBER = '761'
# А10 (054 v+1): репо-слой профиля — <R>/.harness/harness.project.json. Корневой
# адрес миров выбирается ТОЛЬКО в --model/--stabs, когда резолвер установки ещё
# не принимает внутренний профиль (до cutover 184); bare тогда — NOT_IMPLEMENTED.
INTERNAL_PROFILE = '.harness/harness.project.json'
PROFILE_REL = INTERNAL_PROFILE
# 054 v+1 §Инварианты: тела фраз резолвера P1/P10 (дверь несёт отказ резолвера).
A10_P1_BODY = 'нет .harness/harness.project.json: '
A10_P10_BODY = 'корневой harness.project.json рядом с .harness/harness.project.json: '


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
        self.put(PROFILE_REL, json.dumps({
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
        require(self.git('worktree', 'add', '-q', '-b', 'wip/759/architect', self.draft), 'draft worktree')
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

    def foreign_snapshot(self):
        # Independently record the foreign main AND draft before invoking either door.
        # HEAD/index/status cannot expose changed bytes of an untracked existing file.
        def files(root):
            entries = []
            for path in sorted(root.rglob('*')):
                rel = path.relative_to(root)
                if rel.parts[0] == '.git':
                    continue  # git metadata is covered by HEAD/index/status below
                if path.is_symlink():
                    value = ('link', os.readlink(path))
                elif path.is_file():
                    value = ('file', hashlib.sha256(path.read_bytes()).hexdigest())
                else:
                    value = ('dir',)
                entries.append((str(rel), value))
            return tuple(entries)

        return (self.snapshot(),
                require(self.git('rev-parse', 'HEAD', where=self.draft), 'foreign draft HEAD'),
                require(self.git('status', '--porcelain=v1', where=self.draft), 'foreign draft status'),
                require(self.git('write-tree', where=self.draft), 'foreign draft index'),
                files(self.main), files(self.draft))

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

def manifest_refusal(result):
    return result.returncode == 1 and (
        'нет манифеста make_task' in result.stderr or 'MANIFEST_MISSING' in result.stderr)

def worktree_belongs(path, world):
    if not path or not Path(path).is_dir():
        return False
    common = world.git('rev-parse', '--git-common-dir', where=path)
    return common.returncode == 0 and Path(common.stdout.strip()).resolve() == (
        world.main / '.git').resolve()


def tree_fingerprint(root):
    """Include .git and untracked bytes; HEAD/index/status alone miss metadata writes."""
    entries = []
    for path in sorted(root.rglob('*')):
        rel = str(path.relative_to(root))
        if path.is_symlink():
            value = ('link', os.readlink(path))
        elif path.is_file():
            value = ('file', hashlib.sha256(path.read_bytes()).hexdigest())
        else:
            value = ('dir',)
        entries.append((rel, value))
    return tuple(entries)


def no_manifest_for_other_project(mutant=None, poisoned=False, captured=None, tool='hash'):
    """Two different common .git dirs, same number, shared external state base."""
    failures = []
    with tempfile.TemporaryDirectory(prefix='fixture-161-collision-') as tmp:
        base = Path(tmp)
        first, second = World(base, 'first-mobile'), World(base, 'second-mobile')
        state = base / 'external-state'
        state.mkdir()
        fakebin = base / 'fakebin'
        fakebin.mkdir()
        fake = fakebin / ('git' if tool == 'git' else 'sha256sum')
        if tool == 'git':
            # Only the identity probe lies; every other git operation stays real.
            # Both valid projects now appear to have first.main's common .git.
            fake.write_text('#!/bin/sh\n'
                            'case " $* " in\n'
                            '  *" rev-parse --git-common-dir "*) '
                            f'printf "%s\\n" "{first.main / ".git"}"; exit 0 ;;\n'
                            'esac\nexec /usr/bin/git "$@"\n', encoding='utf-8')
        else:
            fake.write_text('#!/bin/sh\nprintf "%064d  -\\n" 0\n', encoding='utf-8')
        fake.chmod(0o755)
        env_first = dict(first.env, TMPDIR=str(state))
        env_second = dict(second.env, TMPDIR=str(state))
        if poisoned:
            env_first['PATH'] = str(fakebin) + os.pathsep + env_first.get('PATH', os.defpath)
            env_second['PATH'] = str(fakebin) + os.pathsep + env_second.get('PATH', os.defpath)
        before_first = first.snapshot()
        before_second = second.snapshot()
        first_task = run('bash', ROOT / 'scripts/make_task.sh', '--repo', first.draft,
                         '--role', 'architect', '--kind', 'task', '--contract', NUMBER,
                         env=env_first)
        check(first.snapshot() == before_first, 'STATE_FIRST_MAIN_DIRTY', failures)
        check(second.snapshot() == before_second, 'STATE_OTHER_MAIN_DIRTY', failures)
        if first_task.returncode == 0:
            # Mint is legitimate for BOTH projects. Only the first has a prepared packet.
            first.mint()
            second.mint()
            branches = require(second.git('branch', '--list'), 'second branches')
            worktrees = require(second.git('worktree', 'list', '--porcelain'), 'second worktrees')
            spawn = ['bash', ROOT / 'scripts/spawn_agent.sh', '--root', second.main,
                     '--nnn', NUMBER, '--author', 'architect']
            if mutant in ('collision-spawn', 'git-path-spawn'):
                result = run(sys.executable, __file__, '--stub-invoke', mutant,
                             first.main, *spawn, env=env_second)
            else:
                result = run(*spawn, env=env_second)
            reason = 'GIT_PATH_COLLISION' if tool == 'git' else 'STATE_KEY_COLLISION'
            check(manifest_refusal(result) or
                  (result.returncode == 1 and not result.stdout),
                  reason + ': second project accepted first manifest: '
                  + result.stdout.strip()[:160] + result.stderr.strip()[:120], failures)
            check(branches == require(second.git('branch', '--list'), 'second branches after'),
                  reason + ': second branch created', failures)
            check(worktrees == require(second.git('worktree', 'list', '--porcelain'),
                                       'second worktrees after'),
                  reason + ': second worktree created', failures)
        else:
            check(first_task.returncode == 1 and not first_task.stdout,
                  ('GIT_TOOL_INVALID' if tool == 'git' else 'HASH_TOOL_INVALID')
                  + ': first pack partial or unexpected refusal: '
                  + first_task.stderr.strip()[:160], failures)
            check(not list(state.rglob(f'{NUMBER}.tsv')),
                  ('GIT_TOOL_INVALID' if tool == 'git' else 'HASH_TOOL_INVALID')
                  + ': rejected pack left a manifest', failures)
    if captured is not None:
        captured.extend(failures)
    else:
        for failure in failures:
            print(failure, file=sys.stderr)
    return int(bool(failures))


def tmpdir_must_not_enter_main(alias=False, gitdir=False, mutant=None, captured=None):
    failures = []
    with tempfile.TemporaryDirectory(prefix='fixture-161-tmpdir-') as tmp:
        base = Path(tmp)
        world = World(base, 'mobile')
        unsafe = world.main / '.git' if gitdir else world.main
        if alias:
            link = base / 'alias-main'
            link.symlink_to(unsafe, target_is_directory=True)
            unsafe = link
        variant = 'symlink' if alias else 'gitdir' if gitdir else 'checkout'
        before = (world.snapshot(), tree_fingerprint(world.main))
        task = ['bash', ROOT / 'scripts/make_task.sh', '--repo', world.draft,
                '--role', 'architect', '--kind', 'task', '--contract', NUMBER]
        env = dict(world.env, TMPDIR=str(unsafe))
        if mutant == 'tmpdir-write':
            result = run(sys.executable, __file__, '--stub-invoke', mutant,
                         world.main, *task, env=env)
        else:
            result = run(*task, env=env)
        check(result.returncode == 1 and not result.stdout,
              f'TMPDIR_INSIDE_MAIN: {variant}: package not refused before output: '
              + result.stderr.strip()[:140], failures)
        check((world.snapshot(), tree_fingerprint(world.main)) == before,
              f'TMPDIR_MAIN_DIRTY: {variant}: package changed main or .git', failures)
    if captured is not None:
        captured.extend(failures)
    else:
        for failure in failures:
            print(failure, file=sys.stderr)
    return int(bool(failures))


def state_symlink_must_not_enter_main(component, gitdir=False, door='make',
                                      captured=None):
    """A safe TMPDIR can still resolve its manifest through a hostile child link."""
    failures = []
    with tempfile.TemporaryDirectory(prefix='fixture-161-state-link-') as tmp:
        base = Path(tmp)
        world = World(base, 'mobile')
        state = base / 'external-state'
        state.mkdir()
        state_root = state / 'dev-harness-project-state'
        prepared = run('bash', ROOT / 'scripts/make_task.sh', '--repo', world.draft,
                       '--role', 'architect', '--kind', 'task', '--contract', NUMBER,
                       env=dict(world.env, TMPDIR=str(state)))
        manifests = list(state_root.glob(f'*/context/{NUMBER}.tsv'))
        if prepared.returncode != 0 or len(manifests) != 1:
            raise RuntimeError('NOT_IMPLEMENTED: cannot prepare valid external manifest: '
                               f'rc={prepared.returncode} stderr={prepared.stderr[:250]} '
                               f'files={list(state.rglob("*.tsv"))}')
        key = manifests[0].parent.parent.name
        manifest = manifests[0].read_bytes()
        context = state_root / key / 'context'
        target = world.main / '.git' / 'trap-161' if gitdir else world.main / 'docs'
        target.mkdir(exist_ok=True)
        if door == 'spawn':
            world.mint()
        shutil.rmtree(state_root)
        if component == 'state':
            state_root.symlink_to(target, target_is_directory=True)
        elif component == 'key':
            state_root.mkdir()
            (state_root / key).symlink_to(target, target_is_directory=True)
        elif component == 'context':
            (state_root / key).mkdir(parents=True)
            context.symlink_to(target, target_is_directory=True)
        else:
            raise ValueError(component)
        if door == 'spawn':
            context.mkdir(parents=True, exist_ok=True)
            (context / f'{NUMBER}.tsv').write_bytes(manifest)
        before = (world.snapshot(), tree_fingerprint(world.main))
        branches = require(world.git('branch', '--list'), 'link branches')
        worktrees = require(world.git('worktree', 'list', '--porcelain'), 'link worktrees')
        argv = (['bash', ROOT / 'scripts/make_task.sh', '--repo', world.draft,
                 '--role', 'architect', '--kind', 'task', '--contract', NUMBER]
                if door == 'make' else
                ['bash', ROOT / 'scripts/spawn_agent.sh', '--root', world.main,
                 '--nnn', NUMBER, '--author', 'architect'])
        env = dict(world.env, TMPDIR=str(state))
        result = run(*argv, env=env)
        variant = f'{door}-{component}-{"gitdir" if gitdir else "checkout"}'
        check(result.returncode == 1 and 'TMPDIR_INSIDE_MAIN' in result.stderr
              and not result.stdout,
              f'STATE_LINK_UNSAFE: {variant}: expected refusal before output: '
              + result.stderr.strip()[:140], failures)
        check((world.snapshot(), tree_fingerprint(world.main)) == before,
              f'STATE_LINK_MAIN_DIRTY: {variant}: changed main or .git', failures)
        if door == 'spawn':
            check(branches == require(world.git('branch', '--list'), 'link branches after')
                  and worktrees == require(world.git('worktree', 'list', '--porcelain'),
                                           'link worktrees after'),
                  f'STATE_LINK_SPAWNED: {variant}: branch or worktree created', failures)
    if captured is not None:
        captured.extend(failures)
    else:
        for failure in failures:
            print(failure, file=sys.stderr)
    return int(bool(failures))

def safe_state_stays_outside_main(mutant=None, captured=None):
    failures = []
    with tempfile.TemporaryDirectory(prefix='fixture-161-safe-state-') as tmp:
        base = Path(tmp)
        world = World(base, 'mobile')
        before = (world.snapshot(), tree_fingerprint(world.main))
        argv = ['bash', ROOT / 'scripts/make_task.sh', '--repo', world.draft,
                '--role', 'architect', '--kind', 'task', '--contract', NUMBER]
        env = dict(world.env, TMPDIR=str(base))
        result = (run(sys.executable, __file__, '--stub-invoke', mutant,
                      world.main, *argv, env=env)
                  if mutant else run(*argv, env=env))
        check(result.returncode == 0, 'STATE_SAFE_PACK_REFUSED', failures)
        check((world.snapshot(), tree_fingerprint(world.main)) == before,
              'STATE_SAFE_MAIN_DIRTY: issued packet wrote into checkout', failures)
    if captured is not None:
        captured.extend(failures)
    else:
        for failure in failures:
            print(failure, file=sys.stderr)
    return int(bool(failures))

def unusable_hash_must_not_issue_packet(mutant=None, captured=None):
    failures = []
    with tempfile.TemporaryDirectory(prefix='fixture-161-hash-tool-') as tmp:
        base = Path(tmp)
        world = World(base, 'mobile')
        fakebin = base / 'fakebin'
        fakebin.mkdir()
        tool = fakebin / 'sha256sum'
        tool.write_text('#!/bin/sh\nexit 127\n', encoding='utf-8')
        tool.chmod(0o755)
        state = base / 'external-state'
        state.mkdir()
        env = dict(world.env, TMPDIR=str(state),
                   PATH=str(fakebin) + os.pathsep + world.env.get('PATH', os.defpath))
        before = (world.snapshot(), tree_fingerprint(world.main))
        task = ['bash', ROOT / 'scripts/make_task.sh', '--repo', world.draft,
                '--role', 'architect', '--kind', 'task', '--contract', NUMBER]
        result = (run(sys.executable, __file__, '--stub-invoke', 'hash-ignored',
                      str(state), *task, env=env)
                  if mutant else run(*task, env=env))
        check(result.returncode != 0 and not result.stdout,
              'HASH_TOOL_UNUSABLE: packet issued with failing hash tool', failures)
        check(not list(state.rglob(f'{NUMBER}.tsv')),
              'HASH_TOOL_UNUSABLE: manifest issued with failing hash tool', failures)
        check((world.snapshot(), tree_fingerprint(world.main)) == before,
              'HASH_TOOL_MAIN_DIRTY: failing hash changed main', failures)
    if captured is not None:
        captured.extend(failures)
    else:
        for failure in failures:
            print(failure, file=sys.stderr)
    return int(bool(failures))


def actual(mutant=None, captured=None):
    failures = []
    with tempfile.TemporaryDirectory(prefix='fixture-161a-') as tmp:
        base = Path(tmp)
        mob, foreign = World(base, 'Complior-mob'), World(base, 'Complior-back')
        before = mob.snapshot()
        task_args = ['bash', ROOT / 'scripts/make_task.sh', '--repo', mob.draft,
                     '--role', 'architect', '--kind', 'task', '--contract', NUMBER]
        result = (run(sys.executable, __file__, '--stub-invoke', 'optional-skipped',
                      'REUSE: docs/reuse.md', *task_args, env=mob.env)
                  if mutant == 'optional-skipped' else run(*task_args, env=mob.env))
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
        saved_manifest = external[0].read_bytes() if external else None
        # Every optional profile row remains required even when its mandatory flag is false.
        optional = mob.draft / 'docs/reuse.md'
        optional.unlink()
        no_optional = run(*task_args, env=mob.env)
        check(no_optional.returncode == 1 and 'docs/reuse.md' in no_optional.stderr,
              'PROFILE_PATH_MISSING: absent optional row accepted', failures)
        if no_optional.returncode == 1:
            check(not no_optional.stdout, 'PROFILE_PATH_MISSING: partial pack on refusal', failures)
            if external:
                check(external[0].read_bytes() == saved_manifest,
                      'PROFILE_PATH_MISSING: refusal overwrote prepared manifest', failures)
        optional.write_text('REUSE Complior-mob\n', encoding='utf-8')
        mob.mint()
        before_spawn = mob.snapshot()
        spawn = ['bash', ROOT / 'scripts/spawn_agent.sh', '--root', mob.main,
                 '--nnn', NUMBER, '--author', 'architect']
        # The positive spawn has its own branch, distinct from the draft and from
        # the foreign-layer probe. A missing manifest cannot prove foreign context.
        normal = run(*spawn, env=mob.env)
        if external:
            if manifest_refusal(normal):
                failures.append('MANIFEST_MAIN_ONLY: positive spawn: ' + normal.stderr.strip()[:180])
            else:
                check(normal.returncode == 0,
                      'SPAWN_REFUSED: positive spawn: ' + normal.stderr.strip()[:180], failures)
        else:
            check(manifest_refusal(normal),
                  'MANIFEST_MAIN_ONLY: positive spawn: ' + normal.stderr.strip()[:180], failures)
        if normal.returncode == 0:
            check('BRANCH=wip/761/architect' in normal.stdout, 'SPAWN_WRONG_BRANCH', failures)
            wt = next((line[9:] for line in normal.stdout.splitlines() if line.startswith('WORKTREE=')), '')
            check(bool(wt) and Path(wt).is_dir(), 'SPAWN_NO_WORKTREE', failures)
            check(bool(wt) and mob.main not in Path(wt).parents, 'WORKTREE_IN_MAIN', failures)
            check(worktree_belongs(wt, mob), 'SPAWN_FOREIGN_REPOSITORY', failures)
            check(before_spawn == mob.snapshot(), 'MAIN_DIRTY: spawn changed main', failures)
        elif manifest_refusal(normal):
            check('wip/761/architect' not in require(mob.git('branch', '--list'), 'branches'),
                  'MANIFEST_MAIN_ONLY: spawn created branch without external pack', failures)
        # A separate author gives the foreign-layer probe an unused branch without
        # making the positive architect spawn depend on the outcome of this negative.
        conflicted = dict(mob.env, HARNESS_PROJECT_LAYER_ROOT=str(foreign.main))
        foreign_before = foreign.foreign_snapshot()
        mt_conflict = (run(sys.executable, __file__, '--stub-invoke', 'foreign-make',
                           foreign.draft, *task_args, env=conflicted)
                       if mutant == 'foreign-make' else
                       run(sys.executable, __file__, '--stub-invoke', 'foreign-write',
                           str(foreign.main), *task_args, env=conflicted)
                       if mutant == 'foreign-write' else run(*task_args, env=conflicted))
        check((mt_conflict.returncode == 1 and 'LAYER_FOREIGN' in mt_conflict.stderr)
              or (mt_conflict.returncode == 0 and 'Complior-mob-source' in mt_conflict.stdout
                  and 'Complior-back-source' not in mt_conflict.stdout),
              'CONTEXT_FOREIGN: make_task accepted foreign layer', failures)
        if mt_conflict.returncode == 1 and 'LAYER_FOREIGN' in mt_conflict.stderr:
            check(not mt_conflict.stdout, 'LAYER_FOREIGN: make_task issued partial pack', failures)
        check(foreign_before == foreign.foreign_snapshot(),
              'FOREIGN_DIRTY: make_task changed foreign project', failures)
        if external:
            foreign_spawn = [*spawn[:-1], 'critic']
            branches_before = require(mob.git('branch', '--list'), 'branches before foreign spawn')
            worktrees_before = require(mob.git('worktree', 'list', '--porcelain'),
                                       'worktrees before foreign spawn')
            foreign_spawn_before = foreign.foreign_snapshot()
            sp_conflict = run(*foreign_spawn, env=conflicted)
            if manifest_refusal(sp_conflict):
                failures.append('MANIFEST_MAIN_ONLY: foreign-layer spawn has no readable external '
                                'manifest: ' + sp_conflict.stderr.strip()[:140])
            else:
                check((sp_conflict.returncode == 1 and 'LAYER_FOREIGN' in sp_conflict.stderr)
                      or (sp_conflict.returncode == 0 and 'BRANCH=wip/761/critic' in sp_conflict.stdout),
                      'CONTEXT_FOREIGN: spawn accepted foreign layer: '
                      + sp_conflict.stderr.strip()[:140], failures)
            if sp_conflict.returncode == 0:
                wt = next((line[9:] for line in sp_conflict.stdout.splitlines()
                           if line.startswith('WORKTREE=')), '')
                check(bool(wt) and Path(wt).is_dir(), 'CONTEXT_FOREIGN: spawn no worktree', failures)
                check(worktree_belongs(wt, mob), 'CONTEXT_FOREIGN: spawn used foreign repository',
                      failures)
            if sp_conflict.returncode == 1 and 'LAYER_FOREIGN' in sp_conflict.stderr:
                check('wip/761/critic' not in require(mob.git('branch', '--list'), 'branches'),
                      'LAYER_FOREIGN: spawn created branch on refusal', failures)
                check(branches_before == require(mob.git('branch', '--list'), 'branches'),
                      'LAYER_FOREIGN: spawn changed branches on refusal', failures)
                check(worktrees_before == require(mob.git('worktree', 'list', '--porcelain'),
                                                  'worktrees'),
                      'LAYER_FOREIGN: spawn created worktree on refusal', failures)
            check(before_spawn == mob.snapshot(), 'MAIN_DIRTY: foreign spawn changed main', failures)
            check(foreign_spawn_before == foreign.foreign_snapshot(),
                  'FOREIGN_DIRTY: spawn changed foreign project', failures)
        # Negative spawn must run independently on a new number, prior to tag/dual-control.
        missing_spawn = ['bash', ROOT / 'scripts/spawn_agent.sh', '--root', mob.main,
                         '--nnn', '762', '--author', 'architect']
        absent = (run(sys.executable, __file__, '--stub-invoke', 'missing-spawn',
                      NUMBER, *missing_spawn, env=mob.env)
                  if mutant == 'missing-spawn' else run(*missing_spawn, env=mob.env))
        check(manifest_refusal(absent),
              'MANIFEST_MISSING: missing pack not rejected before mint: '
              + absent.stderr.strip()[:180], failures)
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
    if captured is not None:
        captured.extend(failures)
    else:
        for failure in failures:
            print(failure, file=sys.stderr)
    return int(bool(failures))


def installation_address():
    """Which repo-layer address the installation's own resolver accepts (054 v+1, А10)."""
    with tempfile.TemporaryDirectory(prefix='fixture-161-address-') as tmp:
        world = World(Path(tmp), 'address')
        env = dict(world.env, HARNESS_PROJECT_LAYER_ROOT=str(world.main))
        resolve = lambda: run('bash', ROOT / 'scripts/profile_resolver.sh', '--repo', world.main, env=env)
        internal = resolve()
        if internal.returncode == 0:
            return 'a10', ''
        (world.main / INTERNAL_PROFILE).rename(world.main / 'harness.project.json')
        legacy = resolve()
        detail = (internal.stderr.strip().splitlines() or [''])[0][:200]
        return ('legacy' if legacy.returncode == 0 else None), detail


def a10_root_profile(door, state, mutant=None, captured=None):
    """А10: root profile alone (P1) or next to the internal one (P10) is refused by the
    door before MAP/manifest/branch/worktree; the refusal carries the resolver phrase."""
    failures = []
    phrase = A10_P10_BODY if state == 'both' else A10_P1_BODY
    name = f'A10_ROOT_PROFILE: {door}-{state}'
    with tempfile.TemporaryDirectory(prefix='fixture-161-a10-') as tmp:
        base = Path(tmp)
        world = World(base, 'Complior-mob')
        state_dir = base / 'external-state'
        state_dir.mkdir()
        env = dict(world.env, TMPDIR=str(state_dir))
        task = ['bash', ROOT / 'scripts/make_task.sh', '--repo', world.draft,
                '--role', 'architect', '--kind', 'task', '--contract', NUMBER]
        if door == 'spawn':
            # A genuine external manifest and mint exist: the root profile is the only defect.
            prepared = run(*task, env=env)
            if prepared.returncode:
                raise RuntimeError('NOT_IMPLEMENTED: A10 spawn world: cannot prepare manifest: '
                                   + prepared.stderr.strip()[:200])
            if state == 'root-only':
                require(world.git('mv', INTERNAL_PROFILE, 'harness.project.json'), 'a10 mv')
            else:
                shutil.copyfile(world.main / INTERNAL_PROFILE, world.main / 'harness.project.json')
                require(world.git('add', 'harness.project.json'), 'a10 add')
            require(world.git('commit', '-qm', 'A10 ' + state), 'a10 commit')
            require(world.git('push', '-q', 'origin', 'main'), 'a10 push')
            world.mint()
            target = world.main
            argv = ['bash', ROOT / 'scripts/spawn_agent.sh', '--root', world.main,
                    '--nnn', NUMBER, '--author', 'architect']
        else:
            target = world.draft
            shutil.copyfile(target / INTERNAL_PROFILE, target / 'harness.project.json')
            if state == 'root-only':
                (target / INTERNAL_PROFILE).unlink()
            argv = task
        before = (world.snapshot(), require(world.git('branch', '--list'), 'a10 branches'),
                  require(world.git('worktree', 'list', '--porcelain'), 'a10 worktrees'))
        manifests = sorted(state_dir.rglob(f'{NUMBER}.tsv'))
        result = (run(sys.executable, __file__, '--stub-invoke', mutant, target, *argv, env=env)
                  if mutant else run(*argv, env=env))
        check(result.returncode == 1 and not result.stdout
              and any(phrase in line for line in result.stderr.splitlines()),
              f'{name}: expected resolver refusal before output: rc={result.returncode} '
              + result.stderr.strip()[:160], failures)
        check(before == (world.snapshot(), require(world.git('branch', '--list'), 'a10 branches'),
                         require(world.git('worktree', 'list', '--porcelain'), 'a10 worktrees')),
              f'{name}: main, branch or worktree changed', failures)
        check(sorted(state_dir.rglob(f'{NUMBER}.tsv')) == manifests,
              f'{name}: manifest issued for a root profile', failures)
    if captured is not None:
        captured.extend(failures)
    else:
        for failure in failures:
            print(failure, file=sys.stderr)
    return int(bool(failures))


def station_spawn_without_manifest(mutant=None, captured=None):
    """The installation is itself a project under А10: its own spawn without a pack keeps
    MANIFEST_MISSING (095 И-15), i.e. its profile lives at the internal address."""
    failures = []
    with tempfile.TemporaryDirectory(prefix='fixture-161-station-') as tmp:
        base = Path(tmp)
        station = base / 'station'
        for rel in require(run('git', '-C', ROOT, 'ls-files'), 'station files').splitlines():
            if rel.startswith(('fixtures/', 'verdicts/')):
                continue
            src = ROOT / rel
            if src.is_file() and not src.is_symlink():
                dst = station / rel
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, dst)
        home = base / 'home'
        home.mkdir()
        env = dict(os.environ, HOME=str(home), TMPDIR=str(base),
                   GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null')
        env.pop('HARNESS_PROJECT_LAYER_ROOT', None)
        git = lambda *a: run('git', '-C', station, '-c', 'user.name=architect',
                             '-c', 'user.email=architect@dev-harness.local', *a, env=env)
        require(git('init', '-q', '-b', 'main'), 'station init')
        require(git('add', '-A'), 'station add')
        require(git('commit', '-qm', 'station copy'), 'station commit')
        before = (require(git('branch', '--list'), 'station branches'),
                  require(git('worktree', 'list', '--porcelain'), 'station worktrees'))
        argv = ['bash', station / 'scripts/spawn_agent.sh', '--root', station,
                '--nnn', NUMBER, '--author', 'architect']
        result = (run(sys.executable, __file__, '--stub-invoke', mutant, station, *argv, env=env)
                  if mutant else run(*argv, env=env))
        check(manifest_refusal(result),
              'STATION_MANIFEST_MISSING: station spawn without pack not refused by manifest: rc='
              + str(result.returncode) + ' ' + result.stderr.strip()[:160], failures)
        check(before == (require(git('branch', '--list'), 'station branches'),
                         require(git('worktree', 'list', '--porcelain'), 'station worktrees')),
              'STATION_MANIFEST_MISSING: station branch or worktree created', failures)
    if captured is not None:
        captured.extend(failures)
    else:
        for failure in failures:
            print(failure, file=sys.stderr)
    return int(bool(failures))


def stub_invoke(kind, value, argv):
    """Executable stand-ins at the public subject call, each delegates to the real door."""
    if kind == 'optional-skipped':
        # The real door runs on a conforming, present-row input; the deceptive
        # stand-in drops precisely the optional row from the issued pack.
        answer = run(*argv)
        answer.stdout = ''.join(line for line in answer.stdout.splitlines(keepends=True)
                                if line.rstrip('\n') != value)
    elif kind == 'foreign-make':
        args = list(argv)
        args[args.index('--repo') + 1] = value
        answer = run(*args)
    elif kind == 'foreign-write':
        # Genuine door on the conflict input, with a concealed foreign write on either exit.
        answer = run(*argv)
        cache = Path(value) / '.omp/cache-161a'
        cache.parent.mkdir(exist_ok=True)
        cache.write_bytes(b'x')
    elif kind == 'missing-spawn':
        # Deceptive door drops the refusal on the SAME absent-number input.
        # The actual door is called; no manifest is placed in main.
        answer = run(*argv)
        if manifest_refusal(answer):
            return 0
    elif kind in ('collision-spawn', 'git-path-spawn'):
        # The first project's legitimate spawn impersonates the second project's call.
        args = list(argv)
        args[args.index('--root') + 1] = value
        answer = run(*args)
    elif kind == 'a10-root-as-profile':
        # Door that takes the root profile for the repo layer (root fallback): the
        # stand-in shows the real door the root file at the internal address.
        root = Path(value)
        internal, legacy = root / INTERNAL_PROFILE, root / 'harness.project.json'
        legacy.rename(internal)
        try:
            answer = run(*argv)
        finally:
            internal.rename(legacy)
    elif kind == 'a10-root-ignored':
        # Door that never looks at the root next to the internal profile.
        root = Path(value)
        legacy = root / 'harness.project.json'
        hidden = root.parent / ('hidden-root-profile-' + root.name)
        legacy.rename(hidden)
        try:
            answer = run(*argv)
        finally:
            hidden.rename(legacy)
    elif kind == 'station-root-profile':
        # Installation whose own profile stayed at the root (no А10 move): the
        # stand-in returns the station profile to the root before the real door.
        root = Path(value)
        internal, legacy = root / INTERNAL_PROFILE, root / 'harness.project.json'
        if internal.exists():
            internal.rename(legacy)
        answer = run(*argv)
    elif kind == 'tmpdir-write':
        answer = run(*argv)
        cache = Path(value) / '.omp/state-161a'
        cache.parent.mkdir(exist_ok=True)
        cache.write_bytes(b'x')
    elif kind == 'hash-ignored':
        # Refuses to notice the caller's failing hash; runs the genuine door with a
        # safe system PATH, while preserving its TMPDIR and all project inputs.
        env = dict(os.environ)
        env['PATH'] = os.pathsep.join(env['PATH'].split(os.pathsep)[1:])
        answer = run(*argv, env=env)
    elif kind == 'symlink-bypass':
        # On a clean, safe state, this stand-in issues a genuine valid packet
        # but secretly replaces the state child with a link into main before
        # writing its manifest. The honest door leaves main unchanged.
        answer = run(*argv)
        if answer.returncode == 0:
            state_root = Path(os.environ['TMPDIR']) / 'dev-harness-project-state'
            manifests = list(state_root.glob(f'*/context/{NUMBER}.tsv'))
            if len(manifests) != 1:
                print('NOT_IMPLEMENTED: stub lacks genuine manifest', file=sys.stderr)
                return 2
            key = manifests[0].parent.parent.name
            manifest = manifests[0].read_bytes()
            shutil.rmtree(state_root)
            state_root.symlink_to(Path(value) / 'docs', target_is_directory=True)
            context = state_root / key / 'context'
            context.mkdir(parents=True)
            (context / f'{NUMBER}.tsv').write_bytes(manifest)
    else:
        print('NOT_IMPLEMENTED: unknown subject stub', file=sys.stderr)
        return 2
    sys.stdout.write(answer.stdout)
    sys.stderr.write(answer.stderr)
    return answer.returncode


def signature(failure):
    return failure.split(':', 1)[0]


def honest_control():
    """Expected product red before cutover is an independently checked control."""
    failures = []
    rc = actual(captured=failures)
    if rc == 2:
        return 2, failures
    observed = Counter(map(signature, failures))
    pre_cutover = Counter({'MANIFEST_MAIN_ONLY': 1, 'PROFILE_PATH_MISSING': 1})
    if (rc == 0 and not failures) or (rc == 1 and observed == pre_cutover
                                       and any('no unique external manifest before spawn' in x
                                               for x in failures)
                                       and any('absent optional row accepted' in x
                                               for x in failures)):
        return observed, failures
    return None, failures


A10_STABS = (
    ('a10-root-as-profile', lambda reds, m: a10_root_profile('make', 'root-only', m, reds),
     'A10_ROOT_PROFILE: make-root-only'),
    ('a10-root-as-profile', lambda reds, m: a10_root_profile('spawn', 'root-only', m, reds),
     'A10_ROOT_PROFILE: spawn-root-only'),
    ('a10-root-ignored', lambda reds, m: a10_root_profile('make', 'both', m, reds),
     'A10_ROOT_PROFILE: make-both'),
    ('a10-root-ignored', lambda reds, m: a10_root_profile('spawn', 'both', m, reds),
     'A10_ROOT_PROFILE: spawn-both'),
    ('station-root-profile', lambda reds, m: station_spawn_without_manifest(m, reds),
     'STATION_MANIFEST_MISSING:'))


def model(stabs, a10=True):
    baseline, failures = honest_control()
    if baseline == 2:
        return 2
    if baseline is None:
        for failure in failures:
            print(failure, file=sys.stderr)
        print('CONTROL_INVALID: honest product outcome is neither post-cutover green '
              'nor the measured two-class pre-cutover red', file=sys.stderr)
        return 1
    print('CONTROL: honest product ' + ('green' if not baseline else 'expected red: '
          + ', '.join(sorted(baseline))), file=sys.stderr)
    if stabs:
        for name, reason in (('optional-skipped', 'CONTEXT_FOREIGN: missing exact REUSE: docs/reuse.md'),
                             ('foreign-make', 'CONTEXT_FOREIGN: make_task'),
                             ('foreign-write', 'FOREIGN_DIRTY: make_task changed foreign project'),
                             ('missing-spawn', 'MANIFEST_MISSING:')):
            reds = []
            rc = actual(mutant=name, captured=reds)
            expected = Counter(baseline)
            expected[reason.split(':', 1)[0]] += 1
            # Before cutover this mutant writes its manifest into foreign.draft;
            # the foreign-state guard must catch that side effect as well.
            if name == 'foreign-make' and baseline:
                expected['FOREIGN_DIRTY'] += 1
            if (rc != 1 or Counter(map(signature, reds)) != expected
                    or sum(item.startswith(reason) for item in reds) != 1):
                print(f'STAB_ZHIV: {name}: {reds}', file=sys.stderr)
                return 1
            print(f'STAB_CAUGHT: {name}: {reason}', file=sys.stderr)
        for name, probe, reason in (
                ('collision-spawn', lambda reds: no_manifest_for_other_project(
                    mutant='collision-spawn', captured=reds),
                 'STATE_KEY_COLLISION: second project accepted first manifest'),
                ('git-path-spawn', lambda reds: no_manifest_for_other_project(
                    mutant='git-path-spawn', poisoned=True, captured=reds, tool='git'),
                 'GIT_PATH_COLLISION: second project accepted first manifest'),
                ('tmpdir-write', lambda reds: safe_state_stays_outside_main(
                    mutant='tmpdir-write', captured=reds),
                 'STATE_SAFE_MAIN_DIRTY: issued packet wrote into checkout'),
                ('hash-ignored', lambda reds: unusable_hash_must_not_issue_packet(
                    mutant='hash-ignored', captured=reds),
                 'HASH_TOOL_UNUSABLE: packet issued with failing hash tool'),
                ('symlink-bypass', lambda reds: safe_state_stays_outside_main(
                    mutant='symlink-bypass', captured=reds),
                 'STATE_SAFE_MAIN_DIRTY: issued packet wrote into checkout')):
            reds = []
            rc = probe(reds)
            expected_reds = [reason]
            if name == 'hash-ignored':
                expected_reds.append('HASH_TOOL_UNUSABLE: manifest issued with failing hash tool')
            if rc != 1 or len(reds) != len(expected_reds) or not all(
                    any(item.startswith(prefix) for item in reds) for prefix in expected_reds):
                print(f'STAB_ZHIV: {name}: {reds}', file=sys.stderr)
                return 1
            print(f'STAB_CAUGHT: {name}: {reason}', file=sys.stderr)
        if not a10:
            print('A10: резолвер установки ещё не принимает .harness/harness.project.json '
                  '(до cutover 184) — клетки А10 и их подмены судит bare после cutover',
                  file=sys.stderr)
            return 0
        for name, probe, reason in A10_STABS:
            honest = []
            if probe(honest, None) != 0:
                for failure in honest:
                    print(failure, file=sys.stderr)
                print(f'CONTROL_INVALID: honest door red on the А10 cell of {name}', file=sys.stderr)
                return 1
            reds = []
            rc = probe(reds, name)
            if rc != 1 or not reds or not all(item.startswith(reason) for item in reds):
                print(f'STAB_ZHIV: {name}: {reds}', file=sys.stderr)
                return 1
            print(f'STAB_CAUGHT: {name}: {reason}', file=sys.stderr)
    return 0


def main(args, a10):
    if not args:
        outcomes = [actual(), no_manifest_for_other_project(poisoned=True),
                    no_manifest_for_other_project(poisoned=True, tool='git'),
                    tmpdir_must_not_enter_main(), tmpdir_must_not_enter_main(alias=True),
                    tmpdir_must_not_enter_main(gitdir=True),
                    unusable_hash_must_not_issue_packet(),
                    *(state_symlink_must_not_enter_main(component, gitdir=gitdir, door=door)
                      for door in ('make', 'spawn') for component, gitdir in
                      (('state', False), ('state', True), ('key', False),
                       ('context', True))),
                    *(a10_root_profile(door, state) for door in ('make', 'spawn')
                      for state in ('root-only', 'both')),
                    station_spawn_without_manifest()]
        return 2 if 2 in outcomes else int(any(outcomes))
    return model(args == ['--stabs'], a10)


if __name__ == '__main__':
    if len(sys.argv) > 2 and sys.argv[1] == '--stub-invoke':
        sys.exit(stub_invoke(sys.argv[2], sys.argv[3], sys.argv[4:]))
    args = sys.argv[1:]
    if len(args) >= 2 and args[0] == '--repo':
        root = Path(args[1]).resolve()
        if not (root / 'scripts/make_task.sh').is_file():
            print('NOT_IMPLEMENTED: --repo lacks subject scripts', file=sys.stderr)
            sys.exit(2)
        ROOT = root
        os.environ['PROBE_161_ROOT'] = str(root)
        args = args[2:]
    if args not in ([], ['--model'], ['--stabs']):
        print('NOT_IMPLEMENTED: unsupported mode', file=sys.stderr)
        sys.exit(2)
    try:
        address, detail = installation_address()
    except RuntimeError as error:
        print(f'NOT_IMPLEMENTED: {error}', file=sys.stderr)
        sys.exit(2)
    if address is None:
        print('NOT_IMPLEMENTED: резолвер установки не принимает профиль ни по одному адресу: '
              + detail, file=sys.stderr)
        sys.exit(2)
    if not args and address != 'a10':
        print('NOT_IMPLEMENTED: А10 (184) не влит: резолвер установки не принимает '
              '.harness/harness.project.json: ' + detail, file=sys.stderr)
        sys.exit(2)
    if address == 'legacy':
        PROFILE_REL = 'harness.project.json'
    try:
        sys.exit(main(args, address == 'a10'))
    except RuntimeError as error:
        message = str(error)
        print(message if message.startswith('NOT_IMPLEMENTED') else 'NOT_IMPLEMENTED: ' + message,
              file=sys.stderr)
        sys.exit(2)

