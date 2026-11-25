#!/usr/bin/env python3
"""210: real git histories, independent expected judgments, byte-exact CLI observations.

The source tree supplies scripts, never worlds or expected results. Expected per-path
judgments are declared while constructing the input and rendered BEFORE the subject.
Git plumbing supplies only immutable commit identities, ordering and census counts.
"""
import argparse
from fnmatch import fnmatchcase
from dataclasses import dataclass
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile
sys.dont_write_bytecode = True
import transport

HERE = Path(__file__).resolve().parent
TREE = HERE.parents[2]
MODEL = HERE / 'model'
TAG = 'refs/tags/frozen/contracts/{number}/1'
IDENTITY = ['-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local']


class Prerequisite(RuntimeError):
    pass


def environment(tick=0):
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    for key in ('BASH_ENV', 'ENV', 'CHARTER_LIB', 'NEXT_ID_LIB', 'LIB_INCR_LOADED',
                'HARNESS_PROJECT_LAYER_ROOT', 'HARNESS_WORKFLOW_ROOT'):
        env.pop(key, None)
    env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               GIT_AUTHOR_DATE=f'{1700000000 + tick} +0000',
               GIT_COMMITTER_DATE=f'{1700000000 + tick} +0000', LC_ALL='C.UTF-8')
    return env


def command(argv, *, cwd, data=None, tick=0, timeout=25):
    proc = subprocess.Popen(list(map(str, argv)), cwd=cwd, env=environment(tick),
                            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, start_new_session=True)
    try:
        out, err = proc.communicate(data, timeout=timeout)
    except subprocess.TimeoutExpired as exc:
        os.killpg(proc.pid, signal.SIGKILL)
        proc.communicate()
        raise Prerequisite('TIMEOUT: ' + str(argv[0])) from exc
    return proc.returncode, out, err


def git(root, *args, data=None, tick=0):
    rc, out, err = command(['git', '-C', root, *IDENTITY, *args], cwd=root,
                           data=data, tick=tick)
    if rc:
        raise Prerequisite(f'GIT_ENVIRONMENT: {args!r} rc={rc} stderr={err!r}')
    return out


@dataclass(frozen=True)
class Cell:
    name: str
    shape: str
    mode: str = 'fast'
    value: bytes = b'# Frozen contract\n\ncanonical bytes\n'
    number: str = '810'
    object_format: str = 'sha1'
    ref: str = 'refs/heads/wip/810/architect'
    slug: str = 'publication'
    directory: str = 'contracts'


def cells():
    original = [
        Cell('a1-v-istorii-tega', 'history'),
        Cell('a2-grandfather-70-71', 'history', 'library'),
        Cell('a3-grandfather-72-74', 'history', 'library'),
        Cell('b1-lend', 'land'),
        Cell('b2-sync', 'sync'),
        Cell('b3-oracle', 'sync', 'oracle'),
        Cell('b4-incr', 'sync', 'incr'),
        Cell('b5-prepush-sync', 'sync', 'push'),
        Cell('b6-prepush-ancestor', 'history', 'push'),
        Cell('g1-posle-tega', 'edit'),
        Cell('g2-blob-ne-tega', 'different'),
        Cell('g3-legkij-teg', 'lightweight'),
        Cell('g4-bokovaja-vetka', 'side'),
        Cell('g5-chuzhie-roditeli', 'unrelated'),
        Cell('g6-smeshannyj', 'mixed'),
        Cell('g7-prepush-pravka', 'edit', 'push'),
        Cell('g8-vozvrat-posle-tega', 'revert'),
        Cell('g9-teg-bez-puti', 'missing-path'),
        Cell('g10-chernovik', 'draft'),
        Cell('g11-teg-ne-origin', 'local-only'),
        Cell('g12-net-seti', 'offline'),
        Cell('g13-net-origin', 'no-origin'),
        Cell('g14-podmena-obekta', 'retag'),
        Cell('g15-v2-ne-indulgencija', 'version2'),
        Cell('g16-nevernaja-grammatika', 'wrong-name'),
        Cell('g17-roditel-drugoj-blob', 'parent-different'),
        Cell('g18-udalenie', 'delete', 'push'),
        Cell('g19-merge-vozvrat', 'merge-return'),
        Cell('g20-prepush-merge-vozvrat', 'merge-return', 'push', ref='refs/heads/main'),
        Cell('g21-vozvrat-bez-predka-T', 'ancestor-return'),
        Cell('g22-oracle-vozvrat-bez-predka-T', 'ancestor-return', 'oracle'),
        Cell('g23-prepush-vozvrat-bez-predka-T', 'ancestor-return', 'push', ref='refs/heads/main'),
        Cell('v8-kirillica-land', 'land', slug='кириллица'),
        Cell('g24-kirillica-pravka', 'edit', slug='кириллица'),
        Cell('g25-oracle-kirillica-pravka', 'edit', 'oracle', slug='кириллица'),
        Cell('v1-empty', 'land', value=b''),
        Cell('v2-nul', 'land', value=b'\x00frozen\x00\n'),
        Cell('v3-crlf', 'land', value=b'first\r\nsecond\r\n'),
        Cell('v4-crlf-ne-lf', 'different', value=b'first\nsecond\n'),
        Cell('v5-long', 'land', value=b'long frozen bytes\n' * 5000),
        Cell('v6-number', 'land', number='007'),
        Cell('v7-sha256', 'land', object_format='sha256'),
    ]
    forms = {
        'ascii': 'ascii', 'cyrillic': 'кириллица', 'nfc': 'café',
        'nfd': 'cafe\u0301', 'quote': 'a"quote', 'slash': 'a\\slash',
        'space': 'a space', 'leading-space': ' leading', 'trailing-space': 'trailing ',
        'dash': '-dash', 'dot': '.dot',
        'literal-escape': 'a\\t\\n\\"quote',
    }
    for form, slug in forms.items():
        for shape, mode in (('draft', 'fast'), ('history', 'fast'), ('land', 'fast'),
                            ('sync', 'fast'), ('edit', 'fast'), ('edit', 'oracle'),
                            ('edit', 'incr'), ('sync', 'incr'), ('sync', 'push'), ('edit', 'push')):
            original.append(Cell(f'nul-{form}-{shape}-{mode}', shape, mode, slug=slug))
    for form, slug in {**forms, 'tab': 'a\ttab', 'lf': 'a\nline',
                       'soh': 'a\x01' + 'f' * 40, 'sha': 'f' * 64,
                       'header': 'a\n\x01' + 'f' * 40}.items():
        for mode in ('fast', 'oracle', 'incr', 'push'):
            if form not in forms:
                original.append(Cell(f'nul-{form}-edit-{mode}', 'edit', mode, slug=slug))
        if form in ('quote', 'slash', 'tab', 'lf', 'soh'):
            original.append(Cell(f'nul-{form}-mixed', 'mixed', slug=slug))
    for mode in ('fast', 'oracle', 'incr', 'push'):
        original.append(Cell(f'nul-plan-{mode}', 'edit', mode, slug='a"quote', directory='plans'))
        original.append(Cell(f'nul-plan-clean-{mode}', 'history', mode, slug='a\\slash', directory='plans'))
    for shape in ('root', 'additions', 'no-ustav'):
        for mode in ('fast', 'oracle', 'incr'):
            original.append(Cell(f'empty-{shape}-{mode}', 'empty-' + shape, mode))
    original.append(Cell('empty-root-incr-seed', 'empty-root', 'incr-seed'))
    original.append(Cell('empty-md-edit-fast', 'empty-md-edit'))
    return original + transport.cells(sys.modules[__name__])


