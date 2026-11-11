#!/usr/bin/env python3
"""Батарея 190 «Л6 — замер связки»: клетки по инвариантам контракта, оракул в данных.

Правило 8: ожидания снимаются в память из dannye/ ДО вызова субъекта; диск
проверяемого как истина не перечитывается. Миры конформны документированной
грамматике контракта (демаркация: валидный контрпример = инвариантность к
значениям ∧ расхождение на конформном входе). Стабы — мутации чтения кодом,
привязки только в source.json (Н-39).

Режимы:
  (без флага) — суд настоящего scripts/zamer_svyazki.sh дерева TOOLS (до
                реализации каждая клетка красна SUBJECT_ABSENT)
  --repo R     — суд живого дерева R
  --model      — эталон model/zamer_model.py (контроль честности миров)
  --stabs      — эталон + матрица обманных стабов (СВЯЗИ)
  --oracle-tamper — сверка sha256 носителей оракула (rc 2 ORACLE_TAMPERED)
"""
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
TOOLS = HERE.parents[2]
DANNYE = HERE / 'dannye'
MODEL = HERE / 'model' / 'zamer_model.py'
STABS_DIR = HERE / 'stabs'


def sha40(n):
    return hashlib.sha256(b'190-world-%d' % n).hexdigest()[:40]


def sud(subject, n, sha):
    return ('СУД: repo=dev-harness; предмет=%s; фаза=контракт; роль=critic; вызов=%d/2; '
            'модель-план=zai/glm-5.3; сессия=Crit%s; модель-факт=zai/glm-5.3; SHA=%s; '
            'предыдущий=нет; исключение=нет' % (subject, n, subject, sha))


VERDICT_301_KRUG1 = """FAIL
OBJECT=%(sha)s
%(sud)s

## Блокирующие находки

БЛОКИРУЕТ contracts/301-x.md:12 — клетка не различает честную и обманную ветвь.
ОБЯЗАТЕЛЬСТВО: обязательство предмета обязано иметь различающую клетку.
ПРОИСХОЖДЕНИЕ: первичный
КЛАСС: К-08

БЛОКИРУЕТ contracts/301-x.md:20 — самописный разбор таблицы вместо канона.
ПРОИСХОЖДЕНИЕ: первичный
КЛАСС: К-12
"""

VERDICT_301_ACCEPT = "accept\nOBJECT=%(sha)s\n%(sud)s\n"
VERDICT_302_KRUG1 = """FAIL
OBJECT=%(sha)s
%(sud)s

## Блокирующие находки

БЛОКИРУЕТ contracts/302-x.md:7 — молча отменяет чужое frozen-обязательство.
ПРОИСХОЖДЕНИЕ: первичный
КЛАСС: К-03
"""
VERDICT_302_KRUG2 = """FAIL
OBJECT=%(sha)s
%(sud)s

## Блокирующие находки

БЛОКИРУЕТ contracts/302-x.md:15 — словарь в тексте расходится со словарём проверки.
ПРОИСХОЖДЕНИЕ: дельта
КЛАСС: К-12
"""
VERDICT_302_ACCEPT = "accept\nOBJECT=%(sha)s\n%(sud)s\n"
VERDICT_303_BEZ_SUDA = """FAIL

# Вердикт критика — контракт 303, вызов 1

## Блокирующие находки

БЛОКИРУЕТ contracts/303-x.md:5 — нет rc-команды приёмки.
"""
VERDICT_303_SUD = VERDICT_303_BEZ_SUDA.replace(
    '# Вердикт критика — контракт 303, вызов 1\n',
    '# Вердикт критика — контракт 303, вызов 1\n\n' + sud('303', 1, sha40(33)) + '\n')
VERDICT_304_BEZ_METOK = """FAIL
OBJECT=%(sha)s
%(sud)s

## Блокирующие находки

БЛОКИРУЕТ contracts/304-x.md:9 — старый вердикт без строк происхождения и класса.
"""

SUD_302_OBRYV = ('СУД: repo=dev-harness; предмет=302; фаза=контракт; роль=critic; вызов=2/2; '
                 'модель-план=zai/glm-5.3; сессия=Crit302b; модель-факт=нет: сессия упала '
                 '"Retry budget exhausted", вердикта нет; SHA=%s; '
                 'предыдущий=verdicts/critic/contracts-302-v1-krug1-fail.md; '
                 'исключение=обрыв без вердикта' % sha40(32))
SUD_301_REVIEWER = ('СУД: repo=dev-harness; предмет=301; фаза=реализация; роль=reviewer; '
                    'вызов=1/1; модель-план=anthropic/claude-opus-5-5; сессия=Rev301a; '
                    'SHA=%s; предыдущий=нет; исключение=нет' % sha40(34))
