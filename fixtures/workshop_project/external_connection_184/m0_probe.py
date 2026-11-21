#!/usr/bin/env python3
"""M-0 public seams: resolver CLI and sourced profile_get, not private helpers."""
from collections import Counter
from copy import deepcopy
from dataclasses import dataclass
import json
import os
from pathlib import Path
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
LIB_FLAG = 'PROFILE_RESOLVER_LIB'
WARNING = 'профиль ПРЕДУПРЕЖДЕНИЕ: неизвестный ключ '


@dataclass(frozen=True)
class Case:
    name: str
    group: str
    layer: bool = False
    path: tuple = ()
    value: object = None
    reason: str = ''
    label: str = 'back'
    get_path: str = ''
    expected: str = ''


CASES = (
    Case('m0-a-root', 'unknown', path=('novyj',), value={'x': 1}),
    *(Case(f'm0-b-{branch}', 'unknown', path=(branch, 'zzz'), value={'x': 1})
      for branch in ('workflowPaths', 'git', 'commands')),
    Case('m0-v-defaults', 'unknown', True, ('defaults', 'zzz'), {'x': 1}),
    *(Case(f'm0-v-defaults-{branch}', 'unknown', True, ('defaults', branch, 'zzz'), {'x': 1})
      for branch in ('workflowPaths', 'git', 'commands')),
    Case('m0-v-layer-root', 'unknown', True, ('zzz',), {'x': 1}),
    Case('m0-g-registry', 'invalid', path=('workflowPaths', 'registry'), value=5,
         reason='значение вне алфавита: workflowPaths.registry: <number>'),
    Case('m0-g-remote', 'invalid', path=('git', 'canonicalRemote'), value=5,
         reason='значение вне алфавита: canonicalRemote: <number>'),
    Case('m0-g-schema', 'invalid', path=('schemaVersion',), value=2,
         reason='значение вне алфавита: schemaVersion: 2'),
    Case('m0-g-commands', 'invalid', path=('commands', 'test'), value='',
         reason='значение вне алфавита: commands.test: пусто'),
    Case('m0-g-canon', 'invalid', path=('sourceCanon',), value={},
         reason='SOURCE_CANON_INVALID'),
    *(Case(f'm0-d-repo-{key}', 'missing', path=(key,), reason=reason)
      for key, reason in (
          ('schemaVersion', 'значение вне алфавита: schemaVersion: <null>'),
          ('repoId', 'значение вне алфавита: repoId: <missing>'),
          ('projectLayer', 'нет файла слоя проекта:'))),
    *(Case(f'm0-d-layer-{key}', 'missing', True, (key,), reason=reason)
      for key, reason in (
          ('schemaVersion', 'значение вне алфавита: schemaVersion: <null>'),
          ('version', 'значение вне алфавита: version: <missing>'),
          ('projectId', 'значение вне алфавита: projectId: <missing>'),
          ('workspaceId', 'значение вне алфавита: workspaceId: <missing>'))),
    Case('m0-e-two-unknown', 'two'),
    *(Case(f'm0-zh-{label}', 'legacy', label=label) for label in ('back', 'mob', 'station')),
    Case('m0-z-present', 'get', get_path='.repoId', expected='Complior-back\n'),
    Case('m0-z-nested', 'get', get_path='.pack.maxBytes', expected='321\n'),
    Case('m0-z-missing-key', 'get', get_path='.pack.absent', expected='fallback\n'),
    Case('m0-z-missing-file', 'get', get_path='.repoId', expected='fallback\n'),
    Case('m0-z-broken-json', 'get', get_path='.repoId', expected='fallback\n'),
    Case('m0-z-wrong-layer', 'get', get_path='.pack.maxBytes', expected='321\n'),
)

