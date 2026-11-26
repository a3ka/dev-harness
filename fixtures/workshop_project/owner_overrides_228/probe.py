#!/usr/bin/env python3
"""228: real Bash API, literal migration oracle, real Git CLI worlds."""
import ast
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
import build

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SCRATCH = ROOT / 'tmp/scratch-arch228'
SCRATCH.mkdir(parents=True, exist_ok=True)
SOURCE = json.loads((HERE / 'source.json').read_text())
ENV = dict(os.environ, TMPDIR=str(SCRATCH), GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
           GIT_AUTHOR_NAME='fixture', GIT_AUTHOR_EMAIL='fixture@example.invalid',
           GIT_COMMITTER_NAME='fixture', GIT_COMMITTER_EMAIL='fixture@example.invalid',
           GIT_AUTHOR_DATE=SOURCE['worlds']['date'], GIT_COMMITTER_DATE=SOURCE['worlds']['date'])
for k in ('GIT_DIR', 'GIT_WORK_TREE', 'GIT_INDEX_FILE', 'GIT_OBJECT_DIRECTORY', 'GIT_ALTERNATE_OBJECT_DIRECTORIES', 'GITHUB_EVENT_NAME', 'BASH_ENV', 'ENV'):
    ENV.pop(k, None)
BASELINE = json.loads((HERE / 'baseline.json').read_text())
ROWS = tuple(tuple(r) for r in BASELINE['rows'])
GATES = build.GATES
CODE = 'source "$1"; ROOT="$2"; shift 2; owner_override_has "$@"'


def run(argv, cwd=None, data=None):
    p = subprocess.run([str(a) for a in argv], cwd=cwd, input=data, stdout=subprocess.PIPE,
                       stderr=subprocess.PIPE, env=ENV, timeout=SOURCE['runner']['timeout_seconds'])
    if p.returncode < 0 or p.returncode in (126, 127):
        raise RuntimeError('SUBJECT_TOOL_FAILURE: ' + repr((argv, p.returncode, p.stderr)))
    if b'Traceback (most recent call last)' in p.stderr or b'SyntaxError:' in p.stderr or b'syntax error near unexpected token' in p.stderr:
        raise RuntimeError('SUBJECT_SYNTAX_OR_CRASH: ' + repr(p.stderr))
    return p.returncode, p.stdout, p.stderr


def git(repo, *args, data=None):
    rc, out, err = run(['git', '-C', repo, *args], data=data)
    if rc:
        raise RuntimeError('GIT: ' + repr((args, rc, err)))
    return out.decode().strip()


def put(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data.encode() if isinstance(data, str) else data)


def registry(rows):
    return ''.join('\t'.join(r) + '\n' for r in rows).encode()


def materialize(dest, model=False, mutation=None, repo=ROOT):
    scripts = dest / 'scripts'
    scripts.mkdir(parents=True)
    # Dependencies are from the candidate; reference replaces only its four doors.
    for path in (repo / 'scripts').iterdir():
        if path.is_file() and path.suffix in ('.sh', '.py'):
            shutil.copyfile(path, scripts / path.name)
            (scripts / path.name).chmod(path.stat().st_mode)
    # env-i in the real doors intentionally drops inherited TMPDIR. Constrain
    # only dependency scratch allocation, equally for baseline/model/candidate.
    for name in ('lib_registry.sh', 'lib_zones.sh', 'next_id.sh'):
        dependency = scripts / name
        first, rest = dependency.read_text().split('\n', 1)
        put(dependency, first + '\nexport TMPDIR=' + shlex.quote(str(SCRATCH)) + '\n' + rest)
    if model:
        texts, rows, library = build.reference()
        for name, text in texts.items():
            put(scripts / (name + '.sh'), text)
        put(scripts / 'lib_owner.sh', library)
        put(dest / 'registry/owner-overrides.tsv', registry(rows))
    elif (repo / 'registry/owner-overrides.tsv').is_file():
        put(dest / 'registry/owner-overrides.tsv', (repo / 'registry/owner-overrides.tsv').read_bytes())
    if mutation:
        for delta in mutation.get('edits', [mutation]):
            target = dest / delta['file']
            text = target.read_text()
            old = delta['old']
            if text.count(old) != 1:
                raise RuntimeError('STAB_ANCHOR: ' + mutation['name'])
            put(target, text.replace(old, delta['new'], 1))
    return dest


