#!/usr/bin/env python3
"""223 public done CLI: real merge deltas, pre-call in-memory SHA/tag/API oracle."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
spec = importlib.util.spec_from_file_location('world201', HERE.parent / 'done_dver_soderzhatelnaja_201/dver_probe.py')
world201 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(world201)
TAG = 'done/contracts/777/1'
# name, operation, path, expected rc, expected selected commit, API variant.
# Expectations are requirements, never computed by the subject/model classifier.
CASES = (
    ('review-merge', 'add', '.review/2026-11-24-06.md', 0, 'product', 'success'),
    ('review-nested', 'add', '.review/deep/a.md', 0, 'product', 'success'),
    ('harness-merge', 'add', '.harness/notes/a.md', 0, 'product', 'success'),
    ('both-services', 'both', '.review/a.md', 0, 'product', 'success'),
    ('backend177-chain', 'chain', '.review/2026-11-24-06.md', 0, 'product', 'success'),
    ('review-linear', 'linear', '.review/a.md', 0, 'product', 'success'),
    ('reviewx', 'add', '.reviewx/a.md', 1, 'head', 'success'),
    ('review-no-dot', 'add', 'review/a.md', 1, 'head', 'success'),
    ('review-file', 'add', '.review', 1, 'head', 'success'),
    ('review-uppercase', 'add', '.REVIEW/a.md', 1, 'head', 'success'),
    ('review-other-dot', 'add', '.github/a.md', 1, 'head', 'success'),
    ('review-not-root', 'add', 'docs/.review/a.md', 1, 'head', 'success'),
    ('mixed-review-product', 'mixed', '.review/a.md', 1, 'head', 'success'),
    ('mixed-both-product', 'mixed-both', '.review/a.md', 1, 'head', 'success'),
    ('review-space', 'add', '.review/a b.md', 0, 'product', 'success'),
    ('review-unicode', 'add', '.review/отзыв.md', 0, 'product', 'success'),
    ('review-dotdot-name', 'add', '.review/a..b.md', 0, 'product', 'success'),
    ('review-newline', 'add', '.review/a\nb.md', 0, 'product', 'success'),
    ('normalized-escape', 'add', '.review/a/../../x', 1, 'head', 'success'),
    ('product-space', 'add', 'src/a b.md', 1, 'head', 'success'),
    ('review-delete', 'delete', '.review/old.md', 0, 'product', 'success'),
    ('product-delete', 'delete', 'src/old.md', 1, 'head', 'success'),
    ('review-rename', 'rename-in', '.review/new.md', 0, 'product', 'success'),
    ('product-rename-in', 'rename-product-in', '.review/new.md', 1, 'head', 'success'),
    ('product-rename-out', 'rename-product-out', 'src/new.md', 1, 'head', 'success'),
    ('review-mode', 'mode', '.review/old.md', 0, 'product', 'success'),
    ('product-mode', 'mode', 'src/old.md', 1, 'head', 'success'),
    ('review-symlink', 'symlink', '.review/link', 0, 'product', 'success'),
    ('product-symlink', 'symlink', 'src/link', 1, 'head', 'success'),
    ('review-type-change', 'type', '.review/old.md', 0, 'product', 'success'),
    ('review-missing-run', 'add', '.review/a.md', 1, 'product', 'missing'),
    ('review-failed-run', 'add', '.review/a.md', 1, 'product', 'failure'),
    ('review-skipped-run', 'add', '.review/a.md', 1, 'product', 'skipped'),
    ('review-other-sha', 'add', '.review/a.md', 1, 'product', 'other'),
    ('review-incomplete-run', 'add', '.review/a.md', 1, 'product', 'in_progress'),
    ('review-wrong-name', 'add', '.review/a.md', 1, 'product', 'archive'),
    ('review-name-space', 'add', '.review/a.md', 0, 'product', 'arch fitness'),
    ('review-name-parenthesis', 'add', '.review/a.md', 0, 'product', 'arch (model)'),
    ('product-head-success', 'mixed', '.review/a.md', 0, 'head', 'head-success'),
)
CURL = '''#!/usr/bin/env python3
import json, os, re, sys
from pathlib import Path
url = sys.argv[-1]
m = re.search(r'/commits/([0-9a-f]{40})/check-runs\\?', url)
if not m:
    raise SystemExit(31)
with Path(os.environ['ARCH223_QUERIES']).open('a') as out:
    out.write(json.dumps(m.group(1)) + '\\n')
api = json.loads(Path(os.environ['ARCH223_API']).read_text())
print(json.dumps(api.get(m.group(1), {'total_count': 0, 'check_runs': []})))
'''


def run(args, cwd=None, env=None):
    return subprocess.run([str(a) for a in args], cwd=cwd, env=env, capture_output=True, timeout=90)


def checked(args, cwd=None):
    p = run(args, cwd)
    if p.returncode:
        raise RuntimeError('COMMAND ' + repr(args) + ': ' + repr(p.stderr))
    return p.stdout.decode().strip()


def g(root, *args):
    return checked(['git', '-C', root, *args])


def put(root, path, text):
    p = root / path
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text)


def commit(root, message):
    g(root, 'add', '-A')
    g(root, 'commit', '-qm', message)
    return g(root, 'rev-parse', 'HEAD')


def merge(root, branch, files):
    g(root, 'checkout', '-qb', branch)
    for path, text in files.items():
        put(root, path, text)
    commit(root, branch)
    g(root, 'checkout', '-q', 'main')
    g(root, 'merge', '--no-ff', '-qm', 'merge ' + branch, branch)


def report(sha, variant):
    if variant == 'missing':
        return {'total_count': 0, 'check_runs': []}
    return {'total_count': 1, 'check_runs': [{
        'name': variant if variant.startswith('arch') else 'arch',
        'head_sha': 'f' * 40 if variant == 'other' else sha,
        'status': 'in_progress' if variant == 'in_progress' else 'completed',
        'conclusion': variant if variant in ('failure', 'skipped') else 'success'}]}


def make_world(work, case):
    name, operation, path, expected_rc, selected_kind, variant = case
    root, target, _ = world201.build(work, 'g-arch-tochno-imja', 'back')
    # A fresh product commit after F/review: selected ancestor has a real
    # product delta, and seeded rename/delete/mode sources do not taint tail.
    put(root, 'src/product.js', 'product 223\n')
    put(root, 'src/old.md', 'unchanged rename content 223\n')
    if path != '.review':
        put(root, '.review/old.md', 'unchanged rename content 223\n')
    if operation == 'add' and path == '.review/a/../../x':
        (root / '.review/a').mkdir(parents=True)
    product = commit(root, 'product ancestor (backend177 c635a010 shape)')
    if operation == 'chain':
        merge(root, 'verdict-pr-1031', {path: 'status: ready\n'})
        merge(root, 'harness-pr-1033', {'.harness/notes/1033': 'metadata\n'})
        merge(root, 'verdict-pr-1034', {'.review/second.md': 'status: ready\n'})
        merge(root, 'harness-pr-1036', {'.harness/notes/1036': 'metadata\n'})
    else:
        if operation != 'linear':
            g(root, 'checkout', '-qb', 'verdict-pr')
        if operation in ('delete', 'mode', 'type'):
            if operation == 'delete':
                (root / path).unlink()
            elif operation == 'mode':
                (root / path).chmod(0o755)
            else:
                (root / path).unlink()
                (root / path).symlink_to('../src/product.js')
        elif operation.startswith('rename'):
            old = 'src/old.md' if operation == 'rename-product-in' else '.review/old.md'
            g(root, 'mv', old, path)
        elif operation == 'symlink':
            (root / path).parent.mkdir(parents=True, exist_ok=True)
            (root / path).symlink_to('../src/product.js')
        else:
            put(root, path, 'status: ready\n')
            if operation in ('both', 'mixed-both'):
                put(root, '.harness/notes/tail.md', 'service\n')
            if operation in ('mixed', 'mixed-both'):
                put(root, 'src/tail.js', 'product delta\n')
        commit(root, 'review carrier')
        if operation != 'linear':
            g(root, 'checkout', '-q', 'main')
            g(root, 'merge', '--no-ff', '-qm', 'merge PR #1031 review', 'verdict-pr')
    head = g(root, 'rev-parse', 'HEAD')
    selected = product if selected_kind == 'product' else head
    # Assert the source of pathological spelling: Git stores canonical x,
    # never a raw '..' component. No invented malformed Git tree is accepted.
    if name == 'normalized-escape':
        if g(root, 'diff', '--name-only', head + '^1', head) != 'x':
            raise RuntimeError('ESCAPE_WORLD_NOT_CANONICAL')
    g(root, 'push', '-q', 'origin', 'main')
    api = {product: report(product, variant)}
    if variant == 'head-success':
        api[head] = report(head, 'success')
    # All expectations and external response bytes exist before invoking subject.
    api_file, queries = work / 'api.json', work / 'queries.jsonl'
    api_file.write_text(json.dumps(api))
    bin_dir = work / 'api-bin'
    bin_dir.mkdir()
    (bin_dir / 'curl').write_text(CURL)
    (bin_dir / 'curl').chmod(0o755)
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               HARNESS_PROJECT_LAYER_ROOT=str(root), HARNESS_WORKFLOW_ROOT=str(root),
               ARCH223_API=str(api_file), ARCH223_QUERIES=str(queries),
               PATH=str(bin_dir) + os.pathsep + os.environ.get('PATH', ''))
    return root, target, head, selected, expected_rc, queries, env


def suite(carrier, cases, label, tools_repo):
    red = 0
    with tempfile.TemporaryDirectory(prefix='arch223-', dir=os.environ.get('TMPDIR')) as tmp:
        work = Path(tmp)
        tools = work / 'tools'
        shutil.copytree(tools_repo / 'scripts', tools / 'scripts')
        door = tools / 'scripts/done_contract.sh'
        door.write_bytes(carrier)
        checked(['bash', '-n', door])
        for i, case in enumerate(cases):
            cell = work / str(i)
            cell.mkdir()
            root, target, head, selected, expected_rc, queries, env = make_world(cell, case)
            result = run(['bash', door, target, '223 architecture acceptance', root], root, env)
            if result.returncode not in (0, 1):
                raise RuntimeError('SUBJECT_ENVIRONMENT ' + repr(result.stderr))
            actual_queries = [json.loads(s) for s in queries.read_text().splitlines()] if queries.exists() else []
            if result.returncode == 1 and not any(line.startswith(b'ARCH_CI:') for line in result.stderr.splitlines()):
                raise RuntimeError('UNRELATED_REFUSAL ' + case[0] + ' ' + repr(result.stderr))
            problems = []
            if result.returncode != expected_rc:
                problems.append('RC')
            if actual_queries != [selected]:
                problems.append('QUERY_SHA')
            prefix = f'ARCH_CI: HEAD={head}; SHA*={selected}; '.encode()
            lines = [line for line in result.stderr.splitlines() if line.startswith(prefix)]
            if len(lines) != 1:
                problems.append('SHA_DIAGNOSIS')
            elif expected_rc == 0 and lines[0] != prefix + 'успешный check-run arch засчитан'.encode():
                problems.append('SUCCESS_DIAGNOSIS')
            elif expected_rc == 1 and 'успешного check-run arch нет'.encode() not in lines[0][len(prefix):]:
                problems.append('REFUSAL_DIAGNOSIS')
            if result.stdout:
                problems.append('STDOUT')
            tags = g(root, 'tag', '-l', 'done/contracts/*').splitlines()
            if expected_rc == 0:
                if tags != [TAG] or g(root, 'rev-parse', TAG + '^{commit}') != head:
                    problems.append('TAG_TARGET')
                elif g(root, 'cat-file', '-t', TAG) != 'tag':
                    problems.append('ANNOTATED_TAG')
            elif tags:
                problems.append('TAG_ON_REFUSAL')
            if g(root, 'rev-parse', 'HEAD') != head:
                problems.append('HEAD_CHANGED')
            red += bool(problems)
            print(label, case[0], 'RED ' + ','.join(problems) if problems else 'GREEN',
                  'rc=' + str(result.returncode), flush=True)
    return red


def carriers():
    source = json.loads((HERE / 'source.json').read_text())
    saved = {path: (HERE / path).read_bytes() for path in source['files']}
    for path, data in saved.items():
        if hashlib.sha256(data).hexdigest() != source['files'][path]:
            raise RuntimeError('CARRIER_CHANGED ' + path)
    names = [c[0] for c in CASES]
    if not names or len(names) != len(set(names)):
        raise RuntimeError('EMPTY_DUPLICATE_CATALOG')
    if any(c not in names for row in source['links'] for c in row['cells']):
        raise RuntimeError('UNKNOWN_LINK')
    tsv = ''.join(row['carrier'] + '\t' + c + '\t' + row['polarity'] + '\n'
                  for row in source['links'] for c in row['cells'])
    if (HERE / 'stabs.tsv').read_bytes() != tsv.encode():
        raise RuntimeError('STABS_TSV_CHANGED')
    return source, saved


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--repo', type=Path)
    for mode in ('model', 'stabs', 'sintaksis', 'catalog'):
        group.add_argument('--' + mode, action='store_true')
    args = parser.parse_args()
    source, saved = carriers()
    model = saved['model/done_contract.sh']
    if args.catalog:
        print('KLETKI', len(CASES), 'STABY', sum(row['polarity'] == 'red' for row in source['links']),
              'EKVIVALENTY', sum(row['polarity'] == 'green' for row in source['links']),
              'SVJAZI', sum(len(row['cells']) for row in source['links']))
        for case in CASES:
            print(case[0], 'rc=' + str(case[3]))
        return 0
    if args.sintaksis:
        for path in saved:
            checked(['bash', '-n', HERE / path])
        for path in (HERE / 'model/done_contract.sh', HERE / 'red_arch_ci_review_223.sh'):
            checked(['bash', REPO / 'scripts/validate_std.sh', 'bash', path])
        for path in HERE.glob('*.py'):
            compile(path.read_bytes(), str(path), 'exec')
        print('SINTAKSIS', len(saved), 'SHELLCHECK', 2)
        return 0
    tools_repo = (args.repo or REPO).resolve()
    if args.stabs:
        if suite(model, CASES, 'CONTROL', tools_repo):
            raise RuntimeError('HONEST_CONTROL_RED')
        alive = 0
        for row in source['links']:
            for name in row['cells']:
                case = next(c for c in CASES if c[0] == name)
                red = suite(saved[row['carrier']], [case], row['carrier'], tools_repo)
                alive += (red == 0) if row['polarity'] == 'red' else (red != 0)
        print('ZHIVYH', alive, 'SVJAZI', sum(len(row['cells']) for row in source['links']))
        return int(alive != 0)
    candidate = model if args.model else (tools_repo / 'scripts/done_contract.sh').read_bytes()
    red = suite(candidate, CASES, 'MODEL' if args.model else 'REPO', tools_repo)
    print('KLETKI', len(CASES), 'KRASNYH', red)
    return int(red != 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print('NOT_IMPLEMENTED: ARCH223: ' + str(error), file=sys.stderr)
        sys.exit(2)
