#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 208 (§ПРОВОДКА): судит дверь замка предмета
# scripts/zamok_predmeta.sh — допуск судьи по ПРЕДКОВОСТИ с кандидатом
# последнего рабочего START при опубликованности OBJECT (D9a/D9b/D9c)
# и повтор роли по записанной в учёте санкции SANKCIJA (D11b).
# Эталон — model/zamok_predmeta.sh: дверь A2 (378e45782e, v8…v13) + блоки
# 208; реализация несёт ту же семантику.
# Привязки стаб↔клетка — ТОЛЬКО source.json:.stab_vhod (Н-39: проза
# контракта пар не утверждает; якорь стаба — кратность 1 в тексте модели).
# Оракул — source.json в памяти ДО вызова субъекта (правило 8); носители —
# sha256; рассинхрон множеств — rc 2 ORACLE_TAMPERED.
#
# Каждая клетка сравнивает rc, stdout И stderr ПОЛНОСТЬЮ байт-в-байт
# (К-10 Crit208V1): ожидания фиксируются в памяти ДО вызова субъекта —
# и для модели, и для стабов, и для производственного слоя одинаково.
#
# Режимы:
#   (без флага) / --repo <корень>
#         субъект = <корень>/scripts/zamok_predmeta.sh (корень по умолчанию —
#         toplevel репозитория батареи; база работы — A2). До реализации
#         клетки нового допуска красны (перечень поимённо), итог rc 1; нет
#         субъекта — rc 1 SUBJECT_ABSENT с перечнем всех входов.
#   --model   контроль входов на эталоне (23/23), строгие ожидания вывода.
#   --stabs   контроль + матрица обманных стабов над текстом модели
#         (SVJAZI 24, живых 0); якорь потерян или синтаксис сломан — rc 2.
#   --sgeneriruj-staby (обслуживание) материализует stabs/<имя>/ и
#         source.json (nositeli).
#
# Миры — в mktemp под $TMPDIR; omp не нужен; сети нет; git/jq/bash обязательны.
# Коды возврата: 0 — зелено; 1 — красная клетка либо STAB_ZHIV либо субъекта
# нет; 2 — нечем проверять (нет git/jq, ORACLE_TAMPERED, дрейф стабов/модели).
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
MODEL = HERE / 'model' / 'zamok_predmeta.sh'
STABS = HERE / 'stabs'
SOURCE = HERE / 'source.json'

REPO_ID = 'dev-harness'
HARNESS_REMOTE = 'ssh://git@github.com/a3ka/dev-harness.git'
SUBJ = '208'
RISK_FILE = '208-fixture.md'
DUMMY = '1234567890123456789012345678901234567890'
PUSCHEM = 'PUSCHEM Crit208 %s/%s (sudja/critic)\n' % (REPO_ID, SUBJ)

GIT_ENV = dict(os.environ)
GIT_ENV.update({
    'GIT_CONFIG_GLOBAL': '/dev/null',
    'GIT_CONFIG_SYSTEM': '/dev/null',
    'GIT_CONFIG_NOSYSTEM': '1',
    'LC_ALL': 'C',
})


def sha256_bytes(b):
    return hashlib.sha256(b).hexdigest()


def run(cmd, cwd=None, env=None, timeout=120):
    return subprocess.run(cmd, capture_output=True, text=True, cwd=cwd,
                          env=env if env is not None else GIT_ENV,
                          timeout=timeout)


