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

# Workflow root controls are discovered from both YAML trees, not from a
# hand-maintained list of currently present fields. The explicit optional
# fields below also prevent an absent but dangerous control from escaping the
# sweep. The model is the independent expectation; the subject only supplies
# additional paths that must be considered.
ROOT_FIELDS = ('name', 'on', 'permissions', 'concurrency', 'defaults',
               'jobs', 'env', 'run-name')
EVENTS = ('pull_request', 'push', 'schedule', 'workflow_dispatch')
EVENT_FILTERS = {
    'pull_request': ('branches', 'branches-ignore', 'paths', 'paths-ignore', 'types'),
    'push': ('branches', 'branches-ignore', 'paths', 'paths-ignore', 'tags', 'tags-ignore'),
}
PERMISSION_SCOPES = ('actions', 'attestations', 'checks', 'contents', 'deployments',
                     'discussions', 'id-token', 'issues', 'models', 'packages',
                     'pages', 'pull-requests', 'repository-projects',
                     'security-events', 'statuses')
REQUIRED_PR_TYPES = frozenset(('opened', 'synchronize', 'reopened'))


def on_key(wf):
    # PyYAML's YAML 1.1 parser resolves unquoted `on` to the boolean True.
    return True if True in wf else 'on'


def root_value(wf, row):
    where, *parts = row
    value = wf
    for index, part in enumerate(parts):
        key = on_key(wf) if index == 0 and (where == 'on' or part == 'on') else part
        if where == 'on' and index == 0:
            value = wf.get(on_key(wf), ABSENT)
            key = part
        if isinstance(value, dict):
            value = value.get(key, ABSENT)
        elif isinstance(value, list) and isinstance(key, int) and key < len(value):
            value = value[key]
        else:
            return ABSENT
    return value


def _paths(value, prefix):
    if isinstance(value, dict):
        for key, child in value.items():
            path = prefix + (key,)
            yield path
            yield from _paths(child, path)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            path = prefix + (index,)
            yield path
            yield from _paths(child, path)


def root_controls(model=None, subject=None):
    roots = set(ROOT_FIELDS)
    for wf in (model, subject):
        if isinstance(wf, dict):
            roots.update('on' if key is True else key for key in wf)
    rows = [('root', key) for key in sorted(roots, key=str)]
    rows += [('on', event) for event in EVENTS]
    rows += [('on', event, field) for event, fields in EVENT_FILTERS.items()
             for field in fields]
    rows += [('root', 'permissions', scope) for scope in PERMISSION_SCOPES]
    for wf in (model, subject):
        if not isinstance(wf, dict):
            continue
        for key, value in wf.items():
            field = 'on' if key is True else key
            if field == 'jobs':
                continue  # job controls are enumerated separately below.
            for path in _paths(value, (field,)):
                row = ('on',) + path[1:] if field == 'on' else ('root',) + path
                rows.append(row)
    return tuple(dict.fromkeys(rows))


def _equal(actual, expected):
    return actual == expected if actual is not ABSENT and expected is not ABSENT else actual is expected

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
    where, *parts = row
    field = parts[0]
    actual = root_value(wf, row)
    expected = root_value(model, row)
    if where == 'root' and len(parts) == 1 and field == 'jobs':
        return isinstance(actual, dict) and isinstance(expected, dict) and all(
            name in actual for name in expected)
    if where == 'root' and len(parts) == 1 and field == 'on':
        return isinstance(actual, dict) and isinstance(expected, dict) and set(actual) == set(expected)
    if where == 'on' and len(parts) == 1:
        if field == 'pull_request':
            return actual is None or (isinstance(actual, dict) and
                                      set(actual).issubset(EVENT_FILTERS[field]))
        if field == 'push':
            return isinstance(actual, dict) and set(actual).issubset(EVENT_FILTERS[field])
    if where == 'on' and field == 'pull_request' and len(parts) >= 2:
        subfield = parts[1]
        optional = root_value(wf, ('on', field, subfield))
        if subfield == 'branches':
            return optional is ABSENT or includes_main(optional)
        if subfield == 'types':
            return optional is ABSENT or (isinstance(optional, list) and
                   REQUIRED_PR_TYPES.issubset(optional) and
                   all(isinstance(v, str) for v in optional))
        return optional is ABSENT
    return _equal(actual, expected)