SUD_999 = ('СУД: repo=dev-harness; предмет=999; фаза=контракт; роль=critic; вызов=1/2; '
           'модель-план=zai/glm-5.3; сессия=Crit999; SHA=%s; предыдущий=нет; '
           'исключение=нет' % sha40(35))


def journal_text(calls):
    """Журнал агента из [(токены, число_инструментов, правка)] — настоящий JSONL-формат."""
    lines = ['{"type": "session", "version": 3, "id": "sess-190", "cwd": "/w"}']
    for i, (tok, ntools, edit) in enumerate(calls):
        tools = []
        if edit:
            tools.append({'type': 'toolCall', 'id': 'e%d' % i, 'name': 'edit', 'arguments': {}})
        for j in range(ntools):
            tools.append({'type': 'toolCall', 'id': 'r%d_%d' % (i, j), 'name': 'read',
                          'arguments': {'path': '/x'}})
        out_tok = 100
        msg = {'role': 'assistant', 'content': tools, 'usage': {
            'input': tok - out_tok, 'output': out_tok, 'cacheRead': 0, 'cacheWrite': 0,
            'totalTokens': tok}}
        lines.append(json.dumps({'type': 'message', 'id': 'm%d' % i,
                                 'timestamp': '2026-11-10T01:%02d:00.000Z' % i,
                                 'message': msg}, ensure_ascii=False))
    return '\n'.join(lines) + '\n'
AGENTS_SESS1 = {
    'Architect301a': [(1000, 1, False), (1500, 1, True), (2000, 2, False), (500, 1, True), (3000, 1, False)],
    'Crit301a': [(500, 1, False), (500, 2, False)],
    'Reviewer301a': [(9999, 2, False)],
}
AGENTS_SESS2 = {
    'Architect302a': [(1000, 1, False), (1000, 1, True), (1000, 1, False)],
    'Crit302a': [(600, 1, False), (600, 1, False)],
    'Steward302': [(7777, 1, False)],
    'ArchitectFixer': [(200, 1, False)],
}
AGENTS_SESS1_G = {
    'Architect301a': [(1000, 2, False), (1000, 2, False)],
    'Crit301a': [(500, 1, False), (500, 2, False)],
    'Reviewer301a': [(9999, 2, False)],
}
SESSIONS = [
    ('2026-11-10T01-00-00-111Z_aa11', AGENTS_SESS1),
    ('2026-11-10T02-00-00-222Z_bb22', AGENTS_SESS2),
]


_WORLDS = {}


def write_world(base, variant):
    """Мир строится один раз на прогон; повторные клетки читают тот же каталог."""
    cache_key = (str(base), variant)
    if cache_key not in _WORLDS:
        _WORLDS[cache_key] = _build_world(base, variant)
    return _WORLDS[cache_key]


def _build_world(base, variant):
    repo = base / ('mir-' + variant)
    zh = base / ('mir-' + variant) / 'zhurnaly'
    (repo / 'verdicts' / 'critic').mkdir(parents=True)
    (repo / 'registry').mkdir(parents=True)
    reg = ['301 → %s' % sha40(1), '302 → %s' % sha40(2), '303 → %s' % sha40(3)]
    if variant == 'E':
        reg.append('304 → %s' % sha40(4))
    (repo / 'registry' / 'contracts.tsv').write_text('\n'.join(reg) + '\n')
    v = repo / 'verdicts' / 'critic'

    def w(name, tmpl, sha):
        (v / name).write_text(tmpl % {'sha': sha, 'sud': sud(name.split('-')[1], n_of(name), sha)})

    def n_of(name):
        return {'contracts-301-v1-krug1-fail.md': 1, 'contracts-301-v1.md': 2,
                'contracts-302-v1-krug1-fail.md': 1, 'contracts-302-v1-krug2-fail.md': 3,
                'contracts-302-v1.md': 4, 'contracts-302-v1-krug3.md': 4,
                'contracts-303-v1-krug1-fail.md': 1,
                'contracts-304-v1-krug1-fail.md': 1}[name]

    w('contracts-301-v1-krug1-fail.md', VERDICT_301_KRUG1, sha40(11))
    w('contracts-301-v1.md', VERDICT_301_ACCEPT, sha40(12))
    w('contracts-302-v1-krug1-fail.md', VERDICT_302_KRUG1, sha40(21))
    w('contracts-302-v1-krug2-fail.md', VERDICT_302_KRUG2, sha40(22))
    w('contracts-302-v1.md', VERDICT_302_ACCEPT, sha40(23))
    w('contracts-302-v1-krug3.md', VERDICT_302_ACCEPT, sha40(23))
    if variant == 'C':
        (v / 'contracts-303-v1-krug1-fail.md').write_text(VERDICT_303_SUD)
    else:
        (v / 'contracts-303-bez-suda.md').write_text(VERDICT_303_BEZ_SUDA)
    if variant == 'E':
        w('contracts-304-v1-krug1-fail.md', VERDICT_304_BEZ_METOK, sha40(41))
    handoff = ['# ГДЕ МЫ', '']
    if variant != 'B':
        handoff.append(SUD_302_OBRYV)
    handoff += [SUD_301_REVIEWER, SUD_999]
    (repo / 'HANDOFF.md').write_text('\n'.join(handoff) + '\n')
    sessions = list(SESSIONS)
    if variant == 'G':
        sessions[0] = (sessions[0][0], AGENTS_SESS1_G)
    for dirname, agents in sessions:
        d = zh / 'cwd-190' / dirname
        d.mkdir(parents=True)
        for name, calls in agents.items():
            if variant == 'F' and name == 'Architect302a':
                continue
            (d / (name + '.jsonl')).write_text(journal_text(calls))
    return repo, zh


