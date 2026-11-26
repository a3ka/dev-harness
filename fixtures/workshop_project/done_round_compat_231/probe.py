#!/usr/bin/env python3
"""231: full done CLI; literal expectations, real Git, addressed independent calls."""
import argparse
import hashlib
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = '568f0ea63271e3461b574105cba8faec7563a8fd'
spec = importlib.util.spec_from_file_location('round224', HERE.parent / 'svezhest_verdikta_done_224/probe.py')
prior = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
g, put, commit, run, checked = prior.g, prior.put, prior.commit, prior.run, prior.checked
# Entries: (suffix, first line, call or None). Expectations are independent literals.
WORLDS = {
    'back181': ([('1', 'FAIL', None), ('2', 'FAIL', None), ('5', 'accept', None)], 0, ''),
    'back179': ([('1', 'FAIL', None), ('2', 'FAIL', None), ('5', 'accept', None)], 0, ''),
    'mobile218': ([('', 'FAIL', None), ('v2', 'FAIL', None), ('v3', 'FAIL', None), ('v4', 'FAIL', None), ('v5', 'accept', None)], 0, ''),
    'krug': ([('krug2', 'FAIL', None), ('krug12', 'accept', None)], 0, ''),
    'bare': ([('', 'accept', None)], 0, ''),
    'bare-fail': ([('', 'FAIL', None)], 1, 'LATE'),
    'bare-duplicate': ([('', 'accept', None), ('1', 'accept', None)], 1, 'VERDICT_ROUND_DUPLICATE'),
    'old-call-equal': ([('2', 'accept', '2')], 0, ''),
    'old-conflict-low': ([('2', 'accept', '1')], 1, 'VERDICT_ROUND_CONFLICT'),
    'old-conflict-high': ([('2', 'accept', '3')], 1, 'VERDICT_ROUND_CONFLICT'),
    'old-no-call': ([('2', 'accept', None)], 0, ''),
    'v-no-call': ([('v2', 'accept', None)], 0, ''),
    'numeric-fail': ([('2', 'accept', None), ('10', 'FAIL', None)], 1, 'LATE'),
    'numeric-accept': ([('2', 'FAIL', None), ('10', 'accept', None)], 0, ''),
    'three-digits': ([('99', 'FAIL', None), ('100', 'accept', None)], 0, ''),
    'nine-digits': ([('999999999', 'accept', None)], 0, ''),
    'ten-digits': ([('1000000000', 'accept', None)], 1, 'VERDICT_ROUND_INVALID'),
    'old-zero': ([('0', 'accept', None)], 1, 'VERDICT_ROUND_INVALID'),
    'old-leading-zero': ([('01', 'accept', None)], 1, 'VERDICT_ROUND_INVALID'),
    'old-empty': ([('@impl-', 'accept', None)], 1, 'VERDICT_ROUND_INVALID'),
    'v-zero': ([('v0', 'accept', None)], 1, 'VERDICT_ROUND_INVALID'),
    'krug-zero': ([('krug0', 'accept', None)], 1, 'VERDICT_ROUND_INVALID'),
    'krug-leading-zero': ([('krug01', 'accept', None)], 1, 'VERDICT_ROUND_INVALID'),
    'unknown': ([('2', 'accept', None), ('unknown', 'accept', None)], 1, 'VERDICT_ROUND_MISSING'),
    'plain-call-high': ([('v1', 'accept', '2')], 0, ''),
    'plain-call-low': ([('v5', 'accept', '1')], 0, ''),
    'plain-v': ([('@v1', 'accept', '2')], 0, ''),
    'plain-order': ([('v1', 'FAIL', '10'), ('v2', 'accept', '2')], 1, 'LATE'),
    'same-call': ([('v1', 'accept', '2'), ('v2', 'accept', '2')], 1, 'VERDICT_ROUND_DUPLICATE'),
    'explicit-conflict': ([('v1-vyzov2', 'accept', '3')], 1, 'VERDICT_ROUND_CONFLICT'),
    'explicit-equal': ([('v1-vyzov2', 'accept', '2')], 0, ''),
    'repeat-call': ([('v1', 'accept', '2; вызов=2')], 1, 'VERDICT_ROUND_CONFLICT'),
    'invalid-call': ([('v1', 'accept', '02')], 1, 'VERDICT_ROUND_CONFLICT'),
    'live227': ([('v1', 'accept', '2')], 0, ''),
}
PRODUCTS = {
    'product-station': ('ПРОДУКТ: станция', 0, ''),
    'product-live215': ('ПРОДУКТ: станция.', 0, ''),
    'product-double-dot': ('ПРОДУКТ: станция..', 1, 'GRAMMAR'),
    'product-dot-x': ('ПРОДУКТ: станция.x', 1, 'GRAMMAR'),
    'product-tail': ('ПРОДУКТ: станция text', 1, 'GRAMMAR'),
    'product-space': ('ПРОДУКТ: станция. ', 1, 'GRAMMAR'),
    'product-leading-space': ('ПРОДУКТ:  станция.', 1, 'GRAMMAR'),
    'product-case': ('ПРОДУКТ: Станция.', 1, 'GRAMMAR'),
    'product-owner': ('ПРОДУКТ: vendor/repo', 1, 'EXTERNAL'),
    # This already-conformant repository identifier is NOT silently renamed.
    'product-owner-dot': ('ПРОДУКТ: vendor/repo.', 1, 'EXTERNAL'),
}
WORLDS.update({
    'config-name-added': ([('z2', 'FAIL', None), ('z10', 'accept', None)], 0, ''),
    'config-name-removed': ([('2', 'FAIL', None), ('10', 'accept', None)], 1, 'VERDICT_ROUND_INVALID'),
    'config-call-disabled': ([('v1', 'accept', '2')], 1, 'VERDICT_ROUND_CONFLICT'),
})
PRODUCTS.update({
    'product-config-added': ('ПРОДУКТ: мастерская', 0, ''),
    'product-config-removed': ('ПРОДУКТ: станция.', 1, 'GRAMMAR'),
})
CONFIG_CASES = ('config-broken', 'config-empty', 'config-missing', 'config-schema',
                'config-worktree', 'config-index', 'config-author', 'config-environment',
                'config-equivalent')
