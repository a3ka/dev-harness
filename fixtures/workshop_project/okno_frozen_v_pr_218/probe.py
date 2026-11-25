#!/usr/bin/env python3
"""218: real PR DAGs; independent semantic expectations and pinned legacy oracle."""
import argparse
import dataclasses
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
TREE = HERE.parents[2]
SOURCE = json.loads((HERE / 'source.json').read_bytes())
FILES = ('check_contract_frozen.sh', 'check_charter.sh', 'lib_incr.sh',
         'next_id.sh', 'lib_registry.sh')
GUARDS = ('frozen', 'charter')
SCRIPT = dict(zip(GUARDS, FILES))


class Prerequisite(RuntimeError):
    pass


def environment(extra=None):
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    for key in ('BASH_ENV', 'ENV', 'CHARTER_LIB', 'NEXT_ID_LIB', 'LIB_INCR_LOADED',
                'INCR_GIT_ROOT', 'GITHUB_EVENT_NAME', 'HARNESS_PROJECT_LAYER_ROOT',
                'HARNESS_WORKFLOW_ROOT'):
        env.pop(key, None)
    env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               GIT_AUTHOR_NAME='architect', GIT_AUTHOR_EMAIL='architect@dev-harness.local',
               GIT_COMMITTER_NAME='architect', GIT_COMMITTER_EMAIL='architect@dev-harness.local',
               GIT_AUTHOR_DATE='1700000000 +0000', GIT_COMMITTER_DATE='1700000000 +0000',
               LC_ALL='C.UTF-8')
    if extra:
        env.update(extra)
    return env


def command(argv, cwd, data=None, extra=None):
    proc = subprocess.Popen(list(map(str, argv)), cwd=cwd, env=environment(extra),
                            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, start_new_session=True)
    try:
        out, err = proc.communicate(data, timeout=SOURCE['runner']['timeout_seconds'])
    except subprocess.TimeoutExpired:
        os.killpg(proc.pid, signal.SIGKILL)
        proc.communicate()
        raise Prerequisite('TIMEOUT: ' + repr(argv))
    return proc.returncode, out, err


def git(root, *args, data=None):
    result = command(['git', '-C', root, *args], root, data=data)
    if result[0]:
        raise Prerequisite(f'GIT_WORLD {args!r}: {result!r}')
    return result[1]


def replace(data, old, new):
    if data.count(old) != 1:
        raise Prerequisite('ANCHOR_NOT_UNIQUE: ' + repr(old))
    return data.replace(old, new)


def sources(root, pinned=False):
    return {name: (git(root, 'show', f"{SOURCE['baseline']}:scripts/{name}")
                   if pinned else (root / 'scripts' / name).read_bytes()) for name in FILES}