def lookup(subject, world, key, sha, path=None, author=None):
    lib = subject / 'scripts/lib_owner.sh'
    if not lib.is_file():
        return 1, b'', b'OWNER_INTERFACE_ABSENT\n'
    args = [key, sha]
    if path is not None:
        args.append(path)
    if author is not None:
        args.append(author)
    return run(['bash', '-c', CODE, 'lookup228', lib, world, *args])


def new_world(path):
    path.mkdir()
    git(path, 'init', '-q')
    git(path, 'config', 'user.name', 'fixture')
    git(path, 'config', 'user.email', 'fixture@example.invalid')
    put(path / 'AGENTS.md', 'charter\n')
    put(path / 'ROADMAP.md', 'roadmap\n')
    put(path / 'roles/critic.md', '---\nverdict: verdicts/critic/\n---\n')
    put(path / 'verdicts/critic/keep.md', 'accept\n')
    put(path / 'verdicts/critic/contracts-001-v1.md', 'accept\n')
    put(path / 'contracts/001-fixture.md', '# Fixture\nЗОНА architect: allowed.txt\nЗОНА fixture: allowed.txt\nЗОНА orchestrator: allowed.txt\n')
    put(path / 'registry/contracts.tsv', '')
    put(path / 'allowed.txt', 'allowed\n')
    commit(path, 'initial')
    git(path, 'tag', '-a', 'ustav/1', '-m', 'fixture charter')
    git(path, 'tag', '-a', 'frozen/contracts/001/1', '-m', 'fixture zones')
    return git(path, 'rev-parse', 'HEAD')


def commit(world, body):
    git(world, 'add', '-A')
    tree = git(world, 'write-tree')
    parent = run(['git', '-C', world, 'rev-parse', '--verify', 'HEAD'])[1].decode().strip()
    args = ['commit-tree', tree]
    if re.fullmatch('[0-9a-f]{40}', parent):
        args += ['-p', parent]
    sha = git(world, *args, data=body.encode())
    git(world, 'update-ref', 'HEAD', sha)
    return sha


def cli(subject, world, gate, extra=()):
    return run(['bash', subject / 'scripts' / (gate + '.sh'), *extra, world], cwd=world)


def check(condition, detail):
    return bool(condition), detail


def matrix(subject, work):
    world = work / 'matrix'
    new_world(world)
    candidate_registry = subject / 'registry/owner-overrides.tsv'
    put(world / 'registry/owner-overrides.tsv', candidate_registry.read_bytes() if candidate_registry.is_file() else b'')
    mismatches = []
    queries = BASELINE['matrix']
    for item in queries:
        got = lookup(subject, world, *item['args'])
        expected = (item['rc'], item['stdout'].encode(), item['stderr'].encode())
        if got != expected:
            mismatches.append((item['args'], got, expected))
    return check(not mismatches, f'queries={len(queries)} mismatches={len(mismatches)} first={mismatches[:1]!r}')


