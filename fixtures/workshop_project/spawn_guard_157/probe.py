#!/usr/bin/env python3
"""Installed spawn-guard task-hook probe for observed session layouts (157).

The accepted owner patch cf4054e8e is the reference for --model; this
worktree's hook is the live subject. Stub-to-cell mappings live in code.
"""
import json
import os
import shutil
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
SOURCE = REPO / '.omp/extensions/spawn-guard.ts'
PATCH = 'cf4054e8e'
START = 'function stateRoots(sessionFile: string): Roots | null {'
DENY = 'DOOR_DENY_157'
ZAMOK_BROKEN = 'ОТКАЗ: страж замка сломан (fail-closed)'
BROKEN = 'ОТКАЗ: страж замка сломан (fail-closed): файл сессии вне грамматики'

STATION = ('c907157c', 'dev')
STATION_ALT = ('different-session-58', 'audit')
TAIL = ('sessions', '--repo--', 'parent', 'Agent157.jsonl')
LIVE_PROJECT = '/home/harness/.local/state/dev-harness-projects/complior-back/home/.omp/profiles/dev/agent/sessions/--home-harness-projects-Complior-back--/2026-11-04T19-07-19-574Z_01a1a7f5-6496-7771-b675-52d247cccf05.jsonl'
LIVE_STATION = '/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--/2026-11-04T19-13-34-040Z_01a1a7fb-1b58-7367-a1bc-088197f6fe4d.jsonl'
LIVE_SUBAGENT = '/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--/2026-11-02T21-05-50-062Z_01a19e15-2bee-7741-aaa7-a4f74b1b4ab2/Arch158/Arch158.ScoutEkrany.jsonl'
PROJECT_TAIL = Path(LIVE_PROJECT).parts[-3:]
STATION_TAIL = Path(LIVE_STATION).parts[-3:]
SUBAGENT_TAIL = Path(LIVE_SUBAGENT).parts[-5:]


def reference():
    return subprocess.run(
        ['git', 'show', PATCH + ':.omp/extensions/spawn-guard.ts'],
        cwd=REPO, capture_output=True, text=True, check=True).stdout


# Every variant mutates an observable branch of the accepted patch (Н-39).
def mutation(source, name):
    if name == 'blind-root':
        anchor = 'const roots = stateRoots(sessionFile);'
        replacement = anchor + '\n      if (roots !== null) return undefined;'
    elif name == 'station-only':
        anchor = "const h = sessionFile.indexOf('/home/.omp/profiles/');"
        replacement = 'const h = -1;'
    elif name == 'project-only':
        anchor = "const z = sessionFile.indexOf('/zones/');"
        replacement = 'const z = -1;'
    elif name == 'env-root':
        anchor = "return { sost: sessionFile.slice(0, h) + '/state', zhurnaly: m[1] };"
        replacement = "return { sost: process.env.HARNESS_SESSION_HOME + '/state', zhurnaly: m[1] };"
    elif name == 'shadow-deny':
        anchor = START
        replacement = START + "\n  if (sessionFile.indexOf('/dev-harness-projects/shadow/') >= 0) return null;"
    elif name == 'rc2-pass':
        anchor = '        return { block: true, reason: ZAMOK_BROKEN };'
        replacement = ("        if (r.status === 2 && sessionFile.includes('/dev-harness-projects/'))"
                       " return undefined;\n" + anchor)
    else:
        raise ValueError('unknown mutant')
    if source.count(anchor) != 1:
        raise ValueError('NOT_IMPLEMENTED: mutant seam absent: ' + name)
    return source.replace(anchor, replacement, 1)


def snapshot(root):
    if not root.exists():
        return None
    return {str(path.relative_to(root)): (None if path.is_dir() else path.read_bytes())
            for path in root.rglob('*')}


def build(base, label, home_parts, profile, tail, state_parts):
    case_root = base / label
    install = case_root / 'installed'
    ext = install / '.omp/extensions/spawn-guard.ts'
    ext.parent.mkdir(parents=True)
    home = case_root.joinpath(*home_parts)
    session = home / '.omp/profiles' / profile / 'agent' / Path(*tail)
    session.parent.mkdir(parents=True)
    session.write_text('{}\n')
    state = case_root.joinpath(*state_parts) if state_parts else None
    return case_root, install, home, state


