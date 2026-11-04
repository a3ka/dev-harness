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
    if result.returncode:
        failures.append(f'PARITET_RC_{result.returncode}: ' + (result.stderr.strip().splitlines()[-1] if result.stderr.strip() else 'без вывода'))
    return failures


def run_model(root, golden, model_allowed):
    failures = acceptance(root, MODEL, golden, model_allowed)
    if failures:
        return failures
    for lane, expected in [('quality', '143'), ('e2e-splash', '117')]:
        with tempfile.TemporaryDirectory(prefix='ci163-marker-') as marker_dir:
            marker = Path(marker_dir) / 'visited'
            result = command(['npm', 'run', f'ci:{lane}'], root,
                             env={**os.environ, 'CI163_MARKER': str(marker)})
            observed = marker.read_text().splitlines() if marker.exists() else []
            if result.returncode or observed != [expected]:
                failures.append(f'BATAREJA_NE_VYZVANA_{lane}: rc={result.returncode} marker={observed}')
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
                'rewritten-123': 'SVERKA_123_IZMENENA'}
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
