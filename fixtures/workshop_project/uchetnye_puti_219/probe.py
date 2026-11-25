#!/usr/bin/env python3
"""219: actual Git trees, exact CLI bytes, independent in-memory expectations."""
import argparse
import ast
import csv
import hashlib
import io
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from model.registry_data_mutation import BEFORE, AFTER

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = '8b52fade7975034d7cabece67e46c16a7d1abe3b'
REG = 'registry/ci-steps.tsv'
SCRIPT = 'scripts/ci_klass.sh'
ORACLE = 'fixtures/ci_b_087/_orakul.py'
FAMILY = 'fixtures/workshop_project/uchetnye_puti_219'
CONTRACT = 'contracts/219-uchetnye-puti-ci-klass.md'
PROTECT = (REG, SCRIPT, '.github/workflows/ci.yml')
ENV = {k: v for k, v in os.environ.items()
       if not k.startswith(('GIT_', 'M087_', 'CI_KLASS_'))
       and k not in ('GITHUB_TOKEN', 'GH_TOKEN', 'BASH_ENV', 'ENV')}
ENV.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
           GIT_TERMINAL_PROMPT='0', PYTHONDONTWRITEBYTECODE='1', LC_ALL='C.UTF-8',
           GIT_AUTHOR_NAME='architect', GIT_COMMITTER_NAME='architect',
           GIT_AUTHOR_EMAIL='architect@dev-harness.local',
           GIT_COMMITTER_EMAIL='architect@dev-harness.local')


class Infrastructure(Exception):
    pass


def call(argv, cwd=ROOT, check=False, timeout=120):
    try:
        p = subprocess.run([str(a) for a in argv], cwd=cwd, env=ENV,
                           capture_output=True, timeout=timeout)
    except (OSError, subprocess.TimeoutExpired) as e:
        raise Infrastructure(str(e)) from e
    if check and p.returncode:
        raise Infrastructure(f'{argv}: rc={p.returncode}: {p.stderr!r}')
    return p


def git(repo, *args):
    return call(['git', '-C', repo, *args], check=True).stdout


def pinned(path):
    return git(ROOT, 'show', f'{BASE}:{path}')


def old_paths():
    # Literal from the pre-219 independent oracle, never from the subject's disk.
    tree = ast.parse(pinned(ORACLE))
    for node in tree.body:
        if isinstance(node, ast.Assign) and any(
                isinstance(t, ast.Name) and t.id == 'U87' for t in node.targets):
            return tuple(ast.literal_eval(node.value))
    raise Infrastructure('pinned U87 literal absent')


def additions():
    rows = list(csv.reader(io.StringIO((HERE / 'model/uchet.tsv').read_text()),
                           delimiter='\t'))
    if not rows or any(len(r) != 2 or r[0] != 'uchet' for r in rows):
        raise Infrastructure('canonical additions malformed')
    paths = tuple(r[1] for r in rows)
    if len(set(paths)) != len(paths):
        raise Infrastructure('canonical additions duplicate')
    return paths


def covered(path, patterns):
    # Definition of H from 087, not parse_uchet/covers imported from production.
    return any((path.startswith(v) if v.endswith('/') else
                ('/' not in path and path.startswith(v[:-1])) if v.endswith('*')
                else path == v) for v in patterns)


def oracle_hash(repo, rev, patterns):
    entries = git(repo, 'ls-tree', '-r', '-z', '--full-tree', rev).split(b'\0')
    raw = b''.join(e + b'\0' for e in entries if e and not covered(
        e.split(b'\t', 1)[1].decode('utf-8', 'surrogateescape'), patterns))
    return hashlib.sha256(raw).hexdigest().encode() + b'\n'


def extend_registry(raw):
    existing = raw.splitlines()
    out = raw
    for value in additions():
        row = b'uchet\t' + value.encode()
        if row not in existing:
            out += (b'' if out.endswith(b'\n') else b'\n') + row + b'\n'
    return out


def extend_oracle(raw):
    marker = b'\nDECISION = '
    if b'# 219: exact snapshot extension;' in raw:
        return raw
    if raw.count(marker) != 1:
        raise Infrastructure('087 oracle migration anchor is not unique')
    snippet = (HERE / 'model/oracle_extension.py').read_bytes()
    return raw.replace(marker, b'\n' + snippet + marker, 1)


def write_file(root, name, data):
    p = root / name
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_bytes(data)


