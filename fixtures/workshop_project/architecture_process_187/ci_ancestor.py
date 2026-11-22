"""ARCH_CI ancestor cases: real Git histories and SHA-addressed API responses."""
import json
import re

from probe import git, put

LIMIT = 50
# Expected results are literal requirements, not outputs of the model selector.
SPECS = (
    ('one', 0), ('three', 0), ('product', 1), ('docs', 1), ('github', 1),
    ('mixed', 1), ('failure', 1), ('skipped', 1), ('depth', 1),
    ('limit', 0), ('root', 1), ('merge', 1), ('head', 0), ('missing', 1),
    ('tag-head', 0), ('prefix-x', 1), ('prefix-old', 1),
)
CASES = tuple((f'done-ancestor-{name}', 'done', f'ancestor-{name}', rc,
               'ARCH_CI' if rc else '', 'done') for name, rc in SPECS)
STABS = {
    **{f'ancestor-any-{name}': (f'done-ancestor-{name}', 'ancestor-any')
       for name in ('product', 'mixed', 'failure', 'skipped')},
    **{f'ancestor-docs-github-{name}': (f'done-ancestor-{name}', 'ancestor-extra-paths')
       for name in ('docs', 'github')},
    'ancestor-cross-merge': ('done-ancestor-merge', 'ancestor-cross-merge'),
    'ancestor-unbounded': ('done-ancestor-depth', 'ancestor-unbounded'),
    'ancestor-tag-on-check-sha': ('done-ancestor-tag-head', 'ancestor-tag-check'),
    **{f'ancestor-prefix-{name}': (f'done-ancestor-{name}', 'ancestor-prefix')
       for name in ('prefix-x', 'prefix-old')},
    'ancestor-head-only': ('done-ancestor-one', 'ancestor-head-only'),
    'ancestor-no-sha-diagnostic': ('done-ancestor-three', 'ancestor-no-sha'),
    'ancestor-no-depth-reason': ('done-ancestor-depth', 'ancestor-no-reason'),
    'ancestor-no-root-reason': ('done-ancestor-root', 'ancestor-no-reason'),
}


def record_path(root):
    return root.parent / (root.name + '-ci-187.json')


def oracle_path(root):
    return root.parent / (root.name + '-ancestor-oracle.json')



def report(sha, conclusion='success'):
    return {'total_count': 1, 'check_runs': [{
        'id': 187, 'name': 'arch', 'status': 'completed',
        'conclusion': conclusion, 'head_sha': sha}]}


def commit(root, files, message):
    for path, text in files.items():
        put(root, path, text)
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', message)
    return git(root, 'rev-parse', 'HEAD')


SERVER = '''#!/usr/bin/env python3
import json, os, re, sys
from pathlib import Path
url = sys.argv[-1]
m = re.search(r"/commits/([0-9a-f]{40})/check-runs\\?", url)
if not m:
    raise SystemExit(31)
path = Path(os.environ['ARCH187_CURL_RESPONSE'])
with path.with_suffix('.queries.jsonl').open('a') as out:
    out.write(json.dumps(m.group(1)) + '\\n')
data = json.loads(path.read_text())
print(json.dumps(data.get(m.group(1), {'total_count': 0, 'check_runs': []})))
'''


def prepare(root, variation):
    if not variation.startswith('ancestor-'):
        return
    name = variation.removeprefix('ancestor-')
    # The normal prepare already gave us a frozen scenario + reviewer OBJECT.
    # A real product commit C follows it, so all later done checks stay applicable.
    product = commit(root, {'app/identity/model.js': 'module.exports = 187;\n'},
                     'product C after review')
    older = git(root, 'rev-parse', product + '^')
    selected = product
    reason = ''
    if name == 'root':
        # Same complete tree, genuinely no parents; no fake rev-parse adapter.
        tree = git(root, 'rev-parse', 'HEAD^{tree}')
        root_sha = git(root, 'commit-tree', tree, '-m', 'root without parent')
        git(root, 'update-ref', 'refs/heads/main', root_sha)
        selected, reason = root_sha, 'root'
    elif name == 'merge':
        # Second parent has product data absent from the resulting merge tree.
        # Diff against first parent is harness-only: naive first-parent skipping
        # would incorrectly accept C, despite the second parent's product work.
        first = commit(root, {'.harness/merge-note': 'first\n'}, 'first parent')
        put(root, '.harness/merge-note', 'merge metadata\n')
        git(root, 'add', '-A')
        tree = git(root, 'write-tree')
        put(root, 'src/second-parent.js', 'product\n')
        git(root, 'add', '-A')
        side_tree = git(root, 'write-tree')
        side = git(root, 'commit-tree', side_tree, '-p', product, '-m', 'side product')
        merge = git(root, 'commit-tree', tree, '-p', first, '-p', side, '-m', 'merge')
        git(root, 'read-tree', tree)
        (root / 'src/second-parent.js').unlink()
        git(root, 'update-ref', 'refs/heads/main', merge)
        selected = merge
    elif name in ('product', 'docs', 'github', 'mixed', 'prefix-x', 'prefix-old'):
        path = {'product': 'src/y', 'docs': 'docs/y', 'github': '.github/y',
                'mixed': 'src/y', 'prefix-x': '.harnessx/a',
                'prefix-old': '.harness-old/b'}[name]
        files = {path: 'outside harness\n'}
        if name == 'mixed':
            files['.harness/x'] = 'metadata\n'
        selected = commit(root, files, 'non harness boundary')
    elif name != 'head':
        count = {'three': 3, 'depth': LIMIT + 1, 'limit': LIMIT}.get(name, 1)
        chain = [product]
        for i in range(count):
            chain.append(commit(root, {'.harness/ci-note': f'{i}\n'}, f'metadata {i}'))
        if name == 'depth':
            selected, reason = chain[1], 'depth'
    final = git(root, 'rev-parse', 'HEAD')
    api = {product: report(product), older: report(older)}
    if name in ('failure', 'skipped'):
        api[product] = report(product, 'failure' if name == 'failure' else 'skipped')
    if name == 'missing':
        api[product] = {'total_count': 0, 'check_runs': []}
    if final != product:
        api[final] = report(final, 'skipped')
    record_path(root).write_text(json.dumps(api))
    oracle_path(root).write_text(json.dumps({'final': final, 'selected': selected,
                                           'reason': reason}))
    # Git effects must be on HEAD, never the SHA whose API response was green.
    if name != 'root':
        git(root, 'push', '-q', 'origin', 'main')
    curl = root.parent / (root.name + '-bin') / 'curl'
    curl.write_text(SERVER)
    curl.chmod(0o755)


