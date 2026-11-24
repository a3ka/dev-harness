#!/usr/bin/env python3
"""217: empty incremental charter window; real Git, Trace2 JSON, exact bytes.

Model is a small insertion, not a second charter implementation. Compatibility
oracle is the pinned pre-217 production source, loaded before subject execution.
The ordinary histories deliberately need no publication exemption from 210.
"""
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
import time

HERE = Path(__file__).resolve().parent
TREE = HERE.parents[2]
BASE = '4576309b967a22818cd7c2ed0738333dd014ca80'
FILES = ('scripts/check_charter.sh', 'scripts/lib_incr.sh',
         'scripts/next_id.sh', 'scripts/lib_registry.sh')
ANCHOR = b'INCR_GIT_ROOT="$ROOT"\n'
MODEL = HERE / 'model/empty_window.sh'


class Prerequisite(RuntimeError):
    pass


def environment(trace=None):
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    for key in ('BASH_ENV', 'ENV', 'CHARTER_LIB', 'NEXT_ID_LIB', 'LIB_INCR_LOADED',
                'INCR_GIT_ROOT', 'HARNESS_PROJECT_LAYER_ROOT', 'HARNESS_WORKFLOW_ROOT'):
        env.pop(key, None)
    env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               GIT_AUTHOR_NAME='architect', GIT_AUTHOR_EMAIL='architect@dev-harness.local',
               GIT_COMMITTER_NAME='architect', GIT_COMMITTER_EMAIL='architect@dev-harness.local',
               GIT_AUTHOR_DATE='1700000000 +0000', GIT_COMMITTER_DATE='1700000000 +0000',
               LC_ALL='C.UTF-8')
    if trace:
        env['GIT_TRACE2_EVENT'] = str(trace)
    return env


def command(argv, cwd, data=None, timeout=30, trace=None):
    proc = subprocess.Popen(list(map(str, argv)), cwd=cwd, env=environment(trace),
                            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, start_new_session=True)
    start = time.monotonic()
    try:
        out, err = proc.communicate(data, timeout=timeout)
    except subprocess.TimeoutExpired:
        os.killpg(proc.pid, signal.SIGKILL)
        out, err = proc.communicate()
        return (124, out, err), time.monotonic() - start
    return (proc.returncode, out, err), time.monotonic() - start


def git(root, *args, data=None):
    result, _ = command(['git', '-C', root, *args], root, data)
    if result[0]:
        raise Prerequisite(f'GIT_ENVIRONMENT {args!r}: {result!r}')
    return result[1]


def replace(data, anchor, replacement):
    if data.count(anchor) != 1:
        raise Prerequisite(f'ANCHOR_NOT_UNIQUE: {anchor!r}')
    return data.replace(anchor, replacement)


def sources(root, pinned=False):
    result = {}
    for name in FILES:
        result[name] = (git(root, 'show', f'{BASE}:{name}') if pinned
                        else (root / name).read_bytes())
    return result


def model_sources(original):
    result = dict(original)
    result[FILES[0]] = replace(result[FILES[0]], ANCHOR, ANCHOR + b'\n' + MODEL.read_bytes())
    return result


@dataclasses.dataclass(frozen=True)
class Cell:
    name: str
    shape: str = 'clean'
    mode: str = 'incr'
    cache: str = 'base'
    large: bool = False
    empty: bool = False


def cells():
    return [
        Cell('e1-empty-small', empty=True),
        Cell('e2-empty-5000', large=True, empty=True),
        Cell('e3-empty-equals', mode='equals', large=True, empty=True),
        Cell('e4-empty-oracle', mode='oracle-incr', empty=True),
        Cell('e5-empty-old-violation', shape='old', empty=True),
        Cell('w1-denied', shape='denied'),
        Cell('w2-allowed', shape='allowed'),
        Cell('w3-clean'),
        Cell('w4-old-outside-window', shape='old'),
        Cell('w5-late-freeze', shape='late'),
        Cell('w6-late-freeze-denied', shape='late-denied'),
        Cell('w7-oracle-denied', shape='denied', mode='oracle-incr'),
        Cell('w8-oracle-allowed', shape='allowed', mode='oracle-incr'),
        Cell('c1-missing-denied', shape='denied', cache='missing'),
        Cell('c2-missing-clean', cache='missing'),
        Cell('c3-unknown-denied', shape='denied', cache='unknown'),
        Cell('c4-unknown-clean', cache='unknown'),
        Cell('c5-foreign-denied', shape='denied', cache='foreign'),
        Cell('c6-foreign-clean', cache='foreign'),
        Cell('c7-broken', cache='broken'),
        Cell('c8-empty-cache', cache='empty'),
        Cell('f1-fast-denied', shape='denied', mode='fast'),
        Cell('f2-fast-allowed', shape='allowed', mode='fast'),
        Cell('f3-oracle-denied', shape='denied', mode='oracle'),
        Cell('f4-oracle-allowed', shape='allowed', mode='oracle'),
    ]


