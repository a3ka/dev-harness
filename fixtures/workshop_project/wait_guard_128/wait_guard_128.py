#!/usr/bin/env python3
"""Движок красной батареи 128 (wait-guard). Раннер — red_wait_guard_128.sh рядом.

Режимы (единый источник грамматики режимов и кодов):
  (без режима)          субъект = <корень харнесса>/.omp/extensions/wait-guard.ts
  --model               субъект = model/wait-guard.ts (честная модель)
  --candidate <клон>    субъект = <клон>/.omp/extensions/wait-guard.ts
  --stabs               каждый стаб source.json: КОНТРОЛЬ (модель зелена в клетке стаба),
                        затем стаб в той же клетке обязан разойтись с оракулом → ПОЙМАН
  --live [<клон>]       живые условия станции: имена файлов сессий из живого каталога
                        сессий и живое табло установки (корень или клон); без журналов
                        сессий — rc 2 NOT_IMPLEMENTED
  --load [<клон>]       НАСТОЯЩИЙ загрузчик omp без модели (omp --mode rpc --no-ui, stdin
                        EOF, свой PI_CODING_AGENT_DIR и cwd) грузит субъект вместе с
                        канарейкой named-only: субъект загружен ⇔ кадр ready, канарейка
                        отвергнута строкой «Failed to load extension <канарейка>:», а
                        строки «Failed to load extension <субъект>:» нет. С --model —
                        модель; с --stabs — КОНТРОЛЬ (модель грузится), затем каждый стаб
                        с полем zagruzka в source.json обязан быть отвергнут → ПОЙМАН.
                        Нет omp / нет ready / канарейка не отвергнута — rc 2 NEEDS_ENV.
                        В CI не подключается (как --live).
  --cell <id>           только эта клетка (к режимам субъекта и --stabs)
  --seed <N>            seed генератора табло (по умолчанию — случайный, печатается)

Коды: 0 — все клетки сошлись / все стабы пойманы / живая сверка сошлась / субъект загружен;
      1 — расхождение / непойманный стаб / предмет отсутствует / загрузчик отверг субъект;
      2 — нечем проверить (нет node/python/omp, якорь стаба не ровно один раз, нет такой
          клетки, живого каталога сессий нет, живое табло упало, живая граница сдвинулась,
          загрузчик omp не дал ready или не отверг канарейку).

Мир клетки: mktemp под /tmp/dev-harness-verify — toy-УСТАНОВКА inst/ (копия субъекта в
inst/.omp/extensions/wait-guard.ts, игрушечное табло inst/ops/server/user/orch-tablo,
переписываемое ПЕРЕД каждым вызовом) и каталог проекта proj/ (cwd драйвера). Драйвер —
node: import субъекта, фабрика выбирается ровно как getExtensionFactory загрузчика omp
(модуль-функция, иначе module.default; omp://extension-loading.md «Module import and
factory contract») и ожидается (await); синтетический pi собирает tool_call-обработчики,
события и ctx — из спецификации клетки. Игрушечное табло пишет строку в tablo_calls.log на
каждый запуск.

Алфавит исходов вызова: BLOCK | PASS | WARN_TABLO | WARN_SESSION (+ THROW, TIMEOUT,
WARN_MIXED — только как факт). Алфавит расхождений:
  <клетка>:<вызов>:ozhidalsya-<ИСХОД>-fakt-<ИСХОД>
  <клетка>:<вызов>:zagolovok | <клетка>:<вызов>:perechen
  <клетка>:zapuskov-<N>-fakt-<M> | <клетка>:<вызов>:dolgo-<мс>
  <клетка>:НЕТ фабрики omp: … | <клетка>:НЕТ обработчика tool_call
"""
import json, os, random, shutil, subprocess, sys, tempfile, time, uuid, glob, re

HERE = os.path.dirname(os.path.realpath(__file__))
ROOT = os.path.realpath(os.path.join(HERE, '..', '..', '..'))
SRC = json.load(open(os.path.join(HERE, 'source.json'), encoding='utf-8'))
MODEL = os.path.join(HERE, 'model', 'wait-guard.ts')
BASE = '/tmp/dev-harness-verify'
WARN_TABLO = 'ПРЕДУПРЕЖДЕНИЕ wait-guard: табло недоступно'
WARN_SESSION = 'ПРЕДУПРЕЖДЕНИЕ wait-guard: сессия не опознана'
STOIT_LIVE = re.compile(r'^ *СТОИТ ([0-9]+) мин ')


def header(n, k):
    return f'ОТКАЗ wait-guard: на табло строк СТОИТ ≥ {n} мин — {k}; сделай ход по каждой до wait'


