#!/usr/bin/env python3
"""229 public CLI cells. Expected results are literals captured before subjects.

Role cells are explicitly structural delivery evidence, not behavioral proof of
LLM compliance. Lock cells use real Git objects, ledger and session journals.
"""
import argparse
import ast
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
sys.dont_write_bytecode = True

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(HERE))
from catalog import MERGED, inventory
from build import MUTATIONS
DATA = json.loads((HERE / 'policy.json').read_bytes())

spec = importlib.util.spec_from_file_location('old140', ROOT / 'fixtures/workshop_project/odin_agent_140/probe.py')
old = importlib.util.module_from_spec(spec)
spec.loader.exec_module(old)
old.GIT_ENV['TMPDIR'] = str(ROOT / 'tmp/scratch-arch229')

INVALID_POLICIES = {
    'policy-null': None, 'policy-boolean': False, 'policy-array': [],
    'policy-incomplete': {}, 'policy-string': 'station ',
    'policy-unknown-field': dict(DATA['defaults'], extra=True),
    'policy-boolean-count': dict(DATA['defaults'], criticCalls=True),
    'policy-negative-count': dict(DATA['defaults'], interruptionRetries=-1),
}

def run(argv, cwd=None, env=None):
    return subprocess.run(argv, cwd=cwd, env={**os.environ, 'GIT_CONFIG_GLOBAL': '/dev/null',
                          'GIT_CONFIG_SYSTEM': '/dev/null', **(env or {})},
                          capture_output=True, timeout=90)


def check(condition, reason):
    if not condition:
        raise AssertionError(reason)


def command(result, rc, reason=None):
    check(result.returncode == rc, f'RC {result.returncode}!={rc} {result.stdout!r} {result.stderr!r}')
    if reason:
        token = reason.encode() if isinstance(result.stderr, bytes) else reason
        check(token in result.stderr, f'DIAGNOSIS {reason}: {result.stderr!r}')


def profile(repo, value='station', hook=None, layer_value=None):
    # Real minimal two-layer resolver input; no fake resolver or fake Git.
    src = json.loads((ROOT / 'harness.project.json').read_bytes())
    src.pop('contextPack', None)
    src['repoId'] = 'dev-harness'
    src['ci'] = {'workflow': 'ci.yml'}
    if value != 'ABSENT':
        src['judges'] = {'policy': value}
    if hook is not None:
        src['hooks'] = {'judgeSetup': hook}
    layer = json.loads((ROOT / 'registry/harness-project.json').read_bytes())
    layer['defaults'].pop('contextPack', None)
    layer['defaults']['ci'] = {'workflow': 'ci.yml'}
    if layer_value is not None:
        layer['defaults']['judges'] = {'policy': layer_value}
    (repo / 'registry').mkdir(exist_ok=True)
    (repo / 'registry/harness-project.json').write_text(json.dumps(layer))
    (repo / 'harness.project.json').write_text(json.dumps(src))
    (repo / 'ci.yml').write_text('name: fixture\n')


def install(source, dest):
    for path in ('scripts/zamok_predmeta.sh', 'scripts/pre_judge.sh',
                 'scripts/profile_resolver.sh', 'scripts/judges_policy.py',
                 'config/judges-policy.json'):
        src = source / path
        if src.exists():
            out = dest / path
            out.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(src, out)


def world(tmp, risk='обычный'):
    m = old.Mir(tmp)
    m.kontrakt('141', risk=risk)
    wt, branch, obj = m.worktree('141', kontrakty=[('fajl', '141-stub.md', '# К\nКЛАСС РИСКА: ' + risk + '\n')])
    m.start('141', 'Author229', wt=wt, branch=branch)
    m.zhurnal('Author229', sdal=True)
    m.release('141', 'Author229')
    profile(m.repo)
    return m, wt, branch, obj


def attempt(m, role, name, obj):
    return m.sobytie('event.json', [old.item(role, name, ['SUBJECT=141', 'OBJECT=' + obj])])