def model_sources(baseline):
    result = dict(baseline)
    result['pr_window.sh'] = (HERE / 'model/pr_window.sh').read_bytes()
    # Library import remains before CLI dispatch and has no PR side effects.
    header = b'''# 218 reference CLI dispatch: event, never branch-name heuristics.
PR_ACTIVE=0
[ "${GITHUB_EVENT_NAME:-}" != pull_request ] || PR_ACTIVE=1
__pr_args=()
for __pr_arg in "$@"; do
  if [ "$__pr_arg" = --pr ]; then PR_ACTIVE=1; else __pr_args+=("$__pr_arg"); fi
done
set -- "${__pr_args[@]}"
unset __pr_args __pr_arg
'''
    charter = result['check_charter.sh']
    charter = replace(charter, b'ORACLE=0\n', header + b'ORACLE=0\n')
    # PR checks the entire own DAG even when CI restored an incr cache at HEAD.
    charter = replace(charter, b'incr_parse "$@"\n', b'''if [ "$PR_ACTIVE" -eq 1 ]; then
  __pr_args=()
  while [ "$#" -gt 0 ]; do
    case "$1" in --incr) shift 2 ;; --incr=*) shift ;; *) __pr_args+=("$1"); shift ;; esac
  done
  set -- "${__pr_args[@]}"
fi
incr_parse "$@"
''')
    start = b'g() { git -C "$ROOT" "$@"; }\n'
    common = b'''# shellcheck disable=SC1091
. "$SELF_DIR/pr_window.sh"
mkdir -p "$ROOT/tmp"
pr_prepare
'''
    charter = replace(charter, start, start + b'if [ "$PR_ACTIVE" -eq 1 ]; then\nPR_NAME=check_charter\n' + common + b'pr_charter\nexit $?\nfi\n')
    result['check_charter.sh'] = charter
    frozen = replace(result['check_contract_frozen.sh'], b'ROOT="$(cd "${1:-"$SELF_DIR/.."}" && pwd)"\n', header + b'ROOT="$(cd "${1:-"$SELF_DIR/.."}" && pwd)"\n')
    frozen = replace(frozen, start, start + b'if [ "$PR_ACTIVE" -eq 1 ]; then\nPR_NAME=check_contract_frozen\n' + common + b'fi\n')
    old = b"g ls-tree -r -z --name-only HEAD -- ':(literal)plans/' ':(literal)contracts/' > \"$TMP/ls-raw\" 2>/dev/null || true\n"
    frozen = replace(frozen, old, b'''if [ "$PR_ACTIVE" -eq 1 ]; then
  pr_files > "$TMP/pr-files"
  while IFS= read -r p; do printf '%s\\0' "$p"; done < "$TMP/pr-files" > "$TMP/ls-raw"
else
''' + old + b'fi\n')
    old = b'g for-each-ref --format=\'%(refname)\' \'refs/tags/frozen/\' 2>/dev/null | sort > "$TMP/tags" || true\n'
    frozen = replace(frozen, old, b'if [ "$PR_ACTIVE" -eq 1 ]; then\npr_tags > "$TMP/tags"\nelse\n' + old + b'fi\n')
    old = b'''      pred_komity="$(g log -s --format=%H --no-renames --diff-merges=first-parent \\
        "refs/tags/frozen/$dir/$NNN/$vmax"..HEAD -- "$f" 2>/dev/null || true)"
'''
    frozen = replace(frozen, old, b'''      if [ "$PR_ACTIVE" -eq 1 ]; then
        pred_komity="$(pr_changes)"
      else
''' + old + b'      fi\n')
    result['check_contract_frozen.sh'] = frozen
    return result


@dataclasses.dataclass(frozen=True)
class Cell:
    name: str
    world: str
    guard: str
    rc: int = 0
    diagnosis: str = ''
    mode: str = 'event'
    legacy: bool = False


def cells():
    result = []
    for guard in GUARDS:
        for world in ('clean', 'late-tag', 'neighbor-before', 'neighbor-after',
                      'owner-update', 'owner-update-allowed', 'draft', 'long-main'):
            result.append(Cell(f'{guard}-{world}', world, guard))
        for world, diagnosis in (('missing-base', 'BASE_MISSING'), ('shallow', 'SHALLOW'),
                                 ('forged-base', 'BASE_UNTRUSTED'), ('no-origin', 'ORIGIN_UNAVAILABLE'),
                                 ('unrelated', 'BASE_UNRELATED')):
            result.append(Cell(f'{guard}-{world}', world, guard, 1, 'PR_WINDOW_' + diagnosis))
        for world in ('own-frozen', 'retroactive-frozen', 'delete-frozen', 'verdict-fail'):
            reason = 'без новой заморозки' if guard == 'frozen' else 'без разрешения владельца'
            if world == 'verdict-fail':
                if guard == 'charter':
                    continue
                reason = 'вердикта, который её не разрешил'
            result.append(Cell(f'{guard}-{world}', world, guard, 1, reason))
        for world in ('push-clean', 'push-bad', 'push-incr-empty', 'push-oracle'):
            result.append(Cell(f'{guard}-{world}', world, guard, legacy=True, mode='push'))
    for world in ('own-charter', 'reverted-charter', 'evil-merge', 'side-charter'):
        result.append(Cell('charter-' + world, world, 'charter', 1, 'без разрешения владельца'))
    result.extend([
        Cell('frozen-main-merges-1284', 'main-merges', 'frozen'),
        Cell('charter-explicit-owner', 'owner-update', 'charter', mode='explicit'),
        Cell('frozen-explicit-late-tag', 'late-tag', 'frozen', mode='explicit'),
        Cell('charter-pr-oracle', 'owner-update', 'charter', mode='oracle'),
        Cell('charter-pr-cache-head', 'own-charter', 'charter', 1, 'без разрешения владельца', mode='cache'),
        Cell('charter-pr-cache-green', 'owner-update', 'charter', mode='cache'),
        Cell('frozen-renamed-values', 'late-tag-alt', 'frozen'),
        Cell('charter-renamed-values', 'own-charter-alt', 'charter', 1, 'без разрешения владельца'),
    ])
    return result


