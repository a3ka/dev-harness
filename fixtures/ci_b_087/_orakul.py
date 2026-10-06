# Оракул батареи 087 (fixtures/ci_b_087/) — НЕ субъект и НЕ фикстура. Живёт в памяти
# проверяющего: хеш кодового дерева по ОПРЕДЕЛЕНИЮ контракта 087 (И-1), разбор
# .github/workflows/ci.yml собственным парсером подмножества YAML (без PyYAML — его нет
# гарантированно на раннере), структурные проверки клеток К1–К9 и извлечение команд шагов
# для исполнения. Вызов: python3 _orakul.py <подкоманда> <аргументы…>; rc 0 — зелёное,
# rc 1 — красное (причина — stdout), rc 2 — вход не разобран.
import hashlib
import json
import os
import re
import subprocess
import sys

# U контракта 087 (И-1) — литерально, независимо от реестра субъекта.
U87 = ['verdicts/', 'docs/', 'forks/', '.review/', 'HANDOFF.md', 'ROADMAP.md', 'NABLIUDENIA*',
       'registry/contracts.tsv', 'registry/closed-without-done.tsv', 'registry/plan.tsv']
DECISION = ("needs.klass.outputs.tyazh == 'run'", "${{ needs.klass.outputs.tyazh == 'run' }}")
PUSH_IF = ("github.event_name == 'push'", "${{ github.event_name == 'push' }}")
CMD_RESHENIE = 'bash scripts/ci_klass.sh reshenie >> "$GITHUB_OUTPUT"'
CMD_STRIP = 'bash scripts/ci_klass.sh strip ${{ needs.klass.outputs.kod }}'
CMD_VOROTA = 'bash scripts/ci_klass.sh vorota ${{ github.event.before }} ${{ github.sha }}'
ART_NAME = 'tyazhelyj-${{ needs.klass.outputs.kod }}'
TOKENS = ('${{ github.token }}', '${{ secrets.GITHUB_TOKEN }}')
HEAVY = ('ci', 'antiplacebo', 'obshchij')
JOBS = ('klass', 'legkij', 'vorota', 'obshchij', 'ci', 'antiplacebo', 'tyazhelyj-itog')
# Контур лёгкого задания (К6; арбитраж 063-b4 — закрытая форма, «ничего сверх контура»):
# ключи джобы legkij и её шага лёгкого — только эти; ключей workflow, наследуемых шагом, нет.
LEGKIJ_JOB = ('runs-on', 'steps', 'timeout-minutes')
LEGKIJ_STEP = ('name', 'id', 'run', 'timeout-minutes')
WF_INHERIT = ('defaults', 'env')


# ── хеш кодового дерева (определение И-1) ──────────────────────────────────────
def u_covers(pat, path):
    if pat.endswith('/'):
        return path.startswith(pat)
    if pat.endswith('*'):
        return '/' not in path and path.startswith(pat[:-1])
    return path == pat


def oracle_hash(repo, sha, upats):
    raw = subprocess.run(['git', '-C', repo, 'ls-tree', '-r', '-z', '--full-tree', sha],
                         capture_output=True, check=True).stdout
    h = hashlib.sha256()
    for ent in raw.split(b'\0'):
        if not ent:
            continue
        path = ent.split(b'\t', 1)[1].decode('utf-8', 'surrogateescape')
        if any(u_covers(p, path) for p in upats):
            continue
        h.update(ent + b'\0')
    return h.hexdigest()