def commit(repo, message):
    git(repo, 'add', '-A')
    git(repo, '-c', 'user.name=architect', '-c',
        'user.email=architect@dev-harness.local', 'commit', '-qm', message)
    return git(repo, 'rev-parse', 'HEAD').decode().strip()


PAUSE = 'registry/pauzy.tsv'
PLACE = 'registry/mesto-legacy.tsv'
LESSONS = 'registry/lessons-harness.tsv'
RISK = 'registry/risk-legacy.tsv'
RECEIPT = 'registry/dostavki/743.json'
DATA = {PAUSE: b'743\t2026-11-24\tconsultant\tafter done 742\n',
        PLACE: ('743\t' + 'a' * 40 + '\tстанция\tfrozen zones\tarchitect\n').encode(),
        LESSONS: b'N-743\tscripts/*\tuse exact paths\n',
        RISK: b'a' * 40 + '\tрисковый\tdefault\tconsultant\n'.encode(),
        RECEIPT: b'{"version":1,"subjectId":"743"}\n'}
CASES = {}
for key, path in (('pause', PAUSE), ('place', PLACE), ('lessons', LESSONS)):
    for operation in ('add', 'edit', 'delete'):
        CASES[f'{key}-{operation}'] = (operation, path, 'uchet')
CASES.update({
    'snapshot-exact': ('snapshot', REG, 'uchet'),
    'mixed-code-place': ('mixed', PLACE, 'kod'),
    'risk-policy': ('edit', RISK, 'kod'),
    'receipt-policy': ('edit', RECEIPT, 'kod'),
    'registry-executable-policy': ('policy', 'registry/policy.tsv', 'kod'),
    'registry-script': ('policy', 'registry/execute.sh', 'kod'),
    'pause-suffix': ('policy', PAUSE + '.sh', 'kod'),
    'place-suffix': ('policy', PLACE + '.extra', 'kod'),
    'nested-pause': ('policy', 'registry/nested/pauzy.tsv', 'kod'),
    'code-content': ('edit', 'scripts/work.sh', 'kod'),
    'code-mode': ('mode', 'scripts/work.sh', 'kod'),
    'registry-add-uchet': ('reg-add', REG, 'kod'),
    'registry-remove-uchet': ('reg-remove', REG, 'kod'),
    'registry-replace-uchet': ('reg-replace', REG, 'kod'),
    'registry-add-uchet-with-data': ('reg-add-data', REG, 'kod'),
    'registry-remove-uchet-with-data': ('reg-remove-data', REG, 'kod'),
    'registry-replace-uchet-with-data': ('reg-replace-data', REG, 'kod'),
    'accounting-data-only': ('data-only', PAUSE, 'uchet'),
    'new-list-cannot-amnesty': ('widen', REG, 'kod'),
    'strip-accounting-only': ('strip', PAUSE, 'uchet'),
})
for i in range(len(PROTECT)):
    CASES[f'protect-exact-{i}'] = ('protect', PROTECT[i], 'refuse')
    CASES[f'protect-parent-{i}'] = ('protect-parent', PROTECT[i], 'refuse')

# Addressed defects are data/operation mutations, not alternate implementations.
MUTATIONS = {
    'NO_PAUSE': ('remove', PAUSE),
    'NO_PLACE': ('remove', PLACE),
    'NO_LESSONS': ('remove', LESSONS),
    'RISK_IS_ACCOUNTING': ('add', RISK),
    'RECEIPTS_ARE_ACCOUNTING': ('add', 'registry/dostavki/'),
    'EXACT_AS_PREFIX': ('source', ('return path == v', 'return path.startswith(v)')),
    'UNKNOWN_ACCOUNTING': ('add', 'registry/unknown.tsv'),
    'MISSING_OLD_DOCS': ('remove', 'docs/'),
    'DUPLICATE_PAUSE': ('add', PAUSE),
    'IGNORE_CODE': ('source', ("return any(covers(p, path) for p in pats)",
                               "return path.startswith('scripts/') or any(covers(p, path) for p in pats)")),
    'NO_PROTECT': ('source', ('for prot in PROTECT:', 'for prot in ():')),
    'ALWAYS_UCHET': ('source', ("print('uchet' if kod_hash(o, pats) == kod_hash(n, pats) else 'kod')",
                                "print('uchet')")),
    'STRIP_NOOP': ('source', ('os.unlink(fp)', 'pass')),
    'REGISTRY_WITH_DATA_IS_UCHET': ('source', (BEFORE, AFTER)),
}