class World:
    def __init__(self, directory, cell):
        self.root = directory / 'repo'
        self.origin = directory / 'origin.git'
        self.root.mkdir()
        self.cell = cell
        self.counter = 0
        self.number = SOURCE['worlds']['alternate_number'] if cell.world.endswith('-alt') else SOURCE['worlds']['number']
        self.path = f'contracts/{self.number:03d}-fixture.md'
        self.foreign = f"contracts/{SOURCE['worlds']['foreign_number']:03d}-neighbor.md"
        self.verdict = f'verdicts/critic/contracts-{self.number:03d}-v1.md'
        git(self.root, 'init', '-q', '-b', 'main')
        self.files = {'AGENTS.md': b'charter\n', 'ROADMAP.md': b'roadmap\n',
                      self.path: b'frozen one\n', self.foreign: b'draft\n', self.verdict: b'accept\n'}
        self.seed = self.commit(self.files, (), 'seed')
        git(self.root, 'tag', '-a', 'ustav/1', self.seed, '-m', 'fixture charter')
        git(self.root, 'tag', '-a', f'frozen/contracts/{self.number:03d}/1', self.seed, '-m', 'fixture freeze')
        self.main = self.seed
        self.head = self.seed
        self.build(cell.world.removesuffix('-alt'))
        git(self.root, 'update-ref', 'refs/heads/main', self.main)
        git(self.root, 'symbolic-ref', 'HEAD', 'refs/heads/owner/fixture')
        git(self.root, 'update-ref', 'HEAD', self.head)
        git(self.root, 'reset', '--hard', '-q', self.head)
        git(self.root, 'init', '--bare', '-q', self.origin)
        git(self.origin, 'fetch', '-q', self.root, '+refs/heads/main:refs/heads/main', '+refs/tags/*:refs/tags/*')
        git(self.root, 'remote', 'add', 'origin', str(self.origin))
        git(self.root, 'update-ref', 'refs/remotes/origin/main', self.main)
        if cell.world == 'missing-base':
            git(self.root, 'update-ref', '-d', 'refs/remotes/origin/main')
        elif cell.world == 'forged-base':
            git(self.root, 'update-ref', 'refs/remotes/origin/main', self.head)
        elif cell.world == 'no-origin':
            git(self.root, 'remote', 'remove', 'origin')
            git(self.root, 'update-ref', 'refs/remotes/origin/main', self.main)
        elif cell.world == 'shallow':
            (self.root / '.git/shallow').write_text(self.seed + '\n')
        elif cell.world == 'unrelated':
            unrelated = self.commit({'isolated': b'other root\n'}, (), 'other root')
            git(self.origin, 'fetch', '-q', self.root, f'+{unrelated}:refs/heads/main')
            git(self.root, 'update-ref', 'refs/remotes/origin/main', unrelated)
            git(self.root, 'read-tree', self.head)
        self.cache = directory / 'cache.sha'
        self.cache.write_text(self.head + '\n')
        self.original_cache = self.cache.read_bytes()
        self.before = git(self.root, 'status', '--porcelain=v1', '-z')
        if self.before:
            raise Prerequisite('WORLD_DIRTY')
        # Git plumbing and the constructor establish expected DAG facts before subject.
        if cell.world not in ('missing-base', 'forged-base', 'no-origin', 'shallow', 'unrelated'):
            self.own = git(self.root, 'rev-list', self.head, '--not', self.main).decode().splitlines()
            if not self.own:
                raise Prerequisite('EMPTY_OWN_HISTORY')
        else:
            self.own = []

    def tree_files(self, commit):
        names = git(self.root, 'ls-tree', '-r', '-z', '--name-only', commit).split(b'\0')
        return {os.fsdecode(p): git(self.root, 'show', f'{commit}:{os.fsdecode(p)}') for p in names if p}

    def commit(self, updates, parents, message):
        files = self.tree_files(parents[0]) if parents else {}
        for name, value in updates.items():
            if value is None:
                files.pop(name, None)
            else:
                files[name] = value
        git(self.root, 'read-tree', '--empty')
        records = bytearray()
        for name, value in sorted(files.items()):
            oid = git(self.root, 'hash-object', '-w', '--stdin', data=value).strip()
            records += b'100644 ' + oid + b'\t' + os.fsencode(name) + b'\0'
        git(self.root, 'update-index', '-z', '--index-info', data=bytes(records))
        tree = git(self.root, 'write-tree').decode().strip()
        args = ['commit-tree', tree]
        for parent in parents:
            args += ['-p', parent]
        self.counter += 1
        sha = git(self.root, *args, data=f'{message}\n\nfixture sequence {self.counter}\n'.encode()).decode().strip()
        return sha

    def allowed(self, path):
        return f'fixture permission\n\nРАЗРЕШИЛ-ВЛАДЕЛЕЦ: {path} synthetic test input'

    def main_change(self):
        self.main = self.commit({self.foreign: b'published neighbor\n',
                                 f"verdicts/critic/contracts-{SOURCE['worlds']['foreign_number']:03d}-v1.md": b'accept\n'},
                                (self.main,), 'neighbor publication')
        git(self.root, 'tag', '-a', f"frozen/contracts/{SOURCE['worlds']['foreign_number']:03d}/1", self.main, '-m', 'neighbor')

    def build(self, kind):
        self.head = self.commit({'code.txt': b'own work\n'}, (self.seed,), 'own PR')
        if kind in ('late-tag', 'neighbor-after', 'owner-update', 'owner-update-allowed',
                    'own-charter', 'reverted-charter', 'evil-merge', 'retroactive-frozen',
                    'main-merges', 'long-main'):
            self.main_change()
        if kind == 'long-main':
            for i in range(SOURCE['worlds']['history_commits']):
                self.main = self.commit({'main-code.txt': str(i).encode()}, (self.main,), f'main {i}')
        if kind in ('owner-update', 'owner-update-allowed', 'own-charter', 'reverted-charter', 'evil-merge'):
            self.main = self.commit({'AGENTS.md': b'main-only unauthorized charter\n'}, (self.main,), 'main-only charter')
            if kind in ('own-charter', 'reverted-charter', 'owner-update-allowed'):
                message = self.allowed('ROADMAP.md') if kind == 'owner-update-allowed' else 'own forbidden charter'
                self.head = self.commit({'ROADMAP.md': b'own roadmap\n'}, (self.head,), message)
                if kind == 'reverted-charter':
                    self.head = self.commit({'ROADMAP.md': b'roadmap\n'}, (self.head,), 'revert own charter')
            imported = self.tree_files(self.main)
            imported['code.txt'] = b'own work\n'
            imported['ROADMAP.md'] = self.tree_files(self.head)['ROADMAP.md']
            if kind == 'evil-merge':
                imported['AGENTS.md'] = b'novel evil merge charter\n'
            self.head = self.commit(imported, (self.head, self.main), 'update-branch')
        elif kind in ('own-frozen', 'retroactive-frozen', 'delete-frozen', 'verdict-fail'):
            if kind == 'verdict-fail':
                self.head = self.commit({self.verdict: b'FAIL\n'}, (self.head,), 'replace verdict')
            else:
                self.head = self.commit({self.path: None if kind == 'delete-frozen' else b'own forbidden frozen\n'},
                                        (self.head,), 'own forbidden frozen')
            if kind == 'retroactive-frozen':
                updates = self.tree_files(self.main)
                updates[self.path] = b'own forbidden frozen\n'
                updates['code.txt'] = b'own work\n'
                self.head = self.commit(updates, (self.head, self.main), 'update-branch after own frozen edit')
        elif kind == 'side-charter':
            side = self.commit({'ROADMAP.md': b'own roadmap\n'}, (self.seed,), 'side forbidden charter')
            self.head = self.commit({'ROADMAP.md': b'own roadmap\n'}, (self.head,), self.allowed('ROADMAP.md'))
            self.head = self.commit({}, (self.head, side), 'merge matching first parent')
        elif kind == 'draft':
            self.head = self.commit({self.foreign: b'own draft revision\n'}, (self.head,), 'draft revision')
        elif kind == 'main-merges':
            next_verdict = f'verdicts/critic/contracts-{self.number:03d}-v2.md'
            self.head = self.commit({self.path: b'next frozen\n', next_verdict: b'accept\n'},
                                    (self.head,), self.allowed(self.path))
            self.main = self.commit({self.path: b'next frozen\n', next_verdict: b'accept\n'}, (self.main,), 'main text without own PR permission')
            for i in range(SOURCE['worlds']['main_merges']):
                side = self.commit({f'side-{i}': b'side\n'}, (self.main,), f'neighbor {i}')
                self.main = self.commit({f'side-{i}': b'side\n'}, (self.main, side), f'main merge {i}')
            updates = self.tree_files(self.main)
            updates['code.txt'] = b'own work\n'
            self.head = self.commit(updates, (self.head, self.main), 'update-branch main merges')
        elif kind == 'push-bad':
            self.head = self.commit({'ROADMAP.md': b'forbidden\n', self.path: b'forbidden\n'}, (self.head,), 'forbidden')

    def run(self, selected, directory, trace):
        tool = directory / 'scripts'
        tool.mkdir()
        for name, data in selected.items():
            (tool / name).write_bytes(data)
        args = ['bash', tool / SCRIPT[self.cell.guard]]
        extra = {'GIT_TRACE2_EVENT': str(trace)}
        if self.cell.mode in ('event', 'oracle', 'cache'):
            extra['GITHUB_EVENT_NAME'] = 'pull_request'
        elif self.cell.mode == 'explicit':
            args += ['--pr']
        else:
            extra['GITHUB_EVENT_NAME'] = 'push'
        if self.cell.mode == 'oracle' or self.cell.world == 'push-oracle':
            if self.cell.guard == 'charter':
                args += ['--oracle']
        if self.cell.mode == 'cache' or self.cell.world == 'push-incr-empty':
            if self.cell.guard == 'charter':
                args += ['--incr', self.cache]
        args += [self.root]
        return command(args, self.root, extra=extra)


