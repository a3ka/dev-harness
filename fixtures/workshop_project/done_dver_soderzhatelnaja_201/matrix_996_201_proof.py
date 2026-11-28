#!/usr/bin/env python3
"""Deterministic matrix_ok protocol proof; DOES NOT run the actual 996 matrix.

The real predicate judges full synthetic probe-protocol records. The same
verifier rejects always-green and reject-one controls on distinguishing inputs.
No subprocess transport, git world or product subsystem is invoked.
"""
import importlib.util
from pathlib import Path
import runpy
import subprocess

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('matrix201', HERE / 'matrix_996_201.py')
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)
probe = runpy.run_path(str(adapter.ROOT / 'fixtures/workshop_project/rezhim_996/probe.py'))
CASES, MUTANTS = tuple(probe['CASES']), dict(probe['MUTANTS'])


def report(mismatches=0):
    lines = [f'{case}: rc=0 ' for case in CASES]
    for i, (mutant, case) in enumerate((m, c) for m, cs in MUTANTS.items() for c in cs):
        lines.append(f'mutation {mutant}: {case}: rc={0 if i < mismatches else 1} ')
    lines.append(f'996: examined=111 mutants={len(MUTANTS)} mismatches={mismatches}')
    if mismatches:
        lines.append('996: проектный цикл не замкнут')
    return subprocess.CompletedProcess((), int(mismatches != 0),
                                       ('\n'.join(lines) + '\n').encode(), b'')


def changed(result, *, stdout=None, stderr=None, rc=None):
    return subprocess.CompletedProcess((), result.returncode if rc is None else rc,
                                     result.stdout if stdout is None else stdout,
                                     result.stderr if stderr is None else stderr)


def verify(predicate, scenarios, name):
    failures = 0
    for label, result, expected in scenarios:
        rc = 0 if predicate(result, CASES, MUTANTS) else 1
        ok = rc == expected
        failures += not ok
        print(f'PROOF {name}/{label}: child_rc={result.returncode} predicate_rc={rc} expected={expected} ok={int(ok)}')
    print(f'VERIFY {name}: failures={failures}')
    return int(bool(failures))


def main():
    zero, one, two = report(0), report(1), report(2)
    first_mutation = next((m, cs[0]) for m, cs in MUTANTS.items() if cs)
    prefix = f'mutation {first_mutation[0]}: {first_mutation[1]}: rc=0 '.encode()
    base_one = changed(one, stdout=one.stdout.replace(
        f'{CASES[0]}: rc=0 '.encode(), f'{CASES[0]}: rc=1 assertion'.encode(), 1)
        .replace(prefix, prefix.replace(b'rc=0', b'rc=1'), 1))
    cases = [
        ('zero', zero, 0), ('one', one, 0), ('over-one', two, 1),
        ('examined-not-111', changed(zero, stdout=zero.stdout.replace(b'examined=111', b'examined=110')), 1),
        ('raw-status-contradiction', changed(one, rc=0), 1),
        ('runtime-status', changed(zero, rc=2), 1),
        ('signal-status', changed(zero, rc=-15), 1),
        ('runtime-stderr-with-valid-stdout', changed(one, stderr=b'Traceback: synthetic runtime failure\n'), 1),
        ('unparsed', changed(zero, stdout=b'not matrix output\n'), 1),
        ('duplicate-summary', changed(zero, stdout=zero.stdout + zero.stdout.splitlines()[-1] + b'\n'), 1),
        ('counter-contradiction', changed(one, stdout=one.stdout.replace(b'mismatches=1', b'mismatches=0')), 1),
        ('missing-record', changed(zero, stdout=zero.stdout.split(b'\n', 1)[1]), 1),
        ('mutant-execution-error', changed(one, stdout=one.stdout.replace(
            prefix, prefix.replace(b'rc=0 ', b'rc=2 PROBE_ERROR: synthetic error'), 1)), 1),
        ('bad-encoding', changed(zero, stdout=zero.stdout + b'\xff'), 1),
        ('base-case-one', base_one, 0),
        ('detail-variation', changed(one, stdout=one.stdout.replace(b': rc=1 ', b': rc=1 arbitrary assertion detail')), 0),
    ]
    failures = verify(adapter.matrix_ok, cases, 'honest')

    def always_green(result, cases, mutants):
        return True

    def reject_one(result, cases, mutants):
        return result.returncode == 0 and adapter.matrix_ok(result, cases, mutants)

    # Code bindings only: run the same verifier at each observable defect.
    stabs = (
        ('always-green', always_green, 'over-one'),
        ('reject-one', reject_one, 'one'),
    )
    for label, predicate, distinguishing in stabs:
        scenarios = [case for case in cases if case[0] == distinguishing]
        rc = verify(predicate, scenarios, label)
        caught = rc == 1
        failures += not caught
        print(f'STAB {label}: verifier_rc={rc} expected=1 caught={int(caught)}')
    print(f'PROOF_FAILURES={failures} ACTUAL_MATRIX=NOT_RUN')
    return int(bool(failures))


if __name__ == '__main__':
    raise SystemExit(main())