# ── генератор табло (форма — print-строки ops/server/user/orch-tablo, замер 2026-10-21 15:05) ──
class Gen:
    def __init__(self, rng):
        self.r = rng
        self.used = set()

    def num(self):
        while True:
            n = self.r.randint(100, 999)
            if n not in self.used:
                self.used.add(n)
                return n

    def agent(self, n):
        return self.r.choice(['Architect', 'Adv', 'Rev', 'Impl', 'Critic']) + str(n) + self.r.choice(['', 'b', 'c', 'd'])

    def subj(self, m):
        n = self.num()
        st = self.r.choice(['frozen', 'до заморозки'])
        last = self.r.choice([f'агент {self.agent(n)} сдал результат', f'main: land: wip/{n}/architect',
                              f'main: fork: n{n}-krug3-obem — кап 3 критика {n} исчерпан'])
        return ('stoit', m, f'  СТОИТ {m} мин {n} [{st}]: последнее — {last}')

    def pr(self, m):
        repo = self.r.choice(['dev-harness', 'Complior-back', 'Complior-mob'])
        n = self.num()
        ci = self.r.choice(['зелёный', 'красный'])
        return ('stoit', m, f'  СТОИТ {m} мин PR {repo}#{self.r.randint(1, 400)} (owner/tip-{n}d): CI {ci}, по нему никто не работает')

    def stale(self, m):
        return self.subj(m) if self.r.random() < 0.6 else self.pr(m)

    def rab(self):
        n = self.num()
        return ('rab', None, f'  РАБОТАЕТ {n} [frozen]: {self.agent(n)} ({self.r.randint(0, 5)} мин)')

    def ci(self):
        n = self.num()
        return ('ci', None, f'  ЖДЁТ CI {n} [frozen]: PR #{self.r.randint(150, 400)} — последнее: main: land: wip/{n}/architect')

    def potok(self, s, m):
        idle = f'{m} мин' if m is not None else 'больше 360 мин'
        return ('potok', m, f'  СТОИТ ПОТОК {s}: ни один предмет не в работе — {idle}; возьми следующую задачу потока')

    def tablo(self, rows, potoki=None, itog=True):
        rows = list(rows)
        self.r.shuffle(rows)
        out = [f'ТАБЛО {self.r.randint(0, 23):02d}:{self.r.randint(0, 59):02d} UTC (окно 360 мин)']
        out += [t for _, _, t in rows]
        out.append('ПОТОКИ:')
        streams = potoki if potoki is not None else [('w', None, f'  {s}: в работе предметов — {self.r.randint(1, 3)}') for s in ('харнесс', 'mob', 'бэкенд')]
        out += [t for _, _, t in streams]
        k = sum(1 for _, _, t in rows + streams if t.startswith('  СТОИТ '))
        if itog:
            out.append(f'итог: стоит без хода — {k}' + ('  → сделай следующий шаг по каждой строке СТОИТ до wait' if k else ''))
        return '\n'.join(out) + '\n', rows

    def potoki_with(self, extra):
        names = ['харнесс', 'mob', 'бэкенд']
        out = []
        for s in names:
            if s in extra:
                out.append(self.potok(s, extra[s]))
            else:
                out.append(('w', None, f'  {s}: в работе предметов — {self.r.randint(1, 3)}'))
        return out


def stale_of(rows, n):
    return [t.lstrip(' ') for kind, m, t in rows if kind == 'stoit' and m >= n]


def top_session(rng, w):
    ts = f'2026-{rng.randint(1, 12):02d}-{rng.randint(1, 28):02d}T{rng.randint(0, 23):02d}-{rng.randint(0, 59):02d}-{rng.randint(0, 59):02d}-{rng.randint(0, 999):03d}Z'
    u = uuid.UUID(int=rng.getrandbits(128))
    return os.path.join(w, 'sessions', '--home-harness-dev-harness--', f'{ts}_{u}.jsonl')


def sub_session(rng, top):
    name = rng.choice(['Architect128', 'Adv127', 'Rev127', 'Impl127b', 'Critic117v2', 'Architect117e.Scout1'])
    return os.path.join(top[:-len('.jsonl')], f'{name}.jsonl')


def out_spec(stdout, rc=0, stderr=''):
    return {'kind': 'out', 'stdout': stdout, 'stderr': stderr, 'rc': rc}