def add_failed(m, obj, count, reason, repo_id='dev-harness', holder=None):
    for number in range(count):
        name = holder or 'Judge' + str(number)
        m.start('141', name, klass='sudja', rol='critic', obj=obj, zanyat=False)
        rows = m.ledg()
        rows[-1]['repoId'] = repo_id
        m.ledger.write_text(''.join(json.dumps(r) + '\n' for r in rows))
        m.release('141', name, reason)
        rows = m.ledg()
        rows[-1]['repoId'] = repo_id
        m.ledger.write_text(''.join(json.dumps(r) + '\n' for r in rows))


def lock_case(source, name):
    with tempfile.TemporaryDirectory(prefix='jp229-', dir=ROOT / 'tmp') as tmp:
        m, wt, branch, obj = world(tmp, risk='рисковый' if name == 'env-not-adversary' else 'обычный')
        door = source / 'scripts/zamok_predmeta.sh'
        if name in ('env-release', 'env-no-evidence', 'court-release', 'env-not-adversary'):
            # Local bare remote is fixture data only; the candidate runs real Git.
            bare = Path(tmp) / 'remote/dev-harness.git'
            bare.parent.mkdir()
            command(run(['git', 'init', '-q', '--bare', str(bare)]), 0)
            m.git(['remote', 'set-url', 'origin', str(bare)])
            role = 'adversary' if name == 'env-not-adversary' else 'critic'
            m.start('141', 'Judge229', klass='sudja', rol=role, obj=obj)
            m.zhurnal('Judge229', sdal=True)
            p = m.repo / f'verdicts/{role}/contracts-141-v1.md'
            p.parent.mkdir(parents=True)
            first = 'FAIL' if name == 'court-release' else 'БЛОК-СРЕДЫ'
            evidence = '' if name == 'env-no-evidence' else 'СРЕДА-КОМАНДА: node --version\nСРЕДА-RC: 127\n'
            p.write_text(f'{first}\nOBJECT={obj}\nСУД: repo=dev-harness; предмет=141; роль={role}; сессия=Judge229; модель-факт=fixture\n{evidence}')
            m.git(['add', str(p)])
            command(run(['git', '-c', f'user.name={role}', '-c', 'user.email=judge@fixture',
                         'commit', '-qm', 'verdict'], cwd=m.repo), 0)
            r = old.osvobodit(door, m, '141', 'Judge229')
            command(r, 0)
            rows = [r for r in m.ledg() if r.get('t') == 'RELEASE' and r.get('holder') == 'Judge229']
            expected = {'env-release': 'blok_sredy', 'env-not-adversary': 'blok_sredy',
                        'env-no-evidence': 'obryv_bez_verdikta', 'court-release': 'verdikt_zakommiten'}[name]
            check(len(rows) == 1 and rows[0]['prichina'] == expected, 'RELEASE ' + repr(rows))
            if name == 'env-not-adversary':
                command(old.sudit(door, m, attempt(m, 'reviewer', 'Review229', obj)),
                        1, 'ADVERSARIJ_DO_REVJUERA')
            return
        if name == 'policy-invalid' or name in INVALID_POLICIES:
            profile(m.repo, INVALID_POLICIES.get(name, {'interruptionRetries': -1}))
            before = m.ledger.read_bytes()
            command(old.sudit(door, m, attempt(m, 'critic', 'Next229', obj)), 1, 'POLICY_INVALID')
            check(m.ledger.read_bytes() == before, 'INVALID_POLICY_WROTE_LEDGER')
            return
        if name in ('policy-limit-effect', 'policy-stop-action'):
            profile(m.repo, dict(DATA['defaults'], interruptionRetries=0,
                                 onExhaustion='stop' if name == 'policy-stop-action' else 'arbiter'))
            add_failed(m, obj, 1, 'obryv_bez_verdikta')
            before = m.ledger.read_bytes()
            command(old.sudit(door, m, attempt(m, 'critic', 'Next229', obj)),
                    1, 'BUDGET_EXHAUSTED' if name == 'policy-stop-action' else 'ARBITRATION_REQUIRED')
            check(m.ledger.read_bytes() == before, 'EXHAUSTION_WROTE_LEDGER')
            return
        if name in ('env-retry', 'environment-cap', 'interruption-cap', 'second-retry', 'foreign-scope', 'reused-holder'):
            reason = 'blok_sredy' if name in ('env-retry', 'environment-cap') else 'obryv_bez_verdikta'
            count = 3 if name.endswith('-cap') else 2
            if name == 'foreign-scope':
                add_failed(m, obj, 9, reason, repo_id='other')
            elif name == 'reused-holder':
                # RELEASE must close the newest open START of a reused name.
                for _ in range(5):
                    m.start('141', 'Same229', klass='sudja', rol='critic', obj=obj, zanyat=False)
                    m.start('141', 'Same229', klass='sudja', rol='critic', obj='f' * 40, zanyat=False)
                    m.release('141', 'Same229', reason)
            else:
                add_failed(m, obj, count, reason)
            before = m.ledger.read_bytes()
            r = old.sudit(door, m, attempt(m, 'critic', 'Next229', obj))
            reject = name.endswith('-cap') or name == 'reused-holder'
            command(r, 1 if reject else 0, 'OBJECT_UZHE_SUZHEN' if reject else None)
            if name.endswith('-cap'):
                check('ARBITRATION_REQUIRED' in r.stderr, 'NO_ARBITRATION_REQUEST')
            if name == 'reused-holder':
                check('ARBITRATION_REQUIRED' not in r.stderr, 'RELEASE_CLOSED_OLDER_START')
            if reject:
                check(m.ledger.read_bytes() == before, 'REFUSAL_WROTE_LEDGER')
            else:
                starts = [r for r in m.ledg() if r.get('holder') == 'Next229' and r['t'] == 'START']
                check(len(starts) == 1 and starts[0]['object'] == obj, 'RETRY_WRONG_START')
            return
        raise RuntimeError('unknown lock case ' + name)


