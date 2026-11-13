#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 140 (§ПРОВОДКА): судит дверь замка предмета
# (model/zamok_predmeta.sh — эталон; реализация scripts/zamok_predmeta.sh
# несёт ту же семантику) по КЛАССАМ входов таблицы осей: «форма → клетка →
# защита → стаб-на-защиту». Обманные стабы — мутации модели КОДОМ
# (STAB_MUTACII, маркеры [Dn] двери), материал в stabs/<имя>/; привязки —
# ТОЛЬКО source.json:.stab_vhod (Н-39: проза контракта пар не утверждает).
# Оракул — source.json в памяти ДО вызова субъекта (правило 8); носители —
# sha256; рассинхрон множеств — rc 2 ORACLE_TAMPERED.
"""Батарея 140 (odin-agent-na-predmet): один рабочий агент на предмет,
атомарный замок (repoId, subjectId) на batch, судья после yield автора
на зафиксированный OBJECT, единый учёт начатых предметов (лимиты 3/3/3 —
слово владельца 2026-10-28: 1/3/2 → 3/3/3, только числа).

Режимы:
  (без флага)   субъект = ПОСТАВЛЕННАЯ дверь дерева scripts/zamok_predmeta.sh
                (образец 136: боли живы → rc 1; зелень — только после ленда
                реализации). Нет субъекта → rc 1 SUBJECT_ABSENT с перечнем всех
                входов ПО ПУТИ реального субъекта; обманная дверь (свидетель
                критика 1/2: «всегда PUSCHEM») → rc 1 с названными клетками.
  --model       субъект = model/zamok_predmeta.sh, контроль входов (N/N);
  --stabs       контроль + матрица обманных стабов над МОДЕЛЬЮ (опора до
                ленда) +, когда scripts/zamok_predmeta.sh существует, СЛОЙ
                СУБЪЕКТА: контроль всех клеток на поставленной двери и та же
                матрица обманных дверей над её текстом (SVJAZI растёт, живых 0);
  --sgeneriruj-staby  (обслуживание) материализует stabs/ из STAB_MUTACII.

Интеграция хука .omp/extensions/spawn-guard.ts без станции НЕ исполнима (корни
состояний — из живого ctx сессии omp, инвариант 1 контракта): клетки интеграции
помечены «станция» в osi.md и закрыты КОМАНДОЙ приёмки stancija_odin_agent_140.sh
(rc 0/1, строки PROBA <имя> OK|KRASNO) — не молчаливым пропуском батареи.

Миры — в mktemp под $TMPDIR; omp НЕ нужен; сети нет; git/jq/bash обязательны.
Коды возврата: 0 — зелено; 1 — красный кейс либо стаб прошёл (STAB_ZHIV)
либо субъекта нет (SUBJECT_ABSENT); 2 — нечем проверять (нет git/jq,
ORACLE_TAMPERED, дрейф стабов/модели).
"""
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
MODEL = HERE / 'model' / 'zamok_predmeta.sh'
STABS = HERE / 'stabs'
# materialy — байт-копии реальных строк/текста из 9ec350f7e (РЕШЕНИЕ
# арбитража 140, Q3 1.2: «брать git show 9ec350f7e:contracts/<файл> —
# не перенабирать»); пины sha256 — source.json:.nositeli (materialy/<имя>)
MATER = HERE / 'materialy'
# ПОСТАВЛЯЕМЫЙ субъект безфлагового режима: реальная дверь дерева клона
# (HERE = <корень>/fixtures/workshop_project/odin_agent_140).
REEPOR = HERE.parents[2]
SUBJEKT_DVERI = REEPOR / 'scripts' / 'zamok_predmeta.sh'
# станционные клетки интеграции хука (osi.md: p01–p14 + m01) — закрыты
# КОМАНДОЙ приёмки stancija_odin_agent_140.sh, не молчаливым пропуском
STANCIONNYH_KLETOK = 15
BASH = '/usr/bin/bash' if Path('/usr/bin/bash').is_file() else 'bash'
TAB = '\t'
GIT_ENV = {'GIT_CONFIG_GLOBAL': '/dev/null', 'GIT_CONFIG_SYSTEM': '/dev/null',
           'PATH': os.environ.get('PATH', '/usr/bin:/bin')}

# константы канона — сверяются с source.json (единый источник значений)
CAP_HARNESS, CAP_MOB, CAP_BACK = 3, 3, 3  # слово владельца 2026-10-28: 1/3/2 → 3/3/3
BROSHEN_TTL_MIN = 60
YIELD_LITERAL = '"toolName":"yield"'
REPO_ID = 'dev-harness'
MOB_REMOTE = 'ssh://git@github.com/a3ka/Complior-mob.git'
BACK_REMOTE = 'ssh://git@github.com/a3ka/Complior-back.git'
HARNESS_REMOTE = 'ssh://git@github.com/a3ka/dev-harness.git'
OBJECT_DUMMY = '1234567890123456789012345678901234567890'


def sha256_bytes(b):
    return hashlib.sha256(b).hexdigest()


def oshibka_orakula(msg):
    print('ORACLE_TAMPERED: %s' % msg, file=sys.stderr)
    return 2


def run(cmd, cwd=None, env=None):
    return subprocess.run(cmd, capture_output=True, text=True, cwd=cwd,
                          env=env if env is not None else GIT_ENV, timeout=120)


# ── мир: состояние + журналы + реестр ────────────────────────────────────────
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
        self.slova = []

    def git(self, args):
        return run(['git', '-c', 'user.name=battery', '-c',
                    'user.email=b@t', '-c', 'commit.gpgsign=false'] + args,
                   cwd=str(self.repo))

    def kontrakt(self, nnn, risk='обычный'):
        f = self.repo / 'contracts' / ('%s-stub.md' % nnn)
        f.write_text('# К\nКЛАСС РИСКА: %s\n' % risk, encoding='utf-8')
        self.git(['add', '-A'])
        self.git(['commit', '-q', '-m', 'c%s' % nnn])

    def pauza(self, nnn):
        f = self.repo / 'registry' / 'pauzy.tsv'
        with f.open('a', encoding='utf-8') as fh:
            fh.write('%s\t2026-10-24\tвладелец\tпозже\n' % nnn)
        self.git(['add', '-A'])
        self.git(['commit', '-q', '-m', 'p%s' % nnn])

    def done(self, nnn):
        self.git(['tag', 'done/contracts/%s/1' % nnn])

    def worktree(self, nnn, remote=HARNESS_REMOTE, kontrakty=None):
        # v+1 (класс из дерева OBJECT, слово владельца 2026-11-12): kontrakty —
        # записи [(вид, имя, данные)] вида 'fajl' (данные — текст), 'symlink'
        # (данные — цель), 'dir'; коммитятся в contracts/ КАНДИДАТА до снятия
        # sha — суд класса читает именно ДЕРЕВО OBJECT.
        wt = self.root / ('wt%s' % nnn)
        wt.mkdir(parents=True, exist_ok=True)
        g = run(['git', 'init', '-q', '.'], cwd=str(wt))
        assert g.returncode == 0, g.stderr
        run(['git', 'remote', 'add', 'origin', remote], cwd=str(wt), env=GIT_ENV)
        br = 'wip/%s/avtor' % nnn
        run(['git', 'checkout', '-q', '-b', br], cwd=str(wt), env=GIT_ENV)
        if kontrakty:
            kat = wt / 'contracts'
            kat.mkdir(exist_ok=True)
            for vid, imja, dannye in kontrakty:
                p = kat / imja
                if vid == 'symlink':
                    p.symlink_to(dannye)
                elif vid == 'dir':
                    p.mkdir(exist_ok=True)
                    (p / 'vnutri.md').write_text('# К\n', encoding='utf-8')
                else:
                    p.write_text(dannye, encoding='utf-8')
            run(['git', 'add', '-A'], cwd=str(wt), env=GIT_ENV)
            run(['git', '-c', 'user.name=b', '-c', 'user.email=b@t', 'commit',
                 '-q', '-m', 'k'], cwd=str(wt), env=GIT_ENV)
        else:
            run(['git', '-c', 'user.name=b', '-c', 'user.email=b@t', 'commit',
                 '-q', '--allow-empty', '-m', 'w'], cwd=str(wt), env=GIT_ENV)
        sha = run(['git', 'rev-parse', 'HEAD'], cwd=str(wt), env=GIT_ENV).stdout.strip()
        return str(wt), br, sha

    def amend(self, nnn):
        wt = self.root / ('wt%s' % nnn)
        run(['git', '-c', 'user.name=b', '-c', 'user.email=b@t', 'commit',
             '-q', '--allow-empty', '--amend', '-m', 'w2'], cwd=str(wt), env=GIT_ENV)
        return run(['git', 'rev-parse', 'HEAD'], cwd=str(wt), env=GIT_ENV).stdout.strip()

    def zhurnal(self, holder, sdal=False, vozrast_min=None):
        f = self.zhurnaly / ('%s.jsonl' % holder)
        body = '{"timestamp":"2026-10-25T10:00:00.000Z","message":{"role":"assistant"}}\n'
        if sdal:
            body += ('{"type":"toolResult","toolCallId":"toolu_x",'
                     '"toolName":"yield","content":[{"type":"text","text":"Result submitted."}]}\n')
        f.write_text(body, encoding='utf-8')
        if vozrast_min is not None:
            was = time.time() - vozrast_min * 60
            os.utime(str(f), (was, was))


    def zhurnal_vyhod(self, holder, kind='normal', poddelka=False, vozrast_min=None):
        # журнал держателя с завершением omp 18.18.8 (замер 2026-11-12 по
        # журналам станции: yield-литералов у субагентов 12.11 — 0; событий
        # session_exit — 2516 normal / 231 signal, все type=custom): ПОСЛЕДНЕЙ
        # строкой — событие рантайма; форма — из журналов станции, поля — те,
        # что читает дверь (.type/.customType/.data.kind). poddelka — литералы
        # «customType":"session_exit"»/«kind":"normal"» вложенными полями
        # ЧУЖОГО custom-события (канал подделки сдачи: подстрока без структуры).
        f = self.zhurnaly / ('%s.jsonl' % holder)
        body = '{"timestamp":"2026-11-12T10:00:00.000Z","message":{"role":"assistant"}}\n'
        if poddelka:
            body += ('{"type":"custom","customType":"task_status",'
                     '"data":{"status":"done","event":{"customType":"session_exit",'
                     '"kind":"normal"}},"timestamp":"2026-11-12T10:01:00.000Z",'
                     '"runtime":{"version":"18.18.8"}}\n')
        else:
            body += ('{"type":"custom","customType":"session_exit",'
                     '"data":{"kind":"%s","reason":"final"},'
                     '"timestamp":"2026-11-12T10:01:00.000Z",'
                     '"runtime":{"version":"18.18.8"}}\n' % kind)
        f.write_text(body, encoding='utf-8')
        if vozrast_min is not None:
            was = time.time() - vozrast_min * 60
            os.utime(str(f), (was, was))

    def risk_legacy(self, blob, klass):
        # строка registry/risk-legacy.tsv ($REPO): класс старого frozen по blob
        f = self.repo / 'registry' / 'risk-legacy.tsv'
        with f.open('a', encoding='utf-8') as fh:
            fh.write('%s\t%s\tслово владельца 2026-11-12\tвладелец\n' % (blob, klass))
        self.git(['add', '-A'])
        self.git(['commit', '-q', '-m', 'legacy'])

    def blob_kandidata(self, nnn, imja):
        # blob-идентификатор contracts/<imja> в ДЕРЕВЕ кандидата (tip его ветки)
        wt = self.root / ('wt%s' % nnn)
        return run(['git', 'rev-parse', 'HEAD:contracts/%s' % imja],
                   cwd=str(wt), env=GIT_ENV).stdout.strip()

    def start(self, nnn, holder, klass='rabochij', rol='architect',
              gruppa='harness', wt='-', branch='-', obj='-', zanyat=True,
              vozrast_min=None):
        line = {'t': 'START', 'repoId': REPO_ID, 'subjectId': nnn,
                'group': gruppa, 'holder': holder, 'klass': klass, 'rol': rol,
                'object': obj, 'worktree': wt, 'branch': branch,
                'at': '2026-10-25T10:00:00Z'}
        with self.ledger.open('a', encoding='utf-8') as fh:
            fh.write(json.dumps(line, ensure_ascii=False) + '\n')
        if zanyat:
            zd = self.sost / 'zamki' / REPO_ID / nnn / 'zanyat'
            zd.mkdir(parents=True, exist_ok=True)
            (zd / 'holder.json').write_text(
                json.dumps({'holder': holder, 'klass': klass, 'rol': rol,
                            'object': obj,
                            'startedAt': '2026-10-25T10:00:00Z'}) + '\n',
                encoding='utf-8')

    def slovo(self, nnn):
        with self.ledger.open('a', encoding='utf-8') as fh:
            fh.write(json.dumps({'t': 'SLOVO', 'repoId': REPO_ID,
                                 'subjectId': nnn, 'group': 'mob',
                                 'at': '2026-10-25T10:00:00Z'}) + '\n')

    def release(self, nnn, holder, prichina='yield'):
        # prichina — причина освобождения в учёте. Дверь пишет для судьи
        # verdikt_zakommiten (вердикт закоммичен) либо obryv_bez_verdikta
        # (судья без закоммиченного вердикта) — контракт 167; 'yield' остаётся
        # причиной освобождения РАБОЧЕГО.
        with self.ledger.open('a', encoding='utf-8') as fh:
            fh.write(json.dumps({'t': 'RELEASE', 'repoId': REPO_ID,
                                 'subjectId': nnn, 'holder': holder,
                                 'prichina': prichina,
                                 'at': '2026-10-25T10:00:00Z'}) + '\n')

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

    def zanyat_holder(self, nnn):
        f = self.sost / 'zamki' / REPO_ID / nnn / 'zanyat' / 'holder.json'
        if not f.is_file():
            return None
        return json.loads(f.read_text(encoding='utf-8'))


def item(agent, name, stroki):
    return {'agent': agent, 'name': name, 'task': '\n'.join(stroki)}


def sudit(door, mir, event):
    return run([BASH, str(door), '--sudit', '--sostojanie', str(mir.sost),
                '--zhurnaly', str(mir.zhurnaly), '--repo', str(mir.repo),
                str(event)])


def osvobodit(door, mir, nnn, holder):
    return run([BASH, str(door), '--osvobodit', '--sostojanie', str(mir.sost),
                '--zhurnaly', str(mir.zhurnaly), '--repo', str(mir.repo),
                nnn, holder])


def uchet(door, mir):
    return run([BASH, str(door), '--uchet', '--sostojanie', str(mir.sost),
                '--zhurnaly', str(mir.zhurnaly), '--repo', str(mir.repo)])


# ── проверки: каждая возвращает None (ок) либо строку-причину ───────────────
def k_rc(r, want, chto):
    return None if r.returncode == want else '%s: rc %d ≠ %d; stderr=%s' % (
        chto, r.returncode, want, r.stderr.strip()[:160])


def k_prichina(r, imja, chto):
    if ('ОТКАЗ: %s:' % imja) not in r.stderr:
        return '%s: причины %s нет в stderr: %s' % (chto, imja, r.stderr.strip()[:160])
    return None


def k_stroka(mir, chto, **pola):
    for row in mir.ledg():
        if row.get('t') == 'START' and all(row.get(k) == v for k, v in pola.items()):
            return None
    return '%s: строки START %r нет в учёте' % (chto, pola)


def k_net_startov(mir, chto):
    if mir.ledg():
        return '%s: учёт не пуст (%d строк)' % (chto, len(mir.ledg()))
    return None