class World:
    def __init__(self, directory, cell):
        self.directory = Path(directory)
        self.root = self.directory / 'world'
        self.root.mkdir()
        self.cell = cell
        self.path = f'{cell.directory}/{cell.number}-{cell.slug}.md'
        self.other = 'contracts/820-other.md'
        self.tag = TAG.format(number=cell.number).replace('/contracts/', f'/{cell.directory}/')
        self.commits = {}
        self.files = {}
        self.events = {}
        self.tick = 0
        git(self.root, 'init', '-q', '-b', 'main', '--object-format=' + cell.object_format)
        initial = {'AGENTS.md': b'# Fixture charter\n', self.path: b'draft\n'}
        if cell.shape == 'mixed':
            initial[self.other] = b'other frozen\n'
        self.commit('base', initial)
        self.annotate('ustav/1', 'base')
        if cell.shape == 'mixed':
            self.annotate('frozen/contracts/820/1', 'base')
        self.build()
        git(self.root, 'update-ref', 'refs/heads/main', self.commits[self.head])
        self.origin = self.directory / 'origin.git'
        git(self.root, 'clone', '-q', '--bare', '--no-hardlinks', self.root, self.origin)
        git(self.root, 'remote', 'add', 'origin', self.origin)
        if cell.mode == 'push':
            # Only the new input commit(s) are outside the live authority snapshot.
            authority = 'land' if cell.shape == 'sync' else ('freeze' if cell.shape == 'edit' else 'base')
            git(self.origin, 'update-ref', 'refs/heads/main', self.commits[authority])
            self.push_base = authority
        if cell.shape == 'local-only':
            git(self.origin, 'update-ref', '-d', self.tag)
        elif cell.shape == 'offline':
            git(self.root, 'remote', 'set-url', 'origin', self.directory / 'unreachable.git')
        elif cell.shape == 'no-origin':
            git(self.root, 'remote', 'remove', 'origin')
        elif cell.shape == 'retag':
            # Same peeled commit, distinct annotation/object: equality of commits is insufficient.
            self.tick += 1
            git(self.root, 'tag', '-f', '-a', self.tag.removeprefix('refs/tags/'),
                self.commits['freeze'], '-m', 'different local annotation', tick=self.tick)
        self.cache = self.directory / 'cache'
        if cell.mode == 'incr':
            self.cache.write_bytes(self.commits['base'].encode() + b'\n')

    def tree(self, files):
        nodes = {}
        for path, data in files.items():
            node = nodes
            parts = path.split('/')
            for part in parts[:-1]:
                node = node.setdefault(part, {})
            node[parts[-1]] = git(self.root, 'hash-object', '-w', '--stdin', data=data).strip()

        def make(node):
            entries = []
            for name, value in node.items():
                if isinstance(value, dict):
                    entries.append(b'040000 tree ' + make(value) + b'\t' + name.encode() + b'\0')
                else:
                    entries.append(b'100644 blob ' + value + b'\t' + name.encode() + b'\0')
            return git(self.root, 'mktree', '-z', data=b''.join(entries)).strip()
        return make(nodes).decode()

    def commit(self, name, changes, parents=None, message=None):
        if parents is None:
            parents = [] if not self.commits else [next(reversed(self.commits))]
        files = {} if not parents else self.files[parents[0]].copy()
        for path, data in changes.items():
            if data is None:
                files.pop(path, None)
            else:
                files[path] = data
        self.tick += 1
        argv = ['commit-tree', self.tree(files)]
        for parent in parents:
            argv += ['-p', self.commits[parent]]
        self.commits[name] = git(self.root, *argv, data=(message or '210 world: ' + name + '\n').encode(),
                                 tick=self.tick).strip().decode()
        self.files[name] = files
        return name

    def annotate(self, ref, commit):
        self.tick += 1
        git(self.root, 'tag', '-a', ref, self.commits[commit], '-m', '210 fixture freeze', tick=self.tick)

    def event(self, commit, status, path=None):
        self.events[(commit, path or self.path)] = status

    def build(self):
        s, p, value = self.cell.shape, self.path, self.cell.value
        self.docs = ['AGENTS.md', p]
        if s == 'draft':
            self.commit('draft', {p: value})
            self.docs = ['AGENTS.md']; self.head = 'draft'; return
        if s == 'missing-path':
            self.commit('freeze', {p: None})
            self.annotate(self.tag.removeprefix('refs/tags/'), 'freeze')
            self.commit('mainline', {'main.txt': b'main\n'}, ['base'])
            self.commit('land', {p: value}, ['mainline', 'freeze'])
            self.event('land', 'unknown'); self.head = 'land'; return
        self.commit('freeze', {p: value})
        if s == 'lightweight':
            git(self.root, 'tag', self.tag.removeprefix('refs/tags/'), self.commits['freeze'])
        else:
            self.annotate(self.tag.removeprefix('refs/tags/'), 'freeze')
        if s == 'history':
            self.head = 'freeze'
            return
        if s in ('edit', 'revert', 'version2', 'wrong-name', 'delete'):
            self.commit('edit', {p: None if s == 'delete' else b'after freeze\n'})
            self.event('edit', 'deny')
            self.head = 'edit'
            if s == 'revert':
                self.commit('revert', {p: value})
                self.event('revert', 'deny'); self.head = 'revert'
            if s in ('version2', 'wrong-name'):
                suffix = '/2' if s == 'version2' else '/01'
                self.annotate('frozen/contracts/' + self.cell.number + suffix, 'edit')
                self.commit('mainline', {'main.txt': b'main\n'}, ['freeze'])
                self.commit('land', {p: b'after freeze\n'}, ['mainline', 'edit'])
                self.event('land', 'deny'); self.head = 'land'
            return
        if s == 'side':
            self.commit('side', {p: value}, ['base'])
            self.event('side', 'deny'); self.head = 'side'; return
        if s == 'unrelated':
            self.commit('stranger', {p: value, 'stranger.txt': b'not the frozen line\n'}, ['base'])
            self.commit('mainline', {'main.txt': b'main\n'}, ['base'])
            self.commit('land', {p: value, 'stranger.txt': b'not the frozen line\n'}, ['mainline', 'stranger'])
            self.event('stranger', 'deny'); self.event('land', 'deny'); self.head = 'land'; return
        if s == 'parent-different':
            self.commit('parent', {p: b'changed parent\n'})
            self.event('parent', 'deny')
            self.commit('mainline', {'main.txt': b'main\n'}, ['base'])
            self.commit('land', {p: value}, ['mainline', 'parent'])
            self.event('land', 'deny'); self.head = 'land'; return
        if s == 'mixed':
            # One frozen introduction must never excuse the other path in the same commit.
            self.commit('mixed-source', {self.other: b'unauthorized other\n'}, ['freeze'])
            self.event('mixed-source', 'deny', self.other)
            self.commit('mainline', {'main.txt': b'main\n'}, ['base'])
            self.commit('land', {p: value, self.other: b'unauthorized other\n'}, ['mainline', 'mixed-source'])
            self.event('land', 'publish'); self.event('land', 'deny', self.other)
            self.docs.append(self.other); self.head = 'land'; return
        if s == 'ancestor-return':
            # Adv210 Б-1: Q is a strict ancestor of T; land has already published
            # the blob although T never enters the first-parent main line.
            self.commit('mainline', {'main.txt': b'main\n'}, ['base'])
            self.commit('land', {p: value}, ['mainline', 'freeze'])
            self.event('land', 'publish')
            self.commit('branch2', {'side.txt': b'side\n'}, ['freeze'])
            self.commit('tagchild', {'tag.txt': b'tag child\n'}, ['branch2'])
            git(self.root, 'tag', '-d', self.tag.removeprefix('refs/tags/'))
            self.annotate(self.tag.removeprefix('refs/tags/'), 'tagchild')
            self.commit('edit', {p: b'authorized new version\n'}, ['land'],
                        message=f'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: {p} authorized\n')
            self.event('edit', 'razreshil')
            self.commit('mergec', {p: value, 'side.txt': b'side\n'}, ['edit', 'branch2'])
            self.event('mergec', 'deny'); self.head = 'mergec'; return
        if s == 'merge-return':
            # Crit210 form: land publishes frozen text into main, a permitted edit
            # follows the tag on main, a branch off T keeps frozen bytes, and a
            # two-parent merge without an owner string restores them (a return).
            self.commit('mainline', {'main.txt': b'main\n'}, ['base'])
            self.commit('land', {p: value}, ['mainline', 'freeze'])
            self.event('land', 'publish')
            self.commit('edit', {p: b'after freeze\n'}, ['land'],
                        message=f'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: {p} правка после тега\n')
            self.event('edit', 'razreshil')
            self.commit('branch', {'branch.txt': b'branch off T\n'}, ['freeze'])
            self.commit('mergec', {p: value, 'branch.txt': b'branch off T\n'}, ['edit', 'branch'])
            self.event('mergec', 'deny'); self.head = 'mergec'; return
        self.commit('mainline', {'main.txt': b'main\n'}, ['base'])
        result = b'first\r\nsecond\r\n' if self.cell.name == 'v4-crlf-ne-lf' else b'not frozen\n'
        self.commit('land', {p: result if s == 'different' else value}, ['mainline', 'freeze'])
        self.event('land', 'deny' if s in ('different', 'lightweight') else
                   ('unknown' if s in ('local-only', 'offline', 'no-origin', 'retag') else 'publish'))
        self.head = 'land'
        if s == 'sync':
            self.commit('work', {'work.txt': b'wip\n'}, ['mainline'])
            self.commit('sync', {p: value}, ['work', 'land'])
            self.event('sync', 'publish'); self.head = 'sync'

    def expected(self, overrides=None):
        if self.cell.mode == 'library':
            accepted = b'1' if overrides else b'0'
            if self.cell.name == 'a3-grandfather-72-74':
                return 0, b'72=' + accepted + b'\n73=' + accepted + b'\n74=' + accepted + b'\nwrongpath=1\n', b''
            return 0, b'70=' + accepted + b'\n71=' + accepted + b'\nwrongpath=1\nwrongcommit=1\n', b''
        events = {**self.events, **(overrides or {})}
        if overrides and any(status == 'lost-events' for status in overrides.values()):
            events = {(name, path): status for (name, path), status in self.events.items()
                      if path != self.path}
        if overrides and any(status == 'out-of-scope' for status in overrides.values()):
            # The quoting mutant loses the entire path, not merely its denial.
            # Keep the counterfactual expectation independent of subject output.
            self.docs = [path for path in self.docs if path != self.path]
            events = {(name, path): status for (name, path), status in self.events.items()
                      if path != self.path}
        if self.cell.mode == 'push':
            names = git(self.root, 'rev-list', self.commits[self.head], '^' + self.commits[self.push_base]).splitlines()
            wanted = []
            for sha in names:
                for (name, path), status in sorted(events.items()):
                    if self.commits[name].encode() != sha:
                        continue
                    if status in ('deny', 'unknown'):
                        reason = ('устав-дельта M/D без РАЗРЕШИЛ-ВЛАДЕЛЕЦ' if status == 'deny'
                                  else 'не могу проверить публикацию заморозки')
                        wanted.append(f'ОТКАЗ: pre-push: {reason}: ref={self.cell.ref} коммит={sha.decode()} путь={path}\n')
            return int(bool(wanted)), b'', ''.join(wanted).encode()
        order = git(self.root, 'rev-list', self.commits[self.head]).splitlines()
        messages = {}
        failed = set()
        for (name, path), status in events.items():
            short = self.commits[name][:8]
            if status == 'publish':
                text = f'  ok   уставной документ внесён публикацией заморозки: {path} в {short}\n'
            elif status == 'unknown':
                text = f'  FAIL не могу проверить публикацию заморозки: {path} в {short} — проверьте origin, тег и объекты git\n'
                failed.add(path)
            elif status == 'razreshil':
                text = f'  ok   уставной документ изменён с разрешения владельца: {path} в {short}\n'
            else:
                text = f'  FAIL уставной документ изменён без разрешения владельца: {path} в {short} — тело коммита обязано нести строку «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: {path} <причина>» в первой колонке\n'
                failed.add(path)
            messages[(self.commits[name].encode(), path)] = text
        lines = []
        if self.cell.mode == 'incr':
            n = int(git(self.root, 'rev-list', '--count', self.commits['base'] + '..' + self.commits[self.head]))
            suffix = 'коммит' if n % 10 == 1 and n % 100 != 11 else ('коммита' if n % 10 in (2, 3, 4) and n % 100 not in (12, 13, 14) else 'коммитов')
            lines.append(f'incr: check_charter судит {self.commits["base"][:8]}..{self.commits[self.head][:8]} ({n} {suffix})\n')
        summaries = {}
        for path in self.docs:
            since = ('ustav/1' if path == 'AGENTS.md' else 'frozen/' + path.split('/')[0] + '/' + path.split('/')[1][:3] + '/1')
            if self.cell.mode == 'incr' and path == 'AGENTS.md':
                since = self.commits['base']
            n = int(git(self.root, 'rev-list', '--count', since + '..' + self.commits[self.head]))
            summaries[path] = f'  ok   {path} — уставной с {since}, коммитов в диапазоне {n}, изменений без разрешения нет\n'
        if self.cell.mode == 'oracle':
            for path in self.docs:
                lines += [messages[(sha, path)] for sha in order if (sha, path) in messages]
                if path not in failed:
                    lines.append(summaries[path])
        else:
            lines += [messages[(sha, path)] for sha in order for path in sorted(self.docs) if (sha, path) in messages]
            lines += [summaries[path] for path in self.docs if path not in failed]
        lines.append(f'\nуставных документов: {len(self.docs)} · изменений в них: {len(events)} · с разрешения: {sum(s in ("publish", "razreshil") for s in events.values())}\n')
        return int(bool(failed)), b'', ''.join(lines).encode()


