#!/usr/bin/env python3
"""End-to-end Git cells; each case owns an isolated bare origin and worktrees."""
import argparse
import os
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
REFERENCE = HERE / 'reference.py'
SUBJECT = REPO / 'scripts/pre_judge.sh'


def run(*argv, cwd=None, env=None):
    return subprocess.run([str(a) for a in argv], cwd=cwd, env=env, text=True, capture_output=True)


def git(cwd, *args):
    p = run('git', *args, cwd=cwd)
    if p.returncode:
        raise AssertionError(f'git {args}: {p.stderr}')
    return p.stdout.strip()


def setup(base):
    bare, root = base / 'origin.git', base / 'repo'
    git(base, 'init', '--bare', str(bare))
    git(base, 'clone', str(bare), str(root))
    git(root, 'config', 'user.name', 'Fixture')
    git(root, 'config', 'user.email', 'fixture@example.invalid')
    git(root, 'switch', '-c', 'main')
    (root / 'README').write_text('initial\n')
    git(root, 'add', 'README')
    git(root, 'commit', '-m', 'base')
    # The harness installation is distinct from the checked project repository R.
    install = base / 'harness/scripts'
    install.mkdir(parents=True)
    (install / 'check_no_leak.sh').write_text('#!/bin/sh\n[ ! -e "$2/leak.flag" ]\n')
    (install / 'pre_judge.sh').write_bytes(SUBJECT.read_bytes() if SUBJECT.is_file() else b'')
    (install / 'reference.py').write_bytes(REFERENCE.read_bytes())
    git(root, 'push', '-u', 'origin', 'main')
    git(bare, 'symbolic-ref', 'HEAD', 'refs/heads/main')
    git(root, 'switch', '-c', 'wip/172/architect')
    (root / 'README').write_text('author\n')
    git(root, 'commit', '-am', 'author')
    git(root, 'push', '-u', 'origin', 'wip/172/architect')
    # This installed detector reads an independently controlled project leak flag.
    # The gate runs as a separate process from the installation, not from R.
    state = base / 'state'
    state.mkdir()
    return root, state


def evaluate(mode, case, root, state, model, mutant=''):
    args = [mode, '--repo', str(root)]
    if mode == 'prepare':
        args += ['--branch', 'wip/172/architect']
        if case != 'prepare_no_state':
            args += ['--sostojanie', str(state)]
        args += ['--timeout', '0.05']
    if mode == 'verdict' and case != 'verdict_no_file':
        args += ['--file', 'verdicts/critic/contracts-172-v1.md']
    env = os.environ.copy()
    if mutant:
        env['STAB_172'] = mutant
    if model:
        return run(sys.executable, root.parent / 'harness/scripts/reference.py', *args, env=env)
    if not SUBJECT.is_file():
        return run('sh', '-c', 'printf "NE_REALIZOVANO: scripts/pre_judge.sh\\n" >&2; exit 2')
    return run('bash', root.parent / 'harness/scripts/pre_judge.sh', *args, env=env)


def case_input(name, root, state, base):
    if name in ('published', 'missing_origin', 'stale_origin', 'state_inside', 'manifest_wait', 'leak_reject', 'prepare_no_state'):
        if name == 'missing_origin':
            git(root, 'push', 'origin', '--delete', 'wip/172/architect')
        if name == 'stale_origin':
            (root / 'README').write_text('new author\n')
            git(root, 'commit', '-am', 'author ahead')
        if name == 'state_inside':
            state = root / 'state'
            state.mkdir()
        if name == 'manifest_wait':
            (root / '.omp/context').mkdir(parents=True)
            (root / '.omp/context/172.tsv').write_text('pending\n')
        if name == 'leak_reject':
            (root / 'leak.flag').touch()
        return 'prepare', state
    if name in ('ff_sync', 'nonff_sync'):
        git(root, 'switch', 'main')
        if name == 'nonff_sync':
            (root / 'README').write_text('local main ahead\n')
            git(root, 'commit', '-am', 'local main')
        # advance origin/main independently in another checkout
        other = base / 'publisher'
        git(base, 'clone', str(base / 'origin.git'), str(other))
        git(other, 'config', 'user.name', 'Publisher')
        git(other, 'config', 'user.email', 'publisher@example.invalid')
        git(other, 'switch', 'main')
        (other / 'remote').write_text('remote\n')
        git(other, 'add', 'remote')
        git(other, 'commit', '-m', 'remote main')
        git(other, 'push', 'origin', 'main')
        git(root, 'fetch', 'origin', 'main')
        return 'sync-main', state
    if name in ('judge_verdict', 'staged_main_verdict', 'committed_main_verdict', 'nonjudge_verdict', 'verdict_no_file'):
        if name in ('staged_main_verdict', 'committed_main_verdict'):
            git(root, 'switch', 'main')
        elif name in ('judge_verdict', 'verdict_no_file'):
            git(root, 'switch', '-c', 'wip/172/critic')
        else:
            git(root, 'switch', '-c', 'wip/172/implementer')
        dest = root / 'verdicts/critic/contracts-172-v1.md'
        dest.parent.mkdir(parents=True)
        dest.write_text('FAIL\n')
        git(root, 'add', str(dest.relative_to(root)))
        if name == 'committed_main_verdict':
            git(root, 'commit', '-m', 'mistaken judge verdict in main')
        return 'verdict', state
    if name in ('archive_free', 'archive_attached'):
        git(root, 'branch', 'archive/172/architect-old')
        if name == 'archive_attached':
            git(root, 'worktree', 'add', str(base / 'archive'), 'archive/172/architect-old')
        return 'archive', state
    raise AssertionError(name)


