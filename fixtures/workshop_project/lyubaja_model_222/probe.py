#!/usr/bin/env python3
"""222: public model gates, installed hook and real registry generator.

Expected rc/effects are literals in Case, captured before invoking the subject.
No network/model requests. The hook is the real exported omp handler (104 seam),
not a replacement predicate. Its subject-lock layer is outside this model seam.
"""
import argparse
import ast
import importlib.util
from dataclasses import dataclass
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import re
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
OBJECT = 'a' * 40
OTHER_OBJECT = 'b' * 40
SESSION = 'Judge222_A'
FACT = 'other-vendor/other-family-9'
BASE = 'primary-vendor/base-1'
FALLBACK = 'reserve-vendor/reserve-2'
EFFORT = 'other-vendor/other-family-9:xhigh'
SUBSTR = 'other-vendor/other-family'
SUBSTR_SUFFIX = 'vendor/other-family-9'
CASE_FACT = 'Primary-Vendor/Base-1'
ROLES = ('critic', 'adversary', 'reviewer', 'arbiter')
NEIGHBOUR_198 = 'fixtures/workshop_project/modeli_tolko_v_reestre_198'
# 222 supersedes exactly these spawn-leg cells of frozen family 198 (declared model is accepted on spawn).
SUPERSEDED_198 = frozenset(('door_spawn_fallback_refused', 'door_spawn_foreign_refused', 'door_stale_primary'))


@dataclass(frozen=True)
class Case:
    name: str
    kind: str
    role: str = 'critic'
    model: str = FACT
    assigned: str | None = None
    expected: int = 0
    reason: bytes = b''
    session: str = SESSION
    object: str = OBJECT
    status: str = 'allowed'
    config: str = 'valid'
    second: bool = False
    missing: bool = False


