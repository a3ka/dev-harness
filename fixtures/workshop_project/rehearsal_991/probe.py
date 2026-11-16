#!/usr/bin/env python3
"""Run the real Jest seam in a disposable Complior clone, never in main.

v3 additionally judges the Maestro version gate at the CI seam: every
workflow must EXECUTE the gate through its real one-line npm-run ci-lane
call (163 frozen form) in a chain replay with a fake maestro, not merely
mention the gate name; the executed chain must fail on a wrong version
by name, and the gate file itself must accept the right one. Bindings of
countermodels to observable inputs belong here, not in contract prose.
"""
import argparse
import json
import os
from pathlib import Path
import re
import shlex
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
# The lane route is the exact one-line workflow command of 163, executed
# verbatim without a shell; flag words after the lane name are allowed,
# any other run body is not a chain candidate and leaves the lane unrun.
LANE_NAME = re.compile(r'ci:[a-z][a-z0-9-]*')
CHAIN_TIMEOUT = 120


def lane_route(run_text):
    """Parse a workflow run body into the frozen 163 one-line lane call.

    Returns the verbatim argv (npm run ci:<lane> [flag words]) or None.
    argv is executed without a shell, so no run text is ever interpreted;
    anything that does not start with `npm run ci:<lane>` is not a chain
    candidate. npm and the real runner resolve the chain — the probe
    keeps no hand-written table of lanes.
    """
    if not isinstance(run_text, str):
        return None
    try:
        parts = shlex.split(run_text)
    except ValueError:
        return None
    if len(parts) < 3 or parts[0:2] != ['npm', 'run']:
        return None
    if LANE_NAME.fullmatch(parts[2]) is None:
        return None
    return parts


def instrument_gate(gate_bytes):
    """Insert a marker line so chain replay can prove the gate RAN."""
    text = gate_bytes.decode('utf-8')
    probe_line = 'printf x > "${REHEARSAL_991_GATE_MARKER:?}"\n'
    lines = text.splitlines(keepends=True)
    if lines and lines[0].startswith('#!'):
        lines.insert(1, probe_line)
    else:
        lines.insert(0, probe_line)
    return ''.join(lines).encode('utf-8')


def lane_steps(workflow):
    """Yield (job_id, job, step) for every step of every job."""
    jobs = workflow.get('jobs') if isinstance(workflow, dict) else None
    if not isinstance(jobs, dict):
        return
    for job_id, job in jobs.items():
        if not isinstance(job, dict) or not isinstance(job.get('steps'), list):
            continue
        for step in job['steps']:
            if isinstance(step, dict):
                yield job_id, job, step


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


class ChainReplay:
    """Run workflow lane one-liners for real in a disposable copy.

    npm and the product's own runner resolve the chain — the probe keeps
    no hand-written lane table. The gate inside the copy is instrumented
    to drop a marker file when it runs, and a fake maestro first on PATH
    serves the wrong version. The right version is judged by replay_gate
    on the untouched gate bytes: with 2.11.0 the real lane would launch
    its full e2e battery, which a probe must not start.
    """

    def __init__(self, root, gate_bytes):
        self._scratch = tempfile.TemporaryDirectory(prefix='991-chain-')
        base = Path(self._scratch.name)
        self.tree = base / 'tree'
        shutil.copytree(root, self.tree,
                        ignore=shutil.ignore_patterns('.git', 'node_modules'))
        (self.tree / GATE).write_bytes(instrument_gate(gate_bytes))
        self.bindir = base / 'bin'
        self.bindir.mkdir()
        maestro = self.bindir / 'maestro'
        maestro.write_text('#!/bin/sh\nprintf \'%s\\n\' "$MAESTRO_FAKE_VERSION"\n')
        maestro.chmod(0o755)
        self.counter = 0

    def close(self):
        self._scratch.cleanup()

    def run(self, argv):
        """Return (rc, output, gate_executed) for one lane chain."""
        self.counter += 1
        marker = self.bindir.parent / f'gate-marker-{self.counter}'
        marker.unlink(missing_ok=True)
        env = dict(os.environ,
                   PATH=str(self.bindir) + os.pathsep + os.environ.get('PATH', ''),
                   MAESTRO_FAKE_VERSION=WRONG_VERSION,
                   REHEARSAL_991_GATE_MARKER=str(marker))
        try:
            proc = subprocess.run(argv, cwd=self.tree, env=env, text=True,
                                  capture_output=True, timeout=CHAIN_TIMEOUT)
            rc, output = proc.returncode, proc.stdout + proc.stderr
        except subprocess.TimeoutExpired as expired:
            rc = None
            parts = []
            for chunk in (expired.stdout, expired.stderr):
                if isinstance(chunk, bytes):
                    chunk = chunk.decode('utf-8', 'replace')
                parts.append(chunk or '')
            output = ''.join(parts)
        return rc, output, marker.exists()