# ── парсер подмножества YAML (блочный стиль GitHub workflow) ───────────────────
class Y:
    def __init__(self, text):
        self.l = text.split('\n')

    @staticmethod
    def ind(s):
        return len(s) - len(s.lstrip(' '))

    def sig(self, i):
        while i < len(self.l):
            s = self.l[i]
            if s.strip() and not s.strip().startswith('#'):
                return i
            i += 1
        return i

    @staticmethod
    def scalar(v):
        v = v.strip()
        if v[:1] in ('"', "'") and len(v) >= 2 and v[-1] == v[0]:
            return v[1:-1]
        if v.startswith('[') and v.endswith(']'):
            return [Y.scalar(x) for x in v[1:-1].split(',') if x.strip()]
        m = re.search(r'\s#', v)
        return v[:m.start()].rstrip() if m else v

    def block(self, i, parent):
        j = self.sig(i)
        if j >= len(self.l) or self.ind(self.l[j]) <= parent:
            return None, j
        ind = self.ind(self.l[j])
        if self.l[j].strip().startswith('- ') or self.l[j].strip() == '-':
            return self.seq(j, ind)
        return self.mapping(j, ind)

    def bscalar(self, i, key_ind):
        out, j = [], i
        while j < len(self.l) and (not self.l[j].strip() or self.ind(self.l[j]) > key_ind):
            out.append(self.l[j])
            j += 1
        while out and not out[-1].strip():
            out.pop()
        d = min([self.ind(x) for x in out if x.strip()] or [0])
        return '\n'.join(x[d:] for x in out), j

    def pair(self, text, i, ind):
        m = re.match(r'^([^\s:#][^:]*?):(?:\s+(.*))?$', text)
        if not m:
            raise ValueError('строка %d: не пара ключ-значение: %r' % (i + 1, text))
        k, rest = m.group(1).strip(), (m.group(2) or '').strip()
        if rest in ('|', '|-', '|+', '>', '>-', '>+'):
            v, j = self.bscalar(i + 1, ind)
            return k, {'__block__': v}, j
        if rest == '':
            v, j = self.block(i + 1, ind)
            return k, v, j
        return k, self.scalar(rest), i + 1

    def mapping(self, i, ind):
        d = {}
        j = self.sig(i)
        while j < len(self.l) and self.ind(self.l[j]) == ind and not self.l[j].strip().startswith('-'):
            k, v, j = self.pair(self.l[j].strip(), j, ind)
            d[k] = v
            j = self.sig(j)
        return d, j

    def seq(self, i, ind):
        out = []
        j = self.sig(i)
        while j < len(self.l) and self.ind(self.l[j]) == ind and self.l[j].strip().startswith('-'):
            item = self.l[j].strip()[1:].strip()
            if item == '':
                v, j = self.block(j + 1, ind)
                out.append(v)
            elif re.match(r'^[^\s:#\'"\[][^:]*?:(\s|$)', item):
                kind = ind + 2
                k, v, j = self.pair(item, j, kind)
                d = {k: v}
                j = self.sig(j)
                while j < len(self.l) and self.ind(self.l[j]) == kind and not self.l[j].strip().startswith('-'):
                    k, v, j = self.pair(self.l[j].strip(), j, kind)
                    d[k] = v
                    j = self.sig(j)
                out.append(d)
            else:
                out.append(self.scalar(item))
                j += 1
            j = self.sig(j)
        return out, j


def load_wf(path):
    with open(path, encoding='utf-8') as f:
        text = f.read()
    d, _ = Y(text).mapping(Y(text).sig(0), 0)
    return d, text


def run_of(step):
    r = step.get('run') if isinstance(step, dict) else None
    if isinstance(r, dict):
        return None  # блочный скаляр — однострочным не является
    return r


def steps_of(job):
    s = job.get('steps') if isinstance(job, dict) else None
    return s if isinstance(s, list) else []


def needs_of(job):
    n = job.get('needs') if isinstance(job, dict) else None
    if n is None:
        return []
    return n if isinstance(n, list) else [n]


def has_token(step):
    env = step.get('env') if isinstance(step.get('env'), dict) else {}
    return env.get('GITHUB_TOKEN') in TOKENS


def reg_rows(path, kind):
    rows = []
    with open(path, encoding='utf-8') as f:
        for line in f.read().split('\n'):
            p = line.split('\t')
            if p and p[0] == kind and len(p) >= 2:
                rows.append(p)
    return rows