def k_chislo_startov(mir, chto, n):
    m = len([r for r in mir.ledg() if r.get('t') == 'START'])
    return None if m == n else '%s: START-строк %d ≠ %d' % (chto, m, n)


def k_zanyat(mir, nnn, holder, chto):
    z = mir.zanyat_holder(nnn)
    if z is None:
        return '%s: занятие %s не создано' % (chto, nnn)
    if z.get('holder') != holder:
        return '%s: в занятии %s holder %r ≠ %r' % (chto, nnn, z.get('holder'), holder)
    return None


def k_svoboden(mir, nnn, chto):
    z = mir.zanyat_holder(nnn)
    return None if z is None else '%s: занятие %s живо (holder %r)' % (chto, nnn, z.get('holder'))


def k_stdout(r, pod, chto):
    return None if pod in r.stdout else '%s: в stdout нет %r (есть %r)' % (chto, pod, r.stdout[:160])


# ── КЕЙСЫ (таблица осей; каждая клетка — свой вход и своё предъявление) ──────
def kejsy():
    K = {}

    def reg(imja, os, fn):
        K[imja] = {'osi': os, 'run': fn}

    # A. рабочие: источник × состояние автора × дубль × рестарт × лимит × реестр
    def w01(mir, door):
        wt, br, _ = mir.worktree('140')
        ev = mir.sobytie('e.json', [item('architect', 'Arch140',
                        ['задание', 'SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'), k_stdout(r, 'PUSCHEM Arch140 dev-harness/140 (rabochij/architect)', 'выход'),
                k_stroka(mir, 'start', subjectId='140', holder='Arch140', klass='rabochij', group='harness'),
                k_zanyat(mir, '140', 'Arch140', 'занятие')]
    reg('w01-pervyj-rabochij', 'роль=рабочий;источник=замок;состояние=свободно', w01)

    def w02(mir, door):
        wt, br, _ = mir.worktree('140')
        mir.start('140', 'Arch140', wt=wt, branch=br)
        mir.zhurnal('Arch140', sdal=False)
        ev = mir.sobytie('e.json', [item('architect', 'Arch140b',
                        ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'RABOCHIJ_ZHIV', 'причина'),
                k_chislo_startov(mir, 'учёт', 1)]
    reg('w02-vtoroj-rabochij-zhiv', 'роль=рабочий;источник=журнал+замок;состояние=бежит', w02)

    def w03(mir, door):
        wt, br, _ = mir.worktree('140')
        mir.start('140', 'Arch140', wt=wt, branch=br)
        mir.zhurnal('Arch140', sdal=True)
        ev = mir.sobytie('e.json', [item('implementer', 'Impl140',
                        ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=wip/140/impl'])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'), k_stroka(mir, 'start', holder='Impl140', rol='implementer'),
                k_zanyat(mir, '140', 'Impl140', 'занятие')]
    reg('w03-posle-yield-novyj-rabochij', 'роль=рабочий;состояние=сдал', w03)

    def w04(mir, door):
        wt, br, _ = mir.worktree('140')
        mir.start('140', 'Arch140', wt=wt, branch=br)
        mir.zhurnal('Arch140', sdal=False, vozrast_min=BROSHEN_TTL_MIN + 60)
        ev = mir.sobytie('e.json', [item('architect', 'Arch140c',
                        ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'ZAMOK_BROSHEN', 'причина'),
                k_chislo_startov(mir, 'учёт', 1)]
    reg('w04-dubl-posle-restarta', 'роль=рабочий;состояние=оборван-рестарт;дубль=после-рестарта', w04)

    def w05(mir, door):
        wt, br, _ = mir.worktree('140')
        mir.start('140', 'Arch140', wt=wt, branch=br)
        mir.zhurnal('Arch140', sdal=False, vozrast_min=BROSHEN_TTL_MIN + 60)
        r0 = osvobodit(door, mir, '140', 'Arch140')
        ev = mir.sobytie('e.json', [item('architect', 'Arch140c',
                        ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        rel = [x for x in mir.ledg() if x.get('t') == 'RELEASE']
        return [k_rc(r0, 0, 'освобождение'), k_stdout(r0, 'OSVOBOZHDEN dev-harness/140', 'выход-освобождения'),
                k_rc(r, 0, 'спавн-после'), k_zanyat(mir, '140', 'Arch140c', 'занятие'),
                None if rel else 'RELEASE-строки нет']
    reg('w05-osvobodit-broshennyj', 'роль=рабочий;состояние=оборван;замок=явное-освобождение', w05)

    def w06(mir, door):
        wt, br, _ = mir.worktree('140')
        mir.start('140', 'Arch140', wt=wt, branch=br)
        mir.zhurnal('Arch140', sdal=False)
        r = osvobodit(door, mir, '140', 'Arch140')
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'ZAMOK_ZHIV', 'причина'),
                k_zanyat(mir, '140', 'Arch140', 'занятие-живо')]
    reg('w06-osvobodit-zhivoj', 'роль=рабочий;состояние=бежит;замок=живой', w06)

    def w07(mir, door):
        wt, br, _ = mir.worktree('140')
        ev = mir.sobytie('e.json', [item('architect', 'Arch140',
                        ['задание без строки предмета', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'SUBJECT_NET_V_ZADANII', 'причина'),
                k_net_startov(mir, 'учёт')]
    reg('w07-subject-net', 'форма=SUBJECT-отсутствует', w07)

    def w08(mir, door):
        wt, br, _ = mir.worktree('140')
        ev = mir.sobytie('e.json', [item('architect', 'Arch140',
                        ['SUBJECT=1404', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'SUBJECT_NET_V_ZADANII', 'причина')]
    reg('w08-subject-vne-grammatiki', 'форма=SUBJECT-вне-грамматики', w08)

    def w09(mir, door):
        wt, br, _ = mir.worktree('140')
        ev = mir.sobytie('e.json', [item('architect', '',
                        ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'IMJA_NET', 'причина')]
    reg('w09-imja-net', 'форма=имя-отсутствует', w09)

    def w10(mir, door):
        mir.pauza('140')
        wt, br, _ = mir.worktree('140')
        ev = mir.sobytie('e.json', [item('architect', 'Arch140',
                        ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'PAUZA_VLADELTSA', 'причина'),
                k_net_startov(mir, 'учёт')]
    reg('w10-pauza', 'источник=реестр;учёт=ПАУЗА', w10)

    def w11(mir, door):
        ev = mir.sobytie('e.json', [item('scout', 'S1', ['SUBJECT=140', 'посмотри'])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'), k_stdout(r, 'PROPUST', 'выход'),
                k_net_startov(mir, 'учёт')]
    reg('w11-scout-propusk', 'роль=вне-классов;режим=любой', w11)

    def w12(mir, door):
        ev = mir.sobytie('e.json', [item('arbiter', 'Arb1', ['тупик процесса'])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'), k_stdout(r, 'PROPUST', 'выход'),
                k_net_startov(mir, 'учёт')]
    reg('w12-arbiter-propusk', 'роль=судья-процесса;режим=любой', w12)

    def _harness_zhivoj(mir, nnn_list):
        for nnn in nnn_list:
            wt, br, _ = mir.worktree(nnn)
            mir.start(nnn, 'Arch%s' % nnn, wt=wt, branch=br)
            mir.zhurnal('Arch%s' % nnn, sdal=False)

    def w13(mir, door):
        # слово владельца 2026-10-28: кап harness 1 → 3; отказ — на 3 из 3
        # занятых (граница «CAP занято → отказ LIMIT_GRUPPY»).
        _harness_zhivoj(mir, ['141', '142', '143'])
        wt, br, _ = mir.worktree('144')
        ev = mir.sobytie('e.json', [item('architect', 'Arch144',
                        ['SUBJECT=144', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'LIMIT_GRUPPY', 'причина')]
    reg('w13-limit-harness', 'учёт=лимит;группа=harness-3-из-3-занято', w13)

    def _mob_zhivoj(mir, nnn_list):
        for nnn in nnn_list:
            wt, br, _ = mir.worktree(nnn, remote=MOB_REMOTE)
            mir.start(nnn, 'Mob%s' % nnn, gruppa='mob', wt=wt, branch=br)
            mir.zhurnal('Mob%s' % nnn, sdal=False)

    def w14(mir, door):
        _mob_zhivoj(mir, ['150', '151'])
        wt, br, _ = mir.worktree('152', remote=MOB_REMOTE)
        ev = mir.sobytie('e.json', [item('implementer', 'Impl152',
                        ['SUBJECT=152', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'), k_stroka(mir, 'start', subjectId='152', group='mob')]
    reg('w14-limit-mob-tri-ok', 'учёт=лимит;группа=mob-3-в-лимите', w14)

    def w15(mir, door):
        _mob_zhivoj(mir, ['150', '151', '152'])
        wt, br, _ = mir.worktree('153', remote=MOB_REMOTE)
        ev = mir.sobytie('e.json', [item('implementer', 'Impl153',
                        ['SUBJECT=153', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'LIMIT_GRUPPY', 'причина')]
    reg('w15-limit-mob-chetyre', 'учёт=лимит;группа=mob-3-сверх', w15)

    def w16(mir, door):
        _mob_zhivoj(mir, ['150', '151', '152'])
        mir.slovo('153')
        wt, br, _ = mir.worktree('153', remote=MOB_REMOTE)
        ev = mir.sobytie('e.json', [item('implementer', 'Impl153',
                        ['SUBJECT=153', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'), k_stroka(mir, 'start', subjectId='153', group='mob')]
    reg('w16-limit-slovo', 'учёт=лимит;СЛОВО=владельца', w16)

    def w17(mir, door):
        # слово владельца 2026-10-28: кап harness 1 → 3 — при пустой группе
        # мир «один done» больше не упирается в лимит (стаб s17 проходил,
        # замер STAB_ZHIV); мир переведён на mob (кап не менялся): 2 живых +
        # done-освобождённый слот + новый = ровно CAP — done обязан освободить.
        _mob_zhivoj(mir, ['150', '151'])
        wt130, br130, _ = mir.worktree('130', remote=MOB_REMOTE)
        mir.start('130', 'Arch130', gruppa='mob', wt=wt130, branch=br130)
        mir.zhurnal('Arch130', sdal=True)
        mir.done('130')
        wt131, br131, _ = mir.worktree('131', remote=MOB_REMOTE)
        ev = mir.sobytie('e.json', [item('architect', 'Arch131',
                        ['SUBJECT=131', 'WORKTREE=' + wt131, 'BRANCH=' + br131])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc')]
    reg('w17-limit-done-osvobozhdaet', 'учёт=лимит;done=тег-реестра;группа=mob-2-живых', w17)

    def w18(mir, door):
        # как w17: ПАУЗА обязана освободить слот — мир на mob, 2 живых +
        # пауза + новый = ровно CAP (стаб s27 красен).
        _mob_zhivoj(mir, ['150', '151'])
        wt130, br130, _ = mir.worktree('130', remote=MOB_REMOTE)
        mir.start('130', 'Arch130', gruppa='mob', wt=wt130, branch=br130)
        mir.pauza('130')
        wt131, br131, _ = mir.worktree('131', remote=MOB_REMOTE)
        ev = mir.sobytie('e.json', [item('architect', 'Arch131',
                        ['SUBJECT=131', 'WORKTREE=' + wt131, 'BRANCH=' + br131])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc')]
    reg('w18-limit-pauza-osvobozhdaet', 'учёт=лимит;ПАУЗА=освобождает-слот;группа=mob-2-живых', w18)

    def w19(mir, door):
        wt, br, _ = mir.worktree('118', remote=MOB_REMOTE)
        ev = mir.sobytie('e.json', [item('implementer', 'Impl118',
                        ['SUBJECT=118', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'),
                k_stroka(mir, 'start', subjectId='118', holder='Impl118', group='mob')]
    reg('w19-gruppa-iz-pina', 'источник=git-remote;учёт=группа-предмета', w19)

    def w20(mir, door):
        # слово владельца 2026-10-28: кап harness 1 → 3; граница «ровно
        # CAP−1 занято → разрешено» (на двери v1 1/3/2 красна — 2 ≥ 1).
        _harness_zhivoj(mir, ['141', '142'])
        wt, br, _ = mir.worktree('143')
        ev = mir.sobytie('e.json', [item('architect', 'Arch143',
                        ['SUBJECT=143', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'),
                k_stroka(mir, 'start', subjectId='143', holder='Arch143', group='harness')]
    reg('w20-limit-harness-tri-ok', 'учёт=лимит;группа=harness-2-из-3-граница', w20)

    def _back_zhivoj(mir, nnn_list):
        for nnn in nnn_list:
            wt, br, _ = mir.worktree(nnn, remote=BACK_REMOTE)
            mir.start(nnn, 'Back%s' % nnn, gruppa='back', wt=wt, branch=br)
            mir.zhurnal('Back%s' % nnn, sdal=False)

    def w21(mir, door):
        # слово владельца 2026-10-28: кап back 2 → 3; граница «ровно CAP−1
        # занято → разрешено» (на двери v1 1/3/2 красна — 2 ≥ 2).
        _back_zhivoj(mir, ['160', '161'])
        wt, br, _ = mir.worktree('162', remote=BACK_REMOTE)
        ev = mir.sobytie('e.json', [item('implementer', 'Impl162',
                        ['SUBJECT=162', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'),
                k_stroka(mir, 'start', subjectId='162', holder='Impl162', group='back')]
    reg('w21-limit-back-tri-ok', 'учёт=лимит;группа=back-2-из-3-граница', w21)

    def w22(mir, door):
        # слово владельца 2026-10-28: кап back 2 → 3; отказ — на 3 из 3
        # занятых (граница «CAP занято → отказ LIMIT_GRUPPY»).
        _back_zhivoj(mir, ['160', '161', '162'])
        wt, br, _ = mir.worktree('163', remote=BACK_REMOTE)
        ev = mir.sobytie('e.json', [item('implementer', 'Impl163',
                        ['SUBJECT=163', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'LIMIT_GRUPPY', 'причина')]
    reg('w22-limit-back-chetyre', 'учёт=лимит;группа=back-3-из-3-занято', w22)

    # A2. сдача держателя без yield: событие рантайма session_exit (слово
    #     владельца 2026-11-12: omp 18.18.8 не даёт субагентам yield; замер
    #     12.11 по станции: 0 yield-литералов, 2516 session_exit normal /
    #     231 signal, все type=custom; маркер — структурные поля события,
    #     не подстрока)
    def w23(mir, door):
        # автор завершился НОРМАЛЬНО (последняя строка журнала — событие
        # session_exit kind=normal, yield-литерала нет) → сдача: ротация свободна
        wt, br, _ = mir.worktree('140')
        mir.start('140', 'Arch140', wt=wt, branch=br)
        mir.zhurnal_vyhod('Arch140', kind='normal')
        ev = mir.sobytie('e.json', [item('implementer', 'Impl140',
                        ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=wip/140/impl'])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'),
                k_stroka(mir, 'start', holder='Impl140', rol='implementer'),
                k_zanyat(mir, '140', 'Impl140', 'занятие')]
    reg('w23-posle-session-exit-novyj-rabochij', 'роль=рабочий;состояние=сдал-по-session-exit', w23)

    def w24(mir, door):
        # аварийный выход (kind=signal) — НЕ сдача: журнал свеж, дубль запрещён
        wt, br, _ = mir.worktree('140')
        mir.start('140', 'Arch140', wt=wt, branch=br)
        mir.zhurnal_vyhod('Arch140', kind='signal')
        ev = mir.sobytie('e.json', [item('architect', 'Arch140b',
                        ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'RABOCHIJ_ZHIV', 'причина'),
                k_chislo_startov(mir, 'учёт', 1)]
    reg('w24-session-exit-signal-ne-sdacha', 'роль=рабочий;состояние=аварийный-выход;дубль=живой', w24)

    def w25(mir, door):
        # ПОДДЕЛКА: литералы session_exit/normal — вложенные поля ЧУЖОГО
        # custom-события (тело записи, не событие завершения) → НЕ сдача:
        # маркер сдачи — структурные поля события рантайма, не подстрока
        wt, br, _ = mir.worktree('140')
        mir.start('140', 'Arch140', wt=wt, branch=br)
        mir.zhurnal_vyhod('Arch140', poddelka=True)
        ev = mir.sobytie('e.json', [item('architect', 'Arch140b',
                        ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'RABOCHIJ_ZHIV', 'причина'),
                k_chislo_startov(mir, 'учёт', 1)]
    reg('w25-poddelnyj-marker-ne-sdacha', 'роль=рабочий;состояние=бежит;сдача=подделка-в-теле-записи', w25)

    # A3. атомарность лимита ГРУППЫ между предметами × слот до done/ПАУЗЫ ×
    #     дедушка начатого (узлы А/Б ремонта 140: adversary v4 FAIL 1/2 на
    #     OBJECT 3572945e — гонка двух РАЗНЫХ NNN, 4 из 3; bootstrap 998 —
    #     11 начатых из 3, замена не пускалась; DIAGNOZ-2026-11-12 F/1.6)
    def w26(mir, door):
        # УЗЕЛ А: лимит группы обязан быть атомарен и МЕЖДУ разными предметами.
        # ДЕТЕРМИНИРОВАННАЯ чередуемость без lucky-timing: реестр пауз — FIFO
        # с пустым содержанием (семантика «нет пауз», как у отсутствующего
        # файла); держатель записи держит трубу открытой, поэтому каждое
        # чтение na_pauze() паркуется в read с наблюдаемым fd. Такт = закрыть
        # запись (EOF всем стоящим в read) и тут же открыть снова; такт
        # подаётся ТОЛЬКО когда каждая живая дверь стоит (fd на FIFO в её
        # дереве процессов). Единственная стоянка двери ДО её снимка группы —
        # na_pauze преплока; значит любой такт, отпускающий дверь ОТ СЧЁТА
        # (в цикле подсчёта занятости), застал вторую дверь ПОСЛЕ её снимка
        # либо вышедшей ⇒ оба снимка группы строго до обеих записей START —
        # дверь без межпредметной атомарности обязана пропустить ОБЕ (4 из 3),
        # дверь с атомарным решением группы — ровно одну. Меры независимые:
        # число принятых (rc 0) и строки START группы в ФАЙЛЕ учёта.
        _harness_zhivoj(mir, ['101', '102'])
        wt140, br140, _ = mir.worktree('140')
        wt141, br141, _ = mir.worktree('141')
        ev140 = mir.sobytie('ev140.json', [item('architect', 'Arch140',
                        ['SUBJECT=140', 'WORKTREE=' + wt140, 'BRANCH=' + br140])])
        ev141 = mir.sobytie('ev141.json', [item('architect', 'Arch141',
                        ['SUBJECT=141', 'WORKTREE=' + wt141, 'BRANCH=' + br141])])
        pauzy = mir.repo / 'registry' / 'pauzy.tsv'
        if pauzy.exists():
            pauzy.unlink()
        os.mkfifo(str(pauzy))
        r0 = os.open(str(pauzy), os.O_RDONLY | os.O_NONBLOCK)
        zap = [os.open(str(pauzy), os.O_WRONLY | os.O_NONBLOCK)]

        def potomki(koren):
            vidy, ochered = set(), [koren]
            while ochered:
                p = ochered.pop()
                if p in vidy:
                    continue
                vidy.add(p)
                for z in Path('/proc/%d/task' % p).glob('*/children'):
                    try:
                        tekst = z.read_text()
                    except OSError:
                        continue
                    ochered.extend(int(x) for x in tekst.split())
            return vidy

        def stoit(pid):
            for q in potomki(pid):
                try:
                    spisok = list(Path('/proc/%d/fd' % q).iterdir())
                except OSError:
                    continue
                for fd in spisok:
                    try:
                        if os.readlink(str(fd)) == str(pauzy):
                            return True
                    except OSError:
                        continue
            return False

        dv = [subprocess.Popen(
                  [BASH, str(door), '--sudit', '--sostojanie', str(mir.sost),
                   '--zhurnaly', str(mir.zhurnaly), '--repo', str(mir.repo), ev],
                  env=GIT_ENV, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                  text=True)
              for ev in (ev140, ev141)]
        problems = []
        kraj = time.time() + 60
        try:
            while True:
                zhivye = [p for p in dv if p.poll() is None]
                if not zhivye:
                    break
                if time.time() > kraj:
                    problems.append('гонка: двери не завершились за 60 с '
                                    '(rc %r)' % [p.poll() for p in dv])
                    for p in zhivye:
                        p.kill()
                    break
                if all(stoit(p.pid) for p in zhivye):
                    # такт: EOF всем стоящим; запись открывается тут же снова
                    os.close(zap[0])
                    zap[0] = os.open(str(pauzy), os.O_WRONLY | os.O_NONBLOCK)
                time.sleep(0.002)
        finally:
            vyhody = [p.communicate(timeout=30) for p in dv]
            for f in (zap[0], r0):
                try:
                    os.close(f)
                except OSError:
                    pass
        prinyato = sum(1 for p in dv if p.returncode == 0)
        if prinyato > 1:
            problems.append('гонка группы: принято обе двери (rc %r; stderr: '
                            '%r | %r)' % ([p.returncode for p in dv],
                                          vyhody[0][1].strip()[:100],
                                          vyhody[1][1].strip()[:100]))
        startov = len([x for x in mir.ledg()
                       if x.get('t') == 'START' and x.get('group') == 'harness'])
        if startov > CAP_HARNESS:
            problems.append('гонка группы: START harness %d > CAP %d (файл '
                            'учёта — независимая мера)' % (startov, CAP_HARNESS))
        return problems
    reg('w26-gonka-gruppy-dva-predmeta',
        'пакет=гонка-разных-предметов;учёт=лимит-группы-атомарен', w26)

    def w27(mir, door):
        # УЗЕЛ Б-1: рабочий СДАЛ (yield в журнале), замок снят --osvobodit
        # (строка RELEASE), предмет НЕ done и НЕ на ПАУЗЕ → слот группы
        # держится: «слот держит предмет до done или ПАУЗЫ» (инвариант 7);
        # при 3 из 3 занятых НОВЫЙ предмет отказывает LIMIT_GRUPPY.
        _harness_zhivoj(mir, ['101', '102'])
        wt103, br103, _ = mir.worktree('103')
        mir.start('103', 'Arch103', wt=wt103, branch=br103)
        mir.zhurnal('Arch103', sdal=True)
        mir.release('103', 'Arch103', 'yield')
        wt144, br144, _ = mir.worktree('144')
        ev = mir.sobytie('e.json', [item('architect', 'Arch144',
                        ['SUBJECT=144', 'WORKTREE=' + wt144, 'BRANCH=' + br144])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'LIMIT_GRUPPY', 'причина')]
    reg('w27-relis-slot-derzhit',
        'учёт=лимит;RELEASE=не-освобождает;состояние=сдал-без-done', w27)

    def w28(mir, door):
        # УЗЕЛ Б-2: группа сверхлимитна (5 начатых — grandfather-ситуация
        # 998: 11 из 3), предмет 141 НАЧАТ, его рабочий сдал, замок снят
        # RELEASE, предмет НЕ done → замена держателя = доведение начатого:
        # «сверх лимита начатые доводятся, новые не стартуют» (roles/
        # orchestrator §Начатое—до-конца п.2), «смена держателя не занимает
        # второй слот» (инвариант 7) → rc 0, START пишется, БЕЗ СЛОВА.
        _harness_zhivoj(mir, ['145', '146', '147', '148', '149'])
        wt141, br141, _ = mir.worktree('141')
        mir.start('141', 'Arch141', wt=wt141, branch=br141, zanyat=False)
        mir.zhurnal('Arch141', sdal=True)
        mir.release('141', 'Arch141', 'yield')
        ev = mir.sobytie('e.json', [item('architect', 'Arch141v2',
                        ['SUBJECT=141', 'WORKTREE=' + wt141, 'BRANCH=' + br141])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'),
                k_stroka(mir, 'start', subjectId='141', holder='Arch141v2',
                         group='harness'),
                k_zanyat(mir, '141', 'Arch141v2', 'занятие')]
    reg('w28-zamena-nachatogo-sverhlimit',
        'учёт=лимит;замена=держателя-начатого;сверхлимит=доводится', w28)

    def w29(mir, door):
        # контроль узла Б: дедушка не расползается — НОВЫЙ предмет (без
        # START) при сверхлимитной группе без СЛОВА отказывает; cap — верхняя
        # граница (инвариант 7), санкция на новый NNN — только СЛОВО.
        _harness_zhivoj(mir, ['145', '146', '147', '148'])
        wt150, br150, _ = mir.worktree('150')
        ev = mir.sobytie('e.json', [item('architect', 'Arch150',
                        ['SUBJECT=150', 'WORKTREE=' + wt150, 'BRANCH=' + br150])])
        r = sudit(door, mir, ev)
        novykh = len([x for x in mir.ledg()
                      if x.get('t') == 'START' and x.get('subjectId') == '150'])
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'LIMIT_GRUPPY', 'причина'),
                None if novykh == 0 else 'START предмета 150 написан (%d)' % novykh]
    reg('w29-novyj-sverhlimit-otkaz',
        'учёт=лимит;новый=сверхлимит-без-СЛОВА;отказ=LIMIT_GRUPPY', w29)

    def w30(mir, door):
        # УЗЕЛ Б-3 «blocked не освобождает» (roles/orchestrator §Начатое—до
        # —конца п.2а): рабочий ОБОРВАН (журнал молчит >TTL), --osvobodit
        # пишут RELEASE(broshen), предмет НЕ done → слот держится до done/
        # ПАУЗЫ: при 3 из 3 занятых новый предмет отказывает LIMIT_GRUPPY.
        _harness_zhivoj(mir, ['101', '102'])
        wt103, br103, _ = mir.worktree('103')
        mir.start('103', 'Arch103', wt=wt103, branch=br103)
        mir.zhurnal('Arch103', sdal=False, vozrast_min=BROSHEN_TTL_MIN + 30)
        mir.release('103', 'Arch103', 'broshen')
        wt144, br144, _ = mir.worktree('144')
        ev = mir.sobytie('e.json', [item('architect', 'Arch144',
                        ['SUBJECT=144', 'WORKTREE=' + wt144, 'BRANCH=' + br144])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'LIMIT_GRUPPY', 'причина')]
    reg('w30-blok-slot-derzhit',
        'учёт=лимит;RELEASE=broshen;blocked=не-освобождает', w30)

    def w31(mir, door):
        # МОДЕЛЬ 45ee1d24 закрыла гонку РАЗНЫХ процессов (D34), но ОДИН batch
        # с двумя НОВЫМИ NNN одной группы судился по ОДНОМУ учёту: START
        # пишутся после ворот ([D26]) — оба элемента видят «занято 2 из 3»
        # и проходят → 4 из 3. [D35]: счёт группы В ПАКЕТЕ — отказ ВСЕМУ
        # пакету без частичного START; контроль: та же ёмкость, один новый
        # проходит (отказ — не застрявший мьютекс, а перелимит пакета).
        _harness_zhivoj(mir, ['171', '172'])
        wt173, br173, _ = mir.worktree('173')
        wt174, br174, _ = mir.worktree('174')
        ev = mir.sobytie('e.json', [
            item('architect', 'Arch173', ['SUBJECT=173', 'WORKTREE=' + wt173, 'BRANCH=' + br173]),
            item('implementer', 'Impl174', ['SUBJECT=174', 'WORKTREE=' + wt174, 'BRANCH=' + br174])])
        r = sudit(door, mir, ev)
        problems = [k_rc(r, 1, 'rc'), k_prichina(r, 'LIMIT_GRUPPY', 'причина'),
                    k_chislo_startov(mir, 'учёт', 2),
                    k_svoboden(mir, '173', 'откат-173'),
                    k_svoboden(mir, '174', 'откат-174')]
        wt175, br175, _ = mir.worktree('175')
        ev2 = mir.sobytie('e2.json', [item('architect', 'Arch175',
                        ['SUBJECT=175', 'WORKTREE=' + wt175, 'BRANCH=' + br175])])
        r2 = sudit(door, mir, ev2)
        return problems + [k_rc(r2, 0, 'контроль-rc'),
                           k_stroka(mir, 'контроль-start', subjectId='175',
                                    group='harness')]
    reg('w31-paket-dva-novyh-otkaz-vsemu',
        'пакет=два-новых-одной-группы;учёт=счёт-пакетом;отказ=весь-пакет;контроль=один-новый-проходит', w31)

    # B. судьи: состояние автора × OBJECT × порядок судей × риск
    def _avtor_sdal(mir, nnn, risk='обычный'):
        # v+1: контракт лежит и в $REPO (main), и в ДЕРЕВЕ кандидата — мир
        # «источники согласны»; клетки расхождения (s39+) расщепляют их сами.
        mir.kontrakt(nnn, risk)
        tekst = '# К\nКЛАСС РИСКА: %s\n' % risk
        wt, br, sha = mir.worktree(nnn, kontrakty=[('fajl', '%s-stub.md' % nnn, tekst)])
        mir.start(nnn, 'Avtor%s' % nnn, wt=wt, branch=br)
        mir.zhurnal('Avtor%s' % nnn, sdal=True)
        return wt, br, sha

    def _verdikt_sudyi(mir, nnn, rol, sessiya, obj):
        # Настоящий ЗАКОММИЧЕННЫЙ вердикт судьи (гейты доказывания, контракт 167):
        # путь verdicts/<каталог роли>/contracts-<NNN>-v1.md, первая строка accept|FAIL,
        # самостоятельная строка OBJECT=<sha>, литеральные поля роль= и сессия= в строке
        # СУД:, автор коммита — роль. Круг судейства на (предмет, роль, OBJECT) тратит
        # именно такой вердикт.
        kat = 'review' if rol == 'reviewer' else rol
        p = mir.repo / 'verdicts' / kat / ('contracts-%s-v1.md' % nnn)
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text('FAIL\nOBJECT=%s\nСУД: repo=%s; предмет=%s; роль=%s; сессия=%s; модель-факт=fixture\n'
                     % (obj, REPO_ID, nnn, rol, sessiya), encoding='utf-8')
        mir.git(['add', '-A'])
        c = run(['git', '-c', 'user.name=%s' % rol, '-c', 'user.email=%s@dev-harness.local' % rol,
                 '-c', 'commit.gpgsign=false', 'commit', '-q', '-m', 'verdict %s' % nnn],
                cwd=str(mir.repo))
        assert c.returncode == 0, c.stderr

    def _avtor_sdal_fajly(mir, nnn, faily):
        # мир «неоднозначного источника класса риска» (вердикт адверсария 140
        # вызов 1/2): несколько contracts/<NNN>-*.md; faily — [(суффикс, риск|None)],
        # None = файл без строки КЛАСС РИСКА; автор сдал, OBJECT == tip ветки.
        kand = []
        for suf, risk in faily:
            if risk is None:
                tekst = '# К\n(без строки класса риска)\n'
            else:
                tekst = '# К\nКЛАСС РИСКА: %s\n' % risk
            f = mir.repo / 'contracts' / ('%s-%s.md' % (nnn, suf))
            f.write_text(tekst, encoding='utf-8')
            kand.append(('fajl', '%s-%s.md' % (nnn, suf), tekst))
        mir.git(['add', '-A'])
        mir.git(['commit', '-q', '-m', 'c%s' % nnn])
        wt, br, sha = mir.worktree(nnn, kontrakty=kand)
        mir.start(nnn, 'Avtor%s' % nnn, wt=wt, branch=br)
        mir.zhurnal('Avtor%s' % nnn, sdal=True)
        return wt, br, sha

    def _mater(imja):
        # строка материала без хвостового перевода строки (байты — из 9ec350f7e)
        t = (MATER / imja).read_text(encoding='utf-8')
        return t[:-1] if t.endswith('\n') else t

    def _avtor_sdal_stroki(mir, nnn, zapisi):
        # мир реальных форм декларации «КЛАСС РИСКА:» (РЕШЕНИЕ арбитража 140,
        # Q2/Q3): zapisi — [(имя, вид, данные)]; вид 'stroka'/'stroki' — файл
        # '# К\n' + строка/строки, 'symlink' — симлинк на данные (относительно
        # contracts/), 'dir' — каталог с именем NNN-*.md; затем add+commit,
        # автор сдал, OBJECT == tip ветки (как _avtor_sdal_fajly).
        kand = []
        for imja, vid, dannye in zapisi:
            p = mir.repo / 'contracts' / imja
            if vid == 'stroka':
                p.write_text('# К\n' + dannye + '\n', encoding='utf-8')
                kand.append(('fajl', imja, '# К\n' + dannye + '\n'))
            elif vid == 'stroki':
                p.write_text('# К\n' + '\n'.join(dannye) + '\n', encoding='utf-8')
                kand.append(('fajl', imja, '# К\n' + '\n'.join(dannye) + '\n'))
            elif vid == 'symlink':
                p.symlink_to(dannye)
                kand.append(('symlink', imja, dannye))
            elif vid == 'dir':
                p.mkdir()
                kand.append(('dir', imja, ''))
        mir.git(['add', '-A'])
        mir.git(['commit', '-q', '-m', 'c%s' % nnn])
        wt, br, sha = mir.worktree(nnn, kontrakty=kand)
        mir.start(nnn, 'Avtor%s' % nnn, wt=wt, branch=br)
        mir.zhurnal('Avtor%s' % nnn, sdal=True)
        return wt, br, sha

    def _podmir(prob):
        # подпространство для многовариантных клеток (s35/s36): свежий мир,
        # авто-уборка; prob(mir) → список проблем
        d = tempfile.mkdtemp(prefix='odin140-podmir-')
        try:
            return prob(Mir(d))
        finally:
            shutil.rmtree(d, ignore_errors=True)

    def s01(mir, door):
        wt, br, sha = _avtor_sdal(mir, '141')
        ev = mir.sobytie('e.json', [item('critic', 'Critic141',
                        ['суд контракта', 'SUBJECT=141', 'OBJECT=' + sha])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'),
                k_stroka(mir, 'start', subjectId='141', holder='Critic141', klass='sudja'),
                k_zanyat(mir, '141', 'Critic141', 'занятие')]
    reg('s01-sudja-posle-yield', 'роль=судья;состояние=автор-сдал;OBJECT=совпадает', s01)

    def s02(mir, door):
        wt, br, sha = _avtor_sdal(mir, '141')
        wt2, br2, _ = mir.worktree('141')
        mir.start('141', 'Avtor141b', wt=wt2, branch=br2)   # второй живой рабочий — замок жив
        mir.zhurnal('Avtor141b', sdal=False)
        ev = mir.sobytie('e.json', [item('critic', 'Critic141',
                        ['SUBJECT=141', 'OBJECT=' + sha])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'RABOCHIJ_ZHIV', 'причина')]
    reg('s02-kritik-pri-zhivom-rabochem', 'роль=судья;состояние=рабочий-бежит;источник=замок', s02)

    def s03(mir, door):
        wt, br, sha = _avtor_sdal(mir, '141')
        ev = mir.sobytie('e.json', [item('critic', 'Critic141',
                        ['SUBJECT=141', 'OBJECT=' + OBJECT_DUMMY])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'OBJECT_RASHODITSJA', 'причина')]
    reg('s03-object-rashoditsja', 'OBJECT=чужой-sha', s03)

    def s04(mir, door):
        _avtor_sdal(mir, '141')
        ev = mir.sobytie('e.json', [item('critic', 'Critic141',
                        ['SUBJECT=141', 'без строки объекта'])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'OBJECT_OTSTUTSVUET', 'причина')]
    reg('s04-object-net', 'OBJECT=отсутствует', s04)

    def s05(mir, door):
        wt, br, sha = _avtor_sdal(mir, '141')
        mir.start('141', 'Critic141', klass='sudja', rol='critic',
                  gruppa='harness', obj=sha)
        mir.zhurnal('Critic141', sdal=False)
        ev = mir.sobytie('e.json', [item('reviewer', 'Rev141',
                        ['SUBJECT=141', 'OBJECT=' + sha])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'SUDJA_ZHIV', 'причина')]
    reg('s05-vtoroj-sudja-zhiv', 'роль=судья;дубль=живой-судья', s05)

    def s06(mir, door):
        wt, br, sha = _avtor_sdal(mir, '141')
        mir.start('141', 'Critic141', klass='sudja', rol='critic', obj=sha)
        mir.zhurnal('Critic141', sdal=True)
        # Контракт 167: круг судейства на (предмет, роль, OBJECT) тратит
        # ЗАКОММИЧЕННЫЙ вердикт роли/сессии/OBJECT — прежний отрицательный
        # инвариант D11 держится на настоящем вердикте, а не на одном START.
        _verdikt_sudyi(mir, '141', 'critic', 'Critic141', sha)
        ev = mir.sobytie('e.json', [item('critic', 'Critic141b',
                        ['SUBJECT=141', 'OBJECT=' + sha])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'OBJECT_UZHE_SUZHEN', 'причина')]
    reg('s06-object-uzhe-suzhen', 'OBJECT=повтор-того-же-sha', s06)

    def s07(mir, door):
        wt, br, sha = _avtor_sdal(mir, '141')
        mir.start('141', 'Critic141', klass='sudja', rol='critic', obj=sha)
        mir.zhurnal('Critic141', sdal=True)
        sha2 = mir.amend('141')
        ev = mir.sobytie('e.json', [item('critic', 'Critic141b',
                        ['SUBJECT=141', 'OBJECT=' + sha2])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'), k_stroka(mir, 'start', holder='Critic141b', klass='sudja')]
    reg('s07-ispravitelnyj-novyj-object', 'OBJECT=новый-sha-после-правки', s07)

    def s08(mir, door):
        mir.kontrakt('141')
        ev = mir.sobytie('e.json', [item('critic', 'Critic141',
                        ['SUBJECT=141', 'OBJECT=' + OBJECT_DUMMY])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'RABOCHEGO_NET', 'причина')]
    reg('s08-rabochego-net', 'состояние=автора-нет', s08)

    def s09(mir, door):
        wt, br, sha = _avtor_sdal(mir, '141', risk='рисковый')
        ev = mir.sobytie('e.json', [item('reviewer', 'Rev141',
                        ['SUBJECT=141', 'OBJECT=' + sha])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'ADVERSARIJ_DO_REVJUERA', 'причина')]
    reg('s09-adv-do-rev', 'риск=рисковый;порядок=ревьюер-раньше', s09)

    def s10(mir, door):
        wt, br, sha = _avtor_sdal(mir, '141', risk='рисковый')
        mir.start('141', 'Adv141', klass='sudja', rol='adversary', obj=sha)
        mir.zhurnal('Adv141', sdal=True)
        ev = mir.sobytie('e.json', [item('reviewer', 'Rev141',
                        ['SUBJECT=141', 'OBJECT=' + sha])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'), k_stroka(mir, 'start', holder='Rev141', rol='reviewer')]
    reg('s10-adv-do-rev-zakryt', 'риск=рисковый;порядок=адверсарий-сдал', s10)

    def s11(mir, door):
        wt, br, sha = _avtor_sdal(mir, '141', risk='обычный')
        ev = mir.sobytie('e.json', [item('reviewer', 'Rev141',
                        ['SUBJECT=141', 'OBJECT=' + sha])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc')]
    reg('s11-obychnyj-bez-adv', 'риск=обычный;порядок=без-адверсария', s11)

    def s12(mir, door):
        mir.kontrakt('141')
        wt, br, sha = mir.worktree('141')
        mir.start('141', 'Avtor141', wt=wt, branch=br)
        mir.zhurnal('Avtor141', sdal=True)
        shutil.rmtree(wt)
        ev = mir.sobytie('e.json', [item('critic', 'Critic141',
                        ['SUBJECT=141', 'OBJECT=' + sha])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'VETKA_NEDOSTUPNA', 'причина')]
    reg('s12-vetka-nedostupna', 'OBJECT=ветка-утеряна', s12)

    def s13(mir, door):
        # мир согласных источников: файл без строки — и в $REPO, и в ДЕРЕВЕ
        # кандидата (v+1 судит кандидата); риск не определён — fail-closed
        f = mir.repo / 'contracts' / '141-stub.md'
        f.write_text('# К\n(без строки класса риска)\n', encoding='utf-8')
        mir.git(['add', '-A'])
        mir.git(['commit', '-q', '-m', 'c141'])
        wt, br, sha = mir.worktree('141', kontrakty=[
            ('fajl', '141-stub.md', '# К\n(без строки класса риска)\n')])
        mir.start('141', 'Avtor141', wt=wt, branch=br)
        mir.zhurnal('Avtor141', sdal=True)
        ev = mir.sobytie('e.json', [item('critic', 'Critic141',
                        ['SUBJECT=141', 'OBJECT=' + sha])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'KLASS_RISKA_NET', 'причина')]
    reg('s13-klass-riska-net', 'риск=строки-нет', s13)

    def s14(mir, door):
        wt, br, _ = mir.worktree('139')
        ev = mir.sobytie('e.json', [item('architect', 'Arch140',
                        ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'RASHOZHDENIE_PINA', 'причина')]
    reg('s14-pin-rashozhdenie', 'форма=пин-расходится-с-предметом', s14)

    # B2. источник класса риска: несколько contracts/<NNN>-*.md (D29; вердикт
    #     адверсария 140 вызов 1/2: «первый результат find» пропускал рисковый
    #     предмет как обычный) — конфликт/нет строки/согласие/мир шести файлов
    def _revjuer(mir, sha):
        return mir.sobytie('e.json', [item('reviewer', 'Rev141',
                        ['SUBJECT=141', 'OBJECT=' + sha])])

    def s23(mir, door):
        # [D29] конфликт значений: 141-a обычный, 141-b рисковый — ревьюер без
        # адверсария обязан получить отказ, а не «класс по одному файлу»
        wt, br, sha = _avtor_sdal_fajly(mir, '141', [('a', 'обычный'), ('b', 'рисковый')])
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'KLASS_RISKA_NET', 'причина'),
                k_chislo_startov(mir, 'учёт', 1)]
    reg('s23-klass-riska-konflikt-ab', 'риск=два-файла;значения=обычный+рисковый', s23)

    def s24(mir, door):
        # [D29] тот же конфликт с обратным порядком имён (a рисковый, b обычный):
        # порядок обхода файлов не должен влиять на вердикт
        wt, br, sha = _avtor_sdal_fajly(mir, '141', [('a', 'рисковый'), ('b', 'обычный')])
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'KLASS_RISKA_NET', 'причина'),
                k_chislo_startov(mir, 'учёт', 1)]
    reg('s24-klass-riska-konflikt-ba', 'риск=два-файла;значения=рисковый+обычный', s24)

    def s25(mir, door):
        # [D29] два файла, у одного нет строки — источник класса риска нечитаем.
        # Имена b/c: sorted-first и (на ext4 этой станции) find-first без
        # сортировки — ОДИН и тот же файл 141-b.md СО строкой: и стаб s28
        # (sort|sed -n 1p), и дефектная дверь 73aa92b7a (голый find) читают
        # файл со строкой и молча пропускают бесстрочный 141-c.md
        # (замер пачки: BC_PERVYJ=141-b.md)
        wt, br, sha = _avtor_sdal_fajly(mir, '141', [('b', 'обычный'), ('c', None)])
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'KLASS_RISKA_NET', 'причина'),
                k_chislo_startov(mir, 'учёт', 1)]
    reg('s25-klass-riska-net-stroki-vo-vtorom', 'риск=два-файла;строка=нет-во-втором', s25)

    def s26(mir, door):
        # два СОГЛАСНЫХ рисковых — прежнее поведение: адверсарий до ревьюера
        wt, br, sha = _avtor_sdal_fajly(mir, '141', [('a', 'рисковый'), ('b', 'рисковый')])
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'ADVERSARIJ_DO_REVJUERA', 'причина')]
    reg('s26-klass-riska-dva-soglasny-riskovye', 'риск=два-согласных-рисковых;порядок=ревьюер-раньше', s26)

    def s27(mir, door):
        # два СОГЛАСНЫХ обычных — прежнее поведение: ревьюер без адверсария проходит
        wt, br, sha = _avtor_sdal_fajly(mir, '141', [('a', 'обычный'), ('b', 'обычный')])
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 0, 'rc'), k_stroka(mir, 'start', holder='Rev141', rol='reviewer')]
    reg('s27-klass-riska-dva-soglasny-obychnye', 'риск=два-согласных-обычных;порядок=без-адверсария', s27)

    def s28(mir, door):
        # мир адверсария (semantic_attacks.py): шесть файлов 141-a…f, один
        # рисковый — класс неопределён, отказ, а не класс по случайно первому
        wt, br, sha = _avtor_sdal_fajly(mir, '141', [
            ('a', 'обычный'), ('b', 'рисковый'), ('c', 'обычный'),
            ('d', 'обычный'), ('e', 'обычный'), ('f', 'обычный')])
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'KLASS_RISKA_NET', 'причина'),
                k_chislo_startov(mir, 'учёт', 1)]
    reg('s28-klass-riska-shest-fajlov', 'риск=шесть-файлов;один=рисковый', s28)

    # B3. реальные формы декларации «КЛАСС РИСКА:» (РЕШЕНИЕ арбитража 140 от
    #     2026-10-26: поставленная дверь 9ec350f7e читала «^КЛАСС РИСКА:» +
    #     cut -d' ' -f1 и ложно отказывала KLASS_RISKA_NET по 4 из 7 реальных
    #     контрактов со строкой — 116/139/140/141; грамматика Q2: декларация
    #     в любой позиции строки, [[:blank:]]* + {обычный|рисковый} +
    #     терминатор {EOL, blank, '.', ',', ';'}, хвост-основание допустим,
    #     иные вхождения — упоминания; ровно ОДНА декларация на файл; канон —
    #     все записи find -maxdepth 1 -name '<NNN>-*.md' БЕЗ -type f)
    def s29(mir, door):
        # байт-копия 116:2 при 9ec350f7e (декларация в середине строки после
        # «КЛАСС ЗАДАЧИ: …», хвост « (…») — обычный: ревьюер проходит
        wt, br, sha = _avtor_sdal_stroki(mir, '141',
                        [('141-a.md', 'stroka', _mater('116-stroka.md'))])
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 0, 'rc'),
                k_stroka(mir, 'start', holder='Rev141', rol='reviewer')]
    reg('s29-klass-riska-realnaja-116', 'риск=реальная-форма-116;декларация=середина-строки;хвост-основание', s29)

    def s30(mir, door):
        # байт-копия 139:3 (середина строки, «обычный.» вплотную — точка из
        # списка терминаторов Q2) — обычный: ревьюер проходит
        wt, br, sha = _avtor_sdal_stroki(mir, '141',
                        [('141-a.md', 'stroka', _mater('139-stroka.md'))])
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 0, 'rc'),
                k_stroka(mir, 'start', holder='Rev141', rol='reviewer')]
    reg('s30-klass-riska-realnaja-139', 'риск=реальная-форма-139;терминатор=точка-вплотную', s30)

    def s31(mir, door):
        # ПОЛНЫЙ текст contracts/140 при 9ec350f7e как единственный файл
        # предмета (в $REPO и в ДЕРЕВЕ кандидата — байт-в-байт): декларация
        # 140:3 (рисковый, середина строки) + упоминание 140:51 в бэктиках;
        # ревьюер до адверсария отказан, после yield адверсария проходит
        # (конвенция s09/s10 — двухшаговая клетка)
        tekst = (MATER / '140-celkom.md').read_text(encoding='utf-8')
        (mir.repo / 'contracts' / '141-a.md').write_text(tekst, encoding='utf-8')
        mir.git(['add', '-A'])
        mir.git(['commit', '-q', '-m', 'c141'])
        wt, br, sha = mir.worktree('141', kontrakty=[('fajl', '141-a.md', tekst)])
        mir.start('141', 'Avtor141', wt=wt, branch=br)
        mir.zhurnal('Avtor141', sdal=True)
        r1 = sudit(door, mir, _revjuer(mir, sha))
        mir.start('141', 'Adv141', klass='sudja', rol='adversary', obj=sha)
        mir.zhurnal('Adv141', sdal=True)
        r2 = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r1, 1, 'rc-до-адверсария'),
                k_prichina(r1, 'ADVERSARIJ_DO_REVJUERA', 'причина-до'),
                k_rc(r2, 0, 'rc-после-адверсария'),
                k_stroka(mir, 'start', holder='Rev141', rol='reviewer')]
    reg('s31-klass-riska-realnaja-140', 'риск=реальный-контракт-140-целиком;упоминание-в-тексте;порядок=два-шага', s31)

    def s32(mir, door):
        # байт-копия 118:3 (начало строки, хвост « — основание…») — рисковый:
        # ревьюер раньше адверсария отказан
        wt, br, sha = _avtor_sdal_stroki(mir, '141',
                        [('141-a.md', 'stroka', _mater('118-stroka.md'))])
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'ADVERSARIJ_DO_REVJUERA', 'причина')]
    reg('s32-klass-riska-realnaja-118', 'риск=реальная-форма-118;декларация=начало-строки-с-хвостом', s32)

    def s33(mir, door):
        # две ОДИНАКОВЫЕ декларации в одном файле — не одна декларация (Q2:
        # ровно одна на файл): неоднозначно, отказ
        wt, br, sha = _avtor_sdal_stroki(mir, '141',
                        [('141-a.md', 'stroki', ['КЛАСС РИСКА: обычный',
                                                'КЛАСС РИСКА: обычный'])])
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'KLASS_RISKA_NET', 'причина'),
                k_chislo_startov(mir, 'учёт', 1)]
    reg('s33-klass-riska-dve-deklaracii-odinakovye', 'риск=две-декларации-в-файле;значения=одинаковые', s33)

    def s34(mir, door):
        # упоминание без декларации (бэктик после двоеточия — значения из
        # алфавита нет) — не декларация: класса нет, отказ
        wt, br, sha = _avtor_sdal_stroki(mir, '141',
                        [('141-a.md', 'stroka', 'строка `КЛАСС РИСКА:` обязательна')])
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'KLASS_RISKA_NET', 'причина'),
                k_chislo_startov(mir, 'учёт', 1)]
    reg('s34-klass-riska-upominanie-bez-deklaracii', 'риск=упоминание-без-декларации', s34)

    def s35(mir, door):
        # значение вне алфавита («средний») и слипшееся слово («обычныйX»):
        # терминатора из списка нет — упоминание, класса нет; каждый вход
        # красен СВОИМ предъявлением (два подпространства)
        prob = []
        for stroka in ('КЛАСС РИСКА: средний — основание',
                       'КЛАСС РИСКА: обычныйX'):
            def odin(m, stroka=stroka):
                wt, br, sha = _avtor_sdal_stroki(m, '141',
                                [('141-a.md', 'stroka', stroka)])
                r = sudit(door, m, _revjuer(m, sha))
                return [k_rc(r, 1, 'rc'), k_prichina(r, 'KLASS_RISKA_NET', 'причина'),
                        k_chislo_startov(m, 'учёт', 1)]
            for p in _podmir(odin):
                if p:
                    prob.append('s35 %r: %s' % (stroka, p))
        return prob
    reg('s35-klass-riska-vne-alfavita', 'риск=значение-вне-алфавита;форма=средний+слипшееся', s35)

    def s36(mir, door):
        # канон без -type f (РЕШЕНИЕ (г)): живой симлинк на «рисковый»
        # читается → конфликт; битый симлинк/каталог с именем NNN-*.md —
        # нечитаемая запись → вне алфавита; все три → neodnoznachno → отказ
        def zapisi(dannye):
            zap = [('141-a.md', 'stroka', 'КЛАСС РИСКА: обычный')]
            if dannye == 'symlink-risk':
                return zap + [('risk-source.md', 'stroka', 'КЛАСС РИСКА: рисковый'),
                              ('141-b.md', 'symlink', 'risk-source.md')]
            if dannye == 'symlink-bityj':
                return zap + [('141-b.md', 'symlink', 'net-takogo.md')]
            return zap + [('141-b.md', 'dir', '')]
        prob = []
        for dannye in ('symlink-risk', 'symlink-bityj', 'dir'):
            def odin(m, dannye=dannye):
                wt, br, sha = _avtor_sdal_stroki(m, '141', zapisi(dannye))
                r = sudit(door, m, _revjuer(m, sha))
                return [k_rc(r, 1, 'rc'), k_prichina(r, 'KLASS_RISKA_NET', 'причина'),
                        k_chislo_startov(m, 'учёт', 1)]
            for p in _podmir(odin):
                if p:
                    prob.append('s36 %s: %s' % (dannye, p))
        return prob
    reg('s36-klass-riska-simlink', 'риск=не-файл-в-каноне;форма=симлинк-живой+битый+каталог', s36)

    def s37(mir, door):
        # цитата шаблона «рисковый|обычный» — упоминание (после «рисковый»
        # в цитате нет терминатора из списка); декларация обычного в середине
        # строки читается, цитата игнорируется — ревьюер проходит
        stroka = ('КЛАСС ЗАДАЧИ: КОДОВЫЙ (мир батареи 140). КЛАСС РИСКА: обычный'
                  ' — см. «КЛАСС РИСКА: рисковый|обычный»')
        wt, br, sha = _avtor_sdal_stroki(mir, '141',
                        [('141-a.md', 'stroka', stroka)])
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 0, 'rc'),
                k_stroka(mir, 'start', holder='Rev141', rol='reviewer')]
    reg('s37-klass-riska-citata-shablona', 'риск=цитата-шаблона;упоминание=в-цитате;декларация=одна', s37)

    def s22(mir, door):
        mir.kontrakt('141')
        wt, br, sha = mir.worktree('141')
        mir.start('141', 'Avtor141', wt=wt, branch=br)
        mir.zhurnal('Avtor141', sdal=False)
        # замок снят вручную (консультант), автор жив: судья обязан отказать ПО ЖУРНАЛУ
        zd = mir.sost / 'zamki' / REPO_ID / '141' / 'zanyat'
        shutil.rmtree(zd, ignore_errors=True)
        mir.release('141', 'Avtor141')
        ev = mir.sobytie('e.json', [item('critic', 'Critic141',
                        ['SUBJECT=141', 'OBJECT=' + sha])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'AVTOR_ESHCHO_RABOTAET', 'причина')]
    reg('s22-avtor-zhiv-bez-zamka', 'роль=судья;состояние=автор-бежит;источник=журнал', s22)

    # B4. сдача автора по session_exit: судейские ворота D10 читают то же
    #     состояние держателя (без yield-литерала в журнале)
    def s38(mir, door):
        mir.kontrakt('141')
        tekst = '# К\nКЛАСС РИСКА: обычный\n'
        wt, br, sha = mir.worktree('141', kontrakty=[('fajl', '141-stub.md', tekst)])
        mir.start('141', 'Avtor141', wt=wt, branch=br)
        mir.zhurnal_vyhod('Avtor141', kind='normal')
        ev = mir.sobytie('e.json', [item('critic', 'Critic141',
                        ['SUBJECT=141', 'OBJECT=' + sha])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'),
                k_stroka(mir, 'start', subjectId='141', holder='Critic141', klass='sudja'),
                k_zanyat(mir, '141', 'Critic141', 'занятие')]
    reg('s38-sudja-posle-session-exit', 'роль=судья;состояние=автор-сдал-по-session-exit;OBJECT=совпадает', s38)

    # B5. источник класса риска — ДЕРЕВО OBJECT кандидата, не $REPO (main)
    #     (слово владельца 2026-11-12, Sol S2 §2.1; боль 991 v3: «рисковый»
    #     в main против «обычный» в кандидате молча отказывала KLASS_RISKA_NET)
    def _avtor_sdal_raznost(mir, nnn, risk_main, risk_kand, imja=None):
        # мир расхождения источников: $REPO декларирует risk_main, ДЕРЕВО
        # кандидата — risk_kand (один файл; None = без строки класса)
        imja = imja or ('%s-stub.md' % nnn)
        mir.kontrakt(nnn, risk_main)
        if risk_kand is None:
            tekst = '# К\n(без строки класса риска)\n'
        else:
            tekst = '# К\nКЛАСС РИСКА: %s\n' % risk_kand
        wt, br, sha = mir.worktree(nnn, kontrakty=[('fajl', imja, tekst)])
        mir.start(nnn, 'Avtor%s' % nnn, wt=wt, branch=br)
        mir.zhurnal('Avtor%s' % nnn, sdal=True)
        return wt, br, sha

    def s39(mir, door):
        # main «рисковый» / кандидат «обычный» → класс кандидата: ревьюер
        # без адверсария проходит (боль 991 v3: дверь отказывала по main)
        wt, br, sha = _avtor_sdal_raznost(mir, '141', 'рисковый', 'обычный')
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 0, 'rc'),
                k_stroka(mir, 'start', holder='Rev141', rol='reviewer')]
    reg('s39-main-riskovyj-kandidat-obychnyj', 'риск=main-рисковый;кандидат=обычный;порядок=без-адверсария', s39)

    def s40(mir, door):
        # обратная пара: main «обычный» / кандидат «рисковый» → рисковый:
        # ревьюер раньше адверсария отказан (по main молча прошёл бы)
        wt, br, sha = _avtor_sdal_raznost(mir, '141', 'обычный', 'рисковый')
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'ADVERSARIJ_DO_REVJUERA', 'причина'),
                k_chislo_startov(mir, 'учёт', 1)]
    reg('s40-main-obychnyj-kandidat-riskovyj', 'риск=main-обычный;кандидат=рисковый;порядок=ревьюер-раньше', s40)

    def s41(mir, door):
        # у кандидата строки нет, blob в реестре не записан → класс не
        # определён ОТ КАНДИДАТА, даже при согласном main: fail-closed
        wt, br, sha = _avtor_sdal_raznost(mir, '141', 'обычный', None)
        ev = mir.sobytie('e.json', [item('critic', 'Critic141',
                        ['SUBJECT=141', 'OBJECT=' + sha])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'KLASS_RISKA_NET', 'причина'),
                k_chislo_startov(mir, 'учёт', 1)]
    reg('s41-kandidat-bez-stroki', 'риск=main-обычный;кандидат=строки-нет;реестр=нет-записи', s41)

    def s42(mir, door):
        # старый frozen без строки: класс по blob ДЕРЕВА кандидата из
        # registry/risk-legacy.tsv ($REPO — реестр владельца, 0814d2f5a);
        # main-текст «рисковый» источником не является
        wt, br, sha = _avtor_sdal_raznost(mir, '141', 'рисковый', None)
        mir.risk_legacy(mir.blob_kandidata('141', '141-stub.md'), 'обычный')
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 0, 'rc'),
                k_stroka(mir, 'start', holder='Rev141', rol='reviewer')]
    reg('s42-risk-legacy-blob-kandidata', 'риск=main-рисковый;кандидат=строки-нет;реестр=blob-кандидата-обычный', s42)

    def s43(mir, door):
        # класс — из ДЕРЕВА OBJECT, не из грязного рабочего каталога автора:
        # незакоммиченная правка контракта в worktree («обычный») не отменяет
        # «рисковый» в судимом дереве
        wt, br, sha = _avtor_sdal_raznost(mir, '141', 'обычный', 'рисковый')
        (mir.root / 'wt141' / 'contracts' / '141-stub.md').write_text(
            '# К\nКЛАСС РИСКА: обычный\n', encoding='utf-8')
        r = sudit(door, mir, _revjuer(mir, sha))
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'ADVERSARIJ_DO_REVJUERA', 'причина'),
                k_chislo_startov(mir, 'учёт', 1)]
    reg('s43-klass-iz-dereva-ne-gryazi', 'риск=дерево-рисковый;рабочий-каталог=грязный-обычный;main=обычный', s43)

    def s44(mir, door):
        # отказ класса не расходует пакет: main согласован («обычный» оба
        # файла), кандидат конфликтен (обычный+рисковый) → KLASS_RISKA_NET,
        # НИ одного нового START, замки не поставлены, мьютексы сняты
        for imja in ('141-a.md', '141-b.md'):
            (mir.repo / 'contracts' / imja).write_text(
                '# К\nКЛАСС РИСКА: обычный\n', encoding='utf-8')
        mir.git(['add', '-A'])
        mir.git(['commit', '-q', '-m', 'c141'])
        zapisi = [('fajl', '141-a.md', '# К\nКЛАСС РИСКА: обычный\n'),
                  ('fajl', '141-b.md', '# К\nКЛАСС РИСКА: рисковый\n')]
        wt141, br141, sha141 = mir.worktree('141', kontrakty=zapisi)
        mir.start('141', 'Avtor141', wt=wt141, branch=br141)
        mir.zhurnal('Avtor141', sdal=True)
        wt142, br142, _ = mir.worktree('142')
        ev = mir.sobytie('e.json', [
            item('critic', 'Critic141', ['SUBJECT=141', 'OBJECT=' + sha141]),
            item('architect', 'Arch142', ['SUBJECT=142', 'WORKTREE=' + wt142, 'BRANCH=' + br142])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'KLASS_RISKA_NET', 'причина'),
                k_chislo_startov(mir, 'учёт', 1),
                k_zanyat(mir, '141', 'Avtor141', 'замок-141-при-авторе'),
                k_svoboden(mir, '142', 'откат-142')]
    reg('s44-klass-otkaz-bez-starta', 'пакет=смешанный;отказ=KLASS_RISKA_NET;откат=без-START-и-замков', s44)

    # C. пакет: дубль в пакете × откат × гонка × режим
    def b01(mir, door):
        wt141, br141, _ = mir.worktree('141')
        wt142, br142, _ = mir.worktree('142')
        ev = mir.sobytie('e.json', [
            item('architect', 'Arch141', ['SUBJECT=141', 'WORKTREE=' + wt141, 'BRANCH=' + br141]),
            item('architect', 'Arch142', ['SUBJECT=142', 'WORKTREE=' + wt142, 'BRANCH=' + br142])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'), k_chislo_startov(mir, 'учёт', 2),
                k_zanyat(mir, '141', 'Arch141', 'занятие-141'),
                k_zanyat(mir, '142', 'Arch142', 'занятие-142')]
    reg('b01-paket-dva-predmeta', 'пакет=разные-предметы', b01)

    def b02(mir, door):
        wt, br, _ = mir.worktree('140')
        ev = mir.sobytie('e.json', [
            item('architect', 'Arch140', ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br]),
            item('architect', 'Arch140b', ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'DUBL_V_PAKETE', 'причина'),
                k_net_startov(mir, 'учёт'), k_svoboden(mir, '140', 'занятие')]
    reg('b02-dubl-v-pakete', 'пакет=один-предмет-дважды', b02)

    def b03(mir, door):
        wt141, br141, _ = mir.worktree('141')
        mir.kontrakt('150')
        ev = mir.sobytie('e.json', [
            item('architect', 'Arch141', ['SUBJECT=141', 'WORKTREE=' + wt141, 'BRANCH=' + br141]),
            item('critic', 'Critic150', ['SUBJECT=150', 'OBJECT=' + OBJECT_DUMMY])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'RABOCHEGO_NET', 'причина'),
                k_net_startov(mir, 'учёт-пакет-откат'), k_svoboden(mir, '141', 'откат-141')]
    reg('b03-smeshannyj-otkat', 'пакет=смешанный;отказ=всему-пакету', b03)

    def b04(mir, door):
        wt, br, _ = mir.worktree('140')
        ev = mir.sobytie('e.json', [item('architect', 'Arch140',
                        ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        import concurrent.futures
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as ex:
            f1 = ex.submit(sudit, door, mir, ev)
            f2 = ex.submit(sudit, door, mir, ev)
            r1, r2 = f1.result(), f2.result()
        ok = sorted([r1.returncode, r2.returncode])
        if ok != [0, 1]:
            return ['гонка: исходы %r ≠ [0, 1] (stderr: %r | %r)' % (
                ok, r1.stderr.strip()[:80], r2.stderr.strip()[:80])]
        return [k_chislo_startov(mir, 'учёт-гонка', 1),
                k_zanyat(mir, '140', 'Arch140', 'занятие-гонка')]
    reg('b04-gonka-dva-protsessa', 'пакет=гонка-двух-процессов;замок=атомарность', b04)

    def b05(mir, door):
        wt, br, sha = _avtor_sdal(mir, '141')
        it = item('critic', 'Critic141', ['SUBJECT=141', 'OBJECT=' + sha])
        ev1 = mir.sobytie('e1.json', [it])
        it2 = dict(it)
        it2['isolated'] = True
        ev2 = mir.sobytie('e2.json', [it2])
        r1 = sudit(door, mir, ev1)
        sha_deref = mir.zanyat_holder('141')
        zd = mir.sost / 'zamki' / REPO_ID / '141' / 'zanyat'
        shutil.rmtree(zd, ignore_errors=True)
        # Освобождение СУДЬИ: причина, которую дверь пишет для судьи без
        # закоммиченного вердикта (контракт 167) — такой release не тратит круг
        # D11, и повторный круг судьи на том же OBJECT допустим (инвариант
        # клетки: изолированный режим не меняет вердикт).
        mir.release('141', 'Critic141', 'obryv_bez_verdikta')
        r2 = sudit(door, mir, ev2)
        if r1.returncode != r2.returncode:
            return ['изолированный режим меняет вердикт: %d vs %d (%r | %r)' % (
                r1.returncode, r2.returncode, r1.stderr[:80], r2.stderr[:80])]
        return [k_rc(r1, 0, 'rc-обычный'), k_rc(r2, 0, 'rc-изолированный'),
                None if sha_deref else 'занятие не создано']
    reg('b05-izolirovannyj-invariant', 'режим=изолированный/нет;инвариант=вердикт', b05)

    def b06(mir, door):
        wt141, br141, _ = mir.worktree('141')
        ev = mir.sobytie('e.json', [
            item('architect', 'Arch141', ['SUBJECT=141', 'WORKTREE=' + wt141, 'BRANCH=' + br141]),
            item('scout', 'S1', ['рядом смотрит'])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'), k_chislo_startov(mir, 'учёт', 1),
                k_stroka(mir, 'start', holder='Arch141')]
    reg('b06-paket-rabochij-plus-scout', 'пакет=рабочий+не-гейт-роль', b06)

    # D. учёт/сторож
    def u01(mir, door):
        mir.kontrakt('141')
        mir.start('141', 'Arch141')
        mir.zhurnal('Arch141', sdal=False)
        mir.start('142', 'Impl142', rol='implementer')
        mir.zhurnal('Impl142', sdal=True)
        mir.start('143', 'Arch143')
        mir.pauza('143')
        mir.start('144', 'Impl144', rol='implementer')
        mir.done('144')
        r = uchet(door, mir)
        lines = [l for l in r.stdout.splitlines() if l.startswith('UCHET\t')]
        want = {
            '142': ('harness', 'Impl142', 'rabochij', 'yield'),
            '143': ('harness', 'Arch143', 'rabochij', 'pauza'),
            '144': ('harness', 'Impl144', 'rabochij', 'done'),
        }
        seen = {}
        bad = []
        for l in lines:
            p = l.split('\t')
            if len(p) != 7:   # UCHET repo nnn group holder klass state
                bad.append('строка UCHET не по грамматике (полей %d): %r'
                           % (len(p), l[:80]))
                continue
            seen[p[2]] = (p[3], p[4], p[5], p[6])
        for nnn, w in want.items():
            if seen.get(nnn) != w:
                bad.append('%s: %r ≠ %r' % (nnn, seen.get(nnn), w))
        grp = {}
        for l in r.stdout.splitlines():
            if not l.startswith('GRP\t'):
                continue
            p = l.split('\t')
            if len(p) != 4:   # GRP group n cap
                bad.append('строка GRP не по грамматике (полей %d): %r'
                           % (len(p), l[:80]))
                continue
            grp[p[1]] = (p[2], p[3])
        if grp.get('harness') != ('2', str(CAP_HARNESS)):
            bad.append('GRP harness %r' % (grp.get('harness'),))
        if grp.get('mob') != ('0', str(CAP_MOB)):
            bad.append('GRP mob %r' % (grp.get('mob'),))
        if grp.get('back') != ('0', str(CAP_BACK)):
            bad.append('GRP back %r' % (grp.get('back'),))
        return [k_rc(r, 0, 'rc')] + (['учёт: ' + '; '.join(bad)] if bad else [])
    reg('u01-uchet-svod', 'сторож=учёт-состояний;источник=журнал+реестр', u01)

    def u02(mir, door):
        r = uchet(door, mir)
        ok = all(l.startswith('GRP\t') for l in r.stdout.splitlines())
        return [k_rc(r, 0, 'rc'), None if ok else 'учёт пуст: строки вне GRP: %r' % r.stdout[:120]]
    reg('u02-uchet-pust', 'сторож=учёт-пуст;источник=замок-пуст', u02)

    # E. гигиена парсинга (норма 041: классы на модели; профиль батареи
    #    parsing_hygiene — реализационной пачкой, те же четыре класса)
    def g01(mir, door):
        wt, br, _ = mir.worktree('140')
        ev = mir.sobytie('e.json', [item('architect', 'Arch140',
                        ['XSUBJECT=140 приманка', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'SUBJECT_NET_V_ZADANII', 'причина'),
                k_net_startov(mir, 'учёт')]
    reg('g01-prefiks-kollizija', 'форма=префикс-коллизия;класс=delimiter-collision', g01)

    def g02(mir, door):
        wt, br, _ = mir.worktree('140')
        ev = mir.sobytie('e.json', [item('architect', 'Arch140',
                        ['SUBJECT=140', 'SUBJECT=141', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'SUBEKT_DVA_V_ZADANII', 'причина')]
    reg('g02-dve-stroki-subject', 'форма=две-строки;класс=regex-injection', g02)

    def g03(mir, door):
        wt, br, _ = mir.worktree('140')
        ev = mir.sobytie('e.json', [item('architect', 'Ar' + TAB + 'ch',
                        ['SUBJECT=140', 'WORKTREE=' + wt, 'BRANCH=' + br])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'IMJA_NET', 'причина')]
    reg('g03-tab-v-imeni', 'форма=разделитель-в-имени;класс=delimiter-collision', g03)

    def g04(mir, door):
        p = mir.root / 'bit.json'
        p.write_text('{"tasks": ["nestrogo"]}', encoding='utf-8')
        r = sudit(door, mir, str(p))
        p2 = mir.root / 'pustoj.json'
        p2.write_text('{"tasks": []}', encoding='utf-8')
        r2 = sudit(door, mir, str(p2))
        p3 = mir.root / 'nejson.txt'
        p3.write_text('not json', encoding='utf-8')
        r3 = sudit(door, mir, str(p3))
        return [k_rc(r, 1, 'rc-битая-форма'), k_prichina(r, 'BITYJ_VHOD', 'причина-битая'),
                k_rc(r2, 1, 'rc-пусто'), k_prichina(r2, 'BITYJ_VHOD', 'причина-пусто'),
                k_rc(r3, 1, 'rc-не-json'), k_prichina(r3, 'BITYJ_VHOD', 'причина-не-json')]
    reg('g04-bityj-vhod', 'форма=битый-вход;класс=silent-drop', g04)

    def g05(mir, door):
        # самоприменение: спавн исполнителя самого предмета 140 зелён на чистом мире
        wt = str(HERE.parent.parent.parent)          # корень клона харнесса батареи
        ev = mir.sobytie('e.json', [item('implementer', 'Impl140',
                        ['реализация двери замка', 'SUBJECT=140',
                         'WORKTREE=' + wt, 'BRANCH=wip/140/architect'])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 0, 'rc'), k_stroka(mir, 'start', subjectId='140', holder='Impl140')]
    reg('g05-samo-prolozhenie', 'класс=self-application-green', g05)

    def g06(mir, door):
        wt, br, _ = mir.worktree('140')
        ev = mir.sobytie('e.json', [item('architect', 'Arch140',
                        ['SUBJECT=140',
                         'см. pin:WORKTREE=%s:BRANCH=%s в середине строки' % (wt, br)])])
        r = sudit(door, mir, ev)
        return [k_rc(r, 1, 'rc'), k_prichina(r, 'PIN_NET', 'причина')]
    reg('g06-podstroka-pina', 'форма=пин-подстрокой;класс=delimiter-collision', g06)

    return K


# ── мутации стабов (Н-39: код, не проза; якорь — маркеры [Dn] и литералы) ────
def _z(t, star, novo):
    if t.count(star) != 1:
        raise RuntimeError('мутирование не нашло ровно одно вхождение: %r' % star[:70])
    return t.replace(star, novo)


def m_bez_dublja(t):
    return _z(t, '''          # [D1 dubl-rabochego] живой рабочий — дубль запрещён (боль 122: v4+v4b).
          otp RABOCHIJ_ZHIV "предмет $sv: рабочий $h_holder бежит без сдачи — дубль запрещён"
''', '')


def m_bez_yield(t):
    return _z(t, '''  if grep -Fq '"toolName":"yield"' "$jf"; then printf 'yield'; return 0; fi''',
              '''  if grep -Fq '"toolName":"yield_NIKOGDA"' "$jf"; then printf 'yield'; return 0; fi''')


def m_avto_relis(t):
    return _z(t, '''        broshen|net_fajla)
          mutexi_snyat_vse
          # [D3 broshennyj-zamok] рестарт ≠ разрешение: дубль после рестарта — отказ.
          otp ZAMOK_BROSHEN "предмет $sv: holder $h_holder без сдачи и без записей >${BROSHEN_TTL_MIN} мин — только --osvobodit, НЕ авто-перезапуск"
          ;;''',
              '''        broshen|net_fajla)
          : # стаб: брошенный замок считаем свободным''')


def m_osvobodit_zhivogo(t):
    return _z(t, '''      rmdir "$zdir/mutex" 2>/dev/null
      # [D24 zhit-zamok] живой замок не освобождается — это и есть дубль-дверь.
      otp ZAMOK_ZHIV "holder $h_holder пишет в журнал свежее (без yield) — живой замок не освобождается"
      ;;''',
              '''      : # стаб: живой замок освобождаем
      prichina='yield' ;;''')


def m_subjekt_bez_jakorja(t):
    return _z(t, """  c="$(kolvo_strok "$t" '^SUBJECT=[0-9]{3}$')\"""",
              """  c="$(kolvo_strok "$t" 'SUBJECT=[0-9]{3}')\"""")
    # NOTE: замена одной строки — якорь ^…$ снят, подстрока валидна


def m_pin_bez_jakorja(t):
    return t.replace('rxw="^WORKTREE=/[^${TAB}]+$"', 'rxw="WORKTREE=/[^${TAB}]+"') \
            .replace('rxb="^BRANCH=wip/[0-9]{3}/[^${TAB}]+$"', 'rxb="BRANCH=wip/[0-9]{3}/[^${TAB}]+"')


def m_object_fabricuet(t):
    return _z(t, """  if [ "$c" = '0' ]; then printf 'net'; return 0; fi
  if [ "$c" -gt 1 ]; then printf 'dva'; return 0; fi
  v="$(printf '%s\\n' "$t" | grep -E '^OBJECT=[0-9a-f]{40}$' | sed -n '1p' | cut -c8-47)"
  printf 'ok:%s' "$v"
}""",
              """  if [ "$c" -gt 1 ]; then printf 'dva'; return 0; fi
  if [ "$c" = '0' ]; then printf 'ok:%s' '0000000000000000000000000000000000000000'; return 0; fi
  v="$(printf '%s\\n' "$t" | grep -E '^OBJECT=[0-9a-f]{40}$' | sed -n '1p' | cut -c8-47)"
  printf 'ok:%s' "$v"
}""")


def m_bez_object_sverki(t):
    return _z(t, '''      [ "$tip" = "$obj" ] || {
        mutexi_snyat_vse
        otp OBJECT_RASHODITSJA "предмет $sv: OBJECT задания $obj ≠ tip ветки $r_br ($tip)"
      }''', '''      : # стаб: сверка OBJECT с веткой снята''')


def m_avtor_ne_sdal(t):
    return _z(t, '''      [ "$(stare_holder "$r_holder")" = 'yield' ] || {
        mutexi_snyat_vse
        otp AVTOR_ESHCHO_RABOTAET "предмет $sv: автор $r_holder не сдал (yield в журнале отсутствует)"
      }''', '''      : # стаб: yield автора не проверяем''')


def m_vtoroj_sudja(t):
    return _z(t, '''            # [D21 vtoroj-sudja] живой судья — второй судья на предмет запрещён.
            otp SUDJA_ZHIV "предмет $sv: судья $h_holder бежит без сдачи — второй судья запрещён"
''', '')


def m_uzhe_suzhen(t):
    return _z(t, '  jq -se --arg r "$REPO_ID" --arg n "$1" --arg roli "$2" --arg o "$3" \'any(.[]; .t == "START" and .repoId == $r and .subjectId == $n and .klass == "sudja" and .rol == $roli and .object == $o)\' "$LEDGER" >/dev/null 2>&1',
              '  return 1 # стаб: повторы роли на OBJECT не ищем')


def m_bez_rabochego(t):
    return _z(t, '''      if [ -z "$rab" ]; then
        # [D12 rabochego-net] судья без автора предмета — судить нечего.
        mutexi_snyat_vse; otp RABOCHEGO_NET "предмет $sv: рабочего START в учёте нет"
      fi''', '''      if [ -z "$rab" ]; then rab="$(printf 'X\\t-\\t-\\t-')"; fi''')


def m_klass_riska_mjagko(t):
    # fail-open на «нет файлов/нет строки/вне алфавита/не-blob»: плохие записи
    # тихо пропускаются, пустой итог — обычный; КОНФЛИКТ согласных значений
    # остаётся отказом (семантика стаба прежняя — «класс не определён → тихо
    # обычный»; источник после v+1 — дерево кандидата, привязка — stab_vhod).
    t = _z(t, '''  if [ -z "$spisok" ]; then printf 'net_stroki:файлов %s/%s-*.md в дереве %s нет' "$kat" "$n" "$obj"; return 0; fi''',
              '''  if [ -z "$spisok" ]; then printf 'obychnyj'; return 0; fi # стаб: пустой перечень — обычный''')
    t = _z(t, '''    if [ "$tip_zap" != blob ]; then ploh="${ploh:+$ploh }$put"; continue; fi''',
              '''    [ "$tip_zap" = blob ] || continue # стаб: не-blob тихо пропущен''')
    t = _z(t, '''      *)        ploh="${ploh:+$ploh }$put"; continue ;;''',
              '''      *)        continue ;; # стаб: нет строки/вне алфавита — тихо пропускаем''')
    t = _z(t, '''  printf '%s' "$znach"''',
              '''  if [ -z "$znach" ]; then printf 'obychnyj'; else printf '%s' "$znach"; fi # стаб: пустой итог — обычный''')
    return t


def m_pervyj_rezultat_find(t):
    # [D29] снят: дефект реализации 140 (73aa92b7a, вердикт адверсария вызов
    # 1/2) — класс читается по ПЕРВОМУ результату (sorted|sed -n '1p' — выбор
    # детерминирован), конфликт/нет строки в остальных файлах молчат: один
    # «рисковый» файл среди шести пропускал рисковый предмет обычным; форма
    # чтения — историческая дверь 73aa92b7a (^-якорь строки, grep -q, не-файлы
    # молча выпадают): краснота на реальных формах наследуется. После v+1
    # источник первый-по-списку записи ДЕРЕВА OBJECT (перечень стабилен LC_ALL=C).
    t = _z(t, '''    | LC_ALL=C sort)"''',
              '''    | LC_ALL=C sort | sed -n '1p')" # стаб: только первый результат''')
    t = _z(t, '''    if [ "$tip_zap" != blob ]; then ploh="${ploh:+$ploh }$put"; continue; fi''',
              '''    case "$zap" in 120000*|*' 'tree'*) continue ;; esac # стаб: симлинк/каталог молча выпадают''')
    t = _z(t, '''    val="$(git -C "$wt" show "$obj:$kat/$put" 2>/dev/null \\
          | grep -E -o 'КЛАСС РИСКА:[[:blank:]]*(обычный|рисковый)([[:blank:].,;]|$)' \\
          | sed -E -e 's/^КЛАСС РИСКА:[[:blank:]]*//' -e 's/[[:blank:].,;]$//')"''',
              '''    if git -C "$wt" show "$obj:$kat/$put" 2>/dev/null | grep -q '^КЛАСС РИСКА: рисковый'; then val='рисковый'
    elif git -C "$wt" show "$obj:$kat/$put" 2>/dev/null | grep -q '^КЛАСС РИСКА:'; then val='обычный'
    else val=''; fi # стаб: историческая форма чтения''')
    return t


def m_bez_adv_do_rev(t):
    return _z(t, '''        if ! subekt_suzhen_sudej "$sv" 'adversary'; then
          mutexi_snyat_vse
          otp ADVERSARIJ_DO_REVJUERA "предмет $sv рисковый, завершённого адверсария в учёте нет — ревьюер раньше адверсария запрещён"
        fi''', '''        : # стаб: порядок адверсарий→ревьюер не проверяем''')


def m_bez_pauzy(t):
    return _z(t, '''  [ -r "$f" ] || return 1
  while IFS= read -r l; do
    case "$l" in '#'*|'') continue ;; esac
    [ "${l%%$'\\t'*}" = "$1" ] && return 0
  done < "$f"
  return 1''', '''  return 1 # стаб: ПАУЗ нет никогда''')


def m_slovo_vsegda(t):
    return _z(t, '''  jq -se --arg r "$REPO_ID" --arg n "$1" \\
    'any(.[]; .t == "SLOVO" and .repoId == $r and .subjectId == $n)' "$LEDGER" >/dev/null 2>&1''',
              '''    'true' "$LEDGER" >/dev/null 2>&1''')


def m_done_net(t):
    return _z(t, '''predmet_done() { [ -n "$(git -C "$REPO" tag -l "done/contracts/$1/*")" ]; }''',
              '''predmet_done() { return 1; } # стаб: done не существует''')


def m_gruppa_vsegda_harness(t):
    return _z(t, '''  if [ "$base" = 'dev-harness' ]; then printf 'harness'; return 0; fi
  if [ "$base" = "$GRP_MOB_REPO" ]; then printf 'mob'; return 0; fi
  if [ "$base" = "$GRP_BACK_REPO" ]; then printf 'back'; return 0; fi
  printf \'-\'''',
              '''  printf 'harness' # стаб: группа всегда harness''')


def m_bez_dublja_v_pakete(t):
    return _z(t, '''  # [D20 dubl-v-pakete] два gated item на один предмет в одном вызове.
  DUBL="$(printf '%s' "$GATED" | cut -d'|' -f4 | sort | uniq -d | sed -n '1p')"
  [ -z "$DUBL" ] || otp DUBL_V_PAKETE "два элемента пакета на предмет $DUBL"''',
              '''  : # стаб: дубль внутри пакета не ищем''')


def m_otkaz_ne_ostanavlivaet(t):
    return t.replace("otp()  { printf 'ОТКАЗ: %s: %s\\n' \"$1\" \"$2\" >&2; exit 1; }",
                     "otp()  { printf 'ОТКАЗ: %s: %s\\n' \"$1\" \"$2\" >&2; return 1; }")


def m_bez_atomarnosti(t):
    return _z(t, '''  i=0
  while [ "$i" -lt 40 ]; do
    mkdir "$d/mutex" 2>/dev/null && return 0
    i=$((i + 1))
    sleep 0.05
  done
  return 1''', '''  sleep 0.4
  return 0 # стаб: мьютекса нет — окно гонки открыто''')


def m_bez_starta(t):
    return _z(t, '''    jq -nc --arg t START --arg r "$REPO_ID" --arg s "$sv" --arg g "$grp2" \\
          --arg h "$name" --arg k "$klass" --arg ro "$rol" --arg o "$obj" \\
          --arg w "$wt" --arg b "$br" --arg at "$(ts_now)" \\
      '{t:$t,repoId:$r,subjectId:$s,group:$g,holder:$h,klass:$k,rol:$ro,object:$o,worktree:$w,branch:$b,at:$at}' \\
      >> "$LEDGER"''', '''    : # стаб: строку START не пишем''')


def m_pustota_prohodit(t):
    return _z(t, '''  [ "$N" -gt 0 ] || otp BITYJ_VHOD 'items пуст\'''',
              '''  : # стаб: пустой items проходит дальше''')


def m_sudi_propusk(t):
    return _z(t, "JUDGES='critic critic-sol adversary reviewer'",
              "JUDGES='' # стаб: судьи не гейтятся")


def m_bez_pin_rashozhdenija(t):
    return _z(t, '''      # [D6 pin-rashozhdenie] номер ветки == номер предмета.
      [ "$(printf '%s' "${br#wip/}" | cut -c1-3)" = "$sv" ] \\
        || otp RASHOZHDENIE_PINA "item $i: BRANCH=wip/$(printf '%s' "${br#wip/}" | cut -c1-3)/… ≠ SUBJECT=$sv"''',
              '''      : # стаб: расхождение пина не проверяем''')


def m_uchet_bez_zhurnala(t):
    return _z(t, '''    st="$(stare_holder "$h")"
    if predmet_done "$s"; then st='done'; fi
    if na_pauze "$s"; then st='pauza'; fi''',
              '''    st='bezhit'
    if predmet_done "$s"; then st='bezhit'; fi
    if na_pauze "$s"; then st='bezhit'; fi''')


def m_vsegda_puschem(t):
    # [X1] свидетель критика (вердикт 1/2, attack-repo): обманная ДВЕРЬ
    # «всегда PUSCHEM» — судья проходит до yield, лимиты/пакет/рестарт
    # пропускаются: все защиты сняты сразу, любая форма вызова разрешает
    # до всякой логики. Стаб поставляемого субъекта: та же мутация над
    # текстом реальной двери (--stabs, слой субъекта).
    star = 'set -uo pipefail\n'
    novo = ('set -uo pipefail\n'
            '# [X1] обманная дверь свидетеля критика: всегда пропуск\n'
            'echo "PUSCHEM (obmannaja dver)"\n'
            'exit 0\n')
    return _z(t, star, novo)


def m_pauza_schitaetsja(t):
    return _z(t, '''    predmet_done "${s#*/}" && continue
    na_pauze "${s#*/}" && continue''',
              '''    predmet_done "${s#*/}" && continue
    : # стаб: ПАУЗА слот держит''')


def m_klass_riska_tolko_nachalo_stroki(t):
    # РЕШЕНИЕ арбитража 140 (главный замер): поставленная дверь 9ec350f7e
    # читала декларацию ТОЛЬКО с начала строки (^-якорь) и cut -d' ' -f1 —
    # ложный KLASS_RISKA_NET на реальных формах 116/139/140/141 (декларация
    # в середине строки после «КЛАСС ЗАДАЧИ: …», хвост-основание в ней же);
    # замена — та же форма извлечения над содержимым дерева OBJECT (v+1).
    return _z(t, '''    val="$(git -C "$wt" show "$obj:$kat/$put" 2>/dev/null \\
          | grep -E -o 'КЛАСС РИСКА:[[:blank:]]*(обычный|рисковый)([[:blank:].,;]|$)' \\
          | sed -E -e 's/^КЛАСС РИСКА:[[:blank:]]*//' -e 's/[[:blank:].,;]$//')"''',
              '''    val="$(git -C "$wt" show "$obj:$kat/$put" 2>/dev/null \\
          | grep '^КЛАСС РИСКА:' | sed -e 's/^КЛАСС РИСКА:[[:space:]]*//' | cut -d' ' -f1)"''')


def m_klass_riska_type_f(t):
    # РЕШЕНИЕ арбитража 140 (г): возврат -type f выкидывает из канона не-файлы:
    # симлинк на «рисковый» молча пропускается — рисковый предмет уходит
    # ревьюеру без адверсария; битый симлинк/каталог тоже исчезают из канона.
    # После v+1 аналог в дереве OBJECT: записи не-blob молча выпадают вместо
    # отказа «нечитаемая запись».
    return _z(t, '''    if [ "$tip_zap" != blob ]; then ploh="${ploh:+$ploh }$put"; continue; fi''',
              '''    [ "$tip_zap" = blob ] || continue # стаб: не-blob записи молча выпадают из канона''')


def m_session_exit_ne_sdacha(t):
    # [D2b] снят: держатель, честно завершившийся session_exit kind=normal
    # (omp 18.18.8 без yield), сдачей НЕ считается — замок висит до TTL
    # (боль 12.11: Arch192Close и др. держали судей 60 мин).
    return _z(t, '''  if tail -n 1 "$jf" | jq -e 'select(.type == "custom" and .customType == "session_exit" and .data.kind == "normal")' >/dev/null 2>&1; then
    printf 'yield'; return 0
  fi
''', '''  : # стаб: session_exit сдачей не считается
''')


def m_session_exit_ljuboj_kind(t):
    # kind не проверяется: аварийный/сигнальный выход (замер: 231 signal)
    # тоже засчитывается сдачей
    return _z(t, '''and .data.kind == "normal")' >/dev/null 2>&1; then''',
              '''and .data.kind != "__NIKOGDA__")' >/dev/null 2>&1; then''')


def m_marker_podstrokoj(t):
    # структурная проверка события заменена подстрокой (форма срочной правки
    # владельца 776d8cd8d): литералы в теле ЧУЖОЙ записи (вложенные поля
    # события иного типа, текст сообщения) засчитываются как сдача
    return _z(t, '''  if tail -n 1 "$jf" | jq -e 'select(.type == "custom" and .customType == "session_exit" and .data.kind == "normal")' >/dev/null 2>&1; then''',
              '''  if tail -n 1 "$jf" | grep -Fq '"customType":"session_exit"' \\
     && tail -n 1 "$jf" | grep -Fq '"kind":"normal"'; then''')


def m_klass_iz_gryazi(t):
    # [D31] класс читается из ГРЯЗНОГО рабочего каталога автора (cat файла
    # worktree и hash-object каталога), не из дерева OBJECT: незакоммиченная
    # правка контракта меняет класс судимого предмета
    t = _z(t, '''    val="$(git -C "$wt" show "$obj:$kat/$put" 2>/dev/null \\
          | grep -E -o 'КЛАСС РИСКА:[[:blank:]]*(обычный|рисковый)([[:blank:].,;]|$)' \\
          | sed -E -e 's/^КЛАСС РИСКА:[[:blank:]]*//' -e 's/[[:blank:].,;]$//')"''',
              '''    val="$(cat "$wt/$kat/$put" 2>/dev/null \\
          | grep -E -o 'КЛАСС РИСКА:[[:blank:]]*(обычный|рисковый)([[:blank:].,;]|$)' \\
          | sed -E -e 's/^КЛАСС РИСКА:[[:blank:]]*//' -e 's/[[:blank:].,;]$//')"''')
    t = _z(t, '''    blob="$(printf '%s' "$zap" | cut -f1 | cut -d' ' -f3)"''',
              '''    blob="$(git -C "$wt" hash-object "$wt/$kat/$put" 2>/dev/null)" # стаб: blob из каталога''')
    return t


def m_klass_iz_main(t):
    # [D31] снят: источник класса — $REPO/contracts (main), как в двери до
    # v+1 (боль 991 v3: «рисковый» старого main против «обычный» кандидата
    # молча отказывала KLASS_RISKA_NET); перечисление find по main, blob —
    # hash-object файлов main, содержимое — cat файлов main
    t = _z(t, '''  if [ "$(git -C "$wt" cat-file -t "$obj:contracts" 2>/dev/null)" = tree ]; then kat='contracts'
  elif [ "$(git -C "$wt" cat-file -t "$obj:.harness/contracts" 2>/dev/null)" = tree ]; then kat='.harness/contracts'
  else printf 'net_stroki:ни contracts/, ни .harness/contracts/ в дереве %s нет' "$obj"; return 0; fi''',
              '''  if [ -d "$REPO/contracts" ]; then kat="$REPO/contracts"
  elif [ -d "$REPO/.harness/contracts" ]; then kat="$REPO/.harness/contracts"
  else printf 'net_stroki:ни contracts/, ни .harness/contracts/ в %s нет' "$REPO"; return 0; fi''')
    t = _z(t, '''  spisok="$(git -C "$wt" ls-tree "$obj:$kat" 2>/dev/null \\
    | awk -F'\\t' -v n="$n" '$2 ~ "^" n "-[^/]*[.]md$" {print $1 "\\t" $2}' \\
    | LC_ALL=C sort)"''',
              '''  spisok="$(find "$kat" -maxdepth 1 -name "$n-*.md" -print | LC_ALL=C sort \\
    | while IFS= read -r mf; do printf '100644 blob %s\\t%s\\n' "$(git hash-object "$mf" 2>/dev/null)" "$mf"; done)"''')
    t = _z(t, '''    val="$(git -C "$wt" show "$obj:$kat/$put" 2>/dev/null \\
          | grep -E -o 'КЛАСС РИСКА:[[:blank:]]*(обычный|рисковый)([[:blank:].,;]|$)' \\
          | sed -E -e 's/^КЛАСС РИСКА:[[:blank:]]*//' -e 's/[[:blank:].,;]$//')"''',
              '''    val="$(grep -E -o 'КЛАСС РИСКА:[[:blank:]]*(обычный|рисковый)([[:blank:].,;]|$)' "$put" 2>/dev/null \\
          | sed -E -e 's/^КЛАСС РИСКА:[[:blank:]]*//' -e 's/[[:blank:].,;]$//')"''')
    return t

def m_bez_gruppovoj_atomarnosti(t):
    # [D34] снят: мьютексы групп не берутся — решение о лимите группы не
    # атомарно между разными предметами (вердикт адверсария 140 v4 вызов 1/2,
    # OBJECT 3572945e: два одновременных суда РАЗНЫХ NNN читали одинаковую
    # заполненность до записи своих START и оба проходили — 4 из 3)
    return _z(t, '''  # [D34 gruppa-atomarna] мьютексы ГРУПП пакета (отсортированы, до мьютексов
  # предметов — общий порядок у конкурентов): решение о лимите группы атомарно
  # и МЕЖДУ разными предметами. Вердикт адверсария 140 v4 вызов 1/2 (OBJECT
  # 3572945e): два одновременных суда РАЗНЫХ NNN одной группы читали одинаковую
  # заполненность до записи своих START и оба проходили — 4 из 3. Судьям группы
  # не нужны: лимит судится только у рабочих.
  local gz g
  gz="$(printf '%s' "$GATED" | while IFS='|' read -r idx agent name sv obj wt br klass rol; do
    [ "$klass" = 'rabochij' ] || continue
    gruppa_iz_pina "$wt"
  done | LC_ALL=C sort -u)"
  while IFS= read -r g; do
    [ -n "$g" ] || continue
    case "$g" in harness|mob|back) ;; *) continue ;; esac
    if ! mutex_zajavit_dir "$(gruppa_zamok_dir "$g")"; then
      mutexi_snyat_vse
      otp ZANYATO_RESHENIEM "группа $g: мьютекс решения группы занят (параллельный суд лимита)"
    fi
    GRUPPY_ZANYATY="${GRUPPY_ZANYATY}${g}"$'\\n'
  done <<EOF
$gz
EOF
''', '''  : # стаб: мьютексы групп не берём — лимит группы не атомарен между предметами
''')


def m_relis_osvobozhdaet_slot(t):
    # [D32] снят: RELEASE снова обнуляет слот группы (форма двери до усиления):
    # сдался либо оборвался + --osvobodit — предмет выпадает из счёта лимитов
    # ДО done/ПАУЗЫ (боль bootstrap 998: слот гасился ротацией держателя)
    return _z(t, '''      if $l.t == "START" then .[$l.repoId + "/" + $l.subjectId] = $l.group
      else . end
    ) | to_entries | map(select(.value != null and .value == $g)) | map(.key) | .[]' \\''',
              '''      if $l.t == "START" then .[$l.repoId + "/" + $l.subjectId] = $l.group
      elif $l.t == "RELEASE" then .[$l.repoId + "/" + $l.subjectId] = null
      else . end
    ) | to_entries | map(select(.value != null and .value == $g)) | map(.key) | .[]' \\''')


def m_bez_dedushki(t):
    # [D33] снят: уже начатый предмет судится лимитом как новый — замена
    # держателя начатого при сверхлимите отказывает LIMIT_GRUPPY (боль
    # bootstrap 998: замена/интегратор при 11 начатых из 3 не пускалась)
    return _z(t, '''        if [ "$zhivo" -ge "$cap" ] && ! slovo_vladelca "$sv" \\
           && ! predmet_derzhit_slot "$sv" "$grp"; then''',
              '''        if [ "$zhivo" -ge "$cap" ] && ! slovo_vladelca "$sv"; then''')


def m_bez_scheta_paketa(t):
    # [D35] снят: занятость судится ТОЛЬКО по учёту — элементы пакета не
    # считают слотов соседей (форма модели до усиления): ОДИН batch с двумя
    # новыми NNN одной группы при 2 занятых из 3 проходит оба — 4 из 3.
    # Внутрипроцессная дыра (одиночный вызов, БЕЗ гонки) — потому стаб
    # отличен от s36-bez-gruppovoj-atomarnosti (межпроцессный мьютекс D34)
    # и красен на СВОЁМ входе w31, где s36 честен.
    t = _z(t, '''        case "$grp" in
          harness) zhivo=$((zhivo + PAKET_HARNESS)) ;;
          mob)     zhivo=$((zhivo + PAKET_MOB)) ;;
          back)    zhivo=$((zhivo + PAKET_BACK)) ;;
        esac''',
              '''        : # стаб: слоты пакета не считаем (учёт без соседей)''')
    return _z(t, '''        if ! predmet_derzhit_slot "$sv" "$grp"; then
          case "$grp" in
            harness) PAKET_HARNESS=$((PAKET_HARNESS + 1)) ;;
            mob)     PAKET_MOB=$((PAKET_MOB + 1)) ;;
            back)    PAKET_BACK=$((PAKET_BACK + 1)) ;;
          esac
        fi''',
              '''        : # стаб: прошедшие пакет слоты не занимают''')



STAB_MUTACII = {
    's01-bez-dublja-rabochego': m_bez_dublja,
    's02-bez-yield-predikata': m_bez_yield,
    's03-avto-relis-broshennogo': m_avto_relis,
    's04-osvobodit-zhivogo': m_osvobodit_zhivogo,
    's05-subjekt-bez-jakorja': m_subjekt_bez_jakorja,
    's06-pin-bez-jakorja': m_pin_bez_jakorja,
    's07-object-fabricuet': m_object_fabricuet,
    's08-bez-object-sverki': m_bez_object_sverki,
    's09-avtor-ne-sdal': m_avtor_ne_sdal,
    's10-vtoroj-sudja': m_vtoroj_sudja,
    's11-uzhe-suzhen': m_uzhe_suzhen,
    's12-bez-rabochego': m_bez_rabochego,
    's13-klass-riska-mjagko': m_klass_riska_mjagko,
    's14-bez-adv-do-rev': m_bez_adv_do_rev,
    's15-bez-pauzy': m_bez_pauzy,
    's16-slovo-vsegda': m_slovo_vsegda,
    's17-done-net': m_done_net,
    's18-gruppa-vsegda-harness': m_gruppa_vsegda_harness,
    's19-bez-dublja-v-pakete': m_bez_dublja_v_pakete,
    's20-otkaz-ne-ostanavlivaet': m_otkaz_ne_ostanavlivaet,
    's21-bez-atomarnosti': m_bez_atomarnosti,
    's22-bez-starta': m_bez_starta,
    's23-pustota-prohodit': m_pustota_prohodit,
    's24-sudi-propusk': m_sudi_propusk,
    's25-bez-pin-rashozhdenija': m_bez_pin_rashozhdenija,
    's26-uchet-bez-zhurnala': m_uchet_bez_zhurnala,
    's27-pauza-schitaetsja': m_pauza_schitaetsja,
    's28-pervyj-rezultat-find': m_pervyj_rezultat_find,
    's29-klass-riska-tolko-nachalo-stroki': m_klass_riska_tolko_nachalo_stroki,
    's30-klass-riska-type-f': m_klass_riska_type_f,
    's31-session-exit-ne-sdacha': m_session_exit_ne_sdacha,
    's32-session-exit-ljuboj-kind': m_session_exit_ljuboj_kind,
    's33-marker-podstrokoj': m_marker_podstrokoj,
    's34-klass-iz-gryazi': m_klass_iz_gryazi,
    's35-klass-iz-main': m_klass_iz_main,
    's36-bez-gruppovoj-atomarnosti': m_bez_gruppovoj_atomarnosti,
    's37-relis-osvobozhdaet-slot': m_relis_osvobozhdaet_slot,
    's38-bez-dedushki': m_bez_dedushki,
    's45-bez-scheta-paketa': m_bez_scheta_paketa,
    'x01-vsegda-puschem': m_vsegda_puschem,
}


def nagrudit_staby():
    """Материализация stabs/<имя>/zamok_predmeta.sh из модели + STAB_MUTACII."""
    base = MODEL.read_text(encoding='utf-8')
    for imja, fn in sorted(STAB_MUTACII.items()):
        tekst = fn(base)
        d = STABS / imja
        d.mkdir(parents=True, exist_ok=True)
        f = d / 'zamok_predmeta.sh'
        f.write_text(tekst, encoding='utf-8')
        f.chmod(0o755)
        print('STAB %s записан (%d байт)' % (imja, len(tekst.encode("utf-8"))))


# ── безфлаговый режим: судит ПОСТАВЛЕННУЮ дверь дерева ──────────────────────
def rezhim_plain(K):
    d = SUBJEKT_DVERI
    if not d.is_file():
        print('SUBJECT_ABSENT: субъекта-двери нет: %s — зелень без субъекта невозможна' % d)
        for imja in sorted(K):
            print('CASE %s KRASNO (SUBJECT_ABSENT: %s)' % (imja, d))
        print('STANCIONNYE: %d клеток интеграции хука (p01-p14,m01, osi.md) — команда приёмки bash %s'
              % (STANCIONNYH_KLETOK, HERE / 'stancija_odin_agent_140.sh'))
        return 1
    krasnyh = 0
    for imja in sorted(K):
        problems = progon(d, imja, K[imja]['run'])
        if problems:
            krasnyh += 1
            for p in problems:
                print('CASE %s KRASNO: %s' % (imja, p))
        else:
            print('CASE %s ok' % imja)
    print('SUBJEKT: %s' % d)
    print('STANCIONNYE: %d клеток интеграции хука (p01-p14,m01, osi.md) — команда приёмки bash %s'
          % (STANCIONNYH_KLETOK, HERE / 'stancija_odin_agent_140.sh'))
    print('KLETKI %d KRASNYH %d' % (len(K), krasnyh))
    return 1 if krasnyh else 0


# ── слой субъекта в --stabs: контроль + обманные двери НАД ПОСТАВЛЕННОЙ ──────
def sloj_subjekta(K, stab_vhod):
    d = SUBJEKT_DVERI
    if not d.is_file():
        print('SUBJEKT_NET: поставленной двери нет (%s) — слой субъекта пропущен; '
              'над МОДЕЛЬЮ как опора уже прогнано (предварительное доказательство)' % d)
        return 0
    baza = d.read_text(encoding='utf-8')
    krasnyh = 0
    for imja in sorted(K):
        problems = progon(d, imja, K[imja]['run'])
        if problems:
            krasnyh += 1
            for p in problems:
                print('SUBJEKT CASE %s KRASNO: %s' % (imja, p))
        else:
            print('SUBJEKT CASE %s ok' % imja)
    if krasnyh:
        print('SUBJEKT_KRASNO: %d — поставленная дверь красна (свидетель критика пойман)' % krasnyh)
        return 1
    svjazi = 0
    zhivye = 0
    vrem = tempfile.mkdtemp(prefix='odin140-subjekt-')
    try:
        for stab in sorted(STAB_MUTACII):
            try:
                tekst = STAB_MUTACII[stab](baza)
            except RuntimeError as e:
                zhivye += 1
                print('STAB_ZHIV: %s якорь мутации не найден в субъекте: %s' % (stab, e))
                continue
            f = Path(vrem) / (stab + '.sh')
            f.write_text(tekst, encoding='utf-8')
            f.chmod(0o755)
            for vhod in stab_vhod[stab]:
                problems = progon(f, vhod, K[vhod]['run'])
                svjazi += 1
                if not problems:
                    zhivye += 1
                    print('STAB_ZHIV: %s прошёл вход %s (над реальным субъектом)' % (stab, vhod))
                else:
                    print('SUBJEKT STAB %s %s KRASEN' % (stab, vhod))
    finally:
        shutil.rmtree(vrem, ignore_errors=True)
    print('SUBJEKT_SVJAZI %d' % svjazi)
    if zhivye:
        print('STAB_ZHIV: %d (субъект)' % zhivye)
        return 1
    if svjazi == 0:
        return oshibka_orakula('пустая матрица связей субъекта')
    return 0


# ── прогон кейса на двери ────────────────────────────────────────────────────
def progon(door, imja, kejs):
    tmp = tempfile.mkdtemp(prefix='odin140-')
    try:
        mir = Mir(tmp)
        problems = [p for p in kejs(mir, Path(door)) if p]
        return problems
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def main():
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', '--matrix', dest='stabs', action='store_true')
    ap.add_argument('--sgeneriruj-staby', action='store_true')
    a = ap.parse_args()

    if a.sgeneriruj_staby:
        nagrudit_staby()
        return 0

    for tool in ('bash', 'git', 'jq'):
        if shutil.which(tool) is None:
            print('NOT_IMPLEMENTED: нет %s' % tool, file=sys.stderr)
            return 2
    if not MODEL.is_file():
        print('SUBJECT_ABSENT: модели нет: %s' % MODEL, file=sys.stderr)
        return 1

    src = json.loads((HERE / 'source.json').read_text(encoding='utf-8'))
    # оракул в памяти ДО вызова субъекта (правило 8): пины носителей
    for imja, pin in src['nositeli'].items():
        if imja == 'model/zamok_predmeta.sh':
            p = MODEL
        elif imja.startswith('materialy/'):
            p = HERE / imja
        else:
            p = STABS / imja / 'zamok_predmeta.sh'
        if not p.is_file():
            return oshibka_orakula('носитель отсутствует: %s' % imja)
        if sha256_bytes(p.read_bytes()) != pin:
            return oshibka_orakula('sha256 носителя %s' % imja)
    if set(src['stab_vhod']) != set(STAB_MUTACII):
        return oshibka_orakula('stab_vhod != STAB_MUTACII')
    K = kejsy()
    if set(src['kejsy']) != set(K):
        return oshibka_orakula('список kejsy != кейсам батареи')
    for stab, vhody in src['stab_vhod'].items():
        for v in vhody:
            if v not in K:
                return oshibka_orakula('стаб %s ведёт в несуществующий кейс %s' % (stab, v))
    if (src['konstanty']['cap_harness'], src['konstanty']['cap_mob'],
            src['konstanty']['cap_back'], src['konstanty']['broshen_ttl_min']) != (
            CAP_HARNESS, CAP_MOB, CAP_BACK, BROSHEN_TTL_MIN):
        return oshibka_orakula('константы source.json != канону батареи')
    if src['konstanty']['yield_literal'] != YIELD_LITERAL:
        return oshibka_orakula('литерал yield разошёлся')

    if not (a.model or a.stabs):
        # безфлаговый режим судит ПОСТАВЛЕННУЮ дверь дерева (вердикт критика
        # 1/2: батарея обязана судить реализацию, не только модель/стабы)
        return rezhim_plain(K)

    # --model: контроль входов на эталоне
    vse_ok = True
    if a.model or a.stabs:
        for imja in sorted(K):
            problems = progon(MODEL, imja, K[imja]['run'])
            if problems:
                vse_ok = False
                for p in problems:
                    print('CASE %s KRASNO: %s' % (imja, p))
            else:
                print('CASE %s ok' % imja)
        if not vse_ok:
            return 1

    if a.stabs:
        baza = MODEL.read_text(encoding='utf-8')
        svjazi = 0
        zhivye = 0
        for stab in sorted(STAB_MUTACII):
            f = STABS / stab / 'zamok_predmeta.sh'
            if sha256_bytes(f.read_bytes()) != sha256_bytes(
                    STAB_MUTACII[stab](baza).encode('utf-8')):
                return oshibka_orakula('стаб %s дрейфовал от мутации' % stab)
            for vhod in src['stab_vhod'][stab]:
                problems = progon(f, vhod, K[vhod]['run'])
                svjazi += 1
                if not problems:
                    zhivye += 1
                    print('STAB_ZHIV: %s прошёл вход %s' % (stab, vhod))
                else:
                    print('STAB %s %s KRASEN' % (stab, vhod))
        print('SVJAZI %d' % svjazi)
        if zhivye:
            print('STAB_ZHIV: %d' % zhivye)
            return 1
        if svjazi == 0:
            return oshibka_orakula('пустая матрица связей')
        # слой субъекта: поставленная дверь существует → контроль + обманные
        # двери над её текстом (свидетель критика обязан краснеть здесь тоже)
        return sloj_subjekta(K, src['stab_vhod'])
    return 0


if __name__ == '__main__':
    sys.exit(main())
