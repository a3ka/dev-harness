"""Live-tree structural counterexamples for compare_carriers --matrix.

These model only permitted workflow deltas, not a delivered evidence checker.
The comparator never executes model shell. Operational replay remains separate.
Each independent mutation is paired with its exact observable diagnosis here.
"""
from copy import deepcopy
import yaml

from compare_carriers import (
    MOBILE, CLOUD, PINS, EXISTING, NATIVE, ARTIFACTS, DISK_SPACE, parse, outcome,
)


def dump(obj):
    return yaml.safe_dump(obj, allow_unicode=True, sort_keys=False).encode()


def job(tree, path=MOBILE):
    workflow = parse(tree[path])
    name = 'android-e2e' if path == MOBILE else 'android-e2e-cloud'
    return workflow, workflow['jobs'][name]


def honest(base, phase, pins):
    candidate = dict(base)
    for path in (MOBILE, CLOUD):
        if phase == 'negative' and path == CLOUD:
            continue
        workflow, native = job(candidate, path)
        if phase in ('negative', 'freeze'):
            native['steps'].append({
                'name': 'Release APK', 'uses': 'actions/upload-artifact@v7',
                'if': 'always()', 'with': {
                    'name': 'apk-${{ github.sha }}-${{ github.run_id }}-${{ github.run_attempt }}',
                    'path': 'mobile/android/app/build/outputs/apk/release/app-release.apk',
                    'if-no-files-found': 'error', 'retention-days': 14,
                },
            })
        if phase == 'freeze':
            for step in native['steps']:
                if step.get('name') == ARTIFACTS:
                    step['with']['name'] = 'maestro-${{ github.sha }}-${{ github.run_id }}-${{ github.run_attempt }}'
                    step['with']['if-no-files-found'] = 'error'
                if path == CLOUD and step.get('name') == 'Maestro':
                    step['run'] = 'curl -fsSL https://get.maestro.mobile.dev | MAESTRO_VERSION=2.11.0 bash\necho "$HOME/.maestro/bin" >> "$GITHUB_PATH"\n'
            native['steps'].append({
                'id': 'rehearsal_version', 'name': 'Check Maestro version',
                'run': 'test "$(maestro --version)" = "2.11.0"',
            })
        if phase == 'positive':
            if path == CLOUD:
                index = next(i for i, step in enumerate(native['steps']) if step.get('name') == NATIVE)
                native['steps'].insert(index, deepcopy(DISK_SPACE))
            native['steps'].append({
                'id': 'rehearsal_evidence', 'name': 'Check rehearsal evidence',
                'run': 'bash scripts/rehearsal-evidence.sh',
            })
        candidate[path] = dump(workflow)
    if phase in ('negative', 'positive'):
        candidate['mobile/.maestro/rehearsal.yaml'] = pins['mobile/.maestro/rehearsal.yaml']
    if phase == 'positive':
        candidate.update(pins)
        # Merely a structural model: replay, not this comparator, judges the body.
        candidate['mobile/scripts/rehearsal-evidence.sh'] = b'test -s maestro-out/rehearsal-before.png\ntest -s maestro-out/rehearsal-after.png\n'
    return candidate


