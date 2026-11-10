#!/usr/bin/env python3
"""143 v3 contract probe: model, live product, and independently bound weak subjects."""
#
# Guard sweep on product mirror 9c4fc4c77: branch → independent cell → neutralised
# guard caught. New rows use `guard_stub`/the named accept-value stub in --stabs;
# legacy rows use probe.py's own public --repo cells and the isolated product
# mutation sweep. The entries below name actual rejective sites, not just reasons.
# Root/on control rows come from workflow_sweep_v3.root_controls(model, subject):
# root field and every nested map/list path in the actual and model YAML;
# absent optional permission scopes and trigger filters have explicit rows.
# Each independently mutated path has its own --workflow-cell assertion.
# `jobs` is checked for required names only; individual job controls below
# preserve extensibility of new screen workers.
# `on.pull_request.branches` must still include main; optional event types
# must contain opened/synchronize/reopened. Other filters can skip PRs.
# Existing trigger rows preserve their names; nested rows append YAML keys or
# list indices (e.g. workflow-root-permissions-contents and
# workflow-on-schedule-0-cron).
# Workflow control-field table (full row expansion and product mutation:
# workflow_sweep_v3.controls + workflow_mutation_sweep.py --repo <candidate>).
# Field → independent cell → rejected mutation is generated mechanically:
#   jobs.<job>.<field> → workflow-<job>-<field> → false/[]/wrong fromJSON/
#     continue-on-error=true/wrong runs-on/timeout=1/outputs={}/write permission/
#     broad concurrency/env CI=false (see mutate(), per-field row).
#   jobs.<job>.steps[<i>].if|continue-on-error|run →
#     workflow-<job>-<field>-step-<i> → false|true|echo skipped-critical-step.
# In addition to the existing job/step rows, each existing job receives a
# named permissions.<scope> cell; absent scopes are mutated to write.
# Independently owned quality steps can grow: their if/continue-on-error
# flags are discovered from the actual workflow. Missing needs/outputs are
# not mutated to []/{} because those are semantically indistinguishable.
# Exact field counts are emitted by workflow_mutation_sweep.py after expanding
# the actual product YAML; stale hand-counts must not be treated as coverage.
# Every real mutant is separately red against its own complete repository copy.
# Five legacy e2e-* jobs: I-15 forbids rewriting; `legacy` checks full YAML.
# New 151/995/117 quality run bodies belong to their frozen owners, not a
# stale 143 model; their conditional flags remain in this sweep.
# Aggregate ci-aggregate.cjs, physical line → cell / matching mutation:
#  27 → legacy-guard-no-needs-arg / weak_ok; 30 → legacy-guard-invalid-needs-json / weak_ok
#  32 → a16-pustoj-needs / bypass; 39 → a07/a08/a09 / bypass
#  45 → legacy-guard-invalid-selection-json / weak_ok
#  51 → legacy-guard-selection-absent / weak_ok
#  56 → guard-no-evidence-arg / weak_ok; 59 → child-matrix-output-absent / bypass
#  60 → guard-selected-invalid / weak_ok; 64 → guard-identity-missing / weak_ok
#  67 → guard-legacy-missing / weak_ok; 71 → guard-legacy-chosen-not-success / weak_ok
#  72 → guard-legacy-skip-no-reason / weak_ok; 76 → guard-matrix-malformed / weak_ok
#  80 → guard-matrix-mismatch,guard-matrix-duplicate / weak_ok
#  81 → child-parent-{failure,cancelled,skipped,absent},empty-parent-* / allow one result
#  85 → guard-evidence-dir-missing / weak_ok; 86 → guard-evidence-extra / weak_ok
#  92 → guard-proof-{id,status,artifact,run,attempt},child-wrong-digest / weak_ok
#  93 → child-missing / weak_ok; 98 → legacy-guard-selection-invalid / weak_ok
#  99 → a01-pustoj-nabor / bypass; 102 → legacy-guard-selected-reason-absent / weak_ok
# 106 → a02-vybrannyj-vne-reestra / bypass
# 114 → legacy-guard-build-identity-absent / weak_ok
# 117 → a03/a04/a05/a06 / bypass; 119 → a10-digest-chuzhoj / bypass
# 120 → legacy-guard-artifact-mismatch / weak_ok; 121 → a11-staryj-artefakt / bypass
# 129 → a12-lishnij-rabotnik / bypass
# 130 → legacy-guard-unselected-failure / weak_ok
# 131 → a13-skip-bez-prichiny / bypass
# Selector select-ci-screens.cjs, physical line → cell / matching mutation:
#  43 → selector-entry-unknown-argument / weak_ok
#  46 → selector-entry-unknown-mode / weak_ok
#  62 → selector-guard-map-json / bypass
#  63 → selector-guard-map-schema / bypass
#  82 → selector-guard-{id,job}-absent / bypass
#  84 → selector-guard-status-invalid / bypass
#  86 → selector-guard-id-duplicate / bypass
#  90 → selector-guard-job-duplicate / bypass
#  93 → selector-guard-pack-duplicate / bypass
#  97 → selector-guard-flow-duplicate / bypass
# 102 → selector-guard-pack-invalid / bypass
# 105 → selector-guard-registry-empty / bypass
# 112 → selector-guard-map-absent / missing-as-empty; 119 → same cell / weak_ok
# 129 → selector-entry-invalid-base-map / weak_ok
# 150 → inventory-guard-mobile-exec-only / weak_ok (readable file, unreadable dir)
# 155 → inventory-guard-pack-name-invalid / bypass
# 159 → no stable input: lstat immediately follows successful readdir
# 160 → inventory-guard-pack-symlink / bypass
# 161 → inventory-guard-pack-file / bypass
# 163 → inventory-guard-pack-unregistered / bypass
# 164 → dominated by map parser's duplicate-pack rejection at 93
# 170 → inventory-guard-pack-missing / weak_ok
# 173 → inventory-guard-legacy-entry-missing / weak_ok
# 178 → inventory-guard-flow-missing / weak_ok
# 193 → inventory-guard-flow-unregistered / weak_ok
# 195 → inventory-guard-flow-two-owners / bypass
# 218 → s16-net-bazy / neutralise fallback; 222 → s18-oshibka-diffa / neutralise
# 250 → selector-entry-api-invalid-pull / accept malformed API
# 256 → selector-entry-api-files-error / accept failed API
# 258 → selector-entry-api-files-object / accept nonarray API
# 268 → s17-api-usechenie / neutralise truncation
# 287 → s17-api-usechenie / accept partial; 288 → s16-net-bazy / accept unavailable
# 380 → s03/s04 / accept unregistered path
# 393 → s05 / accept double-owned flow
# 418 → selector-guard-screen-{pack-absent,flows-absent,port-small,port-odd,
#        port-reserved} / bypass
# 422 → selector-guard-screen-port-duplicate / bypass
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
from workflow_sweep_v3 import check as workflow_controls, stabs as workflow_stabs

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


