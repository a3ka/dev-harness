#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 212 (§ПРОВОДКА): судит инструмент оркестратора
# scripts/replace_line.sh — REPLACE строки реестра «<NNN> → <tag-object
# frozen/contracts/<NNN>/<vmax>>» ПРЯМЫМ коммитом на main сквозь живую
# дверь 031 (check_staged.sh REPLACE-форма), после ленда носителя заморозки.
# Эталон — model/replace_line.sh (исполняемая модель; поведение судится
# батареей, не побайтовым сравнением текста — реализация implementer несёт
# ту же семантику).
#
# Оракул (правило 8): source.json читается в память ДО вызова субъекта;
# носители — sha256; дрейф модели/стабов = rc 2 ORACLE_TAMPERED. Привязки
# стаб↔вход — ТОЛЬКО source.json:.stab_vhod (Н-39: проза контракта пар
# не утверждает; якорь каждой мутации кратен 1 в тексте модели).
#
# НАБЛЮДЕНИЕ — байты обеих труб (К-10, арбитраж 208): каждая клетка
# сравнивает rc, stdout И stderr ПОЛНОСТЬЮ байт-в-байт; обе трубы
# захватываются байтами (subprocess без text=True), между захватом и
# сравнением нет ни декодирования, ни перевода строк, ни strip. Для зелёных
# клеток ожидание stdout реконструируется ПОСЛЕ прогона из МИРА (plumbing
# rev-parse HEAD нового коммита) и сравнивается байт-в-байт: оракул —
# состояние мира, не трубы субъекта. Успешный коммит сквозь живую дверь
# оставляет в stderr байты двери («judged: …» + «ok: staged …») — эта пара
# служит канарейкой неотвратимости двери: стаб с --no-verify / инъекцией
# -c core.hooksPath теряет её и краснеет побайтово.
#
# Режимы:
#   (без флага) / --repo <корень>
#         субъект = <корень>/scripts/replace_line.sh (корень по умолчанию —
#         дерево батареи). До реализации клетки красны поимённо, итог rc 1;
#         нет субъекта — rc 1 SUBJECT_ABSENT с перечнем всех входов.
#   --model   контроль входов на эталоне (KLETKI N KRASNYH 0).
#   --stabs   контроль + матрица обманных стабов над текстом модели
#         (SVJAZI N ZHIVYH 0); якорь потерян/синтаксис сломан — rc 2.
#   --sgeneriruj-staby (обслуживание) материализует stabs/<имя>/ и
#         source.json (nositeli).
#   --sintaksis носители пачки синтаксически цельны: bash -n на модели,
#         каждом стабе и (если поставлен) субъекте; shellcheck — штатным
#         швом scripts/validate_std.sh bash (VALIDATE_STD_SHELLCHECK);
#         отсутствие/неверный пин валидатора — именованный rc 2, не пропуск.
#
# Миры — одноразовые репозитории mktemp под $TMPDIR, вне дерева батареи;
# номера предметов — случайные из заявленного диапазона 985–994 (вне
# занятых 020-119/120-939/940-984 и самого 212: константа предмета в
# копии не проходит). Дверь мира — ЖИВАЯ: pre-commit exec bash
# <дерево-батареи>/scripts/check_staged.sh <toy>.
# Коды возврата: 0 — зелено; 1 — красная клетка либо STAB_ZHIV либо субъекта
# нет; 2 — нечем проверять (нет git/bash/python3/двери, ORACLE_TAMPERED).
import argparse
import hashlib
import json
import os
import random
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
MODEL = HERE / 'model' / 'replace_line.sh'
STABS = HERE / 'stabs'
SOURCE = HERE / 'source.json'
REPO = HERE.parent.parent.parent
DOOR = REPO / 'scripts' / 'check_staged.sh'
VALIDATE_STD = REPO / 'scripts' / 'validate_std.sh'

NNN_POOL = list(range(985, 995))          # заявленный диапазон миров 212
SUBJ_IMJA = 'scripts/replace_line.sh'

# Байты живой двери 031 при пропуске REPLACE-коммита (калибровано прогоном
# модели в честном мире; заголовок check_staged — та же грамматика 016/018).
DVOR = ('judged: registry/contracts.tsv (дверь минта 031: +1 строк ↔ живые dual-control теги)\n'
        'ok: staged в зоне автора orchestrator (1 путь/путей)\n').encode('utf-8')

USAGE = ('использование: replace_line.sh --nnn <NNN> [--root <каталог>]\n'
         '\n'
         'Аргументы:\n'
         '  --nnn NNN    номер контракта (1-3 цифры), обязательно\n'
         '  --root КАТ   корень репозитория. По умолчанию — текущий.\n'
         '\n'
         'Контракт: печатает REPLACED nnn=<NNN> old=<sha> new=<sha> commit=<sha> на stdout, rc 0.\n'
         ).encode('utf-8')


def sha256_bytes(b):
    return hashlib.sha256(b).hexdigest()


def chistaja_git_sreda():
    env = dict(os.environ)
    for k in list(env):
        if k.startswith('GIT_'):
            del env[k]
    env['GIT_CONFIG_GLOBAL'] = '/dev/null'
    env['GIT_CONFIG_SYSTEM'] = '/dev/null'
    env['PYTHONDONTWRITEBYTECODE'] = '1'
    return env


GIT_ENV = chistaja_git_sreda()


def run(cmd, cwd=None, env=None, timeout=240):
    # БАЙТЫ на обеих трубах (К-10): text-режим переводил бы CRLF/CR в LF
    # до сравнения; декодирование — только в diag(), для текста причин.
    return subprocess.run([str(c) for c in cmd], capture_output=True,
                          cwd=str(cwd) if cwd else None,
                          env=env if env is not None else GIT_ENV,
                          timeout=timeout)


def plumbing(r):
    return r.stdout.decode('utf-8', 'surrogateescape').strip()


def diag(b, predel=200):
    return (b or b'').decode('utf-8', 'replace').strip()[:predel]


def bajty(ozhidaemyj):
    if isinstance(ozhidaemyj, bytes):
        return ozhidaemyj
    return ozhidaemyj.encode('utf-8')


