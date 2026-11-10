#!/usr/bin/env python3
"""143 v3 contract probe: model, live product, and independently bound weak subjects."""
import argparse
import copy
import hashlib
import os
import shutil
import json
from pathlib import Path
import subprocess
import sys
import tempfile

import yaml

HERE = Path(__file__).resolve().parent
BASE = HERE / 'model'
LEGACY = ('e2e-splash', 'e2e-first-run', 'e2e-erstinformation', 'e2e-start', 'e2e-pilot')
SELECT_MODEL = BASE / 'mobile/scripts/select-ci-screens.cjs'
AGG_MODEL = BASE / 'mobile/scripts/ci-aggregate.cjs'


def checked(ok, reason):
    return (bool(ok), reason)


def demo_map(names=('vkladki', 'gespraech')):
    data = json.loads((BASE / 'mobile/ci-screens.json').read_text())
    for idx, name in enumerate(names):
        data['ekrany'].append(dict(id=name, job='e2e-screen', status='in-development',
                                    pack='mobile/e2e-' + name + '/',
                                    flows=['mobile/.maestro/' + name + '.yaml'],
                                    avd_port=5570 + idx * 2, child_flows=[], puti=[],
                                    kontrakty=['148'], h_checkout=['.harness'],
                                    output_namespace='mobile/screen-evidence/' + name))
    return data


def model_workflow():
    base = yaml.safe_load((BASE / '.github/workflows/mobile.yml').read_text())
    delta = yaml.safe_load((BASE / 'matrix-v3.yml').read_text())['jobs']
    for name, job in delta.items():
        if name == 'select-screens':
            previous = base['jobs'][name]['outputs']
            base['jobs'][name].update(job)
            base['jobs'][name]['outputs'] = {**previous, **job['outputs']}
        elif name in ('android-e2e', 'mobile-regression-signal'):
            base['jobs'][name].update(job)
        else:
            base['jobs'][name] = job
    return base


def selected(map_data):
    chosen = [e for e in map_data['ekrany'] if e['job'] == 'e2e-screen']
    matrix = json.dumps({'include': [{'screen': {'id': e['id'], 'pack': e['pack'],
                  'flow': e['flows'][0], 'avd_port': e['avd_port']}} for e in chosen]}, separators=(',', ':')) if chosen else ''
    return {'selected': [{'id': e['id'], 'job': e['job'], 'reason': 'DEVELOPMENT'}
                         for e in chosen],
            'excluded': [{'id': e['id'], 'job': e['job'], 'reason': 'NOT_SELECTED'}
                         for e in map_data['ekrany'] if e['job'] != 'e2e-screen'] +
                        [{'id': 'pilot', 'job': 'e2e-pilot', 'reason': 'NOT_SELECTED'}],
            'matrix': matrix}


def node_run(script, *argv):
    return subprocess.run(['node', str(script), *map(str, argv)], capture_output=True, text=True,
                          env=dict(os.environ, GITHUB_RUN_ATTEMPT='2'), timeout=15)


def selector_case(root, model, tmp, names=('vkladki', 'gespraech'), subject=None):
    tmp.mkdir(parents=True, exist_ok=True)
    mapping = demo_map(names) if model else json.loads((root / 'mobile/ci-screens.json').read_text())
    extras = [e for e in mapping['ekrany'] if e.get('job') == 'e2e-screen']
    script = subject or (SELECT_MODEL if model else root / 'mobile/scripts/select-ci-screens.cjs')
    if not script.is_file():
        return checked(False, 'MATRIX_SELECTOR_ABSENT')
    # The real selector owns both selection and the emitted matrix; no standalone
    # matrix helper can make an invalid two-screen map green.
    sandbox = tmp / 'repo'
    (sandbox / 'mobile').mkdir(parents=True)
    (sandbox / 'mobile/ci-screens.json').write_text(json.dumps(mapping))
    output = tmp / 'gh-output'
    env = dict(os.environ, GITHUB_OUTPUT=str(output))
    proc = subprocess.run(['node', str(script), '--mode', 'schedule', '--repo', str(sandbox),
                           '--out', str(tmp / 'selection.json')], capture_output=True, text=True, env=env, timeout=15)
    if proc.returncode:
        return checked(False, 'MATRIX_SELECTOR: ' + proc.stderr.strip()[:160])
    try:
        data = json.loads((tmp / 'selection.json').read_text())
        emitted = [line.split('=', 1)[1] for line in output.read_text().splitlines() if line.startswith('matrix=')]
        if len(emitted) != 1 or data.get('matrix') != emitted[0]:
            return checked(False, 'MATRIX_OUTPUT_ABSENT')
        matrix = data['matrix']
        if not extras:
            return checked(matrix == '', 'MATRIX_EMPTY')
        actual = [entry['screen']['id'] for entry in json.loads(matrix)['include']]
        expected = [e['id'] for e in extras]
        return checked(actual == expected and len(set(actual)) == len(actual) and
                       [s['id'] for s in data['selected'] if s['job'] == 'e2e-screen'] == expected,
                       'MATRIX_NOT_FROM_MAP')
    except (OSError, ValueError, KeyError, TypeError):
        return checked(False, 'MATRIX_OUTPUT_ABSENT')

