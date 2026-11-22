"""ARCH_CI ancestor cases: real Git histories and SHA-addressed API responses.

Слово консультанта 22.11 ~12:19 (merge-подъём, носитель 187): SHA* поднимается
по ПЕРВОМУ родителю и через merge-коммиты — дельтой merge считается
`git diff <первый родитель>..<merge>` (итоговое состояние дерева); если она
только `.harness/**` — подъём продолжается по первому родителю, предел 50
считает и merge. Merge с продуктовой дельтой к первому родителю НЕ обходится;
продуктовые коммиты второго родителя, не вошедшие в дерево merge, дельту
не красят. Octopus (>2 родителей) отказывает с причиной octopus: его
приёмка отдельно от двухродительских PR-merge (см. sdacha_187.md)."""
import json
import re

from probe import git, put

LIMIT = 50
# Б-1(б) вердикта Rev187Ci: конфигурация субмодуля мира submodule-ignore
# и два значения gitlink src/sub (сдвиг между P и HEAD).
SUBMODULE_GITMODULES = ('[submodule "sub"]\n\tpath = src/sub\n'
                        '\turl = https://example.invalid/src-sub.git\n'
                        '\tignore = all\n')
SUBMODULE_A = '1' * 40
SUBMODULE_B = '2' * 40

# Expected results are literal requirements, not outputs of the model selector.
SPECS = (
    ('one', 0), ('three', 0), ('product', 1), ('docs', 1), ('github', 1),
    ('mixed', 1), ('failure', 1), ('skipped', 1), ('depth', 1),
    ('limit', 0), ('root', 1), ('merge', 0), ('head', 0), ('missing', 1),
    ('tag-head', 0), ('prefix-x', 1), ('prefix-old', 1),
    # Б-1 Rev187Ci: rename продукта в .harness/ и gitlink-сдвиг при
    # ignore=all porcelain считает .harness-only (rc базы 0 вместо 1);
    # guard-rename — охранная: большой .harness-only коммит с rename
    # ВНУТРИ .harness/ принимается, чтобы дверь не стала слишком строгой.
    ('rename', 1), ('submodule-ignore', 1), ('guard-rename', 0),
    # Слово консультанта 22.11 ~12:19: 'merge' перестал быть охранной —
    # дельта к первому родителю .harness-only, продуктовый файл второго
    # родителя в дерево merge НЕ вошёл: итоговое состояние служебное →
    # обходится. Новые клетки merge-подъёма: 2-1/1-1 — цепочки служебных
    # merge (--no-ff, второй родитель — ветка PR) над продуктовым merge
    # с успехом на нём; mixed — служебные коммиты и merge вперемешку;
    # limit-50/51 — предел глубины 50 считает и merge (51-й — отказ
    # с названной причиной); product/real/prefix-x — охранные: merge
    # с продуктовой дельтой к ПЕРВОМУ родителю не обходится (real — дельта
    # принесена именно вторым родителем и ВОШЛА в итог; prefix-x —
    # `.harnessx/` не `.harness/`); octopus — именованный отказ для >2 родителей.
    ('merge-sluzhebnyj-2-1', 0), ('merge-sluzhebnyj-1-1', 0),
    ('merge-mixed', 0), ('merge-limit-50', 0), ('merge-limit-51', 1),
    ('merge-product', 1), ('merge-real', 1), ('merge-prefix-x', 1),
    ('merge-octopus', 1),
)
CASES = tuple((f'done-ancestor-{name}', 'done', f'ancestor-{name}', rc,
               'ARCH_CI' if rc else '', 'done') for name, rc in SPECS)
