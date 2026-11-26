#!/usr/bin/env python3
"""230: real JSONL -> models_actual -> real model door -> real verdict writer."""
import argparse
import ast
from dataclasses import dataclass
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = 'fcaff8bf2bc602bbe1fac7a6b7b507d84cc93041'
TERRA = 'openai-codex/gpt-6.1-terra'
SOL = 'openai-codex/gpt-6.1-sol'
DENIED = 'zai/glm-5.3'
SESSION = 'Judge230_A'
OID = 'd' * 64


@dataclass(frozen=True)
class Case:
    name: str
    kind: str = 'honest'
    flags: tuple = ('--tsv', '--bind')
    selected: str | None = SESSION
    rc: int = 0
    reason: str = ''
    role: str = 'adversary'
    style: str = 'compact'
    assigned: str | None = None
    dynamic: bool = False


def catalog():
    cases = [Case('terra-singleton'), Case('terra-bare', kind='bare'),
             Case('terra-tsv', flags=('--tsv',)),
             Case('fallback-tsv', kind='fallback', flags=('--tsv',)),
             Case('terra-bind-alias', flags=('--bind',)),
             Case('declared-fallback', kind='fallback'),
             Case('fallback-with-other-assignment', kind='fallback', assigned=DENIED),
             Case('per-call-configured', kind='per-call', assigned=DENIED),
             Case('changed-registry-primary', dynamic=True),
             Case('changed-registry-fallback', kind='fallback', dynamic=True),
             Case('denied-not-fallback', kind='drift', rc=1, reason='фолбэк вне списка тира'),
             Case('allowed-not-assigned', kind='allowed-drift', rc=1, reason='вердикт не материализуется'),
             Case('return-to-terra', kind='return', rc=1, reason='фолбэк вне списка тира'),
             Case('empty-jsonl', kind='empty', rc=2, reason='TRACE_EMPTY'),
             Case('broken-jsonl', kind='broken', rc=2, reason='TRACE_INVALID'),
             Case('broken-after-good', kind='broken-tail', rc=2, reason='TRACE_INVALID'),
             Case('event-missing-model', kind='missing-model', rc=2, reason='TRACE_INVALID'),
             Case('event-bad-boolean', kind='bad-bool', rc=2, reason='TRACE_INVALID'),
             Case('missing-session', selected='Absent230', rc=2, reason='сессия не найдена')]
    for flags, label in [(('--tsv',), 'tsv'), (('--tsv', '--bind'), 'bind'),
                         (('--bind',), 'bind-alias'), ((), 'human'), (('--all',), 'all-human')]:
        for kind in ('duplicate', 'duplicate-reverse', 'duplicate-allowed'):
            cases.append(Case(f'{kind}-{label}', kind=kind, flags=flags, rc=2, reason='SESSION_AMBIGUOUS'))
    cases.append(Case('duplicate-global-bind', kind='duplicate', selected=None, rc=2, reason='SESSION_AMBIGUOUS'))
    cases.extend([Case('exact-name-not-substring', kind='decoy'),
                  Case('leading-zero-distinct', kind='zero-decoy', selected='Judge000230'),
                  Case('long-name-distinct', kind='long-decoy', selected='J' * 240)])
    for name, value in [('slash', 'Judge/230'), ('colon', 'Judge:230'), ('tab', 'Judge\t230'),
                        ('unicode', 'Судья230')]:
        cases.append(Case('invalid-name-' + name, selected=value, rc=2, reason='session-id вне алфавита'))
    for style in ('spaces', 'reordered', 'runtime'):
        cases.append(Case('honest-' + style, style=style))
        cases.append(Case('drift-' + style, kind='drift', style=style, rc=1, reason='фолбэк вне списка тира'))
    for role in ('critic', 'reviewer', 'arbiter'):
        cases += [Case('honest-' + role, role=role),
                  Case('drift-' + role, kind='drift', role=role, rc=1, reason='фолбэк вне списка тира')]
    for kind, expected in [('suffix', 1), ('provider', 1), ('effort', 1)]:
        cases.append(Case('fallback-' + kind, kind=kind, rc=expected, reason='фолбэк вне списка тира'))
    return {c.name: c for c in cases}


