#!/usr/bin/env python3
# БАРЬЕР-ГУАРД контракта 152 (oom-sessii-i-zamki). Три предмета одной пачки:
#   (A/B) сторож «без эмуляторов/нативных сборок в scope сессии станции» —
#         ИСПОЛНЕНИЕМ с двойниками в PATH и журналом (урок арбитража 148:
#         статическая грамматика открытого языка shell — недо-приближение,
#         правило 7; решающий оракул — прогон в песочнице, суд по журналу);
#   (C)   замок 140: состояние pogib (факт-якорь session_exit) — авто-снятие
#         погибшего замка и немедленный --osvobodit, без 60-мин TTL;
#   (D)   orch-loop: OOM-литерал 085 по ФАКТУ юнита (Result=oom-kill), не
#         только по rc 137 (боль 31.10: rc=143 при oom-kill).
#
# Правило 8: оракул source.json читается в память ДО вызова субъекта; пины
# sha256 носителей сверяются ДО клеток; порча — rc 2 ORACLE_TAMPERED.
# Н-39: обманные стабы — мутации модели КОДОМ (stabs/*.py), привязки —
# ТОЛЬКО source.json:.stab_vhod; рассинхрон — rc 2. Каждый стаб привязан к
# входам, где его дефект наблюдаем (стаб «scope-пропуск» честен вне scope).
#
# Субъект — ТРОЙКА носителей: ops/server/user/dvojniki/ (каталог двойников),
# scripts/zamok_predmeta.sh (дверь замка), ops/server/user/orch-loop (цикл).
# Режимы:
#   (без флага)  субъект = дерево харнесса (носителей 152 нет → клетки красны
#                поимённо; двойников нет → SUBJECT_ABSENT для A/B)
#   --repo R     судится дерево R (до реализации красно, после — зелено)
#   --model      эталон model/: контроль входов (N/N зелёных)
#   --stabs      контроль + матрица обманных стабов (SVJAZI N, живых 0)
#   --oracle-tamper  порча носителей ловится: ORACLE_TAMPER_PROVERENO
#   --seed N     тот же итог при другом порядке клеток
# Коды: 0 — зелено; 1 — красная клетка / живой стаб (STAB_ZHIV) / SUBJECT_
# ABSENT; 2 — нечем проверять (нет bash/git/jq/pgrep, ORACLE_TAMPERED,
# дрейф стабов/носителей).
import argparse
import hashlib
import importlib.util
import json
import os
import random
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
HARNESS = HERE.parents[2]
MODEL_DVOS = HERE / 'model' / 'ops' / 'server' / 'user' / 'dvojniki'
MODEL_ZAMOK = HERE / 'model' / 'scripts' / 'zamok_predmeta.sh'
MODEL_ORCH = HERE / 'model' / 'ops' / 'server' / 'orch-loop' if False else \
    HERE / 'model' / 'ops' / 'server' / 'user' / 'orch-loop'
STABS = HERE / 'stabs'
ORACLE = HERE / 'source.json'

BASH = '/bin/bash'
REPO_ID = 'dev-harness'
LIT_OOM = 'OOM: omp убит потолком памяти'
NONCE = 'oomzamki152'

# имена двойников — замкнутый список установки (единый источник: каталог модели)
IMENA_DVOJNIKOV = ['_jadro.sh', 'emulator', 'emulator-headless', 'qemu-system',
                   'qemu-system-x86_64', 'qemu-system-i386',
                   'qemu-system-x86_64-headless', 'gradle', 'cmake', 'clang',
                   'clang++', 'prebuild', 'expo']
IMENA_NAST = ['emulator', 'emulator-headless', 'qemu-system', 'qemu-system-x86_64',
              'qemu-system-i386', 'qemu-system-x86_64-headless', 'gradle',
              'cmake', 'clang', 'clang++', 'prebuild', 'expo']


class OshibkaVoronki(Exception):
    pass


def run(cmd, cwd=None, env=None, timeout=90):
    return subprocess.run(cmd, cwd=cwd, env=env, capture_output=True,
                          text=True, timeout=timeout)


def sha256_bytes(b):
    return hashlib.sha256(b).hexdigest()


# ── оракул (правило 8: в память ДО субъекта) ─────────────────────────────────
def chitat_orakul():
    if not ORACLE.is_file():
        raise OshibkaVoronki('нет source.json')
    src = json.loads(ORACLE.read_text(encoding='utf-8'))
    na_diske = sorted(p.stem + '.py' for p in STABS.glob('s*.py')) if STABS.is_dir() else []
    stabil = sorted((src.get('stab_vhod') or {}).keys())
    if stabil != na_diske:
        raise OshibkaVoronki('дрейф стабов: source.json %s != диск %s' % (stabil, na_diske))
    return src


def nositeli_modeli():
    """носители модели: путь → байты (для пинов и стабов)."""
    nos = {('dvojniki/' + im): (MODEL_DVOS / im).read_bytes()
           for im in IMENA_DVOJNIKOV}
    nos['scripts/zamok_predmeta.sh'] = MODEL_ZAMOK.read_bytes()
    nos['ops/server/user/orch-loop'] = MODEL_ORCH.read_bytes()
    return nos


def proverit_piny(nos, src):
    piny = src.get('nositeli') or {}
    for put, bajty in nos.items():
        if put in piny and sha256_bytes(bajty) != piny[put]:
            raise OshibkaVoronki('носитель %s расходится с пином' % put)
    nept = sorted(set(piny) - set(nos))
    if nept:
        raise OshibkaVoronki('пины без носителей: %s' % nept)


