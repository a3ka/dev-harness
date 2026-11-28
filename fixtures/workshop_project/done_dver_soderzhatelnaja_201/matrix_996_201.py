#!/usr/bin/env python3
"""C201:118 only: execute the literal matrix command, then judge its protocol.

The probe's rc=1 includes both the permitted one mismatch and forbidden results.
Its own CASES/MUTANTS supply the record order before the child is launched.
"""
import os
from pathlib import Path
import re
import runpy
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
COMMAND = ('python3', 'fixtures/workshop_project/rezhim_996/probe.py', '--matrix')


def matrix_env():
    return dict(os.environ, PYTHONDONTWRITEBYTECODE='1')


def matrix_ok(result, cases, mutants):
    """Validate exactly probe.py:1567–1590, not a generic stdout/rc evaluator."""
    if result.returncode not in (0, 1):
        return False
    try:
        lines = result.stdout.decode('utf-8').splitlines()
    except UnicodeDecodeError:
        return False
    # rc=2/PROBE_ERROR is an execution failure, including in mutant worlds:
    # the producer counts that as a mismatch, not as a successful rejection.
    if b'PROBE_ERROR:' in result.stdout or result.stderr:
        return False
    records = [(f'{case}: rc=', False) for case in cases]
    records += [(f'mutation {mutant}: {case}: rc=', True)
                for mutant, branches in mutants.items() for case in branches]
    if len(lines) < len(records) + 1:
        return False
    errors = 0
    for line, (prefix, mutation) in zip(lines, records):
        if not line.startswith(prefix):
            return False
        outcome = re.fullmatch(r'([01]) (.*)', line[len(prefix):])
        if outcome is None:
            return False
        rc = int(outcome[1])
        errors += (rc != 1) if mutation else rc
    expected = f'996: examined={len(cases)} mutants={len(mutants)} mismatches={errors}'
    tail = [expected] + (['996: проектный цикл не замкнут'] if errors else [])
    return (len(cases) == 111 and errors <= 1
            and lines[len(records):] == tail
            and result.returncode == int(errors != 0))


def main():
    # Definitions only; __main__ is not invoked. No copy of the matrix catalogue.
    probe = runpy.run_path(str(ROOT / COMMAND[1]))
    cases, mutants = tuple(probe['CASES']), dict(probe['MUTANTS'])
    try:
        result = subprocess.run(COMMAND, cwd=ROOT, env=matrix_env(),
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except OSError as error:
        print(f'matrix201: execution error: {error}', file=sys.stderr)
        return 1
    # Preserve original bytes and raw status, even on protocol/runtime failure.
    sys.stdout.buffer.write(result.stdout)
    sys.stdout.buffer.flush()
    sys.stderr.buffer.write(result.stderr)
    sys.stderr.buffer.flush()
    print(f'matrix201: child_exitstatus={result.returncode}', file=sys.stderr)
    return 0 if matrix_ok(result, cases, mutants) else 1


if __name__ == '__main__':
    raise SystemExit(main())
