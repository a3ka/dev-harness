#!/usr/bin/env python3
"""224: public done CLI in real, independent Git histories, no verdict oracle on disk."""
import argparse
import hashlib
import importlib.util
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
# Reuse only the existing profile/world constructor, never its verdict oracle.
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('world201', HERE.parent / 'done_dver_soderzhatelnaja_201/dver_probe.py')
world201 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(world201)
SCENARIOS = ('parallel', 'late-fail', 'duplicate', 'missing', 'conflict', 'date-order',
             'linear', 'equivalent', 'no-metadata', 'name-date-conflict',
             'second-conflict', 'repeat-call', 'call-explanation', 'second-invalid',
             'singleton-unnumbered')
CASES = tuple(role + '-' + name for role in ('review', 'adversary') for name in SCENARIOS) + (
    'review-old-object', 'adversary-other-object', 'regression-new-freeze',
    'regression-no-object', 'regression-single-fail', 'regression-escalate',
    'regression-bad-first', 'regression-no-freeze', 'regression-empty-reason',
    'regression-uncommitted', 'regression-product', 'regression-product-not-merged',
    'frozen201-risk-same-object', 'frozen201-late-fail', 'historic186', 'historic186-late-fail',
    'historic186-phase-conflict', 'historic186-phase-no-call', 'historic186-review-late-fail',
    'historic129', 'historic129-late-fail', 'historic190', 'historic190-late-fail',
    'historic186-bad-call-name')


def run(args, cwd=None, env=None):
    return subprocess.run([str(a) for a in args], cwd=cwd, env=env, capture_output=True, timeout=60)


def checked(args, cwd=None):
    p = run(args, cwd)
    if p.returncode:
        raise RuntimeError('NOT_IMPLEMENTED: ' + repr(args) + ': ' + repr(p.stderr))
    return p.stdout.decode().strip()


def g(root, *args):
    return checked(['git', '-C', root, '-c', 'user.name=Fixture', '-c', 'user.email=fixture@local',
                    '-c', 'commit.gpgsign=false', '-c', 'core.hooksPath=/dev/null', *args])


def put(root, name, text):
    path = root / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def commit(root, message):
    g(root, 'add', '-A')
    g(root, 'commit', '-q', '-m', message)
    return g(root, 'rev-parse', 'HEAD')


