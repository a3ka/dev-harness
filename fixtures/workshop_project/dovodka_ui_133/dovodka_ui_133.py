#!/usr/bin/env python3
"""Движок батареи 133 (dovodka-ui): шаг визуальной доводки UI после implementer.

Режимы (раннер red_dovodka_ui_133.sh передаёт argv как есть):
  (без режима)          субъект = <корень дерева>/scripts/dovodka_ui.sh (нет → PREDMET)
  --candidate <клон>    субъект = <клон>/scripts/dovodka_ui.sh
  --model               субъект = model/dovodka_ui.sh
  --stabs               на каждую подмену source.json: КОНТРОЛЬ (модель сходится в её
                        клетке), затем ПОДМЕНА (обязана разойтись) → ПОЙМАН
  --cell <id>           только эта клетка (с любым режимом)
  --seed <N>            seed миров (токены продукта)

Мир клетки — mktemp без сети: продукт-репозиторий work/ (git: базовый коммит экрана +
правки доводки), sverka-do.tsv / sverka-posle.tsv (грамматика KADR контракта 123),
ui-zona.txt, ekran.md, мини-харнесс-репозиторий harness/ (контракт экрана
contracts/<NNN>-ekran.md + тег frozen/contracts/<NNN>/<v> — замороженный blob экрана,
блокер 2 круга 2), .omp/config.yml (тир vision), двойник omp в bin/ PATH (таблица
models.list из файла мира), двойник scripts/overlay.sh (нога «соответствие модели
задаче», overlay.sh:106-147) и субъект scripts/dovodka_ui.sh. Выдача ворот фиксируется
миром в git-состоянии продукта: refs/dovodka/baza + refs/dovodka/zadanie (блокер 3
круга 2: задание после выдачи изменяется клеткой — байты обязаны разойтись). Клетки
режима dver (блокер 1 круга 2) НЕ зовут субъект: живой пробой клонируют дерево
харнесса, синтезируют маркер заморозки 133 и судят дверь 095 scripts/make_task.sh —
зелёны и на дереве без предмета. Субъект вызывается режимом клетки:
zadanie / zona / sudjam / cep (цепь, арбитраж капа 3 П-Б2: субъект zadanie строит
задание и выдачу refs, мир делает один UI-коммит, субъект zona принимает по файлу,
выданному субъектом; задание для cep мир НЕ пишет — только субъект).

Исходы: ZADACHA (rc 0, stdout `DOVODKA: задание …`, задание — строки грамматики
побайтово, выдача в refs, отказ задание НЕ пишет), OTKAZ (rc 1, stderr
`ОТКАЗ dovodka: …<причина>…`), NECHEM (rc 2, stderr `НЕЧЕМ СУДИТЬ dovodka: …`),
CHISTO (rc 0, `ЗОНА: чисто (путей N)`, N — число путей диффа --no-renames, refs выдачи
погашены), SUD_OK (rc 0, артефакт SUD с числами ДО/ПОСЛЕ побайтово), SUD_KRASNO
(rc 1 `не завершена`, артефакт с числами побайтово — числа предъявлены и красному
исходу), DVER_OK (дверь rc 0, манифест непуст), DVER_OTKAZ (дверь rc 1 с именованной
причиной), DVER_NET_KANALA (дверь rc 0, но задание НЕ попадает в пак/манифест).
Алфавит расхождений: RC, PRICHINA, VYVOD, ARTEFAKT, VYDACHA, POGASHENO, PREDMET.
Ожидания снимаются в память ДО вызова субъекта; задание сверяется по ПОРЯДКУ строк —
порядок секций семантичен для потребителя zona (арбитраж капа 3 П-Б1); SUD-артефакт —
мультимножеством строк (каждая строка сама по себе, не подстрокой).

Коды: 0 — всё сошлось / все подмены пойманы; 1 — расхождение / предмет отсутствует /
непойманная подмена; 2 — нечем судить (нет git/bash, якорь подмены не единственен,
мир не строится, нет такой клетки).
"""
import json
import os
import random
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = json.load(open(os.path.join(HERE, 'source.json'), encoding='utf-8'))
TREE_ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
DV = os.path.join(HERE, 'dvoyniki')
MODEL = os.path.join(HERE, 'model', 'dovodka_ui.sh')
TMPBASE = os.environ.get('TMPDIR', '/tmp')