def selector_output_case(wf, root, tmp):
    """Execute the workflow's actual sel step, not just the selector executable."""
    from connected_v3 import github

    steps = [step for step in wf['jobs']['select-screens']['steps'] if step.get('id') == 'sel']
    if len(steps) != 1:
        return checked(False, 'MATRIX_SEL_STEP_COUNT')
    script = root / 'mobile/scripts/select-ci-screens.cjs'
    if not script.is_file():
        return checked(False, 'MATRIX_SELECTOR_ABSENT')
    mapping = demo_map()
    expected = selected(mapping)['matrix']
    (tmp / 'mobile/scripts').mkdir(parents=True)
    shutil.copy2(script, tmp / 'mobile/scripts/select-ci-screens.cjs')
    (tmp / 'mobile/ci-screens.json').write_text(json.dumps(mapping))
    output = tmp / 'gh-output'
    proc = subprocess.run(['bash', '-eo', 'pipefail', '-c',
                           github(steps[0]['run'], {'github.event_name': 'schedule'})],
                          cwd=tmp, env=dict(os.environ, GITHUB_OUTPUT=str(output)),
                          capture_output=True, text=True, timeout=25)
    if proc.returncode:
        return checked(False, 'MATRIX_SEL_RUN: ' + (proc.stdout + proc.stderr)[-160:])
    try:
        selection = json.loads((tmp / 'selection.json').read_text())
        emitted = [line.split('=', 1)[1] for line in output.read_text().splitlines()
                   if line.startswith('matrix=')]
        if len(emitted) != 1:
            return checked(False, 'MATRIX_OUTPUT_WRITERS: %d' % len(emitted))
        return checked(emitted[0] == selection['matrix'] == expected,
                       'MATRIX_OUTPUT_DIVERGENCE')
    except (OSError, ValueError, KeyError, TypeError):
        return checked(False, 'MATRIX_OUTPUT_DIVERGENCE')


def duplicate_case(tmp):
    mapping = demo_map()
    results = []
    for field, reason in (('id', 'DUPL_ID'), ('pack', 'DUPL_VLADENIJA')):
        weak = copy.deepcopy(mapping)
        weak['ekrany'][-1][field] = weak['ekrany'][-2][field]
        path = tmp / field
        (path / 'mobile').mkdir(parents=True)
        (path / 'mobile/ci-screens.json').write_text(json.dumps(weak))
        proc = node_run(SELECT_MODEL, '--mode', 'schedule', '--repo', path, '--out', path / 'sel.json')
        results.append(proc.returncode == 1 and reason in proc.stderr)
    return checked(all(results), 'MATRIX_DUPLICATE_OWNER_OR_ID')

def duplicate_matrix_case(tmp, field, reason, subject=SELECT_MODEL):
    """Each schedule-map collision must fail at its own public selector input."""
    mapping = demo_map()
    if field == 'flow':
        mapping['ekrany'][-1]['flows'] = list(mapping['ekrany'][-2]['flows'])
    else:
        mapping['ekrany'][-1]['avd_port'] = mapping['ekrany'][-2]['avd_port']
    (tmp / 'mobile').mkdir(parents=True)
    (tmp / 'mobile/ci-screens.json').write_text(json.dumps(mapping))
    proc = node_run(subject, '--mode', 'schedule', '--repo', tmp, '--out', tmp / 'sel.json')
    return checked(proc.returncode == 1 and reason in proc.stderr,
                   'MATRIX_DUPLICATE_' + field.upper() + ': ' + proc.stderr.strip()[:160])