def make_world(work, case):
    if case.startswith('frozen201-'):
        label = ('v-riskovyi-sopostavimyj-object' if case.endswith('same-object')
                 else 'v-riskovyi-svezhij-fail')
        root, target, _facts = world201.build(work, label, 'station')
        head = g(root, 'rev-parse', 'HEAD')
        marker = (b'' if case.endswith('same-object') else
                  b'done: ' + 'свежий вердикт адверсария'.encode())
        return root, target, 'fixture done', int(bool(marker)), marker, 'done/contracts/777/1', head
    product = case.startswith('regression-product')
    root, target, _ = world201.world(work, 'subject', 'mob' if product else 'station')
    prefix = '.harness/' if product else ''
    nn = '777'
    tag = f'done/contracts/{nn}/1'
    risk = case.startswith(('adversary-', 'historic186'))
    text = world201.contract_text('рисковый' if risk else 'обычный', 'станция')
    put(root, target, text)
    # Real check_consumers executes; unchanged placeholder writers lie before F.
    for writer, reader in (('freeze_contract.sh', 'reader.sh'), ('lib_registry.sh', 'spawner.sh'), ('done_contract.sh', 'speccer.sh')):
        put(root, 'scripts/' + writer, '#!/usr/bin/env bash\nexit 0\n')
        put(root, 'scripts/consumers.d/' + writer + '__' + reader.replace('.', '_') + '.tsv', 'scripts/' + writer + '\tscripts/' + reader + '\n')
        put(root, 'scripts/' + reader, '#!/usr/bin/env bash\nexit 0\n')
    old = commit(root, 'before freeze')
    put(root, 'app/identity/model.js', 'module.exports = 2;\n')
    frozen = commit(root, 'freeze text')
    if case != 'regression-no-freeze':
        g(root, 'tag', '-a', f'frozen/contracts/{nn}/1', '-m', 'fixture freeze')
    put(root, 'app/identity/model.js', 'module.exports = 3;\n')
    obj = commit(root, 'implementation')
    role = 'adversary' if risk else 'review'
    scenario = case.partition('-')[2]
    verdict_dir = prefix + 'verdicts/' + role + '/'
    newer = verdict_dir + f'contracts-{nn}-impl-v4.md'
    older = verdict_dir + f'contracts-{nn}-impl-v3.md'
    reason = 'fixture done'

    def verdict(path, first, number, date, object_id=obj, metadata=True):
        body = first + '\n'
        if object_id is not None:
            body += 'OBJECT=' + object_id + '\n'
        if metadata:
            body += f'СУД: repo=fixture; предмет={nn}; фаза=реализация; роль={role}; вызов={number}/9; дата={date}; сессия=fixture\n'
        put(root, path, body)

    expected_rc, marker = 0, ''
    if case.startswith('historic'):
        # Transport actual frozen-positive carriers, not only their filenames.
        source_id = case[8:11]
        if source_id == '186':
            paths = [('adversary', suffix) for suffix in ('v2', 'v2-vyzov1', 'v2-vyzov2')]
            paths += [('review', suffix) for suffix in ('v1', 'v2', 'v3')]
        else:
            paths = [('review', 'v' + str(n)) for n in range(1, 5)]
        blobs = []
        for judge, suffix in paths:
            path = f'verdicts/{judge}/contracts-{source_id}-impl-{suffix}.md'
            result = run(['git', '-C', REPO, 'show', '6c021128eb8ecde054b26ad22700910412d88f7b:' + path])
            if result.returncode:
                raise RuntimeError('NOT_IMPLEMENTED: historical blob ' + path + repr(result.stderr))
            blobs.append(result.stdout.decode())
        originals = [next(line[7:] for line in blob.splitlines() if line.startswith('OBJECT='))
                     for blob in blobs]
        identities = {}
        # Old implementation → old review repair → new implementation → repair.
        for i in ((0, 4, 1, 2) if source_id == '186' else range(4)):
            put(root, 'app/identity/model.js', f'module.exports = {i + 4};\n')
            identities[originals[i]] = commit(root, 'historical implementation ' + str(i))
        for i, ((judge, suffix), blob) in enumerate(zip(paths, blobs)):
            transported = blob.replace(source_id, '777')
            for original, replacement in identities.items():
                transported = transported.replace(original, replacement)
            if i == 2:
                if case == 'historic186-late-fail':
                    transported = transported.replace('accept\n', 'FAIL\n', 1)
                elif case == 'historic186-phase-conflict':
                    transported = transported.replace('фаза=реализация v2 ', 'фаза=реализация v3 ')
                elif case == 'historic186-phase-no-call':
                    transported = transported.replace('вызов=2/2 ', 'примечание=повтор ')
            if i == 2 and case == 'historic186-bad-call-name':
                suffix = 'v2-vyzov02'
            if i == 5 and case == 'historic186-review-late-fail':
                transported = transported.replace('accept\n', 'FAIL\n', 1)
            if source_id != '186' and i == 3 and case.endswith('late-fail'):
                transported = transported.replace('accept\n', 'FAIL\n', 1)
            put(root, f'verdicts/{judge}/contracts-777-impl-{suffix}.md', transported)
            commit(root, 'historical verdict ' + judge + suffix)
        if case == 'historic186-late-fail':
            expected_rc, marker = 1, 'done: свежий вердикт адверсария verdicts/adversary/contracts-777-impl-v2-vyzov2.md не accept'
        elif case == 'historic186-review-late-fail':
            expected_rc, marker = 1, 'done: несколько вердиктов, свежий contracts-777-impl-v3.md не accept'
        elif case in ('historic186-phase-conflict', 'historic186-phase-no-call'):
            expected_rc, marker = 1, 'done: VERDICT_ROUND_CONFLICT: adversary:'
        elif source_id != '186' and case.endswith('late-fail'):
            expected_rc, marker = 1, 'done: несколько вердиктов, свежий contracts-777-impl-v4.md не accept'
        elif case == 'historic186-bad-call-name':
            expected_rc, marker = 1, 'done: VERDICT_ROUND_INVALID: adversary:'
    elif case.startswith('regression-') or case in ('review-old-object', 'adversary-other-object'):
        verdict(newer, 'accept', 4, '2026-11-25', old if case == 'review-old-object' else obj)
        if risk:
            put(root, prefix + 'verdicts/review/contracts-777-impl-v4.md', f'accept\nOBJECT={obj}\n')
            verdict(newer, 'accept', 4, '2026-11-25', frozen)
        if case == 'regression-no-object':
            verdict(newer, 'accept', 4, '2026-11-25', None)
        if case in ('regression-single-fail', 'regression-escalate', 'regression-bad-first'):
            first = {'regression-single-fail': 'FAIL', 'regression-escalate': 'ESCALATE', 'regression-bad-first': 'accepted'}[case]
            verdict(newer, first, 4, '2026-11-25')
        if case == 'regression-product-not-merged':
            g(root, 'switch', '-q', '-c', 'unmerged')
            put(root, 'app/identity/model.js', 'module.exports = 999;\n')
            side = commit(root, 'unmerged object')
            g(root, 'switch', '-q', 'main')
            verdict(newer, 'accept', 4, '2026-11-25', side)
        if case == 'regression-new-freeze':
            # OBJECT carries F2, but the verdict carrier does not: isolate CID/F.
            (root / newer).unlink()
            g(root, 'switch', '-q', '-c', 'future-freeze')
            put(root, 'app/identity/model.js', 'module.exports = 4;\n')
            future = commit(root, 'future freeze on independent branch')
            g(root, 'tag', '-a', 'frozen/contracts/777/2', '-m', 'new version')
            g(root, 'switch', '-q', 'main')
            verdict(newer, 'accept', 4, '2026-11-25', future)
        commit(root, 'one verdict')
        markers = {
            'review-old-object': 'не связан с последней заморозкой',
            'adversary-other-object': 'требуется тот же объект',
            'regression-no-object': 'без строки OBJECT=',
            'regression-single-fail': 'done: вердикт ревьюера FAIL',
            'regression-escalate': 'done: вердикт ревьюера ESCALATE',
            'regression-bad-first': 'done: вердикт вне грамматики: accepted',
            'regression-no-freeze': 'done: нет заморозки frozen/contracts/777/*',
            'regression-empty-reason': 'done: причина пуста',
            'regression-uncommitted': 'done: контракт не закоммичен на HEAD:',
            'regression-new-freeze': 'предшествует последней заморозке',
            'regression-product-not-merged': 'не предок HEAD — реализация не влита в main продукта',
        }
        marker = markers.get(case, '')
        expected_rc = int(bool(marker))
        if case == 'regression-new-freeze':
            g(root, 'merge', '-q', '--no-ff', 'future-freeze', '-m', 'land new freeze')
        if case == 'regression-empty-reason':
            reason = ' \t '
        if case == 'regression-uncommitted':
            put(root, target, text + '\nworking change\n')
    else:
        if risk:
            put(root, prefix + 'verdicts/review/contracts-777-impl-v4.md', f'accept\nOBJECT={obj}\n')
            objbase = commit(root, 'independent reviewer')
        else:
            objbase = obj
        old_first, new_first = ('accept', 'FAIL') if scenario == 'late-fail' else ('FAIL', 'accept')
        if scenario in ('equivalent', 'no-metadata', 'duplicate', 'second-conflict',
                        'repeat-call', 'call-explanation', 'second-invalid', 'singleton-unnumbered'):
            old_first = 'accept'
            new_first = '  AcCePt \r' if scenario == 'equivalent' else 'accept'
        g(root, 'switch', '-q', '-c', 'round3', objbase)
        verdict(older, old_first, 3, '2026-11-26' if scenario == 'date-order' else '2026-11-24', metadata=scenario != 'no-metadata')
        c3 = commit(root, 'round three')
        if scenario == 'linear':
            g(root, 'switch', '-q', '-c', 'round4')
        else:
            g(root, 'switch', '-q', '-c', 'round4', objbase)
        if scenario == 'duplicate':
            newer = verdict_dir + f'contracts-{nn}-impl-v3-extra.md'
        if scenario == 'missing':
            newer = verdict_dir + f'contracts-{nn}-impl-final.md'
        if scenario == 'name-date-conflict':
            newer = verdict_dir + f'contracts-{nn}-impl-v4-2026-11-24.md'
        verdict(newer, new_first, 3 if scenario in ('duplicate', 'conflict') else 4, '2026-11-25', metadata=scenario != 'no-metadata')
        c4 = commit(root, 'round four')
        if scenario in ('second-conflict', 'repeat-call', 'call-explanation', 'second-invalid',
                        'singleton-unnumbered'):
            # Start from one honest accept; isolate metadata from ancestry.
            (root / newer).write_text(f'accept\nOBJECT={obj}\n' + {
                'second-conflict': 'СУД: вызов=4/9; вызов=3/9\n',
                'repeat-call': 'СУД: вызов=4/9; вызов=4/9\n',
                'call-explanation': 'СУД: вызов=4/9 (повтор; это вызов без нового поля); пояснение=свободный текст\n',
                'second-invalid': 'СУД: вызов=4/9; вызов=04/9\n',
                'singleton-unnumbered': 'СУД: пояснение=единственный вердикт на OBJECT\n',
            }[scenario])
            if scenario == 'singleton-unnumbered':
                renamed = verdict_dir + 'contracts-777-impl-final.md'
                (root / newer).rename(root / renamed)
                newer = renamed
            c4 = commit(root, 'metadata branch')
        if scenario != 'linear':
            for a, b in ((c3, c4), (c4, c3)):
                p = run(['git', '-C', root, 'merge-base', '--is-ancestor', a, b])
                if p.returncode != 1:
                    raise RuntimeError('NOT_IMPLEMENTED: parallel carriers are not incomparable')
        g(root, 'switch', '-q', 'main')
        g(root, 'merge', '-q', '--no-ff', 'round3', '-m', 'land carrier three')
        g(root, 'merge', '-q', '--no-ff', 'round4', '-m', 'land carrier four')
        if scenario == 'singleton-unnumbered':
            g(root, 'rm', '-q', older)
            commit(root, 'one unnumbered verdict')
        if (root / older).exists():
            os.utime(root / older, (2000000000, 2000000000))
        os.utime(root / newer, (1500000000, 1500000000))
        late = (f'done: свежий вердикт адверсария {newer} не accept' if risk else
                f'done: несколько вердиктов, свежий {Path(newer).name} не accept')
        markers = {'late-fail': late, 'duplicate': 'VERDICT_ROUND_DUPLICATE',
                   'missing': 'VERDICT_ROUND_MISSING', 'conflict': 'VERDICT_ROUND_CONFLICT',
                   'date-order': 'VERDICT_ROUND_ORDER', 'name-date-conflict': 'VERDICT_ROUND_CONFLICT',
                   'second-conflict': 'VERDICT_ROUND_CONFLICT', 'repeat-call': 'VERDICT_ROUND_CONFLICT',
                   'second-invalid': 'VERDICT_ROUND_CONFLICT'}
        marker = markers.get(scenario, '')
        if marker.startswith('VERDICT_'):
            marker = f'done: {marker}: {role}:'
        expected_rc = int(bool(marker))
    head = g(root, 'rev-parse', 'HEAD')
    # Capture all expectations before invoking the untrusted door.
    return root, target, reason, expected_rc, marker.encode(), tag, head


