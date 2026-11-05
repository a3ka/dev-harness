#!/usr/bin/env python3
"""Replay the effective freeze-version steps in both workflows against a fake Maestro CLI.

python3 version_replay.py --repo /path/to/Complior-mob --base <SHA> --model|--stabs
python3 version_replay.py --repo /path/to/Complior-mob --base <SHA> --head <C> --model
This is a shell replay of the pinned future workflow, not an Android execution.
"""
import argparse
import os
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory

from compare_carriers import CLOUD, MOBILE, PINS, VERSION_SCRIPT, parse, snapshot, resolve
from matrix_carriers import dump, honest

HERE = Path(__file__).resolve().parent


def step_for(tree, path):
    job = 'android-e2e' if path == MOBILE else 'android-e2e-cloud'
    steps = parse(tree[path])['jobs'][job]['steps']
    matches = [step for step in steps if step.get('id') == 'rehearsal_version']
    if len(matches) != 1:
        raise AssertionError(f'{path}: expected exactly one version step')
    return matches[0]


def replay(tree, path, version):
    with TemporaryDirectory(prefix='991-version-') as scratch:
        root = Path(scratch)
        (root / 'bin').mkdir()
        mobile = root / 'mobile'
        script = mobile / 'scripts' / 'check-maestro-version.sh'
        script.parent.mkdir(parents=True)
        script.write_bytes(tree[VERSION_SCRIPT])
        fake = root / 'bin' / 'maestro'
        fake.write_text('#!/bin/sh\nprintf "%s\\n" "$MAESTRO_FAKE_VERSION"\n')
        fake.chmod(0o755)
        step = step_for(tree, path)
        cwd = mobile if step.get('working-directory', 'mobile') == 'mobile' else root
        env = dict(os.environ, PATH=str(root / 'bin') + os.pathsep + os.environ['PATH'],
                   MAESTRO_FAKE_VERSION=version)
        proc = subprocess.run(['bash', '--noprofile', '--norc', '-eo', 'pipefail', '-c', step['run']],
                              cwd=cwd, env=env, text=True, capture_output=True)
        return proc.returncode, proc.stdout + proc.stderr


def verify(label, tree, path, version, expected_rc, reason):
    rc, output = replay(tree, path, version)
    valid = (rc == expected_rc and (reason in output if reason else 'MAESTRO_VERSION_MISMATCH' not in output))
    print(f'991 version/{label}: branch={"station" if path == MOBILE else "cloud"} '
          f'version={version} rc={rc} expected={expected_rc} '
          f'reason={reason or "NONE"} matched={valid}', flush=True)
    if not valid:
        print(output, file=sys.stderr)
    return valid


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--base', required=True)
    parser.add_argument('--head', help='replay actual candidate Git objects instead of the freeze model')
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--model', action='store_true')
    mode.add_argument('--stabs', action='store_true')
    args = parser.parse_args()
    pins = {path: (HERE / name).read_bytes() for path, (name, _) in PINS.items()}
    if args.head and args.stabs:
        parser.error('--stabs is available for the freeze model only')
    model = (snapshot(args.repo, resolve(args.repo, args.head)) if args.head else
             honest(snapshot(args.repo, resolve(args.repo, args.base)), 'freeze', pins))
    if model.get(VERSION_SCRIPT) != (HERE / 'check-maestro-version.sh').read_bytes():
        print(f'991 VERSION_SCRIPT_MISMATCH: {VERSION_SCRIPT}', file=sys.stderr)
        return 1
    failures = 0
    for path in (MOBILE, CLOUD):
        for version, expected, reason in (('2.10.0', 1, 'MAESTRO_VERSION_MISMATCH'),
                                          ('2.11.0', 0, '')):
            failures += not verify('honest', model, path, version, expected, reason)
        if args.stabs:
            for name, bad_run, version, expected, reason in (
                ('skip-mismatch', 'true', '2.10.0', 1, 'MAESTRO_VERSION_MISMATCH'),
                ('reject-correct', 'echo MAESTRO_VERSION_MISMATCH >&2; exit 1', '2.11.0', 0, ''),
            ):
                stub = dict(model)
                workflow = parse(stub[path])
                job = 'android-e2e' if path == MOBILE else 'android-e2e-cloud'
                next(s for s in workflow['jobs'][job]['steps'] if s.get('id') == 'rehearsal_version')['run'] = bad_run
                stub[path] = dump(workflow)
                # Mutate only this branch's effective run; never rely on the other branch's failure.
                accepted = verify(name, stub, path, version, expected, reason)
                print(f'991 version/stub-{name}: branch={"station" if path == MOBILE else "cloud"} '
                      f'caught={not accepted}', flush=True)
                failures += accepted
            stub = dict(model)
            stub[VERSION_SCRIPT] = b'#!/bin/sh\nmaestro --version || true\n'
            accepted = verify('script-placebo', stub, path, '2.10.0', 1, 'MAESTRO_VERSION_MISMATCH')
            print(f'991 version/stub-script-placebo: branch={"station" if path == MOBILE else "cloud"} '
                  f'caught={not accepted}', flush=True)
            failures += accepted
    print(f'991 version replay: failures={failures}')
    return int(bool(failures))


if __name__ == '__main__':
    sys.exit(main())