# Expected diagnosis and witness are independent literals, captured before the subject runs.
CASES = {
    'published': ('OBJECT=', 0, ''),
    'prepare_no_state': ('NE_POLNYJ_VHOD', 1, ''),
    'missing_origin': ('VETKA_NE_OPUBLIKOVANA', 1, 'bash scripts/gitw push origin wip/172/architect'),
    'stale_origin': ('VETKA_NE_OPUBLIKOVANA', 1, 'bash scripts/gitw push origin wip/172/architect'),
    'state_inside': ('SOSTOJANIE_V_CHECKOUT', 1, ''),
    'manifest_wait': ('MANIFESTY_NE_UBRANY', 1, ''),
    'leak_reject': ('CHECK_NO_LEAK_KRASEN', 1, ''),
    'ff_sync': ('MAIN=', 0, ''),
    'nonff_sync': ('MAIN_NE_FAST_FORWARD', 1, 'branch wip/172/architect-main-saved'),
    'judge_verdict': ('VERDICT_BRANCH=wip/172/critic', 0, ''),
    'verdict_no_file': ('NE_POLNYJ_VHOD', 1, ''),
    'nonjudge_verdict': ('NE_SUDJSKAJA_VETKA', 1, ''),
    'staged_main_verdict': ('VERDIKT_V_MAIN', 1, ''),
    'committed_main_verdict': ('VERDIKT_V_MAIN', 1, ''),
    'archive_free': ('ARCHIVE_WORKTREE=0', 0, ''),
    'archive_attached': ('ARCHIVE_WORKTREE', 1, ''),
}
# Pairing is executable only: each mutation must diverge on its own conforming input.
MUTATIONS = {
    'stale_origin': 'stale_origin',
    'prepare_no_state': 'allow_incomplete_prepare',
    'state_inside': 'state_inside',
    'manifest_wait': 'ignore_manifest',
    'leak_reject': 'ignore_leak',
    'nonff_sync': 'allow_nonff',
    'ff_sync': 'ref_only_ff',
    'staged_main_verdict': 'allow_main_verdict',
    'committed_main_verdict': 'allow_main_verdict',
    'verdict_no_file': 'allow_incomplete_verdict',
    'nonjudge_verdict': 'allow_nonjudge_verdict',
    'archive_attached': 'allow_archive_worktree',
}


def check(name, model, mutant='', local_fake=False):
    with tempfile.TemporaryDirectory(prefix='predverie-172-') as temp:
        base = Path(temp)
        root, state = setup(base)
        mode, state = case_input(name, root, state, base)
        if local_fake:
            (root / 'scripts').mkdir()
            (root / 'scripts/check_no_leak.sh').write_text('#!/bin/sh\nexit 0\n')
        if name == 'ff_sync':
            assert not (root / 'remote').exists(), 'publisher file was present before sync'
        before = git(root, 'rev-parse', 'main') if name == 'nonff_sync' else ''
        expected, rc, witness = CASES[name]
        result = evaluate(mode, name, root, state, model, mutant)
        stream = result.stdout if rc == 0 else result.stderr
        ok = (result.returncode == rc
              and (any(line.startswith(expected) for line in stream.splitlines()) if rc == 0
                   else 'ОТКАЗ: ' + expected in stream.splitlines())
              and (not witness or witness in stream))
        if name == 'published' and ok:
            tip = git(root, 'rev-parse', 'refs/remotes/origin/wip/172/architect')
            ok = ('OBJECT=' + tip) in result.stdout and ('SOSTOJANIE=' + str(state.resolve())) in result.stdout
        if name == 'ff_sync' and ok:
            ok = (git(root, 'rev-parse', 'main') == git(root, 'rev-parse', 'origin/main')
                  and (root / 'remote').is_file()
                  and (root / 'remote').read_text() == 'remote\n')
        if name == 'nonff_sync' and ok:
            ok = git(root, 'rev-parse', 'main') == before and ('reset --hard origin/main' in result.stderr)
        if name == 'archive_attached' and ok:
            ok = (base / 'archive').is_dir()
        return ok, result


def main():
    ap = argparse.ArgumentParser()
    group = ap.add_mutually_exclusive_group(required=True)
    group.add_argument('--repo', action='store_true')
    group.add_argument('--model', action='store_true')
    group.add_argument('--stabs', action='store_true')
    opts = ap.parse_args()
    if opts.stabs:
        for name, mutation in MUTATIONS.items():
            good, control = check(name, True)
            caught, suspect = check(name, True, mutation)
            if not good or caught:
                print(f'STAB {mutation} ZHIV: control_rc={control.returncode}, suspect_rc={suspect.returncode}', file=sys.stderr)
                return 1
            print(f'STAB {mutation} caught on {name}')
        for mutation in ('prefer_local', 'ignore_leak_rc'):
            good, control = check('leak_reject', True, local_fake=True)
            caught, suspect = check('leak_reject', True, mutation, local_fake=True)
            if not good or caught:
                print(f'STAB {mutation} ZHIV: control_rc={control.returncode}, suspect_rc={suspect.returncode}', file=sys.stderr)
                return 1
            print(f'STAB {mutation} caught on leak_reject with local fake')
        return 0
    fails = 0
    for name in CASES:
        good, result = check(name, opts.model)
        print(f'{name} {"ok" if good else "KRASNO"} (rc={result.returncode})')
        fails += not good
    return 1 if fails else 0


if __name__ == '__main__':
    sys.exit(main())
