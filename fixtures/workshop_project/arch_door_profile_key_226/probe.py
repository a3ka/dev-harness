#!/usr/bin/env python3
"""Real Git/profile/Node worlds; expectations are literals captured before subjects."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
W = 'fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh'
MISSING = object()


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


sys.path.insert(0, str(ROOT / 'fixtures/workshop_project/dver_brifa_203'))
old = load('world203', ROOT / 'fixtures/workshop_project/dver_brifa_203/probe.py')
pins = load('pin186', ROOT / 'fixtures/workshop_project/architecture_steward_186/pin_probe.py')

# kind, key, repoId, expected rc, exact diagnostic token or successful evidence.
CASES = {
 'other-absent': ('task', MISSING, 'another-project', 0, b'=== make_task contract=777 role=architect kind=task ==='),
 'backend-absent': ('task', MISSING, 'Complior-back', 0, b'=== make_task contract=777 role=architect kind=task ==='),
 'explicit-false': ('task', False, 'another-project', 0, b'=== make_task contract=777 role=architect kind=task ==='),
 'backend-false': ('task', False, 'Complior-back', 0, b'=== make_task contract=777 role=architect kind=task ==='),
 'other-enabled': ('task', 'Elsewhere/Project', 'another-project', 1, b'ARCH_COMPONENT_NET'),
 'backend-enabled': ('task', 'a3ka/Complior-back', 'Complior-back', 1, b'ARCH_COMPONENT_NET'),
 'mixed-case': ('task', 'OwNer/RePo.Name_7-x', 'complior-BACK', 1, b'ARCH_COMPONENT_NET'),
 'long-value': ('task', 'O' * 256 + '/' + 'R' * 512, 'another-project', 1, b'ARCH_COMPONENT_NET'),
 'minimal-value': ('task', 'a/b', 'x', 1, b'ARCH_COMPONENT_NET'),
 'with-component': ('brief', 'Elsewhere/Project', 'another-project', 0, b'# api.identity'),
 'backend-brief': ('brief', 'a3ka/Complior-back', 'Complior-back', 0, b'# api.identity'),
 'document': ('document', 'Elsewhere/Project', 'another-project', 0, b'=== make_task contract=777 role=architect kind=task ==='),
 'enabled-no-pin': ('no-pin', 'Elsewhere/Project', 'another-project', 0, b'=== make_task contract=777 role=architect kind=task ==='),
 'legacy-local': ('legacy', MISSING, 'another-project', 1, b'ARCH_COMPONENT_NET'),
 'bad-null': ('resolver', None, 'toy', 1, b'hooks.archBrief'),
 'bad-zero': ('resolver', 0, 'toy', 1, b'hooks.archBrief'),
 'bad-one': ('resolver', 1, 'toy', 1, b'hooks.archBrief'),
 'bad-true': ('resolver', True, 'toy', 1, b'hooks.archBrief'),
 'bad-empty': ('resolver', '', 'toy', 1, b'hooks.archBrief'),
 'bad-array': ('resolver', ['a/b'], 'toy', 1, b'hooks.archBrief'),
 'bad-object': ('resolver', {'enabled': True}, 'toy', 1, b'hooks.archBrief'),
 'bad-string-false': ('resolver', 'false', 'toy', 1, b'hooks.archBrief'),
 'bad-space': ('resolver', ' a/b ', 'toy', 1, b'hooks.archBrief'),
 'bad-newline': ('resolver', 'a/b\n', 'toy', 1, b'hooks.archBrief'),
 'bad-nul': ('resolver', 'a/b\u0000suffix', 'toy', 1, b'hooks.archBrief'),
 'bad-two-slashes': ('resolver', 'a/b/c', 'toy', 1, b'hooks.archBrief'),
 'bad-empty-owner': ('resolver', '/b', 'toy', 1, b'hooks.archBrief'),
 'bad-empty-repo': ('resolver', 'a/', 'toy', 1, b'hooks.archBrief'),
 'bad-trailing-space': ('resolver', 'owner/repo ', 'toy', 1, 'значение вне алфавита'.encode()),
 'bad-trailing-tab': ('resolver', 'owner/repo\t', 'toy', 1, 'значение вне алфавита'.encode()),
 'bad-trailing-lf': ('resolver', 'owner/repo\n', 'toy', 1, 'значение вне алфавита'.encode()),
 'bad-owner-underscore': ('resolver', '_owner/repo', 'toy', 1, 'значение вне алфавита'.encode()),
 'bad-owner-hyphen': ('resolver', '-owner/repo', 'toy', 1, 'значение вне алфавита'.encode()),
 'bad-owner-dot': ('resolver', '.owner/repo', 'toy', 1, 'значение вне алфавита'.encode()),
 'bad-repo-underscore': ('resolver', 'owner/_repo', 'toy', 1, 'значение вне алфавита'.encode()),
 'bad-repo-hyphen': ('resolver', 'owner/-repo', 'toy', 1, 'значение вне алфавита'.encode()),
 'bad-repo-dot': ('resolver', 'owner/.repo', 'toy', 1, 'значение вне алфавита'.encode()),
 'bad-leading-space': ('resolver', ' owner/repo', 'toy', 1, 'значение вне алфавита'.encode()),
 'bad-owner-internal-space': ('resolver', 'ow ner/repo', 'toy', 1, 'значение вне алфавита'.encode()),
 'bad-repo-internal-space': ('resolver', 'owner/re po', 'toy', 1, 'значение вне алфавита'.encode()),
 'grammar-plain': ('resolver', 'owner/repo', 'toy', 0, b''),
 'grammar-internal-punctuation': ('resolver', 'o_w-n.e/r_e-p.o', 'toy', 0, b''),
 'grammar-initial-digits': ('resolver', '0wner/9repo', 'toy', 0, b''),
 'bad-hooks': ('hooks', None, 'toy', 1, b'hooks.archBrief'),
 'bad-json': ('json', MISSING, 'toy', 1, 'файл не JSON'.encode()),
 'bad-door': ('door', None, 'toy', 1, b'hooks.archBrief'),
 'bad-freeze': ('freeze', None, 'toy', 1, b'hooks.archBrief'),
 'bad-done': ('done', None, 'toy', 1, b'hooks.archBrief'),
 'resolver-known': ('resolver', 'Other/Product', 'toy', 0, b''),
 'unknown-sibling': ('unknown', 'Other/Product', 'toy', 0, b''),
 'layer-cannot-enable': ('layer', MISSING, 'toy', 1, b'ARCH_PROFILE_LAYER'),
 'pin-other': ('pin', 'Elsewhere/Project', 'other', 0, 'ПИН ВЕРЕН'.encode()),
 'pin-case': ('pin', 'OwNer/RePo.Name_7-x', 'other', 0, 'ПИН ВЕРЕН'.encode()),
 'pin-backend': ('pin', 'a3ka/Complior-back', 'Complior-back', 0, 'ПИН ВЕРЕН'.encode()),
 'pin-env': ('pin-env', 'Elsewhere/Project', 'other', 0, 'ПИН ВЕРЕН'.encode()),
 'pin-absent': ('pin', MISSING, 'other', 1, b'ARCH_PROFILE_REQUIRED'),
 'pin-false': ('pin', False, 'other', 1, b'ARCH_PROFILE_REQUIRED'),
 'pin-invalid': ('pin', None, 'other', 1, b'hooks.archBrief'),
 'literal-free': ('static', MISSING, '', 0, b''),
 'key-toggle': ('toggle', 'Elsewhere/Project', 'other', 0, b''),
 'missing-profile-door': ('missing-profile-door', MISSING, 'toy', 1, b'ARCH_PROFILE_MISSING'),
 'missing-profile-no-lock': ('missing-profile-no-lock', MISSING, 'toy', 0, 'ARCH_187A_SKIP: проект не в режиме 187а (repoId/пин модели)'.encode()),
 'missing-layer-door': ('missing-layer-door', MISSING, 'toy', 1, b'ARCH_PROFILE'),
 'malformed-profile-door': ('malformed-profile-door', MISSING, 'toy', 1, b'ARCH_PROFILE'),
 'malformed-layer-door': ('malformed-layer-door', MISSING, 'toy', 1, b'ARCH_PROFILE'),
 'layer-conflict': ('layer-conflict', False, 'toy', 1, b'ARCH_PROFILE_LAYER'),
 'layer-false': ('layer-false', MISSING, 'toy', 1, b'ARCH_PROFILE_LAYER'),
 'layer-door': ('layer-door', MISSING, 'toy', 1, b'ARCH_PROFILE_LAYER'),
 'layer-freeze': ('layer-freeze', MISSING, 'toy', 1, b'ARCH_PROFILE_LAYER'),
 'layer-done': ('layer-done', MISSING, 'toy', 1, b'ARCH_PROFILE_LAYER'),
 'unknown-layer-sibling': ('unknown-layer-sibling', MISSING, 'toy', 0, b''),
}


# Independent character oracle from invariant 1, not the subject's jq regex.
ASCII_FIRST = frozenset('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789')
ASCII_REST = ASCII_FIRST | frozenset('_.-')


def grammar_accepts(value):
    if value is False:
        return True
    if type(value) is not str or value.count('/') != 1:
        return False
    return all(part and part[0] in ASCII_FIRST and
               all(char in ASCII_REST for char in part[1:])
               for part in value.split('/'))


def grammar_grid():
    values = {}
    for name, value in [('false', False), ('null', None), ('zero', 0),
                        ('one', 1), ('true', True), ('array', []), ('object', {}),
                        ('array-full', ['a/b']), ('object-full', {'enabled': True})]:
        values['grid-type-' + name] = value
    for mask in range(32):
        values[f'grid-false-case-{mask:02d}'] = ''.join(
            char.upper() if mask & (1 << index) else char
            for index, char in enumerate('false'))
    for name, value in [('leading', ' false'), ('trailing', 'false ')]:
        values['grid-false-' + name] = value
    for index, value in enumerate(('', '/', '/r', 'u/', 'ur', 'u//r', 'u/r/s',
                                    'a/b', '0/9', 'ab/cd', 'OwNer/RePo.Name_7-x')):
        values[f'grid-separator-{index:02d}'] = value
    for position in ('owner-first', 'repo-first', 'owner-middle', 'owner-end',
                     'repo-middle', 'repo-end'):
        for code in range(128):
            char = chr(code)
            owner, repo = 'ab', 'cd'
            if position == 'owner-first':
                owner = char + 'b'
            elif position == 'repo-first':
                repo = char + 'd'
            elif position == 'owner-middle':
                owner = 'a' + char + 'b'
            elif position == 'owner-end':
                owner += char
            elif position == 'repo-middle':
                repo = 'c' + char + 'd'
            else:
                repo += char
            values[f'grid-ascii-{position}-{code:03d}'] = owner + '/' + repo
    for name, char in [('sp', ' '), ('tab', '\t'), ('cr', '\r'),
                       ('lf', '\n'), ('nul', '\0')]:
        for position, value in [('before', char + 'ab/cd'), ('after', 'ab/cd' + char),
                                ('owner', 'a' + char + 'b/cd'),
                                ('repo', 'ab/c' + char + 'd')]:
            values[f'grid-boundary-{position}-{name}'] = value
    for code, char in enumerate(('ǹ', '١', 'Ａ', '１')):
        for position, value in [('owner-first', char + 'b/cd'),
                                ('repo-first', 'ab/' + char + 'd'),
                                ('owner-rest', 'a' + char + '/cd'),
                                ('repo-rest', 'ab/c' + char)]:
            values[f'grid-unicode-{position}-{code}'] = value
    values['grid-unicode-slash'] = 'ab／cd'
    for name, value in [('owner', 'O' * 1024 + '/R'),
                        ('repo', 'O/' + 'R' * 1024),
                        ('both', 'O' * 1024 + '/' + 'R' * 1024)]:
        values['grid-length-' + name] = value
    return values


GRID = grammar_grid()
# Freeze both values and expectations before any subject runs.
CASES.update({name: ('grid', value, 'toy', 0 if grammar_accepts(value) else 1,
                     'значение вне алфавита'.encode())
              for name, value in GRID.items()})


def public_catalog():
    """Unique raw hooks inputs, with expectations captured before any subject."""
    entries, aliases, axes = {}, {}, {}

    def add(name, axis, fragment):
        # Keep duplicate-key JSON raw; ordinary repeated inputs share one witness.
        identity = fragment
        if identity not in entries:
            parsed = json.loads('{' + fragment + '}')
            hooks = parsed.get('hooks', MISSING)
            shape_ok = hooks is MISSING or type(hooks) is dict
            value = hooks.get('archBrief', MISSING) if type(hooks) is dict else MISSING
            accepted = shape_ok and (value is MISSING or grammar_accepts(value))
            reason = ('ожидается false или owner/repo' if shape_ok else 'hooks не объект')
            projection = (None if hooks is MISSING else
                          {'origin': 'repo', 'value': (
                              {} if value is MISSING else {'archBrief': value})})
            entries[identity] = dict(name=name, fragment=fragment, rc=0 if accepted else 1,
                                     projection=projection, reason=reason,
                                     warning=type(hooks) is dict and 'futureHook' in hooks)
        aliases[name] = identity
        axes.setdefault(axis, []).append(name)

    masks = {0, 31, 1, 2, 4, 8, 16, 10}  # false/FALSE/False/fAlSe + each position.
    for name, value in GRID.items():
        axis = name.split('-')[1]
        selected = (axis in {'type', 'separator', 'boundary', 'unicode', 'length'} or
                    (axis == 'false' and ('case-' not in name or int(name[-2:]) in masks)) or
                    (axis == 'ascii' and int(name[-3:]) in {95, 45, 46, 64}))
        if selected:
            add(name, axis, '"hooks":' + json.dumps({'archBrief': value}, sort_keys=True))
    # Existing public resolver cells participate in the same deduplicated layer.
    for name, (kind, value, _, _, _) in list(CASES.items()):
        if kind in {'resolver', 'hooks', 'unknown'}:
            hooks = None if kind == 'hooks' else {'archBrief': value}
            if kind == 'unknown':
                hooks['futureHook'] = 'keep-M0'
            add(name, 'existing-' + kind, '"hooks":' + json.dumps(hooks, sort_keys=True))
    for name, fragment in [
            ('absent', ''), ('empty', '"hooks":{}'),
            ('future', '"hooks":{"futureHook":"keep-M0"}'),
            ('null', '"hooks":null'), ('false', '"hooks":false'), ('true', '"hooks":true'),
            ('zero', '"hooks":0'), ('string', '"hooks":""'), ('array', '"hooks":[]')]:
        add('public-hooks-' + name, 'hooks', fragment)
    good, cr = json.dumps('ab/cd'), json.dumps('ab/cd\r')
    for first, last, label in [(good, cr, 'last-cr'), (cr, good, 'last-good')]:
        add('public-duplicate-leaf-' + label, 'duplicates',
            '"hooks":{"archBrief":' + first + ',"archBrief":' + last + '}')
        add('public-duplicate-hooks-' + label, 'duplicates',
            '"hooks":{"archBrief":' + first + '},"hooks":{"archBrief":' + last + '}')
    for name in ('mixed-case', 'long-value'):
        add('public-' + name, 'positive-controls',
            '"hooks":' + json.dumps({'archBrief': CASES[name][1]}, sort_keys=True))
    for name, value in [('null', None), ('cr', 'ab/cd\r'), ('true', True),
                        ('zero', 0), ('false', False), ('valid', 'ab/cd')]:
        add('public-control-' + name, 'control',
            '"hooks":' + json.dumps({'archBrief': value}, sort_keys=True))
    return entries, aliases, axes


PUBLIC_INPUTS, PUBLIC_ALIASES, PUBLIC_AXES = public_catalog()
for _name, _identity in PUBLIC_ALIASES.items():
    if _name not in CASES:
        _entry = PUBLIC_INPUTS[_identity]
        CASES[_name] = ('public', _identity, 'toy', _entry['rc'], b'hooks.archBrief')
PUBLIC_WORLDS = {}
PUBLIC_RESULTS = {}

def public_source(bindings):
    return {
        'unique_inputs': len(PUBLIC_INPUTS),
        'axes': PUBLIC_AXES,
        'witnesses': {row['name']: {'fragment': row['fragment'], 'rc': row['rc']}
                      for row in PUBLIC_INPUTS.values()},
        'bindings': {name: {cell: ('public-cli' if cell in PUBLIC_ALIASES else
                                  'internal-jq' if cell in GRID else 'integration-cli')
                           for cell in row['cells']}
                     for name, row in bindings.items()},
    }



class GridFailure(RuntimeError):
    """The internal jq seam failed, independently of public CLI observations."""


def run_grid(base, tools, cells):
    """One real resolver/world captures its actual jq argv; real jq judges the grid.

    Native bash xtrace observes commands without replacing jq/PATH or reading a
    model predicate. Existing integration cells still judge public CLI diagnostics.
    The captured validation and complete merge are replayed, not reimplemented.
    """
    base.mkdir()
    product, arch, *_ = old.build(base, 'grid-product')
    profile = install_profile(product, 'ab/cd', 'toy')
    env = old.env_for(product, arch)
    trace_path = base / 'resolver.trace'
    with trace_path.open('wb') as trace:
        env.update(BASH_XTRACEFD=str(trace.fileno()))
        control = subprocess.run(
            ['bash', '-c', 'PS4=$\'\\nARCH226 \'; set -x; source "$1" --repo "$2"',
             'grid', str(tools / 'scripts/profile_resolver.sh'), str(product)],
            cwd=product, env=env, capture_output=True, pass_fds=(trace.fileno(),),
            timeout=240)
    env.pop('BASH_XTRACEFD')
    if control.returncode:
        raise GridFailure('GRID_RESOLVER_CONTROL ' + repr(control.stderr))
    import shlex
    commands = []
    for record in trace_path.read_text().split('\nARCH226 '):
        if record.startswith('jq '):
            commands.append(shlex.split(record))
    validators = [argv for argv in commands if len(argv) == 4 and
                  argv[1] == '-e' and argv[2].startswith('.hooks.archBrief |')]
    merges = [argv for argv in commands if '--slurpfile' in argv and
              'repo' in argv and 'project' in argv]
    if len(validators) != 1 or len(merges) != 1:
        raise GridFailure('GRID_JQ_SEAM ' + repr((len(validators), len(merges))))
    validation, merge = validators[0], merges[0]
    # Replacing only the input file keeps the actual predicate and jq -e rc.
    # Each positive also runs the subject's full merged expression unchanged.
    results = {}
    input_path = base / 'profile.json'
    for cell in cells:
        _, value, _, rc, _ = CASES[cell]
        profile['hooks'] = {'archBrief': value}
        input_path.write_text(json.dumps(profile))
        result = call(validation[:-1] + [input_path], product, env)
        if result.returncode not in (0, 1) or result.stderr:
            raise GridFailure('GRID_JQ_INFRA ' + cell + repr(result))
        errors = [] if result.returncode == rc else ['GRAMMAR_RC']
        if rc == 0 and result.returncode == 0:
            argv = merge.copy()
            argv[argv.index('repo') + 1] = str(input_path)
            argv[argv.index('project') + 1] = str(product / profile['projectLayer']['profilePath'])
            merged = call(argv, product, env)
            if merged.returncode:
                raise GridFailure('GRID_MERGE_INFRA ' + repr(merged.stderr))
            if json.loads(merged.stdout).get('hooks') != {
                    'origin': 'repo', 'value': {'archBrief': value}}:
                errors.append('MERGED_POLICY')
        if errors:
            # A discrepancy must also be observable through the public resolver,
            # with its real rc, diagnostic and merged output, not a synthetic rc.
            install_profile(product, value, 'toy')
            result = call(['bash', tools / 'scripts/profile_resolver.sh',
                           '--repo', product], product, env)
            if result.returncode not in (0, 1):
                raise GridFailure('GRID_RESOLVER_INFRA ' + repr(result.stderr))
            errors += judge(result, rc, 'значение вне алфавита'.encode() if rc else b'')
        results[cell] = errors, result
    return results


GRID_CACHE = {}
GRID_LINKS = {}


def call(argv, cwd, env):
    return subprocess.run([str(a) for a in argv], cwd=cwd, env=env,
                          capture_output=True, timeout=240)


def install_profile(product, value, rid):
    path = product / 'harness.project.json'
    profile = json.loads(path.read_text())
    profile['repoId'] = rid
    profile.pop('hooks', None)
    if value is not MISSING:
        profile['hooks'] = {'archBrief': value}
    path.write_text(json.dumps(profile))
    return profile


def pin_cell(base, tools, cell):
    kind, value, rid, rc, token = CASES[cell]
    arch, product, env, expected = pins.world(base, 'pin_merged')
    # Reuse the same valid profile schema as the task worlds, not a fake resolver.
    donor = old.world(base, 'profile-donor', kind='mobile')
    shutil.copyfile(donor / 'harness.project.json', product / 'harness.project.json')
    for path in ('.harness/project-layer.json', '.github/workflows/toy.yml'):
        old.put(product, path, (donor / path).read_text())
    profile = install_profile(product, value, rid)
    profile['git']['canonicalRemote'] = 'ssh://git@github.com/Elsewhere/Project.git'
    old.put(product, 'harness.project.json', json.dumps(profile))
    new_head = pins.commit(product, '226 configured product')
    state_path = Path(env['PIN_TOY_STATE'])
    state = json.loads(state_path.read_text())
    state['product']['headRefOid'] = new_head
    state['productRepo'] = value if isinstance(value, str) else 'unused/unused'
    state_path.write_text(json.dumps(state))
    gh = base / 'bin/gh'
    # The HTTP seam is fixture metadata; Git/PR-head/merge/lock checks remain real.
    log = base / 'gh-calls.jsonl'
    gh.write_text(pins.FAKE_GH.replace(
        "elif (repo, number) == ('a3ka/Complior-back', '73'):",
        "elif number == '73':").replace(
        "args = sys.argv[1:]",
        "args = sys.argv[1:]\nwith pathlib.Path(os.environ['GH_CALL_LOG']).open('a') as out:\n    out.write(json.dumps(args) + '\\n')"))
    env.update(HARNESS_PROJECT_LAYER_ROOT=str(product), GH_CALL_LOG=str(log),
               GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null')
    env.pop('PRODUCT_REPO', None)
    if kind == 'pin-env':
        env['PRODUCT_REPO'] = 'Foreign/EnvOverride'
    before = {p.name: p.read_bytes() for p in product.iterdir() if p.is_file()}
    result = call(['bash', tools / 'scripts/check_architecture_pin.sh', arch, '42', product, '73'], product, env)
    errors = judge(result, rc, token, stdout_token=rc == 0)
    calls = [json.loads(line) for line in log.read_text().splitlines()] if log.exists() else []
    if rc == 0 and [a[a.index('-R') + 1] for a in calls if a[2] == '73'] != [value]:
        errors.append('PRODUCT_REPO_DEPENDENCY')
    if rc != 0 and calls:
        errors.append('GH_BEFORE_POLICY')
    if old.git(product, 'rev-parse', 'HEAD') != new_head:
        errors.append('HEAD')
    if before != {p.name: p.read_bytes() for p in product.iterdir() if p.is_file()}:
        errors.append('FILES')
    return errors, result


def judge(result, rc, token, stdout_token=False):
    errors = []
    if result.returncode != rc:
        errors.append('RC')
    channel = result.stdout if stdout_token else result.stderr
    # Refusal codes are independent tokens in their own diagnostic lines, not anywhere in a pack.
    if token and not any(token.decode() in line.split(': ') or line.startswith(token.decode() + ':')
                         or (stdout_token and (line.encode() == token or (token == 'ПИН ВЕРЕН'.encode() and line.startswith('ПИН ВЕРЕН: '))))
                         or (token == b'hooks.archBrief' and 'hooks.archBrief' in line.split())
                         or (token == b'profile' and line.startswith('profile '))
                         for line in channel.decode('utf8', 'replace').splitlines()):
        errors.append('DIAGNOSIS')
    if rc != 0 and result.stdout:
        errors.append('PARTIAL_OUTPUT')
    return errors


def run_cell(base, tools, cell):
    if cell in GRID:
        key = (base.parent, tools)
        if key not in GRID_CACHE:
            cells = GRID_LINKS.get(tools.name, GRID)
            GRID_CACHE[key] = run_grid(base.parent / (tools.name + '-grid'), tools, cells)
        return GRID_CACHE[key][cell]
    base.mkdir()
    kind, value, rid, rc, token = CASES[cell]
    if kind.startswith('pin'):
        return pin_cell(base, tools, cell)
    if kind == 'static':
        files = sorted((tools / 'scripts').glob('check_architecture_*.sh'))
        if not files:
            raise RuntimeError('EMPTY_STATIC_SAMPLE')
        bad = [(p.name, n) for p in files for n, line in enumerate(p.read_text().splitlines(), 1)
               if line.strip() and not line.lstrip().startswith('#') and 'Complior-back' in line]
        return (['PROJECT_LITERAL'] if bad else []), repr(bad)
    product, arch, task, trace, _ = old.build(base, 'product')
    if kind != 'legacy':
        shutil.rmtree(product / 'architecture')
    profile = install_profile(product, value, rid)
    if kind == 'hooks':
        profile['hooks'] = None
    if kind == 'unknown':
        profile['hooks']['futureHook'] = 'keep-M0'
    if kind == 'layer':
        layer = product / '.harness/project-layer.json'
        data = json.loads(layer.read_text())
        data['defaults']['hooks'] = {'archBrief': 'Other/Product'}
        layer.write_text(json.dumps(data))
    if kind.startswith('layer-') or kind == 'unknown-layer-sibling':
        layer = product / '.harness/project-layer.json'
        data = json.loads(layer.read_text())
        data['defaults']['hooks'] = (
            {'futureHook': 'keep-M0'} if kind == 'unknown-layer-sibling'
            else {'archBrief': False if kind == 'layer-false' else 'Other/Product'})
        layer.write_text(json.dumps(data))
    old.put(product, 'harness.project.json', json.dumps(profile))
    if kind == 'json':
        old.put(product, 'harness.project.json', '{broken')
    if kind == 'no-pin':
        (product / 'architecture.lock.json').unlink()
    if kind.startswith('missing-profile'):
        (product / 'harness.project.json').unlink()
        if kind == 'missing-profile-no-lock':
            (product / 'architecture.lock.json').unlink()
    if kind == 'malformed-profile-door':
        old.put(product, 'harness.project.json', '{broken')
    if kind == 'missing-layer-door':
        (product / '.harness/project-layer.json').unlink()
    if kind == 'malformed-layer-door':
        old.put(product, '.harness/project-layer.json', '{broken')
    if kind == 'document':
        path = product / old.CONTRACT
        path.write_text(path.read_text().replace('КЛАСС ЗАДАЧИ: кодовый.', 'КЛАСС ЗАДАЧИ: документальный.'))
    old.git(product, 'add', '.')
    old.git(product, 'commit', '-qm', '226 world')
    before = old.git(product, 'rev-parse', 'HEAD')
    env = old.env_for(product, arch)
    script = tools / 'scripts'
    if kind in ('resolver', 'hooks', 'unknown'):
        argv = ['bash', script / 'profile_resolver.sh', '--repo', product]
    elif kind == 'unknown-layer-sibling':
        argv = ['bash', script / 'profile_resolver.sh', '--repo', product]
    elif kind == 'door':
        argv = ['bash', script / 'check_architecture_contract.sh', '--repo', product, old.CONTRACT]
    elif kind.endswith('-door') or kind == 'missing-profile-no-lock':
        argv = ['bash', script / 'check_architecture_contract.sh', '--repo', product, old.CONTRACT]
    elif kind == 'freeze':
        argv = ['bash', script / 'freeze_contract.sh', old.CONTRACT, '226 toy', product, old.critic_state(product)]
    elif kind == 'layer-freeze':
        argv = ['bash', script / 'freeze_contract.sh', old.CONTRACT, '226 toy', product, old.critic_state(product)]
    elif kind == 'done':
        argv = ['bash', script / 'done_contract.sh', old.CONTRACT, product]
    elif kind == 'layer-done':
        argv = ['bash', script / 'done_contract.sh', old.CONTRACT, product]
    else:
        argv = ['bash', script / 'make_task.sh', '--repo', product, '--role', 'architect',
                '--kind', 'task', '--contract', '777', '--task-file', task, '--model-trace', trace]
        if kind == 'brief':
            argv += ['--arch-component', 'api.identity']
    if kind == 'toggle':
        on = call(argv, product, env)
        install_profile(product, False, rid)
        off = call(argv, product, env)
        install_profile(product, value, rid)
        again = call(argv, product, env)
        errors = judge(on, 1, b'ARCH_COMPONENT_NET') + judge(off, 0, b'=== make_task contract=777 role=architect kind=task ===', True) + judge(again, 1, b'ARCH_COMPONENT_NET')
        return errors, repr([(p.returncode, p.stderr[:120]) for p in (on, off, again)])
    result = call(argv, product, env)
    errors = judge(result, rc, token, stdout_token=rc == 0)
    if kind == 'unknown' and b'hooks.futureHook' not in result.stderr:
        errors.append('M0_WARNING')
    if kind == 'resolver' and rc == 0:
        merged = json.loads(result.stdout)
        if merged.get('hooks') != {'origin': 'repo', 'value': {'archBrief': value}}:
            errors.append('MERGED_POLICY')
    if old.git(product, 'rev-parse', 'HEAD') != before:
        errors.append('HEAD')
    if old.git(product, 'tag', '-l', 'frozen/contracts/777/*', 'done/contracts/777/*'):
        errors.append('TAG')
    return errors, result


_integration_cell = run_cell


def run_public(base, tools, cell):
    identity = PUBLIC_ALIASES[cell]
    key = (base.parent, tools)
    cache_key = (key, identity)
    if cache_key in PUBLIC_RESULTS:
        return PUBLIC_RESULTS[cache_key]
    expected = PUBLIC_INPUTS[identity]
    if key not in PUBLIC_WORLDS:
        world = base.parent / (tools.name + '-public')
        world.mkdir()
        product, arch, *_ = old.build(world, 'product')
        profile = install_profile(product, MISSING, 'toy')
        PUBLIC_WORLDS[key] = product, old.env_for(product, arch), profile
    product, env, profile = PUBLIC_WORLDS[key]
    raw = json.dumps(profile)[:-1]
    if expected['fragment']:
        raw += ',' + expected['fragment']
    raw += '}'
    path = product / 'harness.project.json'
    path.write_text(raw)
    before = (old.git(product, 'rev-parse', 'HEAD'), old.git(product, 'show-ref'), raw)
    result = call(['bash', tools / 'scripts/profile_resolver.sh', '--repo', product], product, env)
    errors = []
    if result.returncode != expected['rc']:
        errors.append('PUBLIC_RC')
    if expected['rc']:
        diagnostic = ('profile ОТКАЗ: значение вне алфавита: hooks.archBrief: ' +
                      expected['reason']).encode()
        if result.stderr != diagnostic + b'\n':
            errors.append('PUBLIC_DIAGNOSIS')
        if result.stdout:
            errors.append('PUBLIC_PARTIAL_OUTPUT')
    else:
        try:
            merged = json.loads(result.stdout)
            if json.dumps(merged.get('hooks'), sort_keys=True) != json.dumps(
                    expected['projection'], sort_keys=True):
                errors.append('PUBLIC_MERGED_POLICY')
        except (ValueError, AttributeError):
            errors.append('PUBLIC_JSON')
        if expected['warning']:
            if b'hooks.futureHook' not in result.stderr:
                errors.append('PUBLIC_M0_WARNING')
        elif result.stderr:
            errors.append('PUBLIC_STDERR')
    after = (old.git(product, 'rev-parse', 'HEAD'), old.git(product, 'show-ref'), path.read_text())
    if after != before:
        errors.append('PUBLIC_SIDE_EFFECT')
    # rc 2 with the exact refusal is a wrong subject status, not infrastructure.
    # Keep its real rc/channels in evidence; never rewrite it as rc 1.
    if result.returncode in (126, 127) or (
            result.returncode == 2 and not any(
                line.startswith('profile ОТКАЗ: '.encode())
                for line in result.stderr.splitlines())):
        raise RuntimeError('PUBLIC_INFRA ' + repr(result))
    evidence = repr(('PUBLIC_CLI', result.returncode, result.stdout[:100], result.stderr))
    PUBLIC_RESULTS[cache_key] = errors, evidence
    return errors, evidence


def run_cell(base, tools, cell):
    if cell not in PUBLIC_ALIASES:
        return _integration_cell(base, tools, cell)
    # Grid still executes in full at its original internal seam. The public
    # observation is unconditional, independent of whether that jq agreed.
    errors, evidence = run_public(base, tools, cell)
    internal = _integration_cell(base, tools, cell)[0] if cell in GRID else []
    return internal + errors, evidence


def carrier_catalog():
    source = json.loads((HERE / 'source.json').read_text())
    build = load('build226', HERE / 'build.py')
    expected = {name: {'path': path, 'cells': cells}
                for name, (path, _old, _new, cells) in build.MUTATIONS.items()}
    if source['bindings'] != expected or source['files'] != list(build.FILES):
        raise RuntimeError('CATALOG_DRIFT')
    for path, digest in source['carriers'].items():
        if hashlib.sha256((HERE / path).read_bytes()).hexdigest() != digest:
            raise RuntimeError('CARRIER_HASH ' + path)
    for name, row in source['bindings'].items():
        if not row['cells'] or set(row['cells']) - CASES.keys():
            raise RuntimeError('ORPHAN ' + name)
        GRID_LINKS[name] = [cell for cell in row['cells'] if cell in GRID]
    print('KLETKI', len(CASES), 'STABY', len(source['bindings']),
          'SVJAZI', sum(len(v['cells']) for v in source['bindings'].values()))
    for axis in ('type', 'false', 'separator', 'ascii', 'boundary', 'unicode', 'length'):
        cells = [name for name in GRID if name.startswith('grid-' + axis + '-')]
        if not cells:
            raise RuntimeError('EMPTY_GRID_AXIS ' + axis)
        print('GRID_AXIS', axis, 'CASES', len(cells), 'ACCEPT',
              sum(CASES[name][3] == 0 for name in cells))
    public = public_source(source['bindings'])
    if source.get('public') != public:
        raise RuntimeError('PUBLIC_CATALOG_DRIFT')
    print('PUBLIC_UNIQUE_INPUTS', len(PUBLIC_INPUTS))
    for axis, cells in PUBLIC_AXES.items():
        print('PUBLIC_AXIS', axis, 'POSITIONS', len(cells), 'UNIQUE_INPUTS',
              len({PUBLIC_ALIASES[cell] for cell in cells}))
    repairs = load('repairs226', HERE / 'repair_checks.py').catalog()
    if source.get('repairs') != repairs:
        raise RuntimeError('REPAIR_CATALOG_DRIFT')
    print('REPAIR_CONTROLS', sum(len(cells) for cells in repairs.values()))
    return source


def materialize(base, name, source, mutation=None):
    target = base / name
    target.mkdir()
    # One real installation copy per experiment. No fake production collaborators.
    shutil.copytree(ROOT / 'scripts', target / 'scripts', symlinks=True)
    shutil.copytree(ROOT / 'config', target / 'config', symlinks=True)
    shutil.copyfile(ROOT / 'package.json', target / 'package.json')
    for family in ('architecture_process_187', 'architecture_steward_186', 'dver_brifa_203'):
        destination = target / 'fixtures/workshop_project' / family
        shutil.copytree(ROOT / 'fixtures/workshop_project' / family, destination,
                        ignore=shutil.ignore_patterns('__pycache__'))
    for p in source['files']:
        shutil.copyfile(HERE / 'model' / p, target / p)
    if mutation:
        p = source['bindings'][mutation]['path']
        shutil.copyfile(HERE / 'stabs' / mutation / p, target / p)
    return target


def syntax(source):
    files = [HERE / path for path in source['carriers'] if path.endswith('.sh')] + [HERE / Path(W).name]
    for path in files:
        p = subprocess.run(['bash', '-n', str(path)], capture_output=True)
        if p.returncode:
            raise RuntimeError('BASH_SYNTAX ' + str(path) + repr(p.stderr))
    for path in list(HERE.glob('*.py')) + [HERE / p for p in source['carriers'] if p.endswith('.py')]:
        compile(path.read_bytes(), str(path), 'exec')
    # validate_std checks the real binary pin on the new wrapper. Existing full
    # scripts have baseline warnings; compare their real shellcheck JSON reports,
    # not a suppression list or a promise that inherited warnings disappeared.
    p = subprocess.run(['bash', str(ROOT / 'scripts/validate_std.sh'), 'bash', str(HERE / Path(W).name)], capture_output=True)
    if p.returncode:
        raise RuntimeError('SHELLCHECK_WRAPPER ' + repr(p.stdout + p.stderr))
    binary = os.environ.get('VALIDATE_STD_SHELLCHECK', str(Path.home() / '.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck'))
    def report(path):
        result = subprocess.run([binary, '--format=json', str(path)], capture_output=True)
        if result.returncode not in (0, 1):
            raise RuntimeError('SHELLCHECK_INFRA ' + repr(result.stderr))
        lines = path.read_text().splitlines()
        return {(d['code'], d['message'], lines[d['line'] - 1]) for d in json.loads(result.stdout)}
    inherited = 0
    with tempfile.TemporaryDirectory(prefix='syntax226-') as temp:
        for path in [p for p in source['files'] if p.endswith('.sh')]:
            original = subprocess.run(['git', '-C', str(ROOT), 'show', source['base'] + ':' + path],
                                      check=True, capture_output=True).stdout
            before = Path(temp) / Path(path).name
            before.write_bytes(original)
            baseline, actual = report(before), report(HERE / 'model' / path)
            if actual - baseline:
                raise RuntimeError('SHELLCHECK_NEW ' + path + repr(actual - baseline))
            inherited += len(actual)
    print('SINTAKSIS', len(files), 'SHELLCHECK_DIFFERENTIAL', len([p for p in source['files'] if p.endswith('.sh')]), 'BASELINE_DIAGNOSTICS', inherited)
    return 0


def main():
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--repo', type=Path)
    mode.add_argument('--model', action='store_true')
    mode.add_argument('--stabs', action='store_true')
    mode.add_argument('--sintaksis', action='store_true')
    mode.add_argument('--catalog', action='store_true')
    mode.add_argument('--regression', nargs='?', const='MODEL', type=str)
    parser.add_argument('--cell', choices=CASES)
    args = parser.parse_args()
    source = carrier_catalog()
    if args.catalog:
        return 0
    if args.sintaksis:
        return syntax(source)
    if args.regression:
        with tempfile.TemporaryDirectory(prefix='regress226-') as temp:
            tools = materialize(Path(temp), 'honest', source) if args.regression == 'MODEL' else Path(args.regression).resolve()
            commands = [
                ['bash', tools / 'fixtures/workshop_project/dver_brifa_203/red_dver_brifa_203.sh', '--repo', tools],
                ['python3', tools / 'fixtures/workshop_project/architecture_steward_186/pin_probe.py', '--repo', tools],
            ]
            for command in commands:
                result = subprocess.run([str(p) for p in command], env=os.environ.copy(), timeout=600)
                if result.returncode:
                    return result.returncode
        print('REGRESSION 203 PIN186 rc=0')
        return 0
    failed, living, links = 0, 0, 0
    with tempfile.TemporaryDirectory(prefix='arch226-') as temp:
        base = Path(temp)
        tools = args.repo.resolve() if args.repo else materialize(base, 'honest', source)
        for cell in ([args.cell] if args.cell else CASES):
            try:
                errors, result = run_cell(base / cell, tools, cell)
            except GridFailure as exc:
                public_red = any(key[0][1] == tools and errors
                                 for key, (errors, _) in PUBLIC_RESULTS.items())
                if not public_red:
                    raise
                # A failed seam cannot erase an independently observed public
                # counterexample. Do not claim the unexecuted grid cells green.
                for key, (errors, evidence) in PUBLIC_RESULTS.items():
                    if key[0][1] == tools and errors:
                        print('RED', PUBLIC_INPUTS[key[1]]['name'],
                              ','.join(errors), evidence, flush=True)
                print('GRID_UNAVAILABLE:', exc, file=sys.stderr)
                print('PUBLIC_COUNTEREXAMPLE: rc=1; remaining internal cells not judged')
                return 1
            failed += bool(errors)
            detail = repr((result.returncode, result.stdout[:100], result.stderr[:250])) if hasattr(result, 'returncode') else result
            print('RED' if errors else 'GREEN', cell, ','.join(errors), detail, flush=True)
        if args.stabs and not failed:
            for name, row in source['bindings'].items():
                mutant = materialize(base, name, source, name)
                for cell in row['cells']:
                    errors, result = run_cell(base / (name + '-' + cell), mutant, cell)
                    if hasattr(result, 'returncode') and (result.returncode in (2, 126, 127) or b'SyntaxError' in result.stderr):
                        raise RuntimeError('INVALID_MUTANT ' + name)
                    links += 1
                    living += not bool(errors)
                    print('CAUGHT' if errors else 'ZHIV', name, cell, flush=True)
    print('KLETKI', 1 if args.cell else len(CASES), 'KRASNYH', failed,
          'SVJAZI', links, 'ZHIVYH', living)
    return int(bool(failed or living))


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as exc:
        print('NOT_IMPLEMENTED:', exc, file=sys.stderr)
        raise SystemExit(2)