def empty_case(tmp, script=AGG_MODEL, omit_matrix=False):
    """A skipped matrix is valid only with a nonempty legacy selection."""
    outputs = {'selection': '', 'matrix': ''}
    if omit_matrix:
        del outputs['matrix']
    needs = {'select-screens': {'result': 'success', 'outputs': outputs},
             'quality': {'result': 'success'},
             'build-apk': {'result': 'success', 'outputs': {'apk_sha256': 'a' * 64,
                 'artifact_name': 'apk-411-aaaaaaaaaaaa', 'run_id': '411', 'run_attempt': '2'}},
             'e2e-screen': {'result': 'skipped'}}
    for name in LEGACY:
        needs[name] = {'result': 'skipped'}
    needs['e2e-splash'] = {'result': 'success', 'outputs': dict(needs['build-apk']['outputs'])}
    sel = {'selected': [{'id': 'splash', 'job': 'e2e-splash', 'reason': 'AFFECTED'}],
           'excluded': [{'job': name, 'reason': 'NOT_SELECTED'} for name in LEGACY[1:]], 'matrix': ''}
    inp = tmp / 'empty-needs.json'
    proof = tmp / 'empty-proof'
    proof.mkdir(parents=True)
    def invoke(payload):
        needs['select-screens']['outputs']['selection'] = json.dumps(payload)
        inp.write_text(json.dumps(needs))
        return node_run(script, '--needs', inp, '--evidence', proof)
    valid = invoke(sel)
    invalid = invoke(dict(sel, selected=[]))
    absent = needs.pop('e2e-start')
    lost = invoke(sel)
    needs['e2e-start'] = absent
    if omit_matrix:
        mismatch = invoke(dict(sel, selected=sel['selected'] + [
            {'id': 'vkladki', 'job': 'e2e-screen', 'reason': 'AFFECTED'}]))
        if mismatch.returncode != 1 or 'MATRIX_NE_SELECTION' not in mismatch.stdout:
            return checked(False, 'MATRIX_ABSENT_WITH_CHILD_ACCEPTED: ' + mismatch.stdout.strip())
    return checked(valid.returncode == 0 and 'CHILD_EVIDENCE_OK' in valid.stdout and
                   invalid.returncode == 1 and 'PUSTOJ_NABOR' in invalid.stdout and
                   lost.returncode == 1 and 'LEGACY_NEEDS_OTSUTSTVUET' in lost.stdout,
                   ('MATRIX_OUTPUT_ABSENT: ' + valid.stdout.strip()) if omit_matrix else 'MATRIX_EMPTY_AGGREGATE')