# ── мир: состояние + журналы + реестр станции ───────────────────────────────
class Mir:
    def __init__(self, root):
        self.root = Path(root)
        self.sost = self.root / 'sost'
        self.zhurnaly = self.root / 'zhurnaly' / 'parent1'
        self.repo = self.root / 'repo'
        self.ledger = self.sost / 'uchet.jsonl'
        for d in (self.sost, self.zhurnaly, self.repo / 'contracts',
                  self.repo / 'registry'):
            d.mkdir(parents=True, exist_ok=True)
        self.ledger.touch()
        g = run(['git', 'init', '-q', '.'], cwd=str(self.repo))
        assert g.returncode == 0, g.stderr
        self.git(['remote', 'add', 'origin', HARNESS_REMOTE])
        self.git(['commit', '-q', '--allow-empty', '-m', 'init'])

    def git(self, args):
        return run(['git', '-c', 'user.name=battery', '-c',
                    'user.email=b@t', '-c', 'commit.gpgsign=false'] + args,
                   cwd=str(self.repo))

    def pauza(self, nnn):
        f = self.repo / 'registry' / 'pauzy.tsv'
        with f.open('a', encoding='utf-8') as fh:
            fh.write('%s\t2026-11-22\tвладелец\tпозже\n' % nnn)
        self.git(['add', '-A'])
        self.git(['commit', '-q', '-m', 'p%s' % nnn])

    def worktree(self, nnn, kontrakty=None):
        wt = self.root / ('wt%s' % nnn)
        wt.mkdir(parents=True, exist_ok=True)
        g = run(['git', 'init', '-q', '.'], cwd=str(wt))
        assert g.returncode == 0, g.stderr
        run(['git', 'remote', 'add', 'origin', HARNESS_REMOTE], cwd=str(wt))
        br = 'wip/%s/avtor' % nnn
        run(['git', 'checkout', '-q', '-b', br], cwd=str(wt))
        kat = wt / 'contracts'
        kat.mkdir(exist_ok=True)
        for vid, imja, dannye in (kontrakty or []):
            (kat / imja).write_text(dannye, encoding='utf-8')
        run(['git', 'add', '-A'], cwd=str(wt))
        run(['git', '-c', 'user.name=b', '-c', 'user.email=b@t',
             'commit', '-q', '-m', 'k'], cwd=str(wt))
        sha = run(['git', 'rev-parse', 'HEAD'], cwd=str(wt)).stdout.strip()
        self.pin_frozen(nnn, wt, sha)
        return str(wt), br, sha

    def pin_frozen(self, nnn, wt, commit):
        # фиксируем только мир: frozen-тег владельца + строка реестра станции
        r = self.git(['fetch', '-q', str(wt), commit])
        assert r.returncode == 0, r.stderr
        tag = 'frozen/contracts/%s/1' % nnn
        r = self.git(['tag', '-a', tag, '-m', 'fixture frozen', commit])
        assert r.returncode == 0, r.stderr
        obj = self.git(['rev-parse', tag]).stdout.strip()
        registry = self.repo / 'registry/contracts.tsv'
        rows = registry.read_text().splitlines() if registry.exists() else []
        rows = [row for row in rows if not row.startswith(nnn + ' → ')]
        registry.write_text('\n'.join(rows + [nnn + ' → ' + obj]) + '\n')
        self.git(['add', 'registry/contracts.tsv'])
        r = self.git(['commit', '-q', '-m', 'pin frozen ' + nnn])
        assert r.returncode == 0, r.stderr

    def publikuj(self, wt, ref, sha):
        # публикация в origin-view НОСИТЕЛЯ (r_wt): refs/remotes/origin/…
        r = run(['git', 'update-ref', ref, sha], cwd=str(wt))
        assert r.returncode == 0, r.stderr

    def zhurnal(self, holder, sdal=False):
        f = self.zhurnaly / ('%s.jsonl' % holder)
        body = ('{"timestamp":"2026-11-22T10:00:00.000Z",'
                '"message":{"role":"assistant"}}\n')
        if sdal:
            body += ('{"type":"toolResult","toolCallId":"toolu_x",'
                     '"toolName":"yield",'
                     '"content":[{"type":"text","text":"Result submitted."}]}\n')
        f.write_text(body, encoding='utf-8')

    def start(self, nnn, holder, klass='rabochij', rol='architect',
              wt='-', branch='-', obj='-', zanyat=True):
        line = {'t': 'START', 'repoId': REPO_ID, 'subjectId': nnn,
                'group': 'harness', 'holder': holder, 'klass': klass,
                'rol': rol, 'object': obj, 'worktree': wt, 'branch': branch,
                'at': '2026-11-22T10:00:00Z'}
        with self.ledger.open('a', encoding='utf-8') as fh:
            fh.write(json.dumps(line, ensure_ascii=False) + '\n')
        if zanyat:
            zd = self.sost / 'zamki' / REPO_ID / nnn / 'zanyat'
            zd.mkdir(parents=True, exist_ok=True)
            (zd / 'holder.json').write_text(
                json.dumps({'holder': holder, 'klass': klass, 'rol': rol,
                            'object': obj,
                            'startedAt': '2026-11-22T10:00:00Z'}) + '\n',
                encoding='utf-8')

    def release(self, nnn, holder, prichina='verdikt_zakommiten'):
        with self.ledger.open('a', encoding='utf-8') as fh:
            fh.write(json.dumps({'t': 'RELEASE', 'repoId': REPO_ID,
                                 'subjectId': nnn, 'holder': holder,
                                 'prichina': prichina,
                                 'at': '2026-11-22T10:00:00Z'}) + '\n')

    def sankcija(self, nnn, rol, obj, subject=None, repo=None):
        # К-08: санкция с ЧУЖИМ адресом — ровно одно поле отличается
        with self.ledger.open('a', encoding='utf-8') as fh:
            fh.write(json.dumps({'t': 'SANKCIJA', 'repoId': repo or REPO_ID,
                                 'subjectId': subject or nnn, 'rol': rol,
                                 'object': obj,
                                 'at': '2026-11-22T10:00:00Z'},
                                ensure_ascii=False) + '\n')

    def sobytie(self, path, items):
        p = self.root / path
        p.write_text(json.dumps({'tasks': items}, ensure_ascii=False),
                     encoding='utf-8')
        return str(p)

    def ledg(self):
        rows = []
        for ln in self.ledger.read_text(encoding='utf-8').splitlines():
            if ln.strip():
                rows.append(json.loads(ln))
        return rows


def wt_git(wt, *args, role='b'):
    return run(['git', '-c', 'user.name=' + role, '-c',
                'user.email=' + role + '@t', '-c', 'commit.gpgsign=false']
               + list(args), cwd=str(wt))


def item(agent, name, stroki):
    return {'agent': agent, 'name': name, 'task': '\n'.join(stroki)}


def sudit(door, mir, event):
    return run(['bash', str(door), '--sudit', '--sostojanie', str(mir.sost),
                '--zhurnaly', str(mir.zhurnaly), '--repo', str(mir.repo),
                str(event)])


def vpered(wt, imja, soderzimoe, role='b', soobshenie='w'):
    # коммит «вперёд» в носителе; возвращает sha
    p = Path(wt) / imja
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(soderzimoe, encoding='utf-8')
    wt_git(wt, 'add', '-A')
    wt_git(wt, 'commit', '-q', '-m', soobshenie, role=role)
    return wt_git(wt, 'rev-parse', 'HEAD').stdout.strip()


def vernut_vetku(wt, br, sha):
    # ветка носителя снова указывает на sha (коммиты «вперёд» остаются в
    # объектном хранилище носителя), рабочее дерево — detached на sha
    wt_git(wt, 'checkout', '-q', '--detach', sha)
    wt_git(wt, 'branch', '-f', br, sha)


# ── проверки: каждая возвращает None (ок) либо строку-причину ───────────────
def k_rc(r, want, chto):
    if r.returncode != want:
        return '%s: rc %s ≠ %s (stderr: %s)' % (chto, r.returncode, want,
                                                (r.stderr or '').strip()[:200])
    return None


def k_text(r, ozhidaemyj, chto):
    if (r.stderr or '') != ozhidaemyj:
        return '%s: stderr байт-в-байт ≠ ожиданию: %r ≠ %r' % (
            chto, r.stderr, ozhidaemyj)
    return None


def k_stdout(r, ozhidaemyj, chto):
    if (r.stdout or '') != ozhidaemyj:
        return '%s: stdout байт-в-байт ≠ ожиданию: %r ≠ %r' % (
            chto, r.stdout, ozhidaemyj)
    return None


def k_start(mir, holder, obj, chto):
    rows = mir.ledg()
    posl = rows[-1] if rows else {}
    if posl.get('t') != 'START' or posl.get('holder') != holder \
            or posl.get('object') != obj:
        return '%s: последняя строка учёта не START %s/%s: %r' % (
            chto, holder, obj, posl)
    return None


def k_uchet_ne_izmenen(mir, do, chto):
    if mir.ledger.read_bytes() != do:
        return '%s: отказ переписал учёт' % chto
    return None


