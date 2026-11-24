#!/usr/bin/env python3
"""143 v6 acceptance: capture/prepare immutable 216 input, exact residual, pairs.

--prepare MOBILE_CLONE OUT reconstructs compatibility.py's R with its own .git.
--repo R judges exact pre-existing residual, never converts full rc 1 to green.
--model/--stabs exercise each lane and scoped negative pair on a green 143 model.
"""
import argparse
import copy
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
os.environ['PYTHONDONTWRITEBYTECODE'] = '1'

import yaml
import lanes_216 as lanes

HERE = Path(__file__).resolve().parent
# Enumerated external remainder from the assignment, not inferred by running R.
RESIDUAL = {'legacy', 'workflow-quality-run-step-3', 'workflow-quality-run-step-6',
            'y12-avd-namespace', 'y13-odin-uroven-vosstanovlenija',
            'y23-ispolnenie-povtora', 'p01-P-nabor'}
LANE_CELLS = ('workflow-select-screens-run-step-2', 'workflow-select-screens-run-step-3',
              'workflow-build-apk-run-step-3', 'workflow-build-apk-run-step-7',
              'selector-output', 'y01-nabor-jobs', 'y02-agregat-needs',
              'y16-noch-polnyj-nabor', 'i02-jobs-iz-karty', 'i04-agregaty-iz-karty',
              'i05-vynos-iz-inventarja')


def call(argv, **kw):
    p = subprocess.run(list(map(str, argv)), text=True, capture_output=True, timeout=180, **kw)
    print('COMMAND ' + ' '.join(map(str, argv)), flush=True)
    print(p.stdout, end='')
    print(p.stderr, end='', file=sys.stderr)
    print('RC ' + str(p.returncode), flush=True)
    return p


def capture(mobile):
    raw = (mobile / '.harness/fixtures/mob_ci_revizija_216/baseline.json').read_bytes()
    if hashlib.sha256(raw).hexdigest() != lanes.BASELINE_SHA:
        raise ValueError('ORACLE_TAMPERED: capture-216')
    lanes.BASELINE.write_bytes(raw)
    print('CAPTURE_SHA256 ' + lanes.BASELINE_SHA)


def prepare(mobile, out):
    # Exactly compatibility.py: disposable clone BASE + b.model overlay.
    if out.exists():
        raise ValueError('PREPARE_TARGET_EXISTS')
    source = mobile / '.harness/fixtures/mob_ci_revizija_216/battery.py'
    spec = importlib.util.spec_from_file_location('mobile216', source)
    b = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(b)
    data = b.oracle()
    subprocess.run(['git', 'clone', '--quiet', '--no-hardlinks', '--no-checkout', str(mobile), str(out)], check=True)
    subprocess.run(['git', '-C', str(out), 'checkout', '--quiet', '--detach', b.BASE], check=True)
    with tempfile.TemporaryDirectory(prefix='model216-') as td:
        generated = Path(td) / 'model'
        b.model(generated, data)
        shutil.copytree(generated, out, dirs_exist_ok=True)
    return call(['bash', b.F / 'run.sh', '--repo', out, '--base', b.BASE]).returncode


