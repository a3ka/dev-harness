#!/usr/bin/env python3
"""M-0 public seams: resolver CLI and sourced profile_get, not private helpers."""
from collections import Counter
from copy import deepcopy
from dataclasses import dataclass
import json
import os
from pathlib import Path
import pty
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


# Rev184M0: the same public CLI, now through its real 2>&1 consumers.
CONSUMERS = {
    'b1a-ci': 'gen_ci_workflow.sh',
    'b1b-merge': 'check_merge_gate.sh',
    'b1v-connection': 'check_project_connection.sh',
}
M0B_CASES = (
    *((f'm0-{name}-{scope}', 'consumer', scope, script)
      for name, script in CONSUMERS.items() for scope in ('repo', 'project')),
    *((f'm0-b1g-warning-{scope}', 'warning', scope, '')
      for scope in ('repo', 'project')),
    *((f'm0-b1d-merged-{scope}', 'merged', scope, '')
      for scope in ('repo', 'project')),
    ('m0-b2a-context-leak', 'context', 'leak', ''),
    ('m0-b2b-context-order0', 'context', 'order0', ''),
    ('m0-b2b-context-order1', 'context', 'order1', ''),
    ('m0-b2v-context-override', 'context', 'override', ''),
)
# Each binding is exercised independently; unrelated redness never catches a stub.
M0B_STABS = {
    'Sa-merged-warning': tuple(c[0] for c in M0B_CASES if c[1] in ('consumer', 'merged')),
    'Sb-warning-lost': tuple(c[0] for c in M0B_CASES if c[1] == 'warning'),
    'Sv-context-leak': ('m0-b2a-context-leak',),
    'Sg-context-rebuilt': ('m0-b2b-context-order0', 'm0-b2b-context-order1'),
}
CONTEXT_ORDERS = (
    ('lessonsPath', 'rows', 'adrPath'),
    ('adrPath', 'lessonsPath', 'rows'),
)
CONTEXT_VALUES = {
    'rows': [{'kind': 'map', 'path': 'map.md'}],
    'adrPath': 'adr',
    'lessonsPath': 'lessons.md',
}


