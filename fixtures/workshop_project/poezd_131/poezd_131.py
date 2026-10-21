#!/usr/bin/env python3
"""Движок батареи 131 (poezd-bez-dogonyalok): публикация main доказанным префиксом.

Режимы (раннер red_poezd_131.sh передаёт argv как есть):
  (без режима)          субъект = <корень дерева батареи>/scripts/publikaciya_main.sh
  --candidate <клон>    субъект и классификатор — из клона implementer
  --model               субъект = model/publikaciya_main.sh, классификатор — дерева батареи
  --stabs               на каждую подмену source.json: КОНТРОЛЬ (модель сходится в её клетке),
                        затем ПОДМЕНА (подменённая модель обязана разойтись) → ПОЙМАН
  --cell <id>           только эта клетка (с любым режимом)
  --seed <N>            seed миров (содержимое, длина учётного хвоста, учётные пути)

Мир клетки — mktemp: bare origin.git, рабочий клон work/ (main), в дереве: реестр с uchet,
настоящий scripts/ci_klass.sh судимого дерева (единственный источник H и доказательства,
контракт 087), двойник scripts/gitw (журнал argv), субъект scripts/publikaciya_main.sh.
Доказательство тяжёлого прогона — строка «<H> <sha поезда>» файла мира, отдаваемая двойником
curl (PATH) на запрос артефактов; поезд — КОПИЯ состояния main (commit-tree того же дерева на
ветке owner/train-<i>), как поезда станции 21.10 (не предки main).

Оракул в памяти: до вызова субъекта снимаются sha метки P, вершины origin и локального main;
диск мира после вызова сверяется с ними. Исходы: PUSH (rc 0, ровно одна строка журнала gitw
`push origin <P>:refs/heads/main`, origin == P, stdout-строка `ПУБЛИКАЦИЯ: <P> …`), NOOP (rc 0,
push не звался, origin не тронут), REFUSE (rc 1, push не звался, строка stderr
`ОТКАЗ публикация: …<причина>…`), NO_JUDGE (rc 2, push не звался, строка
`НЕЧЕМ СУДИТЬ публикация: `), GITW_FAIL (rc 1, ровно одна строка push с P, origin не тронут).
Во всех исходах локальный main не меняется.
Алфавит расхождений: RC, GITW, ORIGIN, LOCAL, PRICHINA, VYVOD, PREDMET (предмет отсутствует).

Коды: 0 — всё сошлось / все подмены пойманы; 1 — расхождение / непойманная подмена / предмет
отсутствует; 2 — нечем судить (нет git/bash, нет классификатора, якорь подмены не единствен,
мир не строится, нет такой клетки).
"""
import json, os, random, shutil, subprocess, sys, tempfile, time

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = json.load(open(os.path.join(HERE, 'source.json'), encoding='utf-8'))
TREE_ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
DV = os.path.join(HERE, 'dvoyniki')
MODEL = os.path.join(HERE, 'model', 'publikaciya_main.sh')
TMPBASE = os.environ.get('TMPDIR', '/tmp')


class Nechem(Exception):
    pass


def run(cmd, cwd, env=None, check=True):
    p = subprocess.run(cmd, cwd=cwd, env=env, capture_output=True, text=True)
    if check and p.returncode != 0:
        raise Nechem('мир не строится: %s rc=%d: %s' % (' '.join(cmd), p.returncode, p.stderr.strip()[:300]))
    return p


def base_env(home):
    e = {k: v for k, v in os.environ.items() if not k.startswith('GIT_') and not k.startswith('POEZD131_')}
    e.update({'HOME': home, 'GIT_CONFIG_GLOBAL': '/dev/null', 'GIT_CONFIG_SYSTEM': '/dev/null',
              'GIT_AUTHOR_NAME': 'mir', 'GIT_AUTHOR_EMAIL': 'mir@131', 'GIT_COMMITTER_NAME': 'mir',
              'GIT_COMMITTER_EMAIL': 'mir@131', 'LC_ALL': 'C.UTF-8'})
    return e