CASES = tuple(role + '-' + name for role in ('review', 'adversary') for name in WORLDS) + tuple(PRODUCTS)
CASES += CONFIG_CASES


def blob(ref, path):
    return checked(['git', '-C', ROOT, 'show', ref + ':' + path]) + '\n'


def filename(nn, suffix):
    if suffix.startswith('@'):
        return f'contracts-{nn}-{suffix[1:]}.md'
    return f'contracts-{nn}-impl' + ('-' + suffix if suffix else '') + '.md'


def make_world(work, case):
    product = case in PRODUCTS
    role, name = ('review', case) if product else case.split('-', 1)
    # Names/topologies from backend and mobile, with real profile workflowPaths;
    # no claim that this autonomous world runs a product's architecture engine.
    kind = 'mob' if name in ('back181', 'back179', 'mobile218') else 'station'
    root, target, _ = prior.world201.world(work, 'subject', kind)
    nn = {'back181': '181', 'back179': '179', 'mobile218': '218', 'live227': '227', 'product-live215': '215'}.get(name, '777')
    prefix = '.harness/' if kind != 'station' else ''
    target = prefix + f'contracts/{nn}-work.md'
    risk = role == 'adversary'
    body = prior.world201.contract_text('рисковый' if risk else 'обычный', 'станция')
    if product:
        line, expected, marker = PRODUCTS[case]
        body = body.replace('ПРОДУКТ: станция', line)
    else:
        entries, expected, marker = WORLDS[name]
    if case == 'product-live215':
        target = 'contracts/215-otkaz-po-soderzhaniyu-zapasnaya.md'
        body = blob('frozen/contracts/215/1^{commit}', target)
        if body.splitlines()[4] != PRODUCTS[case][0]:
            raise RuntimeError('LIVE215_DRIFT')
        # Full original contract bytes remain unchanged, including its wiring.
        guard = 'fixtures/workshop_project/otkaz_po_soderzhaniyu_215/red_otkaz_po_soderzhaniyu_215.sh'
        put(root, guard, blob(BASE, guard))
        put(root, 'roles/orchestrator.md', blob(BASE, 'roles/orchestrator.md'))
        put(root, '.github/workflows/toy.yml', 'name: fixture\non: push\njobs:\n  check:\n    runs-on: ubuntu-latest\n    steps:\n      - run: bash ' + guard + '\n')
        risk = True
    put(root, target, body)
    for writer, reader in (('freeze_contract.sh', 'reader.sh'), ('lib_registry.sh', 'spawner.sh'), ('done_contract.sh', 'speccer.sh')):
        put(root, 'scripts/' + writer, '#!/usr/bin/env bash\nexit 0\n')
        put(root, 'scripts/' + reader, '#!/usr/bin/env bash\nexit 0\n')
        put(root, 'scripts/consumers.d/' + writer + '__' + reader.replace('.', '_') + '.tsv', 'scripts/' + writer + '\tscripts/' + reader + '\n')
    commit(root, 'world before freeze')
    put(root, 'app/identity/model.js', 'module.exports = 2;\n')
    commit(root, 'freeze original contract')
    g(root, 'tag', '-a', f'frozen/contracts/{nn}/1', '-m', 'fixture freeze')
    put(root, 'app/identity/model.js', 'module.exports = 3;\n')
    obj = commit(root, 'real implementation')
    if risk:
        other = 'review' if role == 'adversary' else 'adversary'
        put(root, prefix + f'verdicts/{other}/contracts-{nn}-impl-v1.md', f'accept\nOBJECT={obj}\n')
        commit(root, 'independent judge')
    entries = [('v1', 'accept', None)] if product else entries
    paths = []
    base = g(root, 'rev-parse', 'HEAD')
    carrier_commits = []
    for index, (suffix, first, call) in enumerate(entries):
        g(root, 'switch', '-q', '-c', 'carrier' + str(index), base)
        path = prefix + f'verdicts/{role}/' + filename(nn, suffix)
        text = first + '\nOBJECT=' + obj + '\n'
        if call is not None:
            text += 'СУД: фаза=реализация; вызов=' + call + '\n'
        if name == 'live227':
            original = blob(BASE, 'verdicts/review/contracts-227-impl-v1.md')
            old = next(x[7:] for x in original.splitlines() if x.startswith('OBJECT='))
            text = original.replace(old, obj)
            if role == 'adversary':
                # Same unmodified record grammar at the other shared consumer.
                text = text.replace('роль=reviewer;', 'роль=adversary;')
        put(root, path, text)
        paths.append(path)
        carrier_commits.append(commit(root, 'judgment ' + str(index)))
    if len(carrier_commits) > 1:
        for a, b in zip(carrier_commits, carrier_commits[1:]):
            for x, y in ((a, b), (b, a)):
                if run(['git', '-C', root, 'merge-base', '--is-ancestor', x, y]).returncode != 1:
                    raise RuntimeError('CARRIERS_NOT_PARALLEL')
    g(root, 'switch', '-q', 'main')
    for index in range(len(entries)):
        g(root, 'merge', '-q', '--no-ff', 'carrier' + str(index), '-m', 'land judgment')
    if marker == 'LATE':
        path = next(p for p, entry in zip(paths, entries) if entry[1] == 'FAIL')
        marker = (f'done: свежий вердикт адверсария {path} не accept' if role == 'adversary' else
                  ('done: вердикт ревьюера FAIL' if len(paths) == 1 else
                   'done: несколько вердиктов, свежий ' + Path(path).name + ' не accept'))
    elif marker.startswith('VERDICT_ROUND_'):
        # Duplicate adds a key before the path; validate the whole diagnostic grammar.
        marker = 'done: ' + marker + ': ' + role + ': '
    elif marker == 'GRAMMAR':
        marker = 'done: строка ПРОДУКТ: вне грамматики: ' + PRODUCTS[case][0]
    elif marker == 'EXTERNAL':
        marker = f'done: OBJECT {obj} разрешается в репо станции, а контракт объявил продукт {PRODUCTS[case][0][9:]} — OBJECT внешнего предмета обязан быть SHA продукта'
    return root, target, expected, marker, f'done/contracts/{nn}/1', g(root, 'rev-parse', 'HEAD')