def cases():
    out = []
    for role in ROLES:
        out.extend((Case(f'spawn-{role}-other-family', 'spawn', role),
                    Case(f'verdict-{role}-per-call', 'verdict', role, assigned=FACT),
                    Case(f'gate-{role}-per-call', 'gate', role, assigned=FACT)))
    out.extend((
        Case('spawn-primary', 'spawn', model=BASE),
        Case('spawn-manual-fallback', 'spawn', model=FALLBACK),
        Case('spawn-effort', 'spawn', model=EFFORT),
        Case('verdict-effort', 'verdict', model=EFFORT, assigned=EFFORT),
        Case('verdict-effort-fact-truncated', 'verdict', model=FACT, assigned=EFFORT, expected=1, reason='вердикт не материализуется'.encode()),
        Case('verdict-effort-fact-extended', 'verdict', model=EFFORT, assigned=FACT, expected=1, reason='вердикт не материализуется'.encode()),
        Case('gate-effort-fact-truncated', 'gate', model=FACT, assigned=EFFORT, expected=1, reason='вердикт не материализуется'.encode()),
        Case('spawn-substring-of-declared', 'spawn', model=SUBSTR, expected=1, reason='модель не объявлена'.encode()),
        Case('verdict-assigned-substring-undeclared', 'verdict', model=FACT, assigned=SUBSTR, expected=2, reason='назначенная модель не объявлена'.encode()),
        Case('spawn-suffix-of-declared', 'spawn', model=SUBSTR_SUFFIX, expected=1, reason='модель не объявлена'.encode()),
        Case('verdict-assigned-suffix-undeclared', 'verdict', model=FACT, assigned=SUBSTR_SUFFIX, expected=2, reason='назначенная модель не объявлена'.encode()),
        Case('verdict-fact-case', 'verdict', model=CASE_FACT, expected=1, reason='вердикт не материализуется'.encode()),
        Case('gate-fact-case', 'gate', model=CASE_FACT, expected=1, reason='вердикт не материализуется'.encode()),
        Case('verdict-object-dash', 'verdict', model=BASE, object='-', expected=1, reason='трасса не об объекте суда'.encode()),
        Case('gate-object-dash', 'gate', model=BASE, object='-', expected=1, reason='трасса не об объекте суда'.encode()),
        Case('sosed-198-door-cells', 'sosed'),
        Case('verdict-primary', 'verdict', model=BASE),
        Case('verdict-bare-equivalent', 'verdict', model='base-1'),
        Case('verdict-automatic-fallback', 'verdict', model=FALLBACK, status='denied'),
        Case('verdict-manual-fallback', 'verdict', model=FALLBACK, assigned=FALLBACK),
        Case('verdict-same-model-as-author', 'verdict', assigned=FACT),
        Case('spawn-no-agent', 'spawn', model='', expected=1, reason='спавн судьи без явного agent'.encode()),
        Case('spawn-unconfigured', 'spawn', model='absent/model', expected=1, reason='модель не объявлена'.encode()),
        Case('spawn-no-config', 'spawn', config='missing', expected=2, reason='резолвер назначений отказал'.encode()),
        Case('spawn-broken-config', 'spawn', config='broken', expected=2, reason='резолвер назначений отказал'.encode()),
        Case('verdict-foreign-session', 'verdict', model=BASE, session='Judge222_B', expected=1, reason='чужая трасса'.encode()),
        Case('verdict-foreign-object', 'verdict', model=BASE, object=OTHER_OBJECT, expected=1, reason='трасса не об объекте суда'.encode()),
        Case('verdict-fact-not-assigned', 'verdict', model=FACT, expected=1, reason='вердикт не материализуется'.encode()),
        Case('verdict-per-call-wrong-fact', 'verdict', model=BASE, assigned=FACT, expected=1, reason='вердикт не материализуется'.encode()),
        Case('verdict-second-row-mismatch', 'verdict', model=BASE, second=True, expected=1, reason='вердикт не материализуется'.encode()),
        Case('verdict-missing-trace', 'verdict', model=BASE, missing=True, expected=2, reason='трасса не читается'.encode()),
        Case('verdict-unconfigured-assignment', 'verdict', model=FACT, assigned='absent/model', expected=2, reason='назначенная модель не объявлена'.encode()),
        Case('gate-foreign-session', 'gate', model=BASE, session='Judge222_B', expected=1, reason='чужая трасса'.encode()),
        Case('gate-foreign-object', 'gate', model=BASE, object=OTHER_OBJECT, expected=1, reason='трасса не об объекте суда'.encode()),
        Case('gate-wrong-fact', 'gate', model=FACT, expected=1, reason='вердикт не материализуется'.encode()),
        Case('gate-no-evidence', 'gate', missing=True, expected=1, reason='свидетельство судьи не передано'.encode()),
        Case('frontmatter-generated', 'frontmatter', model=BASE),
        Case('frontmatter-drift', 'frontmatter', model='wrong', expected=1, reason='frontmatter роли не тира роли'.encode()),
    ))
    for role in ('orchestrator', 'architect', 'implementer', *ROLES):
        out.append(Case(f'hook-{role}-flat', 'hook', role))
        out.append(Case(f'hook-{role}-batch', 'batch', role))
    out.extend((Case('hook-no-agent', 'hook', role='', expected=1, reason='спавн без явного agent'.encode()),
                Case('hook-default-task', 'hook', role='task', expected=1, reason='спавн без явного agent'.encode()),
                Case('hook-unknown-role', 'hook', role='alien', expected=1, reason='тип агента вне алфавита'.encode()),
                Case('hook-no-config', 'hook', config='missing', expected=1, reason='конфиг установленного харнеса не читается'.encode()),
                Case('hook-broken-config', 'hook', config='broken', expected=1, reason='конфиг установленного харнеса не читается'.encode()),
                Case('trace-binding', 'trace'),
                Case('single-config-line', 'generate'),
                Case('launcher-orchestrator', 'launcher'),
                Case('launcher-consultant', 'launcher', role='consultant'),
                Case('fork-consultant-arbiter-same-model', 'fork'),
                Case('fork-witness-author-same-model', 'fork-author'),
                Case('fork-model-field-stays-required', 'fork', missing=True, expected=1, reason='артефакт без строки МОДЕЛЬ'.encode())))
    return {c.name: c for c in out}


CASES = cases()


def run(argv, cwd, env=None):
    return subprocess.run([str(a) for a in argv], cwd=cwd, env=env,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=40)


def put(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data if isinstance(data, bytes) else data.encode())