class Nechem(Exception):
    pass


def run(cmd, cwd, env=None, check=True):
    p = subprocess.run(cmd, cwd=cwd, env=env, capture_output=True, text=True)
    if check and p.returncode != 0:
        raise Nechem('мир не строится: %s rc=%d: %s' % (' '.join(cmd), p.returncode, p.stderr.strip()[:300]))
    return p


def base_env(home):
    e = {k: v for k, v in os.environ.items() if not k.startswith('GIT_') and not k.startswith('DOV133_')}
    e.update({'HOME': home, 'GIT_CONFIG_GLOBAL': '/dev/null', 'GIT_CONFIG_SYSTEM': '/dev/null',
              'GIT_AUTHOR_NAME': 'mir', 'GIT_AUTHOR_EMAIL': 'mir@133', 'GIT_COMMITTER_NAME': 'mir',
              'GIT_COMMITTER_EMAIL': 'mir@133', 'LC_ALL': 'C.UTF-8'})
    return e


def sverka_lines(cell, key, rawkey):
    if cell.get(rawkey) is not None:
        return cell[rawkey].splitlines()
    return ['KADR\t' + '\t'.join(r) for r in cell[key]]


def ekran_tag(cell):
    """Тег замороженного экрана мира: единый источник для задания и мини-харнесса."""
    return 'frozen/contracts/%s/%s' % (cell.get('ekran_nnn', '132'), cell.get('ekran_v', '1'))


def zadanie_lines(cell, repo, kadry, makety, ekran, baza):
    """ЕДИНЫЙ источник байтов задания:ожидание ZADACHA и мир-задание zona-клеток."""
    vm = cell['vision']['model'].split('/')[-1]
    return (['# Задание доводки UI (шаг dovodka-ui, контракт 133)',
             'МОДЕЛЬ: %s (тир vision, overlay rc 0, images=yes)' % vm,
             'РЕПОЗИТОРИЙ: %s' % repo,
             'БАЗА: %s' % baza,
             'КОНТРАКТ ЭКРАНА: %s' % ekran,
             'КАДРЫ: %s' % kadry,
             'МАКЕТЫ: %s' % makety,
             'UI-ЗОНА:'] + list(cell['ui_zona'])
            + ['СВЕРКА (дословно, числа похожести на каждый кадр):']
            + sverka_lines(cell, 'sverka_do', 'sverka_raw_do')
            + ['ЗАДАЧА: править только пути UI-ЗОНА; цикл правка → e2e → сверка 123; все кадры не ниже порога; судьям — результат с числами.'])


