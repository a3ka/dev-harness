"""143: independently mutable workflow control fields; never use product disk as oracle.

Legacy e2e-* jobs are I-15 byte-preserved, already covered by workflow_case
('legacy'). The remaining jobs are compared against the architect model's
control values. New screen workers may extend select-screens.outputs; the
existing output names and the matrix producer are still mandatory.
"""

import copy

JOBS = ('select-screens', 'quality', 'build-apk', 'e2e-screen',
        'android-e2e', 'mobile-regression-signal')
FIELDS = ('if', 'needs', 'strategy', 'runs-on', 'continue-on-error',
          'timeout-minutes', 'outputs', 'permissions', 'concurrency', 'env')
# Independent 151/995/117 quality steps may legally enter after the 143
# model: judge their opt-out flags, not their frozen run bodies. New screen
# outputs can be added without changing the generic selection writer.
QUALITY_RUNS = (1, 3, 6)
ABSENT = object()


def aggregate_run(text):
    # The legitimate empty-matrix mkdir was added by the product after the
    # frozen model; remove exactly that single operation, never arbitrary code.
    if not isinstance(text, str):
        return text
    commands = [line for line in text.splitlines() if not line.lstrip().startswith('#')]
    mkdir = 'mkdir -p mobile/screen-evidence-collected'
    if commands.count(mkdir) == 1:
        commands.remove(mkdir)
    return '\n'.join(commands)


def controls(model, subject=None):
    """Enumerate model fields, plus flags of later independently owned steps."""
    rows = []
    for job in JOBS:
        body = model['jobs'][job]
        for field in FIELDS:
            if field in ('needs', 'outputs') and field not in body:
                # Absence -> [] / {} is a no-op, not a valid counterexample.
                continue
            rows.append((job, field, None))
        for index, step in enumerate(body.get('steps', [])):
            for field in ('if', 'continue-on-error'):
                rows.append((job, field, index))
            if 'run' in step and (job != 'quality' or index in QUALITY_RUNS):
                rows.append((job, 'run', index))
        if subject is not None:
            actual = subject.get('jobs', {}).get(job, {}).get('steps', [])
            for index in range(len(body.get('steps', [])), len(actual)):
                for field in ('if', 'continue-on-error'):
                    rows.append((job, field, index))
    return tuple(rows)


def name_of(row):
    job, field, index = row
    return 'workflow-%s-%s%s' % (job, field, '' if index is None else '-step-%d' % index)


def value(wf, row):
    job, field, index = row
    body = wf.get('jobs', {}).get(job, {})
    if index is None:
        return body.get(field, ABSENT)
    steps = body.get('steps', [])
    if len(steps) <= index:
        return ABSENT
    return steps[index].get(field, ABSENT)


def match(wf, model, row):
    expected = value(model, row)
    actual = value(wf, row)
    # The producer has a growing worker inventory, but its existing outputs
    # are never allowed to disappear or change their source.
    if row == ('select-screens', 'outputs', None):
        return isinstance(actual, dict) and all(actual.get(k, ABSENT) == v
                                                    for k, v in expected.items())
    if row[0] in ('android-e2e', 'mobile-regression-signal') and row[1] == 'run' and row[2] is not None:
        return aggregate_run(actual) == aggregate_run(expected)
    return actual == expected if actual is not ABSENT and expected is not ABSENT else actual is expected


def mutate(wf, model, row):
    """Exactly one field per test; a mutation must differ from the model."""
    job, field, index = row
    body = wf['jobs'][job] if index is None else wf['jobs'][job]['steps'][index]
    current = value(model, row)
    if field == 'if':
        body[field] = '${{ false }}' if current != '${{ false }}' else '${{ true }}'
    elif field == 'needs':
        body[field] = []
    elif field == 'strategy':
        body[field] = {'matrix': '${{ fromJSON(needs.build-apk.outputs.matrix) }}'}
    elif field == 'continue-on-error':
        body[field] = True
    elif field == 'runs-on':
        body[field] = ['ubuntu-latest']
    elif field == 'timeout-minutes':
        body[field] = 1 if current != 1 else 2
    elif field == 'outputs':
        body[field] = {}  # sever the producer-to-needs edge
    elif field == 'permissions':
        body[field] = {'contents': 'write'}
    elif field == 'concurrency':
        body[field] = {'group': 'all-mobile', 'cancel-in-progress': True}
    elif field == 'env':
        body[field] = {'CI': 'false'}
    elif field == 'run':
        body[field] = 'echo skipped-critical-step'
    else:
        raise ValueError('WORKFLOW_FIELD_UNKNOWN: ' + field)
    if match(wf, model, row):
        raise ValueError('WORKFLOW_MUTATION_NOT_OBSERVABLE: ' + name_of(row))
    return wf


def check(wf, model):
    return [(name_of(row), (match(wf, model, row),
             'WORKFLOW_CONTROL_%s' % name_of(row))) for row in controls(model, wf)]


def stabs(wf, model):
    for row in controls(model, wf):
        weak = mutate(copy.deepcopy(wf), model, row)
        if match(weak, model, row):
            raise ValueError('STAB_ZHIV: ' + name_of(row))
        yield name_of(row), 'WORKFLOW_CONTROL_' + name_of(row)