POLICY_PATH = 'config/done_forms.json'
SCHEMA_PATH = 'config/done_forms.schema.json'
_original_install = prior.install


def install_policy(work, carrier, tools_repo):
    subject = _original_install(work, carrier, tools_repo)
    tools = subject.parents[1]
    # Real installed repository, separate from the author's project.
    g(tools, 'init', '-q', '-b', 'main')
    for path in (POLICY_PATH, SCHEMA_PATH, 'ops/server/validators.tsv'):
        put(tools, path, (ROOT / path).read_text())
    commit(tools, 'installed policy')
    return subject


prior.install = install_policy
_original_world = make_world


def make_world(work, case):
    if case not in CONFIG_CASES:
        return _original_world(work, case)
    root, target, _, _, tag, _ = _original_world(work, 'product-station')
    # Author's committed/dirty config and ambient config are never authoritative.
    put(root, POLICY_PATH, '{}\n')
    head = commit(root, 'untrusted author policy')
    expected = 1 if case in CONFIG_CASES[:4] else 0
    marker = 'done: DONE_FORMS_CONFIG' if expected else ''
    return root, target, expected, marker, tag, head


def prepare_policy(subject, root, case):
    tools = subject.parents[1]
    policy = json.loads((ROOT / POLICY_PATH).read_text())
    name = case.split('-', 1)[1] if case.startswith(('review-', 'adversary-')) else case
    if name == 'config-name-added':
        policy['verdicts'].append({'pattern': r'-impl-z([1-9][0-9]*)\.md$',
                                  'version_group': 1, 'number_group': 0,
                                  'default_version': 1, 'mode': 'legacy'})
    elif name == 'config-name-removed':
        policy['verdicts'] = policy['verdicts'][:3]
    elif name == 'config-call-disabled':
        policy['plain_call_from_record'] = False
    elif case == 'product-config-added':
        policy['station_lines'].append('ПРОДУКТ: мастерская')
    elif case == 'product-config-removed':
        policy['station_lines'].remove('ПРОДУКТ: станция.')
    text = json.dumps(policy, ensure_ascii=False, indent=4 if case == 'config-equivalent' else None) + '\n'
    if case == 'config-broken':
        text = '{'
    elif case == 'config-empty':
        text = ''
    elif case == 'config-schema':
        text = '{}\n'
    put(tools, POLICY_PATH, text)
    if case == 'config-missing':
        (tools / POLICY_PATH).unlink()
    g(tools, 'add', '-A')
    g(tools, 'commit', '-q', '--allow-empty', '-m', 'policy world ' + case)
    if case in ('config-worktree', 'config-index'):
        put(tools, POLICY_PATH, '{}\n')
        if case == 'config-index':
            g(tools, 'add', POLICY_PATH)
    # Always present an alternative ambient policy, even for honest controls.
    os.environ['DONE_FORMS_CONFIG'] = str(root / POLICY_PATH)