# ── клетки: (вызовы, установка мира). Ожидаемый ИСХОД — source.json (want); перечень — здесь ──
def build_cell(cid, rng, w):
    g = Gen(rng)
    top = top_session(rng, w)
    orch = {'session': top}
    calls, decoy = [], None

    def call(tablo, n=8, sess=None, tool='wait', env=None, lines=None):
        c = {'tool': tool, 'tablo': tablo, 'env': env or {}, 'n': n, 'lines': lines}
        c.update(sess if sess is not None else orch)
        calls.append(c)

    def stale_tablo(k_lo=1, k_hi=3, n=8):
        txt, rows = g.tablo([g.stale(rng.randint(n, n + 300)) for _ in range(rng.randint(k_lo, k_hi))] + [g.rab() for _ in range(rng.randint(0, 2))])
        return txt, stale_of(rows, n)

    if cid == 'c01-stoit':
        txt, st = stale_tablo(3, 7)
        call(out_spec(txt), lines=st)
    elif cid == 'c02-bez-stoit':
        txt, _ = g.tablo([g.rab() for _ in range(rng.randint(1, 3))] + [g.ci() for _ in range(rng.randint(0, 2))])
        call(out_spec(txt))
    elif cid == 'c03-molozhe':
        # граница порог−1 (7 мин) — всегда, не по seed
        txt, _ = g.tablo([g.stale(7)] + [g.stale(rng.randint(0, 7)) for _ in range(rng.randint(0, 3))] + [g.rab()])
        call(out_spec(txt))
    elif cid == 'c04-granica':
        rows = [g.stale(9), g.stale(8), g.stale(7)] + [g.stale(rng.randint(0, 6)) for _ in range(rng.randint(0, 2))] + [g.rab()]
        txt, rows = g.tablo(rows)
        call(out_spec(txt), lines=stale_of(rows, 8))
    elif cid == 'c05-zhdet-ci':
        txt, _ = g.tablo([g.ci() for _ in range(rng.randint(2, 3))] + [g.rab()])
        call(out_spec(txt))
    elif cid == 'c06-potok':
        txt, _ = g.tablo([g.rab()], potoki=g.potoki_with({'харнесс': rng.randint(8, 300), rng.choice(['mob', 'бэкенд']): None}))
        call(out_spec(txt))
    elif cid == 'c08-porog-env':
        cell = SRC_CELLS[cid]
        ps = cell['t_po_seed']
        # весь допустимый диапазон с границами — всегда; сверх того — значения от seed
        for t in cell['t_values'] + [rng.randint(ps['lo'], ps['hi']) for _ in range(ps['count'])]:
            rows = ([g.stale(t - 1)] if t > 1 else []) + [g.stale(t), g.stale(t + 1), g.stale(t + rng.randint(2, 100)), g.rab()]
            txt, rows = g.tablo(rows)
            call(out_spec(txt), n=t, env={'WAIT_GUARD_MIN': str(t)}, lines=stale_of(rows, t))
    elif cid == 'c09-porog-nerazobran':
        for v in SRC_CELLS[cid]['env_values']:
            txt, rows = g.tablo([g.stale(9), g.stale(8), g.stale(7), g.rab()])
            call(out_spec(txt), env={'WAIT_GUARD_MIN': v}, lines=stale_of(rows, 8))
    elif cid == 'c10-tablo-net':
        call({'kind': 'absent'})
    elif cid == 'c11-tablo-rc':
        txt, _ = stale_tablo(2, 4)
        call(out_spec(txt, rc=1, stderr='Traceback (most recent call last):\n  gh: HTTP 502\n'))
    elif cid == 'c12-pustoj':
        call(out_spec(''))
    elif cid == 'c13-bez-itoga':
        txt, _ = g.tablo([g.stale(rng.randint(8, 300)) for _ in range(rng.randint(1, 3))], itog=False)
        call(out_spec(txt))
    elif cid == 'c14-zavis':
        call({'kind': 'hang'})
    elif cid == 'c15-subagent':
        txt, _ = stale_tablo(2, 4)
        call(out_spec(txt), sess={'session': sub_session(rng, top)})
    elif cid == 'c17-neopoznana':
        txt, _ = stale_tablo(2, 4)
        call(out_spec(txt), sess={'session': None, 'ctx': 'bez-sm'})
        call(out_spec(txt), sess={'session': None, 'ctx': 'undefined'})
        call(out_spec(txt), sess={'session': top[:-len('.jsonl')] + '.json'})
    elif cid == 'c18-drugoj-instrument':
        txt, _ = stale_tablo(2, 4)
        call(out_spec(txt), tool=rng.choice(['bash', 'task', 'read', 'write']))
    elif cid == 'c19-cikl':
        txt, st = stale_tablo(1, 3)
        call(out_spec(txt), lines=st)
        call(out_spec(txt), lines=st)
        txt2, _ = g.tablo([g.rab() for _ in range(rng.randint(1, 3))])
        call(out_spec(txt2))
    elif cid == 'c20-ustanovka':
        txt, st = stale_tablo(1, 3)
        call(out_spec(txt), lines=st)
        decoy, _ = g.tablo([g.rab()])
    else:
        raise KeyError(cid)
    return calls, decoy


SRC_CELLS = {c['id']: c for c in SRC['cells']}

TABLO_TPL = '''#!/usr/bin/env python3
import json, sys, time
SPEC = json.loads({spec!r})
with open({log!r}, 'a') as f:
    f.write('z\\n')
if SPEC['kind'] == 'hang':
    time.sleep(120)
sys.stdout.write(SPEC['stdout'])
sys.stderr.write(SPEC['stderr'])
sys.exit(SPEC['rc'])
'''