def seed(root, count, documents):
    root.mkdir()
    git(root, 'init', '-q', '-b', 'main')
    files = {'AGENTS.md': b'# charter\n', 'ROADMAP.md': b'# roadmap\n'}
    files.update({f'contracts/{800+i:03d}-fixture.md': b'# frozen\n'
                  for i in range(documents)})
    stream = bytearray()
    for n in range(count):
        message = f'fixture {n}\n'.encode()
        stream += (b'commit refs/heads/main\n' +
                   f'mark :{n+1}\n'.encode() +
                   b'committer architect <architect@dev-harness.local> 1700000000 +0000\n' +
                   f'data {len(message)}\n'.encode() + message)
        if n == 0:
            for name, body in files.items():
                stream += f'M 100644 inline {name}\ndata {len(body)}\n'.encode() + body
        stream += b'\n'
    git(root, 'fast-import', '--quiet', data=bytes(stream))
    git(root, 'reset', '--hard', '-q', 'HEAD')
    first = git(root, 'rev-list', '--max-parents=0', 'HEAD').decode().strip()
    git(root, 'tag', '-a', 'ustav/1', first, '-m', 'fixture charter')
    for i in range(documents):
        git(root, 'tag', '-a', f'frozen/contracts/{800+i:03d}/1', first, '-m', 'fixture freeze')
    actual = int(git(root, 'rev-list', '--count', 'HEAD'))
    if actual != count:
        raise Prerequisite(f'HISTORY_CENSUS: {actual} != {count}')
    print(f'HISTORY commits={actual} documents={len(files)}', flush=True)


class World:
    def __init__(self, directory, template, cell):
        self.root = directory / 'world'
        git(template, 'clone', '-q', '--local', '--no-hardlinks', template, self.root)
        # The seed is not an authority: remove the clone's source remote.
        git(self.root, 'remote', 'remove', 'origin')
        self.cache = directory / 'cache'
        self.cell = cell
        if cell.shape == 'old':
            self.commit('AGENTS.md', b'old unsanctioned\n')
        self.base = git(self.root, 'rev-parse', 'HEAD').decode().strip()
        if not cell.empty:
            if cell.shape in ('denied', 'allowed'):
                self.commit('AGENTS.md', b'new charter\n', cell.shape == 'allowed')
            elif cell.shape.startswith('late'):
                self.commit('contracts/850-late.md', b'draft\n')
                self.commit('contracts/850-late.md', b'draft revised\n')
                git(self.root, 'tag', '-a', 'frozen/contracts/850/1', '-m', 'late freeze')
                if cell.shape == 'late-denied':
                    self.commit('contracts/850-late.md', b'forbidden after freeze\n')
            else:
                self.commit('ordinary.txt', b'ordinary code\n')
        self.head = git(self.root, 'rev-parse', 'HEAD').decode().strip()
        value = (self.base + '\n').encode()
        if cell.cache == 'unknown':
            value = b'a' * 40 + b'\n'
        elif cell.cache == 'foreign':
            tree = git(self.root, 'rev-parse', 'HEAD^{tree}').strip()
            value = git(self.root, 'commit-tree', tree.decode(), data=b'foreign root\n')
        elif cell.cache == 'broken':
            value = b'not-a-sha\n'
        elif cell.cache == 'empty':
            value = b''
        if cell.cache != 'missing':
            self.cache.write_bytes(value)
        self.original_cache = None if cell.cache == 'missing' else value

    def commit(self, path, body, allowed=False):
        target = self.root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(body)
        git(self.root, 'add', '--', path)
        msg = 'fixture edit\n'
        if allowed:
            msg += f'\nРАЗРЕШИЛ-ВЛАДЕЛЕЦ: {path} synthetic fixture only\n'
        git(self.root, '-c', 'core.hooksPath=/dev/null', 'commit', '-q', '-m', msg)

    def install(self, selected):
        for name, data in selected.items():
            target = self.root / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)

    def run(self, selected, trace=None, limit=30):
        self.install(selected)
        argv = ['bash', self.root / FILES[0]]
        if self.cell.mode.startswith('oracle'):
            argv += ['--oracle']
        if self.cell.mode not in ('fast', 'oracle'):
            argv += ([f'--incr={self.cache}'] if self.cell.mode == 'equals'
                     else ['--incr', self.cache])
        argv += [self.root]
        return command(argv, self.root, trace=trace, timeout=limit)

    def restore_cache(self):
        if self.original_cache is None:
            self.cache.unlink(missing_ok=True)
        else:
            self.cache.write_bytes(self.original_cache)


