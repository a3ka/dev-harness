#!/usr/bin/env python3
"""Таблица переходов stale-поколений (995, круг 2 ревьюера B1′).

ОДИН jest-запуск по table-driven ячейкам: каждый асинхронный порт
(begin, verify, resend, getSession, recover) × каждый достижимый переход
автомата (смена e-mail, возврат handleReturn, повторный begin, resend,
unmount/remount). Отложенный ответ ПРЕДЫДУЩЕГО поколения не меняет
UI/состояние. Ячейки круга 1 (REV_STALE_*) остаются в stale_probe.py;
здесь обобщение класса: RETURN/BEGIN_REBEGIN красные на C без поколенческого
стража на handleReturn/handleDemoEntry. LIVE_* — живой контроль.
Байты теста и source.json сняты в память до исполнения субъекта;
множество assertions сверяется с CASES (ASSERTION_SET_MISMATCH).
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
CASES = [
    # сторож исчерпывающего перечня автомата
    'SENTRY_HANDLERS',
    # begin
    'BEGIN_REBEGIN', 'BEGIN_UNMOUNT',
    # verify
    'VERIFY_CHANGE_EMAIL', 'VERIFY_CHANGE_EMAIL_EARLY', 'VERIFY_RETURN', 'VERIFY_RESEND',
    'VERIFY_REBEGIN', 'VERIFY_UNMOUNT', 'VERIFY_NO_ACCESS',
    # resend
    'RESEND_CHANGE_EMAIL', 'RESEND_RETURN', 'RESEND_RESEND',
    'RESEND_REBEGIN', 'RESEND_UNMOUNT', 'RESEND_NO_ACCESS',
    # getSession
    'GETSESSION_CHANGE_EMAIL', 'GETSESSION_RETURN', 'GETSESSION_RESEND', 'GETSESSION_REBEGIN',
    'GETSESSION_UNMOUNT', 'GETSESSION_NO_ACCESS',
    # recover
    'RECOVER_RETURN', 'RECOVER_REBEGIN', 'RECOVER_UNMOUNT', 'RECOVER_NO_SUCCESS',
    # перенос уже применённого состояния (B1'')
    'RECORD_NOACCESS_RETURN_SENT', 'RECORD_NOACCESS_RETURN_COOLDOWN',
    'RECORD_NOACCESS_RETURN_INVALID', 'RECORD_NOACCESS_RETURN_CODE',
    # окно handleReturn (resolve до re-begin)
    'RETURN_GUARD_EARLY',
    # обработчики, не отменяющие challenge
    'FIRST_RUN_KEEP', 'EMAIL_CHANGE_PENDING_KEEP', 'CODE_CHANGE_KEEP_CHALLENGE',
    # живые контроли
    'LIVE_RESEND_NOTICE', 'LIVE_VERIFY_WELCOME',
]


def run(repo, cases=None):
    repo = repo.resolve()
    if not repo.is_relative_to('/tmp/dev-harness-verify'): raise RuntimeError('DISPOSABLE_REQUIRED')
    mobile = repo / 'mobile'
    bootstrap = mobile / 'src/bootstrap'
    if not (bootstrap / 'pilot-app.tsx').exists():
        print('995 PILOT_ABSENT'); return 1, 'PILOT_ABSENT'
    test_bytes = (HERE / 'stale_table.test.tsx').read_bytes()
    source = (HERE / 'source.json').read_bytes()
    secret = 'synthetic-verification-value'
    expected = ['995 table ' + case for case in (cases or CASES)]
    existed = bootstrap.exists()
    bootstrap.mkdir(parents=True, exist_ok=True)
    workspace = Path(tempfile.mkdtemp(prefix='__staletable995_', dir=bootstrap))
    failures = []
    try:
        with installed({workspace / 'stale_table.test.tsx': test_bytes,
                        workspace / 'source.json': source}):
            report = workspace / 'report.json'
            report.unlink(missing_ok=True)
            env = dict(os.environ, EXPO_PUBLIC_API_MODE='mock', PILOT_995_MODEL='actual')
            env.pop('PILOT_DEMO_CODE', None)
            cmd = ['node', str(mobile / 'node_modules/jest/bin/jest.js'), '--ci', '--runInBand',
                   '--runTestsByPath', str(workspace / 'stale_table.test.tsx'),
                   '--json', '--outputFile', str(report)]
            if cases:
                pattern = '^995 table (?:' + '|'.join(cases) + ')$'
                cmd += ['--testNamePattern', pattern]
            proc = subprocess.run(cmd, cwd=mobile, env=env, capture_output=True, text=True, timeout=300)
            if not report.exists(): raise RuntimeError('JEST_REPORT_MISSING:' + proc.stderr[-1500:])
            payload = json.loads(report.read_text())
            assertions = [a for suite in payload['testResults'] for a in suite['assertionResults'] if a['status'] != 'pending']
            titles = sorted(a['title'] for a in assertions)
            if titles != sorted(expected) or len(titles) != len(assertions):
                missing = sorted(set(expected) - set(titles)); extra = sorted(set(titles) - set(expected))
                raise RuntimeError(f'ASSERTION_SET_MISMATCH: missing={missing} extra={extra} stderr=' + proc.stderr[-1200:])
            results = []
            for result in assertions:
                rc = int(result['status'] == 'failed')
                results.append(rc)
                messages = '\n'.join(result['failureMessages']).replace(secret, '[REDACTED]')
                failures.append(messages)
                print(f"995 stale-table/{result['title']}: rc={rc}", flush=True)
                if rc: print(messages, file=sys.stderr)
            if proc.returncode != int(any(results)): raise RuntimeError('RC_ASSERTION_MISMATCH')
    finally:
        shutil.rmtree(workspace)
        if not existed: bootstrap.rmdir()
    return int(any(results)), '\n'.join(failures)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--case', action='append', choices=CASES)
    args = parser.parse_args()
    rc, _ = run(args.repo, args.case or None)
    return rc


if __name__ == '__main__':
    try: sys.exit(main())
    except (OSError, RuntimeError, ValueError, KeyError, subprocess.TimeoutExpired) as error:
        print('995 INFRASTRUCTURE:', error, file=sys.stderr); sys.exit(2)
