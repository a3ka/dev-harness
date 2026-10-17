#!/usr/bin/env python3
"""Run the real Jest seam in a disposable Complior clone, never in main.

Countermodel-to-observable-input bindings belong here, not in contract prose.
"""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
CASES = {
    'R1': 'R1 starts incomplete and completes only after a press',
    'R2': 'R2 resets when a new screen session starts',
}
# Each mutant is judged only on an input that exposes its defect.
MATRIX = [('honest', 'R1', 0), ('honest', 'R2', 0),
          ('noop', 'R1', 1), ('premature', 'R1', 1),
          ('sticky', 'R2', 1), ('sticky', 'R1', 0)]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', required=True, type=Path)
    parser.add_argument('--matrix', action='store_true')
    args = parser.parse_args()
    repo = args.repo.resolve()
    if not repo.is_relative_to('/tmp/dev-harness-verify'):
        raise RuntimeError('991: disposable clone must be under /tmp/dev-harness-verify')
    mobile = repo / 'mobile'
    subject = mobile / 'src/features/start/start-screen.tsx'
    test = subject.parent / '__tests__/rehearsal-991.test.tsx'
    if test.exists():
        raise RuntimeError(f'991: occupied test path: {test}')
    original = subject.read_bytes()
    test_bytes = (HERE / 'rehearsal.test.tsx').read_bytes()
    model_bytes = (HERE / 'model.tsx').read_bytes()
    rows = MATRIX if args.matrix else [('actual', key, None) for key in CASES]
    results = []
    try:
        test.write_bytes(test_bytes)
        with tempfile.TemporaryDirectory(prefix='991-jest-', dir=repo.parent) as temp:
            for mode, case, expected in rows:
                subject.write_bytes(original if mode == 'actual' else model_bytes)
                output = Path(temp) / f'{mode}-{case}.json'
                env = dict(os.environ, REHEARSAL_991_MODEL=mode)
                proc = subprocess.run(
                    ['node', str(mobile / 'node_modules/jest/bin/jest.js'),
                     '--ci', '--runInBand', '--runTestsByPath', str(test),
                     '--testNamePattern', '^991 rehearsal ' + CASES[case] + '$',
                     '--json', '--outputFile', str(output)],
                    cwd=mobile, env=env, capture_output=True, text=True,
                )
                print(proc.stdout, end='')
                print(proc.stderr, end='', file=sys.stderr)
                report = json.loads(output.read_text())
                assertions = [a for suite in report['testResults']
                              for a in suite['assertionResults']
                              if a['status'] != 'pending']
                if len(assertions) != 1 or assertions[0]['title'] != CASES[case]:
                    raise RuntimeError(f'991: no unique executed assertion: {mode}/{case}')
                status = assertions[0]['status']
                if proc.returncode not in (0, 1) or status not in ('passed', 'failed'):
                    raise RuntimeError(f'991: infrastructure failure: {mode}/{case}')
                if (proc.returncode == 0) != (status == 'passed'):
                    raise RuntimeError(f'991: rc/assertion mismatch: {mode}/{case}')
                results.append((mode, case, proc.returncode, expected))
                print(f'991 {mode}/{case}: rc={proc.returncode} assertion={status}', flush=True)
    finally:
        subject.write_bytes(original)
        test.unlink(missing_ok=True)
    print(f'991 executed={len(results)} mode={"matrix" if args.matrix else "actual"}')
    if args.matrix:
        return int(any(rc != expected for _, _, rc, expected in results))
    return int(any(rc != 0 for _, _, rc, _ in results))


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, KeyError) as error:
        print(f'991 INFRASTRUCTURE: {error}', file=sys.stderr)
        sys.exit(2)
