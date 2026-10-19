#!/usr/bin/env python3
"""992: execute complete scripts in disposable repositories, never source fragments.

--matrix compares packet-A parent, current tree and the candidate model. The
model only patches copied subjects; production scripts are implementer's zone.
Fault shims delegate every non-target invocation to the real binary. Assertions
and pre-call state remain in this process, outside the subject's directory.
"""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
GIT = shutil.which('git')
JQ = shutil.which('jq')
BASE_ENV = dict(os.environ, GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null')
for key in list(BASE_ENV):
    if key.startswith('GIT_CONFIG_') and key not in ('GIT_CONFIG_GLOBAL', 'GIT_CONFIG_SYSTEM'):
        BASE_ENV.pop(key)
    if key in ('GIT_DIR', 'GIT_WORK_TREE', 'GIT_INDEX_FILE', 'GIT_OBJECT_DIRECTORY', 'GIT_ALTERNATE_OBJECT_DIRECTORIES'):
        BASE_ENV.pop(key)


def run(argv, cwd, env=None):
    return subprocess.run(list(map(str, argv)), cwd=cwd, env=env or BASE_ENV,
                          text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


def git(root, *args):
    p = run([GIT, '-C', root, '-c', 'core.hooksPath=/dev/null', '-c', 'commit.gpgsign=false', *args], root)
    if p.returncode:
        raise RuntimeError(f'fixture git {args}: {p.stderr}')
    return p.stdout.strip()


def put(path, text, executable=False):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)
    if executable:
        path.chmod(0o755)


def commit(root):
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', 'fixture')


def init(root):
    root.mkdir()
    git(root, 'init', '-q', '-b', 'main')
    git(root, 'config', 'user.name', 'Fixture')
    git(root, 'config', 'user.email', 'fixture@local')
    git(root, 'config', 'core.hooksPath', '/dev/null')
    git(root, 'config', 'commit.gpgsign', 'false')


# Each row has its own fault, named diagnosis and independent public execution.
CASES = {
    'A-freeze-spec': ('freeze_contract.sh', r'ОТКАЗ: spec-preflight 036 красен.*rc=7.*'),
    'A-done-log': ('done_contract.sh', r'done: история вердикта не читается.*git log rc=128.*'),
    'A-done-order': ('done_contract.sh', r'done: порядок вердиктов не читается.*merge-base rc=128.*'),
    'A-charter-history': ('check_charter.sh', r'.*FAIL .*история .*rev-list rc=128.*'),
    'A-preflight-range': ('gitw_preflight_071.sh', r'gitw ПРЕДПОЛЁТ-ОТКАЗ: диапазон .*git log rc=128.*'),
    'A-judge-write': ('judge_gate.sh', r'ОТКАЗ: журнал: policy-строка не записана:.*'),
    'A-judge-verdict-write': ('judge_gate.sh', r'ОТКАЗ: журнал: verdict-строка не записана:.*'),
    'A-profile-kind': ('profile_resolver.sh', r'profile ОТКАЗ: contextPack.rows:.*jq rc=7.*'),
    'B-charter-diff': ('check_charter.sh', r'.*FAIL .*diff-tree.*'),
    'B-charter-tree': ('check_charter.sh', r'.*FAIL .*ls-tree.*'),
    'B-preflight-package': ('gitw_preflight_071.sh', r'gitw ПРЕДПОЛЁТ-ОТКАЗ: .*package.json.*'),
    'B-preflight-worktrees': ('gitw_preflight_071.sh', r'gitw ПРЕДПОЛЁТ-ОТКАЗ: .*worktree.*'),
    'B-preflight-tags': ('gitw_preflight_071.sh', r'gitw ПРЕДПОЛЁТ-ОТКАЗ: .*for-each-ref.*'),
    'B-judge-policy-seq': ('judge_gate.sh', r'ОТКАЗ: журнал: грамматика: seq'),
    'B-judge-verdict-seq': ('judge_gate.sh', r'ОТКАЗ: журнал: грамматика: seq'),
    'B-profile-defaults': ('profile_resolver.sh', r'profile ОТКАЗ: .*jq.*'),
    'B-profile-keys': ('profile_resolver.sh', r'profile ОТКАЗ: .*jq.*'),
    'B-profile-object': ('profile_resolver.sh', r'profile ОТКАЗ: .*jq.*'),
    'B-profile-strings': ('profile_resolver.sh', r'profile ОТКАЗ: .*jq.*'),
    'B-profile-array': ('profile_resolver.sh', r'profile ОТКАЗ: .*jq.*'),
    'B-freeze-versions': ('freeze_contract.sh', r'ОТКАЗ: .*for-each-ref.*'),
    'B-done-versions': ('done_contract.sh', r'done: .*for-each-ref.*'),
    'B-ci-ok-write': ('check_ci_gate.sh', r'ОТКАЗ: журнал: check-строка не записана:.*'),
    'B-ci-fail-write': ('check_ci_gate.sh', r'ОТКАЗ: журнал: check-строка не записана:.*'),
}


def shim(directory, name, condition, real, rc=128):
    # hit file is evidence of fault delivery, not the acceptance oracle.
    put(directory / name, '#!/usr/bin/env python3\nimport os,sys\na=sys.argv[1:]\n'
        + f'if os.environ.get("FC_FAULT") == "1" and ({condition}):\n'
        + ' open(os.environ["FC_HIT"],"a").write("hit\\n")\n'
        + f' sys.exit({rc})\nos.execv({real!r}, [{real!r}]+a)\n', True)


def prepare(base, case, source):
    root = base / 'repo'
    init(root)
    scripts = root / 'scripts'
    scripts.mkdir()
    subject = CASES[case][0]
    for name in (subject, 'next_id.sh', 'lib_registry.sh', 'ci_klass.sh'):
        shutil.copy2(ROOT / 'scripts' / name, scripts / name)
    put(scripts / subject, source, True)
    # Unrelated prerequisite gates are isolated, as in the original reviewer probe.
    for name in ('check_spec_ready.sh', 'check_consumers.sh', 'check_provodka.sh', 'check_sud_model.sh'):
        put(scripts / name, '#!/bin/bash\nprintf "OK\\n"\nexit 0\n', True)
    put(scripts / 'doc_contract.ts', 'process.exit(1);\n')
    bindir = base / 'bin'
    bindir.mkdir()
    env = dict(BASE_ENV, PATH=f'{bindir}:{BASE_ENV["PATH"]}', FC_HIT=str(base / 'hit'), FC_FAULT='0', TMPDIR=str(base))
    args = []
    observe = lambda: None
    fault_setup = lambda: None
    if subject in ('freeze_contract.sh', 'done_contract.sh'):
        put(root / 'contracts/001-x.md', '# fixture\n')
        put(root / 'verdicts/critic/contracts-001-v1.md', 'accept\n')
        put(root / 'verdicts/review/contracts-001-v1.md', 'accept\n')
        # No remote is needed by registry_state: standalone authoritative toy.
        commit(root)
        if case in ('A-done-log', 'A-done-order'):
            put(root / 'verdicts/review/contracts-001-v2.md', 'accept\n')
            commit(root)
            condition = "'log' in a and a[-1]=='verdicts/review/contracts-001-v2.md'"
            if case == 'A-done-order':
                condition = "'merge-base' in a and '--is-ancestor' in a"
        elif case.endswith('versions'):
            prefix = 'frozen' if subject.startswith('freeze') else 'done'
            # Missing v1 but existing v2 detects fabricated v1, not tag collision.
            git(root, 'tag', f'{prefix}/contracts/001/2')
            put(root / 'verdicts/critic/contracts-001-v3.md', 'accept\n')
            commit(root)
            condition = f"'for-each-ref' in a and 'refs/tags/{prefix}/contracts/001/' in a"
        else:
            condition = 'False'
            put(scripts / 'check_spec_ready.sh', '#!/bin/bash\necho OK\nif [ "$FC_FAULT" = 1 ]; then echo hit >> "$FC_HIT"; exit 7; fi\n', True)
        shim(bindir, 'git', condition, GIT)
        args = ['contracts/001-x.md', 'fixture РАЗРЕШИЛ-ВЛАДЕЛЕЦ: toy only', root]
        observe = lambda: (git(root, 'show-ref', '--tags') if git(root, 'tag', '-l') else '', git(root, 'rev-parse', 'HEAD'), (root / 'registry/contracts.tsv').read_bytes() if (root / 'registry/contracts.tsv').exists() else None)
    elif subject == 'check_charter.sh':
        put(root / 'AGENTS.md', 'base\n')
        put(root / 'contracts/001-x.md', 'base\n')
        commit(root)
        git(root, 'tag', 'ustav/1')
        git(root, 'tag', 'frozen/contracts/001/1')
        put(root / 'note', 'new commit\n')
        commit(root)
        condition = {'A-charter-history': "'rev-list' in a and 'ustav/1..HEAD' in a", 'B-charter-diff': "'diff-tree' in a", 'B-charter-tree': "'ls-tree' in a and ':(literal)contracts/' in a"}[case]
        shim(bindir, 'git', condition, GIT)
        args = [root]
    elif subject == 'gitw_preflight_071.sh':
        put(root / 'package.json', '{}\n')
        commit(root)
        tip = git(root, 'rev-parse', 'HEAD')
        # Local transport is not used: ls-remote response is a deterministic network seam.
        put(bindir / 'git', '#!/usr/bin/env python3\nimport os,sys\na=sys.argv[1:]\n'
            + 'if "ls-remote" in a:\n'
            + f' print({(tip + chr(9) + "refs/heads/main")!r} if "--tags" not in a else "")\n sys.exit(0)\n'
            + 'if os.environ.get("FC_FAULT")=="1" and (' + {
                'A-preflight-range': "'log' in a and '--merges' in a",
                'B-preflight-package': "'show' in a and a[-1].endswith(':package.json')",
                'B-preflight-worktrees': "a[:2]==['worktree','list']",
                'B-preflight-tags': "'for-each-ref' in a and 'refs/tags' in a",
            }[case] + '):\n open(os.environ["FC_HIT"],"a").write("hit\\n")\n sys.exit(128)\n'
            + f'os.execv({GIT!r},[{GIT!r}]+a)\n', True)
        args = ['https://github.com/fixture/fixture.git', 'HEAD:main']
    elif subject == 'judge_gate.sh':
        journal = root / 'registry/candidates.tsv'
        put(journal, '')
        put(root / 'decision', 'accept\n')
        args = ['a'*40, '--policy-row', 'b'*64, 'c'*64, 'd'*64, root / 'decision']
        if 'verdict' in case:
            args = ['a'*40, '--verdict-row', 'fixture', 'b'*64, root / 'decision', '--sud', 'critic', '/unused', 'fixture']
        if case.startswith('A-judge-'):
            # A symlink to /proc/version is readable regular file but not writable,
            # also when the test runs as root; chmod-only fixtures are not portable.
            def fault_setup():
                journal.unlink()
                journal.symlink_to('/proc/version')
        else:
            def fault_setup():
                put(journal, 'policy\t' + '\t'.join(['b'*64, 'c'*64, 'd'*64, 'accept', 'abc']) + '\n')
        observe = lambda: journal.read_bytes()
    elif subject == 'check_ci_gate.sh':
        journal = root / 'registry/candidates.tsv'
        put(journal, '')
        put(root / 'harness/policy', 'mandatory=unit\nciApp=github-actions\n')
        put(root / 'harness/checks/unit.cmd', 'true\n')
        commit(root)
        git(root, 'remote', 'add', 'origin', 'https://github.com/fixture/fixture.git')
        tip = git(root, 'rev-parse', 'HEAD')
        import hashlib
        wfsha = hashlib.sha256(b'true\n').hexdigest()
        body = {'total_count': 1, 'check_runs': [{'id': 7, 'name': 'unit', 'head_sha': tip, 'app': {'slug': 'github-actions'}, 'wfsha': wfsha, 'conclusion': 'success'}]}
        put(bindir / 'curl', '#!/usr/bin/env python3\nimport json,os\nb='+repr(body)+'\nif os.environ.get("FC_FAULT")=="1" and '+repr(case == 'B-ci-fail-write')+': b["check_runs"][0]["conclusion"]="failure"\nprint(json.dumps(b))\n', True)
        args = [root, tip, '--check-row', 'b'*64, 'unit']
        def fault_setup():
            journal.unlink()
            journal.symlink_to('/proc/version')
        observe = lambda: journal.read_bytes()
    else:
        layer = base / 'layer'
        project = {'schemaVersion': 1, 'version': 'v1', 'projectId': 'project', 'workspaceId': 'workspace', 'defaults': {}}
        repo = {'schemaVersion': 1, 'repoId': 'repo', 'language': 'bash', 'projectLayer': {'version': 'v1', 'profilePath': 'registry/harness-project.json'}, 'commands': {'test': 'true'}, 'barriers': {'mandatory': ['unit'], 'optional': []}, 'contextPack': {'rows': []}}
        put(layer / 'registry/harness-project.json', json.dumps(project))
        put(root / 'harness.project.json', json.dumps(repo))
        env['HARNESS_PROJECT_LAYER_ROOT'] = str(layer)
        condition = {
            'A-profile-kind': "any('to_entries[]' in x and '.contextPack.value.rows' in x for x in a)",
            'B-profile-defaults': "'.defaults | keys_unsorted[]' in a",
            'B-profile-keys': "'.commands | keys_unsorted[]' in a",
            'B-profile-object': "'(.commands|type)==\"object\"' in a",
            'B-profile-strings': "'(getpath($p | split(\".\")) // null) | type' in a and 'commands' in a",
            'B-profile-array': "any('join(' in x and 'getpath' in x for x in a) and 'barriers.mandatory' in a",
        }[case]
        shim(bindir, 'jq', condition, JQ, 7)
        args = ['--repo', root]
    return root, scripts / subject, args, env, observe, fault_setup


def execute(case, source, fault):
    with tempfile.TemporaryDirectory(prefix='fc992-') as tmp:
        root, subject, args, env, observe, fault_setup = prepare(Path(tmp), case, source)
        if fault:
            fault_setup()
        before = observe()
        env['FC_FAULT'] = str(int(fault))
        p = run(['bash', subject, *args], root, env)
        after = observe()
        hit = (Path(tmp) / 'hit').exists() or ('judge' in case or '-ci-' in case)
        text = p.stderr + p.stdout
        reason = any(re.fullmatch(CASES[case][1], line) for line in text.splitlines())
        success = 'строка записана:' in text or 'заморожено:' in text
        if fault:
            ok = p.returncode == 1 and reason and not success and before == after and hit
            if 'profile' in case:
                ok = ok and not p.stdout
        else:
            ok = p.returncode == 0
            if 'profile' in case and ok:
                value = json.loads(p.stdout)
                ok = value['repoId']['value'] == 'repo'
            if 'judge' in case and ok:
                row = after.decode().strip().split('\t')
                ok = row[-1] == '1'
        return ok, p.returncode, text.strip(), hit


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--matrix', action='store_true')
    parser.add_argument('--model', action='store_true')
    parser.add_argument('--case', choices=CASES)
    parser.add_argument('--list', action='store_true')
    args = parser.parse_args()
    if args.list:
        print('\n'.join(CASES))
        return 0
    selected = [args.case] if args.case else list(CASES)
    failures = 0
    from model_992 import candidate
    for case in selected:
        name = CASES[case][0]
        current = (ROOT / 'scripts' / name).read_text()
        versions = [('subject', candidate(name, current) if args.model else current)]
        if args.matrix:
            old = run([GIT, 'show', f'3e071370^:scripts/{name}'], ROOT)
            if old.returncode:
                raise RuntimeError(old.stderr)
            versions = [('parent-A', old.stdout), ('current', current), ('model', candidate(name, current))]
        for label, source in versions:
            green, grc, gout, _ = execute(case, source, False)
            ok, rc, out, hit = execute(case, source, True)
            expected = ok
            if args.matrix:
                if label == 'model' or (label == 'current' and case.startswith('A-')):
                    expected = ok
                else:
                    expected = not ok and rc == (1 if '-ci-' in case else 0)
            good = green and expected and hit
            failures += not good
            print(f'{case} {label}: control_rc={grc} fault_rc={rc} oracle={int(ok)} hit={int(hit)} accepted={int(good)}')
            if rc or not good:
                print('  ' + out.replace('\n', '\n  '))
            if not green:
                print('  CONTROL: ' + gout.replace('\n', '\n  '))
    print(f'cases={len(selected)} observations={len(selected)*(3 if args.matrix else 1)} failures={failures}')
    return int(failures != 0)


if __name__ == '__main__':
    raise SystemExit(main())