# ── мир сторожа (блоки A/B) ──────────────────────────────────────────────────
class MirStorozh:
    def __init__(self, root, dvojnik_katalog):
        self.root = Path(root)
        self.home = self.root / 'home'
        self.dvoj = self.root / 'dvojniki'
        self.nast = self.root / 'nast'
        for d in (self.home, self.nast):
            d.mkdir(parents=True, exist_ok=True)
        shutil.copytree(dvojnik_katalog, self.dvoj)
        for im in IMENA_NAST:                      # «настоящие» бинари мира
            f = self.nast / im
            f.write_text('#!/usr/bin/env bash\n'
                         'printf \'%%s\\t%s\\t%%s\\n\' "$(date -u +%%FT%%TZ)" "$*" >> "%s/ran.tsv"\n'
                         'exit 0\n' % (im, self.root), encoding='utf-8')
            f.chmod(0o755)
        (self.home / 'README.md').write_text('emulator qemu-system gradle clang\n', encoding='utf-8')
        (self.home / 'build.gradle').write_text('// gradle текст как данные\n', encoding='utf-8')

    def env(self, scope):
        e = {'PATH': '%s:%s:/usr/local/bin:/usr/bin:/bin' % (self.dvoj, self.nast),
             'HOME': str(self.home),
             'XDG_STATE_HOME': str(self.home / '.local' / 'state'),
             'LANG': 'C.UTF-8', 'TMPDIR': str(self.root)}
        if scope:
            e['ORCH_SESSION_SCOPE'] = '1'
        return e

    def zapusk(self, komanda, scope, cwd=None):
        """scope=True — прямой запуск с маркером; scope=False — запуск с
        kernel-фактом ВНЕ orch-session scope: сам звонящий на станции живёт
        внутри scope (замер: cgroup orch-session-243461-4.scope), потому
        «вне scope» строится одноразовым СИБЛИНГ-скопом systemd-run (юниты
        не вкладываются: новый scope — брат, не потомок); на CI (факта нет
        у самого звонящего) — прямой запуск. Сиблинг недоступен — отказ
        имени, не молчаливая зелень."""
        env = self.env(scope)
        if scope:
            return run([BASH, '-c', komanda], cwd=cwd or str(self.home),
                       env=env, timeout=60)
        try:
            sobstvennyj = Path('/proc/self/cgroup').read_text(encoding='utf-8')
        except OSError:
            sobstvennyj = ''
        if 'orch-session-' not in sobstvennyj:
            return run([BASH, '-c', komanda], cwd=cwd or str(self.home),
                       env=env, timeout=60)
        if not shutil.which('systemd-run'):
            raise OshibkaVoronki('нет systemd-run: мир «вне scope» на станции не строится')
        import uuid
        unit = 'oom-zamki-152-%s.scope' % uuid.uuid4().hex[:12]
        env_shina = dict(env)
        for k in ('XDG_RUNTIME_DIR', 'DBUS_SESSION_BUS_ADDRESS'):
            if os.environ.get(k):
                env_shina[k] = os.environ[k]
        return run(['systemd-run', '--user', '--scope', '-q', '--unit=' + unit,
                    '--', BASH, '-c', komanda], cwd=cwd or str(self.home),
                   env=env_shina, timeout=60)

    def zhurnal(self):
        f = self.home / '.local' / 'state' / 'dev-harness' / 'strogo-stancii.tsv'
        if not f.is_file():
            return []
        return [ln.split('\t') for ln in f.read_text(encoding='utf-8').splitlines() if ln]

    def ran(self):
        f = self.root / 'ran.tsv'
        if not f.is_file():
            return []
        return f.read_text(encoding='utf-8').splitlines()

    def poddelka_qemu(self, nomer):
        """живой процесс мира с qemu-system в cmdline (pgrep -f двойника
        видит argv ПОЛНОСТЬЮ: exec заменил бы cmdline на 'sleep 600' — потому
        подделка живёт сама, циклом, не exec'ом)."""
        f = self.nast / ('qemu-system-fake-%s-%d' % (NONCE, nomer))
        f.write_text('#!/usr/bin/env bash\nwhile :; do sleep 600; done\n', encoding='utf-8')
        f.chmod(0o755)
        p = subprocess.Popen([str(f)], env={'PATH': '/usr/bin:/bin', 'HOME': str(self.home)},
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                             start_new_session=True)
        return p


def zhurnal_soderzhit(mir, imja):
    return any(len(r) >= 3 and r[2] == imja for r in mir.zhurnal())


# клетки A: имя × формы запуска; все формы обязаны отказать с журналом
FORMY = ['bare', 'bash-c', 'env']
KOMANDY = {
    'emulator': {'bare': 'emulator -avd proba', 'bash-c': 'bash -c \'emulator -avd proba\'',
                 'env': 'env emulator -avd proba'},
    'qemu-system-x86_64': {'bare': 'qemu-system-x86_64 -m 2048',
                           'bash-c': 'bash -c \'qemu-system-x86_64 -m 2048\'',
                           'env': 'env qemu-system-x86_64 -m 2048'},
    'gradle': {'bare': 'gradle assembleDebug', 'bash-c': 'bash -c \'gradle assembleDebug\'',
               'env': 'env gradle assembleDebug'},
    'cmake': {'bare': 'cmake -B build', 'bash-c': 'bash -c \'cmake -B build\'',
              'env': 'env cmake -B build'},
    'clang': {'bare': 'clang -c main.c', 'bash-c': 'bash -c \'clang -c main.c\'',
              'env': 'env clang -c main.c'},
    'clang++': {'bare': 'clang++ -c main.cpp', 'bash-c': 'bash -c \'clang++ -c main.cpp\'',
                'env': 'env clang++ -c main.cpp'},
    'prebuild': {'bare': 'prebuild --android', 'bash-c': 'bash -c \'prebuild --android\'',
                 'env': 'env prebuild --android'},
}


def kletka_imeni(mir, imja):
    """клетка A-блока: ВСЕ формы отказа, rc 1, именованная причина, строка журнала."""
    for forma in FORMY:
        r = mir.zapusk(KOMANDY[imja][forma], scope=True)
        if r.returncode != 1:
            return 'форма %s: rc %d ≠ 1 (stderr=%s)' % (forma, r.returncode, r.stderr.strip()[:120])
        if not r.stderr.startswith('ОТКАЗ: STROGO_SCOPE:'):
            return 'форма %s: причина не STROGO_SCOPE: %s' % (forma, r.stderr.strip()[:120])
        if not zhurnal_soderzhit(mir, imja):
            return 'форма %s: строки журнала с именем %s нет' % (forma, imja)
    return None


SEMEJSTVO = ['qemu-system', 'qemu-system-i386', 'qemu-system-x86_64-headless',
             'emulator-headless']