def raw_case(subject, work, variant):
    world = work / variant
    new_world(world)
    row = ['check_charter/grandfather', 'abcdef0123456789' * 2 + 'abcdef01', 'AGENTS.md', '*', 'R-0114', 'never']
    good = registry([row])
    data = good
    key = row[0]
    sha = row[1]
    path = row[2]
    author = 'fixture'
    expect = 0
    diagnostic = None
    if variant == 'missing':
        data = None
        expect = 1
    elif variant == 'empty':
        data = b''
        expect = 1
    elif variant == 'not-listed':
        sha = 'f' * 40
        expect = 1
    elif variant == 'prefix-query':
        sha = sha[:12]
        expect = 2
        diagnostic = 'argument'
    elif variant == 'upper-query':
        sha = sha.upper()
        expect = 2
        diagnostic = 'argument'
    elif variant == 'long-query':
        sha += 'a'
        expect = 2
        diagnostic = 'argument'
    elif variant == 'wrong-path':
        path = 'AGENTS.md.extra'
        expect = 1
    elif variant == 'regex-path':
        path = 'AGENTSxmd'
        expect = 1
    elif variant == 'wrong-door':
        key = 'check_protected/delete'
        expect = 1
    elif variant == 'wrong-author':
        row[3] = 'architect'
        data = registry([row])
        author = 'orchestrator'
        expect = 1
    elif variant == 'unknown-query':
        key = 'check_charter'
        expect = 2
        diagnostic = 'argument'
    elif variant == 'expired':
        row[-1] = SOURCE['worlds']['expired']
        data = registry([row])
        expect = 1
    elif variant == 'future':
        row[-1] = SOURCE['worlds']['future_expiry']
        data = registry([row])
    elif variant == 'prefix-scope':
        row[2] = 'fixtures/data/*'
        data = registry([row])
        path = 'fixtures/data/sub/value.txt'
    elif variant == 'prefix-scope-sibling':
        row[2] = 'fixtures/data/*'
        data = registry([row])
        path = 'fixtures/database/value.txt'
        expect = 1
    elif variant.startswith('bad-'):
        bad = {
            'bad-fields': b'broken\n', 'bad-nul': good[:-1] + b'\0\n',
            'bad-crlf': good.replace(b'\n', b'\r\n'), 'bad-space': good.replace(b'\t', b' ', 1),
            'bad-uppercase': good.replace(row[1].encode(), row[1].upper().encode()),
            'bad-prefix': good.replace(row[1].encode(), row[1][:12].encode()),
            'bad-unknown': good.replace(row[0].encode(), b'unknown'),
            'bad-reason': good.replace(b'R-0114', b'R-11'),
            'bad-expiry': good.replace(b'never', b'2026-02-30'),
            'bad-path': good.replace(b'AGENTS.md', b'../AGENTS.md'),
            'bad-path-trailing': good.replace(b'AGENTS.md', b'folder/'),
            'bad-path-prefix-empty': good.replace(b'AGENTS.md', b'folder//*'),
            'bad-no-lf': good[:-1], 'bad-duplicate': good + good,
            'bad-tail': good + b'broken\n', 'bad-blank': good + b'\n',
        }[variant]
        data = bad
        expect = 2
        diagnostic = '2' if variant in ('bad-tail', 'bad-duplicate', 'bad-blank') else '1'
    if data is not None:
        put(world / 'registry/owner-overrides.tsv', data)
    before = git(world, 'rev-parse', 'HEAD')
    got = lookup(subject, world, key, sha, path, author)
    ok = got[0] == expect and not got[1]
    if diagnostic:
        ok &= b'OWNER_OVERRIDES_INVALID: registry/owner-overrides.tsv:' + diagnostic.encode() + b':' in got[2]
    else:
        ok &= not got[2]
    ok &= git(world, 'rev-parse', 'HEAD') == before
    return check(ok, repr(got))


RAW = ('listed', 'missing', 'empty', 'not-listed', 'prefix-query', 'upper-query', 'long-query', 'wrong-path', 'regex-path',
       'wrong-door', 'wrong-author', 'unknown-query', 'expired', 'future', 'prefix-scope', 'prefix-scope-sibling',
       'bad-fields', 'bad-nul', 'bad-crlf', 'bad-space', 'bad-uppercase', 'bad-prefix', 'bad-unknown',
       'bad-reason', 'bad-expiry', 'bad-path', 'bad-path-trailing', 'bad-path-prefix-empty',
       'bad-no-lf', 'bad-duplicate', 'bad-tail', 'bad-blank')