def case(base, guard, label, home_parts, profile, tail, state_parts, outcome, role='architect'):
    case_root, install, home, state = build(base, label, home_parts, profile, tail, state_parts)
    (install / '.omp/extensions/spawn-guard.ts').write_text(guard)
    cfg = install / 'config/agent_models.json'
    cfg.parent.mkdir(parents=True)
    cfg.write_text(json.dumps({'roles': {'architect': 'slow'}}))
    door = install / 'scripts/zamok_predmeta.sh'
    door.parent.mkdir(parents=True)
    door.write_text('#!/usr/bin/env bash\n'
                    'printf "%s\\0" "$@" > "$PROBE_DOOR_LOG"\n'
                    'if [ "$PROBE_DOOR_RESULT" = deny ]; then printf "DOOR_DENY_157\\n" >&2; exit 1; fi\n'
                    'if [ "$PROBE_DOOR_RESULT" = broken ]; then exit 2; fi\n'
                    'exit 0\n')
    if state is not None:
        state.mkdir(parents=True, exist_ok=True)
        (state / 'existing-lock.txt').write_text('LOCK_157\n')
    before_state = snapshot(state) if state else None
    before_tree = snapshot(case_root) if state is None else None
    log = case_root / 'door-argv.bin'
    env = dict(os.environ, PROBE_DOOR_LOG=str(log), HARNESS_SESSION_HOME=str(case_root / 'forged-home'))
    result = subprocess.run(['node', str(HERE / 'driver.mjs'), str(install / '.omp/extensions/spawn-guard.ts'),
                             str(home / '.omp/profiles' / profile / 'agent' / Path(*tail)), role, outcome],
                            cwd=case_root, env=env, capture_output=True, text=True, timeout=20)
    try:
        answer = json.loads(result.stdout.strip())
    except (ValueError, TypeError):
        raise AssertionError(f'{label}: driver rc={result.returncode}: {result.stdout} {result.stderr}')
    if result.returncode != 0:
        raise AssertionError(f'{label}: driver rc={result.returncode}: {result.stderr}')
    if state is None:
        # Третья форма: отказ ДО двери, замок не создаётся НИГДЕ — дерево
        # случая неизменно (кроме алфавитной клетки ниже).
        if role == 'task':
            assert answer.get('block') is True and 'спавн без явного agent' in answer.get('reason', ''), (label, answer)
        else:
            assert answer == {'block': True, 'reason': BROKEN}, (label, answer)
        assert not log.exists(), (label, 'door called for unknown layout')
        assert snapshot(case_root) == before_tree, (label, 'unknown layout wrote state')
        return
    if role == 'task':
        assert answer.get('block') is True and 'спавн без явного agent' in answer.get('reason', ''), (label, answer)
        assert not log.exists(), (label, 'alphabet bypass')
        assert snapshot(state) == before_state, (label, 'alphabet wrote state')
        return
    if outcome == 'deny':
        expected = {'block': True, 'reason': DENY}
    elif outcome == 'broken':
        expected = {'block': True, 'reason': ZAMOK_BROKEN}
    else:
        expected = {'pass': True}
    assert answer == expected, (label, expected, answer)
    assert log.exists(), (label, 'root returned without door check')
    args = log.read_bytes().split(b'\0')
    assert args[-1] == b'', (label, args)
    argv = [os.fsdecode(value) for value in args[:-1]]
    expected_argv = ['--sudit', '--sostojanie', str(state / 'zamok'), '--zhurnaly',
                     str(home / '.omp/profiles' / profile / 'agent/sessions'), '--repo', str(case_root)]
    assert argv[:len(expected_argv)] == expected_argv and len(argv) == len(expected_argv) + 1, (label, argv)
    assert Path(argv[-1]).parent == state, (label, 'event outside verified state root')
    assert not Path(argv[-1]).exists(), (label, 'event file not removed')
    assert snapshot(state) == before_state | {'zamok': None}, (label, 'wrong lock root or state changed')
    assert not (home / 'zamok').exists(), (label, 'lock orphaned in session home')


DOOR_CELLS_STATION = ('station-deny', 'station-allow', 'station-alt', 'station-profile',
                      'station-broken', 'station-real', 'subagent-real')
DOOR_CELLS_PROJECT = ('project-deny', 'project-allow', 'project-alt', 'project-profile',
                      'project-shadow', 'project-broken', 'project-real')