def residual(repo):
    p = call(['bash', HERE / 'red_mob_ci_143.sh', '--repo', repo])
    red = set()
    green = set()
    for line in p.stdout.splitlines():
        if not line.startswith('КЛЕТКА '):
            continue
        if ' КРАСНА' in line:
            red.add(line.split()[1].rstrip(':'))
        if 'ЗЕЛЕНА' in line or 'ЗЕЛЁНАЯ' in line or 'ЗЕЛЕНАЯ' in line:
            green.add(line.split()[1].rstrip(':'))
    # Legacy CLI prints only red cells, so prove each positive explicitly by
    # its existing checker instead of treating missing output as success.
    with tempfile.TemporaryDirectory(prefix='residual216-143-') as td:
        wf = yaml.safe_load((repo / '.github/workflows/mobile.yml').read_text())
        for branch in LANE_CELLS:
            ok, reason = scoped(wf, repo, Path(td) / branch, branch)
            if ok:
                green.add(branch)
            else:
                print('LANE_DELTA_RED ' + branch + ': ' + reason)
    if p.returncode != 1 or red != RESIDUAL or not set(LANE_CELLS) <= green:
        print('RESIDUAL_MISMATCH red=' + repr(sorted(red)) + ' missing-green=' + repr(sorted(set(LANE_CELLS) - green)))
        return 1
    print('RESIDUAL_EXACT ' + ','.join(sorted(red)))
    print('LANE_DELTA_GREEN ' + str(len(LANE_CELLS)))
    return controls(stabs=True, repo=repo)


def scoped(wf, root, tmp, branch):
    import matrix_v3 as m
    import probe as p
    p.MATRIX_V3 = True
    if branch == 'selector-output':
        return m.selector_output_case(wf, root, tmp)
    if branch.startswith('workflow-'):
        hits = [(ok, reason) for name, (ok, reason) in m.workflow_controls(
            lanes.project(wf, root, m.sweep_bazir(wf)), m.sweep_bazir(wf)) if name == branch]
        if len(hits) != 1:
            raise ValueError('SCOPED_CELL_UNKNOWN ' + branch)
        return hits[0]
    effective = lanes.project(wf, root)
    functions = dict(p.KLETKI_Y)
    functions.update({'i02-jobs-iz-karty': p.sud_joby_iz_karty,
                      'i04-agregaty-iz-karty': p.sud_agregaty_iz_karty,
                      'i05-vynos-iz-inventarja': p.sud_vynos_iz_inventarja})
    try:
        return functions[branch](effective, root)
    except p.KartaSubiekta as exc:
        return False, str(exc)


