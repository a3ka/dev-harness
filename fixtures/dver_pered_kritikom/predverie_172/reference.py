#!/usr/bin/env python3
"""Fixture-only executable control. Not installed as a production gate."""
import argparse
import os
from pathlib import Path
import subprocess
import sys
import time


def git(root, *args):
    p = subprocess.run(['git', '-C', str(root), *args], text=True, capture_output=True)
    if p.returncode:
        raise RuntimeError(p.stderr.strip())
    return p.stdout.strip()


def refuse(reason, instruction=''):
    print('ОТКАЗ: ' + reason + (('\n' + instruction) if instruction else ''), file=sys.stderr)
    return 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('mode', choices=['prepare', 'sync-main', 'verdict', 'archive'])
    ap.add_argument('--repo', required=True)
    ap.add_argument('--branch')
    ap.add_argument('--sostojanie')
    ap.add_argument('--file')
    ap.add_argument('--timeout', type=float, default=0.1)
    args = ap.parse_args()
    root = Path(args.repo).resolve()
    mutant = os.getenv('STAB_172', '')
    try:
        if args.mode == 'prepare':
            if (not args.branch or not args.sostojanie) and mutant != 'allow_incomplete_prepare':
                return refuse('NE_POLNYJ_VHOD')
            state = Path(args.sostojanie or root.parent / 'state').resolve()
            if mutant != 'state_inside' and (state == root or root in state.parents):
                return refuse('SOSTOJANIE_V_CHECKOUT')
            local = git(root, 'rev-parse', 'refs/heads/' + args.branch)
            p = subprocess.run(['git', '-C', str(root), 'rev-parse', '--verify', 'refs/remotes/origin/' + args.branch], capture_output=True, text=True)
            if p.returncode or (p.stdout.strip() != local and mutant != 'stale_origin'):
                return refuse('VETKA_NE_OPUBLIKOVANA', 'bash scripts/gitw push origin ' + args.branch)
            end = time.monotonic() + args.timeout
            while list((root / '.omp/context').glob('*.tsv')) and mutant != 'ignore_manifest':
                if time.monotonic() >= end:
                    return refuse('MANIFESTY_NE_UBRANY')
                time.sleep(0.01)
            if mutant != 'ignore_leak':
                p = subprocess.run(['bash', str(root / 'scripts/check_no_leak.sh'), '--check', str(root)], capture_output=True, text=True)
                if p.returncode:
                    return refuse('CHECK_NO_LEAK_KRASEN')
            print('OBJECT=' + git(root, 'rev-parse', 'refs/remotes/origin/' + args.branch))
            print('SOSTOJANIE=' + str(state))
            return 0
        if args.mode == 'sync-main':
            local = git(root, 'rev-parse', 'refs/heads/main')
            remote = git(root, 'rev-parse', 'refs/remotes/origin/main')
            if subprocess.run(['git', '-C', str(root), 'merge-base', '--is-ancestor', local, remote]).returncode:
                if mutant != 'allow_nonff':
                    return refuse('MAIN_NE_FAST_FORWARD', 'git -C ' + str(root) + ' branch wip/172/architect-main-saved ' + local + ' && git -C ' + str(root) + ' reset --hard origin/main')
                git(root, 'reset', '--hard', 'origin/main')
            elif local != remote:
                if mutant == 'ref_only_ff':
                    git(root, 'update-ref', 'refs/heads/main', remote)
                else:
                    git(root, 'merge', '--ff-only', 'origin/main')
            print('MAIN=' + remote)
            return 0
        if args.mode == 'verdict':
            if not args.file and mutant != 'allow_incomplete_verdict':
                return refuse('NE_POLNYJ_VHOD')
            branch = git(root, 'symbolic-ref', '--short', 'HEAD')
            path = Path(args.file or 'verdicts/critic/contracts-172-v1.md')
            if mutant != 'allow_main_verdict' and branch == 'main' and (git(root, 'status', '--porcelain', '--', str(path)) or git(root, 'log', '-1', '--format=%H', '--', str(path))):
                return refuse('VERDIKT_V_MAIN')
            if mutant not in ('allow_main_verdict', 'allow_nonjudge_verdict') and not (branch.startswith('wip/') and branch.split('/')[-1] in ('critic', 'adversary', 'reviewer', 'arbiter')):
                return refuse('NE_SUDJSKAJA_VETKA')
            print('VERDICT_BRANCH=' + branch)
            return 0
        if args.mode == 'archive':
            for line in git(root, 'worktree', 'list', '--porcelain').splitlines():
                if mutant != 'allow_archive_worktree' and line.startswith('branch refs/heads/archive/'):
                    return refuse('ARCHIVE_WORKTREE')
            print('ARCHIVE_WORKTREE=0')
            return 0
    except RuntimeError as e:
        return refuse('GIT_NEDOSTUPEN: ' + str(e))


if __name__ == '__main__':
    sys.exit(main())
