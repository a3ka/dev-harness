#!/usr/bin/env python3
"""Compare family 140 with an independently executed, court-time origin/main tree."""
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[3]
FAMILY = Path('fixtures/workshop_project/odin_agent_140')


class MeasurementError(RuntimeError):
    pass


def command(argv, cwd, **kwargs):
    return subprocess.run(argv, cwd=cwd, capture_output=True, timeout=900,
                          env={**os.environ, 'PYTHONDONTWRITEBYTECODE': '1'}, **kwargs)


def require(argv, cwd):
    result = command(argv, cwd)
    if result.returncode:
        raise MeasurementError(f'command rc={result.returncode}: {argv[0:3]!r}')
    return result.stdout


def measurement(rc, output, expected):
    """Read only the plain runner's CASE records and final complete summary."""
    if rc not in (0, 1) or not expected:
        raise MeasurementError('exit code or empty case domain')
    states = {}
    summaries = []
    lines = output.splitlines()
    for line in lines:
        if line.startswith('CASE '):
            parts = line.split(' ', 3)
            if len(parts) < 3 or parts[1] not in expected:
                raise MeasurementError('unknown or malformed CASE')
            name, state = parts[1:3]
            if state == 'ok' and len(parts) == 3:
                state = 'green'
            elif state == 'KRASNO:' and len(parts) == 4 and parts[3]:
                state = 'red'
            else:
                raise MeasurementError('malformed CASE result')
            if name in states and (state != 'red' or states[name] != 'red'):
                raise MeasurementError('duplicate or conflicting CASE')
            states[name] = state
        elif line.startswith('KLETKI '):
            match = re.fullmatch(r'KLETKI ([0-9]+) KRASNYH ([0-9]+)', line)
            if match is None:
                raise MeasurementError('malformed summary')
            summaries.append(tuple(map(int, match.groups())))
    red = frozenset(name for name, state in states.items() if state == 'red')
    if (set(states) != set(expected) or summaries != [(len(expected), len(red))]
            or not lines or lines[-1] != f'KLETKI {len(expected)} KRASNYH {len(red)}'
            or rc != int(bool(red))):
        raise MeasurementError('incomplete or inconsistent measurement')
    return rc, red


def difference(expected, actual):
    if expected != actual:
        return 'FAMILY140_RESULT_CHANGED'
    return ''


def run_family(root, expected, scratch):
    result = subprocess.run(
        ['bash', str(root / FAMILY / 'red_odin_agent_140.sh')], cwd=root,
        capture_output=True, text=True, timeout=900,
        env={**os.environ, 'TMPDIR': str(scratch), 'PYTHONDONTWRITEBYTECODE': '1'})
    return measurement(result.returncode, result.stdout, expected)


def compare_main():
    # Resolve live main once, before either execution. No candidate ref or
    # historical red-list is an oracle. Missing local objects fail closed.
    remote = require(['bash', str(ROOT / 'scripts/gitw'), 'ls-remote', '--exit-code',
                      'origin', 'refs/heads/main'], ROOT).decode('ascii')
    match = re.fullmatch(r'([0-9a-f]{40})\trefs/heads/main\n', remote)
    if match is None:
        raise MeasurementError('main is not one exact commit')
    sha = match.group(1)
    if require(['git', 'cat-file', '-t', sha], ROOT) != b'commit\n':
        raise MeasurementError('main commit unavailable')
    source = require(['git', 'show', f'{sha}:{FAMILY}/source.json'], ROOT)
    expected_cases = frozenset(json.loads(source)['kejsy'])
    with tempfile.TemporaryDirectory(prefix='.family140-', dir=ROOT) as tmp:
        tmp = Path(tmp)
        base = tmp / 'main'
        base.mkdir()
        archive = tmp / 'main.tar'
        require(['git', 'archive', '--format=tar', f'--output={archive}', sha], ROOT)
        require(['tar', '-xf', str(archive), '-C', str(base)], ROOT)
        require(['git', 'init', '-q', str(base)], ROOT)
        # The complete baseline observation is held in memory before candidate.
        baseline = run_family(base, expected_cases, tmp)
        print(f'FAMILY140_BASE={sha} rc={baseline[0]} red={",".join(sorted(baseline[1]))}',
              flush=True)
        actual = run_family(ROOT, expected_cases, tmp)
        reason = difference(baseline, actual)
        print(f'FAMILY140_CANDIDATE rc={actual[0]} red={",".join(sorted(actual[1]))}')
        if reason:
            print(reason)
            return 1
        print('GREEN family140-baseline')
        return 0


def controls():
    # Each mutation is bound here to the branch where it differs, not in prose.
    cases = frozenset(('first', 'second'))
    honest = 'CASE first KRASNO: refusal\nCASE second ok\nKLETKI 2 KRASNYH 1\n'
    baseline = measurement(1, honest, cases)
    equal = 'CASE second ok\nCASE first KRASNO: another detail\nKLETKI 2 KRASNYH 1\n'
    changed_set = 'CASE first ok\nCASE second KRASNO: refusal\nKLETKI 2 KRASNYH 1\n'
    changed_rc = 'CASE first ok\nCASE second ok\nKLETKI 2 KRASNYH 0\n'
    if difference(baseline, measurement(1, equal, cases)):
        raise RuntimeError('honest equivalent result rejected')
    print('GREEN family140-identical')
    for name, rc, text in (('changed-set', 1, changed_set), ('changed-rc', 0, changed_rc)):
        if difference(baseline, measurement(rc, text, cases)) != 'FAMILY140_RESULT_CHANGED':
            raise RuntimeError(f'STAB_SURVIVED family140-{name}')
        print(f'STAB_CAUGHT family140-{name}: FAMILY140_RESULT_CHANGED')
    for name, rc, text in (
            ('unreadable', 2, ''), ('truncated', 1, honest.rsplit('KLETKI', 1)[0]),
            ('missing-case', 1, 'CASE first KRASNO: refusal\nKLETKI 2 KRASNYH 1\n'),
            ('wrong-summary', 1, honest.replace('KRASNYH 1', 'KRASNYH 0')),
            ('unknown-case', 1, honest.replace('second', 'third')),
            ('conflicting-case', 1, 'CASE first ok\n' + honest),
            ('inconsistent-rc', 0, honest)):
        try:
            measurement(rc, text, cases)
        except MeasurementError:
            print(f'STAB_CAUGHT family140-{name}: FAMILY140_MEASUREMENT_UNKNOWN')
        else:
            raise RuntimeError(f'STAB_SURVIVED family140-{name}')
    return 0


def main():
    try:
        if sys.argv[1:] == ['--stabs']:
            return controls()
        if sys.argv[1:]:
            raise MeasurementError('unexpected arguments')
        return compare_main()
    except (MeasurementError, OSError, ValueError, KeyError, TypeError,
            subprocess.TimeoutExpired, UnicodeError) as error:
        print(f'FAMILY140_MEASUREMENT_UNKNOWN: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