def authority(subject, work, mode):
    world = work / mode
    new_world(world)
    if mode.startswith('delete'):
        put(world / 'registry/owner-overrides.tsv', b'')
        commit(world, 'approval\n\nРАЗРЕШИЛ-ВЛАДЕЛЕЦ: registry/owner-overrides.tsv fixture approval\n')
    put(world / 'registry/owner-overrides.tsv', registry([ROWS[0]]))
    if mode.startswith('delete'):
        (world / 'registry/owner-overrides.tsv').unlink()
    body = 'unauthorized\n'
    allowed = mode.endswith('-allowed')
    if allowed:
        body += '\nРАЗРЕШИЛ-ВЛАДЕЛЕЦ: registry/owner-overrides.tsv fixture approval\n'
    elif mode == 'authority-other-path':
        body += '\nРАЗРЕШИЛ-ВЛАДЕЛЕЦ: AGENTS.md fixture approval\n'
    sha = commit(world, body)
    if mode == 'authority-self':
        # A grant claiming the carrier itself must not become its approval.
        put(world / 'registry/owner-overrides.tsv', registry([
            ['check_charter/grandfather', sha, 'registry/owner-overrides.tsv', '*', 'R-0114', 'never']]))
    results = [cli(subject, world, 'check_charter', opts) for opts in ((), ('--oracle',))]
    expected = 0 if allowed else 1
    ok = all(r[0] == expected and not r[1] for r in results)
    if not allowed:
        ok &= all('без разрешения владельца: registry/owner-overrides.tsv'.encode() in r[2] for r in results)
    return check(ok, repr(results))


def integration(subject, work, mode):
    world = work / mode
    new_world(world)
    gate = mode.split(':')[0]
    allow = mode.endswith(':allow')
    if gate == 'check_charter':
        put(world / 'AGENTS.md', 'changed\n')
        path = 'AGENTS.md'
        key = 'check_charter/grandfather'
    elif gate == 'check_protected':
        (world / 'verdicts/critic/keep.md').unlink()
        path = 'verdicts/critic/keep.md'
        key = 'check_protected/delete'
    elif gate == 'check_zones':
        put(world / 'outside.txt', 'outside\n')
        path = 'outside.txt'
        key = 'check_zones/process'
    else:
        raise RuntimeError(mode)
    sha = commit(world, 'subject delta\n')
    row = [key, sha if allow else 'e' * 40, path, '*', 'R-0114', 'never']
    put(world / 'registry/owner-overrides.tsv', registry([row]))
    before = git(world, 'rev-parse', 'HEAD')
    got = cli(subject, world, gate)
    ok = got[0] == (0 if allow else 1)
    reason = {'check_charter': 'без разрешения владельца: AGENTS.md',
              'check_protected': 'защищённый артефакт существовал', 'check_zones': 'коммит вне зоны:'}[gate].encode()
    if not allow:
        ok &= reason in got[2]
    ok &= git(world, 'rev-parse', 'HEAD') == before
    return check(ok, repr(got))


def frozen(subject, work, allow):
    world = work / ('frozen-allow' if allow else 'frozen-deny')
    new_world(world)
    put(world / 'contracts/148-fixture.md', '# Frozen\n')
    for n in range(1, 6):
        put(world / f'verdicts/critic/contracts-148-v{n}.md', 'accept\n')
    commit(world, 'frozen history\n')
    for n in (1, 2, 3, 5):
        git(world, 'tag', '-a', f'frozen/contracts/148/{n}', '-m', 'fixture freeze')
    row = ['check_contract_frozen/skip-version', '-', 'contracts/148/4' if allow else 'contracts/149/4', '*', 'R-0114', 'never']
    put(world / 'registry/owner-overrides.tsv', registry([row]))
    got = cli(subject, world, 'check_contract_frozen')
    ok = got[0] == (0 if allow else 1)
    if not allow:
        ok &= 'версия v4 пропущена'.encode() in got[2]
    return check(ok, repr(got))