def install(repo, world, model, mutation=None):
    for rel in ('workshop', 'scripts/gen-harness.ts', 'scripts/roles.ts', 'scripts/models_actual.sh', 'scripts/check_fork_route.sh', '.omp/extensions/spawn-guard.ts'):
        put(world / rel, (repo / rel).read_bytes())
    for name in ('check_sud_model.sh', 'judge_gate.sh'):
        src = HERE / 'model' / name if model else repo / 'scripts' / name
        put(world / 'scripts' / name, src.read_bytes())
        (world / 'scripts' / name).chmod(0o755)
    if model:
        put(world / 'scripts/check_sud_model.ts', (HERE / 'model/check_sud_model.ts').read_bytes())
        policy = json.loads((HERE / 'model/fork_policy.json').read_text())
        frozen = run(['git', '-C', repo, 'show', policy['base']], repo)
        if frozen.returncode:
            raise RuntimeError('REFERENCE_BASE_MISSING')
        text = frozen.stdout.decode()
        for change in policy['changes']:
            if text.count(change['old']) != 1:
                raise RuntimeError('FORK_REFERENCE_DRIFT')
            text = text.replace(change['old'], change['new'])
        put(world / 'scripts/check_fork_route.sh', text)
    if mutation:
        path = world / mutation['file']
        before = path.read_text()
        if before.count(mutation['old']) != 1:
            raise RuntimeError('STAB_ANCHOR_DRIFT: ' + mutation['name'])
        put(path, before.replace(mutation['old'], mutation['new']))
        parser = ['node', '--check', path] if path.suffix == '.ts' else ['bash', '-n', path]
        parsed = run(parser, world)
        if parsed.returncode:
            raise RuntimeError('STAB_SYNTAX_INVALID: ' + mutation['name'])
    cfg = json.loads((repo / 'config/agent_models.json').read_text())
    cfg['models'].update(free=FACT, base=BASE, reserve=FALLBACK, effort=EFFORT)
    for spec in cfg['tiers'].values():
        spec['model'] = '@base'
        spec['fallback'] = '@reserve'
    put(world / 'config/agent_models.json', json.dumps(cfg, ensure_ascii=False))
    (world / 'registry').mkdir(exist_ok=True)
    return cfg


HOOK_DRIVER = '''import {pathToFileURL} from 'node:url';
import {readFileSync} from 'node:fs';
const [file, input] = process.argv.slice(2);
const handlers = new Map();
const mod = await import(pathToFileURL(file).href);
mod.default({on: (name, fn) => handlers.set(name, fn)});
if (!handlers.has('tool_call')) process.exit(2);
const result = await handlers.get('tool_call')({toolName:'task', input:JSON.parse(readFileSync(input,'utf8'))});
if (result !== undefined) {
  process.stderr.write(JSON.stringify(result) + '\\n');
  process.exit(result.block === true ? 1 : 2);
}
'''