class Mir:
    def __init__(self, cell, subject, klass, seed):
        self.cell, self.rnd = cell, random.Random('%s/%s' % (seed, cell['id']))
        self.d = tempfile.mkdtemp(prefix='poezd131.', dir=TMPBASE)
        self.env = base_env(self.d)
        self.origin = os.path.join(self.d, 'origin.git')
        self.w = os.path.join(self.d, 'work')
        self.dokaz = os.path.join(self.d, 'dokaz.txt')
        self.gitw_log = os.path.join(self.d, 'gitw.log')
        self.klass = klass
        self.metka = None
        self.trains = 0
        self.n = 0
        open(self.dokaz, 'w').close()
        open(self.gitw_log, 'w').close()
        self.build(subject)

    def g(self, *a, cwd=None, check=True):
        return run(['git'] + list(a), cwd or self.w, self.env, check).stdout.strip()

    def write(self, rel, text):
        p = os.path.join(self.w, rel)
        os.makedirs(os.path.dirname(p) or self.w, exist_ok=True)
        with open(p, 'w', encoding='utf-8') as f:
            f.write(text)

    def commit(self, msg, author='mir'):
        self.g('add', '-A')
        self.g('-c', 'user.name=%s' % author, '-c', 'user.email=%s@131' % author, 'commit', '-q', '-m', msg)
        return self.g('rev-parse', 'HEAD')

    def tok(self):
        self.n += 1
        return '%d-%08x' % (self.n, self.rnd.getrandbits(32))

    def build(self, subject):
        run(['git', 'init', '-q', '--bare', '-b', 'main', self.origin], self.d, self.env)
        run(['git', 'init', '-q', '-b', 'main', self.w], self.d, self.env)
        self.write('registry/ci-steps.tsv', '# мир 131\n' + ''.join('uchet\t%s\n' % u for u in SRC['uchet']))
        os.makedirs(os.path.join(self.w, 'scripts'))
        shutil.copy(self.klass, os.path.join(self.w, 'scripts', 'ci_klass.sh'))
        shutil.copy(os.path.join(DV, 'gitw'), os.path.join(self.w, 'scripts', 'gitw'))
        if subject:
            shutil.copy(subject, os.path.join(self.w, 'scripts', 'publikaciya_main.sh'))
        self.write('src/kod.sh', 'echo %s\n' % self.tok())
        self.write('HANDOFF.md', '# мир\n')
        self.write('forks/osnova.md', 'основа мира: учётный файл, неизменный до клеток 131\n')
        self.base = self.commit('base')
        self.g('remote', 'add', 'origin', self.origin)
        self.g('push', '-q', 'origin', 'main')
        self.g('fetch', '-q', 'origin')
        for st in self.cell['shagi']:
            getattr(self, 'op_' + st[0])(*st[1:])

    # ── шаги мира ──
    def op_kod(self):
        self.write('src/kod.sh', 'echo %s\n' % self.tok())
        self.commit('land: kod %s' % self.tok(), 'implementer')

    def op_uchet(self):
        kind = self.rnd.choice(['verdicts/v-%s.md', 'forks/f-%s.md', 'HANDOFF.md', 'NABLIUDENIA.md'])
        rel = kind % self.tok() if '%s' in kind else kind
        self.write(rel, 'учёт %s\n' % self.tok())
        self.commit('verdict (131): учёт %s' % self.tok(), 'reviewer')

    def op_uchet_hvost(self):
        for _ in range(self.rnd.randint(1, 3)):
            self.op_uchet()

    def op_smesh(self):
        self.write('verdicts/smesh-%s.md' % self.tok(), 'вердикт\n')
        self.write('src/kod.sh', 'echo %s\n' % self.tok())
        self.commit('verdict (999): вердикт %s' % self.tok(), 'reviewer')

    def op_podpis(self):
        self.write('src/kod.sh', 'echo %s\n' % self.tok())
        self.commit('HANDOFF: чекпойнт %s' % self.tok(), 'orchestrator')

    # ── маскировка: кодовое изменение под учётной подписью, видимое только во ВСЕХ статусах diff ──
    def zamaskirovat(self, what):
        self.write('HANDOFF.md', 'учёт %s\n' % self.tok())
        self.commit('HANDOFF: %s %s' % (what, self.tok()), 'orchestrator')

    def op_udalenie(self):
        # D кодового пути + A учётного (содержимое несхоже — rename не сопоставится)
        os.remove(os.path.join(self.w, 'src', 'kod.sh'))
        self.write('verdicts/v-%s.md' % self.tok(), 'учёт %s\n' % self.tok())
        self.zamaskirovat('удалены устаревшие файлы')

    def op_pereimen_v_uchet(self):
        # R: src/kod.sh (неизменный от R) → verdicts/…; новый путь учётный
        os.makedirs(os.path.join(self.w, 'verdicts'), exist_ok=True)
        self.g('mv', 'src/kod.sh', 'verdicts/kod-%s.md' % self.tok())
        self.zamaskirovat('перенос в вердикты')

    def op_pereimen_iz_ucheta(self):
        # R: forks/osnova.md (неизменный от R) → src/…; старый путь учётный
        self.g('mv', 'forks/osnova.md', 'src/osnova-%s.sh' % self.tok())
        self.commit('forks: перенос %s' % self.tok(), 'orchestrator')

    def op_kopiya(self):
        # C: копия неизменного учётного forks/osnova.md в кодовый путь
        shutil.copy(os.path.join(self.w, 'forks', 'osnova.md'), os.path.join(self.w, 'src', 'osnova-%s.sh' % self.tok()))
        self.commit('forks: копия %s' % self.tok(), 'orchestrator')

    def op_rezhim(self):
        # M только режимом: 100644 → 100755, blob тот же
        os.chmod(os.path.join(self.w, 'src', 'kod.sh'), 0o755)
        self.zamaskirovat('режим')

    def op_tip(self):
        # T: обычный файл → символьная ссылка
        p = os.path.join(self.w, 'src', 'kod.sh')
        os.remove(p)
        os.symlink('kod-%s' % self.tok(), p)
        self.zamaskirovat('ссылка')

    # ── merge-миры (круг 3, обход критика 131 круг 2): боковые ветки и ленды --no-ff ──
    def op_merge_uchet_side(self):
        # Боковая ветка от R: один учётный коммит (verdicts/), датой НОВЕЕ всей main-линии
        # (обе даты +600 с; у merge-коммита даты сняты ДО него, как у критика 131 круг 2),
        # ленд --no-ff в main. W достижим из main только вторым родителем.
        r = self.g('rev-parse', 'refs/remotes/origin/main')
        self.g('checkout', '-q', '-b', 'wip-side', r)
        self.write('verdicts/side-%s.md' % self.tok(), 'вердикт боковой ветки\n')
        late = str(int(time.time()) + 600)
        self.env['GIT_AUTHOR_DATE'] = late; self.env['GIT_COMMITTER_DATE'] = late
        self.side = self.commit('verdict (131): боковой', 'reviewer')
        del self.env['GIT_AUTHOR_DATE'], self.env['GIT_COMMITTER_DATE']
        self.g('checkout', '-q', 'main')
        self.g('merge', '-q', '--no-ff', '-m', 'land: wip/131/reviewer', 'wip-side')
        self.g('branch', '-q', '-D', 'wip-side')

    def op_merge_kod_side(self):
        # Боковая ветка от R: один КОДОВЫЙ коммит (src/dop-*, отдельный путь — без конфликта),
        # датой новее, со СВОИМ доказательством-поездом; ленд --no-ff в main. H(merge) —
        # новая кодовая комбинация без доказательства.
        r = self.g('rev-parse', 'refs/remotes/origin/main')
        self.g('checkout', '-q', '-b', 'wip-kod', r)
        self.write('src/dop-%s.sh' % self.tok(), 'echo dop %s\n' % self.tok())
        late = str(int(time.time()) + 600)
        self.env['GIT_AUTHOR_DATE'] = late; self.env['GIT_COMMITTER_DATE'] = late
        c = self.commit('land: kod dop %s' % self.tok(), 'implementer')
        del self.env['GIT_AUTHOR_DATE'], self.env['GIT_COMMITTER_DATE']
        self.prove(c)
        self.g('checkout', '-q', 'main')
        self.g('merge', '-q', '--no-ff', '-m', 'land: wip/131/implementer', 'wip-kod')
        self.g('branch', '-q', '-D', 'wip-kod')

    def kod_hash(self, rev):
        p = run(['bash', os.path.join(self.w, 'scripts', 'ci_klass.sh'), 'hash', rev], self.w, self.env)
        h = p.stdout.strip()
        if len(h) != 64:
            raise Nechem('ci_klass.sh hash не дал H: %r' % h)
        return h

    def prove(self, tree_rev):
        self.trains += 1
        tree = self.g('rev-parse', tree_rev + '^{tree}')
        t = self.g('commit-tree', tree, '-p', self.base, '-m', 'train %d' % self.trains)
        self.g('branch', 'owner/train-%d' % self.trains, t)
        with open(self.dokaz, 'a') as f:
            f.write('%s %s\n' % (self.kod_hash(t), t))

    def op_poezd(self):
        self.prove('HEAD')

    def op_chuzhoj_poezd(self):
        self.g('checkout', '-q', '-b', 'chuzhoj', self.base)
        self.write('src/kod.sh', 'echo chuzhoj %s\n' % self.tok())
        c = self.commit('chuzhoj')
        self.g('checkout', '-q', 'main')
        self.g('branch', '-q', '-D', 'chuzhoj')
        self.prove(c)

    def op_metka(self):
        self.metka = self.g('rev-parse', 'HEAD')

    def op_origin_vpered(self, fetch):
        o2 = os.path.join(self.d, 'drugoj')
        run(['git', 'clone', '-q', self.origin, o2], self.d, self.env)
        with open(os.path.join(o2, 'src', 'kod.sh'), 'w') as f:
            f.write('echo drugoj %s\n' % self.tok())
        run(['git', 'commit', '-qam', 'land: drugoj'], o2, self.env)
        run(['git', 'push', '-q', 'origin', 'main'], o2, self.env)
        if fetch:
            self.g('fetch', '-q', 'origin')

    def origin_main(self):
        return run(['git', 'rev-parse', 'refs/heads/main'], self.origin, self.env).stdout.strip()

    def call(self, subject_present):
        env = dict(self.env)
        env.update({'PATH': DV + os.pathsep + os.environ.get('PATH', ''),
                    'CI_KLASS_API': 'http://dvoynik.invalid/repos/o/r',
                    'POEZD131_DOKAZ': self.dokaz, 'POEZD131_GITW_LOG': self.gitw_log})
        env.pop('GITHUB_REPOSITORY', None)
        env.pop('GITHUB_TOKEN', None)
        if self.cell.get('api'):
            env['POEZD131_API'] = self.cell['api']
        if self.cell.get('gitw_rc'):
            env['POEZD131_GITW_RC'] = str(self.cell['gitw_rc'])
        if not subject_present:
            return None
        try:
            return subprocess.run(['bash', 'scripts/publikaciya_main.sh'], cwd=self.w, env=env,
                                  capture_output=True, text=True, timeout=180)
        except subprocess.TimeoutExpired:
            return subprocess.CompletedProcess([], 124, '', 'таймаут 180 с')

    def close(self):
        shutil.rmtree(self.d, ignore_errors=True)