def run_matrix(base, pins, base_sha):
    frozen = honest(base, 'freeze', pins)
    positive = honest(frozen, 'positive', pins)
    rows = []

    def add(label, b, c, phase, rc, reason):
        rows.append((label, b, c, phase, rc, reason))

    for phase in ('negative', 'freeze', 'positive'):
        b = frozen if phase == 'positive' else base
        add('honest-' + phase, b, honest(b, phase, pins), phase, 0, 'ACCEPTED')

    def mutate(label, path, change, reason, phase='positive', b=None, source=None):
        b = frozen if b is None else b
        c = dict(positive if source is None else source)
        obj = parse(c[path])
        change(obj)
        c[path] = dump(obj)
        add(label, b, c, phase, 1, reason)

    quality_reason = f'CARRIER_CHANGED: {MOBILE}:quality:whole-job'
    native_steps = parse(positive[MOBILE])['jobs']['android-e2e']['steps']
    native_index = next(i for i, s in enumerate(native_steps) if s.get('name') == NATIVE)
    evidence_index = next(i for i, s in enumerate(native_steps) if s.get('id') == 'rehearsal_evidence')
    cloud_steps = parse(positive[CLOUD])['jobs']['android-e2e-cloud']['steps']
    cloud_index = next(i for i, s in enumerate(cloud_steps) if s.get('name') == NATIVE)
    disk_index = next(i for i, s in enumerate(cloud_steps) if s.get('id') == 'rehearsal_disk_space')
    disk_reason = f'CARRIER_CHANGED: {CLOUD}:android-e2e-cloud:steps[{disk_index}]'

    def disk_steps(obj):
        return obj['jobs']['android-e2e-cloud']['steps']

    mutate('Ds5-missing', CLOUD, lambda o: disk_steps(o).pop(disk_index),
           f'CARRIER_CHANGED: {CLOUD}:android-e2e-cloud:missing-Ds5')
    mutate('Ds5-duplicate', CLOUD,
           lambda o: disk_steps(o).insert(disk_index + 1, deepcopy(DISK_SPACE)),
           f'CARRIER_CHANGED: {CLOUD}:android-e2e-cloud:steps[{disk_index + 1}]')
    for key, value in DISK_SPACE.items():
        mutate('Ds5-changed-' + key, CLOUD,
               lambda o, k=key, v=value: disk_steps(o)[disk_index].update({k: v + '\\n'}),
               disk_reason)
        mutate('Ds5-missing-' + key, CLOUD,
               lambda o, k=key: disk_steps(o)[disk_index].pop(k), disk_reason)
    for key, value in (('if', 'always()'), ('continue-on-error', False),
                       ('env', {}), ('uses', 'actions/checkout@v4')):
        mutate('Ds5-extra-' + key, CLOUD,
               lambda o, k=key, v=value: disk_steps(o)[disk_index].update({k: v}),
               disk_reason)
    for position in range(len(cloud_steps)):
        if position == disk_index:
            continue

        def move_disk(obj, target=position):
            steps = disk_steps(obj)
            steps.insert(target, steps.pop(disk_index))

        mutate(f'Ds5-position-{position}', CLOUD, move_disk,
               f'CARRIER_CHANGED: {CLOUD}:android-e2e-cloud:steps[{position}]')
    mutate('Ds5-wrong-workflow', MOBILE,
           lambda o: o['jobs']['android-e2e']['steps'].insert(native_index, deepcopy(DISK_SPACE)),
           f'CARRIER_CHANGED: {MOBILE}:android-e2e:steps[{native_index}]')
    mutate('Ds5-wrong-job', CLOUD,
           lambda o: o['jobs']['expo-versions']['steps'].append(deepcopy(DISK_SPACE)),
           f'CARRIER_CHANGED: {CLOUD}:expo-versions:whole-job')
    for phase in ('negative', 'freeze'):
        source = honest(base, phase, pins)
        steps = parse(source[CLOUD])['jobs']['android-e2e-cloud']['steps']
        index = next(i for i, s in enumerate(steps) if s.get('name') == NATIVE)
        mutate('Ds5-wrong-phase-' + phase, CLOUD,
               lambda o, i=index: disk_steps(o).insert(i, deepcopy(DISK_SPACE)),
               f'CARRIER_CHANGED: {CLOUD}:android-e2e-cloud:steps[{index}]',
               phase, base, source)

    def quality_test(obj):
        return next(s for s in obj['jobs']['quality']['steps'] if s.get('run') == 'npm test')

    mutate('run-ignore-pattern', MOBILE, lambda o: quality_test(o).update(run='npm test -- --testPathIgnorePatterns=rehearsal'), quality_reason)
    for key, value in (('continue-on-error', True), ('if', 'false')):
        mutate('existing-step-' + key, MOBILE, lambda o, k=key, v=value: quality_test(o).update({k: v}), quality_reason)
        mutate('job-' + key, MOBILE, lambda o, k=key, v=value: o['jobs']['android-e2e'].update({k: v}), f'CARRIER_CHANGED: {MOBILE}:android-e2e:keys')
    mutate('pre-native-step', MOBILE, lambda o: o['jobs']['android-e2e']['steps'].insert(native_index, {'run': 'rm .maestro/start.yaml'}), f'CARRIER_CHANGED: {MOBILE}:android-e2e:steps[{native_index}]')
    mutate('new-quality-forged-log', MOBILE, lambda o: o['jobs']['quality']['steps'].insert(3, {'run': 'rm src/features/start/__tests__/rehearsal.test.tsx; echo "PASS src/features/start/__tests__/rehearsal.test.tsx"'}), quality_reason)

    c = dict(positive)
    script = 'mobile/scripts/ci-e2e.sh'
    if b'.maestro' not in c[script]:
        raise ValueError('matrix input does not contain the real .maestro invocation')
    c[script] = c[script].replace(b'.maestro', b'.maestro/rehearsal.yaml')
    add('station-flow-directory', frozen, c, 'positive', 1, f'EXISTING_CHECK_CHANGED: {script}')

    def cloud_directory(obj):
        native = obj['jobs']['android-e2e-cloud']['steps'][cloud_index]
        native['with']['script'] = native['with']['script'].replace('.maestro', '.maestro/rehearsal.yaml')

    mutate('cloud-flow-directory', CLOUD, cloud_directory, f'CARRIER_CHANGED: {CLOUD}:android-e2e-cloud:steps[{cloud_index}]')
    mutate('trigger-filter', MOBILE, lambda o: o['on']['push'].update({'paths-ignore': ['mobile/**']}), f'CARRIER_CHANGED: {MOBILE}:top:keys')
    for key, value in (('continue-on-error', True), ('if', 'always()')):
        mutate('evidence-' + key, MOBILE, lambda o, k=key, v=value: o['jobs']['android-e2e']['steps'][evidence_index].update({k: v}), f'CARRIER_CHANGED: {MOBILE}:android-e2e:steps[{evidence_index}]')
    mutate('unknown-post-native-step', MOBILE, lambda o: o['jobs']['android-e2e']['steps'].append({'run': 'true'}), f'CARRIER_CHANGED: {MOBILE}:android-e2e:steps[{len(native_steps)}]')
    mutate('duplicate-evidence-step', MOBILE, lambda o: o['jobs']['android-e2e']['steps'].append(deepcopy(o['jobs']['android-e2e']['steps'][evidence_index])), f'CARRIER_CHANGED: {MOBILE}:android-e2e:steps[{len(native_steps)}]')
    mutate('new-job', MOBILE, lambda o: o['jobs'].update(extra={'steps': []}), f'CARRIER_CHANGED: {MOBILE}:jobs:set')
    mutate('top-env', MOBILE, lambda o: o.update(env={'NODE_OPTIONS': '--require ./ignore.js'}), f'CARRIER_CHANGED: {MOBILE}:top:keys')
    mutate('boolean-number-alias', MOBILE, lambda o: o['jobs']['quality']['steps'][0]['with'].update({'persist-credentials': 0}), quality_reason)

    negative = honest(base, 'negative', pins)
    nw, nj = job(negative)
    ni = len(nj['steps']) - 1
    mutate('apk-soft-failure', MOBILE, lambda o: o['jobs']['android-e2e']['steps'][-1]['with'].update({'if-no-files-found': 'warn'}), f'CARRIER_CHANGED: {MOBILE}:android-e2e:steps[{ni}]', 'negative', base, negative)
    mutate('negative-cloud-change', CLOUD, lambda o: o['jobs']['android-e2e-cloud']['steps'].append({'id': 'rehearsal_version', 'run': 'maestro --version'}), f'CARRIER_CHANGED: {CLOUD}:android-e2e-cloud:steps[{len(parse(base[CLOUD])['jobs']['android-e2e-cloud']['steps'])}]', 'negative', base, negative)

    for path, (_, reason) in PINS.items():
        c = dict(positive)
        c[path] += b'\n# changed\n'
        add('pin-' + reason, frozen, c, 'positive', 1, reason)
    c = dict(positive)
    c['mobile/package.json'] = b'{}'
    add('outside-zone', frozen, c, 'positive', 1, 'PR_ZONE_VIOLATION: mobile/package.json')
    c = dict(positive)
    c['mobile/scripts/unreferenced.sh'] = b'exit 0\n'
    add('unused-new-script', frozen, c, 'positive', 1, 'NEW_SCRIPT_NOT_REFERENCED: mobile/scripts/unreferenced.sh')
    # The four P2 predicates overlap: an out-of-zone old-test edit is rejected
    # first by P2(1), not falsely claimed as a P2(2) witness (N-39).
    c = dict(positive)
    c[EXISTING[0]] += b'\n'
    add('old-test-outside-zone', frozen, c, 'positive', 1, 'PR_ZONE_VIOLATION: ' + EXISTING[0])
    for label, content in (('malformed-yaml', b'jobs: [\n'), ('duplicate-yaml-key', b'jobs: {}\njobs: {}\n')):
        c = dict(positive)
        c[MOBILE] = content
        add(label, frozen, c, 'positive', 2, 'UNREADABLE_INPUT:')
    c = dict(positive)
    del c[CLOUD]
    add('missing-workflow', frozen, c, 'positive', 2, 'UNREADABLE_INPUT: missing blob: ' + CLOUD)

    failures = 0
    for label, b, c, phase, expected_rc, expected_reason in rows:
        changed = {p for p in b.keys() | c.keys() if b.get(p) != c.get(p)}
        rc, reason = outcome(b, c, changed, phase, pins)
        matches = reason.startswith(expected_reason) if expected_reason == 'UNREADABLE_INPUT:' else reason == expected_reason
        failures += int(rc != expected_rc or not matches)
        print(f'991 carriers/{label}: rc={rc} expected={expected_rc} reason={reason}', flush=True)
    print(f'991 carriers matrix base={base_sha} executed={len(rows)} mismatches={failures}')
    return int(failures != 0 or not rows)