DRIVER = r'''
import { pathToFileURL } from 'node:url';
import { readFileSync, writeFileSync, rmSync } from 'node:fs';
const [guard, specFile] = process.argv.slice(2);
const spec = JSON.parse(readFileSync(specFile, 'utf8'));
process.chdir(spec.cwd);
delete process.env.WAIT_GUARD_MIN;
const mod = await import(pathToFileURL(guard).href);
// Ровно getExtensionFactory загрузчика omp: модуль-функция, иначе module.default.
const reg = typeof mod === 'function' ? mod : mod.default;
if (typeof reg !== 'function') { console.log(JSON.stringify({ fatal: 'НЕТ фабрики omp: модуль не функция и default не функция (Extension does not export a valid factory function)' })); process.exit(0); }
const handlers = [];
const pi = { on: (name, h) => { if (name === 'tool_call') handlers.push(h); }, sendMessage: () => {}, registerTool: () => {}, registerCommand: () => {} };
await reg(pi);
if (handlers.length < 1) { console.log(JSON.stringify({ fatal: 'НЕТ обработчика tool_call' })); process.exit(0); }
const res = [];
for (const [i, c] of spec.calls.entries()) {
  if (c.tabloScript === null) rmSync(spec.tabloPath, { force: true });
  else writeFileSync(spec.tabloPath, c.tabloScript, { mode: 0o755 });
  delete process.env.WAIT_GUARD_MIN;
  for (const [k, v] of Object.entries(c.env)) process.env[k] = v;
  let ctx;
  if (c.ctx === 'bez-sm') ctx = { cwd: spec.cwd, hasUI: true };
  else if (c.ctx === 'undefined') ctx = { cwd: spec.cwd, hasUI: true, sessionManager: { getSessionFile: () => undefined, getSessionId: () => 'sid-128' } };
  else ctx = { cwd: spec.cwd, hasUI: true, sessionManager: { getSessionFile: () => c.session, getSessionId: () => 'sid-128' } };
  const event = { type: 'tool_call', toolName: c.tool, toolCallId: `call-${i}`, input: {} };
  const t0 = Date.now();
  const r = { block: false, reason: null, context: [], threw: null, timeout: false, ms: 0 };
  for (const h of handlers) {
    let got;
    try {
      got = await Promise.race([Promise.resolve(h(event, ctx)), new Promise((res2) => setTimeout(() => res2('__TIMEOUT__'), 40000))]);
    } catch (e) { r.threw = String(e); break; }
    if (got === '__TIMEOUT__') { r.timeout = true; break; }
    if (got && typeof got === 'object') {
      if (got.block === true) { r.block = true; r.reason = typeof got.reason === 'string' ? got.reason : null; break; }
      if (typeof got.additionalContext === 'string') r.context.push(got.additionalContext);
    }
  }
  r.ms = Date.now() - t0;
  res.push(r);
}
console.log(JSON.stringify({ calls: res }));
process.exit(0);
'''


def classify(r):
    if r['timeout']:
        return 'TIMEOUT'
    if r['threw'] is not None:
        return 'THROW'
    if r['block']:
        return 'BLOCK'
    lines = '\n'.join(r['context']).split('\n')
    wt = any(l.startswith(WARN_TABLO) for l in lines)
    ws = any(l.startswith(WARN_SESSION) for l in lines)
    if wt and ws:
        return 'WARN_MIXED'
    return 'WARN_TABLO' if wt else ('WARN_SESSION' if ws else 'PASS')