def suite(carrier, cases, label, tools_repo):
    red = 0
    with tempfile.TemporaryDirectory(prefix='compat231-', dir=os.environ['TMPDIR']) as temp:
        work = Path(temp)
        subject = prior.install(work, carrier, tools_repo)
        for index, case in enumerate(cases):
            home = work / str(index)
            home.mkdir()
            root, target, expected, marker, tag, head = make_world(home, case)
            prepare_policy(subject, root, case)
            env = {k: v for k, v in os.environ.items() if not k.startswith(('GIT_', 'HARNESS_PROJECT_'))}
            env['GIT_CONFIG_GLOBAL'] = env['GIT_CONFIG_SYSTEM'] = '/dev/null'
            result = run(['bash', subject, target, 'fixture done', root], cwd=root, env=env)
            if result.returncode not in (0, 1):
                raise RuntimeError('SUBJECT_ENV ' + case + repr(result.stderr))
            errors = []
            if result.returncode != expected:
                errors.append('RC')
            stderr = result.stderr.decode()
            if marker.startswith('done: VERDICT_ROUND_'):
                tail = r'[0-9]+: ' if 'DUPLICATE' in marker else ''
                pattern = re.escape(marker) + tail + r'(?:\.harness/)?verdicts/' + case.split('-', 1)[0] + r'/contracts-[0-9]{3}-[^/\n]+\.md\n'
                if not re.fullmatch(pattern, stderr):
                    errors.append('DIAGNOSIS')
            elif marker and stderr != marker + '\n':
                errors.append('DIAGNOSIS')
            if result.stdout or (expected == 0 and result.stderr):
                errors.append('PIPES')
            tags = g(root, 'tag', '-l', 'done/contracts/*').splitlines()
            if expected == 0:
                if tags != [tag] or g(root, 'rev-parse', tag + '^{commit}') != head or g(root, 'cat-file', '-t', tag) != 'tag':
                    errors.append('ANNOTATED_TAG')
            elif tags:
                errors.append('TAG_ON_REFUSAL')
            if g(root, 'rev-parse', 'HEAD') != head:
                errors.append('HEAD_CHANGED')
            red += bool(errors)
            print(label, case, 'RED' if errors else 'GREEN', ','.join(errors), 'RAW_RC', result.returncode,
                  repr(result.stderr) if errors else '', flush=True)
    return red


