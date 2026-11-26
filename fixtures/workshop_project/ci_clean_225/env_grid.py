"""Finite independent axes from Arb225; public CLI, pinned bash + literal oracles."""
import copy
import hashlib
import itertools
import os
from pathlib import Path
import subprocess

KEYS = ('CI_ARTIFACTS_ROOT', 'CI_ARTIFACTS_RETENTION_DAYS', 'CI_ARTIFACTS_REPOS')
BLOB = 'b81b1e105d4daea14eea66539475ee9c519b0c6a'
GRID = {}


def add(family, env, *, repos=('Repo-A',), days=4, error=None, policy=0, matches=False):
    index = sum(name.startswith('grid-' + family + '-') for name in GRID)
    GRID[f'grid-{family}-{index}'] = dict(env=env, repos=repos, days=days, error=error,
                                         policy=policy, matches=matches)


for policy in range(2):
    for bits in itertools.product((False, True), repeat=3):
        add('defaults', {key: '' for key, empty in zip(KEYS, bits) if empty},
            repos=('Repo-A', 'Repo-B') if not policy else ('Repo-B',), days=4 if not policy else 6, policy=policy)
    for env, repos, days in (({KEYS[0]: '@SPACE@'}, ('Repo-A', 'Repo-B') if not policy else ('Repo-B',), 4 if not policy else 6),
                             ({KEYS[1]: '8'}, ('Repo-A', 'Repo-B') if not policy else ('Repo-B',), 8),
                             ({KEYS[2]: 'Repo-A'}, ('Repo-A',), 4 if not policy else 6),
                             (dict(zip(KEYS, ('@SPACE@', '8', 'Repo-A'))), ('Repo-A',), 8)):
        add('defaults', env, repos=repos, days=days, policy=policy)
for size in range(1, 4):
    for chars in itertools.product(' \t\n', repeat=size):
        add('zero', {KEYS[2]: ''.join(chars)}, repos=())
add('zero-invalid', {KEYS[2]: ' \t\n', KEYS[1]: 'abc'}, repos=(), error=('days', 'abc'))
add('zero-invalid', {KEYS[2]: '\n\t ', KEYS[0]: '@MISSING@'}, repos=(), error=('root', '@MISSING@'))
D = ('', ' ', '\t', '\n', ' \t\n')
for p, q in itertools.product(D, repeat=2):
    add('position', {KEYS[2]: p + 'Repo-A' + q})
for sep in D[1:]:
    for repos in (('Repo-A', 'Repo-B'), ('Repo-A', 'Repo-A'), ('Repo-B', 'Repo-A')):
        add('position', {KEYS[2]: sep.join(repos)}, repos=repos)
for c in ('\r', '\v', '\f', '\u00a0'):
    for value in (c, 'Repo-A' + c + 'Repo-B'):
        add('nonbash', {KEYS[2]: value}, error=('repo', value))
for invalid in ('.', '..', '../escape', '/absolute', '-A'):
    for value in (invalid, 'Repo-A ' + invalid, invalid + ' Repo-A'):
        add('invalid', {KEYS[2]: value}, error=('repo', invalid))
for pattern in ('*', '?', '[AB]*'):
    add('glob', {KEYS[2]: pattern}, error=('repo', pattern))
    add('glob', {KEYS[2]: pattern}, repos=('A', 'B'), matches=True)
for value in ('1', '4', '8', '01', '000', '0', '-1', '+1', '1.0', 'abc', '\u0664'):
    valid = value in ('1', '4', '8', '01')
    add('days', {KEYS[1]: value}, days=int(value) if valid else 4,
        error=None if valid else ('days', value))
for s in D[1:]:
    for value in (s, s + '4', '4' + s):
        add('days', {KEYS[1]: value}, error=('days', value))
for value in ('@P@', '@SPACE@', '@TAIL@', '@P@/', '../@LEAF@', '@P@/x/../',
              '@MISSING@', '@FILE@', '@LINK@'):
    add('root', {KEYS[0]: value}, error=('root', value) if value in ('@MISSING@', '@FILE@', '@LINK@') else None)
for s in (' ', '\t', '\n'):
    for value in (s, s + '@P@', '@P@' + s):
        add('root', {KEYS[0]: value}, error=('root', value))


def pinned_legacy(repo):
    source = subprocess.check_output(['git', 'show', 'done/contracts/196/1:ops/server/root/ci-artifacts-clean'], cwd=repo)
    assert hashlib.sha1(b'blob ' + str(len(source)).encode() + b'\0' + source).hexdigest() == BLOB, 'LEGACY_BLOB_CHANGED'
    return source


def legacy_with_defaults(source, conf):
    for needle, value in ((b'${CI_ARTIFACTS_ROOT:-/var/lib/ci-artifacts}', os.fsencode(conf['root'])),
                          (b'${CI_ARTIFACTS_RETENTION_DAYS:-14}', str(conf['retention_days']).encode()),
                          (b'${CI_ARTIFACTS_REPOS:-Complior-mob Complior-back}', ' '.join(conf['repos']).encode())):
        assert source.count(needle) == 1, 'LEGACY_DEFAULT_ANCHOR'
        # Shell literal default, not interpolated shell syntax from a path.
        literal = b"'" + value.replace(b"'", b"'\"'\"'") + b"'"
        source = source.replace(b'"' + needle + b'"', needle.split(b':-', 1)[0] + b':-' + literal + b'}')
    return source