def selector_guard_case(root, model, tmp, variant, subject=None):
    """One map or screen-field rejection, with a valid two-screen baseline."""
    mapping = demo_map()
    entries = mapping['ekrany']
    last = entries[-1]
    other = entries[-2]
    expected = {
        'map-absent': 'KARTA_OTSUTSTVUET', 'map-json': 'KARTA_NE_JSON',
        'map-schema': 'SKHEMA_KARTY', 'id-absent': 'SKHEMA_KARTY',
        'job-absent': 'SKHEMA_KARTY', 'status-invalid': 'SKHEMA_KARTY',
        'id-duplicate': 'DUPL_ID', 'job-duplicate': 'DUPL_JOB',
        'pack-duplicate': 'DUPL_VLADENIJA', 'flow-duplicate': 'INVENTAR_KARTY',
        'pack-invalid': 'SKHEMA_PACHKI', 'registry-empty': 'PUSTOJ_REESTR',
        'screen-pack-absent': 'MATRIX_KARTA_EKRANA',
        'screen-flows-absent': 'MATRIX_KARTA_EKRANA',
        'screen-port-small': 'MATRIX_KARTA_EKRANA',
        'screen-port-odd': 'MATRIX_KARTA_EKRANA',
        'screen-port-reserved': 'MATRIX_KARTA_EKRANA',
        'screen-port-duplicate': 'MATRIX_PORT_KOLLIZIJA',
    }
    tmp.mkdir(parents=True)
    (tmp / 'mobile').mkdir()
    if variant == 'map-schema':
        mapping['schema'] = 2
    elif variant == 'id-absent':
        last.pop('id')
    elif variant == 'job-absent':
        last.pop('job')
    elif variant == 'status-invalid':
        last['status'] = 'archived'
    elif variant == 'id-duplicate':
        last['id'] = other['id']
    elif variant == 'job-duplicate':
        last['job'] = entries[0]['job']
    elif variant == 'pack-duplicate':
        last['pack'] = other['pack']
    elif variant == 'flow-duplicate':
        last['flows'] = other['flows']
    elif variant == 'pack-invalid':
        last['pack'] = 'mobile/e2e-bad_name/'
    elif variant == 'registry-empty':
        mapping['ekrany'] = []
        mapping.pop('integracija', None)
    elif variant == 'screen-pack-absent':
        last['pack'] = None
    elif variant == 'screen-flows-absent':
        last['flows'] = []
    elif variant == 'screen-port-small':
        last['avd_port'] = 1023
    elif variant == 'screen-port-odd':
        last['avd_port'] = 5573
    elif variant == 'screen-port-reserved':
        last['avd_port'] = 5560
    elif variant == 'screen-port-duplicate':
        last['avd_port'] = other['avd_port']
    script = subject or (SELECT_MODEL if model else root / 'mobile/scripts/select-ci-screens.cjs')
    if not script.is_file():
        return checked(False, 'MATRIX_SELECTOR_ABSENT')
    if variant != 'map-absent':
        (tmp / 'mobile/ci-screens.json').write_text('{' if variant == 'map-json' else json.dumps(mapping))
    proc = node_run(script, '--mode', 'schedule', '--repo', tmp, '--out', tmp / 'selection.json')
    return checked(proc.returncode == 1 and 'VYBOR_OTKAZ: ' + expected[variant] in proc.stderr,
                   'SELECTOR_GUARD_%s: rc=%d stdout=%s stderr=%s' % (
                       variant, proc.returncode, proc.stdout.strip()[:80], proc.stderr.strip()[:160]))


SELECTOR_GUARDS = (
    'map-absent', 'map-json', 'map-schema', 'id-absent', 'job-absent',
    'status-invalid', 'id-duplicate', 'job-duplicate', 'pack-duplicate',
    'flow-duplicate', 'pack-invalid', 'registry-empty',
    'screen-pack-absent', 'screen-flows-absent', 'screen-port-small',
    'screen-port-odd', 'screen-port-reserved', 'screen-port-duplicate',
)