def carriers():
    source = json.loads((HERE / 'source.json').read_text())
    saved = {}
    for path, sha in source['nositeli'].items():
        data = (HERE / path).read_bytes()
        if hashlib.sha256(data).hexdigest() != sha:
            raise RuntimeError('CARRIER_CHANGED ' + path)
        saved[path] = data
    links = source['stab_vhod']
    if not CASES or len(CASES) != len(set(CASES)) or not links:
        raise RuntimeError('EMPTY_OR_DUPLICATE_CATALOG')
    if any(x['case'] not in CASES or x['stab'] not in saved for x in links):
        raise RuntimeError('UNKNOWN_LINK')
    if (HERE / 'stabs.tsv').read_text() != ''.join(x['stab'] + '\t' + x['case'] + '\n' for x in links):
        raise RuntimeError('STAB_TSV_CHANGED')
    return source, saved


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument('--repo', type=Path)
    for mode in ('model', 'stabs', 'sintaksis', 'catalog', 'regression224'):
        modes.add_argument('--' + mode, action='store_true')
    args = parser.parse_args()
    scratch = ROOT / 'tmp/scratch-arch231'
    scratch.mkdir(parents=True, exist_ok=True)
    os.environ.setdefault('TMPDIR', str(scratch))
    for name in ('git', 'bash', 'jq', 'date', 'stat'):
        if not shutil.which(name):
            raise RuntimeError('MISSING_TOOL ' + name)
    source, saved = carriers()
    model = saved['model/done_contract.sh']
    tools = (args.repo or ROOT).resolve()
    if args.catalog:
        print('KLETKI', len(CASES), 'STABY', len({x['stab'] for x in source['stab_vhod']}), 'SVJAZI', len(source['stab_vhod']))
        print('\n'.join(CASES))
        return 0
    if args.sintaksis:
        for path in saved:
            checked(['bash', '-n', HERE / path])
        for path in ('model/done_contract.sh', 'red_done_round_compat_231.sh'):
            checked(['bash', ROOT / 'scripts/validate_std.sh', 'bash', HERE / path])
        for path in HERE.glob('*.py'):
            compile(path.read_bytes(), str(path), 'exec')
        print('SINTAKSIS', len(saved) + 1, 'SHELLCHECK', 2)
        return 0
    if args.regression224:
        with tempfile.TemporaryDirectory(prefix='regress224-', dir=os.environ['TMPDIR']) as temp:
            subject = prior.install(Path(temp), model, ROOT)
            result = subprocess.run(['bash', str(HERE.parent / 'svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh'), '--repo', str(subject.parents[1])], check=False)
            print('REGRESSION224_RAW_RC', result.returncode)
            return result.returncode
    if args.stabs:
        if suite(model, CASES, 'CONTROL', tools):
            return 1
        alive = 0
        for link in source['stab_vhod']:
            alive += suite(saved[link['stab']], [link['case']], link['stab'], tools) == 0
        print('STABY', len({x['stab'] for x in source['stab_vhod']}), 'SVJAZI', len(source['stab_vhod']), 'ZHIVYH', alive)
        return int(alive != 0)
    candidate = model if args.model else (tools / 'scripts/done_contract.sh').read_bytes()
    red = suite(candidate, CASES, 'MODEL' if args.model else 'REPO', tools)
    print('KLETKI', len(CASES), 'KRASNYH', red)
    return int(red != 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError, ValueError, subprocess.SubprocessError) as error:
        print('NOT_IMPLEMENTED:', str(error), file=sys.stderr)
        sys.exit(2)