# ── мир: toy + bare-origin + живая дверь ─────────────────────────────────────
class Mir:
    def __init__(self, w, nnn):
        self.w = Path(w)
        self.n = '%03d' % nnn
        self.t = self.w / 'toy'
        t = self.t
        for d in ('contracts', 'registry', 'scripts'):
            (t / d).mkdir(parents=True, exist_ok=True)
        (t / 'contracts' / '001-x.md').write_text(
            '# контракт 001\n\n## Предмет\nподставной предмет\n\n'
            '## Критерий готовности\nкоманда с кодом возврата\n\n'
            '## Исполнители и зоны\nЗОНА orchestrator: HANDOFF.md\n', encoding='utf-8')
        (t / 'HANDOFF.md').write_text('# передача\n', encoding='utf-8')
        (t / 'scripts' / 'a.sh').write_text('seed\n', encoding='utf-8')
        self.git('init', '-q', '-b', 'main', '.')
        self.git('config', 'commit.gpgsign', 'false')
        self.g('add', '-A')
        self.g('commit', '-q', '-m', 'основание: контракт и зона orchestrator')
        (t / 'registry' / 'contracts.tsv').write_text(
            '000 → %s\n' % self.rev('HEAD'), encoding='utf-8')
        self.g('add', '-A')
        self.g('commit', '-q', '-m', 'основание: манифест реестра')
        self.g('tag', '-a', 'frozen/contracts/001/1', '-m', 'контракт утверждён')
        orig = self.w / 'orig.git'
        self.git('init', '-q', '--bare', str(orig))
        self.git('-C', str(orig), 'symbolic-ref', 'HEAD', 'refs/heads/main')
        self.g('remote', 'add', 'origin', str(orig))
        self.g('push', '-q', 'origin', 'main')
        # Живая дверь: pre-commit → check_staged дерева батареи на этот toy.
        # Каталог хука — вне toy-дерева (untracked hooks/ внутри toy делал бы
        # status --porcelain непустым и валил зелёные клетки на «грязное
        # дерево» — урок батареи 068).
        hook = self.w / 'hookdir'
        hook.mkdir(parents=True, exist_ok=True)
        (hook / 'pre-commit').write_text(
            '#!/bin/sh\nexec bash "%s" "%s"\n' % (DOOR, t), encoding='utf-8')
        (hook / 'pre-commit').chmod(0o755)
        self.git('config', 'core.hooksPath', str(hook))

    def git(self, *args):
        return run(['git'] + list(args), cwd=self.t)

    def g(self, *args):
        # миротворец: крюки сняты, identity явная (строитель мира доверен)
        r = run(['git', '-c', 'commit.gpgsign=false',
                 '-c', 'core.hooksPath=/dev/null',
                 '-c', 'user.name=orchestrator',
                 '-c', 'user.email=orchestrator@local'] + list(args), cwd=self.t)
        if r.returncode:
            raise RuntimeError('постройка мира: git %s: %s' % (args[0], diag(r.stdout + r.stderr)))
        return r

    def rev(self, ref):
        return plumbing(self.git('rev-parse', ref))

    def show_bytes(self, what):
        r = self.git('show', what)
        return r.stdout

    def out(self, *args):
        return plumbing(self.git(*args))

    def manifest_fajl(self):
        return self.t / 'registry' / 'contracts.tsv'

    def stroka_nn(self):
        for ln in self.show_bytes('HEAD:registry/contracts.tsv').decode('utf-8').splitlines():
            if ln.startswith(self.n + ' '):
                return ln
        return None

    def mint(self):
        # авторитетная половина: тег id + строка СКВОЗЬ ЖИВУЮ ДВЕРЬ + push
        self.g('tag', '-a', 'id/CONTRACT/%s' % self.n, '-m', 'выдача')
        self.g('push', '-q', 'origin', 'refs/tags/id/CONTRACT/%s' % self.n)
        idsha = self.rev('refs/tags/id/CONTRACT/%s' % self.n)
        with open(self.manifest_fajl(), 'a', encoding='utf-8') as f:
            f.write('%s → %s\n' % (self.n, idsha))
        self.g('add', '-A')
        r = run(['git', '-c', 'commit.gpgsign=false',
                 '-c', 'user.name=orchestrator', '-c', 'user.email=orchestrator@local',
                 'commit', '-q', '-m', 'реестр: строка %s (минт)' % self.n], cwd=self.t)
        if r.returncode != 0:
            raise RuntimeError('мир: минт сквозь дверь отказал: %s' % diag(r.stderr))
        self.g('push', '-q', 'origin', 'main')
        return idsha

    def zamenit_stroku(self, novyj_sha, soobshenie='правка строки (мир)'):
        # строимое состояние: строка N переписана в обход двери + push
        star = self.stroka_nn()
        data = self.manifest_fajl().read_bytes()
        data = data.replace(('%s\n' % star).encode('utf-8'),
                            ('%s → %s\n' % (self.n, novyj_sha)).encode('utf-8'), 1)
        self.manifest_fajl().write_bytes(data)
        self.g('add', '-A')
        self.g('commit', '-q', '-m', soobshenie)
        self.g('push', '-q', 'origin', 'main')

    def freeze(self, land=True, push_tega=True):
        n = self.n
        self.g('checkout', '-q', '-b', 'wip/%s/freeze' % n)
        (self.t / ('contracts/%s-nositel.md' % n)).write_text(
            'носитель заморозки %s\n' % n, encoding='utf-8')
        self.g('add', '-A')
        self.g('commit', '-q', '-m', 'носитель заморозки %s' % n)
        self.g('tag', '-a', 'frozen/contracts/%s/1' % n, '-m', 'заморозка %s v1' % n)
        args = ['push', '-q', 'origin', 'wip/%s/freeze' % n]
        if push_tega:
            args.append('refs/tags/frozen/contracts/%s/1' % n)
        self.g(*args)
        self.g('checkout', '-q', 'main')
        if land:
            self.g('merge', '--no-ff', '-q', '-m', 'ленд носителя %s' % n,
                   'wip/%s/freeze' % n)
            self.g('push', '-q', 'origin', 'main')

    def freeze_v2(self):
        n = self.n
        (self.t / ('contracts/%s-nositel-v2.md' % n)).write_text(
            'носитель заморозки %s v2\n' % n, encoding='utf-8')
        self.g('add', '-A')
        self.g('commit', '-q', '-m', 'носитель заморозки %s v2' % n)
        self.g('tag', '-a', 'frozen/contracts/%s/2' % n, '-m', 'заморозка %s v2' % n)
        self.g('push', '-q', 'origin', 'main', 'refs/tags/frozen/contracts/%s/2' % n)