def workflow_case(wf, old, which):
    jobs = wf.get('jobs', {})
    matrix = jobs.get('e2e-screen', {})
    if which == 'legacy':
        return checked(all(jobs.get(j) == old.get('jobs', {}).get(j) for j in LEGACY), 'LEGACY_JOB_CHANGED')
    if which == 'matrix':
        return checked(matrix.get('needs') == ['select-screens', 'build-apk'] and
                       matrix.get('strategy', {}).get('matrix') == '${{ fromJSON(needs.select-screens.outputs.matrix) }}' and
                       matrix.get('strategy', {}).get('fail-fast') is False and
                       jobs.get('select-screens', {}).get('outputs', {}).get('matrix') == '${{ steps.sel.outputs.matrix }}' and
                       all(jobs['select-screens']['outputs'].get(key) == value
                           for key, value in old['jobs']['select-screens']['outputs'].items()),
                       'MATRIX_DAG')
    if which == 'allocator':
        launch = next((str(s.get('run', '')) for s in matrix.get('steps', [])
                       if 'run-ci-screen.cjs' in str(s.get('run', ''))), '')
        return checked(matrix.get('runs-on') == ['self-hosted', 'linux', 'x64', 'kvm', 'complior'] and
                       matrix.get('strategy', {}).get('max-parallel') == 2 and
                       'matrix.screen.avd_port' in str(matrix.get('steps')) and
                       'flock ' in launch and 'ANDROID_AVD_HOME=' in launch and
                       'ADB_SERVER_PORT=' in launch, 'MATRIX_ALLOCATOR')
    if which == 'evidence':
        for aggregate in ('android-e2e', 'mobile-regression-signal'):
            job = jobs.get(aggregate, {})
            if 'e2e-screen' not in job.get('needs', []):
                return checked(False, 'MATRIX_NEEDS_AGGREGATE_' + aggregate)
            steps = job.get('steps', [])
            if not any('download-artifact@' in str(s.get('uses', '')) and
                       s.get('with', {}).get('merge-multiple') is False and
                       'screen-evidence-*' in str(s.get('with', {}).get('pattern', '')) for s in steps):
                return checked(False, 'CHILD_DOWNLOAD_ABSENT_' + aggregate)
            if not any('ci-aggregate.cjs' in str(s.get('run', '')) and '--evidence' in str(s.get('run', '')) for s in steps):
                return checked(False, 'CHILD_VERIFIER_ABSENT_' + aggregate)
        upload = matrix.get('steps', [])
        return checked(any('upload-artifact@' in str(s.get('uses', '')) and
                           s.get('if') == 'always()' and 'matrix.screen.id' in
                           str(s.get('with', {}).get('name', '')) for s in upload), 'CHILD_UPLOAD_ABSENT')
    if which == 'apk':
        steps = matrix.get('steps', [])
        digest = next((i for i, s in enumerate(steps) if 'APK_DIGEST_RASKHOZHDENIE' in str(s.get('run', ''))), -1)
        run = next((i for i, s in enumerate(steps) if 'run-ci-screen.cjs' in str(s.get('run', ''))), -1)
        secret = str(matrix)
        return checked(0 <= digest < run and 'needs.build-apk.outputs.apk_sha256' in str(steps[digest]) and
                       'PILOT_DEMO_CODE' not in secret, 'MATRIX_APK_OR_SECRET')
    raise ValueError(which)


def evidence_case(root, model, tmp, missing=False, bad_digest=False, parent_failure=False,
                  missing_matrix_output=False, subject=None):
    script = subject or (AGG_MODEL if model else root / 'mobile/scripts/ci-aggregate.cjs')
    if not script.is_file():
        return checked(False, 'CHILD_AGGREGATOR_ABSENT')
    mapping = demo_map()
    ids = [e['id'] for e in mapping['ekrany'] if e.get('job') == 'e2e-screen']
    sel = selected(mapping)
    outputs = {'selection': json.dumps(sel)}
    if sel['matrix'] and not missing_matrix_output:
        outputs['matrix'] = sel['matrix']
    needs = {'select-screens': {'result': 'success', 'outputs': outputs},
        'quality': {'result': 'success'}, 'build-apk': {'result': 'success', 'outputs': {
            'apk_sha256': 'a' * 64, 'artifact_name': 'apk-411-aaaaaaaaaaaa', 'run_id': '411', 'run_attempt': '2'}},
        'e2e-screen': {'result': 'success'}}
    needs.update({j: {'result': 'skipped'} for j in LEGACY})
    proof_dir = tmp / 'child-evidence'
    proof_dir.mkdir(parents=True)
    for ident in ids:
        directory = proof_dir / ('screen-evidence-' + ident + '-411-2')
        directory.mkdir()
        (directory / 'result.json').write_text(json.dumps({'screen_id': ident, 'status': 'success',
                                                          'apk_sha256': 'b' * 64 if bad_digest and ident == ids[-1] else 'a' * 64,
                                                          'artifact_name': 'apk-411-aaaaaaaaaaaa', 'run_id': '411', 'run_attempt': '2'}))
    if missing:
        (proof_dir / ('screen-evidence-' + ids[-1] + '-411-2') / 'result.json').unlink()
    if parent_failure:
        needs['e2e-screen']['result'] = 'failure'
    input_path = tmp / 'needs.json'
    input_path.write_text(json.dumps(needs))
    proc = node_run(script, '--needs', input_path, '--evidence', proof_dir)
    if parent_failure:
        return checked(proc.returncode == 1 and 'AGREGAT_OTKAZ: MATRIX_PARENT_OTKAZ' in proc.stdout,
                       'MATRIX_PARENT_NOT_FAIL_CLOSED: ' + proc.stdout.strip())
    if missing_matrix_output:
        return checked(proc.returncode == 1 and 'AGREGAT_OTKAZ: MATRIX_NE_SELECTION' in proc.stdout,
                       'MATRIX_OUTPUT_NOT_FAIL_CLOSED: ' + proc.stdout.strip())
    if missing or bad_digest:
        return checked(proc.returncode == 1 and 'CHILD_EVIDENCE_OTKAZ' in proc.stdout,
                       'CHILD_NOT_FAIL_CLOSED')
    return checked(proc.returncode == 0 and 'CHILD_EVIDENCE_OK' in proc.stdout,
                   'CHILD_NOT_AGGREGATED')