def inventory_guard_case(root, model, tmp, variant, subject=None):
    """Exercise one inventar-mode filesystem guard with its own counterexample."""
    mapping = demo_map()
    entries = list(mapping['ekrany'])
    if mapping.get('integracija'):
        entries.append(mapping['integracija'])
    expected = {
        'mobile-exec-only': 'NET_KATALOGA',
        'pack-unregistered': 'PACHKA_BEZ_REGISTRACII',
        'pack-missing': 'ZAPIS_BEZ_VHODA',
        'pack-symlink': 'SYMLINK_PACHKI',
        'pack-file': 'SKHEMA_PACHKI',
        'pack-name-invalid': 'SKHEMA_PACHKI',
        'legacy-entry-missing': 'ZAPIS_BEZ_VHODA',
        'flow-missing': 'ZAPIS_BEZ_VHODA',
        'flow-unregistered': 'POTOK_BEZ_REGISTRACII',
        'flow-two-owners': 'DUPL_VLADENIJA',
    }
    if variant == 'flow-two-owners':
        entries[-2]['flows'] = list(entries[-3]['flows'])
    (tmp / 'mobile').mkdir(parents=True)
    (tmp / 'mobile/ci-screens.json').write_text(json.dumps(mapping))
    packs = {e['pack'] for e in entries if e.get('pack')}
    flows = set(mapping.get('sluzhebnye_potoki') or [])
    for entry in entries:
        flows.update(entry.get('flows') or entry.get('fiksirovannyj_nabor') or [])
        flows.update(entry.get('child_flows') or [])
        if entry.get('legacy_entrypoint'):
            flows.add(entry['legacy_entrypoint'])
    for pack in packs:
        (tmp / pack).mkdir(parents=True)
    for flow in flows:
        if flow.startswith('mobile/'):
            target = tmp / flow
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text('flow\n')
    extra_pack = tmp / 'mobile/e2e-proba-143'
    if variant == 'pack-unregistered':
        extra_pack.mkdir()
    elif variant == 'pack-symlink':
        extra_pack.symlink_to(tmp / 'outside')
    elif variant == 'pack-file':
        extra_pack.write_text('not-a-pack\n')
    elif variant == 'pack-name-invalid':
        (tmp / 'mobile/e2e-bad_name').mkdir()
    elif variant == 'pack-missing':
        (tmp / sorted(packs)[0]).rmdir()
    elif variant == 'legacy-entry-missing':
        legacy = next(e['legacy_entrypoint'] for e in entries if e.get('legacy_entrypoint'))
        (tmp / legacy).unlink()
    elif variant == 'flow-missing':
        flow = next(f for f in sorted(flows) if f.startswith('mobile/'))
        (tmp / flow).unlink()
    elif variant == 'flow-unregistered':
        (tmp / 'mobile/.maestro/proba-143.yaml').write_text('unregistered\n')
    script = subject or (SELECT_MODEL if model else root / 'mobile/scripts/select-ci-screens.cjs')
    if not script.is_file():
        return checked(False, 'MATRIX_SELECTOR_ABSENT')
    if variant == 'mobile-exec-only':
        (tmp / 'mobile').chmod(0o111)  # readMap(file) works; readdir(mobile) must fail.
    try:
        proc = node_run(script, '--mode', 'inventar', '--repo', tmp, '--out', tmp / 'inventar.json')
    finally:
        if variant == 'mobile-exec-only':
            (tmp / 'mobile').chmod(0o755)
    return checked(proc.returncode == 1 and 'VYBOR_OTKAZ: ' + expected[variant] in proc.stderr,
                   'INVENTORY_GUARD_%s: rc=%d stdout=%s stderr=%s' % (
                       variant, proc.returncode, proc.stdout.strip()[:80], proc.stderr.strip()[:160]))


INVENTORY_GUARDS = (
    'mobile-exec-only', 'pack-unregistered', 'pack-missing', 'pack-symlink',
    'pack-file', 'pack-name-invalid', 'legacy-entry-missing', 'flow-missing',
    'flow-unregistered', 'flow-two-owners',
)


def selector_entry_guard_case(root, model, tmp, variant, subject=None):
    """One CLI/base/API error at the public selector process boundary."""
    (tmp / 'mobile').mkdir(parents=True)
    (tmp / 'mobile/ci-screens.json').write_text(json.dumps(demo_map()))
    script = subject or (SELECT_MODEL if model else root / 'mobile/scripts/select-ci-screens.cjs')
    if not script.is_file():
        return checked(False, 'MATRIX_SELECTOR_ABSENT')
    expected = {
        'unknown-argument': 'NEIZVESTNYJ_ARGUMENT',
        'unknown-mode': 'REZHIM',
        'invalid-base-map': 'KARTA_NE_JSON',
        'api-invalid-pull': 'NET_BAZY',
        'api-files-error': 'OSIBKA_DIFFA',
        'api-files-object': 'OSIBKA_DIFFA',
    }
    env = dict(os.environ, GITHUB_RUN_ATTEMPT='2')
    argv = ['--mode', 'schedule', '--repo', str(tmp), '--out', str(tmp / 'selection.json')]
    if variant == 'unknown-argument':
        argv += ['--bogus', 'value']
    elif variant == 'unknown-mode':
        argv[1] = 'unknown'
    else:
        bin_dir = tmp / 'bin'
        bin_dir.mkdir()
        git = bin_dir / 'git'
        git.write_text('#!/usr/bin/env python3\nimport sys\n'
                       'if \"show\" in sys.argv and %r:\n print(\"{\"); sys.exit(0)\n'
                       'sys.exit(1)\n' % (variant == 'invalid-base-map'))
        git.chmod(0o755)
        if variant != 'invalid-base-map':
            gh = bin_dir / 'gh'
            gh.write_text('#!/usr/bin/env python3\nimport sys\n'
                          'url = sys.argv[-1]\n'
                          'if \"/files?\" not in url:\n'
                          ' print(%r); sys.exit(0)\n'
                          'if %r: sys.exit(1)\n'
                          'print(\"{}\")\n' % ('{' if variant == 'api-invalid-pull' else '{"changed_files":1}',
                                               variant == 'api-files-error'))
            gh.chmod(0o755)
        env['PATH'] = str(bin_dir) + os.pathsep + env['PATH']
        argv = ['--mode', 'pull_request', '--repo', str(tmp), '--out', str(tmp / 'selection.json'),
                '--base-sha', 'base', '--head-sha', 'head', '--pr', '1']
    proc = subprocess.run(['node', str(script), *argv], capture_output=True, text=True,
                          env=env, timeout=15)
    return checked(proc.returncode == 1 and 'VYBOR_OTKAZ: ' + expected[variant] in proc.stderr,
                   'SELECTOR_ENTRY_%s: rc=%d stdout=%s stderr=%s' % (
                       variant, proc.returncode, proc.stdout.strip()[:80], proc.stderr.strip()[:160]))