def mutate_root(wf, model, row):
    where, *parts = row
    field = parts[0]
    if where == 'root' and len(parts) == 1:
        key = on_key(wf) if field == 'on' else field
        if field == 'env':
            wf[key] = {'BASH_ENV': '/tmp/skip-required'}
        elif field in ('name', 'run-name'):
            wf[key] = 'unprotected-mobile'
        elif key not in wf:
            wf[key] = 'unsafe-control'
        else:
            wf.pop(key)
    elif where == 'on' and len(parts) == 1:
        wf[on_key(wf)].pop(field, None)
    elif where == 'on' and field in EVENT_FILTERS and len(parts) == 2:
        options = wf[on_key(wf)].get(field)
        if options is None:
            options = wf[on_key(wf)][field] = {}
        subfield = parts[1]
        if subfield == 'branches':
            options[subfield] = ['release']
        elif subfield == 'types':
            options[subfield] = ['labeled']
        elif subfield in ('paths', 'paths-ignore'):
            options[subfield] = ['mobile/**']
        elif subfield == 'branches-ignore':
            options.pop('branches', None)
            options[subfield] = ['main']
        else:
            options[subfield] = ['v*']
    else:
        # Mutate exactly the selected nested field (including scalar/list
        # descendants). No path is preselected from the subject as an oracle.
        path = parts if where == 'root' else (on_key(wf),) + tuple(parts)
        path = tuple(on_key(wf) if part == 'on' and index == 0 else part
                     for index, part in enumerate(path))
        parent = wf
        for key in path[:-1]:
            if isinstance(parent, dict):
                if key not in parent or parent[key] is None:
                    parent[key] = {}
                parent = parent[key]
            else:
                parent = parent[key]
        key = path[-1]
        current = root_value(wf, row)
        if current is ABSENT:
            replacement = 'write' if 'permissions' in path else 'unsafe-control'
        elif isinstance(current, bool):
            replacement = not current
        elif isinstance(current, str):
            replacement = 'write' if current == 'read' else 'unsafe-control'
        elif isinstance(current, (int, float)):
            replacement = current + 1
        elif isinstance(current, dict):
            replacement = {'unsafe-control': True}
        else:
            replacement = []
        parent[key] = replacement
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
        scopes = set(PERMISSION_SCOPES)
        for wf in (model, subject):
            permissions = (wf or {}).get('jobs', {}).get(job, {}).get('permissions')
            if isinstance(permissions, dict):
                scopes.update(permissions)
        rows.extend((job, 'permissions', scope) for scope in sorted(scopes))
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
    suffix = '' if index is None else ('-step-%d' % index if isinstance(index, int)
                                        else '-' + str(index))
    return 'workflow-%s-%s%s' % (job, field, suffix)


def value(wf, row):
    job, field, index = row
    body = wf.get('jobs', {}).get(job, {})
    if index is None:
        return body.get(field, ABSENT)
    if isinstance(index, str):
        permissions = body.get('permissions', ABSENT)
        return permissions.get(index, ABSENT) if isinstance(permissions, dict) else ABSENT
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
    body = wf['jobs'][job] if index is None or isinstance(index, str) else wf['jobs'][job]['steps'][index]
    current = value(model, row)
    if isinstance(index, str):
        body.setdefault('permissions', {})[index] = 'write'
        if match(wf, model, row):
            raise ValueError('WORKFLOW_MUTATION_NOT_OBSERVABLE: ' + name_of(row))
        return wf
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
              'WORKFLOW_CONTROL_%s' % root_name(row))) for row in root_controls(model, wf)] +
            [(name_of(row), (match(wf, model, row),
              'WORKFLOW_CONTROL_%s' % name_of(row))) for row in controls(model, wf)])


def stabs(wf, model):
    for row in root_controls(model, wf):
        weak = mutate_root(copy.deepcopy(wf), model, row)
        if root_match(weak, model, row):
            raise ValueError('STAB_ZHIV: ' + root_name(row))
        yield root_name(row), 'WORKFLOW_CONTROL_' + root_name(row)
    for label, permissions in (('write-all', 'write-all'), ('read-all', 'read-all'),
                               ('empty', {})):
        weak = copy.deepcopy(wf)
        weak['permissions'] = permissions
        row = ('root', 'permissions')
        if root_match(weak, model, row):
            raise ValueError('STAB_ZHIV: workflow-root-permissions-' + label)
        yield 'workflow-root-permissions-' + label, 'WORKFLOW_CONTROL_' + root_name(row)
    # Unlike the static optional-field list, this new env child must be
    # discovered by traversing the candidate YAML itself.
    weak = copy.deepcopy(wf)
    weak['env'] = {'CI': 'false'}
    row = ('root', 'env', 'CI')
    if row not in root_controls(model, weak) or root_match(weak, model, row):
        raise ValueError('STAB_ZHIV: workflow-root-env-CI')
    yield root_name(row), 'WORKFLOW_CONTROL_' + root_name(row)
    for row in controls(model, wf):
        weak = mutate(copy.deepcopy(wf), model, row)
        if match(weak, model, row):
            raise ValueError('STAB_ZHIV: ' + name_of(row))
        yield name_of(row), 'WORKFLOW_CONTROL_' + name_of(row)