# ── ожидания ─────────────────────────────────────────────────────────────────
def ozh_otkaz(msg):
    return (1, b'', ('ОТКАЗ: %s\n' % msg).encode('utf-8'))


# ── клетки: имя → (постройка мира, ожидание, пост-проверки) ─────────────────
def kejsy():
    K = {}

    def reg(imja, opisanie, postrojka):
        K[imja] = {'opisanie': opisanie, 'postroit': postrojka}

    def mir_chestnyj(w, nnn):
        m = Mir(w, nnn)
        idsha = m.mint()
        m.freeze()
        return m, {'id': idsha, 'f1': m.rev('refs/tags/frozen/contracts/%s/1' % m.n)}

    reg('r01-chestnyj-replace',
        'ленд состоялся, тег опубликован, строка = id-тег — REPLACE проходит прямым коммитом сквозь живую дверь (rc 0)',
        mir_chestnyj)
    reg('r02-teg-ne-na-origin',
        'frozen-тег жив локально, НЕ запушен на origin (self-freeze) — именованный отказ, дерево не мутировано',
        lambda w, nnn: _mir_r02(w, nnn))
    reg('r03-zamorozka-ne-predok-main',
        'frozen-тег опубликован, но коммит заморозки НЕ предок origin/main (ленд не состоялся) — отказ',
        lambda w, nnn: _mir_r03(w, nnn))
    reg('r04-staraja-stroka-chuzhaja',
        'строка N указывает на посторонний sha (ни id-тег, ни frozen/<vmax-1>) — отказ старой стороны',
        lambda w, nnn: _mir_r04(w, nnn))
    reg('r05-povtornyj-replace',
        'строка N уже указывает на tag-object frozen/<vmax> — повторный REPLACE отказ',
        lambda w, nnn: _mir_r05(w, nnn))
    reg('r06-grjaznoe-derevo',
        'рабочее дерево грязное (untracked) — отказ до любых обменов, дерево не мутировано',
        lambda w, nnn: _mir_r06(w, nnn))
    reg('r07-ne-main',
        'HEAD на wip-ветке — отказ «не main» до любых обменов',
        lambda w, nnn: _mir_r07(w, nnn))
    reg('r08-main-rashoditsja',
        'локальный main позади origin/main — отказ расхождения до записи',
        lambda w, nnn: _mir_r08(w, nnn))
    reg('r09-dver-otkljuchena',
        'core.hooksPath ведёт в каталог без pre-commit — именованный отказ конфиг-дизарма ДО записи',
        lambda w, nnn: _mir_r09(w, nnn))
    reg('r10-stroki-net',
        'строки N нет в манифесте — REPLACE нечего менять',
        lambda w, nnn: _mir_r10(w, nnn))
    reg('r11-frozen-ljogkij',
        'локальный frozen-тег лёгкий (не аннотированный) — отказ',
        lambda w, nnn: _mir_r11(w, nnn))
    reg('r12-dve-stroki',
        'в манифесте две строки N — отказ неоднозначности',
        lambda w, nnn: _mir_r12(w, nnn))
    reg('r13-drejf-frozen',
        'локальный frozen-тег перетегирован (sha ≠ origin) — отказ переминта заморозки',
        lambda w, nnn: _mir_r13(w, nnn))
    reg('r14-avtoritet-nedostupen',
        'origin недоступен (ls-remote rc 128) — fail-closed «авторитет недоступен», НЕ «тег не выдан»',
        lambda w, nnn: _mir_r14(w, nnn))
    reg('r15-vysokaja-versija',
        'живы frozen/N/1 и /2, строка = id-тег — REPLACE ставит tag-object ВЫСШЕЙ заморозки (/2)',
        lambda w, nnn: _mir_r15(w, nnn))
    reg('r16-dogon-vtoroj-versii',
        'строка = tag-object frozen/N/1, жива /2 — догон: старая сторона = frozen/<vmax-1>',
        lambda w, nnn: _mir_r16(w, nnn))
    return K


def _mir_r02(w, nnn):
    m = Mir(w, nnn)
    idsha = m.mint()
    m.freeze(land=True, push_tega=False)
    return m, {'id': idsha, 'f1': m.rev('refs/tags/frozen/contracts/%s/1' % m.n)}


def _mir_r03(w, nnn):
    m = Mir(w, nnn)
    idsha = m.mint()
    m.freeze(land=False, push_tega=True)
    return m, {'id': idsha, 'f1': m.rev('refs/tags/frozen/contracts/%s/1' % m.n)}


def _mir_r04(w, nnn):
    m, d = Mir(w, nnn), None
    idsha = m.mint()
    m.freeze()
    m.zamenit_stroku('1234567890123456789012345678901234567890',
                     'правка строки (мир): посторонний sha')
    return m, {'id': idsha, 'f1': m.rev('refs/tags/frozen/contracts/%s/1' % m.n)}


def _mir_r05(w, nnn):
    m = Mir(w, nnn)
    idsha = m.mint()
    m.freeze()
    f1 = m.rev('refs/tags/frozen/contracts/%s/1' % m.n)
    m.zamenit_stroku(f1, 'правка строки (мир): уже заменено')
    return m, {'id': idsha, 'f1': f1}


def _mir_r06(w, nnn):
    m, d = Mir(w, nnn), None
    idsha = m.mint()
    m.freeze()
    (m.t / 'pomeha.tmp').write_text('грязь\n', encoding='utf-8')
    return m, {'id': idsha, 'f1': m.rev('refs/tags/frozen/contracts/%s/1' % m.n)}


def _mir_r07(w, nnn):
    m = Mir(w, nnn)
    idsha = m.mint()
    m.freeze()
    m.g('checkout', '-q', '-b', 'wip/%s/x' % m.n)
    return m, {'id': idsha, 'f1': m.rev('refs/tags/frozen/contracts/%s/1' % m.n),
               'vetka': 'wip/%s/x' % m.n}