SELECTOR_ENTRY_GUARDS = (
    'unknown-argument', 'unknown-mode', 'invalid-base-map',
    'api-invalid-pull', 'api-files-error', 'api-files-object',
)


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



def empty_parent_case(tmp, script, parent_result):
    """A worker omitted from a truly empty matrix must be exactly skipped."""
    tmp.mkdir(parents=True)
    needs = {'select-screens': {'result': 'success', 'outputs': {}},
             'quality': {'result': 'success'},
             'build-apk': {'result': 'success', 'outputs': {
                 'apk_sha256': 'a' * 64, 'artifact_name': 'apk-411-aaaaaaaaaaaa', 'run_id': '411'}},
             'e2e-screen': {} if parent_result is None else {'result': parent_result}}
    for name in LEGACY:
        needs[name] = {'result': 'skipped'}
    needs[LEGACY[0]] = {'result': 'success', 'outputs': dict(needs['build-apk']['outputs'])}
    selection = {'selected': [{'id': 'splash', 'job': LEGACY[0], 'reason': 'AFFECTED'}],
                 'excluded': [{'job': name, 'reason': 'NOT_SELECTED'} for name in LEGACY[1:]],
                 'matrix': ''}
    needs['select-screens']['outputs']['selection'] = json.dumps(selection)
    (tmp / 'needs.json').write_text(json.dumps(needs))
    (tmp / 'proof').mkdir()
    proc = node_run(script, '--needs', tmp / 'needs.json', '--evidence', tmp / 'proof')
    return checked(proc.returncode == 1 and 'AGREGAT_OTKAZ: MATRIX_PARENT_OTKAZ' in proc.stdout,
                   'EMPTY_PARENT_NOT_FAIL_CLOSED: ' + proc.stdout.strip())


def legacy_guard_case(tmp, script, variant):
    """A valid legacy-only selection with one independently damaged input."""
    tmp.mkdir(parents=True)
    build = {'apk_sha256': 'a' * 64, 'artifact_name': 'apk-411-aaaaaaaaaaaa', 'run_id': '411'}
    needs = {'select-screens': {'result': 'success', 'outputs': {}},
             'quality': {'result': 'success'},
             'build-apk': {'result': 'success', 'outputs': build}}
    for name in LEGACY:
        needs[name] = {'result': 'skipped'}
    needs[LEGACY[0]] = {'result': 'success', 'outputs': dict(build)}
    sel = {'selected': [{'id': 'splash', 'job': LEGACY[0], 'reason': 'AFFECTED'}],
           'excluded': [{'job': name, 'reason': 'NOT_SELECTED'} for name in LEGACY[1:]]}
    expected = {
        'no-needs-arg': 'NET_VHODA', 'invalid-needs-json': 'NEEDS_NE_JSON',
        'invalid-selection-json': 'SELECTION_NE_JSON',
        'selection-absent': 'SELECTION_OTSUTSTVUET',
        'selection-invalid': 'SELECTION_NE_VALIDNA',
        'selected-reason-absent': 'SELECTION_NE_VALIDNA',
        'build-identity-absent': 'SBORKA_BEZ_IDENTICHNOSTI',
        'artifact-mismatch': 'CHUZHOJ_ARTEFAKT',
        'unselected-failure': 'NE_VYBRAN_NE_SKIP',
    }
    if variant == 'selection-invalid':
        del sel['excluded']
    elif variant == 'selected-reason-absent':
        del sel['selected'][0]['reason']
    elif variant == 'build-identity-absent':
        del build['apk_sha256']
    elif variant == 'artifact-mismatch':
        needs[LEGACY[0]]['outputs']['artifact_name'] = 'different'
    elif variant == 'unselected-failure':
        needs[LEGACY[1]]['result'] = 'failure'
    needs['select-screens']['outputs']['selection'] = json.dumps(sel)
    if variant == 'invalid-selection-json':
        needs['select-screens']['outputs']['selection'] = '{'
    elif variant == 'selection-absent':
        del needs['select-screens']['outputs']['selection']
    path = tmp / 'needs.json'
    path.write_text('{' if variant == 'invalid-needs-json' else json.dumps(needs))
    argv = () if variant == 'no-needs-arg' else ('--needs', path)
    proc = node_run(script, *argv)
    return checked(proc.returncode == 1 and 'AGREGAT_OTKAZ: ' + expected[variant] in proc.stdout,
                   'LEGACY_GUARD_' + variant + ': ' + proc.stdout.strip())