CASES = catalog()


def run(args, cwd, env=None):
    result = subprocess.run(list(map(str, args)), cwd=cwd, env=env, capture_output=True, timeout=40)
    if result.returncode in (126, 127) or result.returncode < 0:
        raise RuntimeError('SUBJECT_EXECUTION: ' + result.stderr.decode(errors='replace'))
    return result


def put(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data if isinstance(data, bytes) else data.encode())


def install(repo, world, model, mutation=None):
    for rel in ('scripts/check_sud_model.sh', 'scripts/judge_gate.sh', 'scripts/roles.ts', 'scripts/models_actual.sh'):
        if model and rel != 'scripts/roles.ts' and rel != 'scripts/models_actual.sh':
            p = run(['git', '-C', repo, 'show', BASE + ':' + rel], repo)
            if p.returncode:
                raise RuntimeError('PIN_MISSING: ' + BASE + ':' + rel)
            data = p.stdout
        else:
            data = (repo / rel).read_bytes()
        put(world / rel, data)
        (world / rel).chmod(0o755)
    if model:
        put(world / 'scripts/models_actual.py', (HERE / 'model/models_actual.py').read_bytes())
        put(world / 'scripts/models_actual.sh', '#!/usr/bin/env bash\nexec python3 "$(dirname "$0")/models_actual.py" "$@"\n')
    cfg = json.loads((repo / 'config/agent_models.json').read_text())
    cfg['models'].update(test_primary=TERRA, test_fallback=SOL, test_other=DENIED)
    for spec in cfg['tiers'].values():
        spec.update(model='@test_primary', fallback='@test_fallback')
    put(world / 'config/agent_models.json', json.dumps(cfg))
    put(world / '.omp/agents/architect.md', 'model: ["@slow"]\n')
    put(world / '.omp/config.yml', 'modelRoles:\n  slow: "' + TERRA + '"\n')
    put(world / 'registry/candidates.tsv', b'# retained journal\n')
    put(world / 'verdict.md', 'accept\n')
    if mutation:
        target = world / mutation['file']
        text = target.read_text()
        for change in mutation.get('changes', [mutation]):
            if text.count(change['old']) != 1:
                raise RuntimeError('STAB_ANCHOR: ' + mutation['name'])
            text = text.replace(change['old'], change['new'])
        put(target, text)
        if target.suffix == '.py':
            ast.parse(text)
        elif run(['bash', '-n', target], world).returncode:
            raise RuntimeError('STAB_SYNTAX: ' + mutation['name'])
    for command in (['git', 'init', '-q', world], ['git', '-C', world, '-c', 'user.name=architect', '-c',
                    'user.email=architect@dev-harness.local', '-c', 'core.hooksPath=/dev/null',
                    'commit', '-q', '--allow-empty', '-m', '230 autonomous trace world']):
        if run(command, repo).returncode:
            raise RuntimeError('WORLD_GIT')
    p = run(['git', '-C', world, 'rev-parse', 'HEAD'], world)
    return p.stdout.decode().strip()


