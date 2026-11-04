#!/usr/bin/env python3
"""Acceptance at the CI seam; each mutant is checked at its observable input."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import re

import yaml

HERE = Path(__file__).resolve().parent
MODEL = HERE / 'model'
PARITY = HERE.parents[2] / 'scripts' / 'verify_ci_parity.sh'
DEBT = '.harness/registry/ci_parity_debt.txt'


def command(args, root, **kwargs):
    return subprocess.run(args, cwd=root, capture_output=True, text=True, **kwargs)


def commands_in_workflow(root):
    paths = [root / '.github/workflows/mobile.yml', root / '.github/workflows/mobile-cloud-e2e.yml']
    workflows = []
    for path in paths:
        if path.exists():
            workflows.append(yaml.load(path.read_text(), Loader=yaml.BaseLoader))
    return workflows


def steps_in(workflow):
    for job in workflow.get('jobs', {}).values():
        for step in job.get('steps', []):
            yield step


def exception_keys(text):
    return {line.split(' = ', 1)[0] for line in text.splitlines()
            if line.strip() and not line.lstrip().startswith('#')}

def digest(key):
    return hashlib.sha256(key.encode()).hexdigest()


def lane_routes(root, scripts):
    failures = []
    for name in ('mobile.yml', 'mobile-cloud-e2e.yml'):
        path = root / '.github/workflows' / name
        if not path.is_file():
            failures.append(f'NET_WORKFLOW_{name}')
            continue
        try:
            workflow = yaml.load(path.read_text(), Loader=yaml.BaseLoader)
            steps = list(steps_in(workflow))
        except (OSError, TypeError, ValueError, yaml.YAMLError):
            failures.append(f'NECHITAEMYJ_WORKFLOW_{name}')
            continue
        found = False
        for step in steps:
            run = step.get('run', '')
            if not isinstance(run, str):
                continue
            # The route is an exact, one-line workflow command, not parity's
            # equivalence between an npm script's value and a direct invocation.
            if not (re.search(r'\bnpm\s+(?:run|run-script)\s+ci:[a-z][a-z0-9-]*', run) or
                    'run-mobile-ci.cjs' in run or
                    run in (value for key, value in scripts.items() if key.startswith('ci:'))):
                continue
            found = True
            match = re.fullmatch(r'npm run (ci:[a-z][a-z0-9-]*)', run)
            if match is None or match.group(1) not in scripts:
                failures.append(f'NPM_MARSHRUT_{name}: {run!r}')
        if not found:
            failures.append(f'NET_LANE_V_WORKFLOW_{name}')
    return failures


def acceptance(root, baseline, golden, allowed):
    failures = []
    if (root / DEBT).exists():
        failures.append('DOLG_NE_SNJAT')
    pkg = root / 'package.json'
    try:
        scripts = json.loads(pkg.read_text())['scripts']
    except (OSError, KeyError, ValueError):
        scripts = {}
        failures.append('NET_PRIEMKI')
    if not any(k.startswith('ci:') and 'run-mobile-ci.cjs --lane ' in v for k, v in scripts.items()):
        failures.append('LANE_NE_PODKLIUCHEN')
    runner = root / 'mobile/scripts/run-mobile-ci.cjs'
    if not runner.is_file():
        failures.append('NET_RANNERA')
    else:
        result = command(['node', str(runner), '--list'], root)
        if result.returncode or not result.stdout.strip():
            failures.append('LANE_LIST_NE_RABOTAET')
    try:
        workflow = commands_in_workflow(root)[0]
        matching = [s.get('run', '').strip() for s in steps_in(workflow)
                    if s.get('name') == '123 сверка кадров с макетом (scripts/sverka_maketa.py)']
        if matching != [golden]:
            failures.append('SVERKA_123_IZMENENA')
    except (OSError, ValueError, IndexError, TypeError):
        failures.append('SVERKA_123_OTSUTSTVUET')
    exceptions = root / ('config/ci_parity_exceptions.txt' if baseline == MODEL else '.harness/registry/ci_parity_exceptions.txt')
    try:
        candidate = exception_keys(exceptions.read_text())
        # The allowed set is snapshotted by the caller before reading the subject.
        novel = sorted(k for k in candidate if digest(k) not in allowed)
        if novel:
            failures.append('NOVOE_ISKLIUCHENIE: ' + ', '.join(novel))
    except OSError:
        failures.append('NET_ISKLIUCHENIJ')
    result = command(['bash', str(PARITY), str(root)], root)
    failures.extend(lane_routes(root, scripts))
    if result.returncode:
        failures.append(f'PARITET_RC_{result.returncode}: ' + (result.stderr.strip().splitlines()[-1] if result.stderr.strip() else 'без вывода'))
    return failures


def run_model(root, golden, model_allowed):
    failures = acceptance(root, MODEL, golden, model_allowed)
    if failures:
        return failures
    with tempfile.TemporaryDirectory(prefix='ci163-maestro-') as tools:
        maestro = Path(tools) / 'maestro'
        maestro.write_text('#!/bin/sh\nprintf "%s\\n" "${CI163_MAESTRO_VERSION:-2.11.0}"\n')
        maestro.chmod(0o755)
        env = {**os.environ, 'PATH': tools + os.pathsep + os.environ['PATH']}
        for lane, expected in [('quality', '143'), ('e2e-splash', '117'),
                               ('e2e-cloud', '991')]:
            with tempfile.TemporaryDirectory(prefix='ci163-marker-') as marker_dir:
                marker = Path(marker_dir) / 'visited'
                result = command(['npm', 'run', f'ci:{lane}'], root,
                                 env={**env, 'CI163_MARKER': str(marker)})
                observed = marker.read_text().splitlines() if marker.exists() else []
                if result.returncode or observed != [expected]:
                    failures.append(f'BATAREJA_NE_VYZVANA_{lane}: rc={result.returncode} marker={observed}')
        for lane in ('e2e-splash', 'e2e-cloud'):
            with tempfile.TemporaryDirectory(prefix='ci163-marker-') as marker_dir:
                marker = Path(marker_dir) / 'visited'
                result = command(['npm', 'run', f'ci:{lane}'], root,
                                 env={**env, 'CI163_MARKER': str(marker),
                                      'CI163_MAESTRO_VERSION': '2.10.0'})
                if (result.returncode == 0 or marker.exists() or
                        "MAESTRO_VERSION_MISMATCH: expected=2.11.0 actual='2.10.0'" not in result.stderr):
                    failures.append(f'MAESTRO_VERSION_GATE_PROPUShCHEN_{lane}')
    return failures


def mutant(root, kind):
    workflow = root / '.github/workflows/mobile.yml'
    if kind == 'empty-lane':
        (root / 'mobile/scripts/ci-quality.sh').write_text('#!/usr/bin/env bash\nexit 0\n')
    elif kind == 'battery-omitted':
        (root / 'mobile/scripts/ci-e2e-splash.sh').write_text('#!/usr/bin/env bash\nexit 0\n')
    elif kind == 'deleted-debt-only':
        workflow.write_text(workflow.read_text().replace('run: npm run ci:quality', 'run: echo "$(date)"'))
    elif kind == 'new-exception':
        with (root / 'config/ci_parity_exceptions.txt').open('a') as out:
            out.write('команда: echo ci = подготовка нового обходного шага вместо переноса содержимого в скрипт\n')
        workflow.write_text(workflow.read_text().replace('run: npm run ci:quality', 'run: echo ci'))
    elif kind == 'direct-mobile':
        workflow.write_text(workflow.read_text().replace(
            'run: npm run ci:e2e-splash',
            'run: node mobile/scripts/run-mobile-ci.cjs --lane e2e-splash'))
    elif kind == 'direct-cloud':
        cloud = root / '.github/workflows/mobile-cloud-e2e.yml'
        cloud.write_text(cloud.read_text().replace(
            'run: npm run ci:e2e-cloud',
            'run: node mobile/scripts/run-mobile-ci.cjs --lane e2e-cloud'))
    elif kind in ('no-version-mobile', 'no-version-cloud'):
        lane = 'e2e-splash' if kind == 'no-version-mobile' else 'e2e-cloud'
        path = root / f'mobile/scripts/ci-{lane}.sh'
        path.write_text(path.read_text().replace(
            'bash mobile/scripts/ci-maestro-version.sh\n', ''))
    elif kind == 'rewritten-123':
        workflow.write_text(workflow.read_text().replace('set -o pipefail', 'set +o pipefail'))


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    modes.add_argument('--repo', type=Path)
    args = parser.parse_args()
    # Expectations are detached before the candidate or any mutant is examined.
    golden = (HERE / 'sverka-123-run.txt').read_text().strip()
    model_allowed = {digest(k) for k in exception_keys((MODEL / 'config/ci_parity_exceptions.txt').read_text())}
    repo_allowed = {line for line in (HERE / 'baseline-exception-keys.sha256').read_text().splitlines()
                    if line and not line.startswith('#')}
    if args.repo:
        root = args.repo.resolve()
        if not root.is_dir():
            print('NOT_IMPLEMENTED: NET_REPO', file=sys.stderr)
            return 2
        failures = acceptance(root, root, golden, repo_allowed)
        for reason in failures:
            print(reason)
        return 2 if any(x.startswith('NOT_IMPLEMENTED') for x in failures) else int(bool(failures))
    if args.model:
        failures = run_model(MODEL, golden, model_allowed)
        for reason in failures:
            print(reason)
        return int(bool(failures))
    control = run_model(MODEL, golden, model_allowed)
    if control:
        print('NOT_IMPLEMENTED: MODEL_RED ' + '; '.join(control))
        return 2
    # A CI checkout need not contain the historical commit or even .git.
    with tempfile.TemporaryDirectory(prefix='ci163-shallow-') as temporary:
        target = Path(temporary) / 'model'
        shutil.copytree(MODEL, target)
        registry = target / '.harness/registry'
        registry.mkdir(parents=True)
        shutil.copyfile(target / 'config/ci_parity_exceptions.txt',
                        registry / 'ci_parity_exceptions.txt')
        shallow_failures = acceptance(target, target, golden, repo_allowed)
        if shallow_failures:
            print('SHALLOW_KONTROL_RED: ' + '; '.join(shallow_failures))
            return 1
    expected = {'empty-lane': 'BATAREJA_NE_VYZVANA_quality',
                'battery-omitted': 'BATAREJA_NE_VYZVANA_e2e-splash',
                'deleted-debt-only': 'PARITET_RC_1',
                'new-exception': 'NOVOE_ISKLIUCHENIE',
                'rewritten-123': 'SVERKA_123_IZMENENA',
                'direct-mobile': 'NPM_MARSHRUT_mobile.yml',
                'direct-cloud': 'NPM_MARSHRUT_mobile-cloud-e2e.yml',
                'no-version-mobile': 'MAESTRO_VERSION_GATE_PROPUShCHEN_e2e-splash',
                'no-version-cloud': 'MAESTRO_VERSION_GATE_PROPUShCHEN_e2e-cloud'}
    for name, reason in expected.items():
        with tempfile.TemporaryDirectory(prefix='ci163-stab-') as temporary:
            target = Path(temporary) / 'model'
            shutil.copytree(MODEL, target)
            mutant(target, name)
            failures = run_model(target, golden, model_allowed)
            if not any(item.startswith(reason) for item in failures):
                print(f'STAB_ZHIV {name}: wanted={reason} observed={failures}')
                return 1
            print(f'{name}: {reason}')
    print(f'контроль зелёный; стабов {len(expected)}, непойманных 0')
    return 0


if __name__ == '__main__':
    sys.exit(main())
