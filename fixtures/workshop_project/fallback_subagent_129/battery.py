#!/usr/bin/env python3
"""Battery of contract 129 (fallback-subagent): real omp 18.x against a stub provider.

usage:
  battery.py [--subject DIR] [--cells a,b]   judge the SUBJECT tree (default: repo root)
  battery.py --model                         judge the honest model (model/fallback-route.ts) — all green
  battery.py --stabs                         every cheat of source.json must be red in each bound cell
  battery.py --parser                        observer self-tests: marker link + deceptive observer stubs

Exit: 0 all cells green (or, with --stabs, every stub caught); 1 otherwise; 2 stand broken
or omp output format unrecognized (named refusal «формат omp изменился: <поле>»).
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
            script=[task_step(CHILD, MARK + " yield.")],
            expect=('completed', F), world=None),
        # c2: the live death (omp log 2026-10-21): the sibling hit the exhausted primary and then
        # was rejected on the fallback -> the fallback sits in the process-wide cooldown; the
        # child spawned next must still finish on the tier fallback.
        'c2-sosed-cooldown': dict(
            models=modes(quota_providers=(prov[P],), override={F: {"sib": "quota", "default": "ok"}}),
            script=[task_step(SIB, SIB_MARK + " sibling."), task_step(CHILD, MARK + " yield.")],
            expect=('completed', F), world=[(P, 'quota'), (F, 'quota')]),
        # c3: healthy primary -> the child stays on the PRIMARY (no gratuitous re-route).
        'c3-zdorovyj-primary': dict(
            models=modes(),
            script=[task_step(CHILD, MARK + " yield.")],
            expect=('completed', P), world=None),
        # c4: a sibling's VALIDATION error (400) on the primary is not exhaustion -> next child on PRIMARY.
        'c4-validacija-soseda': dict(
            models=modes(override={P: {"sib": "validation", "default": "ok"}}),
            script=[task_step(SIB, SIB_MARK + " sibling."), task_step(CHILD, MARK + " yield.")],
            expect=('completed', P), world=[(P, 'validation')]),
        # c5: every provider exhausted -> the child FAILS, and switching/retrying stays bounded.
        # Bound = measured omp 18.3.1 behaviour of a dead child: one failed turn + one omp
        # re-prompt = 2 agent turns (honest model 2/2/2, tree of 2026-10-21 2/2; the
        # re-prompt loop cheat s7: 4/5/5). A list-cycle in model[] is neutralised by omp itself.
        'c5-vse-ischerpany': dict(
            models=modes(quota_providers=every),
            script=[task_step(SIB, SIB_MARK + " sibling."), task_step(CHILD, MARK + " yield.")],
            expect=('failed', None), world=[(P, 'quota')], max_child_turns=2),
        # c6: the fallback's cooldown is NOT a quota wall: the sibling hit the exhausted primary,
        # then a 400 on the fallback (omp cools the selector down on hard errors too) -> the
        # fallback provider is healthy; the child spawned next must finish on the tier fallback.
        # Separates "switch when the PRIMARY is exhausted" from "switch only when both providers
        # carry an exhaustion record" (critic 129 round 1): in c2 both answers coincide.
        'c6-zapasnaja-validacija': dict(
            models=modes(quota_providers=(prov[P],), override={F: {"sib": "validation", "default": "ok"}}),
            script=[task_step(SIB, SIB_MARK + " sibling."), task_step(CHILD, MARK + " yield.")],
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


# ── адаптер формата вывода omp — ЕДИНСТВЕННОЕ место, где живёт знание формы события ──
# Слово владельца (2026-11-16, через консультанта): «чтобы ничего жёсткого не было вписано
# в харнессе… омп поменял названия, завтра опять может поменять». Идентификатор omp НЕ
# используется для связи вовсе: ребёнок опознаётся по НАШЕМУ маркеру M129 — логическое имя
# задачи → маркер в задании → результат, несущий этот маркер (завершённый — маркером в
# yield-JSON, умерший — маркером в тексте ошибки stub-провайдера). Знает наблюдатель только
# ФОРМУ события (тег task-result и его поля) — и только здесь; изменившийся формат —
# именованный отказ rc 2 (NOT_IMPLEMENTED-класс), НЕ ложное «нет результата».
MARK_TOKEN = re.compile(r'(?<![A-Za-z0-9])%s(?![A-Za-z0-9])' % re.escape(MARK))
TASK_RESULT_BLOCK = re.compile(r'<task-result\b(?P<attrs>[^>]*)>(?P<body>.*?)</task-result>', re.S)
TASK_RESULT_ATTR = re.compile(r'([\w-]+)="([^"]*)"')
TASK_RESULT_NEED = ('id', 'agent', 'status')


class OmpFormatChanged(Exception):
    """Формат вывода omp не распознан — наблюдатель отказывается судить (живой прогон: rc 2)."""


def read_task_results(out):
    """Транскрипт родителя → [(status, body), …], иначе OmpFormatChanged('формат omp
    изменился: <поле>'). Отказывают: вхождение <task-result>, не разобранное до полей
    id/agent/status и закрывающего тега, и наш маркер, дошедший до родителя ВНЕ
    разобранных блоков (omp сменил форму выдачи). Отсутствие событий вовсе — честное
    «нет результата с маркером» (не отказ)."""
    parsed, rest, prev = [], [], 0
    for m in TASK_RESULT_BLOCK.finditer(out):
        attrs = dict(TASK_RESULT_ATTR.findall(m.group('attrs')))
        miss = [k for k in TASK_RESULT_NEED if k not in attrs]
        if miss:
            raise OmpFormatChanged('формат omp изменился: %s' % miss[0])
        parsed.append((attrs['status'], m.group('body')))
        rest.append(out[prev:m.start()])
        prev = m.end()
    rest.append(out[prev:])
    tail = ''.join(rest)
    if '<task-result' in tail:
        raise OmpFormatChanged('формат omp изменился: <task-result без пары')
    if MARK_TOKEN.search(tail):
        raise OmpFormatChanged('формат omp изменился: маркер %s вне task-result' % MARK)
    return parsed


def resolve_child(out):
    """Связь по НАШЕМУ маркеру: результат ребёнка — единственный task-result, чьё тело
    несёт M129; id omp не участвует (Child129, Child129-2 и zzz-9 судятся одинаково).
    Ноль находок — «нет результата с маркером», больше одной — «дубликат маркера»
    (не угадывать первый/последний)."""
    hits = [(st, body) for st, body in read_task_results(out) if MARK_TOKEN.search(body)]
    if not hits:
        return None, 'нет результата с маркером %s' % MARK
    if len(hits) > 1:
        return None, 'дубликат маркера %s (%d результата)' % (MARK, len(hits))
    return hits[0], None


def judge(w, c, rc, link_fn=None):
    out = open(os.path.join(w, 'out.txt'), errors='replace').read()
    reqs = [json.loads(l) for l in open(os.path.join(w, 'requests.jsonl')) if l.strip()]
    if rc == 124:
        return 'стенд вышел по таймауту (цикл смены моделей или зависание)'
    # the world must have happened as built: the sibling's agent turns met the planned failures
    for model, status in c['world'] or ():
        if not any(r['sib'] and r['turn'] and r['model'] == model and r['status'] == status for r in reqs):
            return 'мир не построен: у соседа нет хода %s со статусом %s' % (model, status)
    hit, why = (link_fn or resolve_child)(out)
    if why:
        return why
    want_child, want_model = c['expect']
    st, body = hit
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


# ── самопроверки наблюдателя (--parser), без omp ──
# Честные транскрипты: plain id (18.3.1), id с суффиксом (18.18.8) и чужой id дают ОДИН И
# ТОТ ЖЕ исход — идентификатор не участвует (механически: группы id-form/id-fail обязаны
# сходиться в один исход). Обманные транскрипты (чужой маркер, дубликат маркера, отсутствие
# маркера, нераспознанная форма события) дают именованный исход. Каждый красный случай
# комментарием И механически привязан к наивному наблюдателю, которого убивает: обманные
# стабы наблюдателя ниже прогоняются по клеткам и обязаны дать ИНОЙ исход (Н-39 — код).
PR_BODY = '\n<output>\n{\n  "marker": "%s",\n  "model": "fam-f"\n}\n</output>\n' % MARK
SIB_BODY = '\n<output>\n{\n  "marker": "%s",\n  "model": "fam-f"\n}\n</output>\n' % SIB_MARK
# умерший ребёнок: маркер доходит текстом ошибки stub-провайдера (живая форма c5, замер
# omp 18.18.8): [провайдер] 429 [1310][…][stub129 M129] …
ERR_M = ('\n<output>\n[stub-openai-codex/gpt-sol] 429 [1310][Weekly/Monthly Limit Exhausted.'
         ' Your limit will reset at 2099-01-01 00:00:00][stub129 %s] (type=rate_limit_error'
         ' param=1310) retry-after-ms=31561000\n</output>\n' % MARK)
ERR_SIB = ERR_M.replace(MARK, SIB_MARK)
OK_NO_MARK = '\n<output>\n{\n  "model": "fam-f"\n}\n</output>\n'


def _tr(tid, status, body=''):
    return '<task-result id="%s" agent="architect" status="%s" duration="1ms">%s</task-result>\n' % (tid, status, body)


# ── обманные стабы наблюдателя (Н-39) — наивные наблюдатели прошлых кругов ──
# В судье НЕ используются; сигнатура как у resolve_child. Каждый обязан быть ПОЙМАН:
# на привязанной клетке исход стаба обязан ОТЛИЧАТЬСЯ от требуемого исхода случая.
def _blocks(out):
    for m in TASK_RESULT_BLOCK.finditer(out):
        a = dict(TASK_RESULT_ATTR.findall(m.group('attrs')))
        yield a.get('id', ''), a.get('status', ''), m.group('body')


def stub_po_id(out):
    # ОБМАН «матчит по id»: результат ребёнка — тот, чей id omp равен имени задачи.
    hits = [(st, b) for tid, st, b in _blocks(out) if tid == CHILD]
    return (hits[0], None) if hits else (None, 'нет результата ребёнка %s' % CHILD)


def stub_po_prefiksu_id(out):
    # ОБМАН «матчит по префиксу id»: id, начинающийся с имени задачи (Child129-2 — да,
    # но и Child129x — тоже; наивный начало-матчер засчитывает чужого ребёнка).
    hits = [(st, b) for tid, st, b in _blocks(out) if tid.startswith(CHILD)]
    return (hits[0], None) if hits else (None, 'нет результата ребёнка %s' % CHILD)


def stub_molchit_na_formate(out):
    # ОБМАН «молчаливо игнорирует нераспознанный формат»: грамматика id прошлого круга
    # по разобравшимся блокам; нераспознанные вхождения и маркер вне блоков молча пропущены.
    own = re.compile(r'%s(?:-\d+)?$' % re.escape(CHILD))
    hits = [(st, b) for tid, st, b in _blocks(out) if own.fullmatch(tid)]
    return (hits[0], None) if hits else (None, 'нет результата ребёнка %s' % CHILD)


def _stub_krajnij(out, last):
    # ОБМАН «берёт первый/последний при дубликате»: при двух результатах с маркером
    # угадывает крайний вместо именованного «дубликат маркера».
    hits = [(st, b) for st, b in read_task_results(out) if MARK_TOKEN.search(b)]
    if not hits:
        return None, 'нет результата с маркером %s' % MARK
    return (hits[-1] if last else hits[0], None)


NAIVE_STUBS = [
    ('матчит по id', stub_po_id),
    ('матчит по префиксу id', stub_po_prefiksu_id),
    ('молчит на нераспознанном формате', stub_molchit_na_formate),
    ('берёт первый при дубликате', lambda out: _stub_krajnij(out, False)),
    ('берёт последний при дубликате', lambda out: _stub_krajnij(out, True)),
]


def parser_cases():
    ok = dict(expect=('completed', 'fam-f'), world=None)
    fail = dict(expect=('failed', None), world=None)
    no_mark = 'нет результата с маркером %s' % MARK
    dup = 'дубликат маркера %s (2 результата)' % MARK
    return [
        # идентификатор omp не участвует: старый формат (plain id), новый (суффикс) и
        # чужой id — один и тот же исход (группа id-form; убивает «матчит по id» на
        # суффиксе и чужом id: тот промахивается «нет результата ребёнка»)
        ('pr1-staryj-id', ok, _tr(CHILD, 'completed', PR_BODY), None, [], 'id-form'),
        ('pr2-novyj-id', ok, _tr(SIB, 'failed (exit 1)') + _tr(CHILD + '-2', 'completed', PR_BODY), None, ['матчит по id'], 'id-form'),
        ('pr3-chuzhoj-id', ok, _tr('zzz-9', 'completed', PR_BODY), None, ['матчит по id'], 'id-form'),
        # то же для отказа ребёнка (живая форма c5): маркер доходит текстом ошибки
        ('pr4-otkaz-staryj-id', fail, _tr(SIB, 'failed (exit 1)', ERR_SIB) + _tr(CHILD, 'failed (exit 1)', ERR_M), None, [], 'id-fail'),
        ('pr5-otkaz-novyj-id', fail, _tr(SIB, 'failed (exit 1)', ERR_SIB) + _tr(CHILD + '-2', 'failed (exit 1)', ERR_M), None, [], 'id-fail'),
        ('pr6-otkaz-chuzhoj-id', fail, _tr(SIB, 'failed (exit 1)', ERR_SIB) + _tr('zzz-9', 'failed (exit 1)', ERR_M), None, [], 'id-fail'),
        # обман «матчит по id»: id ровно Child129, но маркер ЧУЖОЙ (SIB129) — результат
        # не наш; id-матчер засчитывает его и даёт зелёное
        ('pr7-tochnyj-id-chuzhoj-marker', ok, _tr(CHILD, 'completed', SIB_BODY), no_mark, ['матчит по id'], None),
        # обман «матчит по префиксу id»: id начинается с Child129, но маркер чужой
        ('pr8-prefiks-id-chuzhoj-marker', ok, _tr(CHILD + 'x-2', 'completed', SIB_BODY), no_mark, ['матчит по префиксу id'], None),
        # обманы «матчит по id»/«по префиксу»: завершённый результат БЕЗ маркера — не наш
        ('pr9-net-markera', ok, _tr(CHILD, 'completed', OK_NO_MARK), no_mark, ['матчит по id', 'матчит по префиксу id'], None),
        # обманы «берёт первый/последний при дубликате»: два результата с маркером M129 —
        # с одинаковыми и с разными вердиктами; угадывание крайнего вместо именованного
        ('pr10-dublikat-markera', ok, _tr(CHILD, 'completed', PR_BODY) + _tr(CHILD + '-3', 'completed', PR_BODY),
         dup, ['берёт первый при дубликате', 'берёт последний при дубликате'], None),
        ('pr11-dublikat-razlichnye', ok, _tr(CHILD, 'failed (exit 1)', ERR_M) + _tr(CHILD + '-3', 'completed', PR_BODY),
         dup, ['берёт первый при дубликате', 'берёт последний при дубликате'], None),
        # обман «молчаливо игнорирует нераспознанный формат»: status переименован —
        # честный наблюдатель отказывается (rc 2), наивный судит по пустому статусу
        ('pr12-attr-pereimenovan', ok,
         '<task-result id="%s" agent="architect" outcome="completed" duration="1ms">%s</task-result>\n' % (CHILD, PR_BODY),
         ('rc2', 'формат omp изменился: status'), ['молчит на нераспознанном формате'], None),
        # …нет закрывающего тега — блок не разбирается, наивный молчит «нет результата»
        ('pr13-net-zakryvajushchego', ok, '<task-result id="%s" agent="architect" status="completed">%s' % (CHILD, PR_BODY),
         ('rc2', 'формат omp изменился: <task-result без пары'), ['молчит на нераспознанном формате'], None),
        # omp сменил форму события целиком (слово владельца: «завтра опять может
        # поменять»): наш маркер дошёл до родителя ВНЕ task-result — отказ rc 2,
        # а не ложное «нет результата»
        ('pr14-marker-vne-bloka', ok, '{"event":"task_result","marker":"%s","status":"completed"}\n' % MARK,
         ('rc2', 'формат omp изменился: маркер %s вне task-result' % MARK), ['молчит на нераспознанном формате'], None),
        # соседний ребёнок с ДРУГИМ маркером не засчитывается (транскрипт валиден)
        ('pr15-sosed-drugoj-marker', ok, _tr(SIB, 'completed', SIB_BODY), no_mark, [], None),
    ]


def _outcome(w, cell, link_fn=None):
    try:
        return judge(w, cell, 0, link_fn)
    except OmpFormatChanged as e:
        return ('rc2', str(e))


def run_parser_tests():
    red = caught = checks = 0
    cases = parser_cases()
    groups, bound = {}, set()
    for name, cell, out_text, want, kills, group in cases:
        w = tempfile.mkdtemp(prefix='p129-parser-')
        try:
            open(os.path.join(w, 'out.txt'), 'w').write('Working...\nPARENT_SAW:\n' + out_text)
            open(os.path.join(w, 'requests.jsonl'), 'w').write('')
            got = _outcome(w, cell)
            stub_got = {k: _outcome(w, cell, f) for k, f in NAIVE_STUBS if k in kills}
        finally:
            shutil.rmtree(w, ignore_errors=True)
        if got != want:
            red += 1
            print('FAIL %s: judge=%r, ожидалось %r' % (name, got, want))
        else:
            print('ok %s' % name)
        if group:
            groups.setdefault(group, set()).add(got)
        for k, g in stub_got.items():
            bound.add(k)
            checks += 1
            if g == want:
                red += 1
                print('НЕ ПОЙМАН «%s» на %s: стаб даёт тот же исход %r' % (k, name, want))
            else:
                caught += 1
    for k, _ in NAIVE_STUBS:
        if k not in bound:
            red += 1
            print('FAIL стаб «%s» не привязан ни к одной клетке' % k)
    for g, outs in sorted(groups.items()):
        if len(outs) != 1:
            red += 1
            print('FAIL группа %s: исход зависит от формата id: %s' % (g, sorted(map(repr, outs))))
    print('parser=%d red=%d stub_checks=%d caught=%d' % (len(cases), red, checks, caught))
    return 1 if red else 0


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
            try:
                why = judge(w, c, rc)
            except OmpFormatChanged as e:
                print('ФОРМАТ ИЗМЕНЁН %s: %s' % (cell, e))
                sys.exit(2)
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
        if a in ('--model', '--stabs', '--parser'):
            mode = a[2:]; i += 1; continue
        print('usage: battery.py [--subject DIR] [--cells a,b] [--ext FILE] [--model|--stabs|--parser]', file=sys.stderr)
        return 2
    if mode == 'parser':
        # the observer self-tests judge crafted transcripts: no omp, no subject files
        return run_parser_tests()
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