# ── клетки ───────────────────────────────────────────────────────────────────
def kejsy():
    K = {}

    def reg(imja, os, fn):
        assert imja not in K
        K[imja] = (os, fn)

    def bazir(m):
        wt, br, sha = m.worktree(SUBJ, kontrakty=[
            ('fajl', RISK_FILE, '# К\nКЛАСС РИСКА: обычный\n')])
        m.start(SUBJ, 'Arch208', wt=wt, branch=br)
        m.zhurnal('Arch208', sdal=True)
        return wt, br, sha

    def vyzov(m, obj, dop_stroki=()):
        ev = m.sobytie('e.json', [item('critic', 'Crit208',
                                       ['SUBJECT=' + SUBJ,
                                        'OBJECT=' + obj]
                                       + list(dop_stroki))])
        return ev

    def r01(m, door):
        wt, br, K0 = bazir(m)
        ev = vyzov(m, K0)
        r = sudit(door, m, ev)
        return [k_rc(r, 0, 'r01'), k_stdout(r, PUSCHEM, 'r01'),
                k_text(r, '', 'r01'), k_start(m, 'Crit208', K0, 'r01')]

    def r02(m, door):
        wt, br, K0 = bazir(m)
        K2 = vpered(wt, 'rabota.txt', 'novaja rabota\n')
        m.publikuj(wt, 'refs/remotes/origin/main', K0)
        ev = vyzov(m, K0)
        r = sudit(door, m, ev)
        return [k_rc(r, 0, 'r02'), k_stdout(r, PUSCHEM, 'r02'),
                k_text(r, '', 'r02'), k_start(m, 'Crit208', K0, 'r02')]

    def r03(m, door):
        wt, br, K0 = bazir(m)
        K2 = vpered(wt, 'rabota.txt', 'novaja rabota\n')
        m.publikuj(wt, 'refs/remotes/origin/wip/%s/reaccept' % SUBJ, K2)
        ev = vyzov(m, K0)
        r = sudit(door, m, ev)
        return [k_rc(r, 0, 'r03'), k_stdout(r, PUSCHEM, 'r03'),
                k_text(r, '', 'r03'), k_start(m, 'Crit208', K0, 'r03')]

    def r04(m, door):
        wt, br, K0 = bazir(m)
        K2 = vpered(wt, 'rabota.txt', 'novaja rabota\n')
        do = m.ledger.read_bytes()
        ev = vyzov(m, K0)
        r = sudit(door, m, ev)
        ozh = ('ОТКАЗ: OBJECT_RASHODITSJA: предмет %s: OBJECT %s — предок '
               'кандидата %s, но не опубликован (refs/remotes/origin/main и '
               'refs/remotes/origin/wip/%s/* его не содержат); выход: fetch '
               'origin в носителе либо опубликовать работу\n'
               % (SUBJ, K0, K2, SUBJ))
        return [k_rc(r, 1, 'r04'), k_stdout(r, '', 'r04'),
                k_text(r, ozh, 'r04'), k_uchet_ne_izmenen(m, do, 'r04')]

    def r05(m, door):
        wt, br, K0 = bazir(m)
        Kf = vpered(wt, 'ispravlenie.txt', 'kontract fix\n',
                    soobshenie='fix')
        vernut_vetku(wt, br, K0)
        m.publikuj(wt, 'refs/remotes/origin/main', Kf)
        ev = vyzov(m, Kf)
        r = sudit(door, m, ev)
        return [k_rc(r, 0, 'r05'), k_stdout(r, PUSCHEM, 'r05'),
                k_text(r, '', 'r05'), k_start(m, 'Crit208', Kf, 'r05')]

    def r06(m, door):
        wt, br, K0 = bazir(m)
        verdikt = ('accept\nOBJECT=%s\n\n# proverka\n' % K0)
        V = vpered(wt, 'verdicts/critic/contracts-%s-v1.md' % SUBJ, verdikt,
                   role='critic', soobshenie='verdikt')
        vernut_vetku(wt, br, K0)
        do = m.ledger.read_bytes()
        ev = vyzov(m, V)
        r = sudit(door, m, ev)
        ozh = ('ОТКАЗ: OBJECT_RASHODITSJA: предмет %s: OBJECT %s впереди '
               'кандидата %s, но не кодовая граница — вердиктный хвост не '
               'становится объектом суда; выход: OBJECT работы, не '
               'verdikt-коммит\n' % (SUBJ, V, K0))
        return [k_rc(r, 1, 'r06'), k_stdout(r, '', 'r06'),
                k_text(r, ozh, 'r06'), k_uchet_ne_izmenen(m, do, 'r06')]

    def r07(m, door):
        wt, br, K0 = bazir(m)
        Kf = vpered(wt, 'ispravlenie.txt', 'kontract fix\n',
                    soobshenie='fix')
        vernut_vetku(wt, br, K0)
        do = m.ledger.read_bytes()
        ev = vyzov(m, Kf)
        r = sudit(door, m, ev)
        ozh = ('ОТКАЗ: OBJECT_RASHODITSJA: предмет %s: OBJECT %s впереди '
               'кандидата %s (кодовая граница), но не опубликован '
               '(refs/remotes/origin/main и refs/remotes/origin/wip/%s/* его '
               'не содержат); выход: опубликовать работу в main либо ветке '
               'wip/%s/* на origin\n' % (SUBJ, Kf, K0, SUBJ, SUBJ))
        return [k_rc(r, 1, 'r07'), k_stdout(r, '', 'r07'),
                k_text(r, ozh, 'r07'), k_uchet_ne_izmenen(m, do, 'r07')]

    def r08(m, door):
        wt, br, K0 = bazir(m)
        wt_git(wt, 'checkout', '-q', '-b', 'side')
        vpered(wt, 'f.txt', 'odinakovo\n', soobshenie='s')
        wt_git(wt, 'checkout', '-q', br)
        vpered(wt, 'f.txt', 'odinakovo\n', soobshenie='a')
        wt_git(wt, 'merge', '-q', '--no-ff', 'side', '-m', 'm')
        M = wt_git(wt, 'rev-parse', 'HEAD').stdout.strip()
        m.publikuj(wt, 'refs/remotes/origin/main', M)
        ev = vyzov(m, M)
        r = sudit(door, m, ev)
        return [k_rc(r, 0, 'r08'), k_stdout(r, PUSCHEM, 'r08'),
                k_text(r, '', 'r08'), k_start(m, 'Crit208', M, 'r08')]

    def r09(m, door):
        wt, br, K0 = bazir(m)
        wt_git(wt, 'commit', '-q', '--allow-empty', '-m', 'pustoj')
        E = wt_git(wt, 'rev-parse', 'HEAD').stdout.strip()
        do = m.ledger.read_bytes()
        ev = vyzov(m, E)
        r = sudit(door, m, ev)
        ozh = ('ПРЕДУПРЕЖДЕНИЕ: OBJECT_RASHODITSJA: предмет %s: вердиктный '
               'хвост не сохраняет OBJECT\n' % SUBJ)
        # дверь A2 (v8): пустой НЕ-merge tip — предупреждение, rc 0,
        # START несёт ФАКТИЧЕСКИЙ OBJECT (tip автора)
        return [k_rc(r, 0, 'r09'), k_stdout(r, PUSCHEM, 'r09'),
                k_text(r, ozh, 'r09'), k_start(m, 'Crit208', E, 'r09')]

    def r10(m, door):
        wt, br, K0 = bazir(m)
        wt_git(wt, 'checkout', '-q', '-b', 'daleko')
        U = vpered(wt, 'chuzhoe.txt', 'drugaja linija\n', soobshenie='u')
        wt_git(wt, 'checkout', '-q', br)
        K2 = vpered(wt, 'svoe.txt', 'svoja rabota\n', soobshenie='k2')
        do = m.ledger.read_bytes()
        ev = vyzov(m, U)
        r = sudit(door, m, ev)
        ozh = ('ОТКАЗ: OBJECT_RASHODITSJA: предмет %s: OBJECT задания %s ≠ '
               'tip ветки %s (%s) и не связан предковостью с работой '
               'последнего START; выход: новый OBJECT (исправительный круг) '
               'либо опубликовать ветку с этой работой\n'
               % (SUBJ, U, br, K2))
        return [k_rc(r, 1, 'r10'), k_stdout(r, '', 'r10'),
                k_text(r, ozh, 'r10'), k_uchet_ne_izmenen(m, do, 'r10')]

    def krug(m, K0, derzhatel='Critic1'):
        m.start(SUBJ, derzhatel, klass='sudja', rol='critic', obj=K0,
                zanyat=False)
        m.release(SUBJ, derzhatel, prichina='verdikt_zakommiten')

    def uzhe_suzhen_ozh():
        return ('ОТКАЗ: OBJECT_UZHE_SUZHEN: предмет %s: OBJECT %s уже судился '
                'ролью critic; исправительный круг — новый sha; повтор — '
                'записанная в учёте санкция SANKCIJA (один круг, пока не '
                'исчерпан)\n')

    def r11(m, door):
        wt, br, K0 = bazir(m)
        krug(m, K0)
        m.sankcija(SUBJ, 'critic', K0)
        ev = vyzov(m, K0)
        r = sudit(door, m, ev)
        return [k_rc(r, 0, 'r11'), k_stdout(r, PUSCHEM, 'r11'),
                k_text(r, '', 'r11'), k_start(m, 'Crit208', K0, 'r11')]

    def r12(m, door):
        wt, br, K0 = bazir(m)
        krug(m, K0)
        m.sankcija(SUBJ, 'critic', DUMMY)
        do = m.ledger.read_bytes()
        ev = vyzov(m, K0)
        r = sudit(door, m, ev)
        ozh = uzhe_suzhen_ozh() % (SUBJ, K0)
        return [k_rc(r, 1, 'r12'), k_stdout(r, '', 'r12'),
                k_text(r, ozh, 'r12'), k_uchet_ne_izmenen(m, do, 'r12')]

    def r13(m, door):
        wt, br, K0 = bazir(m)
        krug(m, K0, 'Critic1')
        krug(m, K0, 'Critic1')
        m.sankcija(SUBJ, 'critic', K0)
        do = m.ledger.read_bytes()
        ev = vyzov(m, K0)
        r = sudit(door, m, ev)
        ozh = uzhe_suzhen_ozh() % (SUBJ, K0)
        return [k_rc(r, 1, 'r13'), k_stdout(r, '', 'r13'),
                k_text(r, ozh, 'r13'), k_uchet_ne_izmenen(m, do, 'r13')]

    def r14(m, door):
        wt, br, K0 = bazir(m)
        krug(m, K0)
        do = m.ledger.read_bytes()
        # строка 21.11 00:55 в задании есть, но словом 21.11 12:06 (v8 A2)
        # она снята — санкции в учёте нет, повтор не разрешён
        ev = vyzov(m, K0, ['РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР: %s critic %s'
                           % (SUBJ, K0)])
        r = sudit(door, m, ev)
        ozh = uzhe_suzhen_ozh() % (SUBJ, K0)
        return [k_rc(r, 1, 'r14'), k_stdout(r, '', 'r14'),
                k_text(r, ozh, 'r14'), k_uchet_ne_izmenen(m, do, 'r14')]

    def r15(m, door):
        wt, br, K0 = bazir(m)
        krug(m, K0)
        do = m.ledger.read_bytes()
        ev = vyzov(m, K0)
        r = sudit(door, m, ev)
        ozh = uzhe_suzhen_ozh() % (SUBJ, K0)
        return [k_rc(r, 1, 'r15'), k_stdout(r, '', 'r15'),
                k_text(r, ozh, 'r15'), k_uchet_ne_izmenen(m, do, 'r15')]

    def r16(m, door):
        wt, br, K0 = bazir(m)
        m.pauza(SUBJ)
        do = m.ledger.read_bytes()
        ev = vyzov(m, K0)
        r = sudit(door, m, ev)
        ozh = ('ОТКАЗ: PAUZA_VLADELTSA: предмет %s стоит на ПАУЗЕ владельца '
               '(реестр профиля)\n' % SUBJ)
        return [k_rc(r, 1, 'r16'), k_stdout(r, '', 'r16'),
                k_text(r, ozh, 'r16'), k_uchet_ne_izmenen(m, do, 'r16')]

    def r17(m, door):
        wt, br, K0 = bazir(m)
        wt_git(wt, 'checkout', '-q', '--detach', K0)
        wt_git(wt, 'branch', '-D', br)
        ev = vyzov(m, K0)
        r = sudit(door, m, ev)
        # дверь A2 (v8): ветка не читается — предупреждение, rc 0,
        # START несёт запрошенный OBJECT (сверить нечем)
        ozh = ('ПРЕДУПРЕЖДЕНИЕ: VETKA_NEDOSTUPNA: предмет %s: ветка %s в %s '
               'не читается — OBJECT не сверить\n' % (SUBJ, br, wt))
        return [k_rc(r, 0, 'r17'), k_stdout(r, PUSCHEM, 'r17'),
                k_text(r, ozh, 'r17'), k_start(m, 'Crit208', K0, 'r17')]

    def r18(m, door):
        wt, br, K0 = bazir(m)
        wt_git(wt, 'checkout', '-q', '-b', 'side3')
        vpered(wt, 'verdicts/critic/contracts-%s-v1.md' % SUBJ,
               'accept\nOBJECT=%s\n' % K0, role='critic',
               soobshenie='v-s')
        wt_git(wt, 'checkout', '-q', br)
        vpered(wt, 'verdicts/critic/contracts-%s-v2.md' % SUBJ,
               'accept\nOBJECT=%s\n' % DUMMY, role='critic',
               soobshenie='v-m')
        wt_git(wt, 'merge', '-q', '--no-ff', 'side3', '-m', 'vm')
        M2 = wt_git(wt, 'rev-parse', 'HEAD').stdout.strip()
        do = m.ledger.read_bytes()
        ev = vyzov(m, M2)
        r = sudit(door, m, ev)
        # merge с НЕпустой дельтой против первого родителя — не кандидат
        # D9c: поведение резолвера двери A2 (предупреждение, START на tip)
        ozh = ('ПРЕДУПРЕЖДЕНИЕ: OBJECT_RASHODITSJA: предмет %s: вердиктный '
               'хвост не сохраняет OBJECT\n' % SUBJ)
        return [k_rc(r, 0, 'r18'), k_stdout(r, PUSCHEM, 'r18'),
                k_text(r, ozh, 'r18'), k_start(m, 'Crit208', M2, 'r18')]

    def r19(m, door):
        wt, br, K0 = bazir(m)
        krug(m, K0)
        m.sankcija(SUBJ, 'critic', K0, subject='209')
        do = m.ledger.read_bytes()
        ev = vyzov(m, K0)
        r = sudit(door, m, ev)
        ozh = uzhe_suzhen_ozh() % (SUBJ, K0)
        return [k_rc(r, 1, 'r19'), k_stdout(r, '', 'r19'),
                k_text(r, ozh, 'r19'), k_uchet_ne_izmenen(m, do, 'r19')]

    def r20(m, door):
        wt, br, K0 = bazir(m)
        krug(m, K0)
        m.sankcija(SUBJ, 'reviewer', K0)
        do = m.ledger.read_bytes()
        ev = vyzov(m, K0)
        r = sudit(door, m, ev)
        ozh = uzhe_suzhen_ozh() % (SUBJ, K0)
        return [k_rc(r, 1, 'r20'), k_stdout(r, '', 'r20'),
                k_text(r, ozh, 'r20'), k_uchet_ne_izmenen(m, do, 'r20')]

    def r21(m, door):
        wt, br, K0 = bazir(m)
        krug(m, K0)
        m.sankcija(SUBJ, 'critic', K0, repo='other-repo')
        do = m.ledger.read_bytes()
        ev = vyzov(m, K0)
        r = sudit(door, m, ev)
        ozh = uzhe_suzhen_ozh() % (SUBJ, K0)
        return [k_rc(r, 1, 'r21'), k_stdout(r, '', 'r21'),
                k_text(r, ozh, 'r21'), k_uchet_ne_izmenen(m, do, 'r21')]

    def r22(m, door):
        # OBJECT достижим только через ВТОРОГО родителя merge: боковая
        # ветка публикует X, main делает свой коммит и merge --no-ff side;
        # X — предок tip только по второй родительской линии
        wt, br, K0 = bazir(m)
        wt_git(wt, 'checkout', '-q', '-b', 'side2')
        X = vpered(wt, 'x.txt', 'iks\n', soobshenie='x')
        wt_git(wt, 'checkout', '-q', br)
        vpered(wt, 'svoe2.txt', 'escho rabota\n', soobshenie='k2')
        wt_git(wt, 'merge', '-q', '--no-ff', 'side2', '-m', 'm22')
        M = wt_git(wt, 'rev-parse', 'HEAD').stdout.strip()
        m.publikuj(wt, 'refs/remotes/origin/main', M)
        ev = vyzov(m, X)
        r = sudit(door, m, ev)
        return [k_rc(r, 0, 'r22'), k_stdout(r, PUSCHEM, 'r22'),
                k_text(r, '', 'r22'), k_start(m, 'Crit208', X, 'r22')]

    def r23(m, door):
        # та же история с ОБРАТНЫМ порядком родителей merge (merge из
        # боковой ветки): решение допуска не меняется (инвариант 4)
        wt, br, K0 = bazir(m)
        wt_git(wt, 'checkout', '-q', '-b', 'side3m')
        X = vpered(wt, 'x.txt', 'iks\n', soobshenie='x')
        wt_git(wt, 'checkout', '-q', br)
        vpered(wt, 'svoe2.txt', 'escho rabota\n', soobshenie='k2')
        wt_git(wt, 'checkout', '-q', 'side3m')
        wt_git(wt, 'merge', '-q', '--no-ff', br, '-m', 'm23')
        M2 = wt_git(wt, 'rev-parse', 'HEAD').stdout.strip()
        wt_git(wt, 'branch', '-f', br, M2)
        m.publikuj(wt, 'refs/remotes/origin/main', M2)
        ev = vyzov(m, X)
        r = sudit(door, m, ev)
        return [k_rc(r, 0, 'r23'), k_stdout(r, PUSCHEM, 'r23'),
                k_text(r, '', 'r23'), k_start(m, 'Crit208', X, 'r23')]

    reg('r01-ravenstvo-dopusk',
        'OBJECT == кандидат последнего START — допуск как прежде (rc 0, START)',
        r01)
    reg('r02-predok-opublikovan-v-main',
        'OBJECT-предок кандидата, опубликован в origin/main — допуск (боль 179)',
        r02)
    reg('r03-predok-opublikovan-v-vetke',
        'OBJECT-предок кандидата, опубликован в ветке предмета на origin — допуск',
        r03)
    reg('r04-predok-ne-opublikovan',
        'OBJECT-предок без публикации — именованный отказ с причиной и выходом',
        r04)
    reg('r05-vperjod-opublikovan',
        'кандидат — предок OBJECT (кодовая граница, main) — допуск (боли 007/182)',
        r05)
    reg('r06-vperjod-verdikt-hvost',
        'OBJECT-вердикткоммит впереди кандидата — отказ: не кодовая граница',
        r06)
    reg('r07-vperjod-ne-opublikovan',
        'OBJECT впереди кандидата без публикации — именованный отказ',
        r07)
    reg('r08-merge-pustaja-delta',
        'merge с пустой дельтой против первого родителя — допуск tip (боль 152/177)',
        r08)
    reg('r09-pustoj-ne-merge-tip',
        'пустой НЕ-merge tip — поведение двери A2: предупреждение, rc 0, START на tip',
        r09)
    reg('r10-mimo-novoj-raboty',
        'расхождение (не предок и не потомок) — отказ с причиной и выходом',
        r10)
    reg('r11-sankcija-v-uchete',
        'повтор роли по записанной санкции SANKCIJA — допуск (боль 152/177)',
        r11)
    reg('r12-sankcija-chuzhoj-object',
        'санкция на чужой OBJECT — повтор запрещён', r12)
    reg('r13-sankcija-iscerpana',
        'санкция при исчерпанном круге (krugov 2) — повтор запрещён', r13)
    reg('r14-povtor-stroka-ne-dejstvuet',
        'строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР снята словом 21.11 12:06 (A2 v8) — без санкции повтор запрещён',
        r14)
    reg('r15-povtor-bez-razreshenija',
        'повтор без санкции — именованный отказ', r15)
    reg('r16-pauza-vladelca',
        'ПАУЗА владельца — отказ (не ослаблен)', r16)
    reg('r17-vetka-nedostupna',
        'ветка носителя не читается — поведение двери A2: предупреждение, rc 0',
        r17)
    reg('r18-merge-verdikt-neodnoznachnyj',
        'merge c неоднозначным вердиктным хвостом — поведение резолвера A2',
        r18)
    reg('r19-sankcija-chuzhoj-predmet',
        'санкция чужого предмета (subjectId 209) — повтор запрещён (К-08)',
        r19)
    reg('r20-sankcija-chuzhaja-rol',
        'санкция чужой роли (reviewer) — повтор запрещён (К-08)', r20)
    reg('r21-sankcija-chuzhoj-repo',
        'санкция чужого repoId (other-repo) — повтор запрещён (К-08)', r21)
    reg('r22-predok-cherez-vtorogo-roditelja',
        'OBJECT достижим только через второго родителя merge — допуск (К-09)',
        r22)
    reg('r23-porjadok-roditelej-merge',
        'порядок родителей merge не меняет допуск (инвариант 4, К-14)', r23)
    return K