# ── мир замка (блок C) ───────────────────────────────────────────────────────
class MirZamok:
    def __init__(self, root, dver):
        self.root = Path(root)
        self.sost = self.root / 'sost'
        self.zhurnaly = self.root / 'zhurnaly'
        self.parent = self.zhurnaly / 'rod-152'
        self.repo = self.root / 'repo'
        self.ledger = self.sost / 'uchet.jsonl'
        for d in (self.sost, self.parent, self.repo / 'contracts', self.repo / 'registry'):
            d.mkdir(parents=True, exist_ok=True)
        self.ledger.touch()
        self.dver = str(dver)
        g = run(['git', 'init', '-q', '.'], cwd=str(self.repo))
        assert g.returncode == 0, g.stderr
        run(['git', '-C', str(self.repo), 'remote', 'add', 'origin',
             'git@host:owner/dev-harness.git'])
        run(['git', '-c', 'user.name=b', '-c', 'user.email=b@t', '-c',
             'commit.gpgsign=false', '-C', str(self.repo), 'commit', '-q',
             '--allow-empty', '-m', 'init'])
        f = self.repo / 'contracts' / '152-stub.md'
        f.write_text('# К\nКЛАСС РИСКА: обычный\n', encoding='utf-8')
        run(['git', '-C', str(self.repo), 'add', '-A'])
        run(['git', '-c', 'user.name=b', '-c', 'user.email=b@t', '-c',
             'commit.gpgsign=false', '-C', str(self.repo), 'commit', '-q', '-m', 'c152'])
        self.wt = self.root / 'wt152'
        self.wt.mkdir(parents=True, exist_ok=True)
        run(['git', 'init', '-q', '.'], cwd=str(self.wt))
        run(['git', '-C', str(self.wt), 'remote', 'add', 'origin',
             'git@host:owner/dev-harness.git'])
        run(['git', '-C', str(self.wt), 'checkout', '-q', '-b', 'wip/152/avtor'])
        run(['git', '-c', 'user.name=b', '-c', 'user.email=b@t', '-c',
             'commit.gpgsign=false', '-C', str(self.wt), 'commit', '-q',
             '--allow-empty', '-m', 'w'])
        self.tip = run(['git', '-C', str(self.wt), 'rev-parse', 'HEAD']).stdout.strip()

    def zhurnal(self, holder, sdal=False, okonchenie=None, vozrast_min=5):
        """журнал holder внутри parent-каталога; okonchenie: signal|normal."""
        f = self.parent / ('%s.jsonl' % holder)
        telo = '{"timestamp":"2026-10-31T10:00:00.000Z","message":{"role":"assistant"}}\n'
        if sdal:
            telo += ('{"type":"toolResult","toolCallId":"toolu_x","toolName":"yield",'
                     '"content":[{"type":"text","text":"Result submitted."}]}\n')
        if okonchenie:
            telo += ('{"type":"custom","customType":"session_exit","data":{"reason":"%s",'
                     '"kind":"signal"},"timestamp":"2026-10-31T12:01:04.199Z"}\n'
                     % ('sigterm' if okonchenie == 'signal' else 'dispose'))
        f.write_text(telo, encoding='utf-8')
        was = time.time() - vozrast_min * 60
        os.utime(str(f), (was, was))

    def zhurnal_roditelja(self, okonchenie='signal'):
        f = self.zhurnaly / 'rod-152.jsonl'
        telo = '{"timestamp":"2026-10-31T10:00:00.000Z","message":{"role":"user"}}\n'
        telo += ('{"type":"custom","customType":"session_exit","data":{"reason":"%s",'
                 '"kind":"signal"},"timestamp":"2026-10-31T12:01:04.348Z"}\n'
                 % ('sigterm' if okonchenie == 'signal' else 'dispose'))
        f.write_text(telo, encoding='utf-8')

    def start(self, holder, klass='rabochij', rol='architect'):
        zd = self.sost / 'zamki' / REPO_ID / '152' / 'zanyat'
        zd.mkdir(parents=True, exist_ok=True)
        (zd / 'holder.json').write_text(json.dumps(
            {'holder': holder, 'klass': klass, 'rol': rol, 'object': '-',
             'startedAt': '2026-10-31T10:00:00Z'}) + '\n', encoding='utf-8')
        with self.ledger.open('a', encoding='utf-8') as fh:
            fh.write(json.dumps({'t': 'START', 'repoId': REPO_ID, 'subjectId': '152',
                                 'group': 'harness', 'holder': holder, 'klass': klass,
                                 'rol': rol, 'object': '-', 'worktree': str(self.wt),
                                 'branch': 'wip/152/avtor',
                                 'at': '2026-10-31T10:00:00Z'}) + '\n')

    def ledg(self):
        return [json.loads(ln) for ln in
                self.ledger.read_text(encoding='utf-8').splitlines() if ln.strip()]

    def zanyat_holder(self):
        f = self.sost / 'zamki' / REPO_ID / '152' / 'zanyat' / 'holder.json'
        if not f.is_file():
            return None
        return json.loads(f.read_text(encoding='utf-8'))

    def sobytie(self, items):
        p = self.root / 'event.json'
        p.write_text(json.dumps({'tasks': items}, ensure_ascii=False), encoding='utf-8')
        return str(p)


def item(agent, name, stroki):
    return {'agent': agent, 'name': name, 'task': '\n'.join(stroki)}


def rabochij(name):
    return item('architect', name,
                ['SUBJECT=152', 'WORKTREE=|WT|', 'BRANCH=wip/152/avtor'])


def sudja(name, obj):
    return item('critic', name, ['SUBJECT=152', 'OBJECT=' + obj])


def sudit(mir, items):
    ev = mir.sobytie(items)
    return run([BASH, mir.dver, '--sudit', '--sostojanie', str(mir.sost),
                '--zhurnaly', str(mir.zhurnaly), '--repo', str(mir.repo), ev])


def sudit_rabochij(mir, name):
    items = [rabochij(name)]
    ev = mir.sobytie(items)
    d = json.loads(Path(ev).read_text(encoding='utf-8'))
    d['tasks'][0]['task'] = d['tasks'][0]['task'].replace('|WT|', str(mir.wt))
    Path(ev).write_text(json.dumps(d, ensure_ascii=False), encoding='utf-8')
    return run([BASH, mir.dver, '--sudit', '--sostojanie', str(mir.sost),
                '--zhurnaly', str(mir.zhurnaly), '--repo', str(mir.repo), ev])