INPUTS = {
    'AGENT_NET': lambda wt, br, obj: {'name': 'Worker', 'task': 'SUBJECT=141'},
    'IMJA_NET': lambda wt, br, obj: old.item('architect', 'bad name', ['SUBJECT=141']),
    'SUBJECT_NET_V_ZADANII': lambda wt, br, obj: old.item('architect', 'Worker', []),
    'SUBEKT_DVA_V_ZADANII': lambda wt, br, obj: old.item('architect', 'Worker', ['SUBJECT=141', 'SUBJECT=141']),
    'PIN_NET': lambda wt, br, obj: old.item('architect', 'Worker', ['SUBJECT=141']),
    'GRAMMATIKA_PINA': lambda wt, br, obj: old.item('architect', 'Worker', ['SUBJECT=141', 'WORKTREE='+wt, 'WORKTREE='+wt, 'BRANCH='+br]),
    'RASHOZHDENIE_PINA': lambda wt, br, obj: old.item('architect', 'Worker', ['SUBJECT=141', 'WORKTREE='+wt, 'BRANCH=wip/142/avtor']),
    'OBJECT_OTSTUTSVUET': lambda wt, br, obj: old.item('critic', 'Judge', ['SUBJECT=141']),
    'SUBEKT_DVA_OBJECTA': lambda wt, br, obj: old.item('critic', 'Judge', ['SUBJECT=141', 'OBJECT='+obj, 'OBJECT='+obj]),
}


def grammar_case(source, code):
    with tempfile.TemporaryDirectory(prefix='jp229-', dir=ROOT / 'tmp') as tmp:
        m, wt, br, obj = world(tmp)
        door = source / 'scripts/zamok_predmeta.sh'
        before = m.ledger.read_bytes()
        if code == 'GRAMMATIKA_IMENI':
            r = old.osvobodit(door, m, '141', 'bad name')
        elif code == 'GRAMMATIKA_SUBEKTA':
            r = old.osvobodit(door, m, '1', 'Judge')
        else:
            event = m.sobytie('bad.json', [INPUTS[code](wt, br, obj)])
            r = old.sudit(door, m, event)
        command(r, 1, 'ОТКАЗ: BITYJ_VHOD:')
        check(m.ledger.read_bytes() == before, 'GRAMMAR_WROTE_LEDGER')