# ── обманные стабы: якорь кратности 1 в тексте модели → мутация ─────────────
def _mut(tekst, jakor, zamena):
    n = tekst.count(jakor)
    assert n == 1, 'якорь не кратен 1 (%d): %r' % (n, jakor[:80])
    return tekst.replace(jakor, zamena, 1)


STAB_MUTACII = {
    'st01-ravenstvo-tolko': lambda t: _mut(
        t, 'if [ "$obj_fakt" = "$obj" ] && [ "$tip" != "$obj" ]; then',
        'if false; then'),
    'st02-predok-bez-publikacii': lambda t: _mut(
        t, '''            obj_opublikovan "$r_wt" "$sv" "$obj" || {
              mutexi_snyat_vse
              otp OBJECT_RASHODITSJA "предмет $sv: OBJECT $obj — предок кандидата''',
        '''            true || {
              mutexi_snyat_vse
              otp OBJECT_RASHODITSJA "предмет $sv: OBJECT $obj — предок кандидата'''),
    'st03-vperjod-bez-granicy': lambda t: _mut(
        t, '''            kodovaja_granica "$r_wt" "$sv" "$obj" || {''',
        '''            true || {'''),
    'st04-vperjod-bez-publikacii': lambda t: _mut(
        t, '''            obj_opublikovan "$r_wt" "$sv" "$obj" || {
              mutexi_snyat_vse
              otp OBJECT_RASHODITSJA "предмет $sv: OBJECT $obj впереди кандидата $tip (кодовая граница), но не опубликован''',
        '''            true || {
              mutexi_snyat_vse
              otp OBJECT_RASHODITSJA "предмет $sv: OBJECT $obj впереди кандидата $tip (кодовая граница), но не опубликован'''),
    'st05-merge-bez-pustoty': lambda t: _mut(
        t, '''             && [ -z "$(puti_kommita "$r_wt" "$mtip")" ]; then''',
        '''             ; then'''),
    'st06-merge-ljuboj-tip': lambda t: _mut(
        t, """'^[0-9a-f]{40}( [0-9a-f]{40})+$'""", """'^.*$'"""),
    'st07-sankcija-bez-object': lambda t: _mut(
        t, '''
              and .rol == $roli and .object == $o)\'''',
        '''
              and .rol == $roli and true)\''''),
    'st08-sankcija-bez-krugov': lambda t: _mut(
        t, '''      if [ "$(krugov_suda "$sv" "$rol" "$obj")" = '1' ] \\''',
        '''      if true \\'''),
    'st09-stroka-kak-sankcija': lambda t: _mut(
        t, '''         && sankcija_ucheta "$sv" "$rol" "$obj"; then''',
        '''         && { sankcija_ucheta "$sv" "$rol" "$obj" || grep -q 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР' "$EVENT"; }; then'''),
    'st10-otkaz-bez-vyhoda': lambda t: _mut(
        t, '''($tip) и не связан предковостью с работой последнего START; выход: новый OBJECT (исправительный круг) либо опубликовать ветку с этой работой"''',
        '''($tip)"'''),
    'st11-predki-pereputany': lambda t: _mut(
        t, '''          if git -C "$r_wt" merge-base --is-ancestor "$obj" "$tip" 2>/dev/null; then''',
        '''          if git -C "$r_wt" merge-base --is-ancestor "$tip" "$obj" 2>/dev/null; then'''),
    'st12-publikacija-tolko-main': lambda t: _mut(
        t, '''"refs/remotes/origin/wip/$n/")''',
        '''"refs/remotes/origin/wip/$n-net/")'''),
    'st13-sankcija-bez-subjectid': lambda t: _mut(
        t, '''.t == "SANKCIJA" and .repoId == $r and .subjectId == $n''',
        '''.t == "SANKCIJA" and .repoId == $r and true'''),
    'st14-sankcija-bez-roli': lambda t: _mut(
        t, '''
              and .rol == $roli''',
        '''
              and true'''),
    'st15-sankcija-bez-repo': lambda t: _mut(
        t, '''.t == "SANKCIJA" and .repoId == $r and''',
        '''.t == "SANKCIJA" and true and'''),
    'st16-predok-tolko-pervyj-roditel': lambda t: _mut(
        t, '''          if git -C "$r_wt" merge-base --is-ancestor "$obj" "$tip" 2>/dev/null; then''',
        '''          if git -C "$r_wt" rev-list --first-parent "$tip" 2>/dev/null | grep -Fxq "$obj"; then'''),
    'st17-diagnostika-r04': lambda t: _mut(
        t, '''выход: fetch origin в носителе либо опубликовать работу"''',
        '''выход: опубликовать работу"'''),
    'st18-diagnostika-r06': lambda t: _mut(
        t, '''выход: OBJECT работы, не verdikt-коммит"''',
        '''выход отсутствует"'''),
    'st19-diagnostika-r07': lambda t: _mut(
        t, '''выход: опубликовать работу в main либо ветке wip/$sv/* на origin"''',
        '''выход: опубликовать работу в ветке wip/$sv/* либо в main на origin"'''),
}

