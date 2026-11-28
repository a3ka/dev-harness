#!/usr/bin/env python3
"""Deterministic protocol/transport proof; DOES NOT run the actual 996 matrix.

Only the subprocess transport is replaced in memory. The real adapter judges
full synthetic probe-protocol records; no echo program, fake interpreter, git
world, session, journal, event writer or product subsystem is invoked.
"""
import contextlib
import importlib.util
import io
import os
from pathlib import Path
import runpy
import subprocess
from unittest.mock import patch

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


def invoke(result, fail=False):
    calls = []

    def transport(argv, *, cwd, env, stdout, stderr):
        calls.append(tuple(argv))
        # Literal independent oracle for C201:118, not adapter.COMMAND.
        if (tuple(argv) != ('python3', 'fixtures/workshop_project/rezhim_996/probe.py', '--matrix')
                or env.get('PYTHONDONTWRITEBYTECODE') != '1'):
            raise OSError('lost literal matrix argv or ENV')
        assert cwd == adapter.ROOT
        assert env['MATRIX201_INHERITED_CONTROL'] == 'unchanged'
        tmp = Path(env['TMPDIR']).resolve()
        assert tmp.is_dir() and tmp.is_relative_to(adapter.ROOT / 'tmp')
        assert stdout == subprocess.PIPE and stderr == subprocess.PIPE
        if fail:
            raise OSError('synthetic launch failure')
        return result

    out, err = io.BytesIO(), io.BytesIO()
    sout, serr = io.TextIOWrapper(out, write_through=True), io.TextIOWrapper(err, write_through=True)
    with patch.dict(os.environ, PYTHONDONTWRITEBYTECODE='0', MATRIX201_INHERITED_CONTROL='unchanged'):
        with patch.object(adapter.subprocess, 'run', transport):
            with contextlib.redirect_stdout(sout), contextlib.redirect_stderr(serr):
                rc = adapter.main()
    assert len(calls) == 1, calls
    return rc, out.getvalue(), err.getvalue()


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
    failures = 0
    for label, result, expected in cases:
        rc, out, err = invoke(result)
        ok = rc == expected and out == result.stdout and err == (
            result.stderr + f'matrix201: child_exitstatus={result.returncode}\n'.encode())
        failures += not ok
        print(f'PROOF {label}: child_rc={result.returncode} adapter_rc={rc} expected={expected} preserved={out == result.stdout} ok={int(ok)}')
    rc, _, err = invoke(zero, fail=True)
    ok = rc == 1 and b'execution error' in err
    failures += not ok
    print(f'PROOF launch-error: adapter_rc={rc} expected=1 ok={int(ok)}')
    # Code bindings only: each mutant is shown on its distinguishing input.
    stabs = (
        ('always-green', 'matrix_ok', lambda *args: True, two, 1),
        ('reject-one', 'matrix_ok', lambda r, *args: r.returncode == 0, one, 0),
        ('lost-matrix', 'COMMAND', adapter.COMMAND[:-1], zero, 0),
        ('lost-ENV', 'matrix_env', lambda: dict(os.environ), zero, 0),
    )
    for label, target, value, result, honest in stabs:
        with patch.object(adapter, target, value):
            rc, _, _ = invoke(result)
        caught = rc != honest
        failures += not caught
        print(f'STAB {label}: mutant_rc={rc} honest_rc={honest} caught={int(caught)}')
    print(f'PROOF_FAILURES={failures} ACTUAL_MATRIX=NOT_RUN')
    return int(bool(failures))


if __name__ == '__main__':
    raise SystemExit(main())