def expectation(root, variation):
    return (json.loads(oracle_path(root).read_text())
            if variation.startswith('ancestor-') else None)


def select(root, mutant=''):
    sha = git(root, 'rev-parse', 'HEAD')
    if mutant == 'ancestor-head-only':
        return sha, ''
    skipped = 0
    while True:
        parents = git(root, 'rev-list', '--parents', '-n', '1', sha).split()[1:]
        if not parents:
            return sha, 'root'
        if len(parents) != 1 and mutant != 'ancestor-cross-merge':
            return sha, ''  # check the merge itself, never a parent
        paths = git(root, 'diff', '--name-only', '-z', parents[0], sha).split('\0')
        paths = [path for path in paths if path]
        prefixes = ('.harness/',)
        if mutant == 'ancestor-extra-paths':
            prefixes += ('docs/', '.github/')
        if mutant == 'ancestor-prefix':
            prefixes = ('.harness',)
        if not paths or not all(path.startswith(prefixes) for path in paths):
            return sha, ''
        if skipped == LIMIT and mutant != 'ancestor-unbounded':
            return sha, 'depth'
        skipped += 1
        sha = parents[0]


def model(root, mutant=''):
    final = git(root, 'rev-parse', 'HEAD')
    selected, reason = select(root, mutant)
    query = record_path(root).with_suffix('.queries.jsonl')
    query.write_text('')
    api = json.loads(record_path(root).read_text())
    if mutant == 'ancestor-any':
        selected = next((sha for sha in git(root, 'rev-list', 'HEAD').splitlines()
                         if any(r.get('conclusion') == 'success'
                                for r in api.get(sha, {}).get('check_runs', []))), selected)
        reason = ''
    ok = False
    if not reason:
        query.write_text(json.dumps(selected) + '\n')
        ok = any(r.get('head_sha') == selected and r.get('name') == 'arch'
                 and r.get('status') == 'completed' and r.get('conclusion') == 'success'
                 for r in api.get(selected, {}).get('check_runs', []))
    detail = {'root': 'корневой коммит: root', 'depth': f'лимит глубины: depth {LIMIT}'}
    suffix = detail.get(reason, 'успешного check-run arch нет' if not ok else 'success')
    if mutant == 'ancestor-no-reason':
        suffix = 'отказ'
    diagnostic = f'ARCH_CI: HEAD={final}; SHA*={selected}; {suffix}'
    if mutant == 'ancestor-no-sha':
        diagnostic = 'ARCH_CI: success'
    return int(not ok), diagnostic


def tag_target(root, mutant):
    return select(root)[0] if mutant == 'ancestor-tag-check' else 'HEAD'


def observed(root, context, output):
    if context is None:
        return True
    lines = [line for line in output.splitlines() if 'ARCH_CI' in line]
    # Match whole SHA tokens on the same diagnostic, not arbitrary nearby prose.
    if not any(all(re.search(r'(?<![0-9a-f])' + sha + r'(?![0-9a-f])', line)
                   for sha in (context['final'], context['selected'])) for line in lines):
        return False
    reason = context['reason']
    if reason:
        words = r'лимит|глубин|depth|limit' if reason == 'depth' else r'корнев|root'
        return any(re.search(words, line, re.I) for line in lines)
    query = record_path(root).with_suffix('.queries.jsonl')
    queries = [json.loads(line) for line in query.read_text().splitlines()] if query.exists() else []
    return queries == [context['selected']]