def setup_case(source, name):
    with tempfile.TemporaryDirectory(prefix='jp229-', dir=ROOT / 'tmp') as tmp:
        m = old.Mir(tmp)
        profile(m.repo, value=DATA['defaults'] if name == 'policy-causal' else 'station')
        if name.startswith('policy-'):
            helper = source / 'scripts/judges_policy.py'
            check(helper.exists(), 'POLICY_HELPER_ABSENT')
            if name == 'policy-absent':
                profile(m.repo, 'ABSENT')
            elif name == 'policy-layer':
                value = dict(DATA['defaults'], interruptionRetries=4)
                profile(m.repo, 'ABSENT', layer_value=value)
            r = run(['python3', str(helper), 'resolve', '--repo', str(m.repo)])
            command(r, 0)
            got = json.loads(r.stdout)
            expected = None if name == 'policy-absent' else dict(DATA['defaults'], **({'interruptionRetries': 4} if name == 'policy-layer' else {}))
            check(got == expected, f'POLICY_VALUE {got!r}!={expected!r}')
            return
        br = 'wip/141/critic'
        m.git(['checkout', '-qb', br])
        obj = m.git(['rev-parse', 'HEAD']).stdout.strip()
        hook = m.repo / 'setup.py'
        hook.write_text('import os\nfrom pathlib import Path\nPath(os.environ["JUDGE_SCRATCH"],"hook-observed").write_text(os.environ["HARNESS_HEAD"])\n')
        profile(m.repo, hook=['python3', 'setup.py'])
        if name == 'setup-hook-fails':
            hook.write_text('raise SystemExit(7)\n')
        if name == 'setup-wrong-branch':
            m.git(['checkout', '-qb', 'wip/141/author'])
        expected_obj = 'f' * 40 if name == 'setup-wrong-object' else obj
        r = run(['bash', str(source / 'scripts/pre_judge.sh'), 'setup', '--repo', str(m.repo),
                 '--object', expected_obj, '--subject', '141', '--role', 'critic'])
        rc = 2 if name == 'setup-hook-fails' else (1 if name in ('setup-wrong-object', 'setup-wrong-branch') else 0)
        command(r, rc, 'БЛОК-СРЕДЫ: hooks.judgeSetup rc=7' if name == 'setup-hook-fails' else None)
        if rc == 0:
            expected = f'OBJECT={obj}\nJUDGE_SCRATCH={m.repo}/tmp/j\nJUDGE_BRANCH={br}\n'.encode()
            check(r.stdout == expected, 'SETUP_OUTPUT ' + repr(r.stdout))
            observed = m.repo / 'tmp/j/hook-observed'
            check(observed.is_file() and observed.read_text() == obj, 'HOOK_NOT_RUN')
        else:
            check(r.stdout == b'', 'PARTIAL_ENV_OUTPUT')
            check(not (m.repo / 'tmp/j/hook-observed').exists(), 'HOOK_RAN_AFTER_REFUSAL')


LOCK_CASES = ('env-release', 'env-no-evidence', 'court-release', 'env-not-adversary', 'env-retry', 'second-retry',
              'environment-cap', 'interruption-cap', 'foreign-scope', 'reused-holder', 'policy-invalid',
              'policy-limit-effect', 'policy-stop-action', *INVALID_POLICIES)
SETUP_CASES = ('setup-hook', 'setup-hook-fails', 'setup-wrong-object', 'setup-wrong-branch',
               'policy-absent', 'policy-causal', 'policy-layer')
NORMS = {f'norm-{g}-{Path(path).stem}': (path, line)
         for path, rules in DATA['norms'].items() for g, line in rules.items()}
CASES = (*LOCK_CASES, *SETUP_CASES, *('grammar-' + x for x in INPUTS),
         'grammar-GRAMMATIKA_IMENI', 'grammar-GRAMMATIKA_SUBEKTA', 'code-budget', *NORMS)


def cell(source, name):
    try:
        if name in LOCK_CASES:
            lock_case(source, name)
        elif name in SETUP_CASES:
            setup_case(source, name)
        elif name.startswith('grammar-'):
            grammar_case(source, name[len('grammar-'):])
        elif name == 'code-budget':
            text = (source / 'scripts/zamok_predmeta.sh').read_text()
            check(len(inventory(text)) <= 20, 'REFUSAL_CODE_BUDGET ' + str(len(inventory(text))))
        else:
            path, line = NORMS[name]
            check(line in (source / path).read_text().splitlines(), 'NORM_DELIVERY_MISSING ' + path)
        return None
    except AssertionError as error:
        return str(error)