def run_tool(cmd, repo, zh, extra=()):
    argv = [str(c) for c in cmd] + ['--repo', str(repo), '--zhurnaly', str(zh)] + list(extra)
    env = {**os.environ, 'PYTHONDONTWRITEBYTECODE': '1'}
    return subprocess.run(argv, capture_output=True, text=True, timeout=120, env=env)


def parse_table(text):
    rows = {}
    for line in text.splitlines():
        parts = line.split('\t')
        if parts[0] in ('предмет',):
            continue
        rows[parts[0]] = parts
    return rows


def load_oracle():
    """Правило 8: весь оракул — в память ДО первого вызова субъекта."""
    tables = {}
    for line in (DANNYE / 'orakul-tablicy.tsv').read_text().splitlines():
        if not line or line.startswith('#'):
            continue
        world, rest = line.split('\t', 1)
        tables.setdefault(world, []).append(rest.split('\t'))
    rc_exp = []
    for line in (DANNYE / 'orakul-rc.tsv').read_text().splitlines():
        if not line or line.startswith('#'):
            continue
        rc_exp.append(line.split('\t'))
    return tables, rc_exp


def check_pins():
    src = json.loads((HERE / 'source.json').read_text())
    bad = []
    for rel, pin in src['piny'].items():
        p = HERE / rel
        if not p.is_file() or hashlib.sha256(p.read_bytes()).hexdigest() != pin:
            bad.append(rel)
    return src, bad


def cell_cases():
    """(клетка, мир, extra-аргументы, вид сверки, ключ ожидания в оракуле)."""
    return [
        ('mir-a-tablica', 'A', (), 'table', 'A'),
        ('obryv-schitaetsja', 'A', (), 'cells', 'A'),
        ('mir-b-bez-obryva', 'B', (), 'cells', 'B'),
        ('verdikt-bez-suda', 'A', (), 'cells', 'A-NEU'),
        ('verdikt-s-sudoj', 'C', (), 'cells', 'C'),
        ('dubl-materializacii', 'A', (), 'cells', 'A'),
        ('bloki-metki', 'E', (), 'cells', 'E'),
        ('tokeny-rolevye', 'A', (), 'cells', 'A'),
        ('tokeny-bez-agenta', 'F', (), 'cells', 'F'),
        ('odinochnye-hvost', 'A', (), 'cells', 'A'),
        ('odinochnye-nulevye', 'G', (), 'cells', 'G'),
        ('okno-seansov', 'A', ('--s', '2026-11-10T01:30:00Z'), 'cells', 'A-OKNO'),
        ('pustaja-vyborka', 'A', ('--s', '2026-11-11T00:00:00Z'), 'rc', ('A', 'pustaja-vyborka', '1', 'ПУСТАЯ_ВЫБОРКА')),
        ('chistyj-klon', 'A', (), 'rc', ('A', 'chistyj-klon', '2', 'НЕТ_ЖУРНАЛОВ')),
        ('dokument-kanon', 'A', (), 'kanon', 'A'),
    ]


