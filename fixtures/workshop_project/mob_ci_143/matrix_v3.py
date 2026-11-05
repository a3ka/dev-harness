#!/usr/bin/env python3
"""143 v3 contract probe: model, live product, and independently bound weak subjects."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile

import yaml

HERE = Path(__file__).resolve().parent
BASE = HERE / 'model'
LEGACY = ('e2e-splash', 'e2e-first-run', 'e2e-erstinformation', 'e2e-start', 'e2e-pilot')
SELECT_MODEL = BASE / 'matrix-select-v3.cjs'
AGG_MODEL = BASE / 'matrix-aggregate-v3.cjs'


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
        if name in ('select-screens', 'android-e2e', 'mobile-regression-signal'):
            base['jobs'][name].update(job)
        else:
            base['jobs'][name] = job
    return base


def selected(map_data):
    return {'selected': [{'id': e['id'], 'job': 'e2e-screen', 'reason': 'DEVELOPMENT'}
                         for e in map_data['ekrany'] if e['job'] == 'e2e-screen'],
            'excluded': []}


def node_run(script, *argv):
    return subprocess.run(['node', str(script), *map(str, argv)], capture_output=True, text=True, timeout=15)


def selector_case(root, model, tmp, names=('vkladki', 'gespraech'), subject=None):
    tmp.mkdir(parents=True, exist_ok=True)
    mapping = demo_map(names) if model else json.loads((root / 'mobile/ci-screens.json').read_text())
    extras = [e for e in mapping['ekrany'] if e.get('job') == 'e2e-screen']
    map_path, sel_path = tmp / 'map.json', tmp / 'selection.json'
    map_path.write_text(json.dumps(mapping))
    sel_path.write_text(json.dumps(selected(mapping)))
    script = subject or (SELECT_MODEL if model else root / 'mobile/scripts/select-ci-screens.cjs')
    if not script.is_file():
        return checked(False, 'MATRIX_SELECTOR_ABSENT')
    # Product selector's published matrix must derive from the same map and selection.
    if model:
        proc = node_run(script, map_path, sel_path)
        if proc.returncode:
            return checked(False, 'MATRIX_MODEL: ' + proc.stderr.strip())
        if not proc.stdout.strip() and not extras:
            return checked(True, 'MATRIX_EMPTY')
        try:
            output = json.loads(proc.stdout)
        except ValueError:
            return checked(False, 'MATRIX_MODEL_NE_JSON')
    else:
        # The product interface is --mode schedule --repo R --out selection.json;
        # matrix is a separate JSON field in the output, NEVER guessed from the map.
        proc = node_run(script, '--mode', 'schedule', '--repo', root, '--out', tmp / 'actual.json')
        if proc.returncode:
            return checked(False, 'MATRIX_SELECTOR: ' + proc.stderr.strip()[:100])
        try:
            data = json.loads((tmp / 'actual.json').read_text())
            output = data['matrix']
            if not extras and output == '':
                return checked(True, 'MATRIX_EMPTY')
            if isinstance(output, str):
                output = json.loads(output)
        except (OSError, ValueError, KeyError, TypeError):
            return checked(False, 'MATRIX_OUTPUT_ABSENT')
    expected = [e['id'] for e in extras]
    actual = [entry['screen']['id'] for entry in output['include']]
    return checked(actual == expected and len(set(actual)) == len(actual), 'MATRIX_NOT_FROM_MAP')

def empty_case(tmp):
    mapping = json.loads((BASE / 'mobile/ci-screens.json').read_text())
    map_path, sel_path = tmp / 'empty-map.json', tmp / 'empty-selection.json'
    map_path.write_text(json.dumps(mapping))
    sel_path.write_text(json.dumps({'selected': [], 'excluded': []}))
    selector = node_run(SELECT_MODEL, map_path, sel_path)
    if selector.returncode or selector.stdout != '':
        return checked(False, 'MATRIX_EMPTY_NOT_SKIPPED')
    needs = {'select-screens': {'result': 'success', 'outputs': {'selection': sel_path.read_text(), 'matrix': ''}},
             'quality': {'result': 'success'},
             'build-apk': {'result': 'success', 'outputs': {'apk_sha256': 'a' * 64, 'artifact_name': 'apk-411-aaaaaaaaaaaa', 'run_id': '411', 'run_attempt': '2'}},
             'e2e-screen': {'result': 'skipped'}}
    path = tmp / 'empty-needs.json'
    path.write_text(json.dumps(needs))
    proof = tmp / 'empty-proof'
    proof.mkdir()
    aggregate = node_run(AGG_MODEL, path, proof)
    return checked(aggregate.returncode == 0 and 'CHILD_EVIDENCE_OK' in aggregate.stdout, 'MATRIX_EMPTY_AGGREGATE')



def workflow_case(wf, old, which):
    jobs = wf.get('jobs', {})
    matrix = jobs.get('e2e-screen', {})
    if which == 'legacy':
        return checked(all(jobs.get(j) == old.get('jobs', {}).get(j) for j in LEGACY), 'LEGACY_JOB_CHANGED')
    if which == 'matrix':
        return checked(matrix.get('needs') == ['select-screens', 'build-apk'] and
                       matrix.get('strategy', {}).get('matrix') == '${{ fromJSON(needs.select-screens.outputs.matrix) }}' and
                       matrix.get('strategy', {}).get('fail-fast') is False and
                       jobs.get('select-screens', {}).get('outputs', {}).get('matrix') == '${{ steps.sel.outputs.matrix }}',
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


def evidence_case(root, model, tmp, missing=False, bad_digest=False, subject=None):
    script = subject or (AGG_MODEL if model else root / 'mobile/scripts/ci-aggregate.cjs')
    if not script.is_file():
        return checked(False, 'CHILD_AGGREGATOR_ABSENT')
    mapping = demo_map()
    ids = [e['id'] for e in mapping['ekrany'] if e.get('job') == 'e2e-screen']
    needs = {'select-screens': {'result': 'success', 'outputs': {
        'selection': json.dumps(selected(mapping)), 'matrix': json.dumps({'include': [{'screen': {'id': i}} for i in ids]})}},
        'quality': {'result': 'success'}, 'build-apk': {'result': 'success', 'outputs': {
            'apk_sha256': 'a' * 64, 'artifact_name': 'apk-411-aaaaaaaaaaaa', 'run_id': '411', 'run_attempt': '2'}},
        'e2e-screen': {'result': 'success'}}
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
    input_path = tmp / 'needs.json'
    input_path.write_text(json.dumps(needs))
    proc = node_run(script, input_path, proof_dir) if model else node_run(script, '--needs', input_path, '--evidence', proof_dir)
    if missing or bad_digest:
        return checked(proc.returncode == 1 and 'CHILD_EVIDENCE_OTKAZ:' in proc.stderr,
                       'CHILD_NOT_FAIL_CLOSED')
    return checked(proc.returncode == 0 and 'CHILD_EVIDENCE_OK' in proc.stdout,
                   'CHILD_NOT_AGGREGATED')


# Stub bindings live in executable code only: each mutation is observed on its own branch.
STUBS = {
    'legacy-rewritten': ('legacy', lambda wf: wf['jobs']['e2e-splash'].update({'timeout-minutes': 1})),
    'matrix-hardcoded': ('matrix', lambda wf: wf['jobs']['e2e-screen']['strategy'].update({'matrix': {'include': [{'screen': {'id': 'vkladki'}}]}})),
    'matrix-fixed-host': ('allocator', lambda wf: wf['jobs']['e2e-screen'].update({'runs-on': ['self-hosted', 'runner-1']})),
    'aggregate-no-child': ('evidence', lambda wf: wf['jobs']['android-e2e']['needs'].remove('e2e-screen')),
    'no-digest': ('apk', lambda wf: wf['jobs']['e2e-screen']['steps'].pop(2)),
    'secret-leak': ('apk', lambda wf: wf['jobs']['e2e-screen']['steps'][3].update({'env': {'PILOT_DEMO_CODE': '${{ secrets.PILOT_DEMO_CODE }}'}})),
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
        if set(pins) != {'model/matrix-v3.yml', 'model/matrix-select-v3.cjs', 'model/matrix-aggregate-v3.cjs'}:
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
        if not args.repo:
            results.append(('selector-growth', selector_case(root, True, tmp / 'growth',
                                                               names=('vkladki', 'gespraech', 'novyj'))))
        results.append(('child-ok', evidence_case(root, not args.repo, tmp)))
        results.append(('child-missing', evidence_case(root, not args.repo, tmp / 'missing', missing=True)))
        results.append(('child-wrong-digest', evidence_case(root, not args.repo, tmp / 'wrong', bad_digest=True)))
        results.append(('empty-matrix', empty_case(tmp)))
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
            selector_stub = tmp / 'selector-fixed.cjs'
            source = SELECT_MODEL.read_text()
            anchor = "const chosen = selection.selected.filter(e => e.job === 'e2e-screen').map(e => e.id);"
            if source.count(anchor) != 1:
                print('ORACLE_TAMPERED: selector mutation anchor', file=sys.stderr)
                return 2
            selector_stub.write_text(source.replace(anchor, "const chosen = ['vkladki', 'gespraech'];"))
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
            print('стабов %d, привязок %d, живых 0' % (len(STUBS) + 2, len(STUBS) + 3))
        return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, IndexError, subprocess.TimeoutExpired) as exc:
        print('MATRIX_INFRASTRUCTURE: ' + str(exc), file=sys.stderr)
        sys.exit(2)