def version_failures(root):
    """Named refusals of the version-gate seam; an honest tree yields []."""
    failures = []
    gate = root / GATE
    gate_bytes = gate.read_bytes() if gate.is_file() else None
    if gate_bytes is None:
        failures.append(f'VERSION_GATE_NOT_SCRIPT: {GATE}')
    chain = None

    def replay(argv):
        nonlocal chain
        if gate_bytes is None:
            return None, '', False
        if chain is None:
            chain = ChainReplay(root, gate_bytes)
        return chain.run(argv)

    for name in WORKFLOWS:
        path = root / '.github/workflows' / name
        try:
            workflow = yaml.load(path.read_text(), Loader=yaml.BaseLoader)
            steps = list(lane_steps(workflow))
        except (OSError, AttributeError, yaml.YAMLError):
            failures.append(f'VERSION_GATE_DROPPED: {name}: workflow unreadable')
            continue
        honest = 0
        for job_id, job, step in steps:
            argv = lane_route(step.get('run'))
            if argv is None:
                continue
            lane = argv[2]
            rc, output, executed = replay(argv)
            reason = GATE_REASON if GATE_REASON in output else 'NONE'
            print(f'991 version/chain: workflow={name} lane={lane} '
                  f'maestro={WRONG_VERSION} '
                  f'rc={rc if rc is not None else "timeout"} '
                  f'gate={"yes" if executed else "no"} reason={reason}', flush=True)
            if executed and rc is not None and rc != 0 and reason != 'NONE':
                honest += 1
            elif executed and rc == 0:
                failures.append(f'VERSION_GATE_SWALLOWED: {name}: {lane}')
            elif executed:
                failures.append(f'VERSION_GATE_SILENT: {name}: {lane}')
            if not executed:
                continue
            if str(step.get('continue-on-error', 'false')).lower() == 'true':
                failures.append(f'VERSION_GATE_SOFT: {name}: {lane}')
            if str(job.get('continue-on-error', 'false')).lower() == 'true':
                failures.append(f'VERSION_GATE_SOFT: {name}: job={job_id}')
        if honest == 0:
            failures.append(f'VERSION_GATE_DROPPED: {name}')
    if chain is not None:
        chain.close()
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


CALL_LINE = f'bash mobile/scripts/{GATE_NAME}\n'


def _edit(tree, relative, old, new):
    path = tree / relative
    path.write_text(path.read_text().replace(old, new))


