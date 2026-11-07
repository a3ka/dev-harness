#!/usr/bin/env python3
"""Execute the actual v3 workflow steps against a bounded fake Android CLI.

Only GitHub artifact transport and the emulator binaries are simulated; sel, digest,
runner and aggregate scripts are the model's real consumer entrypoints.
"""
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

BASE = Path(__file__).resolve().parent / 'model'
LEGACY = ('e2e-splash', 'e2e-first-run', 'e2e-erstinformation', 'e2e-start', 'e2e-pilot')


class Broken(Exception):
    pass


def demand(value, name):
    if not value:
        raise Broken(name)
    return value


def execute(script, cwd, env, name):
    p = subprocess.run(['bash', '-eo', 'pipefail', '-c', script], cwd=cwd, env=env,
                       capture_output=True, text=True, timeout=25)
    if p.returncode:
        raise Broken('%s: %s' % (name, (p.stdout + p.stderr)[-250:]))


def github(script, values):
    return re.sub(r'\$\{\{\s*(.*?)\s*\}\}', lambda m: str(values.get(m.group(1), 'unused')), script)


def run(wf, map_data, defect=None):
    with tempfile.TemporaryDirectory(prefix='connected-143-') as tmp:
        root = Path(tmp)
        (root / 'mobile/scripts').mkdir(parents=True)
        (root / 'mobile/.maestro').mkdir()
        for name in ('select-ci-screens.cjs', 'ci-aggregate.cjs', 'run-ci-screen.cjs'):
            shutil.copy2(BASE / 'mobile/scripts' / name, root / 'mobile/scripts' / name)
        (root / 'mobile/ci-screens.json').write_text(json.dumps(map_data))
        for entry in map_data['ekrany']:
            if entry['job'] == 'e2e-screen':
                (root / entry['pack']).mkdir(parents=True)
                (root / entry['flows'][0]).write_text('appId: de.complior\n')
        fakebin = root / 'fakebin'
        fakebin.mkdir()
        tool = '''#!/usr/bin/env python3
import os, sys
from pathlib import Path
name = Path(sys.argv[0]).name
args = sys.argv[1:]
log = Path(os.environ['FAKE_ANDROID_LOG'])
if name == 'adb' and 'getprop' in args:
    print('1')
if name == 'adb' and 'install' in args:
    assert Path(args[-1]).is_file()
    with log.open('a') as f: f.write('INSTALLED ' + os.environ['SCREEN_ID'] + '\\n')
if name == 'maestro':
    assert Path(args[-1]).is_file()
    assert 'INSTALLED ' + os.environ['SCREEN_ID'] in log.read_text()
    if os.environ.get('FAKE_TRANSPORT_ONCE') == os.environ['SCREEN_ID']:
        marker = 'FAIL_ONCE ' + os.environ['SCREEN_ID']
        if marker not in log.read_text():
            with log.open('a') as f: f.write(marker + '\\n')
            print('device offline', file=sys.stderr)
            sys.exit(1)
    with log.open('a') as f: f.write('TESTED ' + os.environ['SCREEN_ID'] + '\\n')
'''
        for name in ('avdmanager', 'emulator', 'adb', 'maestro'):
            item = fakebin / name
            item.write_text(tool)
            item.chmod(0o755)
        log = root / 'android.log'
        log.write_text('')
        env = dict(os.environ, PATH=str(fakebin) + os.pathsep + os.environ['PATH'], ANDROID_HOME='',
                   FAKE_ANDROID_LOG=str(log), GITHUB_RUN_ID='411', GITHUB_RUN_ATTEMPT='2',
                   RUNNER_TEMP=str(root / 'runner'), RUNNER_NAME='test',
                   GITHUB_OUTPUT=str(root / 'sel-output'), GITHUB_ENV=str(root / 'job-env'),
                   FAKE_TRANSPORT_ONCE=map_data['ekrany'][-2]['id'] if defect == 'transport-once' else '')
        job = wf['jobs']['select-screens']
        sel_step = next(s for s in job['steps'] if s.get('id') == 'sel')
        demand(job.get('outputs', {}).get('matrix') == '${{ steps.sel.outputs.matrix }}', 'MATRIX_OUTPUT_EDGE')
        execute(github(sel_step['run'], {'github.event_name': 'schedule'}), root, env, 'SEL')
        selector_output = (root / 'sel-output').read_text()
        selection = json.loads((root / 'selection.json').read_text())
        matrix = demand(re.search(r'^matrix=(.+)$', selector_output, re.M), 'SEL_MATRIX_OUTPUT').group(1)
        demand(selection['matrix'] == matrix, 'SEL_MATRIX_MISMATCH')
        children = json.loads(matrix)['include']
        demand(len(children) == 2, 'MATRIX_TWO_CHILDREN')
        apk_bytes = b'APK-FROM-BUILD-143\n'
        digest = hashlib.sha256(apk_bytes).hexdigest()
        artifact = 'apk-411-' + digest[:12]
        store = root / 'artifacts' / artifact
        store.mkdir(parents=True)
        (store / 'app-release.apk').write_bytes(apk_bytes)
        worker = wf['jobs']['e2e-screen']
        demand(worker.get('needs') == ['select-screens', 'build-apk'] and
               worker['strategy']['matrix'] == '${{ fromJSON(needs.select-screens.outputs.matrix) }}', 'MATRIX_NEEDS_EDGE')
        steps = worker['steps']
        dl = next((s for s in steps if s.get('name') == 'Download the single APK'), None)
        demand(dl and dl.get('uses', '').startswith('actions/download-artifact@') and
               dl['with']['name'] == '${{ needs.build-apk.outputs.artifact_name }}', 'APK_DOWNLOAD_EDGE')
        needs = {'select-screens': {'result': 'success', 'outputs': {'matrix': matrix, 'selection': json.dumps(selection)}},
                 'quality': {'result': 'success'},
                 'build-apk': {'result': 'success', 'outputs': {'apk_sha256': digest, 'artifact_name': artifact, 'run_id': '411', 'run_attempt': '2'}},
                 'e2e-screen': {'result': 'success'}}
        for legacy in LEGACY:
            needs[legacy] = {'result': 'success', 'outputs': {'apk_sha256': digest, 'artifact_name': artifact, 'run_id': '411'}}
        collected = root / 'mobile/screen-evidence-collected'
        collected.mkdir()
        for entry in children:
            screen = entry['screen']
            child_env = dict(env, SCREEN_ID=screen['id'], SCREEN_PACK=screen['pack'],
                             SCREEN_FLOW=screen['flow'], AVD_PORT=str(screen['avd_port']),
                             APK_SHA256=digest, APK_ARTIFACT_NAME=artifact)
            dest = root / dl['with']['path']
            dest.mkdir(parents=True, exist_ok=True)
            shutil.copy2(store / 'app-release.apk', dest / 'app-release.apk')
            digest_step = next((s for s in steps if s.get('name') == 'APK digest before installation'), None)
            demand(digest_step, 'APK_DIGEST_EDGE')
            execute(github(digest_step['run'], {'needs.build-apk.outputs.apk_sha256': digest}), root, child_env, 'DIGEST')
            child_env.update(dict(line.split('=', 1) for line in (root / 'job-env').read_text().splitlines()))
            runner = next((s for s in steps if s.get('name') == 'Run selected screen'), None)
            demand(runner and 'run-ci-screen.cjs' in runner.get('run', ''), 'RUNNER_EDGE')
            execute(runner['run'], root, child_env, 'RUNNER')
            upload = next((s for s in steps if s.get('name') == 'Publish child evidence'), None)
            demand(upload and upload.get('if') == 'always()' and upload.get('uses', '').startswith('actions/upload-artifact@') and
                   upload['with']['name'] == 'screen-evidence-${{ matrix.screen.id }}-${{ github.run_id }}-${{ github.run_attempt }}' and
                   upload['with']['path'] == 'mobile/screen-evidence/${{ matrix.screen.id }}/',
                   'CHILD_UPLOAD_EDGE')
            result = root / upload['with']['path'].replace('${{ matrix.screen.id }}', screen['id']) / 'result.json'
            demand(result.is_file(), 'CHILD_RESULT_ABSENT')
            child_artifact = collected / ('screen-evidence-%s-411-2' % screen['id'])
            child_artifact.mkdir()
            shutil.copy2(result, child_artifact / 'result.json')
        demand(all('TESTED ' + c['screen']['id'] in log.read_text() for c in children), 'CHILD_NOT_EXECUTED')
        if defect == 'transport-once':
            ident = map_data['ekrany'][-2]['id']
            demand(log.read_text().count('FAIL_ONCE ' + ident) == 1 and
                   log.read_text().count('INSTALLED ' + ident) == 2,
                   'TRANSPORT_RETRY_NOT_SCREEN_LOCAL')
        aggregate = wf['jobs']['android-e2e']
        demand('e2e-screen' in aggregate['needs'], 'AGGREGATE_NEEDS_EDGE')
        download = next((s for s in aggregate['steps'] if s.get('name') == 'Download child evidence'), None)
        demand(download and download['with']['merge-multiple'] is False and
               download['with']['path'] == 'mobile/screen-evidence-collected' and
               download['with']['pattern'] == 'screen-evidence-*-${{ github.run_id }}-${{ github.run_attempt }}',
               'AGGREGATE_DOWNLOAD_EDGE')
        verify = next((s for s in aggregate['steps'] if s.get('name') == 'Verify selected children'), None)
        demand(verify and verify['env']['NEEDS_KONTEKST'] == '${{ toJSON(needs) }}', 'AGGREGATE_INPUT_EDGE')
        execute(verify['run'], root, dict(env, NEEDS_KONTEKST=json.dumps(needs)), 'AGGREGATE')
        return len(children)


def check(wf, map_data):
    try:
        count = run(wf, map_data)
        run(wf, map_data, defect='transport-once')
        for name, mutate in (
            ('selector-output', lambda w: w['jobs']['select-screens']['outputs'].pop('matrix')),
            ('apk-download', lambda w: w['jobs']['e2e-screen']['steps'].pop(2)),
            ('runner', lambda w: w['jobs']['e2e-screen']['steps'][4].update({'run': 'true'})),
            ('evidence-upload', lambda w: w['jobs']['e2e-screen']['steps'].pop()),
            ('aggregate-needs', lambda w: w['jobs']['android-e2e']['needs'].remove('e2e-screen')),
            ('aggregate-download', lambda w: w['jobs']['android-e2e']['steps'].pop(2)),
        ):
            broken = copy.deepcopy(wf)
            mutate(broken)
            try: run(broken, map_data)
            except (Broken, OSError): continue
            raise Broken('STAB_ZHIV_' + name)
        return True, 'CONNECTED_TWO_CHILDREN_%d' % count
    except (Broken, OSError, KeyError, ValueError, subprocess.TimeoutExpired) as e:
        return False, 'CONNECTED_WORKFLOW: ' + str(e)