def history_calls(path):
    if not path.is_file():
        raise Prerequisite('TRACE_ABSENT')
    starts = [json.loads(line) for line in path.read_bytes().splitlines()]
    return [e['argv'] for e in starts if e.get('event') == 'start' and 'argv' in e]


def observe(cell, selected, baseline, scratch, mutant=False):
    with tempfile.TemporaryDirectory(prefix=cell.name + '-', dir=scratch) as temporary:
        directory = Path(temporary)
        world = World(directory, cell)
        expected = None
        if cell.legacy:
            oracle_dir = directory / 'oracle'
            oracle_dir.mkdir()
            expected = world.run(baseline, oracle_dir, directory / 'oracle.trace')
            # Oracle is saved before the tested process; reset only the known cache.
            world.cache.write_bytes(world.original_cache)
        target_dir = directory / 'subject'
        target_dir.mkdir()
        result = world.run(selected, target_dir, directory / 'subject.trace')
        errors = []
        if cell.legacy:
            if result != expected:
                errors.append('LEGACY_BYTES')
        else:
            if result[0] != cell.rc:
                errors.append('RC')
            if cell.diagnosis and cell.diagnosis.encode() not in result[2]:
                errors.append('DIAGNOSIS')
            if not cell.diagnosis.startswith('PR_WINDOW_'):
                marker = b'pr: ' + ('check_contract_frozen' if cell.guard == 'frozen' else 'check_charter').encode() + b' '
                if not any(line.startswith(marker) for line in result[2].splitlines()):
                    errors.append('PR_MODE')
            if result[1] != b'':
                errors.append('STDOUT')
            if world.cache.read_bytes() != world.original_cache:
                errors.append('PR_CACHE_CHANGED')
            # Structural witness for bounded history, not a self-reported count.
            trace_path = directory / 'subject.trace'
            if not trace_path.is_file() and cell.mode == 'explicit' and b'cd: --: invalid option' in result[2]:
                errors.append('PR_INTERFACE_ABSENT')
                calls = []
            else:
                calls = history_calls(trace_path)
            for argv in calls:
                for op in ('log', 'rev-list'):
                    if op not in argv:
                        continue
                    rest = argv[argv.index(op) + 1:]
                    if op == 'log' and ('-1' in rest or '--no-walk' in rest):
                        continue
                    if op == 'rev-list' and '-n' in rest and rest[rest.index('-n') + 1:rest.index('-n') + 2] == ['1']:
                        continue
                    bounded = '--not' in rest and world.main in rest and world.head in rest
                    bounded |= any('..' in a and a.split('..')[0] in (world.main, world.seed) for a in rest)
                    if not bounded:
                        errors.append('UNBOUNDED_HISTORY')
        if git(world.root, 'rev-parse', 'HEAD').decode().strip() != world.head:
            errors.append('HEAD_CHANGED')
        if git(world.root, 'status', '--porcelain=v1', '-z') != world.before:
            errors.append('TRACKED_CHANGED')
        unsupported = cell.mode == 'explicit' and b'cd: --: invalid option' in result[2]
        if (result[0] == 2 and not unsupported) or b'NOT_IMPLEMENTED' in result[2] or b'syntax error' in result[2]:
            raise Prerequisite('SUBJECT_ENVIRONMENT: ' + repr(result))
        status = 'RED' if errors else 'GREEN'
        print(f'{cell.name} {status} rc={result[0]} {",".join(sorted(set(errors)))}', flush=True)
        if errors and not mutant:
            print('RAW ' + repr(result), flush=True)
        return not errors


