"""143: independently mutable workflow control fields; never use product disk as oracle.

Legacy e2e-* jobs are I-15 byte-preserved, already covered by workflow_case
('legacy'). The remaining jobs are compared against the architect model's
control values. New screen workers may extend select-screens.outputs; the
existing output names and the matrix producer are still mandatory.
"""

import copy
import fnmatch

JOBS = ('select-screens', 'quality', 'build-apk', 'e2e-screen',
        'android-e2e', 'mobile-regression-signal')
FIELDS = ('if', 'needs', 'strategy', 'runs-on', 'continue-on-error',
          'timeout-minutes', 'outputs', 'permissions', 'concurrency', 'env')
# Independent 151/995/117 quality steps may legally enter after the 143
# model: judge their opt-out flags, not their frozen run bodies. New screen
# outputs can be added without changing the generic selection writer.
QUALITY_RUNS = (1, 3, 6)
ABSENT = object()

# Root/on sweep: the honest product and the frozen model agree on these
# controls. Optional PR branch/type filters are judged by whether main PRs
# still receive the required check, not by an incidental spelling of YAML.
ROOT_FIELDS = ('name', 'on', 'permissions', 'concurrency', 'defaults', 'jobs', 'env')
EVENTS = ('pull_request', 'push', 'schedule', 'workflow_dispatch')
EVENT_FILTERS = {
    'pull_request': ('branches', 'branches-ignore', 'paths', 'paths-ignore', 'types'),
    'push': ('branches', 'branches-ignore', 'paths', 'paths-ignore', 'tags', 'tags-ignore'),
}
REQUIRED_PR_TYPES = frozenset(('opened', 'synchronize', 'reopened'))


def on_key(wf):
    # PyYAML's YAML 1.1 parser resolves unquoted `on` to the boolean True.
    return True if True in wf else 'on'


def root_controls():
    return (tuple(('root', field, None) for field in ROOT_FIELDS) +
            tuple(('on', event, None) for event in EVENTS) +
            tuple(('on', event, field) for event, fields in EVENT_FILTERS.items()
                  for field in fields))


def root_value(wf, row):
    where, field, subfield = row
    if where == 'root':
        return wf.get(on_key(wf) if field == 'on' else field, ABSENT)
    trigger = wf.get(on_key(wf), {})
    if not isinstance(trigger, dict):
        return ABSENT
    event = trigger.get(field, ABSENT)
    if subfield is None:
        return event
    return event.get(subfield, ABSENT) if isinstance(event, dict) else ABSENT

def includes_main(patterns):
    if not isinstance(patterns, list) or not patterns:
        return False
    included = False
    for pattern in patterns:
        if not isinstance(pattern, str):
            return False
        if fnmatch.fnmatchcase('main', pattern.lstrip('!')):
            included = not pattern.startswith('!')
    return included


def root_match(wf, model, row):
    where, field, subfield = row
    actual = root_value(wf, row)
    expected = root_value(model, row)
    if where == 'root' and field == 'jobs':
        return isinstance(actual, dict) and all(name in actual
                                                for name in expected)
    if where == 'root' and field == 'on':
        return isinstance(actual, dict) and set(actual) == set(expected)
    if where == 'on' and subfield is None:
        if field == 'pull_request':
            return actual is None or (isinstance(actual, dict) and
                   set(actual).issubset(EVENT_FILTERS[field]))
        if field == 'push':
            return isinstance(actual, dict) and set(actual).issubset(EVENT_FILTERS[field])
        return actual == expected if actual is not ABSENT and expected is not ABSENT else actual is expected
    if where == 'on' and field == 'pull_request':
        if subfield == 'branches':
            return actual is ABSENT or includes_main(actual)
        if subfield == 'types':
            return actual is ABSENT or (isinstance(actual, list) and
                   REQUIRED_PR_TYPES.issubset(actual) and
                   all(isinstance(v, str) for v in actual))
        return actual is ABSENT
    return actual == expected if actual is not ABSENT and expected is not ABSENT else actual is expected


def mutate_root(wf, model, row):
    where, field, subfield = row
    if where == 'root':
        key = on_key(wf) if field == 'on' else field
        if field == 'env':
            wf[key] = {'BASH_ENV': '/tmp/skip-required'}
        elif field == 'name':
            wf[key] = 'unprotected-mobile'
        else:
            wf.pop(key, None)
    else:
        events = wf[on_key(wf)]
        if subfield is None:
            events.pop(field, None)
        else:
            if events.get(field) is None:
                events[field] = {}
            options = events[field]
            if subfield == 'branches':
                options[subfield] = ['release']
            elif subfield == 'types':
                options[subfield] = ['labeled']
            elif subfield == 'paths':
                options[subfield] = ['mobile/**']
            elif subfield == 'paths-ignore':
                options[subfield] = ['mobile/**']
            elif subfield == 'branches-ignore':
                # GitHub forbids branches + branches-ignore in one push event.
                options.pop('branches', None)
                options[subfield] = ['main']
            else:
                options[subfield] = ['v*']
    if root_match(wf, model, row):
        raise ValueError('WORKFLOW_MUTATION_NOT_OBSERVABLE: ' + root_name(row))
    return wf


def root_name(row):
    return 'workflow-' + '-'.join(str(value) for value in row if value is not None)


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
    return ([(root_name(row), (root_match(wf, model, row),
              'WORKFLOW_CONTROL_%s' % root_name(row))) for row in root_controls()] +
            [(name_of(row), (match(wf, model, row),
              'WORKFLOW_CONTROL_%s' % name_of(row))) for row in controls(model, wf)])


def stabs(wf, model):
    for row in root_controls():
        weak = mutate_root(copy.deepcopy(wf), model, row)
        if root_match(weak, model, row):
            raise ValueError('STAB_ZHIV: ' + root_name(row))
        yield root_name(row), 'WORKFLOW_CONTROL_' + root_name(row)
    for row in controls(model, wf):
        weak = mutate(copy.deepcopy(wf), model, row)
        if match(weak, model, row):
            raise ValueError('STAB_ZHIV: ' + name_of(row))
        yield name_of(row), 'WORKFLOW_CONTROL_' + name_of(row)