STAB_VHOD = {
    'st01-ravenstvo-tolko': ['r04-predok-ne-opublikovan',
                             'r06-vperjod-verdikt-hvost',
                             'r07-vperjod-ne-opublikovan',
                             'r10-mimo-novoj-raboty'],
    'st02-predok-bez-publikacii': ['r04-predok-ne-opublikovan'],
    'st03-vperjod-bez-granicy': ['r06-vperjod-verdikt-hvost'],
    'st04-vperjod-bez-publikacii': ['r07-vperjod-ne-opublikovan'],
    'st05-merge-bez-pustoty': ['r18-merge-verdikt-neodnoznachnyj'],
    'st06-merge-ljuboj-tip': ['r09-pustoj-ne-merge-tip'],
    'st07-sankcija-bez-object': ['r12-sankcija-chuzhoj-object'],
    'st08-sankcija-bez-krugov': ['r13-sankcija-iscerpana'],
    'st09-stroka-kak-sankcija': ['r14-povtor-stroka-ne-dejstvuet'],
    'st10-otkaz-bez-vyhoda': ['r10-mimo-novoj-raboty'],
    'st11-predki-pereputany': ['r02-predok-opublikovan-v-main',
                               'r03-predok-opublikovan-v-vetke',
                               'r23-porjadok-roditelej-merge'],
    'st12-publikacija-tolko-main': ['r03-predok-opublikovan-v-vetke'],
    'st13-sankcija-bez-subjectid': ['r19-sankcija-chuzhoj-predmet'],
    'st14-sankcija-bez-roli': ['r20-sankcija-chuzhaja-rol'],
    'st15-sankcija-bez-repo': ['r21-sankcija-chuzhoj-repo'],
    'st16-predok-tolko-pervyj-roditel': ['r22-predok-cherez-vtorogo-roditelja'],
    'st17-diagnostika-r04': ['r04-predok-ne-opublikovan'],
    'st18-diagnostika-r06': ['r06-vperjod-verdikt-hvost'],
    'st19-diagnostika-r07': ['r07-vperjod-ne-opublikovan'],
}