LEGACY_GUARDS = (
    'no-needs-arg', 'invalid-needs-json', 'invalid-selection-json',
    'selection-absent', 'selection-invalid', 'selected-reason-absent',
    'build-identity-absent', 'artifact-mismatch', 'unselected-failure',
)


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


def evidence_case(root, model, tmp, missing=False, bad_digest=False, parent_result='success',
                  missing_matrix_output=False, subject=None, variant=None):
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
    if parent_result is None:
        needs['e2e-screen'].pop('result')
    else:
        needs['e2e-screen']['result'] = parent_result
    # Each malformed input starts from the same fully valid two-child evidence,
    # then changes exactly one guarded condition.
    expected = {
        'no-evidence-arg': 'CHILD_EVIDENCE_OTKAZ — NET_VHODA',
        'selected-invalid': 'PUSTOJ_NABOR',
        'identity-missing': 'CHILD_EVIDENCE_OTKAZ — NET_IDENTICHNOSTI',
        'legacy-missing': 'LEGACY_NEEDS_OTSUTSTVUET',
        'legacy-chosen-not-success': 'LEGACY_OTKAZ',
        'legacy-skip-no-reason': 'LEGACY_SKIP_OTKAZ',
        'matrix-malformed': 'MATRIX_NE_JSON',
        'matrix-mismatch': 'MATRIX_NE_SELECTION',
        'matrix-duplicate': 'MATRIX_NE_SELECTION',
        'evidence-dir-missing': 'CHILD_EVIDENCE_OTKAZ',
        'evidence-extra': 'CHILD_EVIDENCE_OTKAZ — PEREPIS_DETEJ',
        'proof-id': 'CHILD_EVIDENCE_OTKAZ — CHUZHOJ_REZULTAT_',
        'proof-status': 'CHILD_EVIDENCE_OTKAZ — CHUZHOJ_REZULTAT_',
        'proof-artifact': 'CHILD_EVIDENCE_OTKAZ — CHUZHOJ_REZULTAT_',
        'proof-run': 'CHILD_EVIDENCE_OTKAZ — CHUZHOJ_REZULTAT_',
        'proof-attempt': 'CHILD_EVIDENCE_OTKAZ — CHUZHOJ_REZULTAT_',
    }
    if variant == 'selected-invalid':
        sel['selected'] = None
    elif variant == 'identity-missing':
        del needs['build-apk']['outputs']['apk_sha256']
    elif variant == 'legacy-missing':
        del needs[LEGACY[0]]
    elif variant == 'legacy-chosen-not-success':
        sel['selected'].append({'id': 'splash', 'job': LEGACY[0], 'reason': 'AFFECTED'})
        sel['excluded'] = [e for e in sel['excluded'] if e['job'] != LEGACY[0]]
    elif variant == 'legacy-skip-no-reason':
        sel['excluded'] = [e for e in sel['excluded'] if e['job'] != LEGACY[0]]
    elif variant == 'matrix-malformed':
        sel['matrix'] = '{'
        needs['select-screens']['outputs']['matrix'] = '{'
    elif variant == 'matrix-mismatch':
        sel['matrix'] = '{"include":[]}'
        needs['select-screens']['outputs']['matrix'] = sel['matrix']
    elif variant == 'matrix-duplicate':
        sel['selected'].append(dict(sel['selected'][0]))
    elif variant == 'evidence-extra':
        (proof_dir / 'unregistered-child').mkdir()
    elif variant in ('proof-id', 'proof-status', 'proof-artifact', 'proof-run', 'proof-attempt'):
        proof = proof_dir / ('screen-evidence-' + ids[0] + '-411-2') / 'result.json'
        data = json.loads(proof.read_text())
        field = {'proof-id': 'screen_id', 'proof-status': 'status',
                 'proof-artifact': 'artifact_name', 'proof-run': 'run_id',
                 'proof-attempt': 'run_attempt'}[variant]
        data[field] = 'foreign'
        proof.write_text(json.dumps(data))
    if variant is not None:
        needs['select-screens']['outputs']['selection'] = json.dumps(sel)
    input_path = tmp / 'needs.json'
    input_path.write_text(json.dumps(needs))
    argv = ('--needs', input_path) if variant == 'no-evidence-arg' else (
        '--needs', input_path, '--evidence', proof_dir / 'absent' if variant == 'evidence-dir-missing' else proof_dir)
    proc = node_run(script, *argv)
    if variant is not None:
        return checked(proc.returncode == 1 and 'AGREGAT_OTKAZ: ' + expected[variant] in proc.stdout,
                       'GUARD_' + variant + '_NOT_FAIL_CLOSED: ' + proc.stdout.strip())
    if parent_result != 'success':
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


LEGACY_GUARD_LINES = {
    'no-needs-arg': 27, 'invalid-needs-json': 30,
    'invalid-selection-json': 45, 'selection-absent': 51,
    'selection-invalid': 98, 'selected-reason-absent': 102,
    'build-identity-absent': 114, 'artifact-mismatch': 120,
    'unselected-failure': 130,
}


SELECTOR_ENTRY_LINES = {
    'unknown-argument': 43, 'unknown-mode': 46, 'invalid-base-map': 129,
    'api-invalid-pull': 250, 'api-files-error': 256, 'api-files-object': 258,
}


INVENTORY_GUARD_LINES = {
    'mobile-exec-only': 150,
    'pack-unregistered': 163, 'pack-missing': 170, 'pack-symlink': 160,
    'pack-file': 161, 'pack-name-invalid': 155,
    'legacy-entry-missing': 173, 'flow-missing': 178,
    'flow-unregistered': 193, 'flow-two-owners': 195,
}