# Н-39: only executable bindings, never inferred from prose or the first red cell.
STABS = {
    'S1-silent': 'm0-a-root',
    'S2-leak': 'm0-a-root',
    'S3-invalid-accepted': 'm0-g-registry',
    'S4-missing-accepted': 'm0-d-repo-repoId',
    'S5-root-only': 'm0-b-workflowPaths',
    'S6-layer-reader': 'm0-z-wrong-layer',
    'S6-broken-json': 'm0-z-broken-json',
    'S7-last-lost': 'm0-e-two-unknown',
}


def put(data, path, value, remove=False):
    parent = data
    for key in path[:-1]:
        parent = parent.setdefault(key, {})
    if remove:
        parent.pop(path[-1], None)
    else:
        parent[path[-1]] = deepcopy(value)


def prepare(base, case, snapshots):
    root = base / case.name
    root.mkdir()
    snapshot = snapshots[case.label]
    profile = json.loads(snapshot['profile'])
    layer = json.loads(snapshot['layer'])
    if case.group in ('unknown', 'invalid', 'missing'):
        put(layer if case.layer else profile, case.path, case.value, case.group == 'missing')
    if case.group == 'two':
        profile.update(novyj={'x': 1}, drugoj={'x': 2})
    if case.group == 'get':
        profile['pack'] = {'maxBytes': 321}
        # Deliberately different raw and layer values, even for a known key.
        layer['defaults'] = {'pack': {'maxBytes': 999}, 'repoId': 'wrong-layer'}
    path = root / json.loads(snapshot['profile'])['projectLayer']['profilePath']
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(layer))
    profile_path = root / 'harness.project.json'
    profile_path.write_text(json.dumps(profile))
    if case.name == 'm0-z-missing-file':
        profile_path.unlink()
    elif case.name == 'm0-z-broken-json':
        profile_path.write_text('{invalid')
    workflow = root / profile['ci']['workflow']
    workflow.parent.mkdir(parents=True, exist_ok=True)
    workflow.touch()
    return root, profile, layer


def warning_lines(case):
    if case.group == 'unknown':
        label = 'слой-проекта' if case.layer else 'репо-слой'
        return [WARNING + label + ': ' + '.'.join(case.path)]
    if case.group == 'two':
        return [WARNING + 'репо-слой: ' + key for key in ('novyj', 'drugoj')]
    return []


def actual(root, case):
    env = dict(os.environ, HARNESS_PROJECT_LAYER_ROOT=str(root))
    resolver = ROOT / 'scripts/profile_resolver.sh'
    command = ['bash', str(resolver), '--repo', str(root)]
    if case.group == 'get':
        env['HARNESS_PROJECT_LAYER_ROOT'] = str(root / 'absent-layer')
        # Source with the repository's conventional *_LIB=1 early-return seam.
        command = ['bash', '-c',
                   f'{LIB_FLAG}=1 source "$1" || exit $?; profile_get "$2" "$3" "$4"',
                   'm0-profile-get', str(resolver), str(root), case.get_path, 'fallback']
    result = subprocess.run(command, env=env, cwd=ROOT, capture_output=True, text=True)
    return result.returncode, result.stdout, result.stderr