def literals(subject):
    found = []
    for gate in GATES:
        path = subject / 'scripts' / (gate + '.sh')
        code = '\n'.join(l for l in path.read_text().splitlines() if not l.lstrip().startswith('#'))
        if re.search(r'\b[0-9a-f]{40}\b', code):
            found.append(gate)
    return check(not found, repr(found))


def malformed_cli(subject, work, gate):
    world = work / ('malformed-' + gate)
    new_world(world)
    put(world / 'registry/owner-overrides.tsv', b'broken\n')
    got = cli(subject, world, gate)
    return check(got[0] == 1 and b'OWNER_OVERRIDES_INVALID: registry/owner-overrides.tsv:1:' in got[2], repr(got))


def cells():
    result = {'migration-matrix': matrix, 'no-sha-literals': lambda s, w: literals(s)}
    for mode in RAW:
        result[mode] = lambda s, w, m=mode: raw_case(s, w, m)
    for mode in ('authority-add', 'authority-add-allowed', 'authority-other-path', 'authority-self', 'delete-denied', 'delete-allowed'):
        result[mode] = lambda s, w, m=mode: authority(s, w, m)
    for gate in GATES:
        if gate != 'check_contract_frozen':
            for polarity in ('allow', 'deny'):
                mode = gate + ':' + polarity
                result[mode] = lambda s, w, m=mode: integration(s, w, m)
    result['frozen-allow'] = lambda s, w: frozen(s, w, True)
    result['frozen-deny'] = lambda s, w: frozen(s, w, False)
    for gate in GATES:
        result['malformed:' + gate] = lambda s, w, g=gate: malformed_cli(s, w, g)
    return result


def execute(subject, selected, verbose=True):
    results = {}
    with tempfile.TemporaryDirectory(prefix='worlds-', dir=SCRATCH) as tmp:
        for name in selected:
            ok, detail = cells()[name](subject, Path(tmp))
            results[name] = ok
            if verbose:
                print(('ZELENO ' if ok else 'KRASNO ') + name + ('' if ok else ': ' + detail))
    return results