# ── прогон одной клетки: rc, stdout и stderr байт-в-байт в каждом режиме ────
def prognot_kletku(fn, door):
    tmp = tempfile.mkdtemp(prefix='zamok208-')
    problemy = []
    try:
        m = Mir(tmp)
        for ch in fn(m, door):
            if ch:
                problemy.append(ch)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    return problemy


def subjekt_repo(koren=None):
    if koren:
        root = Path(koren).resolve()
    else:
        g = run(['git', '-C', str(HERE), 'rev-parse', '--show-toplevel'])
        if g.returncode != 0:
            return None
        root = Path(g.stdout.strip())
    d = root / 'scripts' / 'zamok_predmeta.sh'
    return d if d.is_file() else None


def zashita_zavisimostej():
    for b in ('git', 'jq', 'bash'):
        if shutil.which(b) is None:
            print('NOT_IMPLEMENTED: нет %s' % b, file=sys.stderr)
            sys.exit(2)


def istochnik():
    if not SOURCE.is_file():
        print('ORACLE_TAMPERED: нет source.json', file=sys.stderr)
        sys.exit(2)
    return json.loads(SOURCE.read_text(encoding='utf-8'))


def nositeli_sverka(src):
    ploho = []
    for otn, pin in src.get('nositeli', {}).items():
        p = HERE / otn
        if not p.is_file() or sha256_bytes(p.read_bytes()) != pin:
            ploho.append(otn)
    if ploho:
        print('ORACLE_TAMPERED: дрейф носителей: %s' % ', '.join(ploho),
              file=sys.stderr)
        sys.exit(2)