def catalog():
    source = json.loads((HERE / 'source.json').read_bytes())
    for rel, digest in source['nositeli'].items():
        check(hashlib.sha256((HERE / rel).read_bytes()).hexdigest() == digest, 'CARRIER_CHANGED ' + rel)
    check(source['stab_vhod'] == {k: v[3] for k, v in MUTATIONS.items()}, 'CATALOG_LINKS_CHANGED')
    check(len(CASES) == len(set(CASES)) and CASES, 'EMPTY_OR_DUPLICATE_CASES')
    check(all(c in CASES for v in source['stab_vhod'].values() for c in v), 'UNKNOWN_CELL')
    print('KLETKI', len(CASES), 'STABY', len(MUTATIONS), 'SVJAZI', sum(len(v[3]) for v in MUTATIONS.values()))
    return source


def syntax():
    for p in (HERE / 'model').rglob('*.py'):
        ast.parse(p.read_bytes(), filename=str(p))
    for p in (HERE / 'stabs').rglob('*.py'):
        ast.parse(p.read_bytes(), filename=str(p))
    for p in [*HERE.glob('*.py'), *HERE.rglob('*.sh')]:
        if p.suffix == '.py':
            ast.parse(p.read_bytes(), filename=str(p))
        else:
            command(run(['bash', '-n', str(p)]), 0)
    shellcheck = os.environ.get('VALIDATE_STD_SHELLCHECK')
    check(shellcheck and Path(shellcheck).is_file(), 'SHELLCHECK_UNAVAILABLE')
    # Whole inherited scripts carry historical diagnostics; wrapper is new code.
    command(run([shellcheck, str(HERE / 'red_judges_policy_229.sh')]), 0)
    print('SINTAKSIS 0')


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--repo', type=Path)
    for mode in ('model', 'stabs', 'sintaksis', 'catalog'):
        group.add_argument('--' + mode, action='store_true')
    parser.add_argument('--case', choices=CASES)
    args = parser.parse_args()
    (ROOT / 'tmp').mkdir(exist_ok=True)
    try:
        for executable in ('git', 'bash', 'jq', 'python3'):
            if shutil.which(executable) is None:
                raise RuntimeError('MISSING_TOOL ' + executable)
        try:
            import jsonschema
        except ImportError as error:
            raise RuntimeError('MISSING_JSONSCHEMA') from error
        catalog()
        if args.catalog:
            return 0
        if args.sintaksis:
            syntax()
            return 0
        source = args.repo.resolve() if args.repo else HERE / 'model'
        selected = (args.case,) if args.case else CASES
        errors = []
        for name in selected:
            error = cell(source, name)
            print(name, 'KRASNO ' + error if error else 'ok')
            if error:
                errors.append(name)
        print('KLETKI', len(selected), 'KRASNYH', len(errors))
        if errors:
            return 1
        if args.stabs:
            live = 0
            for name, (path, _, _, links) in MUTATIONS.items():
                with tempfile.TemporaryDirectory(prefix='jp229-stab-', dir=ROOT / 'tmp') as tmp:
                    dest = Path(tmp)
                    shutil.copytree(HERE / 'model', dest, dirs_exist_ok=True)
                    shutil.copyfile(HERE / 'stabs' / name / path, dest / path)
                    for case in links:
                        error = cell(dest, case)
                        live += error is None
                        print('STAB', name, case, 'ZHIV' if error is None else 'RED ' + error)
            print('STABY', len(MUTATIONS), 'SVJAZI', sum(len(v[3]) for v in MUTATIONS.values()), 'ZHIVYH', live)
            return int(bool(live))
        return 0
    except (OSError, RuntimeError, subprocess.SubprocessError, AssertionError) as error:
        print('NOT_IMPLEMENTED: ' + str(error), file=sys.stderr)
        return 2


if __name__ == '__main__':
    raise SystemExit(main())