def run_cell(cmd, base, variant, extra, kind, expect, tables, doc_root):
    repo, zh = write_world(base, variant)
    if kind in ('table', 'cells'):
        exp_rows = tables.get(expect, [])
        if not exp_rows:
            return False, 'нет ожидания %s в оракуле' % expect
        res = run_tool(cmd, repo, zh, extra)
        if res.returncode != 0:
            return False, 'rc=%d stderr=%r' % (res.returncode, res.stderr[-160:])
        got = parse_table(res.stdout)
        bad = [e[0] for e in exp_rows if got.get(e[0]) != e]
        if bad:
            return False, 'строки %s расходятся: got %r exp %r' % (
                ','.join(bad), [got.get(b) for b in bad],
                [e for e in exp_rows if e[0] in bad])
        return True, ''
    if kind == 'rc':
        _v, _c, code, name = expect
        if name == 'НЕТ_ЖУРНАЛОВ':
            res = run_tool(cmd, repo, base / 'netu-zhurnalov', ())
        else:
            res = run_tool(cmd, repo, zh, extra)
        ok = res.returncode == int(code) and name in (res.stderr + res.stdout)
        return (ok, '' if ok else
                'rc=%d out=%r' % (res.returncode, (res.stderr + res.stdout)[:160]))
    if kind == 'kanon':
        res = run_tool(cmd, repo, zh, extra)
        header = res.stdout.splitlines()[0] if (res.returncode == 0 and res.stdout) else None
        doc = doc_root / 'docs' / '190-zamer-svyazki.md'
        if not doc.is_file():
            return False, 'документ канона отсутствует: %s' % doc
        if header is None or header not in doc.read_text().splitlines():
            return False, 'заголовок таблицы не совпадает с документом канона'
        return True, ''
    return False, 'неизвестный вид клетки'


def main():
    mode = None
    repo_arg = None
    if '--model' in sys.argv:
        mode = 'model'
    elif '--stabs' in sys.argv:
        mode = 'stabs'
    elif '--repo' in sys.argv:
        mode = 'repo'
        repo_arg = Path(sys.argv[sys.argv.index('--repo') + 1]).resolve()
    src, bad = check_pins()
    if bad:
        print('ORACLE_TAMPERED: носители изменены: %s' % ', '.join(bad))
        return 2
    if '--oracle-tamper' in sys.argv:
        print('ORACLE_OK')
        return 0
    tables, rc_exp = load_oracle()
    if mode in ('model', 'stabs'):
        cmd = [sys.executable, str(MODEL)]
        doc_root = HERE / 'model'
    else:
        tools = repo_arg if repo_arg else TOOLS
        subj = tools / 'scripts' / 'zamer_svyazki.sh'
        subj_py = tools / 'scripts' / 'zamer_svyazki.py'
        if not subj.is_file() and not subj_py.is_file():
            print('SUBJECT_ABSENT: scripts/zamer_svyazki.* не реализован — все клетки красны')
            cases = cell_cases()
            for cell, _v, _e, _k, _o in cases:
                print('RED %s: SUBJECT_ABSENT' % cell)
            print('ИТОГ 190: клеток %d, зелёных 0, красных %d' % (len(cases), len(cases)))
            return 1
        cmd = ['bash', str(subj)] if subj.is_file() else [sys.executable, str(subj_py)]
        doc_root = tools
    failures = []
    stab_total = stab_caught = 0
    cases = cell_cases()
    with tempfile.TemporaryDirectory(prefix='zamer190-') as tmp:
        base = Path(tmp)
        for cell, variant, extra, kind, expect in cases:
            ok, why = run_cell(cmd, base, variant, extra, kind, expect, tables, doc_root)
            print('%s %s%s' % ('GREEN' if ok else 'RED', cell, (': ' + why) if why else ''))
            if not ok:
                failures.append(cell)
        if mode == 'stabs':
            for stab_name, binding in sorted(src['stab_vhod'].items()):
                bound = [c for c in cases if c[0] == binding]
                caught = False
                for cell, variant, extra, kind, expect in bound:
                    ok, _why = run_cell([sys.executable, str(STABS_DIR / stab_name)], base,
                                        variant, extra, kind, expect, tables, HERE / 'model')
                    if not ok:
                        caught = True
                stab_total += 1
                if caught:
                    stab_caught += 1
                    print('STAB %s caught @ %s' % (stab_name, binding))
                else:
                    print('STAB %s ZHIV @ %s' % (stab_name, binding))
                    failures.append(stab_name)
    red_cells = len([f for f in failures if not f.startswith('stab_')])
    print('ИТОГ 190: клеток %d, зелёных %d, красных %d; СВЯЗИ %d, поймано %d, жив %d' % (
        len(cases), len(cases) - red_cells, red_cells,
        stab_total, stab_caught, stab_total - stab_caught))
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