def run_cell(cid, subject_text, seed):
    cell = SRC_CELLS[cid]
    rng = random.Random(f'{seed}:{cid}')
    os.makedirs(BASE, exist_ok=True)
    w = tempfile.mkdtemp(prefix='wg128-', dir=BASE)
    try:
        calls, decoy = build_cell(cid, rng, w)
        inst_ext = os.path.join(w, 'inst', '.omp', 'extensions')
        inst_tab = os.path.join(w, 'inst', 'ops', 'server', 'user')
        proj = os.path.join(w, 'proj')
        for d in (inst_ext, inst_tab, proj):
            os.makedirs(d)
        guard = os.path.join(inst_ext, 'wait-guard.ts')
        open(guard, 'w', encoding='utf-8').write(subject_text)
        log = os.path.join(w, 'tablo_calls.log')
        if decoy is not None:
            dd = os.path.join(proj, 'ops', 'server', 'user')
            os.makedirs(dd)
            open(os.path.join(dd, 'orch-tablo'), 'w', encoding='utf-8').write(
                TABLO_TPL.format(spec=json.dumps(out_spec(decoy)), log=os.path.join(w, 'decoy_calls.log')))
        spec = {'cwd': proj, 'tabloPath': os.path.join(inst_tab, 'orch-tablo'), 'calls': []}
        for c in calls:
            t = c['tablo']
            script = None if t['kind'] == 'absent' else TABLO_TPL.format(
                spec=json.dumps(t if t['kind'] == 'out' else {'kind': 'hang', 'stdout': '', 'stderr': '', 'rc': 0}), log=log)
            spec['calls'].append({'tool': c['tool'], 'session': c.get('session'), 'ctx': c.get('ctx'), 'env': c['env'], 'tabloScript': script})
        sf = os.path.join(w, 'spec.json')
        json.dump(spec, open(sf, 'w', encoding='utf-8'), ensure_ascii=False)
        drv = os.path.join(w, 'driver.mjs')
        open(drv, 'w', encoding='utf-8').write(DRIVER)
        env = {k: v for k, v in os.environ.items() if k != 'WAIT_GUARD_MIN'}
        env['PYTHONDONTWRITEBYTECODE'] = '1'
        p = subprocess.run(['node', '--no-warnings', drv, guard, sf], capture_output=True, text=True, env=env, timeout=600)
        try:
            out = json.loads(p.stdout.strip().splitlines()[-1])
        except (ValueError, IndexError):
            return [f'{cid}:driver-rc-{p.returncode}:{(p.stderr.strip().splitlines() or ["—"])[-1][:160]}']
        if 'fatal' in out:
            return [f'{cid}:{out["fatal"]}']
        bad = []
        want = cell['want']
        if len(out['calls']) != len(want):
            return [f'{cid}:vyzovov-{len(want)}-fakt-{len(out["calls"])}']
        for i, (c, r, wnt) in enumerate(zip(calls, out['calls'], want)):
            fact = classify(r)
            if fact != wnt:
                bad.append(f'{cid}:{i}:ozhidalsya-{wnt}-fakt-{fact}')
                continue
            if wnt == 'BLOCK':
                got = (r['reason'] or '').split('\n')
                if got[0] != header(c['n'], len(c['lines'])):
                    bad.append(f'{cid}:{i}:zagolovok')
                if got[1:] != c['lines']:
                    bad.append(f'{cid}:{i}:perechen')
            if 'max_ms' in cell and r['ms'] >= cell['max_ms']:
                bad.append(f'{cid}:{i}:dolgo-{r["ms"]}')
        n_runs = len(open(log).read().splitlines()) if os.path.exists(log) else 0
        if n_runs != cell['zapuskov']:
            bad.append(f'{cid}:zapuskov-{cell["zapuskov"]}-fakt-{n_runs}')
        return bad
    finally:
        shutil.rmtree(w, ignore_errors=True)


def run_subject(label, path, cells, seed):
    if not os.path.isfile(path):
        print(f'КРАСНО: предмет отсутствует: {path}', file=sys.stderr)
        print(f'ИТОГ 128 ({label}): предмет отсутствует')
        return 1
    text = open(path, encoding='utf-8').read()
    ok = 0
    for cid in cells:
        bad = run_cell(cid, text, seed)
        if bad:
            for b in bad:
                print(f'РАСХОЖДЕНИЕ {b}')
        else:
            ok += 1
            print(f'ok {cid}')
    print(f'ИТОГ 128 ({label}): клеток {len(cells)}, сошлось {ok}, расхождений {len(cells) - ok} (seed {seed})')
    return 0 if ok == len(cells) else 1


def make_stub(model, st):
    text = model
    for a, b in st['subst']:
        if model.count(a) != 1:
            raise ValueError(f'стаб {st["id"]}: якорь встречается в модели {model.count(a)} раз: {a[:60]!r}')
        text = text.replace(a, b)
    return text


def run_stubs(only, seed):
    model = open(MODEL, encoding='utf-8').read()
    stubs = [s for s in SRC['stubs'] if only is None or s['cell'] == only]
    if not stubs:
        print(f'нет стабов для клетки: {only}', file=sys.stderr)
        return 2
    try:
        texts = {s['id']: make_stub(model, s) for s in stubs}
    except ValueError as e:
        print(f'ОТКАЗ: {e}', file=sys.stderr)
        return 2
    caught = 0
    for s in stubs:
        ctrl = run_cell(s['cell'], model, seed)
        if ctrl:
            print(f'КОНТРОЛЬ НЕ СОШЁЛСЯ {s["id"]} @ {s["cell"]}: {"; ".join(ctrl)}')
            continue
        bad = run_cell(s['cell'], texts[s['id']], seed)
        if bad:
            caught += 1
            print(f'ПОЙМАН {s["id"]} @ {s["cell"]}: {"; ".join(bad)}')
        else:
            print(f'НЕ ПОЙМАН {s["id"]} @ {s["cell"]}')
    print(f'ИТОГ 128 (стабы): стабов {len(stubs)}, поймано {caught}, непойманных {len(stubs) - caught} (seed {seed})')
    return 0 if caught == len(stubs) else 1


LIVE_GLOB = '/home/harness/.local/state/dev-harness-sessions/*/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--'


