#!/usr/bin/env python3
"""Battery of contract 129 (fallback-subagent): real omp 18.x against a stub provider.

usage:
  battery.py [--subject DIR] [--cells a,b]   judge the SUBJECT tree (default: repo root)
  battery.py --model                         judge the honest model (model/fallback-route.ts) — all green
  battery.py --stabs                         every cheat of source.json must be red in each bound cell

Exit: 0 all cells green (or, with --stabs, every stub caught); 1 otherwise; 2 stand broken.
One line per cell: `ok <cell>` / `FAIL <cell>: <reason>`. Never prints PASS.

What is judged (the subject's real artifacts, copied into a throwaway world):
  config/agent_models.json, .omp/agents/architect.md, the `modelRoles:` and `retry:`
  blocks of .omp/config.yml, and .omp/extensions/fallback-route.ts when present.
Every model family of agent_models.json is remapped to the stub provider
`stub-<real provider>/<family>`; quota exhaustion is per PROVIDER (1310 is an
account wall), so a re-route to another family of the exhausted provider stays dead.
Expectations live in this process (tier -> primary/fallback family, request
bounds); the subject's files are inputs, never the oracle.
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
ROLE = 'architect'
EXT_REL = '.omp/extensions/fallback-route.ts'
CHILD, SIB, SIB_MARK, MARK = 'Child129', 'Sib129', 'SIB129', 'M129'

def task_step(name, text):
    # isolated: true — as the orchestrator spawns architect/implementer live (contract 012/067)
    return {"name": "task", "args": {"i": "Spawn " + name, "context": "stand 129",
                                     "tasks": [{"agent": ROLE, "name": name, "task": text, "isolated": True}]}}


def tier_of(am):
    tier = am['tiers'][am['roles'][ROLE]]
    fam = lambda ref: ref[1:]  # "@opus" -> "opus" (contract: tiers reference families)
    return fam(tier['model']), fam(tier['fallback']), am['roles'][ROLE]


# ── cells: (description, plan builder, judge) — closed table, one property each ──
def cells(am):
    P, F, _ = tier_of(am)
    prov = {f: sel.split('/')[0] for f, sel in am['models'].items()}

    def modes(**kw):
        m = {f: "ok" for f in am['models']}
        for f in am['models']:
            if prov[f] in kw.get('quota_providers', ()):
                m[f] = "quota"
        m.update(kw.get('override', {}))
        m['main'] = 'main'
        return m

    every = tuple(sorted(set(prov.values())))
    return {
        # c1: no sibling; primary provider exhausted -> the child finishes on the tier fallback.
        'c1-zhivoj-perehod': dict(
            models=modes(quota_providers=(prov[P],)),
            script=[task_step(CHILD, "Yield the marker.")],
            expect=('completed', F), world=None),
        # c2: the live death (omp log 2026-10-21): the sibling hit the exhausted primary and then
        # was rejected on the fallback -> the fallback sits in the process-wide cooldown; the
        # child spawned next must still finish on the tier fallback.
        'c2-sosed-cooldown': dict(
            models=modes(quota_providers=(prov[P],), override={F: {"sib": "quota", "default": "ok"}}),
            script=[task_step(SIB, SIB_MARK + " sibling."), task_step(CHILD, "Yield the marker.")],
            expect=('completed', F), world=[(P, 'quota'), (F, 'quota')]),
        # c3: healthy primary -> the child stays on the PRIMARY (no gratuitous re-route).
        'c3-zdorovyj-primary': dict(
            models=modes(),
            script=[task_step(CHILD, "Yield the marker.")],
            expect=('completed', P), world=None),
        # c4: a sibling's VALIDATION error (400) on the primary is not exhaustion -> next child on PRIMARY.
        'c4-validacija-soseda': dict(
            models=modes(override={P: {"sib": "validation", "default": "ok"}}),
            script=[task_step(SIB, SIB_MARK + " sibling."), task_step(CHILD, "Yield the marker.")],
            expect=('completed', P), world=[(P, 'validation')]),
        # c5: every provider exhausted -> the child FAILS, and switching/retrying stays bounded.
        # Bound = measured omp 18.3.1 behaviour of a dead child: one failed turn + one omp
        # re-prompt = 2 agent turns (honest model 2/2/2, tree of 2026-10-21 2/2; the
        # re-prompt loop cheat s7: 4/5/5). A list-cycle in model[] is neutralised by omp itself.
        'c5-vse-ischerpany': dict(
            models=modes(quota_providers=every),
            script=[task_step(SIB, SIB_MARK + " sibling."), task_step(CHILD, "Yield the marker.")],
            expect=('failed', None), world=[(P, 'quota')], max_child_turns=2),
        # c6: the fallback's cooldown is NOT a quota wall: the sibling hit the exhausted primary,
        # then a 400 on the fallback (omp cools the selector down on hard errors too) -> the
        # fallback provider is healthy; the child spawned next must finish on the tier fallback.
        # Separates "switch when the PRIMARY is exhausted" from "switch only when both providers
        # carry an exhaustion record" (critic 129 round 1): in c2 both answers coincide.
        'c6-zapasnaja-validacija': dict(
            models=modes(quota_providers=(prov[P],), override={F: {"sib": "validation", "default": "ok"}}),
            script=[task_step(SIB, SIB_MARK + " sibling."), task_step(CHILD, "Yield the marker.")],
            expect=('completed', F), world=[(P, 'quota'), (F, 'validation')]),
    }


def remap(am):
    """family -> stub selector; real selector -> stub selector (for config.yml text)."""
    stub = {f: 'stub-%s/%s' % (sel.split('/')[0], f) for f, sel in am['models'].items()}
    real = {sel: stub[f] for f, sel in am['models'].items()}
    return stub, real


def top_block(text, key):
    out, on = [], False
    for line in text.splitlines():
        if re.match(r'^[A-Za-z_][\w-]*:', line):
            on = line.startswith(key + ':')
        if on:
            out.append(line)
    return out


def build_world(subj, w, cell, overlay):
    am = json.load(open(os.path.join(subj, 'config/agent_models.json')))
    stub, real = remap(am)
    proj = os.path.join(w, 'proj')
    os.makedirs(os.path.join(proj, '.omp/agents'))
    os.makedirs(os.path.join(proj, '.omp/extensions'))
    os.makedirs(os.path.join(proj, 'config'))
    subprocess.run(['git', 'init', '-q', proj], check=True)
    am2 = dict(am)
    am2['models'] = stub
    json.dump(am2, open(os.path.join(proj, 'config/agent_models.json'), 'w'), ensure_ascii=False, indent=2)
    shutil.copy(os.path.join(subj, '.omp/agents', ROLE + '.md'), os.path.join(proj, '.omp/agents', ROLE + '.md'))
    cfg = open(os.path.join(subj, '.omp/config.yml')).read()
    # live topology: modelRoles + retry (chains) + task/isolation (children run in isolated
    # workspaces, each discovering ITS OWN copy of .omp/extensions from the committed tree)
    text = '\n'.join(top_block(cfg, 'modelRoles') + top_block(cfg, 'retry')
                     + top_block(cfg, 'task') + top_block(cfg, 'isolation')) + '\n'
    for r in sorted(real, key=len, reverse=True):
        text = text.replace('"%s"' % r, '"%s"' % real[r])
    if overlay.get('drop_chain'):
        # cheat s1: no fallback anywhere — every chain entry under retry.fallbackChains removed
        # (a subagent inherits its tier chain, else `default`; dropping one tier is not enough).
        text = '\n'.join(l for l in text.splitlines() if not re.match(r'^ {4}[\w-]+:\s*\[', l)) + '\n'
    open(os.path.join(proj, '.omp/config.yml'), 'w').write(text)
    ext = overlay.get('ext', os.path.join(subj, EXT_REL))
    if ext and os.path.isfile(ext):
        shutil.copy(ext, os.path.join(proj, EXT_REL))
    git = ['git', '-C', proj, '-c', 'user.name=stand129', '-c', 'user.email=stand129@invalid']
    subprocess.run(git + ['add', '-A'], check=True)
    subprocess.run(git + ['commit', '-q', '-m', 'stand world'], check=True)
    c = cells(am)[cell]
    providers = {}
    for f, s in stub.items():
        providers.setdefault(s.split('/')[0], []).append(f)
    providers['stub-main'] = ['main']
    plan = {"_marker": MARK, "_sib_marker": SIB_MARK, "_main_script": c['script'],
            "models": c['models'], "providers": providers}
    json.dump(plan, open(os.path.join(w, 'plan.json'), 'w'))
    return c, tier_of(am)


RESULT_RE = re.compile(r'<task-result id="(\w+)" agent="[\w-]+" status="([^"]+)"[^>]*>(.*?)</task-result>', re.S)


def judge(w, c, rc):
    out = open(os.path.join(w, 'out.txt'), errors='replace').read()
    reqs = [json.loads(l) for l in open(os.path.join(w, 'requests.jsonl')) if l.strip()]
    if rc == 124:
        return 'стенд вышел по таймауту (цикл смены моделей или зависание)'
    # the world must have happened as built: the sibling's agent turns met the planned failures
    for model, status in c['world'] or ():
        if not any(r['sib'] and r['turn'] and r['model'] == model and r['status'] == status for r in reqs):
            return 'мир не построен: у соседа нет хода %s со статусом %s' % (model, status)
    res = {m.group(1): (m.group(2), m.group(3)) for m in RESULT_RE.finditer(out)}
    want_child, want_model = c['expect']
    if CHILD not in res:
        return 'нет результата ребёнка %s в выводе родителя' % CHILD
    st, body = res[CHILD]
    if not st.startswith(want_child):
        return 'ребёнок %s, ожидался %s: %s' % (st, want_child, ' '.join(body.split())[:160])
    if want_model is not None:
        got = re.search(r'"model":\s*"([^"]+)"', body)
        if not got or got.group(1) != want_model:
            return 'ребёнок завершил на модели %s, ожидалась %s' % (got.group(1) if got else '?', want_model)
        if not re.search(r'"marker":\s*"%s"' % MARK, body):
            return 'нет маркера стенда в ответе ребёнка'
    if 'max_child_turns' in c:
        n = sum(1 for r in reqs if r['turn'] and not r['sib'] and r['model'] != 'main')
        if n > c['max_child_turns']:
            return 'ребёнок отправил %d ходов при пределе %d (цикл смены моделей)' % (n, c['max_child_turns'])
    return None


def run_cells(subj, names, overlay, keep=False):
    fails = {}
    for cell in names:
        w = tempfile.mkdtemp(prefix='p129-' + cell + '-')
        try:
            c, _ = build_world(subj, w, cell, overlay)
            rc = subprocess.run(['bash', os.path.join(HERE, 'omp_stand.sh'), w, os.path.join(w, 'plan.json')]).returncode
            if rc == 3:
                print('STAND BROKEN %s: stub did not start' % cell)
                sys.exit(2)
            why = judge(w, c, rc)
        finally:
            if not keep:
                shutil.rmtree(w, ignore_errors=True)
        fails[cell] = why
    return fails


def main(argv):
    subj, names, mode, ext_override = REPO, None, 'subject', None
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == '--subject':
            subj = argv[i + 1]; i += 2; continue
        if a == '--cells':
            names = argv[i + 1].split(','); i += 2; continue
        if a == '--ext':
            ext_override = argv[i + 1]; i += 2; continue
        if a in ('--model', '--stabs'):
            mode = a[2:]; i += 1; continue
        print('usage: battery.py [--subject DIR] [--cells a,b] [--ext FILE] [--model|--stabs]', file=sys.stderr)
        return 2
    if shutil.which('omp') is None:
        print('NOT_IMPLEMENTED: нет omp в PATH — стенд без реального omp не судит', file=sys.stderr)
        return 2
    for rel in ('config/agent_models.json', '.omp/config.yml', '.omp/agents/%s.md' % ROLE):
        if not os.path.isfile(os.path.join(subj, rel)):
            print('NOT_IMPLEMENTED: у субъекта %s нет %s' % (subj, rel), file=sys.stderr)
            return 2
    am = json.load(open(os.path.join(subj, 'config/agent_models.json')))
    all_cells = list(cells(am))
    names = names or all_cells
    keep = os.environ.get('P129_KEEP') == '1'
    if mode in ('subject', 'model'):
        overlay = {'ext': os.path.join(HERE, 'model/fallback-route.ts')} if mode == 'model' else {}
        if ext_override is not None:
            overlay['ext'] = ext_override
        fails = run_cells(subj, names, overlay, keep)
        for cell in names:
            print(('ok %s' % cell) if fails[cell] is None else 'FAIL %s: %s' % (cell, fails[cell]))
        print('cells=%d red=%d' % (len(names), sum(1 for v in fails.values() if v)))
        if not names:
            return 1
        return 1 if any(fails.values()) else 0
    src = json.load(open(os.path.join(HERE, 'source.json')))
    uncaught, pairs = 0, 0
    for stub in src['stubs']:
        overlay = {}
        if 'ext' in stub:
            overlay['ext'] = os.path.join(HERE, stub['ext']) if stub['ext'] else ''
        if stub.get('drop_chain'):
            overlay['drop_chain'] = True
        fails = run_cells(subj, stub['cells'], overlay, keep)
        for cell in stub['cells']:
            pairs += 1
            if fails[cell] is None:
                uncaught += 1
                print('UNCAUGHT %s in %s' % (stub['id'], cell))
            else:
                print('caught %s in %s: %s' % (stub['id'], cell, fails[cell]))
    print('stubs=%d pairs=%d uncaught=%d' % (len(src['stubs']), pairs, uncaught))
    if pairs == 0:
        return 1
    return 1 if uncaught else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