def prepare_m0b(base, cell, snapshots):
    name, group, scope, script = cell
    root, profile, layer = prepare(base, Case(name, 'legacy'), snapshots)
    if group == 'context':
        profile.pop('contextPack', None)
        order = CONTEXT_ORDERS[scope == 'order1']
        layer['defaults'] = {'contextPack': {k: deepcopy(CONTEXT_VALUES[k]) for k in order}}
        if scope == 'override':
            profile['contextPack'] = {'rows': [{'kind': 'rules', 'path': 'repo.md'}],
                                      'adrPath': 'repo-adr'}
    if group == 'consumer':
        for value in profile['workflowPaths'].values():
            (root / value).mkdir(parents=True, exist_ok=True)
        for source in profile['sourceCanon']['sources']:
            target = root / source['path']
            target.parent.mkdir(parents=True, exist_ok=True)
            target.touch()
        target = root / 'tests/tools/gen-contracts.js'
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text('process.exit(0);\n')
        (root / 'package.json').write_text(json.dumps({'scripts': {
            k: 'node tests/tools/gen-contracts.js' for k in ('test', 'smoke:image', 'lint')}}))
        verdict = root / profile['workflowPaths']['verdicts'] / 'review/control.md'
        verdict.parent.mkdir(parents=True, exist_ok=True)
        verdict.write_text('accept\n')
        git_env = dict(os.environ, GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null')
        for args in (('init', '-q'), ('remote', 'add', 'origin', profile['git']['canonicalRemote']),
                     ('add', '.'), ('-c', 'user.name=architect',
                                   '-c', 'user.email=architect@dev-harness.local',
                                   'commit', '-qm', '184 fixture control')):
            subprocess.run(['git', '-C', str(root), *args], env=git_env,
                           check=True, capture_output=True)
    (root / 'harness.project.json').write_text(json.dumps(profile))
    (root / profile['projectLayer']['profilePath']).write_text(json.dumps(layer))
    return root, profile, layer


def dirty_m0b(root, cell, profile, layer):
    _, group, scope, _ = cell
    if group == 'context':
        if scope in ('leak', 'override'):
            layer['defaults']['contextPack']['rowz'] = 'typo'
    else:
        # pack is one unknown root name; maxBytes is its project-owned payload.
        target = layer.setdefault('defaults', {}) if scope == 'project' else profile
        target['pack'] = {'maxBytes': 40000}
    (root / 'harness.project.json').write_text(json.dumps(profile))
    (root / profile['projectLayer']['profilePath']).write_text(json.dumps(layer))


def actual_m0b(root, cell, profile):
    _, group, _, script = cell
    resolver = ROOT / 'scripts/profile_resolver.sh'
    command = ['bash', str(resolver), '--repo', str(root)]
    if group == 'consumer':
        command = ['bash', str(ROOT / 'scripts' / script), '--repo', str(root)]
    elif group == 'merged':
        # Real descriptor alias, not concatenation of separately captured strings.
        command = ['bash', '-c', 'exec bash "$1" --repo "$2" 2>&1',
                   'm0-merged', str(resolver), str(root)]
    response = subprocess.run(command, cwd=ROOT, capture_output=True,
                              env=dict(os.environ, HARNESS_PROJECT_LAYER_ROOT=str(root)))
    # Decode without universal-newline conversion: CRLF must not equal LF.
    workflow = (root / profile['ci']['workflow']).read_bytes().decode() if group == 'consumer' else ''
    return response.returncode, response.stdout.decode(), response.stderr.decode(), workflow


def expected_m0b(cell, root, oracle):
    _, group, scope, script = cell
    if group == 'consumer':
        return tuple(oracle['consumers'][script])
    key = scope if group == 'context' and scope not in ('leak',) else 'order0'
    if group != 'context':
        key = 'plain'
    out = oracle['context'][key].replace(json.dumps('${M0B_ROOT}'), json.dumps(str(root)))
    err = ''
    if group == 'warning':
        err = WARNING + ('слой-проекта: defaults.pack' if scope == 'project' else 'репо-слой: pack') + '\n'
    elif group == 'context' and scope in ('leak', 'override'):
        err = WARNING + 'слой-проекта: defaults.contextPack.rowz\n'
    return 0, out, err, ''


def judge_m0b(cell, response, expected):
    if cell[1] != 'consumer':
        return response == expected
    rc, out, err, workflow = response
    warning = WARNING + ('слой-проекта: defaults.pack' if cell[2] == 'project' else 'репо-слой: pack') + '\n'
    # Consumers may forward the warning separately, but never parse it as JSON.
    return (rc, out, workflow) == (expected[0], expected[1], expected[3]) and err in ('', warning)


def mutate_m0b(cell, response, stub):
    _, group, scope, _ = cell
    rc, out, err, workflow = response
    if stub == 'Sa-merged-warning' and group in ('consumer', 'merged'):
        warning = WARNING + ('слой-проекта: defaults.pack' if scope == 'project' else 'репо-слой: pack') + '\n'
        if group == 'merged':
            out = warning + out
        elif cell[3] == 'gen_ci_workflow.sh':
            workflow, err = '', 'ci-генератор: профиль не объявляет ci.workflow — генерировать некуда\n'
        else:
            rc, err = 1, 'profile JSON parse failed\n'
    elif stub == 'Sb-warning-lost' and group == 'warning':
        err = ''
    elif stub == 'Sv-context-leak' and scope == 'leak':
        data = json.loads(out)
        data['contextPack']['value']['rowz'] = 'typo'
        out = json.dumps(data, ensure_ascii=False, indent=2) + '\n'
    elif stub == 'Sg-context-rebuilt' and scope in ('order0', 'order1'):
        data = json.loads(out)
        value = data['contextPack']['value']
        data['contextPack']['value'] = {k: value[k] for k in ('rows', 'adrPath', 'lessonsPath')}
        out = json.dumps(data, ensure_ascii=False, indent=2) + '\n'
    return rc, out, err, workflow


def run_m0b(mode, snapshots):
    # Frozen clean OBJECT outputs, loaded before invoking any candidate.
    oracle = json.loads((HERE / 'm0b_baseline.json').read_text())
    with tempfile.TemporaryDirectory(prefix='m0b-184-') as tmp:
        worlds = [(cell, *prepare_m0b(Path(tmp), cell, snapshots)) for cell in M0B_CASES]
        expectations = {cell[0]: expected_m0b(cell, root, oracle)
                        for cell, root, _, _ in worlds}
        if mode == 'stabs':
            live = 0
            for stub, targets in M0B_STABS.items():
                for target in targets:
                    cell = next(c for c in M0B_CASES if c[0] == target)
                    expected = expectations[target]
                    if not judge_m0b(cell, expected, expected):
                        raise RuntimeError('honest M0B control is red: ' + target)
                    if cell[1] == 'consumer':
                        warning = WARNING + ('слой-проекта: defaults.pack' if cell[2] == 'project' else 'репо-слой: pack') + '\n'
                        forwarded = (expected[0], expected[1], warning, expected[3])
                        if not judge_m0b(cell, forwarded, expected):
                            raise RuntimeError('forwarded warning is red: ' + target)
                    caught = not judge_m0b(cell, mutate_m0b(cell, expected, stub), expected)
                    print(f'M0B_STAB {stub}@{target}: {"caught" if caught else "LIVE"}')
                    live += not caught
            print(f'M0B_STABS={len(M0B_STABS)} LIVE={live}')
            return int(live != 0)
        failures = 0
        for cell, root, profile, layer in worlds:
            expected = expectations[cell[0]]
            control = actual_m0b(root, cell, profile) if mode == 'repo' else (
                expected if cell[1] == 'consumer' else (0, expected[1], '', ''))
            # Clean controls must succeed; the generator must really write CI.
            clean_expected = expected if cell[1] == 'consumer' else (0, expected[1], '', '')
            control_ok = control == clean_expected and control[0] == 0
            if cell[1] == 'consumer':
                control_ok &= control[1] == ''
                if cell[3] == 'gen_ci_workflow.sh':
                    control_ok &= len(control[3].encode()) > 0
                # Reset file to its initial empty state before the dirty invocation.
                (root / profile['ci']['workflow']).write_text('')
            dirty_m0b(root, cell, profile, layer)
            response = actual_m0b(root, cell, profile) if mode == 'repo' else expected
            ok = control_ok and judge_m0b(cell, response, expected)
            print(f'CELL {cell[0]}: {"ok" if ok else "RED"} (subject_rc={response[0]})')
            if not ok:
                print('  M0B_OBSERVATION ' + json.dumps(dict(
                    control=control, expected=expected, actual=response), ensure_ascii=False))
            failures += not ok
        print(f'M0B_CELLS={len(M0B_CASES)} GREEN={len(M0B_CASES) - failures} RED={failures}')
        return int(failures != 0)


# Rev184M0Д (блок Б-3 вердикта Rev184M0b): терминал оператора — fd1 и fd2 на
# ОДНОМ pty — обязан показывать строку предупреждения; захваты со слитыми
# каналами (труба `$(… 2>&1)`, fifo инструмента агента) остаются побайтно
# чистыми (Б-1 не возвращается). Свойства (а2) и (а3) НЕ дублируются: слитый
# захват — m0-b1d-merged-*, журнал PROFILE_RESOLVER_WARN_FILE — семья
# fixtures/profile_resolver, раздельные потоки — m0-b1g-warning-* и m0-a-*.
PTY_WARNING = WARNING + 'репо-слой: pack'
M0D_CASES = (
    ('m0-b3a-pty-terminal', 'pty', 'dirty'),  # (а1): fd0=fd1=fd2=slave pty, pack.maxBytes
    ('m0-b3a-pty-clean', 'pty', 'clean'),     # (а4): охранная — pty на чистом профиле
    ('m0-b3a-pty-split', 'split', 'dirty'),   # (а5): охранная — fd1=pty, fd2=файл
)
# Н-39: каждый стаб привязан к единственному входу, где он РАЗЛИЧИМ с честной
# реализацией; объединённый case не засчитывается по первой красной точке.
M0D_STABS = {
    # Поведение OBJECT: при fd1==fd2 строка НИКОГДА не попадает на терминал —
    # различим только на (а1); на merged/split входах он совпадает с честным.
    'S-pty': ('m0-b3a-pty-terminal',),
    # Поведение вызова 1 (11dfc5a64f): строка на stderr ВСЕГДА; в слитом
    # захвате она приходит в общий поток — различим только на (а2) = merged.
    'S-pipe': ('m0-b1d-merged-repo', 'm0-b1d-merged-project'),
    # Наивная проверка `-t 8` без различения dev:inode: pty-stdout с файлом-
    # stderr прочитаны как «слитые», строка потеряна — различим только на (а5).
    'S-all': ('m0-b3a-pty-split',),
}


def conformant_stdout(snapshots, root):
    """Чистый stdout этого мира: замороженный снимок, заменён только полный
    JSON-токен временного layerRoot — той же подстановкой, что в run()."""
    snapshot = snapshots['back']['stdout']
    old_root = json.loads(snapshot)['projectLayer']['value']['layerRoot']
    return snapshot.replace(json.dumps(old_root), json.dumps(str(root)))


def run_on_pty(command, env, stderr_path=None):
    """Живой терминал: fd0=fd1=fd2=slave pty (при stderr_path — fd2=файл)."""
    master, slave = pty.openpty()
    err_file = open(stderr_path, 'wb') if stderr_path else None
    proc = subprocess.Popen(command, stdin=slave, stdout=slave,
                            stderr=err_file or slave, env=env, cwd=str(ROOT))
    os.close(slave)
    chunks = []
    while True:
        try:
            data = os.read(master, 65536)
        except OSError:  # Linux: EIO, когда закрыт последний slave-дескриптор
            break
        if not data:
            break
        chunks.append(data)
    os.close(master)
    rc = proc.wait()
    err_text = None
    if err_file is not None:
        err_file.close()
        err_text = Path(stderr_path).read_text(errors='replace')
    return rc, b''.join(chunks).decode(errors='replace'), err_text


def actual_m0d(root, cell, base):
    stderr_path = base / (cell[0] + '.stderr') if cell[1] == 'split' else None
    env = dict(os.environ, HARNESS_PROJECT_LAYER_ROOT=str(root))
    env.pop('PROFILE_RESOLVER_WARN_FILE', None)
    env.pop(LIB_FLAG, None)
    resolver = ROOT / 'scripts/profile_resolver.sh'
    return run_on_pty(['bash', str(resolver), '--repo', str(root)], env, stderr_path)


def model_m0d(cell, expected_json, stub=''):
    """Поведенческий контроль ИСПРАВЛЕННОЙ двери на терминале, не пересадка."""
    _, group, scope = cell
    on_terminal = group == 'pty' and scope == 'dirty'
    err_text = PTY_WARNING + '\n' if group == 'split' and scope == 'dirty' else None
    # Замер вызова 1 (11dfc5a64f): строка приходит на терминал ДО JSON.
    terminal = ((PTY_WARNING + '\n') if on_terminal else '') + expected_json
    if stub == 'S-pty' and group == 'pty' and scope == 'dirty':
        terminal = expected_json
    elif stub == 'S-all' and group == 'split' and scope == 'dirty':
        err_text = ''
    return 0, terminal, err_text


def judge_m0d(cell, response, expected_json):
    _, group, scope = cell
    rc, terminal, err_text = response
    # Терминальные \r снимаются ДО сверки — приказ задания (а1).
    text = terminal.replace('\r', '')
    warn = [line for line in text.splitlines() if line.startswith(WARNING)]
    payload = '\n'.join(line for line in text.splitlines() if not line.startswith(WARNING))
    try:
        same = json.loads(payload) == json.loads(expected_json)
    except ValueError:
        same = False
    if group == 'pty':
        wanted = [PTY_WARNING] if scope == 'dirty' else []
        return rc == 0 and warn == wanted and same
    # (а5): строка — в файле stderr, на терминале её нет.
    return rc == 0 and warn == [] and same and err_text == PTY_WARNING + '\n'


def run_m0d(mode, snapshots):
    oracle = json.loads((HERE / 'm0b_baseline.json').read_text())
    with tempfile.TemporaryDirectory(prefix='m0d-184-') as tmp:
        base = Path(tmp)
        worlds = []
        for cell in M0D_CASES:
            root, profile, _ = prepare(base, Case(cell[0], 'legacy'), snapshots)
            if cell[2] == 'dirty':
                # Один неизвестный ключ репо-слоя, как в замере судьи Б-3.
                profile['pack'] = {'maxBytes': 40000}
                (root / 'harness.project.json').write_text(json.dumps(profile))
            worlds.append((cell, root, conformant_stdout(snapshots, root)))
        if mode == 'stabs':
            live = 0
            for stub, targets in M0D_STABS.items():
                for target in targets:
                    if stub == 'S-pipe':
                        # (а2) — переиспользованные merged-клетки семьи M0B.
                        cell = next(c for c in M0B_CASES if c[0] == target)
                        root, _, _ = prepare_m0b(base, cell, snapshots)
                        expected = expected_m0b(cell, root, oracle)
                        if not judge_m0b(cell, expected, expected):
                            raise RuntimeError('honest M0B control is red: ' + target)
                        warning = WARNING + ('слой-проекта: defaults.pack'
                                             if cell[2] == 'project' else 'репо-слой: pack') + '\n'
                        # Вызов 1: строка на stderr всегда — в слитом захвате
                        # она приходит в общий поток ДО JSON.
                        mutated = (expected[0], warning + expected[1], expected[2], expected[3])
                        caught = not judge_m0b(cell, mutated, expected)
                    else:
                        cell = next(c for c in M0D_CASES if c[0] == target)
                        expected_json = next(text for c, _, text in worlds if c[0] == target)
                        honest = model_m0d(cell, expected_json)
                        if not judge_m0d(cell, honest, expected_json):
                            raise RuntimeError('honest M0D control is red: ' + target)
                        caught = not judge_m0d(
                            cell, model_m0d(cell, expected_json, stub), expected_json)
                    print(f'M0D_STAB {stub}@{target}: {"caught" if caught else "LIVE"}')
                    live += not caught
            print(f'M0D_STABS={len(M0D_STABS)} LIVE={live}')
            return int(live != 0)
        failures = 0
        for cell, root, expected_json in worlds:
            response = (actual_m0d(root, cell, base) if mode == 'repo'
                        else model_m0d(cell, expected_json))
            ok = judge_m0d(cell, response, expected_json)
            print(f'CELL {cell[0]}: {"ok" if ok else "RED"} (subject_rc={response[0]})')
            if not ok:
                rc, terminal, err_text = response
                text = terminal.replace('\r', '')
                warn = [line for line in text.splitlines() if line.startswith(WARNING)]
                print('  M0D_OBSERVATION ' + json.dumps(dict(
                    rc=rc, warning_on_terminal=warn, stderr_file=err_text,
                    terminal_head=text[:120]), ensure_ascii=False))
            failures += not ok
        print(f'M0D_CELLS={len(M0D_CASES)} GREEN={len(M0D_CASES) - failures} RED={failures}')
        return int(failures != 0)


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
            return int(live != 0) | run_m0b(mode, snapshots) | run_m0d(mode, snapshots)
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
    return int(failures != 0) | run_m0b(mode, snapshots) | run_m0d(mode, snapshots)
