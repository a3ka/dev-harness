#!/usr/bin/env python3
"""215: real omp + stand/provider/observer 129. No paid provider requests."""
import argparse
import ast
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
BASE = HERE.parent / 'fallback_subagent_129'
OBJECT = '1234567890abcdef1234567890abcdef12345678'
spec = importlib.util.spec_from_file_location('stand129', BASE / 'battery.py')
old = importlib.util.module_from_spec(spec)
spec.loader.exec_module(old)

# H-39: exact mutations and independently observable inputs, exclusively in code.
STABS = [
    ('no-content', 'fallback-route.ts', "if (!MARKERS.some((marker) => marker.includes(' ') ? m.errorMessage!.includes(marker) : m.errorMessage!.split(/[^A-Za-z0-9_]+/).includes(marker))) return;", 'return;', ['flagged', 'cyber', 'filter']),
    ('any-error', 'fallback-route.ts', "if (!MARKERS.some((marker) => marker.includes(' ') ? m.errorMessage!.includes(marker) : m.errorMessage!.split(/[^A-Za-z0-9_]+/).includes(marker))) return;", '', ['other', 'error500', 'short429']),
    ('substring', 'fallback-route.ts', "m.errorMessage!.split(/[^A-Za-z0-9_]+/).includes(marker)", 'm.errorMessage!.includes(marker)', ['near-token']),
    ('ignore-auto', 'fallback-route.ts', "tier?.autoFallback !== true || ", '', ['auto-off']),
    ('invent-chain', 'fallback-route.ts', 'const chain = init?.retryFallback?.chain;', "const chain = init?.retryFallback?.chain ?? [fallback(init?.modelRole ?? '')];", ['no-chain']),
    ('poison-provider', 'fallback-route.ts', 'seen.add(current);', 'seen.add(current); exhausted.set(m.provider!, Date.now() + 999999);', ['foreign-sibling']),
    ('no-resume', 'fallback-route.ts', "pi.sendUserMessage('Continue the original task on the configured fallback. Do not change its requirements.', { deliverAs: 'followUp' });", '', ['flagged']),
    ('late-hook', 'fallback-route.ts', "pi.on('message_end', async (event, ctx) => {\n    const m = event.message;", "pi.on('agent_end', async (event, ctx) => {\n    const m = event.messages?.filter((entry) => entry.role === 'assistant').at(-1);", ['flagged']),
    ('no-stop-reason', 'fallback-route.ts', "pi.appendEntry('fallback-route-215', { reason: 'CONTENT_FALLBACK_EXHAUSTED', from: current });", '', ['exhausted']),
    ('wrong-target', 'fallback-route.ts', "return cfg.models?.[tier.fallback.replace(/^@/, '')];", "return cfg.models?.[Object.keys(cfg.models ?? {})[0]];", ['flagged']),
    ('same-provider', 'fallback-route.ts', " || target.split('/')[0] === m.provider", '', ['same-provider']),
    ('no-receipt', 'models_actual.py', "recovery = any(r.get('modelChangeId') == entry.get('id') and r.get('target') == entry.get('model')", "recovery = any(False and r.get('modelChangeId') == entry.get('id') and r.get('target') == entry.get('model')", ['trace']),
    ('receipt-any-id', 'models_actual.py', "r.get('modelChangeId') == entry.get('id') and ", '', ['trace']),
    ('receipt-any-model', 'models_actual.py', " and r.get('target') == entry.get('model')", '', ['trace']),
    ('all-denied', 'models_actual.py', "entry.get('resolvedModelIsFallback') is True or recovery", 'True', ['trace']),
    # Critic Б-1 (verdict 215 v1, M1/M5): the WRITER of the receipt must not forge
    # the binding to the real model_change — caught by the trace cell only.
    ('M1-forged-id', 'fallback-route.ts',
     "const modelChangeId = [...ctx.sessionManager.getEntries()].reverse().find((entry) => entry.type === 'model_change')?.id;",
     "const modelChangeId = 'forged-215-id';", ['trace']),
    ('M5-forged-target', 'fallback-route.ts',
     "pi.appendEntry('fallback-route-215', { reason: 'CONTENT_FALLBACK_SWITCH', from: current, target, modelChangeId });",
     "pi.appendEntry('fallback-route-215', { reason: 'CONTENT_FALLBACK_SWITCH', from: current, target: 'forged/fallback-x', modelChangeId });",
     ['trace']),
]


