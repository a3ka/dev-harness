#!/usr/bin/env python3
"""Reproducible serial checks in an SSH-origin clone; all writes stay in own tree."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
FAMILY = 'fixtures/workshop_project/karta_krome_232'
CONTRACT = 'contracts/232-gramm-karta-krome.md'
BASE = '8fe4e79ca8c5165bcd1e7dfb75768c5bd329d3cb'
ORIGIN = 'ssh://git@github.com/a3ka/dev-harness.git'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--prepare', action='store_true')
    parser.add_argument('--only', nargs='*')
    args = parser.parse_args()
    destination = ROOT / 'tmp/verify232-origin'
    records = ROOT / 'tmp/verify232-results.json'
    env = dict(os.environ, PYTHONDONTWRITEBYTECODE='1',
               VALIDATE_STD_SHELLCHECK='/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck',
               SDACHA_TIMEOUT_SEK='1200', SDACHA_BUDZHET_SEK='2400')
    scratch = ROOT / 'tmp/scratch-arch232'
    scratch.mkdir(parents=True, exist_ok=True)
    env['TMPDIR'] = str(scratch)
    results = []
    if records.exists():
        results = json.loads(records.read_text())

    def execute(name, argv, cwd, expected=0):
        start = time.monotonic()
        p = subprocess.run(argv, cwd=cwd, env=env, capture_output=True, text=True)
        record = dict(name=name, command=argv, cwd=str(cwd), rc=p.returncode,
                      expected=expected, seconds=round(time.monotonic() - start, 2),
                      stdout=p.stdout, stderr=p.stderr)
        results.append(record)
        records.write_text(json.dumps(results, ensure_ascii=False, indent=2) + '\n')
        print(name, 'rc=' + str(p.returncode), 'expected=' + str(expected),
              'seconds=' + str(record['seconds']), flush=True)
        print(p.stdout, end='', flush=True)
        print(p.stderr, end='', file=sys.stderr, flush=True)
        return p.returncode == expected

    if args.prepare:
        if destination.exists():
            print('STOP: occupied verification path: ' + str(destination), file=sys.stderr)
            return 2
        if not execute('origin-clone', ['bash', str(ROOT / 'scripts/gitw'), 'clone', '--quiet',
                                       '--branch', 'wip/232/orchestrator-c1', '--single-branch',
                                       ORIGIN, str(destination)], ROOT):
            return 2
        if not execute('origin-tags', ['bash', 'scripts/gitw', 'fetch', 'origin', '+refs/heads/main:refs/remotes/origin/main', '+refs/tags/*:refs/tags/*'], destination):
            return 2
        if not execute('base', ['git', 'switch', '--detach', BASE], destination):
            return 2
        if not execute('origin-identity', ['git', 'remote', 'get-url', 'origin'], destination):
            return 2
    if not destination.is_dir():
        print('NOT_IMPLEMENTED: run --prepare first', file=sys.stderr)
        return 2
    # Deliver just the assigned artifacts; never overlay production or old batteries.
    old_family = destination / FAMILY
    if old_family.exists():
        shutil.rmtree(old_family)
    shutil.copytree(ROOT / FAMILY, old_family)
    shutil.copyfile(ROOT / CONTRACT, destination / CONTRACT)
    checks = [('model', ['bash', FAMILY + '/red_karta_krome_232.sh', '--model'], 0),
              ('stabs', ['bash', FAMILY + '/red_karta_krome_232.sh', '--stabs'], 0),
              ('sintaksis', ['bash', FAMILY + '/red_karta_krome_232.sh', '--sintaksis'], 0),
              ('catalog', ['bash', FAMILY + '/red_karta_krome_232.sh', '--catalog'], 0),
              ('repo', ['bash', FAMILY + '/red_karta_krome_232.sh', '--repo', '.'], 1),
              ('context', ['python3', '-B', FAMILY + '/context.py'], 0),
              ('pre_critic', ['bash', 'scripts/pre_critic.sh', CONTRACT], 0),
              ('sdacha', ['bash', 'scripts/check_sdacha.sh', '.', CONTRACT, '--run'], 0),
              ('precision', ['bash', 'scripts/check_precision_gate.sh', '.', CONTRACT], 0),
              ('regression193', ['bash', 'fixtures/workshop_project/sdacha_193/red_sdacha_193.sh', '--repo', '.'], 0),
              ('regression224', ['bash', 'fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh', '--repo', '.'], 0)]
    bad = 0
    for name, argv, expected in checks:
        if args.only is None or name in args.only:
            bad += not execute(name, argv, destination, expected)
    print('EVIDENCE', records, 'UNEXPECTED', bad)
    return int(bad != 0)


if __name__ == '__main__':
    sys.exit(main())