def controls(stabs=False, repo=None):
    import matrix_v3 as m
    # Each mutation is bound in code to the branch where it is observable.
    bindings = {
        'node-version': ('workflow-build-apk-run-step-3',),
        'build-identity': ('workflow-build-apk-run-step-7',),
        'select-screens': ('workflow-select-screens-run-step-2', 'selector-output',
                           'y01-nabor-jobs', 'y02-agregat-needs', 'y16-noch-polnyj-nabor',
                           'i02-jobs-iz-karty', 'i04-agregaty-iz-karty'),
        'selection-outputs': ('workflow-select-screens-run-step-3',),
        'inventar': ('i05-vynos-iz-inventarja',),
    }
    count = mutations = 0
    with tempfile.TemporaryDirectory(prefix='lane216-143-') as td:
        root = Path(td) / 'repo'
        shutil.copytree(m.BASE, root)
        if repo is None:
            wf = lanes.install(root, m.model_workflow())
        else:
            shutil.copytree(repo / 'mobile/scripts', root / 'mobile/scripts', dirs_exist_ok=True)
            shutil.copy2(repo / 'mobile/ci-screens.json', root / 'mobile/ci-screens.json')
            shutil.copy2(repo / 'package.json', root / 'package.json')
            wf = yaml.safe_load((repo / '.github/workflows/mobile.yml').read_text())
        for branch in LANE_CELLS:
            ok, reason = scoped(wf, root, Path(td) / ('honest-' + branch), branch)
            if not ok:
                print('LANE_HONEST_RED ' + branch + ': ' + reason)
                return 1
            count += 1
        # Honest equivalent shell preamble and YAML serialization remain green.
        for lane in lanes.LANES:
            path = root / ('mobile/scripts/ci-' + lane + '.sh')
            original = path.read_text()
            path.write_text(original.replace('set -euo pipefail\n', 'set -eu\nset -o pipefail\n', 1))
            for branch in bindings[lane]:
                ok, reason = scoped(wf, root, Path(td) / ('equiv-' + branch), branch)
                if not ok:
                    print('LANE_EQUIVALENT_RED ' + branch + ': ' + reason)
                    return 1
            path.write_text(original)
        if stabs:
            for lane, branches in bindings.items():
                # Body, routing, selector env and lifecycle/dispatcher failures
                # are distinct surfaces; none may inherit an inline guarantee.
                for kind in ('body', 'route', 'dispatcher', 'lifecycle', 'cwd', 'env', 'name', 'id'):
                    broken = copy.deepcopy(wf)
                    path = root / ('mobile/scripts/ci-' + lane + '.sh')
                    package = root / 'package.json'
                    dispatcher = root / 'mobile/scripts/run-mobile-ci.cjs'
                    saved = {p: p.read_text() for p in (path, package, dispatcher)}
                    if kind == 'body':
                        path.write_text('#!/usr/bin/env bash\nexit 0\n')
                    elif kind == 'route':
                        value = json.loads(package.read_text())
                        value['scripts']['ci:' + lane] = 'node -e "process.exit(0)"'
                        package.write_text(json.dumps(value))
                    elif kind == 'dispatcher':
                        dispatcher.write_text('process.exit(0);\n')
                    elif kind == 'lifecycle':
                        value = json.loads(package.read_text())
                        value['scripts']['postci:' + lane] = 'echo matrix= >> "$GITHUB_OUTPUT"'
                        package.write_text(json.dumps(value))
                    else:
                        step = next(s for b in broken['jobs'].values() for s in b.get('steps', [])
                                    if s.get('run') == 'npm run ci:' + lane)
                        if kind == 'cwd':
                            step['working-directory'] = 'mobile'
                        elif kind == 'env':
                            step['env'] = {'EVENT_NAME': 'push'}
                        else:
                            step[kind] = 'wrong-operation'
                    for branch in branches:
                        ok, reason = scoped(broken, root, Path(td) / (kind + '-' + branch), branch)
                        if ok:
                            print('LANE_STAB_ALIVE ' + lane + '/' + kind + ' @ ' + branch)
                            return 1
                        mutations += 1
                        print('LANE_STAB ' + lane + '/' + kind + ' @ ' + branch + ' RED ' + reason)
                    for p, text in saved.items():
                        p.write_text(text)
    print('LANE_CONTROLS ' + str(count) + ' NEGATIVE_BINDINGS ' + str(mutations))
    return 0


def syntax():
    import ast
    for path in HERE.glob('*.py'):
        ast.parse(path.read_text(), filename=str(path))
    subprocess.run(['bash', '-n', str(HERE / 'red_mob_ci_143.sh')], check=True)
    for path in (HERE / 'model').rglob('*.cjs'):
        subprocess.run(['node', '--check', str(path)], check=True)
    with tempfile.TemporaryDirectory(prefix='syntax216-143-') as td:
        for name, text in lanes.scripts(lanes.oracle()).items():
            path = Path(td) / name
            path.write_text(text)
            subprocess.run(['bash', '-n', str(path)] if name.endswith('.sh') else ['node', '--check', str(path)], check=True)
    print('SYNTAX_143_OK')
    return 0


def main():
    p = argparse.ArgumentParser()
    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument('--capture', type=Path)
    g.add_argument('--prepare', nargs=2, type=Path, metavar=('MOBILE', 'OUT'))
    g.add_argument('--repo', type=Path)
    g.add_argument('--model', action='store_true')
    g.add_argument('--stabs', action='store_true')
    g.add_argument('--syntax', action='store_true')
    a = p.parse_args()
    if a.capture:
        capture(a.capture)
        return 0
    if a.prepare:
        return prepare(*a.prepare)
    lanes.oracle()
    if a.repo:
        return residual(a.repo)
    if a.syntax:
        return syntax()
    return controls(a.stabs)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as exc:
        print('LANE_216_INFRASTRUCTURE: ' + str(exc), file=sys.stderr)
        sys.exit(2)