def trace_commands(path):
    if not path.is_file():
        raise Prerequisite('TRACE2_ABSENT')
    events = [json.loads(row) for row in path.read_bytes().splitlines()]
    starts = [event['argv'] for event in events if event.get('event') == 'start']
    if not starts or not any('rev-parse' in argv for argv in starts):
        raise Prerequisite('TRACE2_EMPTY_OR_INCOMPLETE')
    return starts


def observe(cell, selected, baseline, scratch, templates, mutant_rc=None):
    with tempfile.TemporaryDirectory(prefix=cell.name + '-', dir=scratch) as tmp:
        directory = Path(tmp)
        w = World(directory, templates[cell.large], cell)
        # Independent compatibility oracle, observed BEFORE the subject. This is
        # the historical door, never files reread from subject-controlled disk.
        if cell.empty:
            marker = (f'incr: check_charter судит {w.base[:8]}..{w.head[:8]} '
                      '(0 коммитов)\n').encode()
            expected = (0, b'', marker)
        else:
            expected, _ = w.run(baseline)
            if expected[0] not in (0, 1):
                raise Prerequisite(f'BASELINE_ENVIRONMENT {cell.name}: {expected!r}')
            # Check the oracle against independent semantic rc, not itself.
            deny = cell.shape in ('denied', 'late-denied') or cell.cache in ('broken', 'empty')
            if expected[0] != int(deny):
                raise Prerequisite(f'BASELINE_SEMANTICS {cell.name}: {expected!r}')
        expected_cache = (None if cell.mode in ('fast', 'oracle') and w.original_cache is None
                          else w.original_cache)
        if cell.mode not in ('fast', 'oracle') and expected[0] == 0:
            expected_cache = (w.head + '\n').encode()
        w.restore_cache()
        before_head = git(w.root, 'rev-parse', 'HEAD')
        before_index = git(w.root, 'ls-files', '--stage')
        trace = directory / 'trace.json'
        actual, elapsed = w.run(selected, trace=trace, limit=2 if cell.empty else 30)
        if mutant_rc is not None and actual[0] != mutant_rc:
            raise Prerequisite(f'MUTANT_NOT_REACHED {cell.name}: expected rc {mutant_rc}, actual={actual!r}')
        after_cache = w.cache.read_bytes() if w.cache.exists() else None
        errors = []
        if actual != expected:
            errors.append(f'BYTES expected={expected!r} actual={actual!r}')
        if after_cache != expected_cache:
            errors.append(f'CACHE expected={expected_cache!r} actual={after_cache!r}')
        if git(w.root, 'rev-parse', 'HEAD') != before_head or git(w.root, 'ls-files', '--stage') != before_index:
            raise Prerequisite('SUBJECT_MUTATED_GIT_WORLD: ' + cell.name)
        calls = trace_commands(trace) if cell.empty or trace.exists() else []
        forbidden = [argv for argv in calls if any(op in argv for op in ('ls-tree', 'log', 'for-each-ref'))]
        if cell.empty and forbidden:
            errors.append(f'EMPTY_DISCOVERY: {forbidden!r}')
        if cell.empty and (elapsed > 2 or actual[0] == 124):
            errors.append('EMPTY_BUDGET_EXCEEDED')
        print(f'{cell.name}: rc={actual[0]} seconds={elapsed:.3f} '
              f'git={len(calls)} discovery={len(forbidden)} '
              f'{"RED" if errors else "GREEN"}', flush=True)
        for error in errors:
            print('  ' + error, flush=True)
        return not errors