def mutate(registry, script, name):
    kind, arg = MUTATIONS[name]
    if kind == 'source':
        before, after = (v.encode() for v in arg)
        if script.count(before) != 1:
            raise Infrastructure(f'{name}: mutation anchor missing/nonunique')
        return registry, script.replace(before, after, 1)
    if kind == 'remove':
        row = b'uchet\t' + arg.encode() + b'\n'
        if registry.count(row) != 1:
            raise Infrastructure(f'{name}: mutation row missing/nonunique')
        registry = registry.replace(row, b'', 1)
    elif kind == 'add':
        registry += b'uchet\t' + arg.encode() + b'\n'
    elif kind == 'rename':
        before, after = arg
        registry = registry.replace(b'uchet\t' + before.encode() + b'\n',
                                    b'uchet\t' + after.encode() + b'\n', 1)
    return registry, script


def world(root, registry, script, case, variant):
    repo = root / 'world'
    repo.mkdir()
    git(repo, 'init', '-q')
    git(repo, 'config', 'core.hooksPath', '/dev/null')
    op, path, expected = CASES[case]
    files = {REG: registry, SCRIPT: script, '.github/workflows/ci.yml': b'name: fixture\n',
             'scripts/work.sh': b'printf initial\\n\n'}
    for p, value in DATA.items():
        files[p] = value
    if op == 'add':
        files.pop(path)
    if op in ('protect', 'protect-parent'):
        pat = path if op == 'protect' else path.rsplit('/', 1)[0] + '/'
        registry = registry + b'uchet\t' + pat.encode() + b'\n'
        files[REG] = registry
    for p, value in files.items():
        write_file(repo, p, value)
    old = commit(repo, f'fixture base {variant}')
    if expected == 'refuse':
        return repo, old, old, registry
    if op == 'delete':
        (repo / path).unlink()
    elif op in ('add', 'edit', 'mixed'):
        original = DATA.get(path, b'work\n')
        write_file(repo, path, original + f'# changed {variant}\n'.encode())
        if op == 'mixed':
            write_file(repo, 'scripts/work.sh', f'printf changed-{variant}\\n\n'.encode())
    elif op == 'mode':
        (repo / path).chmod(0o755)
    elif op == 'policy':
        write_file(repo, path, f'step\tcheck:policy-{variant}\t1\tbash scripts/work.sh\n'.encode())
    elif op in ('reg-add', 'reg-add-data'):
        write_file(repo, REG, registry + b'uchet\tfixtures/data/\n')
    elif op in ('reg-remove', 'reg-remove-data'):
        write_file(repo, REG, registry.replace(b'uchet\tdocs/\n', b'', 1))
    elif op in ('reg-replace', 'reg-replace-data'):
        write_file(repo, REG, registry.replace(b'uchet\tdocs/\n', b'uchet\tother-docs/\n', 1))
    elif op == 'widen':
        write_file(repo, REG, registry + b'uchet\tscripts/work.sh\n')
        write_file(repo, 'scripts/work.sh', b'printf changed\\n\n')
    elif op == 'strip':
        write_file(repo, PAUSE, DATA[PAUSE] + b'# next state\n')
    if op in ('reg-add-data', 'reg-remove-data', 'reg-replace-data', 'data-only'):
        paths = (PAUSE, PLACE, LESSONS) if op in ('reg-replace-data', 'data-only') else (PAUSE,)
        for data_path in paths:
            write_file(repo, data_path, DATA[data_path] + f'# changed {variant}\n'.encode())
    new = commit(repo, f'fixture change {variant}')
    return repo, old, new, registry


def compare(p, rc, out, err):
    return [] if (p.returncode, p.stdout, p.stderr) == (rc, out, err) else [
        f'BYTES expected={(rc, out, err)!r} actual={(p.returncode, p.stdout, p.stderr)!r}']