def _mir_r08(w, nnn):
    m = Mir(w, nnn)
    idsha = m.mint()
    m.freeze()
    # авторитет ушёл вперёд: второй клон коммитит и пушит в origin main
    k2 = m.w / 'k2'
    run(['git', 'clone', '-q', str(m.w / 'orig.git'), str(k2)])
    (k2 / 'dopolnenie.txt').write_text('авторитет ушёл вперёд\n', encoding='utf-8')
    run(['git', '-C', str(k2), '-c', 'commit.gpgsign=false',
         '-c', 'user.name=orchestrator', '-c', 'user.email=orchestrator@local',
         'add', '-A'])
    run(['git', '-C', str(k2), '-c', 'commit.gpgsign=false',
         '-c', 'user.name=orchestrator', '-c', 'user.email=orchestrator@local',
         'commit', '-q', '-m', 'авторитет ушёл вперёд'])
    run(['git', '-C', str(k2), 'push', '-q', 'origin', 'main'])
    return m, {'id': idsha, 'f1': m.rev('refs/tags/frozen/contracts/%s/1' % m.n),
               'origin_main': m.out('ls-remote', 'origin', 'refs/heads/main').split()[0],
               'local_main': m.rev('refs/heads/main')}


def _mir_r09(w, nnn):
    m = Mir(w, nnn)
    idsha = m.mint()
    m.freeze()
    pustoj = m.w / 'pustoj-hookdir'
    pustoj.mkdir(parents=True, exist_ok=True)
    m.git('config', 'core.hooksPath', str(pustoj))
    return m, {'id': idsha, 'f1': m.rev('refs/tags/frozen/contracts/%s/1' % m.n),
               'pustoj': str(pustoj)}


def _mir_r10(w, nnn):
    m = Mir(w, nnn)
    m.freeze()   # заморозка и ленд есть, минта строки нет
    return m, {'id': None, 'f1': m.rev('refs/tags/frozen/contracts/%s/1' % m.n)}


def _mir_r11(w, nnn):
    m = Mir(w, nnn)
    idsha = m.mint()
    m.freeze()
    kommit = m.out('rev-parse', 'refs/tags/frozen/contracts/%s/1^{}' % m.n)
    m.git('tag', '-d', 'frozen/contracts/%s/1' % m.n)
    m.git('tag', 'frozen/contracts/%s/1' % m.n, kommit)
    return m, {'id': idsha, 'f1': m.rev('refs/tags/frozen/contracts/%s/1' % m.n)}


def _mir_r12(w, nnn):
    m = Mir(w, nnn)
    idsha = m.mint()
    m.freeze()
    star = m.stroka_nn()
    with open(m.manifest_fajl(), 'a', encoding='utf-8') as f:
        f.write('%s\n' % star)
    m.g('add', '-A')
    m.g('commit', '-q', '-m', 'дубль строки (мир)')
    m.g('push', '-q', 'origin', 'main')
    return m, {'id': idsha, 'f1': m.rev('refs/tags/frozen/contracts/%s/1' % m.n)}


def _mir_r13(w, nnn):
    m = Mir(w, nnn)
    idsha = m.mint()
    m.freeze()
    original = m.rev('refs/tags/frozen/contracts/%s/1' % m.n)
    drugoj = m.out('rev-parse', 'HEAD~1')
    m.git('tag', '-d', 'frozen/contracts/%s/1' % m.n)
    m.g('tag', '-a', 'frozen/contracts/%s/1' % m.n, '-m', 'переминт (мир)', drugoj)
    return m, {'id': idsha, 'f1': m.rev('refs/tags/frozen/contracts/%s/1' % m.n),
               'origin_f1': original}


def _mir_r14(w, nnn):
    m = Mir(w, nnn)
    idsha = m.mint()
    m.freeze()
    m.git('remote', 'set-url', 'origin', str(m.w / 'set-netu'))
    return m, {'id': idsha, 'f1': m.rev('refs/tags/frozen/contracts/%s/1' % m.n)}


def _mir_r15(w, nnn):
    m = Mir(w, nnn)
    idsha = m.mint()
    m.freeze()
    m.freeze_v2()
    return m, {'id': idsha, 'f1': m.rev('refs/tags/frozen/contracts/%s/1' % m.n),
               'f2': m.rev('refs/tags/frozen/contracts/%s/2' % m.n)}


def _mir_r16(w, nnn):
    m = Mir(w, nnn)
    idsha = m.mint()
    m.freeze()
    f1 = m.rev('refs/tags/frozen/contracts/%s/1' % m.n)
    m.freeze_v2()
    m.zamenit_stroku(f1, 'правка строки (мир): догон с v1')
    return m, {'id': idsha, 'f1': f1,
               'f2': m.rev('refs/tags/frozen/contracts/%s/2' % m.n)}


# ожидание клетки: (rc, stdout, stderr); для зелёных stdout реконструируется
# по миру ПОСЛЕ прогона (rev-parse HEAD) — см. шапку
def ozhidanija(imja, m, d, posle):
    n = m.n
    if imja == 'r01-chestnyj-replace':
        return (0, ('REPLACED nnn=%s old=%s new=%s commit=%s\n'
                    % (n, d['id'], d['f1'], posle['head'])).encode('utf-8'), DVOR)
    if imja == 'r02-teg-ne-na-origin':
        return ozh_otkaz('тег frozen/contracts/%s/1 не выдан авторитетом: тег не достижим на origin (self-freeze)' % n)
    if imja == 'r03-zamorozka-ne-predok-main':
        return ozh_otkaz('коммит заморозки %s (frozen/contracts/%s/1) не предок origin/main — ленд носителя заморозки не состоялся (publish тега недостаточно)'
                         % (d['freeze_commit'], n))
    if imja == 'r04-staraja-stroka-chuzhaja':
        return ozh_otkaz('sha старой строки ≠ ни tag-object id/CONTRACT/%s, ни tag-object frozen/contracts/%s/0' % (n, n))
    if imja == 'r05-povtornyj-replace':
        return ozh_otkaz('повторный REPLACE — строка %s уже указывает на tag-object frozen/contracts/%s/1' % (n, n))
    if imja == 'r06-grjaznoe-derevo':
        return ozh_otkaz('грязное дерево — коммит строки реестра обязан быть единственным предметом')
    if imja == 'r07-ne-main':
        return ozh_otkaz('HEAD не main (текущая ветка: %s) — строка реестра коммитится только на main' % d['vetka'])
    if imja == 'r08-main-rashoditsja':
        return ozh_otkaz('main разошёлся с origin/main (локально %s, на origin %s) — выровняй main с origin/main и повтори'
                         % (d['local_main'], d['origin_main']))
    if imja == 'r09-dver-otkljuchena':
        return ozh_otkaz('дверь 031 отключена конфигом (эффективный hooks-каталог %s без исполняемого pre-commit) — строка реестра коммитится только сквозь живую дверь' % d['pustoj'])
    if imja == 'r10-stroki-net':
        return ozh_otkaz('строки %s нет в манифесте — REPLACE нечего менять' % n)
    if imja == 'r11-frozen-ljogkij':
        return ozh_otkaz('тег frozen/contracts/%s/1 не аннотированный' % n)
    if imja == 'r12-dve-stroki':
        return ozh_otkaz('строк %s в манифесте не одна (2) — REPLACE неоднозначен' % n)
    if imja == 'r13-drejf-frozen':
        return ozh_otkaz('переминт заморозки: sha локального frozen/contracts/%s/1 (%s) ≠ sha тега на origin (%s)'
                         % (n, d['f1'], d['origin_f1']))
    if imja == 'r14-avtoritet-nedostupen':
        return ozh_otkaz('авторитет недоступен (ls-remote origin не ответил, rc=128) — fail-closed, обрыв сети НЕ пишет строку')
    if imja == 'r15-vysokaja-versija':
        return (0, ('REPLACED nnn=%s old=%s new=%s commit=%s\n'
                    % (n, d['id'], d['f2'], posle['head'])).encode('utf-8'), DVOR)
    if imja == 'r16-dogon-vtoroj-versii':
        return (0, ('REPLACED nnn=%s old=%s new=%s commit=%s\n'
                    % (n, d['f1'], d['f2'], posle['head'])).encode('utf-8'), DVOR)
    raise AssertionError('нет ожидания для %s' % imja)