# Each mutation changes real executed code. Bindings are data, not prose.
MUTATIONS = {
    'NO_SHORTCUT': ('door', MODEL.read_bytes(), b'\n'),
    'ALL_WINDOWS': ('door', b'[ "$INCR_BASE" = "$INCR_HEAD" ]', b'[ -n "$INCR_HEAD" ]'),
    'FULL_TOO': ('door', b'[ "${INCR_MODE:-full}" = "incr" ] && [ "$INCR_BASE" = "$INCR_HEAD" ]', b'true'),
    'CACHE_CORRUPT': ('block', b'  incr_finish 0\n', b'  printf stale > "$INCR_CACHE"\n'),
    'NO_FINISH': ('lib', b'  local rc="$1"\n', b'  local rc="$1"\n  return 0\n'),
    'FAIL_EMPTY': ('block', b'  exit 0\n', b'  exit 1\n'),
    'DOCUMENT_WALK': ('block', b'  incr_finish 0\n', b'  git -C "$ROOT" ls-tree -r --name-only HEAD >/dev/null\n  incr_finish 0\n'),
    'TAG_LOG': ('block', b'  incr_finish 0\n', b'  git -C "$ROOT" log --format=%H ustav/1..HEAD >/dev/null\n  incr_finish 0\n'),
    'NO_MARKER': ('lib', '  printf \'incr: %s судит %s..%s (%s)\\n\' \\\n'.encode(), b'  printf \'altered: %s %s %s (%s)\\n\' \\\n'),
    'WRONG_COUNT': ('lib', b'"$(_incr_plural "$INCR_N")"', b'"$(_incr_plural 1)"'),
    'INVALID_CLEAN': ('door', b'[ "$INCR_RC" -eq 0 ] || { incr_fail; exit 1; }', b'[ "$INCR_RC" -eq 0 ] || exit 0'),
    'UNKNOWN_CLEAN': ('lib', '    INCR_MODE="full"\n    printf \'incr: %s полный прогон (база'.encode(), '    exit 0\n    printf \'incr: %s полный прогон (база'.encode()),
    'MISSING_CLEAN': ('lib', '    INCR_MODE="full"\n    printf \'incr: %s полный прогон (кеш отсутствует)'.encode(), '    exit 0\n    printf \'incr: %s полный прогон (кеш отсутствует)'.encode()),
    'SLOW_EMPTY': ('block', b'  incr_finish 0\n', b'  sleep 3\n  incr_finish 0\n'),
}


def bindings():
    rows = [row.split('\t') for row in (HERE / 'stabs.tsv').read_text().splitlines()[1:]]
    names = {cell.name for cell in cells()}
    if not rows or any(len(row) != 2 or row[0] not in MUTATIONS or row[1] not in names for row in rows):
        raise Prerequisite('STABS_CENSUS')
    if {row[0] for row in rows} != set(MUTATIONS) or len({tuple(r) for r in rows}) != len(rows):
        raise Prerequisite('STABS_COVERAGE')
    return rows