# ── клетки К1–К9 (структура) ────────────────────────────────────────────────────
def k_check(cell, wf_path, reg_path):
    try:
        wf, text = load_wf(wf_path)
    except Exception as e:  # noqa: BLE001
        return ['ci.yml не разобран: %s' % e]
    jobs = wf.get('jobs') if isinstance(wf.get('jobs'), dict) else {}
    bad = []
    if cell == 'K1':
        for j in JOBS:
            if j not in jobs:
                bad.append('нет джобы %s' % j)
    elif cell == 'K2':
        kj = jobs.get('klass') or {}
        sid = None
        for s in steps_of(kj):
            if run_of(s) == CMD_RESHENIE:
                sid = s.get('id')
                if not has_token(s):
                    bad.append('шаг решения без env GITHUB_TOKEN')
        if not sid:
            bad.append('нет шага с id и run: %s' % CMD_RESHENIE)
        out = kj.get('outputs') if isinstance(kj.get('outputs'), dict) else {}
        for k in ('kod', 'tyazh'):
            if out.get(k) != '${{ steps.%s.outputs.%s }}' % (sid, k):
                bad.append('outputs.%s ≠ ${{ steps.%s.outputs.%s }} (есть %r)' % (k, sid, k, out.get(k)))
    elif cell.startswith('K3:'):
        j = cell[3:]
        job = jobs.get(j) or {}
        if 'klass' not in needs_of(job):
            bad.append('%s: needs без klass' % j)
        if job.get('if') not in DECISION:
            bad.append('%s: if %r ≠ %s' % (j, job.get('if'), DECISION[0]))
    elif cell.startswith('K4:'):
        j = cell[3:]
        runs = [run_of(s) for s in steps_of(jobs.get(j) or {}) if isinstance(s, dict) and 'run' in s]
        if not runs or runs[0] != CMD_STRIP:
            bad.append('%s: первый run-шаг %r ≠ %s' % (j, runs[0] if runs else None, CMD_STRIP))
        elif runs.count(CMD_STRIP) != 1:
            bad.append('%s: strip-шагов %d ≠ 1' % (j, runs.count(CMD_STRIP)))
    elif cell == 'K5':
        job = jobs.get('tyazhelyj-itog') or {}
        miss = [n for n in ('klass',) + HEAVY if n not in needs_of(job)]
        if miss:
            bad.append('tyazhelyj-itog: needs без %s' % ' '.join(miss))
        if job.get('if') not in DECISION:
            bad.append('tyazhelyj-itog: if %r ≠ %s' % (job.get('if'), DECISION[0]))
        up = [s for s in steps_of(job) if isinstance(s, dict)
              and str(s.get('uses', '')).startswith('actions/upload-artifact@')]
        names = [(s.get('with') or {}).get('name') for s in up if isinstance(s.get('with'), dict)]
        if ART_NAME not in names:
            bad.append('tyazhelyj-itog: нет upload-artifact с name: %s (есть %r)' % (ART_NAME, names))
    elif cell == 'K6':
        # Лёгкое — гейт: шаг лёгкого исполняется так, как его исполняет К-исп legkij
        # (всегда, из корня, оболочкой по умолчанию, в окружении раннера), и его отказ роняет
        # джобу legkij. Закрытая форма (арбитраж 063-b4): ключ сверх контура LEGKIJ_JOB /
        # LEGKIJ_STEP / WF_INHERIT — if, continue-on-error, shell, working-directory, env,
        # defaults, needs, strategy, … (перечень иллюстративный) — отключает шаг или джобу
        # либо гасит отказ лёгких проверок: красное; выражения GitHub не толкуются.
        for k in WF_INHERIT:
            if k in wf:
                bad.append('workflow: ключ %s сверх контура — его наследует шаг лёгкого' % k)
        job = jobs.get('legkij')
        job = job if isinstance(job, dict) else {}
        if 'if' in job:
            bad.append('legkij: условная (if %r) — лёгкое задание обязано идти всегда' % job.get('if'))
        extra = [k for k in job if k not in LEGKIJ_JOB and k != 'if']
        if extra:
            bad.append('legkij: ключи джобы сверх контура {%s}: %s'
                       % (', '.join(LEGKIJ_JOB), ' '.join(extra)))
        st_lane = [s for s in steps_of(job) if isinstance(s, dict)
                   and isinstance(run_of(s), str) and run_of(s).startswith('bash scripts/run_ci_lane.sh ')]
        lane = [run_of(s) for s in st_lane]
        if len(lane) != 1:
            bad.append('legkij: шагов run_ci_lane.sh %d ≠ 1 (однострочный скаляр)' % len(lane))
        else:
            extra = [k for k in st_lane[0] if k not in LEGKIJ_STEP]
            if extra:
                bad.append('legkij: ключи шага лёгкого сверх контура {%s}: %s — отказ лёгких '
                           'проверок обязан ронять джобу' % (', '.join(LEGKIJ_STEP), ' '.join(extra)))
            keys = lane[0].split()[2:]
            if '${{' in lane[0]:
                bad.append('legkij: ключи шага не литеральны: %r' % lane[0])
            want = [r[1] for r in reg_rows(reg_path, 'legkij')]
            if not want:
                bad.append('реестр без строк legkij')
            if keys != want:
                bad.append('legkij: ключи шага %r ≠ строкам legkij реестра %r' % (keys, want))
            lanes = []
            cj = jobs.get('ci') or {}
            st = cj.get('strategy') if isinstance(cj.get('strategy'), dict) else {}
            mx = st.get('matrix') if isinstance(st.get('matrix'), dict) else {}
            for e in mx.get('include') or []:
                if isinstance(e, dict) and isinstance(e.get('keys'), str):
                    lanes += e['keys'].split()
            dup = sorted(set(keys) & set(lanes))
            if dup:
                bad.append('ключи legkij в lane-матрице ci: %s' % ' '.join(dup))
    elif cell == 'K7':
        job = jobs.get('vorota') or {}
        if job.get('if') not in PUSH_IF:
            bad.append('vorota: if %r ≠ %s' % (job.get('if'), PUSH_IF[0]))
        st = [s for s in steps_of(job) if isinstance(s, dict) and run_of(s) == CMD_VOROTA]
        if len(st) != 1:
            bad.append('vorota: шагов run: %s — %d ≠ 1' % (CMD_VOROTA, len(st)))
        elif not has_token(st[0]):
            bad.append('vorota: шаг без env GITHUB_TOKEN')
    elif cell == 'K8':
        for n, line in enumerate(text.split('\n'), 1):
            m = re.match(r'^\s*cancel-in-progress:\s*(.*?)\s*$', line)
            if m and m.group(1) != 'false':
                bad.append('строка %d: cancel-in-progress: %s' % (n, m.group(1)))
    elif cell == 'K9':
        where_p, where_a = [], []
        for jn, job in jobs.items():
            for s in steps_of(job):
                r = s.get('run') if isinstance(s, dict) else None
                body = r['__block__'] if isinstance(r, dict) else (r or '')
                if run_of(s) == 'npm run check:ci-parity':
                    where_p.append(jn)
                if 'npm run check:antiplacebo -- "$TMP_ROOT"' in body:
                    where_a.append(jn)
        if where_p != ['obshchij']:
            bad.append('npm run check:ci-parity: джобы %r ≠ [obshchij]' % where_p)
        if where_a != ['obshchij']:
            bad.append('сам-тесты раннера анти-плацебо: джобы %r ≠ [obshchij]' % where_a)
        if 'strategy' in (jobs.get('obshchij') or {}):
            bad.append('obshchij — матричная джоба (strategy)')
        nci = [s for s in steps_of(jobs.get('ci') or {}) if isinstance(s, dict) and 'run' in s]
        if len(nci) != 2:
            bad.append('джоба ci: run-шагов %d ≠ 2 (strip + lane-шаг)' % len(nci))
    else:
        return ['неизвестная клетка %s' % cell]
    return bad


