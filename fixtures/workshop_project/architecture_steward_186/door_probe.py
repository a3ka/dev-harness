#!/usr/bin/env python3
"""Isolated Git worlds: real baseline diff, fake GitHub network, observed merge argv."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
DEFAULT_REPO = HERE.parents[2]
REPO = 'a3ka/CompliorOS-architecture'

FAKE_GH = '''#!/usr/bin/env python3
import json, os, pathlib, sys
state = json.loads(pathlib.Path(os.environ['TOY_STATE']).read_text())
args = sys.argv[1:]
if args[:2] == ['pr', 'view']:
    print(json.dumps(state['pr']))
elif args == ['api', 'user']:
    print(json.dumps({'login': state['operator']}))
elif args[:2] == ['api', 'repos/a3ka/CompliorOS-architecture/pulls/42/reviews']:
    print(json.dumps(state['reviews']))
elif args[:2] == ['api', 'repos/a3ka/CompliorOS-architecture/commits/' + state['pr']['headRefOid'] + '/check-runs']:
    print(json.dumps({'check_runs': state['checks']}))
elif args[:2] == ['pr', 'merge']:
    import subprocess
    sha = state['pr']['headRefOid']
    if '--match-head-commit' in args and args[args.index('--match-head-commit') + 1] != sha:
        sys.exit(41)
    subprocess.run(['git', 'switch', '-q', 'main'], check=True)
    subprocess.run(['git', '-c', 'user.name=station-orchestrator',
                    '-c', 'user.email=station@dev-harness.local',
                    'merge', '-q', '--no-ff', 'pr-42', '-m', 'Merge toy architecture PR'],
                   check=True)
    pathlib.Path(os.environ['TOY_MERGE_LOG']).write_text(json.dumps(args))
else:
    print('unexpected gh: ' + repr(args), file=sys.stderr)
    sys.exit(43)
'''
FAKE_NPM = '''#!/usr/bin/env python3
import json, pathlib, sys
from pathlib import Path
args = sys.argv[1:]
if args != ['run', 'check', '--', '--base', 'governance/baseline/approved.json', '--report']:
    print('unexpected npm: ' + repr(args), file=sys.stderr)
    sys.exit(43)
base = json.loads(Path('governance/baseline/approved.json').read_text())
current = json.loads(Path('governance/current.json').read_text())
mismatches = [key for key in sorted(set(base) | set(current)) if base.get(key) != current.get(key)]
print(json.dumps({'baselineStatus': 'PASS' if not mismatches else 'FAIL',
                  'findings': [{'code': 'BASELINE_MISMATCH', 'section': section}
                               for section in mismatches],
                  'contractReadiness': {'incompatibleContracts': []}}))
sys.exit(2)
'''


def call(argv, cwd, env=None):
    return subprocess.run(argv, cwd=cwd, env=env, text=True, capture_output=True)


def write(root, name, data):
    path = root / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(data, encoding='utf-8')
    return path


def world(tmp, case):
    root = tmp / 'CompliorOS-architecture'
    root.mkdir()
    check = call(['git', 'init', '-q', '-b', 'main'], root)
    if check.returncode:
        raise RuntimeError(check.stderr)
    base = {'moduleBoundaries': {'api': ['identity']}, 'resources': {'identity': 'owner'}}
    current = json.loads(json.dumps(base))
    write(root, 'governance/baseline/approved.json', json.dumps(base))
    write(root, 'governance/current.json', json.dumps(current))
    write(root, 'package.json', json.dumps({'scripts': {'check': 'node tooling/checks/cli.js check'}}))
    check = call(['git', 'add', '.'], root)
    if check.returncode:
        raise RuntimeError(check.stderr)
    check = call(['git', '-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local',
                  'commit', '-qm', 'toy baseline'], root)
    if check.returncode:
        raise RuntimeError(check.stderr)
    check = call(['git', 'switch', '-q', '-c', 'pr-42'], root)
    if check.returncode:
        raise RuntimeError(check.stderr)
    if case == 'l2_without_owner':
        current['moduleBoundaries']['api'].append('new-api')
    if case == 'l3_without_owner':
        current['resources']['identity'] = 'public'
    write(root, 'governance/current.json', json.dumps(current))
    write(root, 'architecture/description.md', 'L1 corrected relationship\n')
    check = call(['git', 'add', '.'], root)
    if check.returncode:
        raise RuntimeError(check.stderr)
    check = call(['git', '-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local',
                  'commit', '-qm', 'arch(L1): correct model'], root)
    if check.returncode:
        raise RuntimeError(check.stderr)
    sha = call(['git', 'rev-parse', 'HEAD'], root).stdout.strip()
    state = {
        'pr': {'title': 'COMPLIOR-186 architectural correction', 'author': {'login': 'steward'},
               'headRefOid': sha, 'baseRefName': 'main'},
        'operator': 'station-orchestrator',
        'reviews': [{'state': 'APPROVED', 'commit_id': sha, 'user': {'login': 'critic'},
                     'body': 'accept\nСУД: repo=architecture; модель-факт=zai/glm-5.3; SHA=' + sha}],
        'checks': [{'name': 'architecture', 'status': 'completed', 'conclusion': 'success'}],
    }
    if case == 'no_accept':
        state['reviews'] = []
    if case == 'accept_other_head':
        state['reviews'][0]['commit_id'] = call(['git', 'rev-parse', 'main'], root).stdout.strip()
    if case == 'accept_author':
        state['pr']['author']['login'] = 'critic'
    if case == 'accept_same_family':
        state['reviews'][0]['body'] = state['reviews'][0]['body'].replace('zai/glm-5.3', 'openai-codex/gpt-6-sol')
    if case == 'ci_red':
        state['checks'][0]['conclusion'] = 'failure'
    if case == 'ci_architecture_missing':
        state['checks'][0]['name'] = 'unrelated-quality'
    if case == 'no_complior':
        state['pr']['title'] = 'Architectural correction'
    if case == 'author_merger':
        state['operator'] = 'steward'
    write(tmp, 'state.json', json.dumps(state))
    bin_dir = tmp / 'bin'
    bin_dir.mkdir()
    for name, program in (('gh', FAKE_GH), ('npm', FAKE_NPM)):
        path = write(bin_dir, name, program)
        path.chmod(0o755)
    env = dict(os.environ, PATH=str(bin_dir) + os.pathsep + os.environ['PATH'],
               TOY_STATE=str(tmp / 'state.json'), TOY_MERGE_LOG=str(tmp / 'merged.json'), TOY_HEAD=sha)
    return root, env


CASES = {
    'l1_merge': (0, None),
    'no_accept': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_other_head': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_author': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_same_family': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'ci_red': (1, 'CI_NOT_GREEN_ON_HEAD'),
    'ci_architecture_missing': (1, 'CI_NOT_GREEN_ON_HEAD'),
    'l2_without_owner': (1, 'L2_OWNER_APPROVAL_REQUIRED'),
    'l3_without_owner': (1, 'L3_OWNER_APPROVAL_REQUIRED'),
    'no_complior': (1, 'NO_COMPLIOR_ID'),
    'author_merger': (1, 'AUTHOR_IS_MERGER'),
}
MUTATIONS = {
    'skip_accept': ('if not accepted:', 'if False:', 'no_accept'),
    'skip_head': ("r['commit_id'] == sha", 'True', 'accept_other_head'),
    'skip_author': ("r['user']['login'] != pr['author']['login']", 'True', 'accept_author'),
    'skip_family': (r'zai/glm-5\.3; SHA=', r'(?:zai/glm-5\.3|openai-codex/gpt-6-sol); SHA=', 'accept_same_family'),
    'skip_ci': ("c['conclusion'] != 'success'", 'False', 'ci_red'),
    'skip_architecture_ci': ("c['name'] == 'architecture'", 'True', 'ci_architecture_missing'),
    'skip_baseline': ('if mismatches:', 'if False:', 'l2_without_owner'),
    'skip_l3': ("return fail('L3_OWNER_APPROVAL_REQUIRED')", "return fail('L2_OWNER_APPROVAL_REQUIRED')", 'l3_without_owner'),
    'skip_id': ("if not re.search(r'\\bCOMPLIOR-[0-9]+\\b', pr['title']):", 'if False:', 'no_complior'),
    'skip_merger': ("if pr['author']['login'] == operator:", 'if False:', 'author_merger'),
    'skip_head_pin': ("'--match-head-commit', sha", "'--delete-branch'", 'l1_merge'),
}


def check(root, env, script, case):
    result = call(['python3', str(script), str(root), '42'] if script.suffix == '.py' else
                  ['bash', str(script), str(root), '42'], root, env)
    expected_rc, expected_reason = CASES[case]
    log = Path(env['TOY_MERGE_LOG'])
    merged = json.loads(log.read_text()) if log.exists() else None
    if expected_rc == 0:
        expected = ['pr', 'merge', '42', '-R', REPO, '--merge', '--match-head-commit', env['TOY_HEAD']]
        parents = call(['git', 'rev-list', '--parents', '-n', '1', 'HEAD'], root).stdout.split()
        return (result.returncode == 0 and merged == expected and len(parents) == 3
                and parents[2] == env['TOY_HEAD']), result
    return (result.returncode == expected_rc and expected_reason in result.stdout.splitlines()
            and merged is None and call(['git', 'branch', '--show-current'], root).stdout.strip() == 'pr-42'), result


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--model', action='store_true')
    group.add_argument('--stabs', action='store_true')
    group.add_argument('--repo', type=Path)
    args = parser.parse_args()
    source = (args.repo or DEFAULT_REPO).resolve()
    if not (source / '.git').exists():
        parser.error('ожидается корень Git-репозитория')
    failed = False
    jobs = [(name, case, old, new) for name, (old, new, case) in MUTATIONS.items()] if args.stabs else [
        (case, case, None, None) for case in CASES]
    for name, case, old, new in jobs:
        with tempfile.TemporaryDirectory(prefix='arch-door-186-') as directory:
            tmp = Path(directory)
            project, env = world(tmp, case)
            if args.model or args.stabs:
                control = HERE / 'door_control.py'
                if args.stabs:
                    original = control.read_text(encoding='utf-8')
                    if original.count(old) != 1:
                        raise RuntimeError('non-unique mutant anchor: ' + name)
                    changed = original.replace(old, new)
                    if name == 'skip_baseline':
                        fallback = "if status['baselineStatus'] != 'PASS' or status['contractReadiness']['incompatibleContracts']:"
                        if changed.count(fallback) != 1:
                            raise RuntimeError('missing baseline fallback mutant anchor')
                        changed = changed.replace(fallback, 'if False:')
                    control = write(tmp, 'control.py', changed)
            else:
                control = source / 'scripts/merge_architecture_pr.sh'
            if not control.is_file():
                print(f'186 door {name} KRASNO: merge door missing')
                failed = True
                continue
            ok, result = check(project, env, control, case)
            if args.stabs:
                ok = not ok and result.returncode != 2
            label = ('caught' if ok else 'ZHIV') if args.stabs else ('ok' if ok else 'KRASNO')
            print(f'186 door {name} {label}: rc={result.returncode} output={result.stdout.strip()} {result.stderr.strip()}')
            failed |= not ok
    return int(failed)


if __name__ == '__main__':
    raise SystemExit(main())
