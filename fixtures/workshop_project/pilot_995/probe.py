#!/usr/bin/env python3
"""Frozen RNTL probe; code binds each countermodel to an observable branch."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
CASES = ['DIRECT_unknown', 'DIRECT_incomplete', 'INVALID_CODE', 'RESEND_UNCONFIRMED', 'RESEND_CONFIRMED', 'RESEND_COOLDOWN', 'EMAIL_STALE', 'RECOVERY_A07', 'AUTH_stale', 'AUTH_revoked', 'AUTH_missing_scope', 'SECRET', 'REPLAY', 'DEFAULT_OFFLINE']
MUTANTS = [
    ('start', 'DIRECT_unknown', 'F02.01'),
    ('start', 'DIRECT_incomplete', 'F02.01'),
    ('skip-reads', 'DIRECT_unknown', 'toHaveBeenCalledTimes'),
    ('accept-invalid', 'INVALID_CODE', 'auth-invalid'),
    ('eager-sent', 'RESEND_UNCONFIRMED', 'toBeNull'),
    ('never-sent', 'RESEND_CONFIRMED', 'Ein neuer Code'),
    ('fake-wait', 'RESEND_CONFIRMED', 'toBeNull'),
    ('drop-wait', 'RESEND_COOLDOWN', 'auth-cooldown'),
    ('unmarked', 'RESEND_CONFIRMED', 'SYNTHETIC'),
    ('stale-email', 'EMAIL_STALE', 'toBeNull'),
    ('missing-a07', 'RECOVERY_A07', 'recovery-A07'),
    ('accept-denied', 'AUTH_stale', 'toBeNull'),
    ('accept-denied', 'AUTH_revoked', 'toBeNull'),
    ('accept-denied', 'AUTH_missing_scope', 'toBeNull'),
    ('secret', 'SECRET', 'not.toContain'),
    ('replay', 'REPLAY', '995 BUSINESS_COMMAND_FORBIDDEN'),
    ('http-default', 'DEFAULT_OFFLINE', '995 HTTP_UNAVAILABLE'),
]


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--repo', type=Path, required=True)
    p.add_argument('--matrix', action='store_true')
    p.add_argument('--model', choices=['honest'] + sorted({m for m, _, _ in MUTANTS}))
    p.add_argument('--case', choices=CASES)
    a = p.parse_args()
    repo = a.repo.resolve()
    if not repo.is_relative_to('/tmp/dev-harness-verify'):
        raise RuntimeError('DISPOSABLE_REQUIRED')
    mobile = repo / 'mobile'
    subject = mobile / 'src/features/auth/pilot-app.tsx'
    testdir = subject.parent / '__tests__'
    test = testdir / 'pilot-995.test.tsx'
    data = testdir / 'source.json'
    if test.exists() or data.exists():
        raise RuntimeError('OCCUPIED_TEST_PATH')
    # Oracle and all executable specification bytes are captured before subject execution.
    test_bytes = (HERE / 'pilot.test.tsx').read_bytes()
    source_bytes = (HERE / 'source.json').read_bytes()
    model_bytes = (HERE / 'model.tsx').read_bytes()
    original = subject.read_bytes() if subject.exists() else None
    if not a.matrix and not a.model and original is None:
        print('995 PILOT_ABSENT: real composition seam is not implemented')
        return 1
    rows = [('honest', None, 0, '')] + [(m, c, 1, reason) for m, c, reason in MUTANTS] if a.matrix else [(a.model or 'actual', a.case, None, '')]
    results = []
    testdir.mkdir(parents=True, exist_ok=True)
    try:
        test.write_bytes(test_bytes)
        data.write_bytes(source_bytes)
        with tempfile.TemporaryDirectory(prefix='pilot995-', dir=repo.parent) as temp:
            for index, (mode, case, expected, reason) in enumerate(rows):
                if mode != 'actual': subject.write_bytes(model_bytes)
                output = Path(temp) / f'{index}.json'
                cmd = ['node', str(mobile / 'node_modules/jest/bin/jest.js'), '--ci', '--runInBand', '--runTestsByPath', str(test), '--json', '--outputFile', str(output)]
                if case: cmd += ['--testNamePattern', '^995 pilot ' + case + '$']
                proc = subprocess.run(cmd, cwd=mobile, env=dict(os.environ, PILOT_995_MODEL=mode), capture_output=True, text=True, timeout=90)
                if not output.exists(): raise RuntimeError('JEST_REPORT_MISSING: ' + proc.stderr[-1500:])
                report = json.loads(output.read_text())
                assertions = [x for s in report['testResults'] for x in s['assertionResults'] if x['status'] != 'pending']
                wanted = [case] if case else CASES
                if sorted(x['title'] for x in assertions) != sorted(wanted):
                    raise RuntimeError('ASSERTION_SET_MISMATCH: ' + proc.stderr[-1500:])
                if any(x['status'] not in ('passed', 'failed') for x in assertions): raise RuntimeError('ASSERTION_NOT_EXECUTED')
                failed = [x for x in assertions if x['status'] == 'failed']
                if proc.returncode != int(bool(failed)): raise RuntimeError('RC_ASSERTION_MISMATCH')
                if expected == 1 and not any(reason in '\n'.join(x['failureMessages']) for x in failed):
                    raise RuntimeError('WRONG_RED_REASON: ' + proc.stderr[-1500:])
                for x in assertions:
                    print(f"995 {mode}/{x['title']}: rc={int(x['status'] == 'failed')} assertion={x['status']}", flush=True)
                if failed and expected != 1:
                    # Redact full code even when Jest renders actual/expected values.
                    print(proc.stderr.replace('synthetic-verification-value', '[REDACTED]'), file=sys.stderr)
                results.append((proc.returncode, expected))
    finally:
        if original is None: subject.unlink(missing_ok=True)
        else: subject.write_bytes(original)
        test.unlink(missing_ok=True)
        data.unlink(missing_ok=True)
    print(f'995 runs={len(results)} mismatches={sum(rc != expected for rc, expected in results if expected is not None)}')
    return int(any(rc != expected if expected is not None else rc != 0 for rc, expected in results))


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, KeyError, subprocess.TimeoutExpired) as error:
        print(f'995 INFRASTRUCTURE: {error}', file=sys.stderr)
        sys.exit(2)