def snapshot(root):
    files = tuple((str(p.relative_to(root)), p.read_bytes()) for p in sorted(root.rglob('*'))
                  if p.is_file() and '.git' not in p.relative_to(root).parts)
    return files, git(root, 'rev-parse', 'HEAD'), git(root, 'ls-files', '--stage')


class EmptyWorld(World):
    """The make_repo charter shape, without manufacturing an M/D before the test."""

    def __init__(self, directory, cell):
        self.directory = Path(directory)
        self.root = self.directory / 'world'
        self.root.mkdir()
        self.cell = cell
        self.commits, self.files, self.events = {}, {}, {}
        self.tick = 0
        git(self.root, 'init', '-q', '-b', 'main')
        self.commit('base', {
            'AGENTS.md': '# норма системы\nправило 1: правило без механизма не существует\n'.encode(),
            'ROADMAP.md': '# роадмап\nшаг 5 сделан\n'.encode(),
            'plans/001-p.md': 'предмет плана, критерий готовности, исполнители\n'.encode(),
            'verdicts/critic/plans-001-v1.md': 'accept\nвердикт критика по плану 001\n'.encode(),
        })
        self.annotate('frozen/plans/001/1', 'base')
        if cell.shape != 'empty-no-ustav':
            self.annotate('ustav/1', 'base')
        self.head = 'base'
        if cell.shape in ('empty-additions', 'empty-no-ustav'):
            self.commit('add-one', {'one.txt': b'one\n'})
            self.commit('add-two', {'two.txt': b'two\n'})
            self.head = 'add-two'
        elif cell.shape == 'empty-md-edit':
            self.commit('edit', {'AGENTS.md': b'unauthorized charter edit\n'})
            self.head = 'edit'
        git(self.root, 'update-ref', 'refs/heads/main', self.commits[self.head])
        self.cache = self.directory / 'cache'
        if cell.mode == 'incr':
            self.cache.write_bytes(self.commits['base'].encode() + b'\n')
        # Observe the native protocol, not a Git double. Both invocations must
        # describe this input before any subject has a chance to mutate it.
        native = git(self.root, 'log', '-z', '--format=%x00%H', '--name-only',
                     '--no-renames', '--diff-filter=MD', '--diff-merges=first-parent', 'HEAD')
        match = git(self.root, 'log', '-1', '--format=%H', '--no-renames',
                    '--diff-filter=MD', '--diff-merges=first-parent', 'HEAD')
        has_md = cell.shape == 'empty-md-edit'
        count = int(git(self.root, 'rev-list', '--count', 'HEAD'))
        wanted_count = 2 if has_md else (1 if cell.shape == 'empty-root' else 3)
        if bool(native) != has_md or bool(match) != has_md or count != wanted_count:
            raise Prerequisite('INVALID_EMPTY_WORLD: ' + cell.name)
        if len(git(self.root, 'rev-list', '--parents', self.commits['base']).split()) != 1:
            raise Prerequisite('ROOT_HAS_PARENT: ' + cell.name)

    def expected(self, overrides=None):
        statuses = set((overrides or {}).values())
        lines = []
        head = self.commits[self.head]
        if self.cell.mode == 'incr':
            n = 0 if self.head == 'base' else 2
            suffix = 'коммитов' if n == 0 else 'коммита'
            lines.append(f'incr: check_charter судит {self.commits["base"][:8]}..{head[:8]} ({n} {suffix})\n')
        elif self.cell.mode == 'incr-seed':
            lines.append('incr: check_charter полный прогон (кеш отсутствует)\n')
        if self.cell.shape == 'empty-no-ustav':
            lines.append('NOT_IMPLEMENTED: устав не введён — создайте тег ustav/1 последним коммитом документных правок\n')
            cache = self.commits['base'].encode() + b'\n' if self.cell.mode == 'incr' else None
            return 2, b'', ''.join(lines).encode(), cache
        rejected = 'empty-log-rejected' in statuses
        edited = self.cell.shape == 'empty-md-edit'
        if rejected:
            lines.append('  FAIL пустой или оборванный протокол git log: проверить невозможно\n')
        n = 2 if self.cell.shape == 'empty-additions' else int(edited)
        for path in ('AGENTS.md', 'ROADMAP.md', 'plans/001-p.md'):
            if edited and path == 'AGENTS.md':
                lines.append(f'  FAIL уставной документ изменён без разрешения владельца: {path} в {head[:8]} — тело коммита обязано нести строку «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: {path} <причина>» в первой колонке\n')
                continue
            since = 'frozen/plans/001/1' if path.startswith('plans/') else 'ustav/1'
            if self.cell.mode == 'incr':
                since = self.commits['base']
            lines.append(f'  ok   {path} — уставной с {since}, коммитов в диапазоне {n}, изменений без разрешения нет\n')
        lines.append(f'\nуставных документов: 3 · изменений в них: {int(edited)} · с разрешения: 0\n')
        cache = head.encode() + b'\n' if self.cell.mode in ('incr', 'incr-seed') else None
        if 'cache-absent' in statuses:
            cache = None
        return int(rejected or edited), b'', ''.join(lines).encode(), cache