# Branch-to-input bindings are taken from the actual rejective statements in
# model/{select-ci-screens,ci-aggregate}.cjs. Each weakened condition is tested
# against its own conforming rejection input, never a bundle's first red cell.
AGG_GUARD_LINES = {
    'no-evidence-arg': 56, 'selected-invalid': 60, 'identity-missing': 64,
    'legacy-missing': 67, 'legacy-chosen-not-success': 71,
    'legacy-skip-no-reason': 72, 'matrix-malformed': 76,
    'matrix-mismatch': 80, 'matrix-duplicate': 80,
    'evidence-dir-missing': 85, 'evidence-extra': 86,
    'proof-id': 92, 'proof-status': 92, 'proof-artifact': 92,
    'proof-run': 92, 'proof-attempt': 92,
}
SELECTOR_GUARD_LINES = {
    'map-absent': 119, 'map-json': 62, 'map-schema': 63,
    'id-absent': 82, 'job-absent': 82, 'status-invalid': 83,
    'id-duplicate': 86, 'job-duplicate': 89, 'pack-duplicate': 93,
    'flow-duplicate': 96, 'pack-invalid': 101, 'registry-empty': 105,
    'screen-pack-absent': 415, 'screen-flows-absent': 415,
    'screen-port-small': 415, 'screen-port-odd': 415,
    'screen-port-reserved': 415, 'screen-port-duplicate': 422,
}