def source():
    return {'stabs': [{'id': n, 'file': f, 'cells': c} for n, f, _, _, c in STABS],
            'sha256': {str(p.relative_to(HERE)): hashlib.sha256(p.read_bytes()).hexdigest()
                       for p in sorted((HERE / 'model').iterdir()) if p.is_file()}}


def check_source():
    if json.loads((HERE / 'source.json').read_text()) != source():
        raise RuntimeError('ORACLE_TAMPERED: regenerate source.json with --catalog-write')


def cases(am):
    primary, target, _ = old.tier_of(am)
    result = {name: dict(mode=name, expect=('completed', target)) for name in ['flagged', 'cyber', 'filter']}
    for mode in ['other', 'error500', 'short429', 'near-token']:
        result[mode] = dict(mode=mode, expect=('failed', None))
    result['healthy'] = dict(mode='ok', expect=('completed', primary))
    result['exhausted'] = dict(mode='flagged', fallback_mode='cyber', expect=('failed', None), stop=True)
    result['no-chain'] = dict(mode='flagged', no_chain=True, expect=('failed', None))
    result['auto-off'] = dict(mode='flagged', auto_off=True, expect=('failed', None))
    result['same-provider'] = dict(mode='flagged', same_provider=True, expect=('failed', None))
    result['foreign-sibling'] = dict(mode={'sib': 'flagged', 'default': 'ok'}, sibling=True, expect=('completed', primary))
    result['trace'] = dict(mode='flagged', expect=('completed', target), trace=True)
    return result


def trace_checks(subject, w, entries, model, override, wire_target):
    native = [e for e in entries if e.get('type') == 'model_change']
    receipts = [e for e in entries if e.get('customType') == 'fallback-route-215'
                and e.get('data', {}).get('reason') == 'CONTENT_FALLBACK_SWITCH']
    if len(receipts) != 1:
        return 'TRACE_RECEIPT_ABSENT_OR_DUPLICATE'
    receipt = receipts[0]
    # Critic Б-1 (215 v1): the paired expectation is derived INDEPENDENTLY of the
    # receipt — the real model_change of this session is the last native change in
    # the world trace, and its model must be the selector the child actually
    # completed on (provider wire), as the TSV consumer sees the transition. A
    # receipt with a forged id or a foreign target cannot pair with it and leaves
    # the real change allowed -> red (writer stabs M1/M5, verdict 215 v1).
    change = native[-1] if native else None
    if not change or change.get('model') != wire_target:
        return 'TRACE_REAL_MODEL_CHANGE_ABSENT_OR_MISMATCH'
    trace_script = override or (HERE / 'model/models_actual.py' if model else subject / 'scripts/models_actual.sh')
    command = ['python3' if trace_script.suffix == '.py' else 'bash', str(trace_script)]
    failures = []
    # Expectations captured in memory before invoking the subject. Each negative has
    # a truthful equivalent: an ordinary native choice must remain allowed.
    variants = [('paired', None), ('wrong-id', 'modelChangeId'), ('wrong-target', 'target'),
                ('wrong-reason', 'reason'), ('absent', 'absent')]
    for name, field in variants:
        changed = json.loads(json.dumps(entries))
        r = next(e for e in changed if e.get('id') == receipt['id'])
        if field == 'absent':
            changed.remove(r)
        elif field:
            r['data'][field] = 'unrelated-value'
        zone = w / ('trace-' + name)
        zone.mkdir()
        (zone / 'Child129.jsonl').write_text(''.join(json.dumps(e, separators=(',', ':')) + '\n' for e in changed))
        expected = [('architect', e['model'], 'denied' if e.get('resolvedModelIsFallback') or
                     (name == 'paired' and e.get('id') == change['id']) else 'allowed') for e in native]
        for bind in (False, True):
            expected_text = ''.join('\t'.join(list(row) + (['Child129', OBJECT] if bind else [])) + '\n' for row in expected)
            got = subprocess.run(command + ['--tsv', '--session', 'Child129'] + (['--bind'] if bind else []),
                                 env={**os.environ, 'HARNESS_SESSION_HOME': str(zone)}, capture_output=True, text=True)
            if got.returncode == 2:
                raise RuntimeError('NOT_IMPLEMENTED: trace consumer: ' + got.stderr)
            if got.returncode != 0 or got.stdout != expected_text:
                failures.append('TRACE_%s_%s rc=%s got=%r expected=%r' % (name, bind, got.returncode, got.stdout, expected_text))
    return '; '.join(failures) or None