def observe_empty(cell, sources, scratch, override):
    with tempfile.TemporaryDirectory(prefix=cell.name + '-', dir=scratch) as directory:
        world = EmptyWorld(directory, cell)
        expected = world.expected(override)
        for name, data in sources.items():
            target = world.root / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
        before = snapshot(world.root)
        argv = ['bash', world.root / 'scripts/check_charter.sh']
        if cell.mode == 'oracle':
            argv += ['--oracle']
        elif cell.mode in ('incr', 'incr-seed'):
            argv += ['--incr', world.cache]
        actual = command([*argv, world.root], cwd=world.root)
        # rc 2 is a declared observation ONLY for the no-ustav input. Other
        # missing prerequisites remain infrastructure failures, never catches.
        allowed = (0, 1, 2) if cell.shape == 'empty-no-ustav' else (0, 1)
        if actual[0] not in allowed:
            raise Prerequisite(f'SUBJECT_ENVIRONMENT {cell.name}: {actual!r}')
        if snapshot(world.root) != before:
            raise Prerequisite('SUBJECT_MUTATED_WORLD: ' + cell.name)
        cache = world.cache.read_bytes() if world.cache.is_file() else None
        return (*actual, cache), expected


def observe(cell, sources, scratch, override=None):
    if cell.shape.startswith('empty-'):
        return observe_empty(cell, sources, scratch, override)
    if cell.mode == 'seam':
        return transport.observe(sys.modules[__name__], cell, sources, scratch, override)
    with tempfile.TemporaryDirectory(prefix=cell.name + '-', dir=scratch) as directory:
        world = World(directory, cell)
        # Freeze both honest and mutant expected observations before any subject execution.
        expected = world.expected(override)
        for name, data in sources.items():
            target = world.root / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
        before = snapshot(world.root)
        if cell.mode == 'library':
            program = '''CHARTER_LIB=1
. "$1"
set +e
grandfather_pair 409836ed5d918d4ecb16f132b8f6e26d287b32cc contracts/204-karta-vyzova-po-faze.md
printf '70=%s\\n' "$?"
grandfather_pair 66a37efff06a1da72febe8e36b9bb37f8ff6d3eb contracts/204-karta-vyzova-po-faze.md
printf '71=%s\\n' "$?"
grandfather_pair 409836ed5d918d4ecb16f132b8f6e26d287b32cc contracts/205-other.md
printf 'wrongpath=%s\\n' "$?"
grandfather_pair aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa contracts/204-karta-vyzova-po-faze.md
printf 'wrongcommit=%s\\n' "$?"
'''
            if cell.name == 'a3-grandfather-72-74':
                program = '''CHARTER_LIB=1
. "$1"
set +e
grandfather_pair 3f313c37cd336905a7a6621034889f8b9d0622c9 contracts/208-zamok-object-predok.md
printf '72=%s\\n' "$?"
grandfather_pair c8711daa62892b1833472f6d54ac7e5a3d7d15c7 contracts/208-zamok-object-predok.md
printf '73=%s\\n' "$?"
grandfather_pair 3f25b7e6da54750e511dbd154f1d98d6c5e89765 contracts/208-zamok-object-predok.md
printf '74=%s\\n' "$?"
grandfather_pair 3f313c37cd336905a7a6621034889f8b9d0622c9 contracts/204-karta-vyzova-po-faze.md
printf 'wrongpath=%s\\n' "$?"
'''
            argv = ['bash', '-c', program, 'library-210', world.root / 'scripts/check_charter.sh']
            stdin = None
        elif cell.mode == 'push':
            argv = ['bash', world.root / '.githooks/pre-push', 'origin', world.origin]
            stdin = f'{cell.ref} {world.commits[world.head]} {cell.ref} {"0" * len(world.commits[world.head])}\n'.encode()
        else:
            argv = ['bash', world.root / 'scripts/check_charter.sh']
            if cell.mode == 'oracle':
                argv += ['--oracle']
            if cell.mode == 'incr':
                argv += ['--incr', world.cache]
            argv += [world.root]
            stdin = None
        actual = command(argv, cwd=world.root, data=stdin)
        if actual[0] not in (0, 1):
            raise Prerequisite(f'SUBJECT_ENVIRONMENT {cell.name}: {actual!r}')
        if snapshot(world.root) != before:
            raise Prerequisite('SUBJECT_MUTATED_WORLD: ' + cell.name)
        if cell.mode == 'incr' and actual[0] == 0 and world.cache.read_bytes() != world.commits[world.head].encode() + b'\n':
            raise Prerequisite('CACHE_NOT_HEAD: ' + cell.name)
        if cell.mode == 'incr' and actual[0] == 1 and world.cache.read_bytes() != world.commits['base'].encode() + b'\n':
            raise Prerequisite('CACHE_ADVANCED_ON_DENIAL: ' + cell.name)
        return actual, expected