def osvobodit(mir, holder):
    return run([BASH, mir.dver, '--osvobodit', '--sostojanie', str(mir.sost),
                '--zhurnaly', str(mir.zhurnaly), '--repo', str(mir.repo),
                '152', holder])


def uchet(mir):
    return run([BASH, mir.dver, '--uchet', '--sostojanie', str(mir.sost),
                '--zhurnaly', str(mir.zhurnaly), '--repo', str(mir.repo)])


# ── мир orch-loop (блок D) ───────────────────────────────────────────────────
class MirLoop:
    def __init__(self, root, orch_tekst, result, rc_agenta, systemctl_rezhim='ok'):
        self.root = Path(root)
        self.repo = self.root / 'repo'
        self.bin = self.root / 'bin'
        self.home = self.root / 'home'
        self.dvos = self.root / 'dvos'
        self.rc_agenta = rc_agenta
        self.result = result
        self.systemctl_rezhim = systemctl_rezhim
        for d in (self.repo, self.bin, self.home, self.dvos):
            d.mkdir(parents=True, exist_ok=True)
        f = self.repo / 'orch-loop'
        f.write_text(orch_tekst, encoding='utf-8')
        f.chmod(0o755)
        self.log = self.root / 'loop.log'
        omp = self.bin / 'omp'
        omp.write_text('#!/usr/bin/env bash\nexit ${ORCH152_RC:-%s}\n' % rc_agenta, encoding='utf-8')
        omp.chmod(0o755)
        sdr = self.bin / 'systemd-run'
        sdr.write_text('#!/usr/bin/env bash\n'
                       'while [ $# -gt 0 ]; do case "$1" in --) shift; break ;; *) shift ;; esac; done\n'
                       'exec "$@"\n', encoding='utf-8')
        sdr.chmod(0o755)
        scl = self.bin / 'systemctl'
        if systemctl_rezhim == 'otsutstvuet':
            telo = '#!/usr/bin/env bash\nexit 1\n'   # нет шины/бинарника: честная деградация
        else:
            telo = ('#!/usr/bin/env bash\n'
                    'if [ "$2" = "is-active" ]; then exit 1; fi\n'
                    'if [ "$2" = "show" ]; then printf \'%%s\\n\' "%s"; fi\n'
                    'exit 0\n' % result)
        scl.write_text(telo, encoding='utf-8')
        scl.chmod(0o755)
        (self.dvos / '.dr').write_text('', encoding='utf-8')

    def env(self):
        return {'PATH': '%s:/usr/local/bin:/usr/bin:/bin' % self.bin,
                'HOME': str(self.home), 'LANG': 'C.UTF-8',
                'TMPDIR': str(self.root),
                'ORCH_REPO': str(self.repo), 'ORCH_ENV': str(self.root / 'net-konfiga'),
                'ORCH_SELF_UPDATE': '0',
                'ORCH_MARK': str(self.root / 'restart'), 'ORCH_STOP': str(self.root / 'stop'),
                'ORCH_LOG': str(self.log),
                'ORCH_LOOP_AGENT_CMD': str(self.bin / 'omp'),
                'ORCH_WORKSHOP': str(self.bin / 'omp'),
                'ORCH_AGENT_HOME': str(self.home),
                'ORCH_GRACE': '0', 'ORCH_MIN_LIFE': '3600', 'ORCH_EARLY_WAIT': '0',
                'ORCH_EARLY_MAX': '1', 'ORCH_MEM_MAX': '64M',
                'ORCH_DVOJNIKI': str(self.dvos), 'ORCH152_RC': self.rc_agenta}

    def zapusk(self):
        e = self.env()
        p = subprocess.Popen([BASH, str(self.repo / 'orch-loop')], cwd=str(self.repo),
                             env=e, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                             text=True, start_new_session=True)
        try:
            p.wait(timeout=60)
        except subprocess.TimeoutExpired:
            p.kill()
            p.wait()
            return None
        return p.returncode

    def log_tekst(self):
        if not self.log.is_file():
            return ''
        return self.log.read_text(encoding='utf-8')

    def pobery(self):
        """убрать осиротевший watcher мира (cmdline содержит путь orch-loop)."""
        r = run(['pgrep', '-f', str(self.repo / 'orch-loop')])
        for ln in r.stdout.split():
            try:
                os.kill(int(ln), 15)
            except (ProcessLookupError, ValueError):
                pass


# ── клетки: имя → (блок, фабрика мира, суд) ──────────────────────────────────
KLETKI = []


def kletka(imja, blok):
    def deco(fn):
        KLETKI.append((imja, blok, fn))
        return fn
    return deco


def mir_subjekta(tmp, subj, stub=None):
    """материализовать субъект в мир: копии носителей (со стаб-мутацией)."""
    root = Path(tmp)
    dvoj = root / 'subj-dvojniki'
    if subj['dvojnik_dir'] is not None:
        shutil.copytree(subj['dvojnik_dir'], dvoj)
    else:
        dvoj.mkdir(parents=True, exist_ok=True)
        for im in IMENA_DVOJNIKOV:
            shutil.copyfile(MODEL_DVOS / im, dvoj / im)
            os.chmod(dvoj / im, 0o755)
    zamok = root / 'subj-zamok.sh'
    zamok.write_bytes(subj['zamok'])
    zamok.chmod(0o755)
    orch = root / 'subj-orch-loop'
    orch.write_bytes(subj['orch'])
    orch.chmod(0o755)
    if stub is not None:
        primeni_stub(stub, root)
    return {'dvojnik_dir': dvoj, 'zamok': zamok, 'orch': orch}


def primeni_stub(stub_mod, root):
    """применить замены стаба к материализованным носителям мира.
    Носитель: ('dvojniki', '<файл>') — файл каталога двойников; 'zamok' —
    subj-zamok.sh; 'orch' — subj-orch-loop."""
    for nositel, zamena in getattr(stub_mod, 'ZAMENA', []):
        if isinstance(nositel, str):
            cel = {'zamok': root / 'subj-zamok.sh',
                   'orch': root / 'subj-orch-loop'}[nositel]
        else:
            cel = root / 'subj-dvojniki' / nositel[1]
        tekst = cel.read_text(encoding='utf-8')
        if tekst.count(zamena[0]) != 1:
            raise OshibkaVoronki('стаб %s: якорь %-40s встречается %d раз'
                                 % (getattr(stub_mod, 'IMJA', '?'), zamena[0][:40], tekst.count(zamena[0])))
        cel.write_text(tekst.replace(zamena[0], zamena[1]), encoding='utf-8')