def observe(repo, world, c, cfg):
    config = world / 'config/agent_models.json'
    if c.config == 'missing':
        config.unlink()
    elif c.config == 'broken':
        put(config, '{')
    if c.kind in ('hook', 'batch'):
        # No lock door in this installation: exact frozen 104 model/alphabet seam.
        # An isolated hook must not consult the calling project's registry.
        put(world / 'driver.mjs', HOOK_DRIVER)
        item = {'name': 'Subject222', 'task': 'SUBJECT=222', 'model': c.model, 'isolated': True}
        if c.role:
            item['agent'] = c.role
        payload = {'tasks': [item]} if c.kind == 'batch' else item
        put(world / 'input.json', json.dumps(payload))
        p = run(['node', world / 'driver.mjs', world / '.omp/extensions/spawn-guard.ts', world / 'input.json'], world)
        return p, True
    if c.kind == 'launcher':
        # Reuse 209's real launcher world constructor, not its assertions/oracle.
        helper = repo / 'fixtures/workshop_project/zasev_trassy_209/probe.py'
        spec = importlib.util.spec_from_file_location('launcher_world_209', helper)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        launcher = (world / 'workshop').read_bytes()
        w = module.World(world, repo, launcher, launcher)
        cfg_path = w.tools / 'config/agent_models.json'
        actual = json.loads(cfg_path.read_text())
        actual['models']['free222'] = FACT
        for tier in actual['tiers'].values():
            tier['model'] = '@free222'
        put(cfg_path, json.dumps(actual, ensure_ascii=False))
        generated = run(['node', w.tools / 'scripts/gen-harness.ts'], world)
        if generated.returncode:
            return generated, False
        actual['models']['free222'] = EFFORT
        put(cfg_path, json.dumps(actual, ensure_ascii=False))
        generated = run(['node', w.tools / 'scripts/gen-harness.ts'], world)
        if generated.returncode:
            return generated, False
        put(w.bin / 'omp', '#!/usr/bin/env bash\nif [ "${1:-}" = --version ]; then printf "omp/209-toy\\n"; exit 0; fi\nprintf "%s\\n" "$@" > "$OMP_STUB_LOG"\n')
        (w.bin / 'omp').chmod(0o755)
        argv = ['bash', w.workshop]
        if c.role == 'consultant':
            argv.append('--fable')
        p = run(argv, world, w.env_base)
        captured = w.log.read_bytes().splitlines() if w.log.exists() else []
        indices = [i for i, value in enumerate(captured) if value == b'--model']
        effect = len(indices) == 1 and captured[indices[0] + 1] == EFFORT.encode()
        return p, effect
    if c.kind in ('fork', 'fork-author'):
        kind = 'воля-владельца' if c.kind == 'fork-author' else 'инженерный'
        route = 'батч' if c.kind == 'fork-author' else 'консультант'
        record = f'ФОРК: choice-222\nКЛАСС: {kind}\nМАРШРУТ: {route}\n'
        if c.kind == 'fork-author':
            record += f'ПРИЗНАК: норма\nАВТОР: {FACT}\n'
        put(world / 'forks/choice-222.md', record)
        evidence = '' if c.missing else f'МОДЕЛЬ: {FACT}\n'
        evidence += 'ПОДТВЕРЖДЕНО: воля-владельца\n'
        suffix = 'klass-v1' if c.kind == 'fork-author' else 'v1'
        put(world / f'verdicts/consultant/choice-222-{suffix}.md', evidence)
        if c.kind == 'fork':
            put(world / 'verdicts/arbitration/choice-222-v1.md', f'МОДЕЛЬ: {FACT}\n')
        p = run(['bash', world / 'scripts/check_fork_route.sh', '--root', world], world)
        return p, True
    if c.kind == 'trace':
        zone = world / 'sessions'
        events = [
            {'type': 'session', 'parentSession': 'Parent222'},
            {'type': 'message', 'message': {'role': 'user', 'content': [{'type': 'text', 'text': 'OBJECT=' + OBJECT}]}},
            {'type': 'model_change', 'model': FACT, 'resolvedModelIsFallback': False},
            {'type': 'message', 'message': {'role': 'assistant', 'agent': 'critic'}}]
        put(zone / (SESSION + '.jsonl'), '\n'.join(json.dumps(e, separators=(',', ':')) for e in events) + '\n')
        env = dict(os.environ, HARNESS_SESSION_HOME=str(zone))
        p = run(['bash', world / 'scripts/models_actual.sh', '--tsv', '--bind', '--session', SESSION], world, env)
        return p, p.stdout == f'critic\t{FACT}\tallowed\t{SESSION}\t{OBJECT}\n'.encode()
    if c.kind == 'generate':
        # Production generator, roles, resolver and configuration. Only isolated copies mutate.
        for rel in ('.omp/config.yml',):
            put(world / rel, (repo / rel).read_bytes())
        shutil.copytree(repo / 'roles', world / 'roles')
        for spec in cfg['tiers'].values():
            spec['model'] = '@free'
        put(config, json.dumps(cfg, ensure_ascii=False))
        p = run(['node', world / 'scripts/gen-harness.ts'], world)
        if p.returncode:
            return p, False
        # One source entry changes; every role still has its existing tier, no code edits.
        cfg['models']['free'] = EFFORT
        put(config, json.dumps(cfg, ensure_ascii=False))
        p = run(['node', world / 'scripts/gen-harness.ts'], world)
        if p.returncode:
            return p, False
        p = run(['node', world / 'scripts/gen-harness.ts', '--check'], world)
        okay = p.returncode == 0
        generated = (world / '.omp/config.yml').read_text()
        for tier in cfg['tiers']:
            okay &= f'  {tier}: "{EFFORT}"' in generated.splitlines() or any(
                line.startswith(f'  {tier}: "{EFFORT}"  #') for line in generated.splitlines())
        for role, tier in cfg['roles'].items():
            r = run(['node', world / 'scripts/roles.ts', '--resolve-model', role, '--root', world], world)
            okay &= r.returncode == 0 and r.stdout.split(b'\t')[1] == EFFORT.encode()
            okay &= f'model: ["@{tier}"]' in (world / '.omp/agents' / (role + '.md')).read_text().splitlines()
        return p, okay
    if c.kind == 'sosed':
        # Neighbour family 198 judges the same door in its own toy-registry worlds. Its probe is run
        # unmodified on a copy whose door is the one under test; only the cells superseded by 222 may be red.
        tree = world / 'sosed'
        for rel in ('scripts/roles.ts', 'scripts/gen-harness.ts', 'scripts/check_project_session.sh', '.omp/config.yml', 'config/agent_models.json'):
            put(tree / rel, (repo / rel).read_bytes())
        shutil.copytree(repo / 'roles', tree / 'roles')
        shutil.copytree(repo / NEIGHBOUR_198, tree / NEIGHBOUR_198, ignore=shutil.ignore_patterns('stabs', '__pycache__'))
        door_ts = world / 'scripts/check_sud_model.ts'
        if door_ts.exists():
            # The 198 worlds copy only the .sh: the reference .ts is reached by absolute path.
            put(tree / 'scripts/check_sud_model.ts', door_ts.read_bytes())
            put(tree / 'scripts/check_sud_model.sh', f'#!/usr/bin/env bash\nexec node "{tree / "scripts/check_sud_model.ts"}" "$@"\n')
        else:
            put(tree / 'scripts/check_sud_model.sh', (world / 'scripts/check_sud_model.sh').read_bytes())
        p = subprocess.run(['python3', str(tree / NEIGHBOUR_198 / 'probe.py'), '--model'], cwd=tree,
                           env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=170)
        text = p.stdout.decode()
        red = set(re.findall(r'^CELL (\S+) КРАСНА', text, re.M))
        okay = (re.search(r'^CELLS=\d+ FAILURES=\d+$', text, re.M) is not None
                and p.returncode in (0, 1) and (p.returncode == 0) == (not red) and red <= SUPERSEDED_198)
        return subprocess.CompletedProcess(p.args, 0 if okay else 1, f'198 rc={p.returncode} red={sorted(red)}\n'.encode(), p.stderr), okay
    if c.kind == 'frontmatter':
        tier = cfg['roles'][c.role] if c.model == BASE else 'wrong'
        put(world / '.omp/agents' / (c.role + '.md'), f'---\nmodel: ["@{tier}"]\n---\n')
        return run(['bash', world / 'scripts/check_sud_model.sh', '--frontmatter', c.role, '--root', world], world), True
    if c.kind == 'spawn':
        argv = ['bash', world / 'scripts/check_sud_model.sh', '--spawn', c.role]
        if c.model:
            argv.append(c.model)
        return run([*argv, '--root', world], world), True
    trace = world / 'trace.tsv'
    rows = [f'{c.role}\t{c.model}\t{c.status}\t{c.session}\t{c.object}']
    if c.name == 'verdict-same-model-as-author':
        rows.insert(0, f'architect\t{c.model}\tallowed\tAuthor222\t{OBJECT}')
    if c.second:
        rows.append(f'{c.role}\t{FACT}\tallowed\t{SESSION}\t{OBJECT}')
    if not c.missing:
        put(trace, '\n'.join(rows) + '\n')
    if c.kind == 'verdict':
        argv = ['bash', world / 'scripts/check_sud_model.sh', '--verdict', c.role, '--trace', trace,
                '--session', SESSION, '--object', OBJECT, '--root', world]
    else:
        put(world / 'decision', 'accept\n')
        argv = ['bash', world / 'scripts/judge_gate.sh', OBJECT, '--verdict-row', 'contracts/222', 'c' * 64, world / 'decision']
        if not c.missing:
            argv += ['--sud', c.role, trace, SESSION]
    if c.assigned:
        argv += ['--assigned-model', c.assigned]
    p = run(argv, world)
    effect = True
    if c.kind == 'gate':
        journal = world / 'registry/candidates.tsv'
        actual = journal.read_bytes() if journal.exists() else b''
        want = ('verdict\tcontracts/222\t' + 'c' * 64 + '\taccept\t1\n').encode() if c.expected == 0 else b''
        effect = actual == want
    return p, effect