def exercise(registry, script, case, variant=0):
    patterns = old_paths() + additions()  # captured independently before subject invocation
    if case == 'snapshot-exact':
        rows = list(csv.reader(io.StringIO(registry.decode()), delimiter='\t'))
        got = sorted(r[1] for r in rows if len(r) == 2 and r[0] == 'uchet')
        want = sorted(patterns)
        return [] if got == want else [f'SNAPSHOT expected={want!r} actual={got!r}']
    with tempfile.TemporaryDirectory(prefix='uchet219-world-') as d:
        repo, old, new, actual_reg = world(Path(d), registry, script, case, variant)
        command = ['bash', repo / SCRIPT]
        op, path, expected = CASES[case]
        if expected == 'refuse':
            pat = path if op == 'protect' else path.rsplit('/', 1)[0] + '/'
            line = len(actual_reg.splitlines())
            stderr = (f'ОТКАЗ: реестр {REG}: строка {line}: учётный путь {pat} '
                      f'накрывает машину классификатора {path}\n').encode()
            return compare(call(command + ['hash', old], repo), 1, b'', stderr)
        h_old = oracle_hash(repo, old, patterns)
        # klass always uses U(old), independent of any new registry changes.
        h_new = oracle_hash(repo, new, patterns)
        if op in ('reg-add-data', 'reg-remove-data', 'reg-replace-data') and h_old == h_new:
            raise Infrastructure('joint registry/data fixture has identical code hashes')
        errors = compare(call(command + ['klass', old, new], repo), 0,
                         (expected + '\n').encode(), b'')
        if expected == 'uchet' or op in ('reg-add-data', 'reg-remove-data', 'reg-replace-data'):
            errors += compare(call(command + ['hash', old], repo), 0, h_old, b'')
            errors += compare(call(command + ['hash', new], repo), 0, h_new, b'')
        if op == 'strip':
            # Snapshot bytes/expected surviving paths in memory before destructive CLI.
            listing = git(repo, 'ls-files', '-z').split(b'\0')
            kept = {p: (repo / p.decode()).read_bytes() for p in listing if p and
                    not covered(p.decode(), patterns)}
            removed = [p for p in listing if p and covered(p.decode(), patterns)]
            stdout = (f'strip: удалено учётных путей {len(removed)}, '
                      f'кодовое дерево H={h_new.decode().strip()}\n').encode()
            errors += compare(call(command + ['strip', h_new.decode().strip()], repo),
                              0, stdout, b'')
            if any((repo / p.decode()).exists() for p in removed):
                errors.append('STRIP_LEFT_ACCOUNTING')
            if any(not (repo / p.decode()).exists() or
                   (repo / p.decode()).read_bytes() != value for p, value in kept.items()):
                errors.append('STRIP_CHANGED_CODE')
            if git(repo, 'rev-parse', 'HEAD').decode().strip() != new:
                errors.append('STRIP_CHANGED_HEAD')
        return errors


def catalog():
    rows = list(csv.reader(io.StringIO((HERE / 'stabs.tsv').read_text()), delimiter='\t'))
    rows = [r for r in rows if r and not r[0].startswith('#')]
    if not rows or any(len(r) != 3 or r[0] not in MUTATIONS or r[1] not in CASES
                       or r[2] not in CASES for r in rows):
        raise Infrastructure('stab registry malformed')
    if {r[0] for r in rows} != set(MUTATIONS):
        raise Infrastructure('stab registry does not cover mutation dictionary')
    print(f'KLETKI={len(CASES)} MUTACII={len(MUTATIONS)} SVJAZI={len(rows)} '
          f'UCHET={len(old_paths()) + len(additions())}')
    return rows


def snapshot(repo, destination):
    # 087 K10/runner-hygiene reads real historical acts, not just current files.
    # A local disposable clone owns its .git/index; object sharing is read-only.
    call(['git', 'clone', '--quiet', '--shared', repo, destination], check=True)
    shutil.copytree(HERE, destination / FAMILY, dirs_exist_ok=True)
    for p in (REG, SCRIPT, ORACLE, CONTRACT):
        if (repo / p).exists():
            write_file(destination, p, (repo / p).read_bytes())


def compatibility(repo, model):
    with tempfile.TemporaryDirectory(prefix='uchet219-compat-') as d:
        target = Path(d)
        snapshot(repo, target)
        if model:
            write_file(target, REG, extend_registry((target / REG).read_bytes()))
            write_file(target, ORACLE, extend_oracle((target / ORACLE).read_bytes()))
        commands = [
            ['bash', target / 'fixtures/ci_b_087/red_ci_b_087.sh', target],
            ['bash', target / 'scripts/gen_ci_steps.sh', '--check', '--root', target],
            ['bash', target / 'scripts/check_provodka.sh', target, CONTRACT],
        ]
        bad = 0
        for argv in commands:
            p = call(argv, target, timeout=300)
            sys.stdout.buffer.write(p.stdout)
            sys.stderr.buffer.write(p.stderr)
            print(f'COMPAT {Path(argv[1]).name} rc={p.returncode}', flush=True)
            bad += p.returncode != 0
        return int(bad != 0)