class Mir:
    def __init__(self, cell, subject, seed):
        self.cell = cell
        self.rnd = random.Random('%s/%s' % (seed, cell['id']))
        self.d = tempfile.mkdtemp(prefix='dovodka133.', dir=TMPBASE)
        self.env = base_env(self.d)
        self.work = os.path.join(self.d, 'work')
        self.kadry = os.path.join(self.d, 'kadry')
        self.makety = os.path.join(self.d, 'makety')
        self.bin = os.path.join(self.d, 'bin')
        self.models_tsv = os.path.join(self.d, 'models.tsv')
        self.harness_dir = os.path.join(self.d, 'harness')
        self.build(subject)

    def gr(self, *a):
        return run(['git'] + list(a), self.work, self.env, False)

    def g(self, *a, check=True):
        return run(['git'] + list(a), self.work, self.env, check).stdout.strip()

    def gh(self, *a, check=True):
        return run(['git'] + list(a), self.harness_dir, self.env, check).stdout.strip()

    def write(self, rel, text):
        p = os.path.join(self.work, rel)
        os.makedirs(os.path.dirname(p) or self.work, exist_ok=True)
        with open(p, 'w', encoding='utf-8') as f:
            f.write(text)

    def commit(self, msg, author='mir'):
        self.g('add', '-A')
        self.g('-c', 'user.name=%s' % author, '-c', 'user.email=%s@133' % author, 'commit', '-q', '-m', msg)
        return self.g('rev-parse', 'HEAD')

    def tok(self):
        return '%08x' % self.rnd.getrandbits(32)

    def wfile(self, name, text):
        with open(os.path.join(self.d, name), 'w', encoding='utf-8') as f:
            f.write(text)

    def sverka_file(self, name, key, rawkey):
        if self.cell.get(rawkey) is not None:
            self.wfile(name, self.cell[rawkey])
        else:
            self.wfile(name, ''.join('KADR\t%s\n' % '\t'.join(r) for r in self.cell[key]))

    # ── выдача ворот в git-состоянии продукта: refs байтов задания и БАЗЫ ──
    def vydacha(self, baza):
        """Мир играет честный zadanie: байты задания + refs/dovodka/{baza,zadanie}."""
        lines = zadanie_lines(self.cell, self.work, self.kadry, self.makety, ekran_tag(self.cell), baza)
        self.wfile('zadanie-vydacha.md', ''.join(l + '\n' for l in lines))
        blob = self.g('hash-object', '-w', os.path.join(self.d, 'zadanie-vydacha.md'))
        self.g('update-ref', 'refs/dovodka/baza', baza)
        self.g('update-ref', 'refs/dovodka/zadanie', blob)

    def build(self, subject):
        if self.cell['rezhim'] == 'dver':
            # клетка двери 095 (блокер 1 круга 2): живая проба на клоне дерева
            # харнесса; субъект НЕ участвует; маркер заморозки 133 синтезируется
            # миром (на станции в момент шага экран уже заморожен)
            snap = os.path.join(self.d, 'harness-snap')
            run(['git', 'clone', '-q', '--no-hardlinks', TREE_ROOT, snap], self.d, self.env)
            run(['git', '-C', snap, 'tag', '-f', 'frozen/contracts/133/1', 'HEAD'], self.d, self.env)
            self.wfile('dver-trace.tsv', 'implementer\tprobe/sonnet-v4\tallowed\n')
            self.wfile('dver-zadanie.md', 'ZADANIE-PROBE-133\n')
            return
        run(['git', 'init', '-q', '-b', 'main', self.work], self.d, self.env)
        # мини-харнесс: замороженный контракт экрана (блокер 2 круга 2)
        run(['git', 'init', '-q', '-b', 'main', self.harness_dir], self.d, self.env)
        os.makedirs(os.path.join(self.harness_dir, 'contracts'), exist_ok=True)
        with open(os.path.join(self.harness_dir, 'contracts', '%s-ekran.md' % self.cell.get('ekran_nnn', '132')),
                  'w', encoding='utf-8') as f:
            f.write('# Контракт экрана (мир батареи 133)\n'
                    + ''.join('ЗОНА implementer: %s\n' % z for z in self.cell['ekran_zona']))
        self.gh('add', '-A')
        self.gh('-c', 'user.name=freeze', '-c', 'user.email=freeze@133', 'commit', '-q', '-m', 'ekran: zamorozka')
        if not self.cell.get('ekran_net_tega'):
            self.gh('tag', ekran_tag(self.cell))
        os.makedirs(self.kadry)
        os.makedirs(self.makety)
        os.makedirs(self.bin)
        # продукт: UI-слой (mobile/src/) и НЕ-UI пути (workflow, e2e, docs/ux)
        self.write('mobile/src/ui/Splash.tsx', 'export const Splash = %s\n' % self.tok())
        self.write('mobile/src/lib/tokens.ts', 'export const t = %s\n' % self.tok())
        self.write('.github/workflows/mobile.yml', 'name: mobile\n')
        self.write('mobile/e2e/vkhod.yaml', 'flow: vkhod\n')
        self.write('docs/ux/Splash.png', 'PNG-mir-133-%s\n' % self.tok())
        # обвязка мира (.omp/, scripts/, двойники) уходит в БАЗОВЫЙ коммит вместе с
        # продуктом: дифф база..HEAD видит только правки доводки клетки, а не
        # сантехнику мира (иначе add -A клетки подхватывает .omp/config.yml)
        self.sverka_file('sverka-do.tsv', 'sverka_do', 'sverka_raw_do')
        if self.cell.get('sverka_posle') is not None or self.cell.get('sverka_raw_posle') is not None:
            self.sverka_file('sverka-posle.tsv', 'sverka_posle', 'sverka_raw_posle')
        self.wfile('ui-zona.txt', ''.join(z + '\n' for z in self.cell['ui_zona']))
        self.wfile('ekran.md', '# Контракт экрана (мир батареи 133)\n'
                  + ''.join('ЗОНА implementer: %s\n' % z for z in self.cell['ekran_zona']))
        # конфиг моделей мира: тир vision объявлен клеткой (или не объявлен)
        v = self.cell.get('vision', {})
        cfg = 'models:\n  default: "probe/tekst-m1"\n'
        if not v.get('net_tira'):
            cfg += '  vision: "%s"\n' % v['model']
        os.makedirs(os.path.join(self.work, '.omp'), exist_ok=True)
        with open(os.path.join(self.work, '.omp', 'config.yml'), 'w', encoding='utf-8') as f:
            f.write(cfg)
        rows = ['probe/tekst-m1\tyes\n']
        if not v.get('net_tira') and not v.get('ne_perechislena'):
            rows.append('%s\t%s\n' % (v['model'], v.get('images', 'yes')))
        with open(self.models_tsv, 'w', encoding='utf-8') as f:
            f.write('' if v.get('omp_pustoj') else ''.join(rows))
        os.makedirs(os.path.join(self.work, 'scripts'), exist_ok=True)
        shutil.copy(os.path.join(DV, 'overlay.sh'), os.path.join(self.work, 'scripts', 'overlay.sh'))
        shutil.copy(os.path.join(DV, 'omp'), os.path.join(self.bin, 'omp'))
        os.chmod(os.path.join(self.bin, 'omp'), 0o755)
        if subject:
            shutil.copy(subject, os.path.join(self.work, 'scripts', 'dovodka_ui.sh'))
        self.base = self.commit('ekran: bazovyj kommit + obvjazka mira', 'implementer')
        # выдача ворот ДО шагов мира: c24 (правка текста ПОСЛЕ выдачи) и c25
        # (повторная выдача при непогашенной) фиксируются честно на базе
        self.zadanie_base = None
        redakt_posle = (self.cell['rezhim'] == 'zona' and self.cell.get('redaktirovana_baza')
                        and self.cell.get('zadanie_raw') is None)
        if redakt_posle or self.cell.get('vydacha_do_shagov'):
            self.vydacha(self.base)
        for st in self.cell.get('shagi', []):
            getattr(self, 'op_' + st[0])()
        # задание — вход zona-клеток: мир пишет его сам по грамматике ворот (единый
        # источник байтов — zadanie_lines); zadanie_raw = рукописная/подменённая
        # правка БАЗЫ ПОСЛЕ вне-зонного коммита (c24, блокер 3 круга 2): текст
        # правится, refs выдачи остаются на базе — байты обязаны разойтись
        if self.cell['rezhim'] == 'zona':
            if self.cell.get('zadanie_raw') is not None:
                self.wfile('zadanie.md', self.cell['zadanie_raw'])
            elif redakt_posle:
                edited = zadanie_lines(self.cell, self.work, self.kadry, self.makety,
                                       ekran_tag(self.cell), self.g('rev-parse', 'HEAD'))
                self.wfile('zadanie.md', ''.join(l + '\n' for l in edited))
                self.zadanie_base = self.base
            else:
                self.wfile('zadanie.md', ''.join(l + '\n' for l in
                            zadanie_lines(self.cell, self.work, self.kadry, self.makety,
                                          ekran_tag(self.cell), self.base)))
                self.zadanie_base = self.base
                blob = self.g('hash-object', '-w', os.path.join(self.d, 'zadanie.md'))
                self.g('update-ref', 'refs/dovodka/baza', self.base)
                self.g('update-ref', 'refs/dovodka/zadanie', blob)

    # ── шаги мира (правки доводки в продукте) ──
    def op_ui(self):
        self.write('mobile/src/ui/Splash.tsx', 'export const Splash = %s\n' % self.tok())
        self.commit('dovodka: pravka UI %s' % self.tok(), 'implementer-vision')

    def op_workflow(self):
        self.write('.github/workflows/mobile.yml', 'name: mobile\ndovodka: lishnee\n')
        self.commit('dovodka: workflow %s' % self.tok(), 'implementer-vision')

    def op_pereimena(self):
        self.g('mv', '.github/workflows/mobile.yml', 'mobile/src/wf.yml')
        self.commit('dovodka: pereimen %s' % self.tok(), 'implementer-vision')

    def cmd_zadanie(self):
        cmd = ['bash', 'scripts/dovodka_ui.sh', 'zadanie',
               '--sverka', os.path.join(self.d, 'sverka-do.tsv'),
               '--repo', self.work, '--ui-zona', os.path.join(self.d, 'ui-zona.txt'),
               '--ekran', self.cell.get('ekran_nnn', '132'),
               '--harness', self.harness_dir,
               '--kadry', self.kadry, '--makety', self.makety,
               '--out', os.path.join(self.d, 'zadanie.md')]
        if self.cell.get('dop_arg_kontrakt'):
            # c26 (блокер 2 круга 2): файл контракта экрана от вызывающего
            cmd += ['--kontrakt-ekrana', os.path.join(self.d, 'ekran.md')]
        return cmd

    def cmd_zona(self, zadanie):
        if self.cell.get('zona_starye_args'):
            # c20: старая грамматика (--base/--ui-zona/--kontrakt-ekrana от
            # вызывающего) — «неизвестный аргумент zona»
            return ['bash', 'scripts/dovodka_ui.sh', 'zona',
                    '--repo', self.work, '--base', self.base,
                    '--ui-zona', os.path.join(self.d, 'ui-zona.txt'),
                    '--kontrakt-ekrana', os.path.join(self.d, 'ekran.md')]
        return ['bash', 'scripts/dovodka_ui.sh', 'zona',
                '--repo', self.work, '--zadanie', zadanie,
                '--harness', self.harness_dir]

    def cmd_sudjam(self):
        return ['bash', 'scripts/dovodka_ui.sh', 'sudjam',
                '--do', os.path.join(self.d, 'sverka-do.tsv'),
                '--posle', os.path.join(self.d, 'sverka-posle.tsv'),
                '--out', os.path.join(self.d, 'sudjam.tsv')]

    def run_subject(self, cmd):
        env = dict(self.env)
        env.update({'PATH': self.bin + os.pathsep + os.environ.get('PATH', ''),
                    'OMP133_MODELS': self.models_tsv})
        try:
            return subprocess.run(cmd, cwd=self.work, env=env, capture_output=True, text=True, timeout=60)
        except subprocess.TimeoutExpired:
            return subprocess.CompletedProcess([], 124, '', 'таймаут 60 с')

    def call(self, subject_present):
        if not subject_present:
            return None
        r = self.cell['rezhim']
        if r == 'zadanie':
            cmd = self.cmd_zadanie()
        elif r == 'zona':
            cmd = self.cmd_zona(os.path.join(self.d, 'zadanie.md'))
        elif r == 'sudjam':
            cmd = self.cmd_sudjam()
        else:
            raise Nechem('неизвестный режим клетки: %s' % r)
        return self.run_subject(cmd)

    def call_dver(self):
        """Живая проба двери 095 на клоне мира (блокер 1 круга 2): субъект не зван."""
        snap = os.path.join(self.d, 'harness-snap')
        mt = os.path.join(snap, 'scripts', 'make_task.sh')
        role = 'implementer-vision' if self.cell.get('dver') == 'vne-alfavita' else 'implementer'
        cmd = ['bash', mt, '--repo', snap, '--role', role, '--kind', 'task',
               '--contract', '133', '--model-trace', os.path.join(self.d, 'dver-trace.tsv')]
        if self.cell.get('dver') == 'taskfile':
            cmd += ['--task-file', os.path.join(self.d, 'dver-zadanie.md')]
        try:
            return subprocess.run(cmd, cwd=snap, env=dict(self.env), capture_output=True, text=True, timeout=180)
        except subprocess.TimeoutExpired:
            return subprocess.CompletedProcess([], 124, '', 'таймаут 180 с')

    def close(self):
        shutil.rmtree(self.d, ignore_errors=True)