def battery(repo, model=False, mutation=None, selected=None, quiet=False):
    bad = []
    todo = [CASES[n] for n in selected] if selected else list(CASES.values())
    with tempfile.TemporaryDirectory(prefix='lyubaja222-') as tmp:
        for c in todo:
            world = Path(tmp) / c.name
            cfg = install(repo, world, model, mutation)
            p, effect = observe(repo, world, c, cfg)
            okay = p.returncode == c.expected and effect and (not c.reason or c.reason in p.stderr)
            if not okay:
                bad.append(c.name)
                if not quiet:
                    print(f'KRASNO {c.name}: rc={p.returncode} expected={c.expected} effect={effect} stdout={p.stdout!r} stderr={p.stderr!r}')
    if not quiet:
        print(f'{"MODEL" if model else "SUBJEKT"} 222: KLETKI {len(todo)} KRASNYH {len(bad)}')
    return bad


def syntax():
    ast.parse(Path(__file__).read_text())
    for p in HERE.rglob('*.sh'):
        r = run(['bash', ROOT / 'scripts/validate_std.sh', 'bash', p], ROOT)
        if r.returncode:
            sys.stderr.buffer.write(r.stderr)
            return 2
    # Native TypeScript parser, not a home-grown syntax predicate.
    r = run(['node', '--check', HERE / 'model/check_sud_model.ts'], ROOT)
    sys.stderr.buffer.write(r.stderr)
    return r.returncode