def sgeneriruj():
    tekst = MODEL.read_text(encoding='utf-8')
    K = kejsy()
    for imja, fn in sorted(STAB_MUTACII.items()):
        mut = fn(tekst)
        sint = subprocess.run(['bash', '-n', '/dev/stdin'], input=mut,
                              capture_output=True, text=True, env=GIT_ENV)
        if sint.returncode != 0:
            raise SystemExit('ORACLE_TAMPERED: стаб %s сломал синтаксис: %s'
                             % (imja, sint.stderr.strip()[:200]))
        d = STABS / imja
        d.mkdir(parents=True, exist_ok=True)
        (d / 'zamok_predmeta.sh').write_text(mut, encoding='utf-8')
        os.chmod(d / 'zamok_predmeta.sh', 0o755)
    nositeli = {'model/zamok_predmeta.sh':
                sha256_bytes(MODEL.read_bytes())}
    for imja in sorted(STAB_MUTACII):
        otn = 'stabs/%s/zamok_predmeta.sh' % imja
        nositeli[otn] = sha256_bytes((HERE / otn).read_bytes())
    src = {
        'versija': 1,
        'kontrakt': 'contracts/208-zamok-object-predok.md',
        'subjekt': 'scripts/zamok_predmeta.sh',
        'model': 'model/zamok_predmeta.sh',
        'kejsy': {imja: os for imja, (os, _) in sorted(K.items())},
        'stab_vhod': {k: sorted(v) for k, v in sorted(STAB_VHOD.items())},
        'nositeli': dict(sorted(nositeli.items())),
        'zametki': 'привязки стаб↔клетка — единственный источник (Н-39); '
                   'якорь каждой мутации — кратность 1 в тексте модели',
    }
    SOURCE.write_text(json.dumps(src, ensure_ascii=False, indent=1) + '\n',
                      encoding='utf-8')
    print('SGENERIROVANO stabov %d kletok %d' % (len(STAB_MUTACII), len(K)))