def scenarios():
    station = ('dev-harness-sessions', STATION[0], 'zones', STATION[1])
    station_state = ('dev-harness-sessions', STATION[0])
    station_alt = ('dev-harness-sessions', STATION_ALT[0], 'zones', STATION_ALT[1])
    project = ('dev-harness-projects', 'complior-back', 'home')
    project_state = ('dev-harness-projects', 'complior-back', 'state')
    # Preserve every observable component of the live absolute pathname
    # under the disposable case root; never write into live session storage.
    live_prefix = Path('/home/harness/.local/state').parts[1:]
    live_station = live_prefix + station
    live_station_state = live_prefix + station_state
    live_project = live_prefix + project
    live_project_state = live_prefix + project_state
    return [
        ('station-deny', station, 'dev', TAIL, station_state, 'deny', 'architect'),
        ('station-allow', station, 'dev', TAIL, station_state, 'allow', 'architect'),
        ('station-alt', station_alt, 'dev', TAIL, ('dev-harness-sessions', STATION_ALT[0]), 'deny', 'architect'),
        ('station-profile', station, 'back-profilit', TAIL, station_state, 'deny', 'architect'),
        ('station-broken', station, 'dev', TAIL, station_state, 'broken', 'architect'),
        ('station-real', live_station, 'dev', STATION_TAIL, live_station_state, 'deny', 'architect'),
        ('subagent-real', live_station, 'dev', SUBAGENT_TAIL, live_station_state, 'deny', 'architect'),
        ('project-deny', project, 'dev', TAIL, project_state, 'deny', 'architect'),
        ('project-allow', project, 'dev', TAIL, project_state, 'allow', 'architect'),
        ('project-alt', ('dev-harness-projects', 'another-backend-98', 'home'), 'dev', TAIL,
         ('dev-harness-projects', 'another-backend-98', 'state'), 'deny', 'architect'),
        ('project-profile', project, 'dev-profile-2', TAIL, project_state, 'deny', 'architect'),
        ('project-shadow', ('dev-harness-projects', 'shadow', 'home'), 'dev', TAIL,
         ('dev-harness-projects', 'shadow', 'state'), 'deny', 'architect'),
        ('project-real', live_project, 'dev', PROJECT_TAIL, live_project_state, 'deny', 'architect'),
        ('project-broken', project, 'dev', TAIL, project_state, 'broken', 'architect'),
        ('station-alphabet', station, 'dev', TAIL, station_state, 'deny', 'task'),
        ('foreign-deny', ('foreign-layout', 'flat'), 'dev', TAIL, None, 'deny', 'architect'),
        ('malformed-session', station, 'dev', ('history', 'Agent157.jsonl'), None, 'deny', 'architect'),
        ('project-alphabet', project, 'dev', TAIL, project_state, 'deny', 'task'),
    ]


def run(source, tag):
    failed = []
    all_scenarios = scenarios()
    with tempfile.TemporaryDirectory(prefix='spawn-guard-157-') as temp:
        for name, home, profile, tail, state, outcome, role in all_scenarios:
            try:
                case(Path(temp), source, name, home, profile, tail, state, outcome, role)
                print(f'CASE {tag} {name} OK')
            except (AssertionError, OSError, subprocess.TimeoutExpired) as error:
                failed.append(name)
                print(f'CASE {tag} {name} KRASNO: {error}')
    print(f'KLETKI {tag} {len(all_scenarios)} KRASNYH {len(failed)}')
    return set(failed)


def main():
    if (len(sys.argv) == 2 and sys.argv[1] not in ('--model', '--stabs')) or (
            len(sys.argv) == 3 and sys.argv[1] != '--revision') or len(sys.argv) > 3:
        print('usage: probe.py [--model|--stabs|--revision <commit>]', file=sys.stderr)
        return 2
    if not SOURCE.is_file():
        print('NOT_IMPLEMENTED: absent hook ' + str(SOURCE), file=sys.stderr)
        return 2
    if shutil.which('node') is None:
        print('NOT_IMPLEMENTED: node absent', file=sys.stderr)
        return 2
    source = SOURCE.read_text()
    try:
        if len(sys.argv) == 1:
            return int(bool(run(source, 'subject')))
        if len(sys.argv) == 3:
            revision = subprocess.run(
                ['git', 'show', sys.argv[2] + ':.omp/extensions/spawn-guard.ts'],
                cwd=REPO, capture_output=True, text=True, check=True).stdout
            return int(bool(run(revision, 'subject')))
        ref_source = reference()
        control = run(ref_source, 'model')
        if control:
            print('NOT_IMPLEMENTED: reference model failed', file=sys.stderr)
            return 2
        if sys.argv[1] == '--model':
            return 0
        targets = {
            'blind-root': set(DOOR_CELLS_STATION) | set(DOOR_CELLS_PROJECT),
            'station-only': set(DOOR_CELLS_PROJECT),
            'project-only': set(DOOR_CELLS_STATION),
            'env-root': set(DOOR_CELLS_PROJECT),
            'shadow-deny': {'project-shadow'},
            'rc2-pass': {'project-broken'},
        }
        for name, observed in targets.items():
            fails = run(mutation(ref_source, name), name)
            if not observed <= fails:
                print(f'STAB_ZHIV: {name}: expected {sorted(observed)}, got {sorted(fails)}', file=sys.stderr)
                return 1
        return 0
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print(str(error), file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