def capture_matrix():
    texts, rows, indices = build.extracted()
    a, b, c, d, e, f, g, h, i, j = indices
    charter = texts['check_charter']
    protected = texts['check_protected']
    zones = texts['check_zones']
    funcs = 'TMP="$PWD"\n' + charter[a:b] + '\npermit() {\n' + charter[c:d] + '\nreturn 1;\n}\n'
    funcs += 'protected() { local c="$1" p="$2";\n' + protected[e:f] + '\nreturn 1;\n}\n'
    # Execute the actual pinned case arms, not a second matcher of their TSV.
    funcs += 'mint() { local c="$1" f="$2" an="$3" skip_path=""; [ "$f" = registry/contracts.tsv ] && [ "$an" = orchestrator ] || return 1; for once in 1; do\n' + zones[g:h] + '\ndone; [ "$skip_path" = 1 ];\n}\n'
    funcs += 'process() { local c="$1" f="$2"; : > "$TMP/process_excluded"; for once in 1; do\n' + zones[i:j] + '\ndone; [ -s "$TMP/process_excluded" ];\n}\n'
    funcs += '''frozen() { [ "$2" = contracts/148/4 ]; }
permit_wrapper() { local c="$1" p="$2"; permit; }
'''
    queries = []
    # Every old row is crossed with all four doors, with its original path and
    # actor. Literal outputs are captured before the production implementation.
    functions = {'check_charter': 'charter', 'check_zones': 'zones', 'check_protected': 'protected', 'check_contract_frozen': 'frozen_query'}
    funcs += '''charter() { grandfather_pair "$1" "$2" || permit_wrapper "$1" "$2"; }
zones() { mint "$@" || process "$@"; }
frozen_query() { [ "$1" = - ] && frozen "$@"; }
'''
    with tempfile.TemporaryDirectory(prefix='capture-', dir=SCRATCH) as tmp:
        for row in rows:
            key, sha, path, actor = row[:4]
            for gate in GATES:
                if sha == '-' and gate != key.split('/')[0]:
                    continue
                if sha == '-':
                    expected = int(gate != key.split('/')[0])
                    # Both skip predicates are separate semantic keys.
                    out = err = b''
                else:
                    cmd = funcs + '\n' + functions[gate] + ' "$1" "$2" "$3"'
                    expected, out, err = run(['bash', '-c', cmd, 'capture228', sha, path.rstrip('*') + ('sample' if path.endswith('*') else ''), actor], cwd=tmp)
                if err:
                    raise RuntimeError('BASELINE_CAPTURE_DIAGNOSTIC: ' + repr(err))
                query_key = key if gate == key.split('/')[0] else {
                    'check_charter': 'check_charter/grandfather', 'check_zones': 'check_zones/process',
                    'check_protected': 'check_protected/delete', 'check_contract_frozen': 'check_contract_frozen/skip-version'}[gate]
                if sha != '-' and gate == 'check_contract_frozen':
                    # A full SHA query is legal but cannot match the '-' predicate.
                    pass
                queries.append({'args': [query_key, sha, path.rstrip('*') + ('sample' if path.endswith('*') else ''), actor],
                                'rc': expected, 'stdout': out.decode(), 'stderr': err.decode()})
    payload = dict(BASELINE, matrix=queries)
    (HERE / 'baseline.json').write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n')
    print('CAPTURED', len(queries))


def parsing():
    with tempfile.TemporaryDirectory(prefix='parsing-', dir=SCRATCH) as tmp:
        path = Path(tmp)
        for name in ('run_battery.sh', 'lib.sh'):
            put(path / name, (ROOT / 'fixtures/parsing_hygiene_battery' / name).read_bytes())
        put(path / 'profiles/owner228.sh', (HERE / 'parsing_profile.sh').read_bytes())
        ENV['OWNER_228_ROOT'] = str(ROOT)
        got = run(['bash', path / 'run_battery.sh', 'owner228'])
        print(got[1].decode(), end='')
        if got[0]:
            raise RuntimeError('PARSING_HYGIENE: ' + repr(got))


def syntax():
    for path in HERE.rglob('*.py'):
        ast.parse(path.read_text(), filename=str(path))
    for path in HERE.rglob('*.sh'):
        got = run(['bash', ROOT / 'scripts/validate_std.sh', 'bash', path])
        if got[0]:
            raise RuntimeError('SYNTAX: ' + repr(got))
    with tempfile.TemporaryDirectory(prefix='syntax-', dir=SCRATCH) as tmp:
        subject = materialize(Path(tmp), model=True)
        for gate in GATES:
            got = run(['bash', '-n', subject / 'scripts' / (gate + '.sh')])
            if got[0]:
                raise RuntimeError('MODEL_SYNTAX: ' + repr(got))
    print('SYNTAX rc=0')


