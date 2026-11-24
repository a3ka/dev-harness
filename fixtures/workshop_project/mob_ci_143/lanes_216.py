"""143 v6: five bounded npm forms, never a general shell/JS parser.

The immutable 216 baseline is the single source of inline bodies. Compare
canonical route/dispatcher/child bytes BEFORE projecting into the existing
143 checks. Invalid lanes remain npm calls and therefore cannot inherit an
inline body's guarantees. Selector-output additionally executes actual npm.
"""
import copy
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASELINE = HERE / 'nositeli/lanes-216.json'
# Original .harness/fixtures/mob_ci_revizija_216/baseline.json at fa6678d216.
BASELINE_SHA = 'e502c44d93bd93e090ba4e2be80462bfc753a961af10dd0efc310f37b8831511'
LANES = ('node-version', 'build-identity', 'select-screens', 'selection-outputs', 'inventar')
ENV = {'EVENT_NAME': '${{ github.event_name }}',
       'PR_BASE_SHA': '${{ github.event.pull_request.base.sha }}',
       'PR_HEAD_SHA': '${{ github.event.pull_request.head.sha }}',
       'PR_NUMBER': '${{ github.event.pull_request.number }}',
       'PUSH_BASE_SHA': '${{ github.event.before }}', 'HEAD_SHA': '${{ github.sha }}',
       'GROUP_BASE_SHA': '${{ github.event.merge_group.base_sha }}',
       'GROUP_HEAD_SHA': '${{ github.event.merge_group.head_sha }}'}
EXPRESSIONS = {v: '${' + k + '}' for k, v in ENV.items()}
EXPRESSIONS.update({'${{ github.sha }}': '${GITHUB_SHA}',
                    '${{ github.run_id }}': '${GITHUB_RUN_ID}',
                    '${{ github.run_attempt }}': '${GITHUB_RUN_ATTEMPT}'})


def oracle():
    raw = BASELINE.read_bytes()
    if hashlib.sha256(raw).hexdigest() != BASELINE_SHA:
        raise ValueError('ORACLE_TAMPERED: lanes-216')
    return json.loads(raw)


def child_body(body):
    for expression, variable in EXPRESSIONS.items():
        body = body.replace(expression, variable)
    return body.replace('/tmp/dev-harness-verify', '${TMPDIR}/dev-harness-verify')


def scripts(data):
    registry = {x: 'ci-' + x + '.sh' for x in LANES}
    files = {'ci-' + x + '.sh': '#!/usr/bin/env bash\nset -euo pipefail\n' +
             child_body(data['bodies'][x]) + '\n' for x in LANES}
    files['run-mobile-ci.cjs'] = ('const {spawnSync}=require("child_process"); const path=require("path");\n'
        'const lanes=' + json.dumps(registry) + ';\n'
        'const lane=process.argv[3]; if(process.argv.length!==4 || process.argv[2]!=="--lane" || !Object.hasOwn(lanes,lane)) process.exit(1);\n'
        'const r=spawnSync("bash",[path.join(__dirname,lanes[lane])],{cwd:path.resolve(__dirname,"../.."),stdio:"inherit"}); process.exit(r.status===null?1:r.status);\n')
    return files


def shell_equivalent(actual, expected):
    # Both accepted preambles enable precisely the same bash options. The
    # remaining bytes must equal the canon; comments/substrings are not proof.
    return actual.rstrip('\n') in (expected.rstrip('\n'),
        expected.replace('set -euo pipefail\n', 'set -eu\nset -o pipefail\n', 1).rstrip('\n'))


def operation(data, lane):
    job = {'node-version': 'build-apk', 'build-identity': 'build-apk',
           'select-screens': 'select-screens', 'selection-outputs': 'select-screens',
           'inventar': 'quality'}[lane]
    index, step = next((i, s) for i, s in enumerate(data['workflow']['jobs'][job]['steps'])
                       if s.get('run') == data['bodies'][lane])
    return job, index, step


def valid(root, step, lane, data=None):
    data = oracle() if data is None else data
    _, _, original = operation(data, lane)
    if (step.get('name') != original.get('name') or
            step.get('id') != original.get('id')):
        return False
    if (step.get('run', '').strip() != 'npm run ci:' + lane or
            step.get('working-directory') != '${{ github.workspace }}' or
            step.get('env', {}) != (ENV if lane == 'select-screens' else {})):
        return False
    try:
        package = json.loads((Path(root) / 'package.json').read_text())
        routes = package['scripts']
        if (routes.get('ci:' + lane) != 'node mobile/scripts/run-mobile-ci.cjs --lane ' + lane or
                any(x + 'ci:' + lane in routes for x in ('pre', 'post'))):
            return False
        expected = scripts(data)
        directory = Path(root) / 'mobile/scripts'
        if (directory / 'run-mobile-ci.cjs').read_text().rstrip('\n') != expected['run-mobile-ci.cjs'].rstrip('\n'):
            return False
        name = 'ci-' + lane + '.sh'
        return shell_equivalent((directory / name).read_text(), expected[name])
    except (OSError, ValueError, KeyError, TypeError):
        return False


def project(workflow, root, model=None):
    """Preserve every YAML field except a proven lane's run/env equivalence.

    For sweep use the existing independent epoch model's run bytes, not the
    subject or a new whole-workflow baseline. Other cells see 216's inline
    body. No legacy worker or unrelated quality body is changed.
    """
    data = oracle()  # In memory before any subject bytes.
    result = copy.deepcopy(workflow)
    for job, body in result.get('jobs', {}).items():
        for index, step in enumerate(body.get('steps', [])):
            for lane in LANES:
                expected_job, expected_index, _ = operation(data, lane)
                if (job == expected_job and (lane == 'inventar' or index == expected_index)
                        and valid(root, step, lane, data)):
                    step['run'] = data['bodies'][lane]
                    if model is not None:
                        expected = model.get('jobs', {}).get(job, {}).get('steps', [])
                        if index < len(expected):
                            step['run'] = expected[index].get('run', step['run'])
                    # ENV is solely the literal transport of expressions in the
                    # canonical body; it has already been checked in full.
                    if lane == 'select-screens':
                        step.pop('env', None)
                    break
    return result


def install(root, workflow):
    """Construct honest lane controls from the same pinned source as 216."""
    data = oracle()
    directory = Path(root) / 'mobile/scripts'
    directory.mkdir(parents=True, exist_ok=True)
    for name, content in scripts(data).items():
        (directory / name).write_text(content)
    package = Path(root) / 'package.json'
    p = json.loads(package.read_text()) if package.exists() else {'scripts': {}}
    p.setdefault('scripts', {}).update({'ci:' + x: 'node mobile/scripts/run-mobile-ci.cjs --lane ' + x for x in LANES})
    package.write_text(json.dumps(p))
    for lane in LANES:
        job, _, original = operation(data, lane)
        target = next(s for s in workflow['jobs'][job]['steps'] if s.get('name') == original['name'])
        target['run'] = 'npm run ci:' + lane
        target['working-directory'] = '${{ github.workspace }}'
        if lane == 'select-screens':
            target['env'] = dict(ENV)
    return workflow