def syntax():
    for p in (HERE / 'probe.py', HERE / 'model/oracle_extension.py',
              HERE / 'model/registry_data_mutation.py'):
        compile(p.read_bytes(), str(p), 'exec')
    compile('def c_klass(o, n, pats):\n' + AFTER + '\n',
            'registry_data_mutation.AFTER', 'exec')
    p = call(['bash', ROOT / 'scripts/validate_std.sh', 'bash',
              HERE / 'red_uchetnye_puti_219.sh'])
    sys.stdout.buffer.write(p.stdout)
    sys.stderr.buffer.write(p.stderr)
    print(f'SYNTAX rc={p.returncode}')
    return p.returncode


def context():
    program = ('source "$1/scripts/lib_zones.sh"; LIB_ZONES_ROOT="$1"; '
               'trap __lib_zones_cleanup EXIT; '
               'out="$(zones_load "$1")" || exit $?; cat "$out/zones_scoped"')
    raw = call(['bash', '-c', program, '--', ROOT], check=True).stdout.decode()
    targets = (CONTRACT, FAMILY + '/', ORACLE, REG,
               'registry/ci-zamery.tsv', '.github/workflows/ci.yml')
    count = 0
    for target in targets:
        author = ('architect' if target in (CONTRACT, FAMILY + '/') else
                  'implementer' if target == ORACLE else 'orchestrator')
        owners = sorted({r.split('\t')[2] for r in raw.splitlines()
                         if len(r.split('\t')) == 3
                         and r.split('\t')[0] != author
                         and ((r.split('\t')[1].endswith('/') and
                               target.startswith(r.split('\t')[1]))
                              or r.split('\t')[1] == target)})
        count += len(owners)
        print(target + '\t' + ' '.join(owners))
    if not count:
        raise Infrastructure('empty ownership sample')
    return 0


def main():
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--repo', type=Path)
    mode.add_argument('--model', action='store_true')
    mode.add_argument('--stabs', action='store_true')
    mode.add_argument('--sintaksis', '--syntax', action='store_true')
    mode.add_argument('--catalog', action='store_true')
    mode.add_argument('--context', action='store_true')
    parser.add_argument('--compat', action='store_true')
    parser.add_argument('--equivalent', action='store_true')
    parser.add_argument('--cell', choices=tuple(CASES))
    args = parser.parse_args()
    if args.context:
        return context()
    if args.sintaksis:
        return syntax()
    rows = catalog()
    if args.catalog:
        return 0
    repo = (args.repo or ROOT).resolve()
    if args.compat:
        return compatibility(repo, args.model)
    registry = (repo / REG).read_bytes()
    script = (repo / SCRIPT).read_bytes()
    if args.model or args.stabs:
        registry = extend_registry(registry)
    if args.equivalent:
        if not args.model:
            raise Infrastructure('--equivalent requires --model')
        accounting = [r for r in registry.splitlines() if r.startswith(b'uchet\t')]
        rest = [r for r in registry.splitlines() if not r.startswith(b'uchet\t')]
        registry = b'\n'.join(rest + list(reversed(accounting))) + b'\n'
        script = script.replace(b'return path == v', b'return v == path')
    if args.stabs:
        caught = 0
        for name, case, control in rows:
            honest = exercise(registry, script, case)
            differential = exercise(*mutate(registry, script, name), control)
            if honest or differential:
                raise Infrastructure(f'{name}: honest/control not green: {honest}, {differential}')
            errors = exercise(*mutate(registry, script, name), case)
            if errors:
                caught += 1
            print(f'{name} -> {case}: {"POIMAN" if errors else "ZHIV"}; '
                  f'control={control} GREEN; {errors}')
        print(f'SVJAZI={len(rows)} POIMANY={caught} ZHIVYH={len(rows)-caught}')
        return int(caught != len(rows))
    bad = 0
    selected = (args.cell,) if args.cell else tuple(CASES)
    # Same values are not a proof: run both state variants, independently committed.
    for case in selected:
        errors = []
        for variant in (17, 823):
            errors += exercise(registry, script, case, variant)
        bad += bool(errors)
        print(f'{case}: {"RED" if errors else "GREEN"} {errors}')
    print(f'KLETKI={len(selected)} ZELENYE={len(selected)-bad} KRASNYE={bad}')
    return int(bad != 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (Infrastructure, OSError, ValueError) as exc:
        print(f'NOT_IMPLEMENTED: {exc}', file=sys.stderr)
        sys.exit(2)