# Every anchor is exact and must occur once. Per-cell bindings live in stabs.tsv.
MUTATIONS = {
    'BEZ-BLOBA': ('scripts/check_charter.sh', '  [ "$cb" = "$tb" ] || return 1', '  :', {('land', None): 'publish'}),
    'INVERSIJA-BLOBA': ('scripts/check_charter.sh', '[ "$cb" = "$tb" ]', '[ "$cb" != "$tb" ]', {('land', None): 'publish'}),
    'BEZ-PREDKA': ('scripts/check_charter.sh', '  [ "$bound" -eq 1 ] || return 1', '  :', {('land', None): 'publish'}),
    'BEZ-SYNC': ('scripts/check_charter.sh', 'merge-base --is-ancestor "$tc" "$parent"', 'merge-base --is-ancestor "$parent" "$tc"', {('sync', None): 'deny'}),
    'LEGKIJ-TEG': ('scripts/check_charter.sh', '  [ "$typ" = tag ] || return 1', '  :', {('land', None): 'publish'}),
    'BEZ-ORIGIN': ('scripts/check_charter.sh', '  [ "$remote" = "$oid"$\'\\t\'"$ref" ] || return 2', '  :', {('land', None): 'publish'}),
    'BEZ-RODITEL-BLOBA': ('scripts/check_charter.sh', '  [ "$pb" = "$tb" ] || return 1', '  :', {('land', None): 'publish'}),
    'BEZ-FAST': ('scripts/check_charter.sh', '            __ch_publication_rc=0; charter_frozen_publication "$__ch_c" "$__ch_p" "$ROOT" || __ch_publication_rc=$?', '            __ch_publication_rc=1', {('land', None): 'deny'}),
    'BEZ-ORACLE': ('scripts/check_charter.sh', '        publication_rc=0; charter_frozen_publication "$c" "$f" "$ROOT" || publication_rc=$?', '        publication_rc=1', {('land', None): 'deny', ('sync', None): 'deny'}),
    'BEZ-PREPUSH': ('.githooks/pre-push', '        publication_rc=0; charter_frozen_publication "$c" "$f" "$ROOT" || publication_rc=$?', '        publication_rc=1', {('sync', None): 'deny'}),
    'V2-INDULGENCIJA': ('scripts/check_charter.sh', '  ref="refs/tags/frozen/contracts/$nnn/1"', '  ref="refs/tags/frozen/contracts/$nnn/2"', {('land', None): 'publish'}),
    'BEZ-POST-TAG': ('scripts/check_charter.sh', '  cb="$(git -C "$root" rev-parse --verify --quiet "$c:$p" 2>/dev/null)" || return 1', '  return 0', {('edit', None): 'publish'}),
    'BEZ-NETWORK-FAIL': ('scripts/check_charter.sh', '  remote="$(git -C "$root" ls-remote --refs --tags origin "$ref" 2>/dev/null)" || return 2', '  remote="$(git -C "$root" ls-remote --refs --tags origin "$ref" 2>/dev/null)" || remote="$oid"$\'\\t\'"$ref"', {('land', None): 'publish'}),
    'WRONG-GRAMMAR': ('scripts/check_charter.sh', '  ref="refs/tags/frozen/contracts/$nnn/1"', '  ref="refs/tags/frozen/contracts/$nnn/01"', {('land', None): 'publish'}),
    'SMESHANNYJ': ('scripts/check_charter.sh', '            __ch_publication_rc=0; charter_frozen_publication "$__ch_c" "$__ch_p" "$ROOT" || __ch_publication_rc=$?', '            if [ "${__ch_last_commit:-}" != "$__ch_c" ]; then __ch_last_commit="$__ch_c"; __ch_first_path="$__ch_p"; fi\n            __ch_publication_rc=0; charter_frozen_publication "$__ch_c" "$__ch_first_path" "$ROOT" || __ch_publication_rc=$?', {('land', 'contracts/820-other.md'): 'publish'}),
    'GRANDFATHER-UDALEN': ('scripts/check_charter.sh', '    409836ed5d918d4ecb16f132b8f6e26d287b32cc|66a37efff06a1da72febe8e36b9bb37f8ff6d3eb)', '    0000000000000000000000000000000000000000)', {('grandfather', ''): 'removed'}),
    'BEZ-PERVICHNOJ': ('scripts/check_charter.sh',
                       '  case "$fb" in 0) return 1 ;; 1) ;; *) return 2 ;; esac',
                       '  case "$fb" in 0) return 0 ;; 1) ;; *) return 2 ;; esac',
                       {('mergec', None): 'publish'}),
    'PARY-208-UDALENY': ('scripts/check_charter.sh',
                         '    3f313c37cd336905a7a6621034889f8b9d0622c9|c8711daa62892b1833472f6d54ac7e5a3d7d15c7|3f25b7e6da54750e511dbd154f1d98d6c5e89765)',
                         '    0000000000000000000000000000000000000000)', {('grandfather', ''): 'removed'}),
    'T-VMESTO-PUBLIKACII': ('scripts/check_charter.sh',
                           '    [ "$seen" != "$tb" ] || return 1', '    :',
                           {('mergec', None): 'publish'}),
    'CYRILLIC-VNE-OBLASTI': ('scripts/check_charter.sh',
                            'g ls-tree -r -z --name-only HEAD',
                            'g ls-tree -r --name-only HEAD', {('edit', None): 'out-of-scope'}),
    'NUL-DIFF': ('scripts/check_charter.sh',
                 'diff-tree -r -z --no-commit-id --name-only --no-renames --diff-filter=MD "${c}^1"',
                 'diff-tree -r --no-commit-id --name-only --no-renames --diff-filter=MD "${c}^1"',
                 {('wire', None): 'wire-diff-line'}),
    'NUL-PAIRS': ('scripts/check_charter.sh',
                  "printf '%s\\0%s\\0' \"$f\" \"frozen/$dir/$NNN/1\"",
                  "printf '%s\\t%s\\n' \"$f\" \"frozen/$dir/$NNN/1\"",
                  {('edit', None): 'out-of-scope'}),
    'NUL-ORACLE': ('scripts/check_charter.sh',
                   "while IFS= read -r -d '' dp; do", 'while IFS= read -r dp; do',
                   {('edit', None): 'lost-events'}),
    'NUL-FAST': ('scripts/check_charter.sh', '__ch_p="$__ch_line"',
                 '__ch_p="${__ch_line%%$\'\\n\'*}"', {('edit', None): 'lost-events'}),
    'NUL-RING': ('.githooks/pre-push', "while IFS= read -r -d '' f; do\n      [ -n \"$f\" ]",
                 'while IFS= read -r f; do\n      [ -n "$f" ]', {('edit', None): 'lost-events'}),
    'NUL-OWNER': ('.githooks/pre-push',
                  'diff-tree -z --root --no-commit-id --name-only -r "$c" -- docs/owner/',
                  'diff-tree --root --no-commit-id --name-only -r "$c" -- docs/owner/',
                  {('wire', None): 'wire-owner-line'}),
    'NUL-OWNER-READ': ('.githooks/pre-push',
                       "      while IFS= read -r -d '' f; do",
                       '      while IFS= read -r f; do',
                       {('wire', None): 'wire-empty'}),
    'NUL-HEAD': ('reader-model.sh', 'ls-tree -r -z --name-only HEAD',
                 'ls-tree -r --name-only HEAD', {('wire', None): 'wire-zero'}),
    'NUL-HISTORY': ('reader-model.sh', 'log -z --all --diff-filter=A',
                    'log --all --diff-filter=A', {('wire', None): 'wire-zero'}),
    'NUL-BACKFILL': ('reader-model.sh', 'find "$root/contracts/" -type f -print0',
                     'find "$root/contracts/" -type f -print', {('wire', None): 'wire-empty'}),
    'NUL-FROZEN': ('reader-model.sh', "while IFS= read -r -d '' df; do\n      [ -n \"$df\" ] || continue\n      if",
                   'while IFS= read -r df; do\n      [ -n "$df" ] || continue\n      if',
                   {('wire', None): 'wire-frozen-clean'}),
    'NUL-ZONES': ('reader-model.sh', "while IFS= read -r -d '' df; do\n      [ -n \"$df\" ] || continue\n      case",
                  'while IFS= read -r df; do\n      [ -n "$df" ] || continue\n      case',
                  {('wire', None): 'wire-zones-clean'}),
    **{f'NUL-167-{array.upper()}': (
        '.githooks/pre-push',
        f'  git -C "$ROOT" diff -z --no-renames --name-only {args} > "$paths_167" || {{ rm -f "$paths_167"; return 1; }}\n'
        f"  mapfile -d '' -t {array} < \"$paths_167\"",
        f'  mapfile -t {array} < <(git -C "$ROOT" diff --no-renames --name-only {args} 2>/dev/null)',
        {('wire', None): 'wire-167-allow' if array in ('d1', 'd2') else 'wire-167-deny'})
       for array, args in (('d1', '"$base" "$p1"'), ('d2', '"$base" "$p2"'),
                           ('cm', '"$p1" "$c"'), ('cm2', '"$p2" "$c"'))},
    'NUL-FROZEN-SCOPE': ('reader-model.sh',
                         "frozen_scope_210() {\n  scope_delimiter_210=''",
                         '''frozen_scope_210() {
  scope_delimiter_210=$'\\n'
  g ls-tree -r --name-only HEAD -- ':(literal)plans/' ':(literal)contracts/' 2>/dev/null | awk '/\\.md$/' | sort > "$TMP/files" || true
  return 0''', {('wire', None): 'wire-scope-missing'}),
    'NUL-ZONES-HEAD-TREE': ('reader-model.sh', 'zones_head_tree_210() {',
                           '''zones_head_tree_210() {
  file_head="$(g ls-tree -r --name-only HEAD -- ':(literal)contracts/' 2>/dev/null | awk -v n="$nnn" 'index($0, "contracts/" n "-") == 1 { print; exit }')"
  body_head=""
  [ -z "$file_head" ] || body_head="$(g cat-file -p "HEAD:$file_head")"
  return 0''', {('wire', None): 'wire-tree-missing'}),
    'NUL-ZONES-FROZEN-TREE': ('reader-model.sh', 'zones_tag_tree_210() {',
                             '''zones_tag_tree_210() {
  file="$(g ls-tree -r --name-only "refs/tags/frozen/contracts/$nnn/$vmax^{commit}" -- ':(literal)contracts/' 2>/dev/null | awk -v n="$nnn" 'index($0, "contracts/" n "-") == 1 { print; exit }')"
  body=""
  [ -z "$file" ] || body="$(g cat-file -p "refs/tags/frozen/contracts/$nnn/$vmax^{commit}:$file")"
  return 0''', {('wire', None): 'wire-tree-missing'}),
    'EMPTY-OLD-REJECTION': ('scripts/check_charter.sh',
                            '''    if [ -n "$__ch_line" ]; then
      bad "пустой или оборванный протокол git log: проверить невозможно"
    elif [ -z "$__ch_c" ]; then
      __ch_pr=0
      __ch_pmatch="$(g log -1 --format=%H --no-renames --diff-filter=MD --diff-merges=first-parent HEAD 2>/dev/null)" || __ch_pr=$?
      if [ "$__ch_pr" -ne 0 ] || [ -n "$__ch_pmatch" ]; then
        bad "пустой или оборванный протокол git log: проверить невозможно"
      fi
    fi''',
                            '''    if [ -z "$__ch_c" ] || [ -n "$__ch_line" ]; then
      bad "пустой или оборванный протокол git log: проверить невозможно"
    fi''',
                            {('empty', None): 'empty-log-rejected'}),
    'EMPTY-ROOT-CACHE': ('scripts/check_charter.sh',
                         '  incr_finish 0\n  exit 0',
                         '  incr_finish 1\n  exit 0',
                         {('empty', None): 'cache-absent'}),
    'NUL-OWNER-CC': ('.githooks/pre-push',
                     'diff-tree -z --cc --no-commit-id --name-only -r "$c" -- docs/owner/',
                     'diff-tree --cc --no-commit-id --name-only -r "$c" -- docs/owner/',
                     {('wire', None): 'wire-owner-merge-lost'}),
    **{f'NUL-167-{array.upper()}-READ': (
        '.githooks/pre-push',
        f"  mapfile -d '' -t {array} < \"$paths_167\"",
        f'  mapfile -t {array} < "$paths_167"',
        {('wire', None): 'wire-167-allow'})
       for array in ('cm', 'cm2')},
    'EMPTY-PROBE-RC-IGNORED': ('scripts/check_charter.sh',
                              'HEAD 2>/dev/null)" || __ch_pr=$?',
                              'HEAD 2>/dev/null)" || true',
                              {('wire', None): 'wire-probe-ignored'}),
    'EMPTY-PROBE-RC-UNCHECKED': ('scripts/check_charter.sh',
                                '[ "$__ch_pr" -ne 0 ] || [ -n "$__ch_pmatch" ]',
                                '[ -n "$__ch_pmatch" ]',
                                {('wire', None): 'wire-probe-ignored'}),
}