# Each stub is bound to the observable input where its defect shows up:
# the same version_failures() that judges a real --repo tree judges every
# disposable mutated copy, so a caught stab proves the catcher, not itself.
STUBS = (
    ('station-gate-dropped',
     lambda tree: _edit(tree, 'mobile/scripts/ci-e2e-native.sh',
                        CALL_LINE, ''),
     'VERSION_GATE_DROPPED: mobile.yml'),
    ('cloud-gate-dropped',
     lambda tree: _edit(tree, 'mobile/scripts/ci-e2e-cloud.sh',
                        CALL_LINE, ''),
     'VERSION_GATE_DROPPED: mobile-cloud-e2e.yml'),
    # M1: gate name echoed in the lane script instead of executed.
    ('station-echo-name',
     lambda tree: _edit(tree, 'mobile/scripts/ci-e2e-native.sh', CALL_LINE,
                        'echo "ci-maestro-version.sh: pinned in battery"\n'),
     'VERSION_GATE_DROPPED: mobile.yml'),
    # M2: gate refusal swallowed inside the lane script.
    ('cloud-swallow',
     lambda tree: _edit(tree, 'mobile/scripts/ci-e2e-cloud.sh', CALL_LINE,
                        f'bash mobile/scripts/{GATE_NAME} || true\n'),
     'VERSION_GATE_SWALLOWED: mobile-cloud-e2e.yml: ci:e2e-cloud'),
    # M6: same-name .shx placebo called while the honest gate sits idle.
    ('station-shx-placebo',
     lambda tree: (
         (tree / f'mobile/scripts/{GATE_NAME}x').write_text(
             '#!/bin/sh\nmaestro --version || true\n'),
         _edit(tree, 'mobile/scripts/ci-e2e-native.sh', CALL_LINE,
               f'bash mobile/scripts/{GATE_NAME}x\n')),
     'VERSION_GATE_DROPPED: mobile.yml'),
    ('gate-placebo',
     lambda tree: (tree / f'mobile/scripts/{GATE_NAME}').write_text(
         '#!/bin/sh\nmaestro --version || true\n'),
     'VERSION_GATE_PLACEBO'),
    ('gate-rejects-correct',
     lambda tree: (tree / f'mobile/scripts/{GATE_NAME}').write_text(
         '#!/bin/sh\n'
         'echo "MAESTRO_VERSION_MISMATCH: expected=2.11.0 actual=stub" >&2\n'
         'exit 1\n'),
     'VERSION_GATE_REJECTS_CORRECT'),
    ('gate-silent',
     lambda tree: (tree / f'mobile/scripts/{GATE_NAME}').write_text(
         '#!/bin/sh\n'
         'v="$(maestro --version 2>/dev/null || true)"\n'
         '[ "$v" = "2.11.0" ] || exit 1\n'),
     'VERSION_GATE_SILENT'),
    ('station-gate-soft',
     lambda tree: _edit(tree, '.github/workflows/mobile.yml',
                        '- run: npm run ci:e2e-native',
                        '- run: npm run ci:e2e-native\n'
                        '        continue-on-error: true'),
     'VERSION_GATE_SOFT: mobile.yml: ci:e2e-native'),
    # M4: continue-on-error on the JOB that carries the gate lane.
    ('job-gate-soft',
     lambda tree: _edit(tree, '.github/workflows/mobile.yml',
                        '  e2e-native:\n',
                        '  e2e-native:\n    continue-on-error: true\n'),
     'VERSION_GATE_SOFT: mobile.yml: job=e2e-native'),
    ('station-direct-call',
     lambda tree: _edit(tree, '.github/workflows/mobile.yml',
                        'npm run ci:e2e-native',
                        'node mobile/scripts/run-mobile-ci.cjs --lane e2e-native'),
     'VERSION_GATE_DROPPED: mobile.yml'),
)


def run_stabs():
    control = version_failures(VERSION_MODEL)
    print(f'991 version/control: failures={len(control)}', flush=True)
    for failure in control:
        print(f'991 version: {failure}', flush=True)
    caught = 0
    for name, mutate, expected in STUBS:
        with tempfile.TemporaryDirectory(prefix='991-stab-') as scratch:
            tree = Path(scratch) / 'tree'
            shutil.copytree(VERSION_MODEL, tree)
            mutate(tree)
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