def judge(cell, subject, seed):
    """→ (список расхождений, деталь). Ожидания снимаются в память ДО вызова субъекта."""
    m = Mir(cell, subject, seed)
    try:
        exp = cell['iskhod']
        r = cell['rezhim']
        do_rows, posle_rows = [], []
        if r != 'dver':
            do_rows = sverka_lines(cell, 'sverka_do', 'sverka_raw_do')
            if r == 'sudjam':
                posle_rows = sverka_lines(cell, 'sverka_posle', 'sverka_raw_posle')
        n_paths = None
        if r == 'zona' and m.zadanie_base:
            n_paths = len([x for x in m.g('diff', '--no-renames', '--name-only', m.zadanie_base, 'HEAD',
                                          check=False).splitlines() if x])
        if r == 'dver':
            # клетки двери: судят грамматику двери 095 живой пробой, не субъект
            p = m.call_dver()
            bad = []
            out, err = p.stdout.splitlines(), p.stderr.splitlines()
            mf = os.path.join(m.d, 'harness-snap', '.omp', 'context', '133.tsv')
            if exp == 'DVER_OK':
                if p.returncode != 0:
                    bad.append('RC')
                if not (os.path.isfile(mf) and os.path.getsize(mf) > 0):
                    bad.append('ARTEFAKT')
            elif exp == 'DVER_OTKAZ':
                if p.returncode != 1:
                    bad.append('RC')
                if not any(l.startswith('ОТКАЗ: ') and cell['prichina'] in l for l in err):
                    bad.append('PRICHINA')
            elif exp == 'DVER_NET_KANALA':
                if p.returncode != 0:
                    bad.append('RC')
                if any('=== TASK ===' in l for l in out):
                    bad.append('VYVOD')
                mrows = open(mf, encoding='utf-8').read().splitlines() if os.path.isfile(mf) else []
                if not mrows or any(x.startswith('task\t') for x in mrows) \
                        or any('ZADANIE-PROBE-133' in l for l in out):
                    bad.append('ARTEFAKT')
            else:
                raise Nechem('неизвестный исход клетки двери: %s' % exp)
            tail = (p.stderr.strip().splitlines() or [''])[-1][:200]
            return bad, 'rc=%d %s' % (p.returncode, tail)
        if subject is None:
            return ['PREDMET'], 'предмет отсутствует'
        if r == 'cep':
            # П-Б2 (арбитраж капа 3): цепь на выходе СУБЪЕКТА. Фаза 1 — исход
            # ZADACHA (rc 0, stdout, задание по ПОРЯДКУ строк — П-Б1, выдача refs
            # судится ДО приёма — успех zona гасит refs); один UI-коммит; фаза 2 —
            # субъект zona по файлу, выданному субъектом: rc 0 «ЗОНА: чисто (путей
            # N)», refs выдачи погашены.
            p1 = m.run_subject(m.cmd_zadanie())
            bad = []
            reds = [l for l in do_rows if l.split('\t')[5] == 'NIZHE_POROGA']
            want = zadanie_lines(cell, m.work, m.kadry, m.makety, ekran_tag(cell), m.base)
            got = []
            zf = os.path.join(m.d, 'zadanie.md')
            if os.path.isfile(zf):
                got = open(zf, encoding='utf-8').read().splitlines()
            if p1.returncode != 0:
                bad.append('RC')
            if not any(l == 'DOVODKA: задание %s; красных кадров %d' % (zf, len(reds))
                       for l in p1.stdout.splitlines()):
                bad.append('VYVOD')
            if got != want:
                bad.append('ARTEFAKT')  # порядок секций семантичен (П-Б1)
            if m.gr('rev-parse', '-q', '--verify', 'refs/dovodka/baza').stdout.strip() != m.base:
                bad.append('VYDACHA')
            blob = m.gr('hash-object', zf).stdout.strip()
            if blob != m.gr('rev-parse', '-q', '--verify', 'refs/dovodka/zadanie').stdout.strip():
                bad.append('VYDACHA')
            m.op_ui()
            p2 = m.run_subject(m.cmd_zona(zf))
            n_paths = len([x for x in m.g('diff', '--no-renames', '--name-only',
                                          m.base, 'HEAD', check=False).splitlines() if x])
            if p2.returncode != 0:
                bad.append('RC')
            if not any(l == 'ЗОНА: чисто (путей %d)' % n_paths for l in p2.stdout.splitlines()):
                bad.append('VYVOD')
            for ref in ('refs/dovodka/zadanie', 'refs/dovodka/baza'):
                if m.gr('rev-parse', '-q', '--verify', ref).returncode == 0:
                    bad.append('POGASHENO')  # приём состоялся — выдача погашена
                    break
            bad = list(dict.fromkeys(bad))
            tail = (p2.stderr.strip().splitlines() or [''])[-1][:200]
            return bad, 'rc=%d/%d %s' % (p1.returncode, p2.returncode, tail)
        p = m.call(True)
        bad = []
        out, err = p.stdout.splitlines(), p.stderr.splitlines()
        if exp in ('OTKAZ', 'NECHEM'):
            want_rc, pref = (1, 'ОТКАЗ dovodka: ') if exp == 'OTKAZ' else (2, 'НЕЧЕМ СУДИТЬ dovodka: ')
            if p.returncode != want_rc:
                bad.append('RC')
            if not any(l.startswith(pref) and cell['prichina'] in l for l in err):
                bad.append('PRICHINA')
            if r == 'zadanie' and os.path.exists(os.path.join(m.d, 'zadanie.md')):
                bad.append('ARTEFAKT')  # отказ не пишет задание (И-1)
        elif exp == 'ZADACHA':
            if p.returncode != 0:
                bad.append('RC')
            reds = [l for l in do_rows if l.split('\t')[5] == 'NIZHE_POROGA']
            want = zadanie_lines(cell, m.work, m.kadry, m.makety, ekran_tag(cell), m.base)
            if not any(l == 'DOVODKA: задание %s; красных кадров %d' % (os.path.join(m.d, 'zadanie.md'), len(reds)) for l in out):
                bad.append('VYVOD')
            got = []
            zf = os.path.join(m.d, 'zadanie.md')
            if os.path.isfile(zf):
                got = open(zf, encoding='utf-8').read().splitlines()
            if got != want:
                bad.append('ARTEFAKT')  # порядок секций семантичен (П-Б1)
            # выдача зафиксирована в git-состоянии (блокер 3 круга 2): refs байтов и БАЗЫ
            if m.gr('rev-parse', '-q', '--verify', 'refs/dovodka/baza').stdout.strip() != m.base:
                bad.append('VYDACHA')
            blob = m.gr('hash-object', zf).stdout.strip()
            if blob != m.gr('rev-parse', '-q', '--verify', 'refs/dovodka/zadanie').stdout.strip():
                bad.append('VYDACHA')
        elif exp == 'CHISTO':
            if p.returncode != 0:
                bad.append('RC')
            if not any(l == 'ЗОНА: чисто (путей %d)' % n_paths for l in out):
                bad.append('VYVOD')
            for ref in ('refs/dovodka/zadanie', 'refs/dovodka/baza'):
                if m.gr('rev-parse', '-q', '--verify', ref).returncode == 0:
                    bad.append('POGASHENO')  # приём состоялся — выдача погашена
                    break
        else:  # SUD_OK / SUD_KRASNO
            pdo = {}
            for l in do_rows:
                t = l.split('\t')
                pdo[t[1]] = t
            ppo = {}
            for l in posle_rows:
                t = l.split('\t')
                ppo[t[1]] = t
            want = ['SUD\t%s\t%s\t%s\t%s\t%s\t%s' % (i, t[2], ppo[i][2], t[3], ppo[i][4], ppo[i][5])
                    for i, t in pdo.items()]
            want_rc = 0 if exp == 'SUD_OK' else 1
            if p.returncode != want_rc:
                bad.append('RC')
            got = []
            sf = os.path.join(m.d, 'sudjam.tsv')
            if os.path.isfile(sf):
                got = open(sf, encoding='utf-8').read().splitlines()
            if sorted(got) != sorted(want):
                bad.append('ARTEFAKT')
            if exp == 'SUD_OK':
                if not any(l == 'СУДЬЯМ: числа предъявлены (кадров %d)' % len(pdo) for l in out):
                    bad.append('VYVOD')
            else:
                if not any(l.startswith('ОТКАЗ dovodka: ') and 'не завершена' in l for l in err):
                    bad.append('PRICHINA')
        tail = (p.stderr.strip().splitlines() or [''])[-1][:200]
        return bad, 'rc=%d %s' % (p.returncode, tail)
    finally:
        m.close()


