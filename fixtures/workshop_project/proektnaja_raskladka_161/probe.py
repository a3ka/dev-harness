#!/usr/bin/env python3
"""161a: exercise the real project launch doors and report named violations."""
import json
import hashlib
import os
from collections import Counter
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


def model(stabs):
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
    return 0


if __name__ == '__main__' and len(sys.argv) > 2 and sys.argv[1] == '--stub-invoke':
    sys.exit(stub_invoke(sys.argv[2], sys.argv[3], sys.argv[4:]))
if __name__ == '__main__':
    if len(sys.argv) == 1:
        sys.exit(actual())
    if sys.argv[1:] == ['--model']:
        sys.exit(model(False))
    if sys.argv[1:] == ['--stabs']:
        sys.exit(model(True))
    print('NOT_IMPLEMENTED: unsupported mode', file=sys.stderr)
    sys.exit(2)