def grid_case(World, run, snapshot, age, check, repo, source, overlay, name):
    row = GRID[name]
    legacy = pinned_legacy(repo)  # Capture oracle BEFORE either subject call.
    observations = []
    for label in ('196', '225'):
        with World(source, overlay if label == '225' else None) as w:
            conf = w.cfg['artifacts']
            conf.update(root=str(w.root / ('artifacts' if not row['policy'] else 'alternate artifacts')),
                        retention_days=4 if not row['policy'] else 6,
                        repos=(['Repo-A', 'Repo-B'] if not row['policy'] else ['Repo-B']) if name.startswith('grid-defaults-') else ['Repo-A'])
            P = Path(conf['root'])
            P.mkdir(exist_ok=True)
            space, tail = w.root / 'artifacts inner space', w.root / 'artifacts-tail '
            roots = (P, space, tail)
            for root in roots:
                root.mkdir(exist_ok=True)
                (root / 'x').mkdir()
                for r in ('Repo-A', 'Repo-B', 'Other', 'A', 'B'):
                    for entry, days in (('111-1', 1.5), ('222-2', 5), ('333-3', 9), ('444-4', 0.25)):
                        path = root / r / entry
                        path.mkdir(parents=True)
                        (path / 'data').write_bytes(b'artifact\x00\xff')
                        age(path, days)
            (w.root / 'plain-file').write_bytes(b'not a directory')
            (w.root / 'root-link').symlink_to(P, target_is_directory=True)
            cwd = w.root / 'cwd'
            cwd.mkdir()
            if row['matches']:
                for r in ('A', 'B'): (cwd / r).mkdir()
            replacements = {'@P@': str(P), '@SPACE@': str(space), '@TAIL@': str(tail),
                            '@MISSING@': str(w.root / 'missing'), '@FILE@': str(w.root / 'plain-file'),
                            '@LINK@': str(w.root / 'root-link'), '@LEAF@': P.name}
            def expand(value):
                for token, replacement in replacements.items(): value = value.replace(token, replacement)
                return value
            env = dict(w.env, TMPDIR=str(cwd))
            env.update({key: expand(value) for key, value in row['env'].items()})
            # Independent literal schedule, not the cleaner's age computation.
            removed = {1: ('111-1', '222-2', '333-3'), 4: ('222-2', '333-3'),
                       6: ('333-3',), 8: ('333-3',)}[row['days']]
            expected = {str(root.relative_to(w.root)): copy.deepcopy(snapshot(root)) for root in roots}
            root_value = env.get(KEYS[0]) or conf['root']
            chosen = (cwd / root_value).resolve()
            output, error, rc = b'', b'', 0
            if row['error']:
                kind, value = row['error']
                prefix = {'days': 'срок не целое ≥1', 'repo': 'недопустимое имя репо', 'root': 'корень не каталог'}[kind]
                error = os.fsencode('ОТКАЗ: ' + prefix + ': ' + expand(value) + '\n')
                rc = 1
            else:
                deleted_repos = set()
                for r in row['repos']:
                    deleted = () if r in deleted_repos else removed
                    for entry in deleted:
                        output += os.fsencode(f'удалено: {root_value}/{r}/{entry}\n')
                    output += f'ci-artifacts: репо {r}: удалено {len(deleted)}, хранится {4 - len(removed)}\n'.encode()
                    deleted_repos.add(r)
                    tree = expected[str(chosen.relative_to(w.root))]
                    for entry in removed:
                        prefix = r + '/' + entry
                        for key in list(tree):
                            if key == prefix or key.startswith(prefix + '/'): del tree[key]
            outside = snapshot(w.root / 'outside')
            runners = [snapshot(Path(r['root'])) for r in w.cfg['tmp']['runners']]
            w.save()
            script = w.root / 'legacy-clean'
            script.write_bytes(legacy_with_defaults(legacy, conf))
            public = script if label == '196' else w.runtime / 'ci-artifacts-clean'
            if label == '225':
                check((w.runtime / 'ci-clean.py').is_file(), 'SUBJECT_ABSENT ci-clean.py')
            result = run(['bash', str(public)], env)
            check((result.returncode, result.stdout, result.stderr) == (rc, output, error),
                  f'GRID_{label}_LITERAL {result.returncode} {result.stdout!r} {result.stderr!r} expected={rc, output, error!r}')
            actual = {str(root.relative_to(w.root)): snapshot(root) for root in roots}
            check(actual == expected, f'GRID_{label}_TREE')
            check(snapshot(w.root / 'outside') == outside, f'GRID_{label}_OUTSIDE')
            check([snapshot(Path(r['root'])) for r in w.cfg['tmp']['runners']] == runners, f'GRID_{label}_RUNNERS')
            check(not w.journal(), f'GRID_{label}_SYSTEMCTL')
            for unit in ('toy-a.service', 'toy-b.service'):
                check((w.root / 'cgroup' / unit / 'cgroup.events').read_bytes() == b'frozen 0\n', f'GRID_{label}_FREEZE')
            def normalize(value): return value.replace(os.fsencode(w.root), b'{WORLD}')
            observations.append((result.returncode, normalize(result.stdout), normalize(result.stderr), actual, outside, runners))
    check(observations[0] == observations[1], 'GRID_DIFFERENTIAL')