def stub_text(stub):
    t = open(MODEL, encoding='utf-8').read()
    k = t.count(stub['anchor'])
    if k != 1:
        raise Nechem('якорь подмены %s встречается в модели %d раз (нужно 1)' % (stub['id'], k))
    return t.replace(stub['anchor'], stub['zamena'])


def main(argv):
    mode, cand, only, seed = 'product', None, None, None
    i = 0
    while i < len(argv):
        a = argv[i]
        if a in ('--model', '--stabs'):
            mode = a[2:]
        elif a == '--candidate' and i + 1 < len(argv):
            mode, cand = 'candidate', argv[i + 1]
            i += 1
        elif a == '--cell' and i + 1 < len(argv):
            only = argv[i + 1]
            i += 1
        elif a == '--seed' and i + 1 < len(argv):
            seed = argv[i + 1]
            i += 1
        else:
            print('NOT_IMPLEMENTED: неизвестный аргумент: %s' % a, file=sys.stderr)
            return 2
        i += 1
    for tool in ('git', 'bash'):
        if not shutil.which(tool):
            print('NOT_IMPLEMENTED: нет %s' % tool, file=sys.stderr)
            return 2
    if seed is None:
        seed = str(random.SystemRandom().randrange(1, 10 ** 6))
    cells = SRC['cells']
    if only:
        cells = [c for c in cells if c['id'] == only]
        if not cells:
            print('НЕЧЕМ СУДИТЬ: нет такой клетки: %s' % only, file=sys.stderr)
            return 2
    root = os.path.abspath(cand) if mode == 'candidate' else TREE_ROOT
    print('seed=%s режим=%s корень=%s' % (seed, mode, root))
    try:
        if mode == 'stabs':
            return run_stabs(cells, seed)
        subject = MODEL if mode == 'model' else os.path.join(root, SRC['subject_rel'])
        if not os.path.isfile(subject):
            subject = None
        ok = 0
        for c in cells:
            bad, det = judge(c, subject, seed)
            if bad:
                print('%s: РАСХОЖДЕНИЕ %s (ожидалось %s; %s)' % (c['id'], ','.join(bad), c['iskhod'], det))
            else:
                ok += 1
                print('%s: СОШЛОСЬ %s' % (c['id'], c['iskhod']))
        label = {'product': 'продукт', 'candidate': 'кандидат', 'model': 'модель'}[mode]
        extra = '; предмет отсутствует' if subject is None else ''
        print('ИТОГ 133 (%s): клеток %d, сошлось %d, расхождений %d%s' % (label, len(cells), ok, len(cells) - ok, extra))
        return 0 if ok == len(cells) else 1
    except Nechem as e:
        print('НЕЧЕМ СУДИТЬ: %s' % e, file=sys.stderr)
        return 2