def run_live(root, seed):
    """Живые условия: (1) имена файлов сессий — из живого каталога сессий станции;
    (2) табло — живое табло установки root (ops/server/user/orch-tablo с её git/gh)."""
    subj = os.path.join(root, '.omp', 'extensions', 'wait-guard.ts')
    if not os.path.isfile(subj):
        print(f'КРАСНО: предмет отсутствует: {subj}', file=sys.stderr)
        print('ИТОГ 128 (живьём): предмет отсутствует')
        return 1
    tops = sorted(f for b in glob.glob(LIVE_GLOB) for f in glob.glob(b + '/*.jsonl'))
    subs = sorted(f for b in glob.glob(LIVE_GLOB) for f in glob.glob(b + '/*/*.jsonl'))
    print(f'живых файлов сессий: верхнего уровня {len(tops)}, субагентов {len(subs)}')
    if not tops or not subs:
        print('NOT_IMPLEMENTED: нет живого каталога сессий станции (пустая выборка)', file=sys.stderr)
        return 2
    text = open(subj, encoding='utf-8').read()
    bad = []
    # (1) имена: живой верхний → судится (BLOCK на игрушечном stale-табло), живой субагент → PASS
    rng = random.Random(f'{seed}:live')
    g = Gen(rng)
    txt, rows = g.tablo([g.stale(rng.randint(8, 300)), g.rab()])
    for kind, path, wnt in (('top', tops[-1], 'BLOCK'), ('top0', tops[0], 'BLOCK'), ('sub', subs[-1], 'PASS'), ('sub0', subs[0], 'PASS')):
        r = live_call(text, None, path, txt)
        fact = classify(r)
        print(f'  имя {kind}: {os.path.basename(path)} → {fact}' + (f' ({r["threw"]})' if r['threw'] else ''))
        if fact != wnt:
            bad.append(f'live-imya-{kind}:ozhidalsya-{wnt}-fakt-{fact}')
    # (2) живое табло установки: оракул — собственный прогон табло ДО субъекта
    tablo = os.path.join(root, 'ops', 'server', 'user', 'orch-tablo')
    o = subprocess.run(['python3', tablo], capture_output=True, text=True, timeout=120,
                       env={**os.environ, 'PYTHONDONTWRITEBYTECODE': '1'})
    if o.returncode != 0 or not o.stdout.strip():
        print(f'NOT_IMPLEMENTED: живое табло rc {o.returncode}: {o.stderr.strip()[:160]}', file=sys.stderr)
        return 2
    mins = [int(m.group(1)) for m in map(STOIT_LIVE.match, o.stdout.splitlines()) if m]
    edge = [m for m in mins if m in (7, 8)]
    if edge:
        print(f'живая граница сдвигается (строки {edge} мин у порога 8) — повтори прогон', file=sys.stderr)
        return 2
    want = 'BLOCK' if any(m >= 8 for m in mins) else 'PASS'
    r = live_call(text, root, tops[-1], None)
    fact = classify(r)
    print(f'  живое табло: строк СТОИТ N мин {len(mins)}, из них ≥ 8 — {sum(m >= 8 for m in mins)} → ждём {want}, факт {fact} ({r["ms"]} мс)')
    if fact != want:
        bad.append(f'live-tablo:ozhidalsya-{want}-fakt-{fact}')
    elif want == 'BLOCK':
        got = (r['reason'] or '').split('\n')[1:]
        exp = [re.sub(r'^СТОИТ [0-9]+ мин ', '', l.lstrip(' ')) for l in o.stdout.splitlines()
               if (m := STOIT_LIVE.match(l)) and int(m.group(1)) >= 8]
        heads = [re.sub(r'^СТОИТ [0-9]+ мин ', '', l) for l in got]
        if sorted(heads) != sorted(exp):
            bad.append('live-tablo:perechen')
    for b in bad:
        print(f'РАСХОЖДЕНИЕ {b}')
    print(f'ИТОГ 128 (живьём): расхождений {len(bad)} (seed {seed})')
    return 0 if not bad else 1