ZELENYE = ('r01-chestnyj-replace', 'r15-vysokaja-versija', 'r16-dogon-vtoroj-versii')




# ── прогон одной клетки ──────────────────────────────────────────────────────
def vyzvat(subjekt, t, n):
    return run(['bash', str(subjekt), '--root', str(t), '--nnn', n], timeout=240)


def sravnit(imja, r, ozh):
    orc, out_c, err_c = ozh
    prichiny = []
    if r.returncode != orc:
        prichiny.append('rc %d ≠ %d' % (r.returncode, orc))
    if r.stdout != bajty(out_c):
        prichiny.append('stdout байт-в-байт ≠ ожиданию: факт %r / ожидание %r'
                        % (diag(r.stdout, 80), diag(bajty(out_c), 80)))
    if r.stderr != bajty(err_c):
        prichiny.append('stderr байт-в-байт ≠ ожиданию: факт %r / ожидание %r'
                        % (diag(r.stderr, 120), diag(bajty(err_c), 120)))
    return prichiny


def post_problemy(imja, m, d, pre):
    prichiny = []
    posle_head = m.rev('HEAD')
    posle_manifest = m.manifest_fajl().read_bytes()
    status = m.out('status', '--porcelain')
    if imja in ZELENYE:
        if posle_head == pre['head']:
            prichiny.append('пост: HEAD не двинулся (коммита нет)')
        cnt = m.out('rev-list', '--count', '%s..HEAD' % pre['head'])
        if cnt != '1':
            prichiny.append('пост: коммитов %s ≠ 1' % cnt)
        ozh_manifest = pre['manifest'].replace(
            ('%s\n' % pre['staraja_stroka']).encode('utf-8'),
            ('%s → %s\n' % (m.n, d['novyj'])).encode('utf-8'), 1)
        if m.show_bytes('HEAD:registry/contracts.tsv') != ozh_manifest:
            prichiny.append('пост: манифест HEAD ≠ «ровно одна строка заменена, прочие байты целы»')
        ident = m.out('log', '-1', '--format=%an|%ae|%cn|%ce')
        if ident != 'orchestrator|orchestrator@dev-harness.local|orchestrator|orchestrator@dev-harness.local':
            prichiny.append('пост: identity %r ≠ orchestrator' % ident)
        if status:
            prichiny.append('пост: дерево грязное после успеха: %r' % status)
    else:
        if posle_head != pre['head']:
            prichiny.append('пост: HEAD двинулся на отказе')
        if posle_manifest != pre['manifest_fajl']:
            prichiny.append('пост: манифест worktree мутирован на отказе')
        if status != pre['status']:
            prichiny.append('пост: отказ добавил грязь (было %r, стало %r)'
                            % (pre['status'], status))
    return prichiny


def prognot_kletku(imja, kejs, subjekt, s_post=True):
    tmp = tempfile.mkdtemp(prefix='zamena212-')
    try:
        nnn = random.choice(NNN_POOL)
        m, d = kejs[imja]['postroit'](tmp, nnn)
        pre = {'head': m.rev('HEAD'),
               'manifest': m.show_bytes('HEAD:registry/contracts.tsv'),
               'manifest_fajl': m.manifest_fajl().read_bytes(),
               'status': m.out('status', '--porcelain'),
               'staraja_stroka': m.stroka_nn()}
        d['novyj'] = d.get('f2', d.get('f1'))
        if imja == 'r03-zamorozka-ne-predok-main':
            d['freeze_commit'] = m.out('rev-parse', 'refs/tags/frozen/contracts/%s/1^{}' % m.n)
        r = vyzvat(subjekt, m.t, m.n)
        posle = {'head': m.rev('HEAD')}
        ozh = ozhidanija(imja, m, d, posle)
        prichiny = sravnit(imja, r, ozh)
        if s_post:
            prichiny += post_problemy(imja, m, d, pre)
        return prichiny
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


ARGV_KEJSY = ('n01-grammatika-nnn', 'n02-root-ne-katalog', 'n03-bez-nnn',
              'n04-nnn-novaja-stroka', 'n05-nnn-crlf', 'n06-nnn-dlinnyj')

# ── argv-клетки (без миров) ─────────────────────────────────────────────────
def argv_kletki(subjekt, koren_tmp):
    rez = {}
    r = run(['bash', str(subjekt), '--nnn', '12x'], cwd=str(koren_tmp))
    rez['n01-grammatika-nnn'] = sravnit(
        'n01', r, (2, b'',
                   ('NOT_IMPLEMENTED: --nnn вне грамматики [0-9]{1,3}: 12x\n').encode('utf-8')))
    netu = Path(koren_tmp) / 'net-kataloga-212'
    r = run(['bash', str(subjekt), '--nnn', '5', '--root', str(netu)], cwd=str(koren_tmp))
    rez['n02-root-ne-katalog'] = sravnit(
        'n02', r, (2, b'', ('NOT_IMPLEMENTED: --root не каталог: %s\n' % netu).encode('utf-8')))
    r = run(['bash', str(subjekt)], cwd=str(koren_tmp))
    rez['n03-bez-nnn'] = sravnit(
        'n03', r, (1, b'',
                   ('replace_line: --nnn обязателен\n').encode('utf-8') + USAGE))
    for imja, arg in zip(ARGV_KEJSY[3:], ('12\n34', '12\r\n', '1234')):
        r = run(['bash', str(subjekt), '--nnn', arg], cwd=str(koren_tmp))
        rez[imja] = sravnit(imja, r, (2, b'',
            ('NOT_IMPLEMENTED: --nnn вне грамматики [0-9]{1,3}: %s\n' % arg).encode('utf-8')))
    return rez