def gasit_gruppu(p):
    """гасить подделку ЦЕЛОЙ группой (start_new_session): сон-ребёнок не
    остаётся сиротой; двойной вызов безопасен."""
    import signal
    try:
        os.killpg(os.getpgid(p.pid), signal.SIGTERM)
    except (ProcessLookupError, PermissionError):
        pass
    try:
        p.wait(timeout=10)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(os.getpgid(p.pid), signal.SIGKILL)
        except (ProcessLookupError, PermissionError):
            pass
        p.wait(timeout=10)


ZHGIVYE_PODDELKI = []   # pid-ы подделок qemu миров: гигиена e01


@kletka('a01-emulator', 'A')
def a01(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='a01-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        return kletka_imeni(mir, 'emulator')


@kletka('a02-qemu-system-x86_64', 'A')
def a02(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='a02-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        return kletka_imeni(mir, 'qemu-system-x86_64')


@kletka('a03-gradle', 'A')
def a03(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='a03-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        return kletka_imeni(mir, 'gradle')


@kletka('a04-cmake', 'A')
def a04(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='a04-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        return kletka_imeni(mir, 'cmake')


@kletka('a05-clang', 'A')
def a05(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='a05-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        return kletka_imeni(mir, 'clang')


@kletka('a06-clang++', 'A')
def a06(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='a06-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        return kletka_imeni(mir, 'clang++')


@kletka('a07-prebuild', 'A')
def a07(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='a07-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        return kletka_imeni(mir, 'prebuild')


@kletka('a08-semejstva-imen', 'A')
def a08(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='a08-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        for im in SEMEJSTVO:
            r = mir.zapusk('%s proba' % im, scope=True)
            if r.returncode != 1 or not r.stderr.startswith('ОТКАЗ: STROGO_SCOPE:'):
                return 'имя %s: rc %d, stderr=%s' % (im, r.returncode, r.stderr.strip()[:120])
            if not zhurnal_soderzhit(mir, im):
                return 'имя %s: строки журнала нет' % im
        return None


@kletka('a09-expo-run-android-prebuild', 'A')
def a09(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='a09-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        for token in ('run:android', 'prebuild'):
            r = mir.zapusk('expo %s' % token, scope=True)
            if r.returncode != 1 or not r.stderr.startswith('ОТКАЗ: STROGO_SCOPE:'):
                return 'expo %s: rc %d, stderr=%s' % (token, r.returncode, r.stderr.strip()[:120])
            if not zhurnal_soderzhit(mir, 'expo'):
                return 'expo %s: строки журнала нет' % token
        return None


@kletka('a10-expo-export-propusk', 'A')
def a10(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='a10-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        r = mir.zapusk('expo export --platform web', scope=True)
        if r.returncode != 0:
            return 'expo export: rc %d ≠ 0 (легитимный запуск отказан): %s' % (
                r.returncode, r.stderr.strip()[:120])
        if not any(ln.startswith('2') and '\texpo\t' in ln for ln in mir.ran()):
            return 'expo export: pass-through не исполнен (нет строки ran.tsv)'
        return None


@kletka('a11-rezolv-formy', 'A')
def a11(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='a11-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        # абсолютный путь к двойнику
        r = mir.zapusk('"%s/emulator" -avd proba' % mir.dvoj, scope=True)
        if r.returncode != 1 or not r.stderr.startswith('ОТКАЗ: STROGO_SCOPE:'):
            return 'абсолютный путь: rc %d, stderr=%s' % (r.returncode, r.stderr.strip()[:120])
        # симлинк на двойника
        lnk = mir.root / 'g152'
        os.symlink(str(mir.dvoj / 'gradle'), str(lnk))
        r = run([BASH, '-c', '"%s" assembleDebug' % lnk], cwd=str(mir.home),
                env=mir.env(True), timeout=60)
        if r.returncode != 1 or not r.stderr.startswith('ОТКАЗ: STROGO_SCOPE:'):
            return 'симлинк: rc %d, stderr=%s' % (r.returncode, r.stderr.strip()[:120])
        # sh -c составная команда
        r = mir.zapusk('sh -c \'cd /tmp && cmake -B build152\'', scope=True)
        if r.returncode != 1 or not r.stderr.startswith('ОТКАЗ: STROGO_SCOPE:'):
            return 'sh -c: rc %d, stderr=%s' % (r.returncode, r.stderr.strip()[:120])
        for im in ('emulator', 'gradle', 'cmake'):
            if not zhurnal_soderzhit(mir, im):
                return 'формы резолва: строки журнала для %s нет' % im
        return None


@kletka('a12-bezobidnye', 'A')
def a12(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='a12-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        for komanda in ('grep -r emulator README.md', 'cat build.gradle',
                        'git --version', 'echo clang slovo', 'ls'):
            r = mir.zapusk(komanda, scope=True)
            if r.returncode != 0:
                return '«%s»: rc %d ≠ 0 (ложное срабатывание): %s' % (
                    komanda, r.returncode, r.stderr.strip()[:120])
            if 'ОТКАЗ: STROGO' in r.stderr:
                return '«%s»: ложный отказ сторожа' % komanda
        if mir.zhurnal():
            return 'безобидные команды писали журнал: %s' % mir.zhurnal()[:2]
        return None


@kletka('b01-nol-jivyh-propusk', 'B')
def b01(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='b01-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        r = mir.zapusk('emulator -avd proba', scope=False)
        if r.returncode != 0:
            return 'вне scope при нуля живых qemu запуск отказан: rc %d, %s' % (
                r.returncode, r.stderr.strip()[:120])
        if not any('\temulator\t' in ln for ln in mir.ran()):
            return 'настоящий emulator не исполнен (нет строки ran.tsv)'
        return None


@kletka('b02-dva-jivyh-tretij-otkaz', 'B')
def b02(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='b02-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        poddelki = [mir.poddelka_qemu(i) for i in (1, 2)]
        ZHGIVYE_PODDELKI.extend(poddelki)
        try:
            time.sleep(0.3)
            r = mir.zapusk('emulator -avd proba', scope=False)
            if r.returncode != 1:
                return 'третий эмулятор: rc %d ≠ 1' % r.returncode
            if not r.stderr.startswith('ОТКАЗ: STROGO_EMULJATORY_LIMIT:'):
                return 'причина не STROGO_EMULJATORY_LIMIT: %s' % r.stderr.strip()[:120]
            for i, p in enumerate(poddelki, 1):
                if p.poll() is not None:
                    return 'сторож убил живую подделку №%d' % i
            if not zhurnal_soderzhit(mir, 'emulator'):
                return 'строки журнала отказа нет'
            return None
        finally:
            # гигиена клетки: подделки гасятся ГРУППОЙ при ЛЮБОМ исходе —
            # ранний return у обмана (замер --stabs: мир s03) не оставляет
            # живых; иначе счётчик следующей клетки видит чужих (замер b03)
            for p in poddelki:
                gasit_gruppu(p)


@kletka('b03-odin-jivoj-propusk', 'B')
def b03(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='b03-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        p = mir.poddelka_qemu(1)
        ZHGIVYE_PODDELKI.append(p)
        try:
            time.sleep(0.3)
            r = mir.zapusk('emulator -avd proba', scope=False)
            if r.returncode != 0:
                return 'при одном живом qemu запуск отказан: rc %d, %s' % (
                    r.returncode, r.stderr.strip()[:120])
            if not any('\temulator\t' in ln for ln in mir.ran()):
                return 'настоящий emulator не исполнен'
            return None
        finally:
            gasit_gruppu(p)


@kletka('b04-gradle-vne-scope-propusk', 'B')
def b04(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='b04-') as w:
        mir = MirStorozh(w, subj['dvojnik_dir'])
        r = mir.zapusk('gradle --version', scope=False)
        if r.returncode != 0:
            return 'gradle вне scope отказан (не лимитируется числом): rc %d, %s' % (
                r.returncode, r.stderr.strip()[:120])
        if not any('\tgradle\t' in ln for ln in mir.ran()):
            return 'настоящий gradle не исполнен'
        return None


@kletka('c01-pogib-avto-snjatie', 'C')
def c01(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='c01-') as w:
        mir = MirZamok(w, subj['zamok'])
        mir.start('ArchPogib')
        mir.zhurnal('ArchPogib', okonchenie='signal', vozrast_min=5)
        r = sudit_rabochij(mir, 'Raboj2')
        if r.returncode != 0 or 'PUSCHEM Raboj2' not in r.stdout:
            return 'rc %d, stdout=%s stderr=%s' % (r.returncode, r.stdout.strip()[:120], r.stderr.strip()[:120])
        rel = [x for x in mir.ledg() if x.get('t') == 'RELEASE' and x.get('holder') == 'ArchPogib']
        if not rel or rel[-1].get('prichina') != 'pogib':
            return 'RELEASE pogib для ArchPogib нет: %s' % rel
        if (mir.zanyat_holder() or {}).get('holder') != 'Raboj2':
            return 'замок не перезаписан новым holder: %s' % mir.zanyat_holder()
        return None


@kletka('c02-pogib-osvobodit-srazu', 'C')
def c02(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='c02-') as w:
        mir = MirZamok(w, subj['zamok'])
        mir.start('ArchPogib')
        mir.zhurnal('ArchPogib', okonchenie='normal', vozrast_min=2)
        r = osvobodit(mir, 'ArchPogib')
        if r.returncode != 0:
            return 'rc %d (TTL не должен был ждать): %s' % (r.returncode, r.stderr.strip()[:160])
        if 'prichina=pogib' not in r.stdout:
            return 'причина не pogib: %s' % r.stdout.strip()[:120]
        return None


@kletka('c03-roditel-umer', 'C')
def c03(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='c03-') as w:
        mir = MirZamok(w, subj['zamok'])
        mir.start('ArchTihij')                      # собственный журнал без якорей
        mir.zhurnal('ArchTihij', vozrast_min=5)
        mir.zhurnal_roditelja('signal')             # станция умерла целиком
        r = sudit_rabochij(mir, 'Raboj2')
        if r.returncode != 0 or 'PUSCHEM Raboj2' not in r.stdout:
            return 'rc %d, stderr=%s' % (r.returncode, r.stderr.strip()[:160])
        rel = [x for x in mir.ledg() if x.get('t') == 'RELEASE' and x.get('holder') == 'ArchTihij']
        if not rel or rel[-1].get('prichina') != 'pogib':
            return 'RELEASE pogib по родителю нет: %s' % rel
        return None


@kletka('c04-yield-prioritet', 'C')
def c04(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='c04-') as w:
        mir = MirZamok(w, subj['zamok'])
        mir.start('Avtor152')
        mir.zhurnal('Avtor152', sdal=True, okonchenie='normal', vozrast_min=3)
        r = osvobodit(mir, 'Avtor152')
        if r.returncode != 0 or 'prichina=yield' not in r.stdout:
            return 'сдавший обязан освобождаться с prichina=yield: rc %d, %s' % (
                r.returncode, r.stdout.strip()[:120])
        r = sudit_rabochij(mir, 'Raboj2')
        if r.returncode != 0 or 'PUSCHEM Raboj2' not in r.stdout:
            return 'после yield автора новый рабочий обязан пройти: rc %d, %s' % (
                r.returncode, r.stderr.strip()[:120])
        return None


@kletka('c05-zhivoj-kak-ranyshe', 'C')
def c05(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='c05-') as w:
        mir = MirZamok(w, subj['zamok'])
        mir.start('ArchZhiv')
        mir.zhurnal('ArchZhiv', vozrast_min=3)
        r = sudit_rabochij(mir, 'Raboj2')
        if r.returncode != 1 or 'RABOCHIJ_ZHIV' not in r.stderr:
            return 'живой holder: rc %d, stderr=%s' % (r.returncode, r.stderr.strip()[:160])
        if any(x.get('t') == 'RELEASE' for x in mir.ledg()):
            return 'живой holder снят авто-релизом'
        return None


@kletka('c06-broshen-kak-ranyshe', 'C')
def c06(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='c06-') as w:
        mir = MirZamok(w, subj['zamok'])
        mir.start('ArchStaryj')
        mir.zhurnal('ArchStaryj', vozrast_min=75)
        r = sudit_rabochij(mir, 'Raboj2')
        if r.returncode != 1 or 'ZAMOK_BROSHEN' not in r.stderr:
            return 'тишина >TTL: rc %d, stderr=%s' % (r.returncode, r.stderr.strip()[:160])
        if any(x.get('t') == 'RELEASE' for x in mir.ledg()):
            return 'таймерная ветка сняла замок авто-релизом (запрещено, ветка Е 140)'
        return None


@kletka('c07-uchet-pogib', 'C')
def c07(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='c07-') as w:
        mir = MirZamok(w, subj['zamok'])
        mir.start('ArchPogib')
        mir.zhurnal('ArchPogib', okonchenie='signal', vozrast_min=4)
        r = uchet(mir)
        if r.returncode != 0:
            return 'uchet: rc %d, %s' % (r.returncode, r.stderr.strip()[:120])
        stroka = [ln for ln in r.stdout.splitlines() if 'ArchPogib' in ln]
        if not stroka or not stroka[0].rstrip().endswith('pogib'):
            return 'учёт не показывает pogib: %s' % stroka
        return None


@kletka('c08-sudja-avtor-pogib', 'C')
def c08(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='c08-') as w:
        mir = MirZamok(w, subj['zamok'])
        mir.start('AvtorPogib')
        mir.zhurnal('AvtorPogib', okonchenie='signal', vozrast_min=4)
        r = sudit(mir, [sudja('Kritik152', mir.tip)])
        if r.returncode != 1 or 'AVTOR_ESHCHO_RABOTAET' not in r.stderr:
            return 'судья без сдачи автора: rc %d, stderr=%s' % (r.returncode, r.stderr.strip()[:160])
        rel = [x for x in mir.ledg() if x.get('t') == 'RELEASE' and x.get('holder') == 'AvtorPogib']
        if not rel or rel[-1].get('prichina') != 'pogib':
            return 'авто-снятие погибшего автора не исполнено: %s' % rel
        return None


@kletka('c09-gonka-avto-snjatija', 'C')
def c09(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='c09-') as w:
        mir = MirZamok(w, subj['zamok'])
        mir.start('ArchPogib')
        mir.zhurnal('ArchPogib', okonchenie='signal', vozrast_min=4)
        ev1, ev2 = mir.sobytie([rabochij('A')]), mir.sobytie([rabochij('B')])
        for ev in (ev1, ev2):
            d = json.loads(Path(ev).read_text(encoding='utf-8'))
            d['tasks'][0]['task'] = d['tasks'][0]['task'].replace('|WT|', str(mir.wt))
            Path(ev).write_text(json.dumps(d, ensure_ascii=False), encoding='utf-8')
        args = lambda ev: [BASH, mir.dver, '--sudit', '--sostojanie', str(mir.sost),
                           '--zhurnaly', str(mir.zhurnaly), '--repo', str(mir.repo), ev]
        p1 = subprocess.Popen(args(ev1), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        p2 = subprocess.Popen(args(ev2), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        o1, _ = p1.communicate(timeout=60)
        o2, _ = p2.communicate(timeout=60)
        pushem = (1 if 'PUSCHEM' in o1 else 0) + (1 if 'PUSCHEM' in o2 else 0)
        starty = [x for x in mir.ledg() if x.get('t') == 'START' and x.get('holder') in ('A', 'B')]
        if pushem != 1 or len(starty) != 1:
            return 'гонка авто-снятия: PUSCHEM %d, START %d (ожидано 1 и 1)' % (pushem, len(starty))
        return None


@kletka('d01-fakt-oom-rc143', 'D')
def d01(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='d01-') as w:
        mir = MirLoop(w, Path(subj['orch']).read_text(encoding='utf-8'), 'oom-kill', '143')
        mir.rc_agenta = '143'
        rc = mir.zapusk()
        mir.pobery()
        if rc is None:
            return 'цикл завис'
        if LIT_OOM not in mir.log_tekst():
            return 'факт oom-kill при rc=143 не дал литерал 085: лог=%s' % mir.log_tekst()[-300:]
        return None


@kletka('d02-rc137-bez-fakta', 'D')
def d02(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='d02-') as w:
        mir = MirLoop(w, Path(subj['orch']).read_text(encoding='utf-8'), 'dead', '137')
        mir.rc_agenta = '137'
        rc = mir.zapusk()
        mir.pobery()
        if LIT_OOM not in mir.log_tekst():
            return 'rc=137 без факта обязан сохранять литерал 085'
        return None


@kletka('d03-rc143-bez-fakta', 'D')
def d03(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='d03-') as w:
        mir = MirLoop(w, Path(subj['orch']).read_text(encoding='utf-8'), 'dead', '143')
        mir.rc_agenta = '143'
        rc = mir.zapusk()
        mir.pobery()
        if LIT_OOM in mir.log_tekst():
            return 'ложная маркировка OOM без факта и без rc 137'
        if 'упала без маркера (rc=143' not in mir.log_tekst():
            return 'строки падения нет: %s' % mir.log_tekst()[-300:]
        return None


@kletka('d04-fakt-oom-rc137', 'D')
def d04(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='d04-') as w:
        mir = MirLoop(w, Path(subj['orch']).read_text(encoding='utf-8'), 'oom-kill', '137')
        mir.rc_agenta = '137'
        rc = mir.zapusk()
        mir.pobery()
        if LIT_OOM not in mir.log_tekst():
            return 'факт oom-kill при rc=137 не дал литерал'
        return None


@kletka('d05-net-systemctl-degradacija', 'D')
def d05(subj, tmp):
    with tempfile.TemporaryDirectory(prefix='d05-') as w:
        mir = MirLoop(w, Path(subj['orch']).read_text(encoding='utf-8'), 'dead', '143',
                      systemctl_rezhim='otsutstvuet')
        mir.rc_agenta = '143'
        rc = mir.zapusk()
        mir.pobery()
        if rc is None:
            return 'цикл завис без systemctl'
        if LIT_OOM in mir.log_tekst():
            return 'ложная маркировка OOM при недоступном systemctl'
        if 'упала без маркера (rc=143' not in mir.log_tekst():
            return 'деградация сломана: цикл не дошёл до строки падения (rc=%s): %s' % (
                rc, mir.log_tekst()[-300:])
        return None


@kletka('e01-gigiena-mirov', 'E')
def e01(subj, tmp):
    for p in ZHGIVYE_PODDELKI:
        gasit_gruppu(p)
    # добор: осиротевшие подделки ПРОШЛЫХ прогонов (замер: обрыв --stabs
    # оставил троих; NONCE — приватный маркер батареи, чужих не задаёт)
    r = run(['pgrep', '-f', 'qemu-system-fake-' + NONCE])
    for ln in r.stdout.split():
        try:
            os.kill(int(ln), 15)
        except (ProcessLookupError, ValueError):
            pass
    time.sleep(0.2)
    r = run(['pgrep', '-af', NONCE])


# ── прогон ───────────────────────────────────────────────────────────────────
def zagruzit_stab(put):
    spec = importlib.util.spec_from_file_location(put.stem, str(put))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def subjekt_iz_argumenta(rezhat, est):
    if est == 'model':
        return {'dvojnik_dir': MODEL_DVOS, 'zamok': MODEL_ZAMOK, 'orch': MODEL_ORCH}
    baz = Path(rezhat).resolve()
    dvoj = baz / 'ops' / 'server' / 'user' / 'dvojniki'
    return {'dvojnik_dir': dvoj if dvoj.is_dir() else None,
            'zamok': baz / 'scripts' / 'zamok_predmeta.sh',
            'orch': baz / 'ops' / 'server' / 'user' / 'orch-loop'}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    ap.add_argument('--oracle-tamper', action='store_true')
    ap.add_argument('--repo')
    ap.add_argument('--seed', type=int, default=None)
    a = ap.parse_args()

    for instrument in ('bash', 'git', 'jq', 'pgrep'):
        if run(['bash', '-lc', 'command -v %s' % instrument]).returncode != 0:
            print('NOT_IMPLEMENTED: нет %s' % instrument)
            return 2
    try:
        src = chitat_orakul()
        nos = nositeli_modeli()
        proverit_piny(nos, src)
    except OshibkaVoronki as e:
        print('ORACLE_TAMPERED: %s' % e)
        return 2

    if a.oracle_tamper:
        # доказательство: порча КАЖДОГО носителя ловится ДО клеток по пину
        ulovleno = 0
        for put in nos:
        # (порча подменяет один носитель в ПОЛНОМ наборе: отказ — только
        # по несовпадению пина, не по «пинов без носителей»)
            with tempfile.TemporaryDirectory(prefix='tamper-') as w:
                zaportit = dict(nos)
                bajty = bytearray(nos[put])
                bajty[-1] ^= 0xFF
                zaportit[put] = bytes(bajty)
                try:
                    proverit_piny(zaportit, src)
                except OshibkaVoronki:
                    ulovleno += 1
        print('ORACLE_TAMPER_PROVERENO nositelej=%d' % ulovleno)
        return 0

    est = 'model' if (a.model or a.stabs) else 'repo'
    baz = a.repo if a.repo else str(HARNESS)
    subj = subjekt_iz_argumenta(baz, est)

    # SUBJECT_ABSENT: двойники не установлены — клетки A/B красны поимённо
    net_dvojnikov = subj['dvojnik_dir'] is None

    # e01 (гигиена) судит ПОСЛЕ всех миров — из перестановки --seed исключена
    kletki = [k for k in KLETKI if k[1] != 'E']
    if a.seed is not None:
        random.Random(a.seed).shuffle(kletki)
    kletki += [k for k in KLETKI if k[1] == 'E']

    krasnye, vsego = [], 0
    for imja, blok, fn in kletki:
        vsego += 1
        if blok in 'AB' and net_dvojnikov:
            krasnye.append('%s: SUBJECT_ABSENT (двойники не установлены)' % imja)
            print('KLETKA %s KRASNO: SUBJECT_ABSENT' % imja)
            continue
        try:
            prichina = fn(subj, None)
        except Exception as exc:                     # noqa: BLE001 — клетка честно красна
            prichina = 'ИСКЛЮЧЕНИЕ: %r' % exc
        if prichina:
            krasnye.append('%s: %s' % (imja, prichina))
            print('KLETKA %s KRASNO: %s' % (imja, prichina))
        else:
            print('KLETKA %s OK' % imja)

    svjazi = 0
    zhivye_staby = []
    if a.stabs:
        for imja_staba in sorted((src.get('stab_vhod') or {})):
            mod = zagruzit_stab(STABS / imja_staba)
            pojmanno = 0
            for kletka_imja in src['stab_vhod'][imja_staba]:
                fn = next((f for i, b, f in KLETKI if i == kletka_imja), None)
                if fn is None:
                    print('ORACLE_TAMPERED: стаб %s → неизвестная клетка %s' % (imja_staba, kletka_imja))
                    return 2
                with tempfile.TemporaryDirectory(prefix='stab-') as w:
                    s = mir_subjekta(w, {'dvojnik_dir': MODEL_DVOS,
                                         'zamok': MODEL_ZAMOK.read_bytes(),
                                         'orch': MODEL_ORCH.read_bytes()}, stub=mod)
                    try:
                        prichina = fn(s, None)
                    except Exception as exc:         # noqa: BLE001
                        prichina = 'ИСКЛЮЧЕНИЕ: %r' % exc
                svjazi += 1
                if prichina is None:
                    zhivye_staby.append('%s на %s' % (imja_staba, kletka_imja))
                else:
                    pojmanno += 1
            print('STAB %s: kletok %d, pojmannyh %d' % (
                imja_staba, len(src['stab_vhod'][imja_staba]), pojmanno))
        if krasnye:
            print('KRASNO: клеток %d, красных %d; стабы не гонялись' % (vsego, len(krasnye)))
            return 1
        if zhivye_staby:
            print('STAB_ZHIV: %s' % '; '.join(zhivye_staby))
            return 1
        print('SUBJEKT_SVJAZI %d, живых 0' % svjazi)

    if krasnye:
        print('KRASNO: клеток %d, красных %d' % (vsego, len(krasnye)))
        return 1
    print('ZELENO: клеток %d, зелёных %d' % (vsego, vsego))
    return 0


if __name__ == '__main__':
    sys.exit(main())