def main():
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--repo', type=Path)
    mode.add_argument('--model', action='store_true')
    mode.add_argument('--stabs', action='store_true')
    mode.add_argument('--sintaksis', action='store_true')
    mode.add_argument('--catalog', action='store_true')
    parser.add_argument('--case', choices=CASES)
    args = parser.parse_args()
    for tool in ('bash', 'node', 'jq', 'git'):
        if shutil.which(tool) is None:
            raise RuntimeError('NOT_IMPLEMENTED: нет ' + tool)
    if args.sintaksis:
        return syntax()
    if args.catalog:
        mutations = json.loads((HERE / 'source.json').read_text())
        names = [m['name'] for m in mutations]
        if len(names) != len(set(names)) or any(not m['cases'] or set(m['cases']) - CASES.keys() for m in mutations):
            raise RuntimeError('BINDING_REGISTRY_INVALID')
        links = sum(len(m['cases']) for m in mutations)
        print(f'KLETKI={len(CASES)} STABS={len(mutations)} SVJAZI={links}')
        return 0
    selected = [args.case] if args.case else None
    if not args.stabs:
        return int(bool(battery((args.repo or ROOT).resolve(), args.model, selected=selected)))
    if battery(ROOT, True):
        return 1
    mutations = json.loads((HERE / 'source.json').read_text())
    alive = 0
    for mutation in mutations:
        bad = battery(ROOT, True, mutation, mutation['cases'], quiet=True)
        missing = set(mutation['cases']) - set(bad)
        alive += bool(missing)
        print(f'STAB {mutation["name"]}: ' + ('ZHIV ' + ','.join(sorted(missing)) if missing else 'KRASNYJ'))
    print(f'STABY 222: STABS {len(mutations)} ZHIVYH {alive}')
    return int(alive > 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError, subprocess.TimeoutExpired, ValueError, KeyError, IndexError) as error:
        print('NOT_IMPLEMENTED: ' + str(error), file=sys.stderr)
        sys.exit(2)
