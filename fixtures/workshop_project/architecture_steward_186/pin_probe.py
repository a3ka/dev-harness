#!/usr/bin/env python3
"""Independent post-merge lock cells over Git object PR heads and fake GitHub metadata."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
ARCH_REPO = 'a3ka/CompliorOS-architecture'
PRODUCT_REPO = 'a3ka/Complior-back'
FAKE_GH = '''#!/usr/bin/env python3
import json, os, pathlib, sys
state = json.loads(pathlib.Path(os.environ['PIN_TOY_STATE']).read_text())
args = sys.argv[1:]
if args[:2] != ['pr', 'view'] or '--json' not in args or '-R' not in args:
    print('unexpected gh call: ' + repr(args), file=sys.stderr)
    sys.exit(43)
repo = args[args.index('-R') + 1]
number = args[2]
if (repo, number) == ('a3ka/CompliorOS-architecture', '42'):
    print(json.dumps(state['arch']))
elif (repo, number) == ('a3ka/Complior-back', '73'):
    print(json.dumps(state['product']))
else:
    print('unexpected PR: ' + repr(args), file=sys.stderr)
    sys.exit(43)
'''


def call(args, cwd, env=None):
    return subprocess.run(args, cwd=cwd, env=env, capture_output=True, text=True)


def must(args, cwd):
    result = call(args, cwd)
    if result.returncode:
        raise RuntimeError(f'fixture setup: {args!r}: {result.stderr} {result.stdout}')
    return result.stdout.strip()


def commit(root, message):
    must(['git', 'add', '.'], root)
    must(['git', '-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local',
          'commit', '-qm', message], root)
    return must(['git', 'rev-parse', 'HEAD'], root)


def world(tmp, case):
    arch = tmp / 'CompliorOS-architecture'
    product = tmp / 'Complior-back'
    arch.mkdir()
    product.mkdir()
    must(['git', 'init', '-qb', 'main'], arch)
    (arch / 'base.txt').write_text('approved\n')
    must(['git', 'add', '.'], arch)
    commit(arch, 'approved model')
    must(['git', 'switch', '-qc', 'pr-42'], arch)
    (arch / 'model.txt').write_text('L1 description\n')
    arch_head = commit(arch, 'arch(L1): correct model COMPLIOR-186')
    must(['git', 'switch', '-q', 'main'], arch)
    must(['git', '-c', 'user.name=station-orchestrator', '-c', 'user.email=station@dev-harness.local',
          'merge', '-q', '--no-ff', 'pr-42', '-m', 'Merge architecture PR'], arch)
    merge_sha = must(['git', 'rev-parse', 'HEAD'], arch)
    base_sha = must(['git', 'rev-parse', 'HEAD^1'], arch)
    must(['git', 'init', '-qb', 'main'], product)
    (product / 'README.md').write_text('product\n')
    commit(product, 'product baseline')
    must(['git', 'switch', '-qc', 'pr-73'], product)
    pin = {'format': 'complioros-architecture-pin/1', 'repository': ARCH_REPO,
           'commit': merge_sha, 'workItem': 'COMPLIOR-186', 'snapshot': 4,
           'status': 'APPROVED', 'snapshotDigest': 'a' * 64}
    if case == 'pin_missing':
        del pin['commit']
    elif case == 'pin_wrong':
        pin['commit'] = base_sha
    elif case == 'pin_arch_head':
        pin['commit'] = arch_head
    if case != 'lock_missing':
        (product / 'architecture.lock.json').write_text(json.dumps(pin) + '\n')
    else:
        (product / 'README.md').write_text('product with no architecture pin\n')
    product_head = commit(product, 'COMPLIOR-186 pin architecture' if case != 'lock_missing' else 'COMPLIOR-186 code')
    state = {'arch': {'title': 'COMPLIOR-186 architectural correction', 'state': 'MERGED',
                      'headRefOid': arch_head, 'mergeCommit': {'oid': merge_sha}},
             'product': {'title': 'COMPLIOR-186 backend change', 'headRefOid': product_head}}
    (tmp / 'state.json').write_text(json.dumps(state))
    bin_dir = tmp / 'bin'
    bin_dir.mkdir()
    gh = bin_dir / 'gh'
    gh.write_text(FAKE_GH)
    gh.chmod(0o755)
    env = dict(os.environ, PATH=str(bin_dir) + os.pathsep + os.environ['PATH'],
               PIN_TOY_STATE=str(tmp / 'state.json'))
    expected = {'merge_sha': merge_sha, 'head_sha': arch_head, 'product_sha': product_head,
                'file_present': case != 'lock_missing', 'pin': pin.copy()}
    return arch, product, env, expected


CASES = {'pin_merged': (0, None), 'lock_missing': (1, 'ARCHITECTURE_LOCK_MISSING'),
         'pin_missing': (1, 'ARCHITECTURE_PIN_MISSING'),
         'pin_wrong': (1, 'ARCHITECTURE_PIN_MISMATCH'),
         'pin_arch_head': (1, 'ARCHITECTURE_PIN_MISMATCH')}
MUTATIONS = {
    'skip_pin_check': ('return fail(\'ARCHITECTURE_LOCK_MISSING\')', 'return 0', 'lock_missing'),
    'skip_pin_field': ('return fail(\'ARCHITECTURE_PIN_MISSING\')', 'return 0', 'pin_missing'),
    'compare_arch_head': ("if pin['commit'] != merge_sha:", "if pin['commit'] != arch_head:", 'pin_arch_head'),
    'accept_any_sha': ("if pin['commit'] != merge_sha:", "if not SHA.fullmatch(pin['commit']):", 'pin_wrong'),
}


def check(control, arch, product, env, case, expected):
    if expected['file_present']:
        assert (product / 'architecture.lock.json').exists()
    else:
        assert not (product / 'architecture.lock.json').exists()
    assert must(['git', 'rev-parse', 'HEAD'], product) == expected['product_sha']
    assert must(['git', 'rev-parse', 'HEAD'], arch) == expected['merge_sha']
    if case == 'pin_arch_head':
        assert expected['pin']['commit'] == expected['head_sha'] != expected['merge_sha']
    if case == 'pin_wrong':
        assert expected['pin']['commit'] not in (expected['head_sha'], expected['merge_sha'])
    command = ['python3', str(control)] if control.suffix == '.py' else ['bash', str(control)]
    result = call(command + [str(arch), '42', str(product), '73'], product, env)
    rc, reason = CASES[case]
    ok = result.returncode == rc and (reason is None or reason in result.stdout.splitlines())
    return ok, result


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--model', action='store_true')
    group.add_argument('--stabs', action='store_true')
    group.add_argument('--repo', type=Path)
    args = parser.parse_args()
    failed = False
    jobs = [(name, case, old, new) for name, (old, new, case) in MUTATIONS.items()] if args.stabs else [
        (case, case, None, None) for case in CASES]
    for name, case, old, new in jobs:
        with tempfile.TemporaryDirectory(prefix='arch-pin-186-') as folder:
            tmp = Path(folder)
            arch, product, env, expected = world(tmp, case)
            if args.stabs:
                original = (HERE / 'pin_control.py').read_text()
                if original.count(old) != 1:
                    raise RuntimeError('non-unique mutation: ' + name)
                control = tmp / 'mutant.py'
                control.write_text(original.replace(old, new))
            elif args.model:
                control = HERE / 'pin_control.py'
            else:
                control = args.repo.resolve() / 'scripts/check_architecture_pin.sh'
            if not control.is_file():
                print(f'186 pin {name} KRASNO: post-merge pin checker missing')
                failed = True
                continue
            ok, result = check(control, arch, product, env, case, expected)
            if args.stabs:
                ok = not ok and result.returncode != 2
            label = ('caught' if ok else 'ZHIV') if args.stabs else ('ok' if ok else 'KRASNO')
            print(f'186 pin {name} {label}: rc={result.returncode} output={result.stdout.strip()} {result.stderr.strip()}')
            failed |= not ok
    return int(failed)


if __name__ == '__main__':
    raise SystemExit(main())