def k_cmd(what, wf_path):
    wf, _ = load_wf(wf_path)
    jobs = wf.get('jobs') or {}
    if what == 'legkij':
        for s in steps_of(jobs.get('legkij') or {}):
            r = run_of(s)
            if isinstance(r, str) and r.startswith('bash scripts/run_ci_lane.sh '):
                return r
    want = {'reshenie': ('klass', CMD_RESHENIE), 'strip': ('ci', CMD_STRIP),
            'vorota': ('vorota', CMD_VOROTA)}.get(what)
    if want:
        for s in steps_of(jobs.get(want[0]) or {}):
            if run_of(s) == want[1]:
                return want[1]
    return ''


# ── toy-мир клеток А/Б (строит батарея; оракул знает его состав) ────────────────
TOY_ENV = dict(os.environ, GIT_AUTHOR_NAME='toy', GIT_AUTHOR_EMAIL='toy@toy',
               GIT_COMMITTER_NAME='toy', GIT_COMMITTER_EMAIL='toy@toy',
               GIT_AUTHOR_DATE='2026-10-06T00:00:00Z', GIT_COMMITTER_DATE='2026-10-06T00:00:00Z',
               GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_SYSTEM=os.devnull)


def reg_text(upats, extra='', last_nolf=False):
    rows = ['lanes\t6'] + ['uchet\t%s' % u for u in upats]
    rows += ['step\tk:a\t5\tbash scripts/a.sh', 'legkij\tk:l\t3\tbash scripts/b.sh']
    if extra:
        rows.append(extra)
    if last_nolf:
        return '\n'.join(rows)
    return '\n'.join(rows) + '\n'