# ── обманные стабы: якорь кратности 1 в тексте модели → мутация ─────────────
def _mut(tekst, jakor, zamena):
    n = tekst.count(jakor)
    assert n == 1, 'якорь не кратен 1 (%d): %r' % (n, jakor[:80])
    return tekst.replace(jakor, zamena, 1)


LOZH = 'if false; then'

STAB_MUTACII = {
    'st01-povtor-propuschen': (
        'if [ "$OLD_SHA" = "$NEW_SHA" ]; then', LOZH),
    'st02-teg-origin-ne-sverjaetsja': (
        'if [ -z "$sha_origin" ]; then', LOZH),
    'st03-setevoj-otkaz-prodolzhaet': (
        'if [ "$ls_rc" -ne 0 ]; then', LOZH),
    'st04-predok-ne-proverjaetsja': (
        'if ! git -C "$ROOT" merge-base --is-ancestor "$FREEZE_COMMIT" "$ORIGIN_MAIN" 2>/dev/null; then',
        LOZH),
    'st05-staraja-stroka-ne-sverjaetsja': (
        'if [ "$old_ok" -ne 1 ]; then', LOZH),
    'st06-main-rashozhdenie-propuscheno': (
        'if [ "$LOCAL_MAIN" != "$ORIGIN_MAIN" ]; then', LOZH),
    'st07-awk-inversija': (
        "$0 == o { print n; next } { print }",
        "$0 != o { print n; next } { print }"),
    'st08-grjaznoe-propuscheno': (
        'if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then', LOZH),
    'st09-ne-main-propuschen': (
        'if [ "$current_head" != "main" ]; then', LOZH),
    'st10-dver-disarm-propuschen': (
        'if [ ! -x "$HOOKS_DIR/pre-commit" ]; then', LOZH),
    'st11-nizshaja-versija': (
        '| sort -n | tail -1', '| sort -n | head -1'),
    'st12-annotirovannost-propuschena': (
        'if [ "$new_tag_type" != "tag" ]; then', LOZH),
    'st13-stroki-net-propuscheno': (
        'if [ "$cnt" -eq 0 ]; then', LOZH),
    'st14-identitet-consultant': (
        'GIT_AUTHOR_NAME=orchestrator GIT_AUTHOR_EMAIL=orchestrator@dev-harness.local',
        'GIT_AUTHOR_NAME=consultant GIT_AUTHOR_EMAIL=consultant@dev-harness.local'),
    'st15-no-verify-injekcija': (
        'git -C "$ROOT" commit -q --no-gpg-sign -m "реестр: REPLACE строки $NNN (replace_line, контракт 212)"',
        'git -C "$ROOT" commit -q --no-gpg-sign --no-verify -m "реестр: REPLACE строки $NNN (replace_line, контракт 212)"'),
    'st16-hookspath-injekcija': (
        'git -C "$ROOT" commit -q --no-gpg-sign -m "реестр: REPLACE строки $NNN (replace_line, контракт 212)"',
        'git -C "$ROOT" -c core.hooksPath=/dev/null commit -q --no-gpg-sign -m "реестр: REPLACE строки $NNN (replace_line, контракт 212)"'),
    'st17-drejf-propuschen': (
        'if [ "$NEW_SHA" != "$sha_origin" ]; then', LOZH),
    'st18-dogon-staraja-storona': (
        'if [ "$old_ok" -eq 0 ]; then', LOZH),
    'st19-dubl-propuschen': (
        'if [ "$cnt" -ne 1 ]; then', LOZH),
    'st40-konstanta-nomera': (
        'NNN="$(printf \'%03d\' "$((10#$NNN_ARG))")"', 'NNN="212"'),
}

STAB_VHOD = {
    'st01-povtor-propuschen': ['r05-povtornyj-replace'],
    'st02-teg-origin-ne-sverjaetsja': ['r02-teg-ne-na-origin'],
    'st03-setevoj-otkaz-prodolzhaet': ['r14-avtoritet-nedostupen'],
    'st04-predok-ne-proverjaetsja': ['r03-zamorozka-ne-predok-main'],
    'st05-staraja-stroka-ne-sverjaetsja': ['r04-staraja-stroka-chuzhaja'],
    'st06-main-rashozhdenie-propuscheno': ['r08-main-rashoditsja'],
    'st07-awk-inversija': ['r01-chestnyj-replace'],
    'st08-grjaznoe-propuscheno': ['r06-grjaznoe-derevo'],
    'st09-ne-main-propuschen': ['r07-ne-main'],
    'st10-dver-disarm-propuschen': ['r09-dver-otkljuchena'],
    'st11-nizshaja-versija': ['r15-vysokaja-versija'],
    'st12-annotirovannost-propuschena': ['r11-frozen-ljogkij'],
    'st13-stroki-net-propuscheno': ['r10-stroki-net'],
    'st14-identitet-consultant': ['r01-chestnyj-replace'],
    'st15-no-verify-injekcija': ['r01-chestnyj-replace'],
    'st16-hookspath-injekcija': ['r01-chestnyj-replace'],
    'st17-drejf-propuschen': ['r13-drejf-frozen'],
    'st18-dogon-staraja-storona': ['r16-dogon-vtoroj-versii'],
    'st19-dubl-propuschen': ['r12-dve-stroki'],
    'st40-konstanta-nomera': ['r01-chestnyj-replace'],
}