def live_call(text, root, session, tablo_txt):
    """Один wait ведущей/субагента. root=None → игрушечная установка с табло tablo_txt;
    иначе — субъект на своём месте в root (живое табло установки)."""
    os.makedirs(BASE, exist_ok=True)
    w = tempfile.mkdtemp(prefix='wg128-live-', dir=BASE)
    try:
        if root is None:
            ext = os.path.join(w, 'inst', '.omp', 'extensions')
            tab = os.path.join(w, 'inst', 'ops', 'server', 'user')
            os.makedirs(ext)
            os.makedirs(tab)
            guard = os.path.join(ext, 'wait-guard.ts')
            open(guard, 'w', encoding='utf-8').write(text)
            script = TABLO_TPL.format(spec=json.dumps(out_spec(tablo_txt)), log=os.path.join(w, 'log'))
            tpath = os.path.join(tab, 'orch-tablo')
        else:
            guard = os.path.join(root, '.omp', 'extensions', 'wait-guard.ts')
            script, tpath = None, None
        proj = os.path.join(w, 'proj')
        os.makedirs(proj)
        spec = {'cwd': proj, 'tabloPath': tpath or os.path.join(w, 'nenuzhen'),
                'calls': [{'tool': 'wait', 'session': session, 'ctx': None, 'env': {}, 'tabloScript': script if script else ''}]}
        if root is not None:
            spec['calls'][0]['tabloScript'] = ''   # пишется в w/nenuzhen — табло установки не трогается
        sf = os.path.join(w, 'spec.json')
        json.dump(spec, open(sf, 'w', encoding='utf-8'), ensure_ascii=False)
        drv = os.path.join(w, 'driver.mjs')
        open(drv, 'w', encoding='utf-8').write(DRIVER)
        env = {k: v for k, v in os.environ.items() if k != 'WAIT_GUARD_MIN'}
        p = subprocess.run(['node', '--no-warnings', drv, guard, sf], capture_output=True, text=True, env=env, timeout=300)
        out = json.loads(p.stdout.strip().splitlines()[-1])
        if 'fatal' in out:
            return {'timeout': False, 'threw': out['fatal'], 'block': False, 'reason': None, 'context': [], 'ms': 0}
        return out['calls'][0]
    finally:
        shutil.rmtree(w, ignore_errors=True)


LOAD_FAIL = 'Failed to load extension '
# Канарейка — форма, которую загрузчик omp обязан отвергнуть (named-only, без default).
# Отдельный прогон канарейки той же командой доказывает, что загрузчик в этой среде судит
# --extension и что его отказ читается этой мерой; без него «нет строки отказа» — не
# свидетельство загрузки. Субъект грузится ОДИН (--no-extensions, пустой агентский
# каталог): любая строка отказа его прогона — его; путь в строке не сверяется (omp
# сокращает длинные пути многоточием — замер 2026-10-21).
CANARY = 'export function register(pi: unknown): void {\n  void pi;\n}\n'


def omp_run(ext):
    """Один старт настоящего загрузчика omp с единственным --extension. → (None|NEEDS_ENV, строки отказа)."""
    omp = shutil.which('omp')
    if omp is None:
        return 'NEEDS_ENV: нет omp в PATH', []
    os.makedirs(BASE, exist_ok=True)
    w = tempfile.mkdtemp(prefix='wg128-load-', dir=BASE)
    try:
        cwd, agent = os.path.join(w, 'cwd'), os.path.join(w, 'agent')
        os.makedirs(cwd)
        os.makedirs(agent)
        cmd = [omp, '--mode', 'rpc', '--no-ui', '--no-session', '--no-extensions', '--extension', ext,
               '--no-skills', '--no-rules', '--no-tools', '--no-lsp']
        env = {k: v for k, v in os.environ.items() if k != 'WAIT_GUARD_MIN'}
        env['PI_CODING_AGENT_DIR'] = agent
        try:
            p = subprocess.run(cmd, cwd=cwd, stdin=subprocess.DEVNULL, capture_output=True, text=True, env=env, timeout=120)
        except subprocess.TimeoutExpired:
            return 'NEEDS_ENV: omp не завершился за 120 с после EOF stdin', []
        except OSError as e:
            return f'NEEDS_ENV: omp не запускается: {e}', []
        ready = False
        for line in p.stdout.splitlines():
            try:
                ready = ready or json.loads(line).get('type') == 'ready'
            except (ValueError, AttributeError):
                pass
        if not ready:
            tail = (p.stderr.strip().splitlines() or ['—'])[-1][:200]
            return f'NEEDS_ENV: omp rc {p.returncode} без кадра ready: {tail}', []
        return None, [l for l in p.stderr.splitlines() if l.startswith(LOAD_FAIL)]
    finally:
        shutil.rmtree(w, ignore_errors=True)


def omp_load(subject):
    """Настоящий загрузчик omp без модели. → (rc, причина): 0 загружен, 1 отвергнут, 2 NEEDS_ENV."""
    os.makedirs(BASE, exist_ok=True)
    w = tempfile.mkdtemp(prefix='wg128-canary-', dir=BASE)
    try:
        canary = os.path.join(w, 'named-only.ts')
        open(canary, 'w', encoding='utf-8').write(CANARY)
        env_err, fails = omp_run(canary)
    finally:
        shutil.rmtree(w, ignore_errors=True)
    if env_err:
        return 2, env_err
    if len(fails) != 1:
        return 2, f'NEEDS_ENV: канарейка named-only дала строк отказа {len(fails)}, ждали 1 — загрузчик не судит --extension этой мерой'
    env_err, fails = omp_run(os.path.realpath(subject))
    if env_err:
        return 2, env_err
    if fails:
        return 1, fails[0][:300]
    return 0, 'загружен: кадр ready, отказа загрузки нет; канарейка той же командой отвергнута'