def run(subject, extension, name, model=False, trace_override=None):
    am = json.loads((subject / 'config/agent_models.json').read_text())
    primary, target, tier = old.tier_of(am)
    case = cases(am)[name]
    models = {f: 'ok' for f in am['models']}
    models.update({primary: case['mode'], target: case.get('fallback_mode', 'ok'), 'main': 'main'})
    script = [old.task_step(old.CHILD, old.MARK + '\nOBJECT=' + OBJECT + '\nyield.')]
    if case.get('sibling'):
        script.insert(0, old.task_step(old.SIB, old.SIB_MARK + ' sibling.'))
    cell = dict(models=models, script=script, expect=case['expect'],
                world=[(primary, 'flagged')] if case.get('sibling') else None)
    if case.get('stop') or case['expect'][0] == 'completed':
        cell['max_child_turns'] = 2
    with tempfile.TemporaryDirectory(prefix='p215-', dir=os.environ.get('TMPDIR')) as temp:
        w = Path(temp)
        previous = old.cells
        old.cells = lambda _: {name: cell}
        try:
            old.build_world(str(subject), str(w), name, {'ext': str(extension), 'drop_chain': bool(case.get('no_chain'))})
        finally:
            old.cells = previous
        cfg = w / 'proj/.omp/config.yml'
        cfg.write_text(cfg.read_text().replace('retry:\n', 'retry:\n  fallbackOn: usage-limit\n  maxRetries: 1\n  baseDelayMs: 1\n'))
        if case.get('auto_off'):
            roster_path = w / 'proj/config/agent_models.json'
            roster = json.loads(roster_path.read_text())
            roster['tiers'][tier]['autoFallback'] = False
            roster_path.write_text(json.dumps(roster))
        if case.get('same_provider'):
            roster_path = w / 'proj/config/agent_models.json'
            roster = json.loads(roster_path.read_text())
            original = roster['models'][target]
            replacement = roster['models'][primary].split('/')[0] + '/' + target
            roster['models'][target] = replacement
            roster_path.write_text(json.dumps(roster))
            cfg.write_text(cfg.read_text().replace(original, replacement))
        observer = """export default function register(pi: { on(n: string, h: (e: { message?: { role?: string; stopReason?: string; errorMessage?: string; errorStatus?: number; errorId?: number; provider?: string; model?: string } }) => void): void; appendEntry(t: string, d: object): void }) {
  pi.on('message_end', (event) => {
    const m = event.message;
    if (m?.role === 'assistant' && m.stopReason === 'error')
      pi.appendEntry('observed-215', { stopReason: m.stopReason, errorMessage: m.errorMessage, errorStatus: m.errorStatus, errorId: m.errorId, provider: m.provider, model: m.model });
  });
}
"""
        (w / 'proj/.omp/extensions/observer215.ts').write_text(observer)
        # Commit the scenario before isolated children copy it.
        git = ['git', '-C', str(w / 'proj'), '-c', 'user.name=stand215', '-c', 'user.email=stand215@invalid']
        subprocess.run(git + ['add', '-A'], check=True, stdout=subprocess.DEVNULL)
        subprocess.run(git + ['commit', '-qm', '215 scenario'], check=True)
        plan = json.loads((w / 'plan.json').read_text())
        plan['_provider_base'] = str(BASE / 'stub_provider.py')
        if case.get('same_provider'):
            provider = old.remap(am)[0][primary].split('/')[0]
            plan['providers'][provider].append(target)
        (w / 'plan.json').write_text(json.dumps(plan))
        launcher = (BASE / 'omp_stand.sh').read_text()
        launcher = launcher.replace("printf 'async:\\n  enabled: false\\n'", "printf 'async:\\n  enabled: false\\nretry:\\n  fallbackOn: usage-limit\\n  maxRetries: 1\\n  baseDelayMs: 1\\n'")
        (w / 'omp_stand.sh').write_text(launcher)
        shutil.copy(HERE / 'stub_provider.py', w / 'stub_provider.py')
        rc = subprocess.run(['bash', str(w / 'omp_stand.sh'), str(w), str(w / 'plan.json')],
                            env={**os.environ, 'STAND_TIMEOUT': '90'}).returncode
        if rc in (124, 3):
            raise RuntimeError('NOT_IMPLEMENTED: stand timeout/provider startup')
        why = old.judge(str(w), cell, rc)
        requests = [json.loads(s) for s in (w / 'requests.jsonl').read_text().splitlines()]
        turns = [r for r in requests if r['turn'] and r['model'] != 'main']
        if not turns:
            raise RuntimeError('NOT_IMPLEMENTED: empty provider sample')
        if not any(r['model'] == primary and r['status'] == case['mode'] for r in turns) and not case.get('sibling'):
            raise RuntimeError('NOT_IMPLEMENTED: planned primary refusal not exercised')
        children = []
        for path in (w / 'sessions').rglob('*.jsonl'):
            rows = [json.loads(line) for line in path.read_text().splitlines()]
            init = next((e for e in rows if e.get('type') == 'session_init'), {})
            if old.MARK_TOKEN.search(str(init.get('task', ''))):
                children.append((rows, init))
        if len(children) != 1:
            raise RuntimeError('NOT_IMPLEMENTED: child marker absent/ambiguous')
        entries, init = children[0]
        print('SIGNAL', name, json.dumps({k: init.get(k) for k in ('agent', 'modelRole', 'retryFallback')}), flush=True)
        errors = [e['data'] for e in entries if e.get('customType') == 'observed-215']
        if case['mode'] != 'ok' and not case.get('sibling') and not errors:
            raise RuntimeError('NOT_IMPLEMENTED: no live message_end error')
        print('ERRORS', name, json.dumps(errors), flush=True)
        if case.get('stop') and not any(e.get('customType') == 'fallback-route-215' and
                                       e.get('data', {}).get('reason') == 'CONTENT_FALLBACK_EXHAUSTED' for e in entries):
            why = why or 'CONTENT_FALLBACK_EXHAUSTED absent'
        if case.get('trace') and not why:
            why = trace_checks(subject, w, entries, model, trace_override,
                               old.remap(am)[0].get(turns[-1]['model']))
        print('OBS', name, json.dumps(turns), 'rc', rc, flush=True)
        return why