# ── границы наблюдения (rc, stdout bytes, stderr bytes) — К-10 ───────────────
# Мутация ОДНОЙ операции печати честной модели: тексты ветвей и rc не меняются —
# меняются только ВЫХОДНЫЕ БАЙТЫ и/или труба. На каждую трубу — восемь границ
# байтов (CRLF, одиночный CR, пробел в конце, двойной LF, BOM, NUL, не-UTF8,
# лишняя строка), перенос в другую трубу и лишняя строка в ТИХОЙ трубе:
# stderr/otkaz — st20…st29, stdout/REPLACED — st30…st39. Поля — escape-строки
# bash printf: в файле стаба только ASCII, сами байты рождает печать двери.
OTKAZ_STROKA = "  printf 'ОТКАЗ: %s\\n' \"$*\" >&2"
REPLACED_STROKA = ("printf 'REPLACED nnn=%s old=%s new=%s commit=%s\\n' "
                   "\"$NNN\" \"$OLD_SHA\" \"$NEW_SHA\" \"$COMMIT_SHA\"")
OTKAZ_FORMAT = "'ОТКАЗ: %s\\n'"
REPLACED_FORMAT = "'REPLACED nnn=%s old=%s new=%s commit=%s\\n'"

GRANICY = ('crlf', 'odinochnyj-cr', 'probel-v-konce', 'dvojnoj-lf',
           'bom', 'nul', 'ne-utf8', 'lishnij-vyvod')


def granica_formata(fmt, vid):
    vnutri = fmt[1:-1]
    if vid == 'crlf':
        vnutri = vnutri.replace('\\n', '\\r\\n')
    elif vid == 'odinochnyj-cr':
        vnutri = vnutri.replace('\\n', '\\r')
    elif vid == 'probel-v-konce':
        vnutri = vnutri.replace('%s\\n', '%s \\n')
    elif vid == 'dvojnoj-lf':
        vnutri = vnutri.replace('\\n', '\\n\\n')
    elif vid == 'bom':
        vnutri = '\\xEF\\xBB\\xBF' + vnutri
    elif vid == 'nul':
        vnutri = vnutri.replace('%s\\n', '%s\\x00\\n')
    elif vid == 'ne-utf8':
        vnutri = '\\xFF' + vnutri
    elif vid == 'lishnij-vyvod':
        vnutri = vnutri.replace('\\n', '\\nLISHNJAJA stroka\\n')
    return "'" + vnutri + "'"


def _dobavit_granicy():
    nomer = 20
    for vid in GRANICY:
        imja = 'st%02d-otkaz-%s' % (nomer, vid)
        STAB_MUTACII[imja] = (OTKAZ_FORMAT, granica_formata(OTKAZ_FORMAT, vid))
        STAB_VHOD[imja] = ['r02-teg-ne-na-origin', 'r05-povtornyj-replace',
                           'r14-avtoritet-nedostupen']
        nomer += 1
    imja = 'st28-otkaz-perenos'
    STAB_MUTACII[imja] = (OTKAZ_STROKA, "  printf 'ОТКАЗ: %s\\n' \"$*\"")
    STAB_VHOD[imja] = ['r02-teg-ne-na-origin', 'r05-povtornyj-replace',
                       'r14-avtoritet-nedostupen']
    imja = 'st29-otkaz-lishnij-v-stdout'
    STAB_MUTACII[imja] = (OTKAZ_STROKA,
                          "  printf 'LISHNJAJA stroka\\n'\n" + OTKAZ_STROKA)
    STAB_VHOD[imja] = ['r02-teg-ne-na-origin', 'r05-povtornyj-replace',
                       'r14-avtoritet-nedostupen']
    nomer = 30
    for vid in GRANICY:
        imja = 'st%02d-replaced-%s' % (nomer, vid)
        STAB_MUTACII[imja] = (REPLACED_FORMAT, granica_formata(REPLACED_FORMAT, vid))
        STAB_VHOD[imja] = ['r01-chestnyj-replace', 'r15-vysokaja-versija']
        nomer += 1
    imja = 'st38-replaced-perenos'
    STAB_MUTACII[imja] = ('"$OLD_SHA" "$NEW_SHA" "$COMMIT_SHA"',
                          '"$OLD_SHA" "$NEW_SHA" "$COMMIT_SHA" >&2')
    STAB_VHOD[imja] = ['r01-chestnyj-replace', 'r15-vysokaja-versija']
    imja = 'st39-replaced-lishnij-v-stderr'
    STAB_MUTACII[imja] = (REPLACED_STROKA,
                          "printf 'LISHNJAJA stroka\\n' >&2\n" + REPLACED_STROKA)
    STAB_VHOD[imja] = ['r01-chestnyj-replace', 'r15-vysokaja-versija']


_dobavit_granicy()


def tekst_modeli():
    # байты файла, декодированные без перевода строк: стаб отличается от
    # модели ровно одной мутацией
    return MODEL.read_bytes().decode('utf-8')


def sgeneriruj():
    tekst = tekst_modeli()
    if STABS.is_dir():
        shutil.rmtree(STABS)
    STABS.mkdir(parents=True)
    for imja, (jakor, zamena) in sorted(STAB_MUTACII.items()):
        mut = _mut(tekst, jakor, zamena)
        d = STABS / imja
        d.mkdir()
        (d / 'replace_line.sh').write_bytes(mut.encode('utf-8'))
    K = kejsy()
    nositeli = {'model/replace_line.sh': sha256_bytes(MODEL.read_bytes())}
    for imja in sorted(STAB_MUTACII):
        put = STABS / imja / 'replace_line.sh'
        nositeli['stabs/%s/replace_line.sh' % imja] = sha256_bytes(put.read_bytes())
    src = {
        'versija': 1,
        'kontrakt': 'contracts/212-replace-posle-lenda.md',
        'subjekt': SUBJ_IMJA,
        'model': 'model/replace_line.sh',
        'kejsy': {k: K[k]['opisanie'] for k in K},
        'stab_vhod': dict(STAB_VHOD),
        'nositeli': nositeli,
    }
    SOURCE.write_text(json.dumps(src, ensure_ascii=False, indent=1,
                                 sort_keys=False) + '\n', encoding='utf-8')
    print('SGENERIROVANO stabov %d kletok %d' % (len(STAB_MUTACII), len(K) + len(ARGV_KEJSY)))
    return 0


def istochnik():
    if not SOURCE.is_file():
        print('ORACLE_TAMPERED: нет source.json', file=sys.stderr)
        sys.exit(2)
    return json.loads(SOURCE.read_text(encoding='utf-8'))