def run_load(label, path):
    if not os.path.isfile(path):
        print(f'КРАСНО: предмет отсутствует: {path}', file=sys.stderr)
        print(f'ИТОГ 128 (загрузка, {label}): предмет отсутствует')
        return 1
    rc, why = omp_load(path)
    print(f'  {path}: {why}')
    print(f'ИТОГ 128 (загрузка, {label}): ' + {0: 'загружен', 1: 'ОТВЕРГНУТ загрузчиком omp', 2: 'NEEDS_ENV'}[rc])
    return rc


def run_load_stubs():
    model = open(MODEL, encoding='utf-8').read()
    stubs = [s for s in SRC['stubs'] if s.get('zagruzka')]
    if not stubs:
        print('ОТКАЗ: в source.json нет стабов с полем zagruzka (пустая выборка)', file=sys.stderr)
        return 2
    try:
        texts = {s['id']: make_stub(model, s) for s in stubs}
    except ValueError as e:
        print(f'ОТКАЗ: {e}', file=sys.stderr)
        return 2
    rc, why = omp_load(MODEL)
    if rc != 0:
        print(f'КОНТРОЛЬ НЕ СОШЁЛСЯ: модель: {why}')
        print(f'ИТОГ 128 (загрузка, стабы): контроль rc {rc}')
        return 2
    print(f'КОНТРОЛЬ модель: {why}')
    caught = 0
    for s in stubs:
        os.makedirs(BASE, exist_ok=True)
        w = tempfile.mkdtemp(prefix='wg128-loadstub-', dir=BASE)
        try:
            ext = os.path.join(w, 'inst', '.omp', 'extensions')
            os.makedirs(ext)
            f = os.path.join(ext, 'wait-guard.ts')
            open(f, 'w', encoding='utf-8').write(texts[s['id']])
            rc, why = omp_load(f)
        finally:
            shutil.rmtree(w, ignore_errors=True)
        if rc == 2:
            print(f'NEEDS_ENV {s["id"]}: {why}')
            return 2
        if rc == 1:
            caught += 1
            print(f'ПОЙМАН {s["id"]} @ загрузка: {why}')
        else:
            print(f'НЕ ПОЙМАН {s["id"]} @ загрузка')
    print(f'ИТОГ 128 (загрузка, стабы): стабов {len(stubs)}, поймано {caught}, непойманных {len(stubs) - caught}')
    return 0 if caught == len(stubs) else 1


def main(argv):
    mode, target, cell, seed, load = 'subject', None, None, None, False
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == '--model':
            mode = 'model'
        elif a == '--stabs':
            mode = 'stabs'
        elif a == '--candidate':
            mode, target = 'candidate', argv[i + 1]
            i += 1
        elif a == '--live':
            mode = 'live'
            if i + 1 < len(argv) and not argv[i + 1].startswith('--'):
                target = argv[i + 1]
                i += 1
        elif a == '--load':
            load = True
            if i + 1 < len(argv) and not argv[i + 1].startswith('--'):
                target = argv[i + 1]
                i += 1
        elif a == '--cell':
            cell = argv[i + 1]
            i += 1
        elif a == '--seed':
            seed = int(argv[i + 1])
            i += 1
        else:
            print(f'неизвестный аргумент: {a}', file=sys.stderr)
            return 2
        i += 1
    if seed is None:
        seed = random.SystemRandom().randint(1, 10**9)
    if cell is not None and cell not in SRC_CELLS:
        print(f'нет такой клетки: {cell}', file=sys.stderr)
        return 2
    for c in SRC_CELLS.values():
        if any(o not in SRC['outcomes'] for o in c['want']):
            print(f'ОТКАЗ: клетка {c["id"]}: исход вне алфавита', file=sys.stderr)
            return 2
    for s in SRC['stubs']:
        if s['cell'] not in SRC_CELLS:
            print(f'ОТКАЗ: стаб {s["id"]}: нет клетки {s["cell"]}', file=sys.stderr)
            return 2
    if load:
        if mode == 'model':
            return run_load('модель', MODEL)
        if mode == 'stabs':
            return run_load_stubs()
        if mode != 'subject' or cell is not None:
            print('--load несовместим с --candidate/--live/--cell', file=sys.stderr)
            return 2
        return run_load('кандидат' if target else 'продукт',
                        os.path.join(target or ROOT, '.omp', 'extensions', 'wait-guard.ts'))
    cells = [cell] if cell else [c['id'] for c in SRC['cells']]
    if mode == 'model':
        return run_subject('модель', MODEL, cells, seed)
    if mode == 'stabs':
        return run_stubs(cell, seed)
    if mode == 'candidate':
        return run_subject('кандидат', os.path.join(target, '.omp', 'extensions', 'wait-guard.ts'), cells, seed)
    if mode == 'live':
        return run_live(os.path.realpath(target) if target else ROOT, seed)
    return run_subject('продукт', os.path.join(ROOT, '.omp', 'extensions', 'wait-guard.ts'), cells, seed)


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