BASE = {
    'scripts/a.sh': 'echo a\n', 'scripts/b.sh': 'echo b\n', 'fixtures/x/case_a.sh': 'exit 1\n',
    'verdicts/critic/v1.md': 'accept\n', 'verdicts/a\tb.md': 'tab\n', 'docs/owner/d.md': 'doc\n',
    'forks/f1.md': 'fork\n', '.review/r1.md': 'status: ready\n', 'HANDOFF.md': 'h\n',
    'ROADMAP.md': 'r\n', 'NABLIUDENIA.md': 'n\n',
    'NABLIUDENIA_ARCHITECT.md': 'na\n', 'registry/contracts.tsv': 'c\n',
    'registry/closed-without-done.tsv': 'cwd\n', 'registry/plan.tsv': 'p\n',
    # ловушки границы: всё ниже — КОД
    'docsx/a.sh': 'dx\n', 'HANDOFFxmd': 'hx\n', 'NABLIUDENIA_x/run.sh': 'nx\n',
    'sub/HANDOFF.md': 'sh\n', 'verdicts.md': 'vm\n', 'x/NABLIUDENIA.md': 'xn\n',
    'scripts/p\nverdicts/q.sh': 'nl\n',
}
# вариант → (ожидаемый класс относительно c0, операции); операция: ('w', путь, текст) запись,
# ('x', путь) chmod +x, ('rm', путь) удаление, ('mv', из, в) переименование.
VARIANTS = {
    'U_verdicts': ('uchet', [('w', 'verdicts/critic/v1.md', 'fail\n'), ('w', 'verdicts/new.md', 'n\n')]),
    'U_docs': ('uchet', [('w', 'docs/owner/d.md', 'doc2\n')]),
    'U_forks': ('uchet', [('w', 'forks/f2.md', 'f2\n')]),
    'U_review': ('uchet', [('w', '.review/r1.md', 'status: partial\n')]),
    'U_handoff': ('uchet', [('w', 'HANDOFF.md', 'h2\n')]),
    'U_roadmap': ('uchet', [('w', 'ROADMAP.md', 'r2\n')]),
    'U_nabl': ('uchet', [('w', 'NABLIUDENIA.md', 'n2\n')]),
    'U_nabl_arch': ('uchet', [('w', 'NABLIUDENIA_ARCHITECT.md', 'na2\n')]),
    'U_reg_contracts': ('uchet', [('w', 'registry/contracts.tsv', 'c2\n')]),
    'U_reg_cwd': ('uchet', [('w', 'registry/closed-without-done.tsv', 'cwd2\n')]),
    'U_reg_plan': ('uchet', [('w', 'registry/plan.tsv', 'p2\n')]),
    'U_tab': ('uchet', [('w', 'verdicts/a\tb.md', 'tab2\n')]),
    'U_del': ('uchet', [('rm', 'docs/owner/d.md')]),
    'K_content': ('kod', [('w', 'scripts/a.sh', 'echo a2\n')]),
    'K_mode': ('kod', [('x', 'scripts/b.sh')]),
    'K_rename': ('kod', [('mv', 'scripts/a.sh', 'scripts/a2.sh')]),
    'K_add': ('kod', [('w', 'scripts/new.sh', 'echo new\n')]),
    'K_del': ('kod', [('rm', 'fixtures/x/case_a.sh')]),
    'K_docsx': ('kod', [('w', 'docsx/a.sh', 'dx2\n')]),
    'K_handoffx': ('kod', [('w', 'HANDOFFxmd', 'hx2\n')]),
    'K_nabl_dir': ('kod', [('w', 'NABLIUDENIA_x/run.sh', 'nx2\n')]),
    'K_sub_handoff': ('kod', [('w', 'sub/HANDOFF.md', 'sh2\n')]),
    'K_verdicts_md': ('kod', [('w', 'verdicts.md', 'vm2\n')]),
    'K_x_nabl': ('kod', [('w', 'x/NABLIUDENIA.md', 'xn2\n')]),
    'K_nl': ('kod', [('w', 'scripts/p\nverdicts/q.sh', 'nl2\n')]),
    'K_registry': ('kod', [('w', 'registry/ci-steps.tsv', reg_text(U87).replace('lanes\t6', 'lanes\t7'))]),
    'W_widen': ('kod', [('w', 'registry/ci-steps.tsv', reg_text(U87, 'uchet\tfixtures/')),
                        ('w', 'fixtures/x/case_a.sh', 'exit 0\n')]),
}
# плохие строки uchet (А7): имя варианта → значение строки «uchet<TAB><значение>»
BAD_UCHET = {
    'B_registry': 'registry/', 'B_scripts_dir': 'scripts/', 'B_github': '.github/',
    'B_klass': 'scripts/ci_klass.sh', 'B_dotdot': '../docs/', 'B_abs': '/docs/',
    'B_dslash': 'docs//x/', 'B_lowglob': 'nabl*', 'B_slashglob': 'docs/*', 'B_space': 'docs/ ',
    'B_empty': '',
}