def inventory_case(wf, tmp, branch):
    """Exercise each product inventory branch on the empty matrix map."""
    import probe
    probe.MATRIX_V3 = True
    (tmp / 'mobile').mkdir(parents=True, exist_ok=True)
    shutil.copy2(BASE / 'mobile/ci-screens.json', tmp / 'mobile/ci-screens.json')
    checks = {
        'y01-nabor-jobs': lambda: probe.KLETKI_Y[0][1](wf, tmp),
        'y02-agregat-needs': lambda: probe.KLETKI_Y[1][1](wf, tmp),
        'i02-jobs-iz-karty': lambda: probe.sud_joby_iz_karty(wf, tmp),
        'i04-agregaty-iz-karty': lambda: probe.sud_agregaty_iz_karty(wf, tmp),
    }
    try:
        ok, reason = checks[branch]()
        return checked(ok, reason)
    except probe.KartaSubiekta as exc:
        return checked(False, str(exc))


INVENTORY_BRANCHES = ('y01-nabor-jobs', 'y02-agregat-needs',
                      'i02-jobs-iz-karty', 'i04-agregaty-iz-karty')


# Stub bindings live in executable code only: each mutation is observed on its own branch.
STUBS = {
    'legacy-rewritten': ('legacy', lambda wf: wf['jobs']['e2e-splash'].update({'timeout-minutes': 1})),
    'matrix-hardcoded': ('matrix', lambda wf: wf['jobs']['e2e-screen']['strategy'].update({'matrix': {'include': [{'screen': {'id': 'vkladki'}}]}})),
    'matrix-fixed-host': ('allocator', lambda wf: wf['jobs']['e2e-screen'].update({'runs-on': ['self-hosted', 'runner-1']})),
    'aggregate-no-child': ('evidence', lambda wf: wf['jobs']['android-e2e']['needs'].remove('e2e-screen')),
    'no-digest': ('apk', lambda wf: wf['jobs']['e2e-screen']['steps'].pop(3)),
    'secret-leak': ('apk', lambda wf: wf['jobs']['e2e-screen']['steps'][4].update({'env': {'PILOT_DEMO_CODE': '${{ secrets.PILOT_DEMO_CODE }}'}})),
}


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--model', action='store_true')
    group.add_argument('--stabs', action='store_true')
    group.add_argument('--repo', type=Path)
    args = parser.parse_args()
    if not args.model and not args.stabs and not args.repo:
        print('MATRIX_SUBJECT_ABSENT', file=sys.stderr)
        return 1
    try:
        pins = json.loads((HERE / 'source.json').read_text())['v3_piny']
        if set(pins) != {'model/matrix-v3.yml', 'model/mobile/scripts/run-ci-screen.cjs'}:
            print('ORACLE_TAMPERED: v3_piny census', file=sys.stderr)
            return 2
        for name, expected in pins.items():
            if hashlib.sha256((HERE / name).read_bytes()).hexdigest() != expected:
                print('ORACLE_TAMPERED: ' + name, file=sys.stderr)
                return 2
    except (OSError, KeyError, ValueError) as exc:
        print('ORACLE_TAMPERED: ' + str(exc), file=sys.stderr)
        return 2
    root = BASE if not args.repo else args.repo.resolve()
    try:
        workflow = model_workflow() if not args.repo else yaml.safe_load((root / '.github/workflows/mobile.yml').read_text())
        old = yaml.safe_load((BASE / '.github/workflows/mobile.yml').read_text())
    except (OSError, yaml.YAMLError) as exc:
        print('MATRIX_WORKFLOW_ABSENT: ' + str(exc), file=sys.stderr)
        return 1
    with tempfile.TemporaryDirectory(prefix='matrix-143-v3-') as t:
        tmp = Path(t)
        results = [(name, workflow_case(workflow, old, name)) for name in ('legacy', 'matrix', 'allocator', 'evidence', 'apk')]
        results.append(('selector', selector_case(root, not args.repo, tmp)))
        results.append(('selector-output', selector_output_case(workflow, root, tmp / 'selector-output')))
        if not args.repo:
            from connected_v3 import check as connected_check
            results.append(('connected', connected_check(workflow, demo_map())))
            for branch in INVENTORY_BRANCHES:
                results.append(('inventory-' + branch, inventory_case(workflow, tmp / ('inventory-' + branch), branch)))
        if not args.repo:
            results.append(('selector-growth', selector_case(root, True, tmp / 'growth',
                                                               names=('vkladki', 'gespraech', 'novyj'))))
            results.append(('selector-duplicates', duplicate_case(tmp / 'duplicates')))
            results.append(('selector-duplicate-flow',
                            duplicate_matrix_case(tmp / 'duplicate-flow', 'flow', 'INVENTAR_KARTY')))
            results.append(('selector-duplicate-port',
                            duplicate_matrix_case(tmp / 'duplicate-port', 'port', 'MATRIX_PORT_KOLLIZIJA')))
        results.append(('child-ok', evidence_case(root, not args.repo, tmp)))
        results.append(('child-missing', evidence_case(root, not args.repo, tmp / 'missing', missing=True)))
        results.append(('child-wrong-digest', evidence_case(root, not args.repo, tmp / 'wrong', bad_digest=True)))
        results.append(('child-parent-failure',
                        evidence_case(root, not args.repo, tmp / 'parent-failure', parent_failure=True)))
        results.append(('child-matrix-output-absent',
                        evidence_case(root, not args.repo, tmp / 'matrix-output-absent',
                                      missing_matrix_output=True)))
        results.append(('empty-matrix', empty_case(tmp, AGG_MODEL if not args.repo else root / 'mobile/scripts/ci-aggregate.cjs')))
        results.append(('empty-matrix-output-absent', empty_case(
            tmp / 'absent', AGG_MODEL if not args.repo else root / 'mobile/scripts/ci-aggregate.cjs',
            omit_matrix=True)))
        for name, (ok, reason) in results:
            print('КЛЕТКА %s %s%s' % (name, 'ЗЕЛЕНА' if ok else 'КРАСНА: ', '' if ok else reason))
        print('клеток %d, зелёных %d, красных %d' % (len(results), sum(ok for _, (ok, _) in results), sum(not ok for _, (ok, _) in results)))
        if any(not ok for _, (ok, _) in results):
            return 1
        if args.stabs:
            for name, (branch, mutate) in STUBS.items():
                weak = copy.deepcopy(workflow)
                mutate(weak)
                ok, reason = workflow_case(weak, old, branch)
                if ok or reason.startswith('ISKLJUCHENIE'):
                    print('STAB_ZHIV %s @ %s: %s' % (name, branch, reason))
                    return 1
                print('СТАБ %s @ %s КРАСЕН: %s' % (name, branch, reason))
            for name, mutate in (
                ('output-absent', lambda wf: wf['jobs']['select-screens']['outputs'].pop('matrix')),
                ('producer-absent', lambda wf: wf['jobs']['select-screens']['steps'].__setitem__(
                    next(i for i, step in enumerate(wf['jobs']['select-screens']['steps'])
                         if step.get('id') == 'sel'),
                    {'id': 'sel', 'run': 'echo selection.json'})),
            ):
                weak = copy.deepcopy(workflow)
                mutate(weak)
                for branch in INVENTORY_BRANCHES:
                    ok, reason = inventory_case(weak, tmp / ('weak-' + name + '-' + branch), branch)
                    if ok or 'MATRIX_OUTPUT_REQUIRED' not in reason:
                        print('STAB_ZHIV %s @ %s: %s' % (name, branch, reason))
                        return 1
                    print('СТАБ %s @ %s КРАСЕН: %s' % (name, branch, reason))
            weak = copy.deepcopy(workflow)
            sel_step = next(step for step in weak['jobs']['select-screens']['steps']
                            if step.get('id') == 'sel')
            sel_step['run'] += '\necho \'matrix={"include":[{"screen":{"id":"podmena"}}]}\' >> "$GITHUB_OUTPUT"\n'
            ok, reason = selector_output_case(weak, root, tmp / 'weak-second-writer')
            if ok or 'MATRIX_OUTPUT_WRITERS' not in reason:
                print('STAB_ZHIV matrix-second-writer @ selector-output: ' + reason)
                return 1
            print('СТАБ matrix-second-writer @ selector-output КРАСЕН: ' + reason)
            selector_stub = tmp / 'selector-fixed.cjs'
            source = SELECT_MODEL.read_text()
            anchor = "const matrix = matrixScreens.length ? JSON.stringify({ include: matrixScreens }) : \"\";"
            if source.count(anchor) != 1:
                print('ORACLE_TAMPERED: selector mutation anchor', file=sys.stderr)
                return 2
            selector_stub.write_text(source.replace(anchor,
                "const matrix = matrixScreens.length ? JSON.stringify({ include: matrixScreens.slice(0, 2) }) : \"\";"))
            ok, reason = selector_case(root, True, tmp / 'selector-weak',
                                       names=('vkladki', 'gespraech', 'novyj'), subject=selector_stub)
            if ok:
                print('STAB_ZHIV selector-fixed @ selector-growth')
                return 1
            print('СТАБ selector-fixed @ selector-growth КРАСЕН: ' + reason)
            aggregate_stub = tmp / 'aggregate-echo.cjs'
            aggregate_stub.write_text("console.log('CHILD_EVIDENCE_OK');\n")
            for name, kwargs in (('child-missing', {'missing': True}),
                                 ('child-wrong-digest', {'bad_digest': True})):
                ok, reason = evidence_case(root, True, tmp / ('weak-' + name),
                                           subject=aggregate_stub, **kwargs)
                if ok:
                    print('STAB_ZHIV aggregate-echo @ ' + name)
                    return 1
                print('СТАБ aggregate-echo @ %s КРАСЕН: %s' % (name, reason))
            absent_stub = tmp / 'aggregate-requires-matrix-key.cjs'
            aggregate_source = AGG_MODEL.read_text()
            equality = '  if ((matrixOutput === undefined ? "" : matrixOutput) !== sel.matrix) otkaz("MATRIX_NE_SELECTION");'
            if aggregate_source.count(equality) != 1:
                print('ORACLE_TAMPERED: empty matrix mutation anchor', file=sys.stderr)
                return 2
            absent_stub.write_text(aggregate_source.replace(
                equality, '  if (matrixOutput !== sel.matrix) otkaz("MATRIX_NE_SELECTION");'))
            ok, reason = empty_case(tmp / 'weak-empty-absent', absent_stub, omit_matrix=True)
            if ok or 'MATRIX_NE_SELECTION' not in reason:
                print('STAB_ZHIV aggregate-requires-matrix-key @ empty-matrix-output-absent: ' + reason)
                return 1
            print('СТАБ aggregate-requires-matrix-key @ empty-matrix-output-absent КРАСЕН: ' + reason)
            ok, reason = empty_case(tmp / 'weak-empty-present', absent_stub)
            if not ok:
                print('STAB_NE_K_ETOMU_VHODU aggregate-requires-matrix-key @ empty-matrix: ' + reason)
                return 1
            flow_stub = tmp / 'selector-no-flow.cjs'
            flow_guard = '''      if (poFlow.has(flow) && (args.mode === "schedule" || args.mode === "dispatch")) {
        return { oshibka: "INVENTAR_KARTY", label, flow };
      }
'''
            if source.count(flow_guard) != 1:
                print('ORACLE_TAMPERED: flow mutation anchor', file=sys.stderr)
                return 2
            flow_stub.write_text(source.replace(flow_guard, ''))
            ok, reason = duplicate_matrix_case(tmp / 'weak-duplicate-flow', 'flow',
                                                'INVENTAR_KARTY', subject=flow_stub)
            if ok:
                print('STAB_ZHIV selector-no-flow @ selector-duplicate-flow')
                return 1
            print('СТАБ selector-no-flow @ selector-duplicate-flow КРАСЕН: ' + reason)
            port_stub = tmp / 'selector-no-port.cjs'
            port_guard = 'if (new Set(matrixScreens.map((e) => e.screen.avd_port)).size !== matrixScreens.length) fail("MATRIX_PORT_KOLLIZIJA");'
            if source.count(port_guard) != 1:
                print('ORACLE_TAMPERED: port mutation anchor', file=sys.stderr)
                return 2
            port_stub.write_text(source.replace(port_guard, ''))
            ok, reason = duplicate_matrix_case(tmp / 'weak-duplicate-port', 'port',
                                                'MATRIX_PORT_KOLLIZIJA', subject=port_stub)
            if ok:
                print('STAB_ZHIV selector-no-port @ selector-duplicate-port')
                return 1
            print('СТАБ selector-no-port @ selector-duplicate-port КРАСЕН: ' + reason)
            parent_stub = tmp / 'aggregate-no-parent.cjs'
            aggregate_source = AGG_MODEL.read_text()
            parent_guard = '  if (needs["e2e-screen"]?.result !== (chosen.length ? "success" : "skipped")) otkaz("MATRIX_PARENT_OTKAZ");\n'
            if aggregate_source.count(parent_guard) != 1:
                print('ORACLE_TAMPERED: parent mutation anchor', file=sys.stderr)
                return 2
            parent_stub.write_text(aggregate_source.replace(parent_guard, ''))
            ok, reason = evidence_case(root, True, tmp / 'weak-parent-failure',
                                       parent_failure=True, subject=parent_stub)
            if ok:
                print('STAB_ZHIV aggregate-no-parent @ child-parent-failure')
                return 1
            print('СТАБ aggregate-no-parent @ child-parent-failure КРАСЕН: ' + reason)
            wrong_field = tmp / 'aggregate-matrix-from-selection.cjs'
            matrix_field = '  const matrixOutput = needs["select-screens"].outputs?.matrix;'
            if aggregate_source.count(matrix_field) != 1:
                print('ORACLE_TAMPERED: actual matrix output mutation anchor', file=sys.stderr)
                return 2
            wrong_field.write_text(aggregate_source.replace(matrix_field, '  const matrixOutput = sel.matrix;'))
            ok, reason = evidence_case(root, True, tmp / 'weak-matrix-output',
                                       missing_matrix_output=True, subject=wrong_field)
            if ok or 'MATRIX_OUTPUT_NOT_FAIL_CLOSED' not in reason:
                print('STAB_ZHIV aggregate-matrix-from-selection @ child-matrix-output-absent: ' + reason)
                return 1
            print('СТАБ aggregate-matrix-from-selection @ child-matrix-output-absent КРАСЕН: ' + reason)
            ok, reason = evidence_case(root, True, tmp / 'weak-matrix-present', subject=wrong_field)
            if not ok:
                print('STAB_NE_K_ETOMU_VHODU aggregate-matrix-from-selection @ child-ok: ' + reason)
                return 1
            false_parent = tmp / 'aggregate-false-parent.cjs'
            false_parent.write_text(aggregate_source.replace(
                parent_guard, '  if (false) otkaz("MATRIX_PARENT_OTKAZ");\n'))
            ok, reason = evidence_case(root, True, tmp / 'weak-false-parent',
                                       parent_failure=True, subject=false_parent)
            if ok or 'MATRIX_PARENT_NOT_FAIL_CLOSED' not in reason:
                print('STAB_ZHIV aggregate-false-parent @ child-parent-failure: ' + reason)
                return 1
            print('СТАБ aggregate-false-parent @ child-parent-failure КРАСЕН: ' + reason)
            ok, reason = evidence_case(root, True, tmp / 'weak-parent-success', subject=false_parent)
            if not ok:
                print('STAB_NE_K_ETOMU_VHODU aggregate-false-parent @ child-ok: ' + reason)
                return 1
            print('стабов %d, привязок %d, живых 0' % (len(STUBS) + 11, len(STUBS) + 18))
        return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, IndexError, subprocess.TimeoutExpired) as exc:
        print('MATRIX_INFRASTRUCTURE: ' + str(exc), file=sys.stderr)
        sys.exit(2)