def sources(root, model):
    names = ('scripts/check_charter.sh', 'scripts/next_id.sh', 'scripts/lib_registry.sh',
             'scripts/lib_incr.sh', '.githooks/pre-push',
             'scripts/check_contract_frozen.sh', 'scripts/check_zones.sh',
             'scripts/check_staged.sh', 'scripts/lib_zones.sh', 'scripts/mint_line.sh',
             '.githooks/pre-commit')
    result = {}
    for name in names:
        source = root / name
        if model and name in ('scripts/check_charter.sh', '.githooks/pre-push'):
            source = MODEL / Path(name).name
        if not source.is_file():
            raise Prerequisite('SUBJECT_ABSENT: ' + str(source))
        result[name] = source.read_bytes()
    if model:
        result['reader-model.sh'] = (MODEL / 'path_readers.sh').read_bytes()
    return result


def judge(cell, selected, scratch):
    actual, expected = observe(cell, selected, scratch)
    good = actual == expected
    print(f'210 {cell.name} {"ok" if good else "KRASNO"} rc={actual[0]}', flush=True)
    if not good:
        print(f'210 expected={expected!r}\n210 actual={actual!r}', flush=True)
    return good


def stabs(cases, selected, scratch):
    by_name = {c.name: c for c in cases}
    bindings = [tuple(line.split('\t')) for line in (HERE / 'stabs.tsv').read_text().splitlines()
                if line and not line.startswith('#')]
    if not bindings or len(set(bindings)) != len(bindings) or {b[0] for b in bindings} != set(MUTATIONS):
        raise Prerequisite('INVALID_BINDINGS')
    caught = 0
    for name, cell_name in bindings:
        if cell_name not in by_name:
            raise Prerequisite('MISSING_CELL: ' + cell_name)
        cell = by_name[cell_name]
        if not judge(cell, selected, scratch):
            raise Prerequisite('HONEST_CONTROL_RED: ' + cell_name)
        path, anchor, replacement, overrides = MUTATIONS[name]
        raw = selected[path]
        if raw.count(anchor.encode()) != 1:
            raise Prerequisite('ANCHOR_NOT_UNIQUE: ' + name)
        mutant = {**selected, path: raw.replace(anchor.encode(), replacement.encode(), 1)}
        syntax_file = Path(scratch) / 'mutant.sh'
        syntax_file.write_bytes(mutant[path])
        if command(['bash', '-n', syntax_file], cwd=scratch)[0]:
            raise Prerequisite('MUTANT_SYNTAX: ' + name)
        changes = {(commit, path or f'contracts/{cell.number}-{cell.slug}.md'): status
                   for (commit, path), status in overrides.items()}
        actual, expected = observe(cell, mutant, scratch, changes)
        # Exact mutant result, not any crash or arbitrary difference.
        honest_actual, _ = observe(cell, selected, scratch)
        good = actual == expected and actual != honest_actual
        caught += int(good)
        print(f'210 {name} -> {cell_name} {"POIMAN" if good else "ZHIV"}', flush=True)
        if not good:
            print(f'210 mutant_expected={expected!r}\n210 mutant_actual={actual!r}', flush=True)
    alive = len(bindings) - caught
    print(f'ИТОГ 210: MUTACII={len(MUTATIONS)} SVJAZI={len(bindings)} POIMANY={caught} ZHIVYH={alive}', flush=True)
    return int(bool(alive))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=TREE)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--model', action='store_true')
    mode.add_argument('--stabs', action='store_true')
    mode.add_argument('--syntax', action='store_true')
    parser.add_argument('--cell')
    args = parser.parse_args()
    try:
        for binary in ('bash', 'git', 'python3', 'awk', 'sed', 'grep'):
            if not shutil.which(binary):
                raise Prerequisite('LIVE_PREDPOSYLKA: ' + binary)
        if args.syntax:
            for source in (HERE / 'probe.py', HERE / 'transport.py'):
                compile(source.read_bytes(), str(source), 'exec')
            for script in (MODEL / 'check_charter.sh', MODEL / 'pre-push',
                           MODEL / 'path_readers.sh', HERE / 'red_charter_tekst_do_tega_210.sh'):
                actual = command(['bash', '-n', script], cwd=HERE)
                if actual != (0, b'', b''):
                    raise Prerequisite(f'BASH_SYNTAX: {script.name} {actual!r}')
            print('210 SYNTAX: bash=4 python=2')
            return 0
        cases = cells()
        if args.cell:
            cases = [cell for cell in cases if fnmatchcase(cell.name, args.cell)]
        if not cases or len({c.name for c in cases}) != len(cases):
            raise Prerequisite('EMPTY_OR_DUPLICATED_CENSUS')
        selected = sources(args.repo.resolve(), args.model or args.stabs)
        with tempfile.TemporaryDirectory(prefix='battery-210-') as scratch:
            if args.stabs:
                return stabs(cases, selected, scratch)
            green = sum(judge(cell, selected, scratch) for cell in cases)
            red = len(cases) - green
            print(f'ИТОГ 210: KLETKI={len(cases)} ZELENYE={green} KRASNYE={red}', flush=True)
            return int(bool(red))
    except (OSError, Prerequisite) as exc:
        print('NOT_IMPLEMENTED: ' + str(exc), file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