def wgit(d, *a):
    p = subprocess.run(['git', '-C', d] + list(a), capture_output=True, env=TOY_ENV)
    if p.returncode != 0:
        raise RuntimeError('git %s: %s' % (' '.join(a), p.stderr.decode()))
    return p.stdout.decode().strip()


def apply_ops(d, ops):
    for op in ops:
        if op[0] == 'w':
            fp = os.path.join(d, op[1])
            os.makedirs(os.path.dirname(fp), exist_ok=True)
            with open(fp, 'w', encoding='utf-8') as f:
                f.write(op[2])
        elif op[0] == 'x':
            os.chmod(os.path.join(d, op[1]), 0o755)
        elif op[0] == 'rm':
            wgit(d, 'rm', '-q', '--', op[1])
        elif op[0] == 'mv':
            wgit(d, 'mv', '--', op[1], op[2])


def commit_from(d, base, ops, msg):
    wgit(d, 'checkout', '-q', '--detach', base)
    apply_ops(d, ops)
    wgit(d, 'add', '-A')
    wgit(d, 'commit', '-q', '--allow-empty', '-m', msg)
    return wgit(d, 'rev-parse', 'HEAD')


def build_world(d):
    os.makedirs(d)
    wgit(d, 'init', '-q', '-b', 'main')
    files = dict(BASE)
    files['registry/ci-steps.tsv'] = reg_text(U87)
    apply_ops(d, [('w', p, t) for p, t in files.items()])
    wgit(d, 'add', '-A')
    wgit(d, 'commit', '-q', '-m', 'c0')
    sh = {'C0': wgit(d, 'rev-parse', 'HEAD')}
    for k, (_, ops) in VARIANTS.items():
        sh[k] = commit_from(d, sh['C0'], ops, k)
    for k, v in BAD_UCHET.items():
        sh[k] = commit_from(d, sh['C0'], [('w', 'registry/ci-steps.tsv', reg_text(U87, 'uchet\t' + v))], k)
    sh['P'] = sh['K_content']
    sh['A'] = commit_from(d, sh['P'], [('w', 'HANDOFF.md', 'h-a\n')], 'A: учётное поверх P')
    sh['Q'] = sh['K_add']
    sh['M1'] = commit_from(d, sh['C0'], [('w', 'scripts/b2.sh', 'echo b2\n')], 'M1: main ушёл кодом')
    sh['M1U'] = commit_from(d, sh['C0'], [('w', 'HANDOFF.md', 'h-m\n')], 'M1U: main ушёл учётом')
    for k, base in (('L_MOVED', 'M1'), ('L_OK', 'M1U')):
        wgit(d, 'checkout', '-q', '--detach', sh[base])
        wgit(d, 'merge', '-q', '--no-ff', '--no-edit', '-m', 'land: wip/087/implementer', sh['P'])
        sh[k] = wgit(d, 'rev-parse', 'HEAD')
    # линия без реестра (переход / внешний проект): N0 без registry/, N1 — код поверх
    wgit(d, 'checkout', '-q', '--orphan', 'bezreestra')
    wgit(d, 'rm', '-q', '-r', '--cached', '.')
    for p in list(files):
        os.unlink(os.path.join(d, p))
    apply_ops(d, [('w', 'scripts/a.sh', 'echo a\n')])
    wgit(d, 'add', '-A')
    wgit(d, 'commit', '-q', '-m', 'N0')
    sh['N0'] = wgit(d, 'rev-parse', 'HEAD')
    sh['N1'] = commit_from(d, sh['N0'], [('w', 'scripts/a.sh', 'echo a1\n')], 'N1')
    # тихая потеря (гигиена): последняя строка uchet без перевода строки
    sh['SD0'] = commit_from(d, sh['C0'], [('w', 'registry/ci-steps.tsv',
                                             reg_text([u for u in U87 if u != 'forks/'],
                                                      'uchet\tforks/', last_nolf=True))], 'SD0')
    sh['SD1'] = commit_from(d, sh['SD0'], [('w', 'forks/f3.md', 'f3\n')], 'SD1')
    wgit(d, 'checkout', '-q', 'main')
    for k, v in sh.items():
        wgit(d, 'update-ref', 'refs/heads/t/%s' % k, v)
        print('%s=%s' % (k, v))
    return 0