def guard_stub(source, line, selector=False):
    lines = source.splitlines(keepends=True)
    target = lines[line - 1]
    if selector and 'return { oshibka: label === "head"' in target:
        lines[line - 1] = target.replace(
            'return { oshibka: label === "head" ? "KARTA_OTSUTSTVUET" : null, net: true };',
            'return { zapisi: [], shared: [], sha: null, sluzhebnye: [] };')
    elif selector and 'return { oshibka:' in target and 'catch (e)' in target:
        lines[line - 1] = target.replace(
            'return { oshibka: "KARTA_NE_JSON", label };',
            'return { zapisi: [], shared: [], sha: "", sluzhebnye: [] };')
    elif selector and 'return { net: true,' in target:
        lines[line - 1] = target.replace('return { net: true,', 'return { net: false, zapisi: [],', 1)
    elif 'otkaz(' in target or 'fail(' in target:
        name = 'fail(' if selector else 'otkaz('
        lines[line - 1] = target.replace(name, 'weak_ok(', 1)
        lines.insert(15, 'function weak_ok() { process.stdout.write("CHILD_EVIDENCE_OK\\n"); process.exit(0); }\n'
                     if not selector else
                     'function weak_ok() { process.stdout.write("SELECTOR_OK\\n"); process.exit(0); }\n')
    elif 'if (' in target:
        # Parenthesise the complete JS condition: `false && a || b` is NOT
        # neutralisation when b is true (the identity guard has four fields).
        start = source.index(target) if source.count(target) == 1 else sum(len(s) for s in lines[:line - 1])
        ends = [source.index(mark, start) for mark in (') return ', ') {') if mark in source[start:]]
        end = min(ends) if ends else None
        if end is None:
            raise ValueError('GUARD_TERMINATOR_ABSENT: %d' % line)
        return source[:start] + source[start:end].replace('if (', 'if (false && (', 1) + ')' + source[end:]
    else:
        raise ValueError('GUARD_ANCHOR_ABSENT: %d %s' % (line, target.strip()))
    weak = ''.join(lines)
    if weak == source:
        raise ValueError('GUARD_NOT_MUTATED: %d' % line)
    return weak


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--model', action='store_true')
    group.add_argument('--stabs', action='store_true')
    group.add_argument('--repo', type=Path)
    parser.add_argument('--workflow-cell', help='One scoped --repo control-field mutation probe')
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
    if args.workflow_cell:
        if not args.repo:
            print('WORKFLOW_CELL_REQUIRES_REPO', file=sys.stderr)
            return 2
        hits = [(name, result) for name, result in workflow_controls(workflow, model_workflow())
                if name == args.workflow_cell]
        if len(hits) != 1:
            print('WORKFLOW_CELL_UNKNOWN: ' + args.workflow_cell, file=sys.stderr)
            return 2
        name, (ok, reason) = hits[0]
        print('КЛЕТКА %s %s%s' % (name, 'ЗЕЛЕНА' if ok else 'КРАСНА: ', '' if ok else reason))
        return 0 if ok else 1
    with tempfile.TemporaryDirectory(prefix='matrix-143-v3-') as t:
        tmp = Path(t)
        results = [(name, workflow_case(workflow, old, name)) for name in ('legacy', 'matrix', 'allocator', 'evidence', 'apk')]
        results.extend(workflow_controls(workflow, model_workflow()))
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
        for variant in SELECTOR_GUARDS:
            results.append(('selector-guard-' + variant, selector_guard_case(
                root, not args.repo, tmp / ('selector-guard-' + variant), variant)))
        for variant in INVENTORY_GUARDS:
            results.append(('inventory-guard-' + variant, inventory_guard_case(
                root, not args.repo, tmp / ('inventory-guard-' + variant), variant)))
        for variant in SELECTOR_ENTRY_GUARDS:
            results.append(('selector-entry-' + variant, selector_entry_guard_case(
                root, not args.repo, tmp / ('selector-entry-' + variant), variant)))
        results.append(('child-ok', evidence_case(root, not args.repo, tmp)))
        results.append(('child-missing', evidence_case(root, not args.repo, tmp / 'missing', missing=True)))
        results.append(('child-wrong-digest', evidence_case(root, not args.repo, tmp / 'wrong', bad_digest=True)))
        for parent_result in ('failure', 'cancelled', 'skipped', None):
            name = parent_result if parent_result is not None else 'absent'
            results.append(('child-parent-' + name, evidence_case(
                root, not args.repo, tmp / ('parent-' + name), parent_result=parent_result)))
        results.append(('child-matrix-output-absent',
                        evidence_case(root, not args.repo, tmp / 'matrix-output-absent',
                                      missing_matrix_output=True)))
        for variant in ('no-evidence-arg', 'selected-invalid', 'identity-missing',
                        'legacy-missing', 'legacy-chosen-not-success', 'legacy-skip-no-reason',
                        'matrix-malformed', 'matrix-mismatch', 'matrix-duplicate',
                        'evidence-dir-missing', 'evidence-extra', 'proof-id', 'proof-status',
                        'proof-artifact', 'proof-run', 'proof-attempt'):
            results.append(('guard-' + variant, evidence_case(
                root, not args.repo, tmp / ('guard-' + variant), variant=variant)))
        for variant in LEGACY_GUARDS:
            script = AGG_MODEL if not args.repo else root / 'mobile/scripts/ci-aggregate.cjs'
            results.append(('legacy-guard-' + variant, legacy_guard_case(
                tmp / ('legacy-guard-' + variant), script, variant)))
        results.append(('empty-matrix', empty_case(tmp, AGG_MODEL if not args.repo else root / 'mobile/scripts/ci-aggregate.cjs')))
        results.append(('empty-matrix-output-absent', empty_case(
            tmp / 'absent', AGG_MODEL if not args.repo else root / 'mobile/scripts/ci-aggregate.cjs',
            omit_matrix=True)))
        for parent_result in ('failure', 'cancelled', 'success', None):
            name = parent_result if parent_result is not None else 'absent'
            script = AGG_MODEL if not args.repo else root / 'mobile/scripts/ci-aggregate.cjs'
            results.append(('empty-parent-' + name, empty_parent_case(
                tmp / ('empty-parent-' + name), script, parent_result)))
        for name, (ok, reason) in results:
            print('КЛЕТКА %s %s%s' % (name, 'ЗЕЛЕНА' if ok else 'КРАСНА: ', '' if ok else reason))
        print('клеток %d, зелёных %d, красных %d' % (len(results), sum(ok for _, (ok, _) in results), sum(not ok for _, (ok, _) in results)))
        if any(not ok for _, (ok, _) in results):
            return 1
        if args.stabs:
            for name, reason in workflow_stabs(workflow, model_workflow()):
                print('СТАБ %s @ %s КРАСЕН: %s' % (name, name, reason))
            from connected_v3 import check as connected_check
            skipped = copy.deepcopy(workflow)
            skipped['jobs']['e2e-screen']['if'] = '${{ false }}'
            ok, reason = connected_check(skipped, demo_map())
            if ok or 'MATRIX_WORKER_SKIPPED' not in reason:
                print('STAB_ZHIV matrix-worker-never-runs @ connected: ' + reason)
                return 1
            print('СТАБ matrix-worker-never-runs @ connected КРАСЕН: ' + reason)
            # Independent frozen quality steps added later must not opt out.
            extended = copy.deepcopy(workflow)
            extended['jobs']['quality']['steps'].extend(
                {'name': 'Independent quality step %d' % index, 'run': 'exit 1'}
                for index in range(4))
            if any(not ok for _, (ok, _) in workflow_controls(extended, workflow)):
                print('WORKFLOW_EXTENSION_HONEST_RED', file=sys.stderr)
                return 2
            first_new = len(workflow['jobs']['quality']['steps'])
            for name, reason in workflow_stabs(extended, workflow):
                if (name.startswith('workflow-quality-') and '-step-' in name and
                        int(name.rsplit('-step-', 1)[1]) >= first_new):
                    print('СТАБ %s @ %s КРАСЕН: %s' % (name, name, reason))
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
                                       parent_result='failure', subject=parent_stub)
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
                                       parent_result='failure', subject=false_parent)
            if ok or 'MATRIX_PARENT_NOT_FAIL_CLOSED' not in reason:
                print('STAB_ZHIV aggregate-false-parent @ child-parent-failure: ' + reason)
                return 1
            print('СТАБ aggregate-false-parent @ child-parent-failure КРАСЕН: ' + reason)
            ok, reason = evidence_case(root, True, tmp / 'weak-parent-success', subject=false_parent)
            if not ok:
                print('STAB_NE_K_ETOMU_VHODU aggregate-false-parent @ child-ok: ' + reason)
                return 1
            # Each weakened guard accepts exactly one forbidden result.
            for parent_result in ('failure', 'cancelled', 'skipped', None):
                name = parent_result if parent_result is not None else 'absent'
                allowed = json.dumps(parent_result) if parent_result is not None else 'undefined'
                weak = tmp / ('aggregate-accept-' + name + '.cjs')
                weak.write_text(aggregate_source.replace(
                    parent_guard,
                    '  if (needs["e2e-screen"]?.result !== (chosen.length ? "success" : "skipped") && '
                    'needs["e2e-screen"]?.result !== ' + allowed + ') otkaz("MATRIX_PARENT_OTKAZ");\n'))
                ok, reason = evidence_case(root, True, tmp / ('weak-accept-parent-' + name),
                                           parent_result=parent_result, subject=weak)
                if ok or 'MATRIX_PARENT_NOT_FAIL_CLOSED' not in reason or 'CHILD_EVIDENCE_OK' not in reason:
                    print('STAB_ZHIV aggregate-accept-%s @ child-parent-%s: %s' % (name, name, reason))
                    return 1
                print('СТАБ aggregate-accept-%s @ child-parent-%s КРАСЕН: %s' % (name, name, reason))
            for parent_result in ('failure', 'cancelled', 'success', None):
                name = parent_result if parent_result is not None else 'absent'
                allowed = json.dumps(parent_result) if parent_result is not None else 'undefined'
                weak = tmp / ('aggregate-accept-empty-' + name + '.cjs')
                weak.write_text(aggregate_source.replace(
                    parent_guard,
                    '  if (needs["e2e-screen"]?.result !== (chosen.length ? "success" : "skipped") && '
                    'needs["e2e-screen"]?.result !== ' + allowed + ') otkaz("MATRIX_PARENT_OTKAZ");\n'))
                ok, reason = empty_parent_case(tmp / ('weak-empty-parent-' + name), weak, parent_result)
                if ok or 'CHILD_EVIDENCE_OK' not in reason:
                    print('STAB_ZHIV aggregate-accept-empty-%s @ empty-parent-%s: %s' % (name, name, reason))
                    return 1
                print('СТАБ aggregate-accept-empty-%s @ empty-parent-%s КРАСЕН: %s' % (name, name, reason))
            for variant, line in AGG_GUARD_LINES.items():
                weak = tmp / ('aggregate-guard-' + variant + '.cjs')
                weak.write_text(guard_stub(aggregate_source, line))
                ok, reason = evidence_case(root, True, tmp / ('weak-guard-' + variant),
                                           variant=variant, subject=weak)
                if ok:
                    print('STAB_ZHIV aggregate-guard-%s @ guard-%s: %s' % (variant, variant, reason))
                    return 1
                print('СТАБ aggregate-guard-%s @ guard-%s КРАСЕН: %s' % (variant, variant, reason))
            for variant, line in SELECTOR_GUARD_LINES.items():
                weak = tmp / ('selector-guard-' + variant + '.cjs')
                weak.write_text(guard_stub(source, line, selector=True))
                ok, reason = selector_guard_case(root, True, tmp / ('weak-selector-' + variant),
                                                 variant, subject=weak)
                if ok:
                    print('STAB_ZHIV selector-guard-%s @ selector-guard-%s: %s' % (variant, variant, reason))
                    return 1
                print('СТАБ selector-guard-%s @ selector-guard-%s КРАСЕН: %s' % (variant, variant, reason))
            weak = tmp / 'selector-map-missing-as-empty.cjs'
            weak.write_text(guard_stub(source, 112, selector=True))
            ok, reason = selector_guard_case(root, True, tmp / 'weak-selector-map-missing',
                                             'map-absent', subject=weak)
            if ok or 'rc=0' not in reason:
                print('STAB_ZHIV selector-map-missing-as-empty @ selector-guard-map-absent: ' + reason)
                return 1
            print('СТАБ selector-map-missing-as-empty @ selector-guard-map-absent КРАСЕН: ' + reason)
            for variant, line in LEGACY_GUARD_LINES.items():
                weak = tmp / ('legacy-guard-' + variant + '.cjs')
                weak.write_text(guard_stub(aggregate_source, line))
                ok, reason = legacy_guard_case(tmp / ('weak-legacy-' + variant), weak, variant)
                if ok:
                    print('STAB_ZHIV legacy-guard-%s @ legacy-guard-%s: %s' % (variant, variant, reason))
                    return 1
                print('СТАБ legacy-guard-%s @ legacy-guard-%s КРАСЕН: %s' % (variant, variant, reason))
            for variant, line in INVENTORY_GUARD_LINES.items():
                weak = tmp / ('inventory-guard-' + variant + '.cjs')
                weak.write_text(guard_stub(source, line, selector=True))
                ok, reason = inventory_guard_case(root, True, tmp / ('weak-inventory-' + variant),
                                                  variant, subject=weak)
                if ok:
                    print('STAB_ZHIV inventory-guard-%s @ inventory-guard-%s: %s' % (variant, variant, reason))
                    return 1
                print('СТАБ inventory-guard-%s @ inventory-guard-%s КРАСЕН: %s' % (variant, variant, reason))
            for variant, line in SELECTOR_ENTRY_LINES.items():
                weak = tmp / ('selector-entry-' + variant + '.cjs')
                weak.write_text(guard_stub(source, line, selector=True))
                ok, reason = selector_entry_guard_case(root, True, tmp / ('weak-selector-entry-' + variant),
                                                       variant, subject=weak)
                if ok:
                    print('STAB_ZHIV selector-entry-%s @ selector-entry-%s: %s' % (variant, variant, reason))
                    return 1
                print('СТАБ selector-entry-%s @ selector-entry-%s КРАСЕН: %s' % (variant, variant, reason))
            from workflow_sweep_v3 import controls, root_controls
            control_count = len(controls(model_workflow())) + len(root_controls(model_workflow(), workflow))
            extension_count = 8
            print('стабов %d, привязок %d, живых 0' % (
                len(STUBS) + 25 + len(AGG_GUARD_LINES) + len(SELECTOR_GUARD_LINES) + len(LEGACY_GUARD_LINES) + len(INVENTORY_GUARD_LINES) + len(SELECTOR_ENTRY_LINES) + control_count + extension_count,
                len(STUBS) + 32 + len(AGG_GUARD_LINES) + len(SELECTOR_GUARD_LINES) + len(LEGACY_GUARD_LINES) + len(INVENTORY_GUARD_LINES) + len(SELECTOR_ENTRY_LINES) + control_count + extension_count))
        return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, IndexError, subprocess.TimeoutExpired) as exc:
        print('MATRIX_INFRASTRUCTURE: ' + str(exc), file=sys.stderr)
        sys.exit(2)
