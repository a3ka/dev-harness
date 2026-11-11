#!/usr/bin/env python3
"""Run the real Jest seam in a disposable Complior clone, never in main.

v3 additionally judges the Maestro version gate at the CI seam: both
workflows must reach the gate script through one-line npm-run ci-lane
calls (163 frozen form), and the executed gate must refuse a wrong
version by name. Countermodel-to-observable-input bindings belong here,
not in contract prose.
"""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

import yaml

HERE = Path(__file__).resolve().parent
CASES = {
    'R1': 'R1 starts incomplete and completes only after a press',
    'R2': 'R2 resets when a new screen session starts',
}
# Each mutant is judged only on an input that exposes its defect.
MATRIX = [('honest', 'R1', 0), ('honest', 'R2', 0),
          ('noop', 'R1', 1), ('premature', 'R1', 1),
          ('sticky', 'R2', 1), ('sticky', 'R1', 0)]

# v3: the Maestro version-gate seam (window of contract 163).
VERSION_MODEL = HERE / 'version_model'
WORKFLOWS = ('mobile.yml', 'mobile-cloud-e2e.yml')
GATE = Path('mobile/scripts/ci-maestro-version.sh')
GATE_NAME = 'ci-maestro-version.sh'
GATE_REASON = 'MAESTRO_VERSION_MISMATCH'
WRONG_VERSION, RIGHT_VERSION = '2.10.0', '2.11.0'
# The lane route is the exact one-line workflow command of 163; a longer
# run body is not a chain candidate and leaves the workflow unreached.
LANE_ROUTE = re.compile(r'npm run (ci:[a-z][a-z0-9-]*)')
LANE_FLAG = re.compile(r'--lane\s+([A-Za-z0-9_-]+)')
SCRIPT_PATH = re.compile(r'mobile/scripts/\S+\.(?:sh|cjs)$')


def lane_script(root, npm_name):
    """Resolve ci:<X> workflow call to its lane script via the runner table."""
    try:
        scripts = json.loads((root / 'package.json').read_text())['scripts']
    except (OSError, ValueError, KeyError, TypeError):
        return None
    value = scripts.get(npm_name)
    if not isinstance(value, str) or 'run-mobile-ci.cjs' not in value:
        return None
    match = LANE_FLAG.search(value)
    if match is None:
        return None
    try:
        table = (root / 'mobile/scripts/run-mobile-ci.cjs').read_text()
    except OSError:
        return None
    lane = re.escape(match.group(1))
    key = "['\"]?"
    entry = re.search(key + lane + key + r"\s*:\s*\[", table)
    if entry is None:
        return None
    window = table[entry.start():entry.start() + 400]
    strings = "['\"]([^'\"]+)['\"]"
    for quoted in re.findall(strings, window):
        if SCRIPT_PATH.fullmatch(quoted):
            return root / quoted
    return None


def steps_of(workflow):
    jobs = workflow.get('jobs') if isinstance(workflow, dict) else None
    if not isinstance(jobs, dict):
        return
    for job in jobs.values():
        if not isinstance(job, dict) or not isinstance(job.get('steps'), list):
            continue
        for step in job['steps']:
            if isinstance(step, dict):
                yield step


def replay_gate(gate_bytes, version):
    """Execute the captured gate bytes against a fake maestro CLI on PATH."""
    with tempfile.TemporaryDirectory(prefix='991-version-') as scratch:
        root = Path(scratch)
        bindir = root / 'bin'
        bindir.mkdir()
        maestro = bindir / 'maestro'
        maestro.write_text('#!/bin/sh\nprintf \'%s\\n\' "$MAESTRO_FAKE_VERSION"\n')
        maestro.chmod(0o755)
        gate = root / 'gate.sh'
        gate.write_bytes(gate_bytes)
        gate.chmod(0o755)
        env = dict(os.environ,
                   PATH=str(bindir) + os.pathsep + os.environ.get('PATH', ''),
                   MAESTRO_FAKE_VERSION=version)
        proc = subprocess.run(['bash', str(gate)], cwd=root, env=env,
                              text=True, capture_output=True)
        return proc.returncode, proc.stdout + proc.stderr


def version_failures(root):
    """Named refusals of the version-gate seam; an honest tree yields []."""
    failures = []
    gate = root / GATE
    gate_bytes = gate.read_bytes() if gate.is_file() else None
    if gate_bytes is None:
        failures.append(f'VERSION_GATE_NOT_SCRIPT: {GATE}')
    for name in WORKFLOWS:
        path = root / '.github/workflows' / name
        try:
            workflow = yaml.load(path.read_text(), Loader=yaml.BaseLoader)
            steps = list(steps_of(workflow))
        except (OSError, AttributeError, yaml.YAMLError):
            failures.append(f'VERSION_GATE_DROPPED: {name}: workflow unreadable')
            continue
        reached = []
        for step in steps:
            run = step.get('run')
            if not isinstance(run, str):
                continue
            route = LANE_ROUTE.fullmatch(run.strip())
            if route is None:
                continue
            script = lane_script(root, route.group(1))
            if script is None:
                continue
            try:
                text = script.read_text()
            except (OSError, UnicodeDecodeError):
                continue
            invoked = any(GATE_NAME in line for line in text.splitlines()
                          if not line.lstrip().startswith('#'))
            if invoked:
                reached.append((route.group(1), step))
        if not reached:
            failures.append(f'VERSION_GATE_DROPPED: {name}')
        for lane, step in reached:
            if str(step.get('continue-on-error', 'false')).lower() == 'true':
                failures.append(f'VERSION_GATE_SOFT: {name}: {lane}')
    if gate_bytes is not None:
        wrong_rc, wrong_out = replay_gate(gate_bytes, WRONG_VERSION)
        print(f'991 version/replay: maestro={WRONG_VERSION} rc={wrong_rc} '
              f'reason={GATE_REASON if GATE_REASON in wrong_out else "NONE"}', flush=True)
        if wrong_rc == 0:
            failures.append('VERSION_GATE_PLACEBO')
        elif GATE_REASON not in wrong_out:
            failures.append('VERSION_GATE_SILENT')
        right_rc, _ = replay_gate(gate_bytes, RIGHT_VERSION)
        print(f'991 version/replay: maestro={RIGHT_VERSION} rc={right_rc} '
              f'reason=NONE', flush=True)
        if right_rc != 0:
            failures.append('VERSION_GATE_REJECTS_CORRECT')
    return failures


