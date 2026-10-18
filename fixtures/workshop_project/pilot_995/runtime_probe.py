#!/usr/bin/env python3
"""No-port shipped-route probes. Each mode starts a fresh Jest process."""
import argparse
from contextlib import contextmanager
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
CASES = {
    'SHIPPED_INVALID': 'mock', 'SHIPPED_VALID': 'mock', 'DEFAULT_VALID': None,
    'HTTP_UNAVAILABLE': 'http', 'UNKNOWN_MODE': 'banana',
    'RUNTIME_RESPONSES': 'mock',
}
MUTANTS = [
    ('copied-model', 'SHIPPED_INVALID', 'auth-invalid'),
    ('any-code', 'SHIPPED_INVALID', 'auth-invalid'),
    ('env-code', 'SHIPPED_INVALID', 'auth-invalid'),
    ('http-demo', 'HTTP_UNAVAILABLE', 'auth-unavailable'),
    ('ignore-mode', 'UNKNOWN_MODE', 'rejects.toThrow'),
    ('bypass-ports', 'RUNTIME_RESPONSES', 'toHaveBeenCalled'),
    ('wrong-session', 'RUNTIME_RESPONSES', 'principal_ref'),
    ('wrong-disclosure', 'RUNTIME_RESPONSES', 'acknowledged'),
]


@contextmanager
def installed(files):
    """Restore only touched files and directories created by this invocation."""
    before = {p: p.read_bytes() if p.exists() else None for p in files}
    created = set()
    try:
        for path, content in files.items():
            parent = path.parent
            while not parent.exists():
                created.add(parent); parent = parent.parent
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(content)
        yield
    finally:
        for path, content in before.items():
            if content is None: path.unlink(missing_ok=True)
            else: path.write_bytes(content)
        for path in sorted(created, key=lambda p: len(p.parts), reverse=True): path.rmdir()


def run(repo, cases=None, model=None, values=None):
    repo = repo.resolve()
    if not repo.is_relative_to('/tmp/dev-harness-verify'): raise RuntimeError('DISPOSABLE_REQUIRED')
    mobile = repo / 'mobile'
    bootstrap = mobile / 'src/bootstrap'
    subject = bootstrap / 'pilot-app.tsx'
    if model is None and not subject.exists():
        print('995 PILOT_ABSENT'); return 1, 'PILOT_ABSENT'
    # Capture ALL oracle bytes before any code from the subject runs.
    test_bytes = (HERE / 'runtime.test.tsx').read_bytes()
    source = (HERE / 'source.json').read_bytes()
    model_bytes = (HERE / 'model.tsx').read_bytes()
    runtime_bytes = (HERE / 'runtime-model.ts').read_bytes()
    if values is None:
        path = mobile / 'src/mocks/pilot-responses.json'
        if model:
            captured = json.loads(source)
            values = {'getSession': captured['session'], 'getDisclosure': captured['disclosure']}
        elif not path.exists():
            print('995 MOCK_RESPONSES_ABSENT'); return 1, 'MOCK_RESPONSES_ABSENT'
        else: values = json.loads(path.read_bytes())
    frozen_values = json.dumps(values).encode()
    existed = bootstrap.exists()
    bootstrap.mkdir(parents=True, exist_ok=True)
    workspace = Path(tempfile.mkdtemp(prefix='__runtime995_', dir=bootstrap))
    secret = 'synthetic-verification-value'
    files = {workspace / 'runtime.test.tsx': test_bytes, workspace / 'runtime-values.json': frozen_values,
             workspace / 'source.json': source}
    config = None
    if model:
        composed = model_bytes.decode().replace("'./__tests__/source.json'", repr('./' + workspace.name + '/source.json'))
        if model != 'copied-model':
            composed = "import { runtime } from '@pilot/runtime';\n" + composed
            defaults = 'demoAuth, api = demoApi' if model == 'bypass-ports' else 'runtime.auth, api = runtime.api'
            composed = composed.replace('demoAuth, api = demoApi', defaults)
            composed = composed.replace("setChallenge(result.challenge || email); setFrame('code');", "setChallenge(result.challenge || email); setFrame(result.status === 'unavailable' ? 'unavailable' : 'code');")
            composed = composed.replace("{frame === 'first'", "{frame === 'unavailable' && <Text testID=\"auth-unavailable\">Unavailable</Text>}\n    {frame === 'first'")
        files.update({subject: composed.encode(), mobile / 'src/app/index.tsx': b"export { PilotApp as default } from '../bootstrap/pilot-app';\n",
                      workspace / 'runtime-model.ts': runtime_bytes})
        config = json.loads((mobile / 'package.json').read_text()).get('jest', {'preset': 'jest-expo'})
        config = dict(config, rootDir=str(mobile), moduleNameMapper={
            **config.get('moduleNameMapper', {}), '^@pilot/runtime$': str(workspace / 'runtime-model.ts')})
    results = []
    failures = []
    try:
        with installed(files):
            for case in cases or CASES:
                report = workspace / 'report.json'
                report.unlink(missing_ok=True)
                env = dict(os.environ, EXPO_PUBLIC_API_MODE=CASES[case],
                           PILOT_995_MODEL=model or 'actual')
                env.pop('PILOT_DEMO_CODE', None)
                if CASES[case] is None: env.pop('EXPO_PUBLIC_API_MODE', None)
                cmd = ['node', str(mobile / 'node_modules/jest/bin/jest.js'), '--ci', '--runInBand',
                       '--runTestsByPath', str(workspace / 'runtime.test.tsx'), '--testNamePattern', '^995 runtime ' + case + '$',
                       '--json', '--outputFile', str(report)]
                if config: cmd += ['--config', json.dumps(config)]
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
                print(f'995 runtime/{model or "actual"}/{case}: rc={rc}', flush=True)
                if rc and model is None: print(messages, file=sys.stderr)
    finally:
        shutil.rmtree(workspace)
        if not existed: bootstrap.rmdir()
    return int(any(results)), '\n'.join(failures)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--matrix', action='store_true')
    parser.add_argument('--model', choices=['honest'] + sorted({m for m, _, _ in MUTANTS}))
    parser.add_argument('--case', choices=CASES)
    args = parser.parse_args()
    if not args.matrix: return run(args.repo, [args.case] if args.case else None, args.model)[0]
    rows = [('honest', None, 0, '')] + [(m, [c], 1, reason) for m, c, reason in MUTANTS]
    mismatches = 0
    for model, cases, expected, reason in rows:
        rc, failure = run(args.repo, cases, model)
        if rc != expected or reason not in failure:
            mismatches += 1
            print('995 runtime WRONG_RESULT:' + failure, file=sys.stderr)
    print(f'995 runtime runs={len(rows)} mismatches={mismatches}')
    return int(bool(mismatches))


if __name__ == '__main__':
    try: sys.exit(main())
    except (OSError, RuntimeError, ValueError, KeyError, subprocess.TimeoutExpired) as error:
        print('995 INFRASTRUCTURE:', error, file=sys.stderr); sys.exit(2)