def nositeli_sverka(src):
    ploho = []
    for put, sha in src.get('nositeli', {}).items():
        fajl = HERE / put
        if not fajl.is_file():
            ploho.append('носитель исчез: %s' % put)
        elif sha256_bytes(fajl.read_bytes()) != sha:
            ploho.append('дрейф носителя: %s' % put)
    if ploho:
        for p in ploho:
            print('ORACLE_TAMPERED: %s' % p, file=sys.stderr)
        sys.exit(2)
    if src.get('stab_vhod') != STAB_VHOD:
        print('ORACLE_TAMPERED: множество стабов source.json ≠ матрице пробы',
              file=sys.stderr)
        sys.exit(2)


def zashita_zavisimostej():
    for b in ('git', 'bash'):
        if shutil.which(b) is None:
            print('NOT_IMPLEMENTED: нет %s' % b, file=sys.stderr)
            sys.exit(2)
    if not DOOR.is_file():
        print('NOT_IMPLEMENTED: нет живой двери батареи: %s' % DOOR, file=sys.stderr)
        sys.exit(2)


def subjekt_put(koren=None):
    if koren:
        p = Path(koren) / SUBJ_IMJA
    else:
        p = REPO / SUBJ_IMJA
    return p if p.is_file() else None


def progon_vseh(subjekt, s_post=True):
    K = kejsy()
    krasnye = []
    vhody = []
    for imja in K:
        prichiny = prognot_kletku(imja, K, subjekt, s_post=s_post)
        if prichiny:
            krasnye.append((imja, prichiny))
        vhody.append(imja)
    tmp = tempfile.mkdtemp(prefix='zamena212-argv-')
    try:
        for imja, prichiny in argv_kletki(subjekt, tmp).items():
            if prichiny:
                krasnye.append((imja, prichiny))
            vhody.append(imja)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    return krasnye, vhody


def pechat_krasnyh(krasnye, predmet):
    for imja, prichiny in krasnye:
        for p in prichiny:
            print('KRASNAJA-KLETKA %s: %s' % (imja, p))
    print('%s 212: KLETKI %d KRASNYH %d' % (predmet, len(kejsy()) + len(ARGV_KEJSY), len(krasnye)))


def rezhim_model():
    isto = istochnik()
    nositeli_sverka(isto)
    krasnye, _ = progon_vseh(MODEL, s_post=True)
    pechat_krasnyh(krasnye, 'MODEL')
    return 1 if krasnye else 0


def rezhim_stabs():
    isto = istochnik()
    nositeli_sverka(isto)
    krasnye, _ = progon_vseh(MODEL, s_post=True)
    pechat_krasnyh(krasnye, 'MODEL')
    if krasnye:
        return 1
    K = kejsy()
    svjazi = 0
    zhivye = []
    tekst = tekst_modeli()
    for imja in sorted(STAB_MUTACII):
        stab = STABS / imja / 'replace_line.sh'
        telo = stab.read_bytes().decode('utf-8')
        if telo == tekst:
            print('ORACLE_TAMPERED: стаб совпадает с моделью: %s' % imja,
                  file=sys.stderr)
            return 2
        syntax = run(['bash', '-n', str(stab)])
        if syntax.returncode != 0:
            print('ORACLE_TAMPERED: синтаксис стаба %s: %s' % (imja, diag(syntax.stderr)), file=sys.stderr)
            return 2
        for vhod in isto['stab_vhod'][imja]:
            svjazi += 1
            prichiny = prognot_kletku(vhod, K, stab, s_post=True)
            if not prichiny:
                zhivye.append('%s/%s' % (imja, vhod))
    for z in zhivye:
        print('STAB_ZHIV: %s не различим на связанном входе' % z,
              file=sys.stderr)
    print('STABY 212: SVJAZI %d ZHIVYH %d' % (svjazi, len(zhivye)))
    return 1 if zhivye else 0


def rezhim_repo(koren):
    subjekt = subjekt_put(koren)
    if subjekt is None:
        print('SUBJEKT 212: SUBJECT_ABSENT %s' % (koren or REPO))
        for imja in kejsy():
            print('VHOD: %s' % imja)
        for imja in ARGV_KEJSY:
            print('VHOD: %s' % imja)
        return 1
    krasnye, _ = progon_vseh(subjekt, s_post=True)
    pechat_krasnyh(krasnye, 'SUBJEKT')
    return 1 if krasnye else 0


def rezhim_sintaksis():
    zashita_zavisimostej()
    nositeli = [MODEL] + sorted(STABS.glob('*/replace_line.sh'))
    subjekt = subjekt_put()
    if subjekt is not None:
        nositeli.append(subjekt)
    ploho = []
    for f in nositeli:
        r = run(['bash', '-n', str(f)])
        if r.returncode != 0:
            ploho.append('bash -n %s: %s' % (f.name, diag(r.stderr)))
    if ploho:
        for p in ploho:
            print('SINTAKSIS KRASNO: %s' % p)
        return 1
    # Стандартный валидатор удостоверяет бинарь, включая ENV-шов; его
    # отсутствие/битый пин — rc 2, никогда не зелёный пропуск.
    chestnye = [MODEL, HERE / 'red_replace_posle_lenda_212.sh']
    if subjekt is not None:
        chestnye.append(subjekt)
    for f in chestnye:
        r = run(['bash', str(VALIDATE_STD), 'bash', str(f)])
        if r.returncode:
            print('SINTAKSIS: %s: %s' % (f, diag(r.stdout + r.stderr, 1000)), file=sys.stderr)
            return 2 if r.returncode == 2 else 1
    print('SINTAKSIS OK (bash -n: %d; пинованный shellcheck честных носителей: %d)' % (len(nositeli), len(chestnye)))
    return 0


def main():
    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument('--repo', nargs='?', const='', default=None)
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    ap.add_argument('--sgeneriruj-staby', action='store_true')
    ap.add_argument('--sintaksis', action='store_true')
    argj = ap.parse_args()

    if getattr(argj, 'sintaksis', False):
        return rezhim_sintaksis()
    zashita_zavisimostej()

    if argj.sgeneriruj_staby:
        return sgeneriruj()
    if argj.model:
        return rezhim_model()
    if argj.stabs:
        return rezhim_stabs()
    return rezhim_repo(argj.repo)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, subprocess.TimeoutExpired, RuntimeError, AssertionError, json.JSONDecodeError) as exc:
        print('NOT_IMPLEMENTED: проверка не исполнена: %s' % exc, file=sys.stderr)
        sys.exit(2)