def install(work, carrier, tools_repo):
    tools = work / 'tools'
    shutil.copytree(tools_repo / 'scripts', tools / 'scripts')
    (tools / 'scripts/done_contract.sh').write_bytes(carrier)
    checked(['bash', '-n', tools / 'scripts/done_contract.sh'])
    return tools / 'scripts/done_contract.sh'


def suite(carrier, baseline, cases, label, tools_repo):
    red = 0
    with tempfile.TemporaryDirectory(prefix='round224-', dir=os.environ.get('TMPDIR')) as temp:
        work = Path(temp)
        subject = install(work, carrier, tools_repo)
        canon = work / 'tools/scripts/canon224.sh'
        canon.write_bytes(baseline)
        for i, case in enumerate(cases):
            base = work / str(i)
            base.mkdir()
            root, target, reason, expected_rc, marker, tag, head = make_world(base, case)
            env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
            env['GIT_CONFIG_GLOBAL'] = env['GIT_CONFIG_SYSTEM'] = '/dev/null'
            # Regression expected bytes come from the pre-change door, not the model.
            parity = None
            if case.startswith('regression-'):
                parity = run(['bash', canon, target, reason, root], cwd=root, env=env)
                if parity.returncode != expected_rc or (marker and marker not in parity.stderr):
                    raise RuntimeError('NOT_IMPLEMENTED: baseline world mismatch ' + case + repr(parity.stderr))
                if parity.returncode == 0:
                    g(root, 'tag', '-d', tag)
            result = run(['bash', subject, target, reason, root], cwd=root, env=env)
            if case.startswith(('historic', 'frozen201-')):
                print(label, case, 'RAW', result.returncode, repr(result.stdout), repr(result.stderr), flush=True)
            tags = g(root, 'tag', '-l', 'done/contracts/*').splitlines()
            problems = []
            if result.returncode not in (0, 1):
                raise RuntimeError('NOT_IMPLEMENTED: subject environment failure ' + repr(result.stderr))
            if result.returncode != expected_rc:
                problems.append('RC')
            if marker and marker not in result.stderr:
                problems.append('DIAGNOSIS')
            if result.stdout != b'':
                problems.append('STDOUT')
            if expected_rc == 0:
                if tags != [tag] or g(root, 'rev-parse', tag + '^{commit}') != head:
                    problems.append('TAG_TARGET')
                if result.stderr:
                    problems.append('STDERR')
            elif tags:
                problems.append('TAG_ON_REFUSAL')
            if g(root, 'rev-parse', 'HEAD') != head:
                problems.append('HEAD_CHANGED')
            if parity and (result.returncode, result.stdout, result.stderr) != (parity.returncode, parity.stdout, parity.stderr):
                problems.append('BASELINE_BYTES')
            ok = not problems
            red += not ok
            print(label, case, 'GREEN' if ok else 'RED', '' if ok else ','.join(problems) + ' rc=' + str(result.returncode) + ' stderr=' + repr(result.stderr), flush=True)
    return red