def mutations():
    result = {}
    for path in sorted((HERE / 'stabs').glob('*.json')):
        row = json.loads(path.read_bytes())
        if path.stem != row['name'] or row['name'] in result:
            raise Prerequisite('MUTATION_NAME')
        result[row['name']] = row
    if not result:
        raise Prerequisite('EMPTY_MUTATIONS')
    return result


def catalog():
    cases = cells()
    changes = mutations()
    names = {c.name for c in cases}
    if len(names) != len(cases):
        raise Prerequisite('DUPLICATE_CELL')
    for change in changes.values():
        if not change['cells'] or any(n not in names for n in change['cells']):
            raise Prerequisite('MUTATION_BINDINGS')
    census = {'cells': len(cases), 'mutations': len(changes),
              'bindings': sum(len(m['cells']) for m in changes.values())}
    if SOURCE['census'] != census:
        raise Prerequisite('SOURCE_CENSUS: ' + repr(census))
    print(' '.join(f'{k.upper()}={v}' for k, v in census.items()))
    return cases, changes


def syntax(root, baseline):
    compile(Path(__file__).read_bytes(), str(__file__), 'exec')
    compile((HERE / 'context.py').read_bytes(), str(HERE / 'context.py'), 'exec')
    with tempfile.TemporaryDirectory(prefix='syntax-218-', dir=root) as temporary:
        directory = Path(temporary)
        for name, data in model_sources(baseline).items():
            path = directory / name
            path.write_bytes(data)
            result = command(['bash', '-n', path], TREE)
            if result[0]:
                raise Prerequisite('BASH_SYNTAX: ' + repr(result))
        for path in (HERE / 'model/pr_window.sh', HERE / 'red_okno_frozen_v_pr_218.sh'):
            result = command(['bash', TREE / 'scripts/validate_std.sh', 'bash', path], TREE)
            if result[0]:
                raise Prerequisite('BASH_VALIDATOR: ' + repr(result))
    print('SYNTAX rc=0')
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=TREE)
    modes = parser.add_mutually_exclusive_group()
    for name in ('model', 'stabs', 'catalog', 'sintaksis', 'context'):
        modes.add_argument('--' + name, action='store_true')
    parser.add_argument('--cell')
    args = parser.parse_args()
    try:
        cases, changes = catalog()
        if args.catalog:
            for case in cases:
                print('CELL ' + case.name)
            for change in changes.values():
                for name in change['cells']:
                    print(f"{change['name']} -> {name}")
            return 0
        if args.context:
            return command(['python3', HERE / 'context.py'], TREE)[0]
        baseline = sources(args.repo.resolve(), pinned=True)
        scratch = TREE / 'tmp/scratch-arch218'
        scratch.mkdir(parents=True, exist_ok=True)
        if args.sintaksis:
            return syntax(scratch, baseline)
        selected = model_sources(baseline) if args.model or args.stabs else sources(args.repo.resolve())
        if args.cell:
            cases = [c for c in cases if c.name == args.cell]
            if not cases:
                raise Prerequisite('EMPTY_SELECTION')
        if args.stabs:
            by_name = {c.name: c for c in cases}
            caught = count = 0
            for change in changes.values():
                altered = dict(selected)
                name = change['file']
                altered[name] = replace(altered[name], change['old'].encode(), change['new'].encode())
                checked = command(['bash', '-n'], TREE, data=altered[name])
                if checked[0]:
                    raise Prerequisite('MUTATION_SYNTAX: ' + change['name'])
                for name in change['cells']:
                    case = by_name[name]
                    if not observe(case, selected, baseline, scratch):
                        raise Prerequisite('HONEST_CONTROL_RED: ' + name)
                    dead = not observe(case, altered, baseline, scratch, mutant=True)
                    count += 1
                    caught += dead
                    print(f"{change['name']} -> {name}: {'POIMAN' if dead else 'ZHIV'}", flush=True)
            print(f'STABY={len(changes)} SVJAZI={count} POIMANY={caught} ZHIVYH={count-caught}')
            return int(caught != count)
        green = sum(observe(c, selected, baseline, scratch) for c in cases)
        print(f'KLETKI={len(cases)} ZELENYE={green} KRASNYE={len(cases)-green}')
        return int(green != len(cases))
    except (OSError, ValueError, KeyError, Prerequisite) as exc:
        print('NOT_IMPLEMENTED: ' + str(exc), file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