def mutate(temp, stab):
    name, filename, before, after, _ = stab
    text = (HERE / 'model' / filename).read_text()
    if text.count(before) != 1:
        raise RuntimeError('ORACLE_TAMPERED: mutation anchor ' + name)
    path = temp / filename
    path.write_text(text.replace(before, after, 1))
    if filename.endswith('.ts'):
        rc = subprocess.run(['node', '--check', str(path)], capture_output=True).returncode
    else:
        ast.parse(path.read_text())
        rc = 0
    if rc:
        raise RuntimeError('NOT_IMPLEMENTED: malformed mutant ' + name)
    return path


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--repo', type=Path, default=ROOT)
    group.add_argument('--model', action='store_true')
    group.add_argument('--stabs', action='store_true')
    group.add_argument('--sintaksis', action='store_true')
    group.add_argument('--catalog', action='store_true')
    group.add_argument('--catalog-write', action='store_true')
    group.add_argument('--sosed', action='store_true')
    parser.add_argument('--case')
    parser.add_argument('--stab')
    args = parser.parse_args()
    subject = args.repo.resolve()
    if args.catalog_write:
        (HERE / 'source.json').write_text(json.dumps(source(), indent=2) + '\n')
        return 0
    check_source()
    names = list(cases(json.loads((subject / 'config/agent_models.json').read_text())))
    if args.catalog:
        assert len(names) == len(set(names)) and len(STABS) == len({s[0] for s in STABS})
        assert all(c in names for s in STABS for c in s[4])
        print('KLETKI=%d STABY=%d SVJAZI=%d' % (len(names), len(STABS), sum(len(s[4]) for s in STABS)))
        return 0
    if args.sintaksis:
        for p in HERE.rglob('*.py'):
            ast.parse(p.read_text())
        subprocess.run(['node', '--check', str(HERE / 'model/fallback-route.ts')], check=True)
        subprocess.run(['bash', str(ROOT / 'scripts/validate_std.sh'), 'bash', str(HERE / 'red_otkaz_po_soderzhaniyu_215.sh')], check=True)
        print('SINTAKSIS=0')
        return 0
    if shutil.which('omp') is None:
        raise RuntimeError('NOT_IMPLEMENTED: omp absent')
    if args.sosed:
        return subprocess.run(['python3', str(BASE / 'battery.py'), '--subject', str(subject), '--ext', str(HERE / 'model/fallback-route.ts')]).returncode
    if args.stabs:
        selected = [s for s in STABS if not args.stab or s[0] == args.stab]
        if not selected:
            raise RuntimeError('NOT_IMPLEMENTED: unknown stab')
        alive = pairs = 0
        for stab in selected:
            with tempfile.TemporaryDirectory(prefix='mut215-', dir=os.environ.get('TMPDIR')) as temp:
                mutation = mutate(Path(temp), stab)
                extension = mutation if stab[1].endswith('.ts') else HERE / 'model/fallback-route.ts'
                trace = mutation if stab[1].endswith('.py') else None
                for name in stab[4]:
                    why = run(subject, extension, name, True, trace)
                    pairs += 1
                    alive += not bool(why)
                    print(('caught ' if why else 'ZHIV ') + stab[0] + ' ' + name + ': ' + str(why), flush=True)
        print('STABY=%d SVJAZI=%d ZHIVYH=%d' % (len(selected), pairs, alive))
        return int(bool(alive))
    names = [args.case] if args.case else names
    red = 0
    for name in names:
        # Critic Б-1: the trace cell exercises the SUBJECT writer in --repo (the
        # receipt is written by the subject extension) and the honest model in
        # --model; the TSV consumer is the subject's in --repo and the honest one
        # in --model. The paired expectation always comes from the real
        # model_change of the session, never from the receipt fields.
        extension = HERE / 'model/fallback-route.ts' if args.model else subject / old.EXT_REL
        why = run(subject, extension, name, args.model)
        red += bool(why)
        print(('KRASNO ' + name + ': ' + why) if why else 'ok ' + name, flush=True)
    print('KLETKI=%d KRASNYH=%d' % (len(names), red))
    return int(bool(red))


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError, old.OmpFormatChanged) as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(2)