def carriers():
    source = json.loads((HERE / 'source.json').read_text())
    saved = {}
    for rel, sha in source['nositeli'].items():
        data = (HERE / rel).read_bytes()
        if hashlib.sha256(data).hexdigest() != sha:
            raise RuntimeError('NOT_IMPLEMENTED: CARRIER_CHANGED ' + rel)
        saved[rel] = data
    if not CASES or len(CASES) != len(set(CASES)):
        raise RuntimeError('NOT_IMPLEMENTED: empty/duplicate catalog')
    if any(link['case'] not in CASES for link in source['stab_vhod']):
        raise RuntimeError('NOT_IMPLEMENTED: unknown link')
    return source, saved


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--repo', type=Path)
    for mode in ('model', 'stabs', 'sintaksis', 'catalog', 'compatibility', 'independent-mutants'):
        group.add_argument('--' + mode, action='store_true')
    args = parser.parse_args()
    for tool in ('git', 'bash', 'jq', 'date', 'stat'):
        if not shutil.which(tool):
            raise RuntimeError('NOT_IMPLEMENTED: missing ' + tool)
    source, saved = carriers()
    model, baseline = saved['model/done_contract.sh'], saved['model/station.sh']
    if args.catalog:
        print('KLETKI', len(CASES), 'STABY', len({x['stab'] for x in source['stab_vhod']}), 'SVJAZI', len(source['stab_vhod']))
        print('\n'.join(CASES))
        for link in source['stab_vhod']:
            print(link['stab'], '->', link['case'])
        return 0
    if args.sintaksis:
        files = [HERE / rel for rel in saved] + [HERE / 'red_svezhest_verdikta_done_224.sh']
        for file in files:
            checked(['bash', '-n', file])
        for file in (HERE / 'model/done_contract.sh', HERE / 'red_svezhest_verdikta_done_224.sh'):
            checked(['bash', REPO / 'scripts/validate_std.sh', 'bash', file])
        for file in (Path(__file__), HERE / 'build.py'):
            compile(file.read_bytes(), str(file), 'exec')
        print('SINTAKSIS', len(files), 'SHELLCHECK', 2)
        return 0
    tools_repo = (args.repo or REPO).resolve()
    if args.compatibility:
        with tempfile.TemporaryDirectory(prefix='compat224-', dir=os.environ.get('TMPDIR')) as temp:
            work = Path(temp)
            subject = install(work, model, tools_repo)
            root, target, facts = world201.build(work, 'v-riskovyi-sopostavimyj-object', 'station')
            result = world201.live(subject.parents[1], root, target, facts)
            print('world201.live', repr(result), flush=True)
            if result != (0, '') or g(root, 'tag', '-l', 'done/contracts/777/1') != 'done/contracts/777/1':
                return 1
        return int(suite(model, baseline, ['historic186', 'historic129', 'historic190'], 'HISTORIC_RAW', tools_repo) != 0)
    if args.independent_mutants:
        # Different operations from catalog anchors: ignore the unconsumed tail,
        # or reject the singleton aN before any filename interpretation.
        mutants = (
            ('first-call-tail', b'rest="${rest#*"${BASH_REMATCH[0]}"}"', b"rest=''",
             ['review-second-conflict', 'adversary-second-conflict']),
            ('single-a-rejected', b'    name="${f##*/}"', b'    if [[ "$f" == *-impl-a*.md ]] && [ "$count" -eq 1 ]; then\n'
             b'      die "done: VERDICT_ROUND_MISSING: $role: $f"\n    fi\n    name="${f##*/}"',
             ['frozen201-risk-same-object']),
        )
        alive = 0
        for name, old, new, cases in mutants:
            if model.count(old) != 1:
                raise RuntimeError('NOT_IMPLEMENTED: independent anchor ' + name)
            candidate = model.replace(old, new)
            alive += suite(candidate, baseline, cases, name, tools_repo) == 0
        print('INDEPENDENT_MUTANTS', len(mutants), 'ZHIVYH', alive)
        return int(alive != 0)
    if args.stabs:
        control = suite(model, baseline, CASES, 'CONTROL', tools_repo)
        if control:
            print('MODEL_RED', control)
            return 1
        alive = 0
        for link in source['stab_vhod']:
            count = suite(saved[link['stab']], baseline, [link['case']], link['stab'], tools_repo)
            alive += count == 0
        print('STABY', len({x['stab'] for x in source['stab_vhod']}), 'SVJAZI', len(source['stab_vhod']), 'ZHIVYH', alive)
        return int(alive != 0)
    candidate = model if args.model else (tools_repo / 'scripts/done_contract.sh').read_bytes()
    red = suite(candidate, baseline, CASES, 'MODEL' if args.model else 'REPO', tools_repo)
    print('KLETKI', len(CASES), 'KRASNYH', red)
    return int(red != 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError, ValueError, subprocess.SubprocessError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(2)