def observe(repo, world, c, model, mutation=None):
    object_id = install(repo, world, model, mutation)
    primary, fallback = TERRA, SOL
    if c.dynamic:
        primary, fallback = 'vendor/changed-0009:high@route', 'vendor/backup-0010:low@route'
        cfg_path = world / 'config/agent_models.json'
        cfg = json.loads(cfg_path.read_text())
        cfg['models'].update(test_primary=primary, test_fallback=fallback)
        put(cfg_path, json.dumps(cfg))
    session = c.selected or SESSION
    if c.kind == 'zero-decoy':
        session = 'Judge000230'
    zone = world / 'zone'
    zone.mkdir()
    events = [dict(type='session', parentSession='Parent230'),
              dict(type='message', message=dict(role='user', content=[dict(type='text', text='OBJECT=' + object_id)])),
              dict(type='message', message=dict(role='assistant', agent=c.role)),
              dict(type='model_change', model=primary, resolvedModelIsFallback=False)]
    if c.assigned is not None:
        events[-1]['model'] = c.assigned
    changes = []
    if c.kind in ('drift', 'return', 'allowed-drift'):
        changes.append(dict(type='model_change', model=DENIED, resolvedModelIsFallback=c.kind != 'allowed-drift'))
    if c.kind == 'return':
        changes.append(dict(type='model_change', model=primary, resolvedModelIsFallback=False))
    if c.kind in ('fallback', 'suffix', 'provider', 'effort'):
        value = {'fallback': fallback, 'suffix': fallback + '-extra', 'provider': 'other/' + fallback.split('/')[1],
                 'effort': fallback + ':xhigh'}[c.kind]
        changes.append(dict(type='model_change', model=value, resolvedModelIsFallback=True))
    if c.kind == 'bare':
        events[-1]['model'] = primary.split('/')[1]
    if c.kind == 'per-call':
        events[-1]['model'] = DENIED
    events += changes
    if c.kind == 'missing-model':
        events.append(dict(type='model_change', resolvedModelIsFallback=True))
    if c.kind == 'bad-bool':
        events.append(dict(type='model_change', model=DENIED, resolvedModelIsFallback='true'))

    def encode(rows):
        rendered = []
        for original in rows:
            event = dict(original)
            if c.style == 'reordered':
                event = dict(reversed(list(event.items())))
            if c.style == 'runtime' and event.get('type') == 'model_change':
                event = dict(type='model_change', runtime=dict(version='18.18.8', nested=dict(ok=True)),
                             model=event['model'], resolvedModelIsFallback=event['resolvedModelIsFallback'])
            rendered.append(json.dumps(event, separators=(', ', ': ') if c.style == 'spaces' else (',', ':')))
        return '\n'.join(rendered) + '\n'

    path = zone / '2026-11-25' / (SESSION + '.jsonl' if c.name == 'missing-session' else session + '.jsonl')
    if c.name.startswith('invalid-name-'):
        path = zone / '2026-11-25' / (SESSION + '.jsonl')
    put(path, encode(events))
    if c.kind.startswith('duplicate'):
        second = zone / '2026-11-23' / (session + '.jsonl')
        other = events + ([] if c.kind == 'duplicate-allowed' else [dict(type='model_change', model=DENIED, resolvedModelIsFallback=True)])
        put(second, encode(other))
        os.utime(path, (100, 100))
        os.utime(second, (200 if c.kind == 'duplicate-reverse' else 50,) * 2)
    if c.kind in ('decoy', 'zero-decoy', 'long-decoy'):
        decoy_name = {'decoy': session + '-suffix', 'zero-decoy': 'Judge230', 'long-decoy': session[:-1]}[c.kind]
        put(zone / '2026-11-26' / (decoy_name + '.jsonl'), encode(events + [dict(type='model_change', model=DENIED, resolvedModelIsFallback=True)]))
    if c.kind == 'empty':
        put(path, '')
    elif c.kind == 'broken':
        put(path, '{bad json\n')
    elif c.kind == 'broken-tail':
        put(path, path.read_bytes() + b'{broken\n')
    before = (world / 'registry/candidates.tsv').read_bytes()
    expected_journal = before + (f'verdict\t230\t{OID}\taccept\t1\n'.encode() if c.rc == 0 else b'')
    expected_rows = []
    for event in events:
        if event.get('type') == 'model_change' and isinstance(event.get('model'), str):
            fields = [c.role, event['model'], 'denied' if event['resolvedModelIsFallback'] is True else 'allowed']
            expected_rows.append('\t'.join(fields + ([session, object_id] if '--bind' in c.flags else [])))
    expected_trace = ('\n'.join(expected_rows) + '\n').encode()
    ambiguity_paths = [str(path).encode(), str(second).encode()] if c.kind.startswith('duplicate') else []
    env = dict(os.environ, HARNESS_SESSION_HOME=str(zone), GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null')
    command = ['bash', world / 'scripts/models_actual.sh', *c.flags]
    if c.selected is not None:
        command += ['--session', c.selected]
    produced = run(command, world, env)
    if produced.returncode:
        diagnostic = all(name in produced.stderr for name in ambiguity_paths)
        return produced, before == (world / 'registry/candidates.tsv').read_bytes(), produced.stdout == b'' and diagnostic
    if not c.flags:
        return produced, True, True
    trace = world / 'trace.tsv'
    put(trace, produced.stdout)
    exact_trace = produced.stdout == expected_trace
    if '--bind' not in c.flags:
        return produced, before == (world / 'registry/candidates.tsv').read_bytes(), exact_trace
    argv = ['bash', world / 'scripts/judge_gate.sh', object_id, '--verdict-row', '230', OID,
            world / 'verdict.md', '--sud', c.role, trace, session]
    if c.assigned is not None:
        argv += ['--assigned-model', c.assigned]
    result = run(argv, world, env)
    return result, (world / 'registry/candidates.tsv').read_bytes() == expected_journal, exact_trace


def check(repo, c, model, mutation=None):
    with tempfile.TemporaryDirectory(prefix='arch230-') as temp:
        p, effect, projection = observe(repo, Path(temp), c, model, mutation)
    ok = p.returncode == c.rc and (not c.reason or c.reason.encode() in p.stderr) and effect and projection
    return ok, f'rc={p.returncode}/{c.rc} journal={effect} projection={projection} stderr={p.stderr.decode(errors="replace").strip()}'


def mutations():
    entries = json.loads((HERE / 'source.json').read_text())
    return [json.loads((HERE / entry['stub']).read_text()) if 'stub' in entry else entry for entry in entries]


def main():
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--repo', nargs='?', const='.')
    for name in ('model', 'stabs', 'sintaksis', 'catalog'):
        mode.add_argument('--' + name, action='store_true')
    parser.add_argument('--case', choices=CASES)
    parser.add_argument('--source-root', type=Path, help='Read candidates/pins from an origin-only clean clone')
    args = parser.parse_args()
    repo = args.source_root.resolve() if args.source_root else (Path(args.repo).resolve() if args.repo else ROOT)
    for binary in ('bash', 'git', 'jq', 'node', 'python3'):
        if shutil.which(binary) is None:
            raise RuntimeError('DEPENDENCY_MISSING: ' + binary)
    definitions = mutations()
    if args.catalog:
        assert CASES and definitions and len({m['name'] for m in definitions}) == len(definitions)
        assert all(m['cases'] and all(c in CASES for c in m['cases']) for m in definitions)
        for c in CASES:
            print(c)
        print(f'KLETKI={len(CASES)} STABS={len(definitions)} SVJAZI={sum(len(m["cases"]) for m in definitions)}')
        return 0
    if args.sintaksis:
        for path in HERE.rglob('*.py'):
            ast.parse(path.read_text())
        wrapper = HERE / 'red_sud_model_drift_230.sh'
        for argv in (['bash', '-n', wrapper], ['bash', repo / 'scripts/validate_std.sh', 'bash', wrapper]):
            p = run(argv, repo)
            if p.returncode:
                sys.stderr.buffer.write(p.stderr + p.stdout)
                return 2
        return 0
    if args.stabs:
        bad = 0
        # Honest controls are run first; broken checking is never a killed mutant.
        for c in CASES.values():
            ok, detail = check(repo, c, True)
            if not ok:
                raise RuntimeError('HONEST_CONTROL: ' + c.name + ': ' + detail)
        for mutation in definitions:
            caught = []
            for name in mutation['cases']:
                ok, _ = check(repo, CASES[name], True, mutation)
                caught.append(not ok)
            alive = not all(caught)
            bad += alive
            print('STAB', mutation['name'], 'ZHIV' if alive else 'KRASNYJ', flush=True)
        print(f'STABS={len(definitions)} ZHIVYH={bad}')
        return int(bad != 0)
    bad = 0
    chosen = [CASES[args.case]] if args.case else CASES.values()
    for c in chosen:
        ok, detail = check(repo, c, args.model)
        bad += not ok
        print(('ZELENO' if ok else 'KRASNO') + ' ' + c.name + ('' if ok else ': ' + detail), flush=True)
    print(f'KLETKI={1 if args.case else len(CASES)} KRASNYH={bad}')
    return int(bad != 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError, ValueError, SyntaxError, subprocess.TimeoutExpired) as error:
        print('NOT_IMPLEMENTED:', error, file=sys.stderr)
        sys.exit(2)