def model(root, case, profile, layer, snapshot, stub=''):
    """Behavioral control, not a replacement resolver or a production transplant."""
    rc, out, err = 0, snapshot['stdout'], ''
    if case.group in ('invalid', 'missing'):
        rc, out, err = 1, '', 'profile ОТКАЗ: ' + case.reason + '\n'
    elif case.group == 'get':
        try:
            raw = json.loads((root / 'harness.project.json').read_text())
            value = raw
            for key in case.get_path.removeprefix('.').split('.'):
                value = value[key]
            out = (value if isinstance(value, str) else json.dumps(value)) + '\n'
        except (OSError, ValueError, KeyError, TypeError):
            out = 'fallback\n'
    else:
        err = ''.join(line + '\n' for line in warning_lines(case))
    if stub == 'S1-silent' and case.group in ('unknown', 'two'):
        err = ''
    elif stub == 'S2-leak' and case.group == 'unknown':
        leaked = json.loads(out)
        put(leaked, case.path, case.value)
        out = json.dumps(leaked) + '\n'
    elif stub == 'S3-invalid-accepted' and case.group == 'invalid':
        rc, out, err = 0, snapshot['stdout'], ''
    elif stub == 'S4-missing-accepted' and case.group == 'missing':
        rc, out, err = 0, snapshot['stdout'], ''
    elif stub == 'S5-root-only' and case.group == 'unknown' and len(case.path) > 1:
        rc, out, err = 1, '', 'profile ОТКАЗ: неизвестный ключ\n'
    elif stub == 'S6-layer-reader' and case.group == 'get':
        out = '999\n'
    elif stub == 'S6-broken-json' and case.name == 'm0-z-broken-json':
        rc, out, err = 4, '', 'jq: parse error\n'
    elif stub == 'S7-last-lost' and case.group == 'two':
        err = warning_lines(case)[0] + '\n'
    return rc, out, err


def judge(case, response, snapshot):
    rc, out, err = response
    if case.group in ('invalid', 'missing'):
        lines = err.splitlines()
        # Variable filesystem suffixes are allowed only after the named reason.
        return rc == 1 and out == '' and any(
            line.startswith('profile ОТКАЗ: ' + case.reason) for line in lines)
    if case.group == 'get':
        return rc == 0 and out == case.expected and err == ''
    if rc != 0 or Counter(err.splitlines()) != Counter(warning_lines(case)):
        return False
    if case.group == 'legacy':
        return out == snapshot['stdout']
    try:
        # Full structural equality: no unknown path or changed known value leaks.
        return json.loads(out) == json.loads(snapshot['stdout'])
    except ValueError:
        return False


def run(mode):
    # Read ALL expectations before invoking any candidate. Never reopen them afterward.
    snapshots = json.loads((HERE / 'm0_baseline.json').read_text())['profiles']
    failures = 0
    with tempfile.TemporaryDirectory(prefix='m0-184-') as tmp:
        base = Path(tmp)
        worlds = [(case, *prepare(base, case, snapshots)) for case in CASES]
        # layerRoot binds the environment. Instantiate that exact JSON string
        # before the candidate, retaining every other byte of the base output.
        expected = {}
        for case, root, _, _ in worlds:
            snapshot = dict(snapshots[case.label])
            old_root = json.loads(snapshot['stdout'])['projectLayer']['value']['layerRoot']
            snapshot['stdout'] = snapshot['stdout'].replace(json.dumps(old_root), json.dumps(str(root)))
            expected[case.name] = snapshot
        if mode == 'stabs':
            live = 0
            for stub, target in STABS.items():
                results = {}
                for case, root, profile, layer in worlds:
                    snapshot = expected[case.name]
                    control = model(root, case, profile, layer, snapshot)
                    if not judge(case, control, snapshot):
                        raise RuntimeError('honest control is red: ' + case.name)
                    results[case.name] = judge(case, model(root, case, profile, layer, snapshot, stub), snapshot)
                caught = not results[target]
                print(f'M0_STAB {stub}@{target}: {"caught" if caught else "LIVE"}')
                live += not caught
            print(f'M0_STABS={len(STABS)} LIVE={live}')
            return int(live != 0)
        for case, root, profile, layer in worlds:
            snapshot = expected[case.name]
            response = (actual(root, case) if mode == 'repo' else
                        model(root, case, profile, layer, snapshot))
            ok = judge(case, response, snapshot)
            print(f'CELL {case.name}: {"ok" if ok else "RED"} (subject_rc={response[0]})')
            if not ok:
                print('  OBSERVATION ' + json.dumps(dict(rc=response[0], stdout=response[1], stderr=response[2]),
                                                     ensure_ascii=False))
            failures += not ok
    print(f'M0_CELLS={len(CASES)} GREEN={len(CASES) - failures} RED={failures}')
    return int(failures != 0)