STABS = {
    **{f'ancestor-any-{name}': (f'done-ancestor-{name}', 'ancestor-any')
       for name in ('product', 'mixed', 'failure', 'skipped')},
    **{f'ancestor-docs-github-{name}': (f'done-ancestor-{name}', 'ancestor-extra-paths')
       for name in ('docs', 'github')},
    'ancestor-unbounded': ('done-ancestor-depth', 'ancestor-unbounded'),
    'ancestor-tag-on-check-sha': ('done-ancestor-tag-head', 'ancestor-tag-check'),
    **{f'ancestor-prefix-{name}': (f'done-ancestor-{name}', 'ancestor-prefix')
       for name in ('prefix-x', 'prefix-old')},
    'ancestor-head-only': ('done-ancestor-one', 'ancestor-head-only'),
    'ancestor-no-sha-diagnostic': ('done-ancestor-three', 'ancestor-no-sha'),
    'ancestor-no-depth-reason': ('done-ancestor-depth', 'ancestor-no-reason'),
    'ancestor-no-root-reason': ('done-ancestor-root', 'ancestor-no-reason'),
    # Б-1 (привязка по коду select, Н-39): потеря флагов полного списка
    # путей; каждый дефект наблюдаем на входе своей клетки.
    'ancestor-rename-detection': ('done-ancestor-rename', 'ancestor-renames'),
    'ancestor-submodule-hidden': ('done-ancestor-submodule-ignore', 'ancestor-submodule-ignore'),
    'ancestor-porcelain-paths': ('done-ancestor-rename', 'ancestor-porcelain'),
    # 22.11 ~12:19, привязка по коду select (Н-39); каждый дефект наблюдаем
    # на входе своей клетки: S-merge-stop (поведение main :324-331 — merge
    # не обходится) — на служебных merge-цепочках; S-merge-second-parent —
    # на merge (второй родитель продуктовый, итог служебный); S-merge-always
    # (бывший ancestor-cross-merge: обход ЛЮБОГО merge без дельты) — на
    # merge-product; S-merge-diff-parent (дельта не к первому родителю) — на
    # merge-real (дельта к второму родителю выглядит .harness-only);
    # S-merge-unbounded (предел 50 не считает merge) — на merge-limit-51.
    'ancestor-merge-stop-2-1': ('done-ancestor-merge-sluzhebnyj-2-1', 'ancestor-merge-stop'),
    'ancestor-merge-stop-1-1': ('done-ancestor-merge-sluzhebnyj-1-1', 'ancestor-merge-stop'),
    'ancestor-merge-second-parent': ('done-ancestor-merge', 'ancestor-merge-second-parent'),
    'ancestor-cross-merge': ('done-ancestor-merge-product', 'ancestor-merge-always'),
    'ancestor-merge-diff-parent': ('done-ancestor-merge-real', 'ancestor-merge-diff-parent'),
    'ancestor-merge-unbounded': ('done-ancestor-merge-limit-51', 'ancestor-merge-unbounded'),
    'ancestor-no-octopus-reason': ('done-ancestor-merge-octopus', 'ancestor-no-reason'),
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


def pr_merge(root, branch, files, message):
    """Merge как PR проекта: --no-ff, второй родитель — ветка PR."""
    git(root, 'checkout', '-q', '-b', branch)
    commit(root, files, message + ' (PR branch)')
    git(root, 'checkout', '-q', 'main')
    git(root, 'merge', '--no-ff', '-qm', message, branch)
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
    product_files = {'app/identity/model.js': 'module.exports = 187;\n'}
    if name == 'rename':
        # Б-1(а): источник переименования живёт в продукте; байты идентичны,
        # чтобы porcelain diff (diff.renames) видел rename и скрывал старый путь.
        product_files['src/r.js'] = product_files['app/identity/model.js']
    if name == 'guard-rename':
        product_files['.harness/a'] = 'guard source\n'
    if name == 'submodule-ignore':
        # Б-1(б): P несёт .gitmodules (ignore = all) и gitlink src/sub —
        # появись .gitmodules в HEAD, он сам вышел бы из .harness и краснота
        # исчезла бы без ремонта двери.
        for path, text in product_files.items():
            put(root, path, text)
        put(root, '.gitmodules', SUBMODULE_GITMODULES)
        git(root, 'add', '-A')
        git(root, 'update-index', '--add', '--cacheinfo',
            f'160000,{SUBMODULE_A},src/sub')
        git(root, 'commit', '-qm', 'product C after review')
        product = git(root, 'rev-parse', 'HEAD')
    else:
        product = commit(root, product_files, 'product C after review')
    older = git(root, 'rev-parse', product + '^')
    selected = product
    green = product
    reason = ''
    if name == 'root':
        # Same complete tree, genuinely no parents; no fake rev-parse adapter.
        tree = git(root, 'rev-parse', 'HEAD^{tree}')
        root_sha = git(root, 'commit-tree', tree, '-m', 'root without parent')
        git(root, 'update-ref', 'refs/heads/main', root_sha)
        selected, reason = root_sha, 'root'
    elif name == 'merge':
        # (е) 22.11 ~12:19: второй родитель несёт продуктовый коммит, НО в
        # дерево merge он НЕ вошёл — итоговое состояние относительно первого
        # родителя .harness-only → merge обходится, SHA* = продуктовый C
        # (ранее охранная «merge не обходится» — заменена словом консультанта).
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
        selected = product
    elif name in ('merge-sluzhebnyj-2-1', 'merge-sluzhebnyj-1-1', 'merge-mixed',
                  'merge-limit-50', 'merge-limit-51', 'merge-product',
                  'merge-real', 'merge-prefix-x', 'merge-octopus'):
        # Клетки merge-подъёма (слово консультанта 22.11 ~12:19). Хвосты —
        # merge-коммиты PR-формы: --no-ff, первый родитель — main, второй —
        # ветка PR; продуктовый merge несёт успех check-run на себе.
        if name == 'merge-product':
            # (д) охранная: продуктовая дельта к первому родителю — merge
            # НЕ обходится, зачёт по check-run именно на нём.
            selected = pr_merge(root, 'pr-989', {'src/feature/report.js': 'report\n'},
                                'merge PR #989 (product)')
        elif name == 'merge-real':
            # (е) охранная: второй родитель приносит продуктовые коммиты И
            # они ВОШЛИ в итог — дельта к первому родителю продуктовая.
            git(root, 'checkout', '-q', '-b', 'pr-feature', product)
            commit(root, {'src/feature/one.js': 'one\n'}, 'feature one')
            commit(root, {'src/feature/two.js': 'two\n'}, 'feature two')
            git(root, 'checkout', '-q', 'main')
            commit(root, {'.harness/ci-note': 'service before merge\n'}, 'service note')
            git(root, 'merge', '--no-ff', '-qm', 'merge PR feature (product)', 'pr-feature')
            selected = git(root, 'rev-parse', 'HEAD')
        elif name == 'merge-prefix-x':
            # (ж) охранная: граница каталога — `.harnessx/` НЕ `.harness/`.
            selected = pr_merge(root, 'pr-x', {'.harnessx/a': 'outside harness\n'},
                                'merge PR harnessx (boundary)')
        elif name == 'merge-octopus':
            # (з) >2 родителей: консервативный именованный отказ до API;
            # PR-merge из задания имеют ровно двух родителей (см. sdacha).
            git(root, 'checkout', '-q', '-b', 'oct-a', product)
            side_a = commit(root, {'.harness/oct-a': 'side a\n'}, 'octopus side a')
            git(root, 'checkout', '-q', '-b', 'oct-b', product)
            side_b = commit(root, {'.harness/oct-b': 'side b\n'}, 'octopus side b')
            git(root, 'checkout', '-q', 'main')
            put(root, '.harness/oct-a', 'side a\n')
            put(root, '.harness/oct-b', 'side b\n')
            git(root, 'add', '-A')
            tree = git(root, 'write-tree')
            octopus = git(root, 'commit-tree', tree, '-p', product,
                          '-p', side_a, '-p', side_b, '-m', 'octopus merge')
            git(root, 'update-ref', 'refs/heads/main', octopus)
            git(root, 'reset', '-q', '--hard', 'main')
            selected, reason = octopus, 'octopus'
        else:
            green = pr_merge(root, 'pr-989', {'src/feature/report.js': 'report\n'},
                             'merge PR #989 (product)')
            selected = green
            if name == 'merge-mixed':
                # (в) смешанный хвост: обычные служебные коммиты + merge.
                commit(root, {'.harness/ci-note': 'plain 1\n'}, 'service note (no merge)')
                pr_merge(root, 'pr-991', {'.harness/registry/note-991': 'service\n'},
                         'merge PR #991 (harness only)')
                commit(root, {'.harness/ci-note': 'plain 2\n'}, 'service note (no merge)')
            elif name == 'merge-limit-50':
                # (г) 50 служебных merge разрешены.
                for i in range(LIMIT):
                    pr_merge(root, f'pr-t{i:02d}',
                             {f'.harness/registry/tail-{i:02d}': f'tail {i}\n'},
                             f'merge PR tail {i} (harness only)')
            elif name == 'merge-limit-51':
                # (г) 51-й служебный merge — отказ с названной причиной.
                tails = []
                for i in range(LIMIT + 1):
                    tails.append(pr_merge(root, f'pr-t{i:02d}',
                                          {f'.harness/registry/tail-{i:02d}': f'tail {i}\n'},
                                          f'merge PR tail {i} (harness only)'))
                selected, reason = tails[0], 'depth'
            elif name == 'merge-sluzhebnyj-2-1':
                # (а) merge .harness-only → merge .harness-only → merge
                # продукт (успех на нём): SHA* = продуктовый merge.
                pr_merge(root, 'pr-991', {'.harness/registry/note-991': 'service\n'},
                         'merge PR #991 (harness only)')
                pr_merge(root, 'pr-992', {'.harness/registry/note-992': 'service\n'},
                         'merge PR #992 (harness only)')
            else:
                # (б) одиночный служебный merge поверх продуктового merge.
                pr_merge(root, 'pr-995', {'.harness/registry/note-995': 'service\n'},
                         'merge PR #995 (harness only)')
    elif name in ('product', 'docs', 'github', 'mixed', 'prefix-x', 'prefix-old'):
        path = {'product': 'src/y', 'docs': 'docs/y', 'github': '.github/y',
                'mixed': 'src/y', 'prefix-x': '.harnessx/a',
                'prefix-old': '.harness-old/b'}[name]
        files = {path: 'outside harness\n'}
        if name == 'mixed':
            files['.harness/x'] = 'metadata\n'
        selected = commit(root, files, 'non harness boundary')
    elif name == 'rename':
        # Б-1(а): git mv продукта в .harness — полный список обязан видеть
        # ОБЕ стороны переименования, porcelain видит только новую.
        git(root, 'mv', 'src/r.js', '.harness/r.js')
        git(root, 'commit', '-qm', 'move product file into harness')
        selected = git(root, 'rev-parse', 'HEAD')
    elif name == 'submodule-ignore':
        # Б-1(б): HEAD только сдвигает gitlink и добавляет .harness/n;
        # submodule.sub.ignore=all скрывает gitlink из porcelain diff.
        put(root, '.harness/n', 'metadata note\n')
        git(root, 'add', '-A')
        git(root, 'update-index', '--add', '--cacheinfo',
            f'160000,{SUBMODULE_B},src/sub')
        git(root, 'commit', '-qm', 'harness note shifts gitlink')
        selected = git(root, 'rev-parse', 'HEAD')
    elif name == 'guard-rename':
        # Охранная: БОЛЬШОЙ .harness-only коммит (30 новых файлов) с
        # переименованием ВНУТРИ .harness/ — принимается; дверь не запрещает
        # переименования как класс и не режет большие .harness-списки путей.
        git(root, 'mv', '.harness/a', '.harness/b')
        for i in range(30):
            put(root, f'.harness/bulk/{i:02d}', f'bulk {i}\n')
        git(root, 'add', '-A')
        git(root, 'commit', '-qm', 'large harness-only rename inside .harness')
    elif name != 'head':
        count = {'three': 3, 'depth': LIMIT + 1, 'limit': LIMIT}.get(name, 1)
        chain = [product]
        for i in range(count):
            chain.append(commit(root, {'.harness/ci-note': f'{i}\n'}, f'metadata {i}'))
        if name == 'depth':
            selected, reason = chain[1], 'depth'
    final = git(root, 'rev-parse', 'HEAD')
    api = {product: report(product), older: report(older), green: report(green)}
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
        merge = len(parents) > 1
        if len(parents) > 2:
            return sha, 'octopus'
        if merge and mutant == 'ancestor-merge-stop':
            return sha, ''  # old door: every merge stops the climb
        climb = parents[1] if merge and mutant == 'ancestor-merge-second-parent' else parents[0]
        base = parents[1] if merge and mutant == 'ancestor-merge-diff-parent' else parents[0]
        # Б-1: список путей коммита ПОЛОН — обе стороны переименования и
        # каждый изменённый gitlink; не зависит от rename-детекта и от
        # submodule.*.ignore. Стабы снимают флаги по одному (поведение
        # двери OBJECT); rename-детект стабов закреплён конфигом команды,
        # а не умолчанием станции.
        config = []
        flags = ['--no-renames', '--ignore-submodules=none']
        if mutant == 'ancestor-renames':
            config, flags = ['-c', 'diff.renames=true'], ['--ignore-submodules=none']
        elif mutant == 'ancestor-submodule-ignore':
            flags = ['--no-renames']
        elif mutant == 'ancestor-porcelain':
            config, flags = ['-c', 'diff.renames=true'], []
        paths = git(root, *config, 'diff', *flags, '--name-only', '-z',
                    base, sha).split('\0')
        paths = [path for path in paths if path]
        prefixes = ('.harness/',)
        if mutant == 'ancestor-extra-paths':
            prefixes += ('docs/', '.github/')
        if mutant == 'ancestor-prefix':
            prefixes = ('.harness',)
        always = merge and mutant == 'ancestor-merge-always'
        if not always and (not paths or not all(path.startswith(prefixes) for path in paths)):
            return sha, ''
        counted = not (merge and mutant == 'ancestor-merge-unbounded')
        if counted and skipped == LIMIT and mutant != 'ancestor-unbounded':
            return sha, 'depth'
        if counted:
            skipped += 1
        sha = climb


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
    detail = {'root': 'корневой коммит: root', 'depth': f'лимит глубины: depth {LIMIT}',
              'octopus': 'octopus: более двух родителей'}
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
        words = {'depth': r'лимит|глубин|depth|limit', 'root': r'корнев|root',
                 'octopus': r'octopus|октопус|более двух родител'}[reason]
        return any(re.search(words, line, re.I) for line in lines)
    query = record_path(root).with_suffix('.queries.jsonl')
    queries = [json.loads(line) for line in query.read_text().splitlines()] if query.exists() else []
    return queries == [context['selected']]