def judge(cell, subject, klass, seed):
    """→ (список расхождений, деталь). Ожидания снимаются в память ДО вызова субъекта."""
    m = Mir(cell, subject, klass, seed)
    try:
        exp = cell['iskhod']
        P = m.metka
        if exp in ('PUSH', 'GITW_FAIL') and not P:
            raise Nechem('клетка %s без метки P' % cell['id'])
        origin0 = m.origin_main()
        local0 = m.g('rev-parse', 'refs/heads/main')
        HP = m.kod_hash(P) if exp == 'PUSH' else None
        k_local = len(m.g('rev-list', '%s..%s' % (P, local0)).split()) if exp == 'PUSH' else None
        p = m.call(subject is not None)
        if p is None:
            return ['PREDMET'], 'предмет отсутствует'
        bad = []
        want_rc = {'PUSH': 0, 'NOOP': 0, 'REFUSE': 1, 'NO_JUDGE': 2, 'GITW_FAIL': 1}[exp]
        if p.returncode != want_rc:
            bad.append('RC')
        pushes = [l for l in open(m.gitw_log, encoding='utf-8').read().splitlines() if l.split(' ', 1)[0] == 'push']
        if exp in ('PUSH', 'GITW_FAIL'):
            if pushes != ['push origin %s:refs/heads/main' % P]:
                bad.append('GITW')
        elif pushes:
            bad.append('GITW')
        origin1 = m.origin_main()
        if origin1 != (P if exp == 'PUSH' else origin0):
            bad.append('ORIGIN')
        if m.g('rev-parse', 'refs/heads/main') != local0:
            bad.append('LOCAL')
        err = p.stderr.splitlines()
        out = p.stdout.splitlines()
        if exp == 'REFUSE':
            if not any(l.startswith('ОТКАЗ публикация: ') and cell['prichina'] in l for l in err):
                bad.append('PRICHINA')
        elif exp == 'NO_JUDGE':
            if not any(l.startswith('НЕЧЕМ СУДИТЬ публикация: ') for l in err):
                bad.append('PRICHINA')
        elif exp == 'PUSH':
            if not any(l == 'ПУБЛИКАЦИЯ: %s H=%s остаётся локально %s' % (P, HP, k_local) for l in out):
                bad.append('VYVOD')
        elif exp == 'NOOP':
            if 'ПУБЛИКАЦИЯ: нечего публиковать' not in out:
                bad.append('VYVOD')
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
            mode, cand = 'candidate', argv[i + 1]; i += 1
        elif a == '--cell' and i + 1 < len(argv):
            only = argv[i + 1]; i += 1
        elif a == '--seed' and i + 1 < len(argv):
            seed = argv[i + 1]; i += 1
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
    klass = os.path.join(root, SRC['klass_rel'])
    if not os.path.isfile(klass):
        print('NOT_IMPLEMENTED: нет классификатора %s' % klass, file=sys.stderr)
        return 2
    print('seed=%s режим=%s корень=%s' % (seed, mode, root))
    try:
        if mode == 'stabs':
            return run_stabs(cells, klass, seed)
        subject = MODEL if mode == 'model' else os.path.join(root, SRC['subject_rel'])
        if not os.path.isfile(subject):
            subject = None
        ok = 0
        for c in cells:
            bad, det = judge(c, subject, klass, seed)
            if bad:
                print('%s: РАСХОЖДЕНИЕ %s (ожидалось %s; %s)' % (c['id'], ','.join(bad), c['iskhod'], det))
            else:
                ok += 1
                print('%s: СОШЛОСЬ %s' % (c['id'], c['iskhod']))
        label = {'product': 'продукт', 'candidate': 'кандидат', 'model': 'модель'}[mode]
        extra = '; предмет отсутствует' if subject is None else ''
        print('ИТОГ 131 (%s): клеток %d, сошлось %d, расхождений %d%s' % (label, len(cells), ok, len(cells) - ok, extra))
        return 0 if ok == len(cells) else 1
    except Nechem as e:
        print('НЕЧЕМ СУДИТЬ: %s' % e, file=sys.stderr)
        return 2