def context(root):
    program = '''set -euo pipefail
. "$1/scripts/lib_zones.sh"
LIB_ZONES_ROOT="$1"
trap '__lib_zones_cleanup' EXIT
d="$(zones_load "$1")"
cat "$d/zones_scoped"
'''
    result, _ = command(['bash', '-c', program, 'context-217', root], root, timeout=90)
    if result[0]:
        raise Prerequisite(f'ZONE_UNION: {result!r}')
    targets = ['scripts/check_charter.sh', 'scripts/lib_incr.sh',
               'contracts/217-incr-pustoe-okno.md',
               'fixtures/workshop_project/incr_pustoe_okno_217/',
               'registry/ci-steps.tsv', 'registry/ci-zamery.tsv', '.github/workflows/ci.yml']
    for row in result[1].decode().splitlines():
        author, path, number = row.split('\t')
        if any(target == path or (path.endswith('/') and target.startswith(path)) for target in targets):
            print(row)
    tags = git(root, 'tag', '--list', 'frozen/contracts/*').decode().splitlines()
    for number in ('019', '022', '046', '065', '083', '113', '200', '207', '210', '992'):
        choices = [t for t in tags if t.startswith(f'frozen/contracts/{number}/')]
        tag = max(choices, key=lambda t: int(t.rsplit('/', 1)[1]))
        commit = git(root, 'rev-parse', f'{tag}^{{commit}}').decode().strip()
        paths = git(root, 'ls-tree', '-r', '--name-only', tag, '--', 'contracts').decode().splitlines()
        path = next(p for p in paths if p.startswith(f'contracts/{number}-'))
        body = git(root, 'show', f'{tag}^{{commit}}:{path}').decode()
        print(f'FROZEN {tag} {commit} {path}')
        for line in body.splitlines():
            if line.startswith('ЗОНА ') and any(t in line for t in targets):
                print(line)
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--repo', type=Path, default=TREE)
    mode = ap.add_mutually_exclusive_group()
    for name in ('model', 'stabs', 'syntax', 'catalog', 'context'):
        mode.add_argument('--' + name, action='store_true')
    ap.add_argument('--live', action='store_true')
    ap.add_argument('--cell')
    args = ap.parse_args()
    root = args.repo.resolve()
    try:
        for binary in ('git', 'bash', 'python3'):
            if not shutil.which(binary):
                raise Prerequisite('BINARY_ABSENT: ' + binary)
        if args.context:
            return context(root)
        rows = bindings()
        if args.catalog:
            print(f'KLETKI={len(cells())} MUTACII={len(MUTATIONS)} SVJAZI={len(rows)}')
            for mutation, cell in rows:
                print(f'{mutation} -> {cell}')
            return 0
        if args.syntax:
            compile(Path(__file__).read_bytes(), str(__file__), 'exec')
            for script in (MODEL, HERE / 'red_incr_pustoe_okno_217.sh'):
                result, _ = command(['bash', TREE / 'scripts/validate_std.sh', 'bash', script], TREE)
                if result != (0, b'', b''):
                    raise Prerequisite(f'BASH_VALIDATION: {script}: {result!r}')
            print('SYNTAX bash=2 python=1 rc=0')
            return 0
        baseline = sources(root, pinned=True)
        selected = model_sources(baseline) if args.model or args.stabs else sources(root)
        with tempfile.TemporaryDirectory(prefix='incr-217-') as tmp:
            scratch = Path(tmp)
            if args.live:
                # A private clone of real history; no writes to the supplied tree.
                live = scratch / 'live'
                git(root, 'clone', '-q', '--local', '--no-hardlinks', '--no-checkout', root, live)
                w = World.__new__(World)
                w.root, w.cache = live, scratch / 'cache'
                w.cell = Cell('live', empty=True)
                head = git(live, 'rev-parse', 'HEAD').decode().strip()
                w.cache.write_text(head + '\n')
                expected = (0, b'', f'incr: check_charter судит {head[:8]}..{head[:8]} (0 коммитов)\n'.encode())
                actual, elapsed = w.run(selected, limit=2)
                count = int(git(live, 'rev-list', '--count', 'HEAD'))
                good = actual == expected and elapsed <= 2 and w.cache.read_text() == head + '\n'
                print(f'LIVE commits={count} seconds={elapsed:.3f} rc={actual[0]} bytes={actual!r}')
                return int(not good)
            templates = {False: scratch / 'small', True: scratch / 'large'}
            seed(templates[False], 1, 1)
            seed(templates[True], 5000, 24)
            cases = [cell for cell in cells() if not args.cell or cell.name == args.cell]
            if not cases:
                raise Prerequisite('EMPTY_CENSUS')
            if args.stabs:
                by_name = {c.name: c for c in cases}
                caught = 0
                for name, cell_name in rows:
                    cell = by_name[cell_name]
                    if not observe(cell, selected, baseline, scratch, templates):
                        raise Prerequisite('HONEST_CONTROL_RED: ' + cell_name)
                    which, anchor, replacement = MUTATIONS[name]
                    path = FILES[1 if which == 'lib' else 0]
                    mutant = dict(selected)
                    if which == 'block':
                        block = MODEL.read_bytes()
                        mutant[path] = replace(mutant[path], block, replace(block, anchor, replacement))
                    else:
                        mutant[path] = replace(mutant[path], anchor, replacement)
                    rc = {'FAIL_EMPTY': 1, 'SLOW_EMPTY': 124}.get(name, 0)
                    dead = not observe(cell, mutant, baseline, scratch, templates, mutant_rc=rc)
                    caught += dead
                    print(f'{name} -> {cell_name}: {"POIMAN" if dead else "ZHIV"}', flush=True)
                print(f'MUTACII={len(MUTATIONS)} SVJAZI={len(rows)} POIMANY={caught} ZHIVYH={len(rows)-caught}')
                return int(caught != len(rows))
            green = sum(observe(cell, selected, baseline, scratch, templates) for cell in cases)
            print(f'KLETKI={len(cases)} ZELENYE={green} KRASNYE={len(cases)-green}')
            return int(green != len(cases))
    except (OSError, ValueError, KeyError, Prerequisite) as exc:
        print('NOT_IMPLEMENTED: ' + str(exc), file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