def drop_gate(text):
    return text.replace(f'bash mobile/scripts/{GATE_NAME}\n', '')


# Each stub is bound to the observable input where its defect shows up.
STUBS = (
    ('station-gate-dropped', 'mobile/scripts/ci-e2e-native.sh', drop_gate,
     'VERSION_GATE_DROPPED: mobile.yml'),
    ('cloud-gate-dropped', 'mobile/scripts/ci-e2e-cloud.sh', drop_gate,
     'VERSION_GATE_DROPPED: mobile-cloud-e2e.yml'),
    ('gate-placebo', f'mobile/scripts/{GATE_NAME}',
     lambda text: '#!/bin/sh\nmaestro --version || true\n',
     'VERSION_GATE_PLACEBO'),
    ('gate-rejects-correct', f'mobile/scripts/{GATE_NAME}',
     lambda text: '#!/bin/sh\n'
                  'echo "MAESTRO_VERSION_MISMATCH: expected=2.11.0 actual=stub" >&2\n'
                  'exit 1\n',
     'VERSION_GATE_REJECTS_CORRECT'),
    ('gate-silent', f'mobile/scripts/{GATE_NAME}',
     lambda text: '#!/bin/sh\n'
                  'v="$(maestro --version 2>/dev/null || true)"\n'
                  '[ "$v" = "2.11.0" ] || exit 1\n',
     'VERSION_GATE_SILENT'),
    ('station-gate-soft', '.github/workflows/mobile.yml',
     lambda text: text.replace('- run: npm run ci:e2e-native',
                               '- run: npm run ci:e2e-native\n'
                               '        continue-on-error: true'),
     'VERSION_GATE_SOFT: mobile.yml: ci:e2e-native'),
    ('station-direct-call', '.github/workflows/mobile.yml',
     lambda text: text.replace('npm run ci:e2e-native',
                               'node mobile/scripts/run-mobile-ci.cjs --lane e2e-native'),
     'VERSION_GATE_DROPPED: mobile.yml'),
)


def run_stabs():
    control = version_failures(VERSION_MODEL)
    print(f'991 version/control: failures={len(control)}', flush=True)
    for failure in control:
        print(f'991 version: {failure}', flush=True)
    caught = 0
    for name, relative, mutate, expected in STUBS:
        with tempfile.TemporaryDirectory(prefix='991-stab-') as scratch:
            tree = Path(scratch) / 'tree'
            shutil.copytree(VERSION_MODEL, tree)
            target = tree / relative
            target.write_text(mutate(target.read_text()))
            failures = version_failures(tree)
        hit = expected in failures
        caught += hit
        print(f'991 version/stab-{name}: caught={hit} expected={expected}', flush=True)
    print(f'991 version stabs: total={len(STUBS)} caught={caught}')
    return int(bool(control) or caught != len(STUBS))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path)
    parser.add_argument('--matrix', action='store_true')
    parser.add_argument('--model', action='store_true')
    parser.add_argument('--stabs', action='store_true')
    args = parser.parse_args()
    if sum((args.matrix, args.model, args.stabs)) > 1:
        parser.error('--matrix/--model/--stabs are mutually exclusive')
    if args.model:
        failures = version_failures(VERSION_MODEL)
        for failure in failures:
            print(f'991 version: {failure}', flush=True)
        print(f'991 version seam: failures={len(failures)}')
        return int(bool(failures))
    if args.stabs:
        return run_stabs()
    repo = args.repo.resolve()
    if not repo.is_relative_to('/tmp/dev-harness-verify'):
        raise RuntimeError('991: disposable clone must be under /tmp/dev-harness-verify')
    if not args.matrix:
        # v3: the product replaced the temporary rehearsal screen with its
        # real route (v2 clause), so --repo judges only the version seam.
        failures = version_failures(repo)
        for failure in failures:
            print(f'991 version: {failure}', flush=True)
        print(f'991 version seam: failures={len(failures)}')
        return int(bool(failures))
    mobile = repo / 'mobile'
    subject = mobile / 'src/features/start/start-screen.tsx'
    test = subject.parent / '__tests__/rehearsal-991.test.tsx'
    if test.exists():
        raise RuntimeError(f'991: occupied test path: {test}')
    original = subject.read_bytes()
    test_bytes = (HERE / 'rehearsal.test.tsx').read_bytes()
    model_bytes = (HERE / 'model.tsx').read_bytes()
    rows = MATRIX
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
    print(f'991 executed={len(results)} mode=matrix')
    return int(any(rc != expected for _, _, rc, expected in results))


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, KeyError) as error:
        print(f'991 INFRASTRUCTURE: {error}', file=sys.stderr)
        sys.exit(2)