def run_stabs(cells, klass, seed):
    ids = {c['id'] for c in cells}
    by_id = {c['id']: c for c in SRC['cells']}
    stubs = [s for s in SRC['stubs'] if s['cell'] in ids]
    if not stubs:
        print('НЕЧЕМ СУДИТЬ: пустая выборка подмен', file=sys.stderr)
        return 2
    caught = 0
    for s in stubs:
        cell = by_id[s['cell']]
        bad0, det0 = judge(cell, MODEL, klass, seed)
        if bad0:
            print('%s @ %s: КОНТРОЛЬ НЕ СОШЁЛСЯ %s (%s)' % (s['id'], cell['id'], ','.join(bad0), det0))
            continue
        fd, path = tempfile.mkstemp(prefix='poezd131-stub.', suffix='.sh', dir=TMPBASE)
        with os.fdopen(fd, 'w', encoding='utf-8') as f:
            f.write(stub_text(s))
        try:
            bad, det = judge(cell, path, klass, seed)
        finally:
            os.unlink(path)
        if bad and bad != ['PREDMET']:
            caught += 1
            print('%s @ %s: ПОЙМАН %s (%s)' % (s['id'], cell['id'], ','.join(bad), s['defect']))
        else:
            print('%s @ %s: НЕ ПОЙМАН (%s)' % (s['id'], cell['id'], s['defect']))
    print('ИТОГ 131 (стабы): стабов %d, поймано %d, непойманных %d' % (len(stubs), caught, len(stubs) - caught))
    return 0 if caught == len(stubs) else 1


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