def run_stabs(cells, seed):
    ids = {c['id'] for c in cells}
    by_id = {c['id']: c for c in SRC['cells']}
    stubs = [s for s in SRC['stubs'] if s['cell'] in ids]
    if not stubs:
        print('НЕЧЕМ СУДИТЬ: пустая выборка подмен', file=sys.stderr)
        return 2
    caught = 0
    for s in stubs:
        cell = by_id[s['cell']]
        bad0, det0 = judge(cell, MODEL, seed)
        if bad0:
            print('%s @ %s: КОНТРОЛЬ НЕ СОШЁЛСЯ %s (%s)' % (s['id'], cell['id'], ','.join(bad0), det0))
            continue
        fd, path = tempfile.mkstemp(prefix='dovodka133-stub.', suffix='.sh', dir=TMPBASE)
        with os.fdopen(fd, 'w', encoding='utf-8') as f:
            f.write(stub_text(s))
        try:
            bad, det = judge(cell, path, seed)
        finally:
            os.unlink(path)
        if bad and bad != ['PREDMET']:
            caught += 1
            print('%s @ %s: ПОЙМАН %s (%s)' % (s['id'], cell['id'], ','.join(bad), s['defect']))
        else:
            print('%s @ %s: НЕ ПОЙМАН (%s)' % (s['id'], cell['id'], s['defect']))
    print('ИТОГ 133 (стабы): стабов %d, поймано %d, непойманных %d' % (len(stubs), caught, len(stubs) - caught))
    return 0 if caught == len(stubs) else 1


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