def main():
    import historical_checks
    import historical_snapshot_checks
    import historical
    args = sys.argv[1:]
    if args[:1] == ['--historical']:
        return historical.main()
    if args == ['--capture']:
        capture_matrix()
        return 0
    if args == ['--sintaksis']:
        syntax()
        return 0
    if args == ['--parsing']:
        parsing()
        return 0
    catalog = cells()
    mutations = json.loads((HERE / 'stabs/mutations.json').read_text())
    if args == ['--catalog']:
        assert len(catalog) == len(set(catalog)) and catalog and mutations
        for m in mutations:
            assert m['cells'] and all(c in catalog for c in m['cells'])
        actual = {'cells': len(catalog), 'mutations': len(mutations),
                  'bindings': sum(len(m['cells']) for m in mutations), 'rows': len(ROWS),
                  'matrix': len(BASELINE['matrix']), 'unique_sha': len({r[1] for r in ROWS if r[1] != '-'}),
                  'historical_cli_decisions': len({r[1] for r in ROWS if r[1] != '-'}) * len(GATES)}
        if actual != SOURCE['census']:
            raise RuntimeError('SOURCE_CENSUS_DRIFT')
        print('CELLS=' + str(len(catalog)), 'STABS=' + str(len(mutations)), 'BINDINGS=' + str(sum(len(m['cells']) for m in mutations)), 'ROWS=' + str(len(ROWS)), 'MATRIX=' + str(len(BASELINE['matrix'])))
        print(f'HISTORICAL_POLICY_CELLS={len(historical_checks.CELLS)} HISTORICAL_STABS={len(historical_checks.STABS)} HISTORICAL_BINDINGS={len(historical_checks.STABS)}')
        print(f'SNAPSHOT_CELLS={len(historical_snapshot_checks.CELLS)} SNAPSHOT_STABS={len(historical_snapshot_checks.STABS)} SNAPSHOT_BINDINGS={len(historical_snapshot_checks.STABS)}')
        return 0
    selected = list(catalog)
    if '--cell' in args:
        idx = args.index('--cell')
        selected = [args[idx + 1]]
        del args[idx:idx + 2]
        if selected[0] not in catalog:
            raise RuntimeError('UNKNOWN_CELL')
    with tempfile.TemporaryDirectory(prefix='subject-', dir=SCRATCH) as tmp:
        temp = Path(tmp)
        if args == ['--model']:
            subject = materialize(temp, model=True)
        elif args[:1] == ['--repo'] and len(args) == 2:
            subject = materialize(temp, repo=Path(args[1]).resolve())
        elif args == ['--stabs']:
            honest = materialize(temp / 'honest', model=True)
            involved = sorted({c for m in mutations for c in m['cells']})
            control = execute(honest, involved, False)
            if not all(control.values()):
                raise RuntimeError('HONEST_CONTROL: ' + repr(control))
            alive = count = 0
            for m in mutations:
                subject = materialize(temp / m['name'], model=True, mutation=m)
                for gate in (*GATES, 'lib_owner'):
                    parsed = run(['bash', '-n', subject / 'scripts' / (gate + '.sh')])
                    if parsed[0]:
                        raise RuntimeError('STAB_SYNTAX: ' + m['name'])
                library = (subject / 'scripts/lib_owner.sh').read_text()
                ast.parse(library.split("<<'PY'\n", 1)[1].rsplit('\nPY\n', 1)[0])
                got = execute(subject, m['cells'], False)
                for cell, ok in got.items():
                    count += 1
                    alive += int(ok)
                    print(('ZHIV ' if ok else 'POIMAN ') + m['name'] + ' ' + cell)
            print(f'STABS={len(mutations)} BINDINGS={count} ZHIVYH={alive}')
            alive += historical_checks.run('--stabs')
            return int(alive != 0)
        else:
            raise RuntimeError('USAGE: --repo R | --model | --stabs | --sintaksis | --catalog')
        result = execute(subject, selected)
        bad = sum(not v for v in result.values())
        print(f'KLETKI={len(result)} ZELENYE={len(result)-bad} KRASNYE={bad}')
        if args == ['--model']:
            bad += historical_checks.run('--model')
            bad += historical.dispatch('--model')
        return int(bad != 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, OSError, subprocess.SubprocessError, AssertionError, KeyError, ValueError, SyntaxError, IndexError) as exc:
        print('NOT_IMPLEMENTED: ' + str(exc), file=sys.stderr)
        sys.exit(2)
