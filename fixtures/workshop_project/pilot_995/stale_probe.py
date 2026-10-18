#!/usr/bin/env python3
"""Stale-challenge generation probes (995, круг 1 ревьюера B1).

После смены e-mail отложенные ответы СТАРОГО challenge — confirmed resend и
прочитанная сессия — не применяются к новому challenge: нет «Ein neuer Code
wurde gesendet.» и cooldown для неподтверждённого адреса, F02.01 не открывается.
Порты в тесте — deferred-наблюдатели над отгружаемой композицией; source.json
и байты теста сняты в память до исполнения субъекта.
"""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from runtime_probe import installed

HERE = Path(__file__).resolve().parent
CASES = ['REV_STALE_RESEND', 'REV_STALE_SESSION']


def run(repo, cases=None):
    repo = repo.resolve()
    if not repo.is_relative_to('/tmp/dev-harness-verify'): raise RuntimeError('DISPOSABLE_REQUIRED')
    mobile = repo / 'mobile'
    bootstrap = mobile / 'src/bootstrap'
    if not (bootstrap / 'pilot-app.tsx').exists():
        print('995 PILOT_ABSENT'); return 1, 'PILOT_ABSENT'
    test_bytes = (HERE / 'stale.test.tsx').read_bytes()
    source = (HERE / 'source.json').read_bytes()
    secret = 'synthetic-verification-value'
    existed = bootstrap.exists()
    bootstrap.mkdir(parents=True, exist_ok=True)
    workspace = Path(tempfile.mkdtemp(prefix='__stale995_', dir=bootstrap))
    results = []
    failures = []
    try:
        with installed({workspace / 'stale.test.tsx': test_bytes,
                        workspace / 'source.json': source}):
            for case in cases or CASES:
                report = workspace / 'report.json'
                report.unlink(missing_ok=True)
                env = dict(os.environ, EXPO_PUBLIC_API_MODE='mock', PILOT_995_MODEL='actual')
                env.pop('PILOT_DEMO_CODE', None)
                cmd = ['node', str(mobile / 'node_modules/jest/bin/jest.js'), '--ci', '--runInBand',
                       '--runTestsByPath', str(workspace / 'stale.test.tsx'),
                       '--testNamePattern', '^995 stale ' + case + '$',
                       '--json', '--outputFile', str(report)]
                proc = subprocess.run(cmd, cwd=mobile, env=env, capture_output=True, text=True, timeout=90)
                if not report.exists(): raise RuntimeError('JEST_REPORT_MISSING:' + proc.stderr[-1500:])
                payload = json.loads(report.read_text())
                assertions = [a for suite in payload['testResults'] for a in suite['assertionResults'] if a['status'] != 'pending']
                if len(assertions) != 1 or assertions[0]['title'] != case: raise RuntimeError('ASSERTION_SET_MISMATCH:' + proc.stderr[-1500:])
                result = assertions[0]
                rc = int(result['status'] == 'failed')
                if result['status'] not in ('passed', 'failed') or proc.returncode != rc: raise RuntimeError('RC_ASSERTION_MISMATCH')
                messages = '\n'.join(result['failureMessages']).replace(secret, '[REDACTED]')
                results.append(rc); failures.append(messages)
                print(f'995 stale/{case}: rc={rc}', flush=True)
                if rc: print(messages, file=sys.stderr)
    finally:
        shutil.rmtree(workspace)
        if not existed: bootstrap.rmdir()
    return int(any(results)), '\n'.join(failures)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--case', choices=CASES)
    args = parser.parse_args()
    rc, _ = run(args.repo, [args.case] if args.case else None)
    return rc


if __name__ == '__main__':
    try: sys.exit(main())
    except (OSError, RuntimeError, ValueError, KeyError, subprocess.TimeoutExpired) as error:
        print('995 INFRASTRUCTURE:', error, file=sys.stderr); sys.exit(2)