def main():
    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument('--repo', nargs='?', const='', default=None)
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    ap.add_argument('--sgeneriruj-staby', action='store_true')
    ap.add_argument('--sintaksis', action='store_true')
    argj = ap.parse_args()
    if getattr(argj, 'sintaksis', False):
        # носители пачки синтаксически цельны: модель и (если поставлен)
        # субъект дерева; rc 1 — сломан носитель, rc 2 — нечем проверить
        zashita_zavisimostej()
        ploho = []
        for put, imja in ((MODEL, 'model'),
                          (HERE.parent.parent.parent
                           / 'scripts' / 'zamok_predmeta.sh', 'subjekt')):
            if not put.is_file():
                continue
            r = run(['bash', '-n', str(put)])
            if r.returncode != 0:
                ploho.append('%s: %s' % (imja, r.stderr.strip()[:200]))
        if ploho:
            for s in ploho:
                print('SINTAKSIS KRASNO: %s' % s)
            return 1
        print('SINTAKSIS OK')
        return 0
    zashita_zavisimostej()

    if argj.sgeneriruj_staby:
        sgeneriruj()
        return 0

    K = kejsy()
    src = istochnik()
    if sorted(src.get('kejsy', {})) != sorted(K):
        print('ORACLE_TAMPERED: рассинхрон перечня клеток с source.json',
              file=sys.stderr)
        sys.exit(2)
    if sorted(src.get('stab_vhod', {})) != sorted(STAB_MUTACII):
        print('ORACLE_TAMPERED: рассинхрон перечня стабов с source.json',
              file=sys.stderr)
        sys.exit(2)
    for st, vhod in STAB_VHOD.items():
        for c in vhod:
            if c not in K:
                print('ORACLE_TAMPERED: стаб %s ведёт на неизвестную клетку %s'
                      % (st, c), file=sys.stderr)
                sys.exit(2)

    if argj.model or argj.stabs:
        nositeli_sverka(src)
        krasnye = []
        for imja, (_, fn) in sorted(K.items()):
            for p in prognot_kletku(fn, MODEL):
                krasnye.append('%s: %s' % (imja, p))
        if krasnye:
            print('MODEL 208: KLETKI %d KRASNYH %d' % (len(K), len(krasnye)))
            for s in krasnye:
                print('KRASNAJA-KLETKA %s' % s)
            return 1
        print('MODEL 208: KLETKI %d KRASNYH 0' % len(K))
        if not argj.stabs:
            return 0
        tekst = MODEL.read_text(encoding='utf-8')
        zhivyh = 0
        svjazi = 0
        for imja, fn in sorted(STAB_MUTACII.items()):
            try:
                mut = fn(tekst)
            except AssertionError as e:
                print('ORACLE_TAMPERED: %s: %s' % (imja, e), file=sys.stderr)
                sys.exit(2)
            katalog = Path(tempfile.mkdtemp(prefix='stab208-'))
            dvor = katalog / 'zamok_predmeta.sh'
            dvor.write_text(mut, encoding='utf-8')
            os.chmod(dvor, 0o755)
            sint = run(['bash', '-n', str(dvor)])
            if sint.returncode != 0:
                shutil.rmtree(katalog, ignore_errors=True)
                print('ORACLE_TAMPERED: стаб %s сломал синтаксис: %s'
                      % (imja, sint.stderr.strip()[:200]), file=sys.stderr)
                sys.exit(2)
            pojmali = []
            try:
                for vhod in STAB_VHOD[imja]:
                    _, kfn = K[vhod]
                    problemy = prognot_kletku(kfn, dvor)
                    if problemy:
                        pojmali.append(vhod)
            finally:
                shutil.rmtree(katalog, ignore_errors=True)
            svjazi += len(STAB_VHOD[imja])
            if not pojmali:
                zhivyh += 1
                print('STAB_ZHIV %s: ни одна связанная клетка не красна' % imja)
        print('STABY 208: SVJAZI %d ZHIVYH %d' % (svjazi, zhivyh))
        return 1 if zhivyh else 0

    # производственный слой: субъект дерева (база A2); байт-в-байт тот же
    koren = argj.repo if argj.repo else None
    subj = subjekt_repo(koren)
    if subj is None:
        perechen = '\n'.join(sorted(K))
        print('SUBJECT_ABSENT: нет scripts/zamok_predmeta.sh; входы:')
        print(perechen)
        print(perechen, file=sys.stderr)
        return 1
    krasnye = {}
    for imja, (_, fn) in sorted(K.items()):
        for p in prognot_kletku(fn, subj):
            krasnye.setdefault(imja, []).append(p)
    print('SUBJEKT 208: KLETKI %d KRASNYH %d' % (len(K), len(krasnye)))
    if krasnye:
        print('КРАСНОЕ 208')
        print('КРАСНОЕ 208', file=sys.stderr)
        for imja in sorted(krasnye):
            for s in krasnye[imja]:
                print('KRASNAJA-KLETKA %s: %s' % (imja, s))
                print('KRASNAJA-KLETKA %s: %s' % (imja, s), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