def variants(kind):
    if kind == 'bad':
        print(' '.join(BAD_UCHET))
    else:
        print(' '.join(k for k, (c, _) in VARIANTS.items() if c == kind and not k.startswith('W_')))
    return 0


def main(a):
    if a[0] == 'hash':
        upats = U87
        if len(a) > 3:
            upats = [r[1] for r in reg_rows(a[3], 'uchet')]
        print(oracle_hash(a[1], a[2], upats))
        return 0
    if a[0] == 'kcheck':
        bad = k_check(a[1], a[2], a[3] if len(a) > 3 else '')
        for b in bad:
            print(b)
        return 1 if bad else 0
    if a[0] == 'kcmd':
        c = k_cmd(a[1], a[2])
        print(c)
        return 0 if c else 1
    if a[0] == 'wf-json':
        print(json.dumps(load_wf(a[1])[0], ensure_ascii=False, indent=1))
        return 0
    if a[0] == 'reg-keys':
        print(' '.join(r[1] for r in reg_rows(a[1], a[2])))
        return 0
    if a[0] == 'world':
        return build_world(a[1])
    if a[0] == 'variants':
        return variants(a[1])
    if a[0] == 'reg-text':
        sys.stdout.write(reg_text(U87))
        return 0
    print('неизвестная подкоманда %s' % a[0])
    return 2


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
