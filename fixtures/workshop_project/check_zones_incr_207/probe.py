#!/usr/bin/env python3
"""207: check_zones --incr — суд окна один раз.

--repo [ROOT] — субъект scripts/check_zones.sh выбранного дерева (по умолчанию
дерево батареи): эквивалентность incr↔полный прогон на той же двери, счётчики
судов окна под strace (красное до реализации), нарушения зон по классам.
--model — модель окна-один-раз: rc и полные байты обоих каналов равны
базовой двери на каждом мире; счётчики по И1 (в том числе ноль при K=0).
--stabs — адресные мутации модели и обманные стабы по stabs.tsv (Н-39):
честный контроль зелёный, мутация различима на связанной клетке; ZHIVYH == 0.
Оракул (ожидания, sha, маркеры, сводки) снимается в память ДО вызова субъекта;
субъект пишет только в одноразовых git-мирах и свой скратч.
"""
import argparse
import ast
import os
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
TREE = HERE.parents[2]
MODEL = HERE / 'model' / 'check_zones.sh'
STABS_TSV = HERE / 'stabs.tsv'

C_STRING = r'"(?:\\.|[^"\\])*"'
EXECVE_RE = re.compile(r'execve\((' + C_STRING + r'), (\[(?:' +
                       C_STRING + r'(?:, )?)*\]), .* = 0$')


def window_counters(traces, base):
    """Успешные execve настоящего git, операция определяется argv, не /usr/bin."""
    anchors = {
        'rk_rev': ('rev-list', '--no-merges', '--reverse', f'{base}..HEAD'),
        'rk_merges': ('rev-list', '--merges', f'{base}..HEAD'),
        'ak': ('log', '--no-walk'),
        'dt': ('diff-tree',),
    }
    counts = dict.fromkeys(anchors, 0)
    seen = 0
    for trace in traces:
        for line in trace.read_text(errors='strict').splitlines():
            match = EXECVE_RE.search(line)
            if not match:
                if 'execve(' in line and line.endswith(' = 0'):
                    raise Prerequisite('не разобран успешный execve strace')
                continue
            seen += 1
            exe, argv = (ast.literal_eval(part) for part in match.groups())
            if not argv or not (Path(argv[0]).name == 'git' or
                                Path(exe).resolve().name == 'git'):
                continue
            args = tuple(argv[1:])
            for key, anchor in anchors.items():
                if any(args[i:i + len(anchor)] == anchor
                       for i in range(len(args) - len(anchor) + 1)):
                    counts[key] += 1
    if not seen:
        raise Prerequisite('strace не предъявил ни одного успешного execve')
    return counts


def model_text(name, anchor, replacement):
    text = MODEL.read_text()
    if text.count(anchor) != 1:
        raise Prerequisite(f'ORACLE_TAMPERED: якорь {name} встречается {text.count(anchor)} раз')
    return text.replace(anchor, replacement)


class Prerequisite(RuntimeError):
    pass


def environment():
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    for name in ('SDACHA_OKRUG', 'HARNESS_PROJECT_LAYER_ROOT', 'HARNESS_WORKFLOW_ROOT'):
        env.pop(name, None)
    env['GIT_CONFIG_GLOBAL'] = '/dev/null'
    env['GIT_CONFIG_SYSTEM'] = '/dev/null'
    return env


def command(argv, cwd=None, timeout=120):
    proc = subprocess.Popen(argv, cwd=cwd, env=environment(), stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, start_new_session=True)
    try:
        out, err = proc.communicate(timeout=timeout)
    except subprocess.TimeoutExpired as exc:
        os.killpg(proc.pid, signal.SIGKILL)
        proc.communicate()
        return 124, b'', b''
    return proc.returncode, out, err


def git(root, *args, author=None):
    who = author or 'Фикстура'
    argv = ['git', '-C', str(root), '-c', f'user.name={who}', '-c', f'user.email={who}@local',
            '-c', 'commit.gpgsign=false', '-c', 'core.hooksPath=/dev/null'] + list(args)
    rc, out, err = command(argv)
    if rc:
        raise Prerequisite(f'git {args}: rc={rc} {err.decode().strip()}')
    return out


def wfile(root, rel, content):
    p = Path(root) / rel
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_bytes(content if isinstance(content, bytes) else content.encode())


def commit_files(root, author, msg):
    git(root, 'add', '-A', author=author)
    git(root, 'commit', '-q', '-m', msg, author=author)


def plural(n):
    n10, n100 = n % 10, n % 100
    if n == 0:
        return '0 коммитов'
    if n10 == 1 and n100 != 11:
        return f'{n} коммит'
    if 2 <= n10 <= 4 and (n100 < 12 or n100 > 14):
        return f'{n} коммита'
    return f'{n} коммитов'


def contract_body(nnn, zone_lines, saved=None):
    body = (f'# контракт {nnn}\n\n## Предмет\nподставной предмет\n\n'
            '## Критерий готовности\nкоманда с кодом возврата\n\n## Исполнители и зоны\n')
    body += '\n'.join(zone_lines) + '\n'
    if saved:
        body += saved + '\n'
    return body


class World:
    """Одноразовый git-мир: контракты заморожены тегами на корне, окно поверх."""

    def __init__(self, root):
        self.root = Path(root)
        self.root.mkdir(parents=True)
        git(self.root, 'init', '-q', '-b', 'main')

    def seed(self, contracts):
        for nnn, lines, saved in contracts:
            wfile(self.root, f'contracts/{nnn}-x.md', contract_body(nnn, lines, saved))
            wfile(self.root, f'verdicts/critic/contracts-{nnn}-v1.md', 'accept\nвердикт критика\n')
        git(self.root, 'add', '-A')
        git(self.root, 'commit', '-q', '-m', 'основание')
        for nnn, _, _ in contracts:
            git(self.root, 'tag', '-a', f'frozen/contracts/{nnn}/1', '-m', 'контракт утверждён')

    def c(self, author, msg, files):
        for rel, content in files.items():
            wfile(self.root, rel, content)
        commit_files(self.root, author, msg)

    def merge(self, msg, ref):
        git(self.root, 'merge', '--no-ff', '-q', '-m', msg, ref)

    def branch(self, name, at):
        git(self.root, 'branch', name, at)

    def checkout(self, ref):
        git(self.root, 'checkout', '-q', ref)

    def tag_id(self, nnn, at):
        git(self.root, 'tag', '-a', f'id/CONTRACT/{nnn}', '-m', f'id {nnn}', at)

    def sha(self, ref='HEAD'):
        return git(self.root, 'rev-parse', ref).decode().strip()


class Battery:
    def __init__(self, repo_root):
        self.repo = repo_root
        self.scratch = Path(tempfile.mkdtemp(prefix='check_zones_incr_207.'))
        self.worlds = {}

    def cleanup(self):
        shutil.rmtree(self.scratch, ignore_errors=True)

    # ── миры ────────────────────────────────────────────────────────────────
    def world(self, name):
        if name in self.worlds:
            return self.worlds[name]
        w = World(self.scratch / name)
        info = {'root': w.root}
        if name == 'w1':
            w.seed([('001', ['ЗОНА architect: zones/w1/'], None),
                    ('002', ['ЗОНА architect: zones/w1/'], None),
                    ('003', ['ЗОНА architect: zones/w1/'], None)])
            w.c('architect', 'w-1', {'zones/w1/a.md': 'a\n'})
            w.c('Фон', 'fon', {'plans/fon.md': 'f\n'})
            w.c('architect', 'w-2', {'zones/w1/b.md': 'b\n'})
            info.update(base=w.sha('HEAD~3'), head=w.sha('HEAD'), n=3,
                        rc=0, fails=0, commits=9, checked=6)
        elif name == 'w2':
            w.seed([('001', ['ЗОНА architect: zones/w2/'], None),
                    ('002', ['ЗОНА architect: zones/w2/'], None),
                    ('003', ['ЗОНА architect: zones/w2/'], None)])
            w.c('architect', 'v-1', {'zones/w2/a.md': 'a\n'})
            bad_sha = None
            w.c('architect', 'v-2', {'plans/chuzhoe.md': 'x\n'})
            bad_sha = w.sha('HEAD')
            info.update(base=w.sha('HEAD~2'), head=bad_sha, n=2, rc=1, fails=3,
                        commits=6, checked=6,
                        fail_line=f'  FAIL коммит вне зоны: architect {bad_sha[:8]} plans/chuzhoe.md — '
                                  f'зона автора (объединение всех замороженных): zones/w2/ ',
                        cache_stays=True)
        elif name == 'w3':
            w.seed([('001', ['ЗОНА implementer: scripts/check_zones.sh'], None),
                    ('002', ['ЗОНА architect: zones/w3/'], None)])
            w.c('implementer', 'i-1', {'scripts/check_zones.sh': '# impl\n'})
            w.c('architect', 'a-1', {'scripts/check_zones.sh': '# arch poputka\n'})
            viol = w.sha('HEAD')
            w.c('architect', 'a-2', {'zones/w3/b.md': 'b\n'})
            info.update(base=w.sha('HEAD~3'), head=w.sha('HEAD'), n=3, rc=1, fails=1,
                        commits=6, checked=3,
                        fail_line=f'  FAIL коммит вне зоны: architect {viol[:8]} scripts/check_zones.sh — '
                                  f'зона автора (объединение всех замороженных): zones/w3/ ',
                        cache_stays=True)
        elif name in ('w4', 'w4b'):
            w.seed([('001', ['ЗОНА architect: zones/w4/'], None),
                    ('002', ['ЗОНА architect: zones/w4/'], None)])
            root = w.sha('HEAD')
            w.c('architect', 'w1', {'zones/w4/a.md': 'a\n'})
            w.branch('side1', 'HEAD')
            side_files = ({'zones/w4/s.md': 's\n'} if name == 'w4'
                          else {'plans/hack-side.md': 'h\n'})
            w.checkout('side1')
            w.c('architect', 'c-side', side_files)
            side_sha = w.sha('HEAD')
            w.checkout('main')
            w.merge('land: wip/001/architect', 'side1')
            m1 = w.sha('HEAD')
            w.branch('side2', 'HEAD')
            w.checkout('side2')
            w.c('architect', 'c-fon2', {'plans/hack.md': 'h2\n'})
            fon2_sha = w.sha('HEAD')
            w.checkout('main')
            w.merge('land: wip/999/chuzoj', 'side2')
            if name == 'w4':
                info.update(base=root, head=w.sha('HEAD'), n=5, rc=0, fails=0,
                            commits=3, checked=3)
            else:
                info.update(base=root, head=w.sha('HEAD'), n=5, rc=1, fails=1,
                            commits=3, checked=3,
                            fail_line=f'  FAIL коммит вне зоны: architect {side_sha[:8]} plans/hack-side.md — '
                                      f'зона автора (объединение всех замороженных): zones/w4/ ',
                            cache_stays=True)
        elif name == 'w5':
            w.seed([('001', ['ЗОНА architect: zones/w5/'], None),
                    ('002', ['ЗОНА architect: zones/w5/'], None)])

            info.update(base=w.sha('HEAD'), head=w.sha('HEAD'), n=0, rc=0, fails=0,
                        commits=0, checked=0, cache_stays=True)
        elif name == 'w6':
            w.seed([('001', ['ЗОНА architect: zones/w6/'], None),
                    ('002', ['ЗОНА architect: zones/w6/'], None)])
            w.c('architect', 'v-1', {'plans/x.md': 'x\n'})
            viol = w.sha('HEAD')
            info.update(base=w.sha('HEAD~1'), head=viol, n=1, rc=1, fails=2,
                        commits=2, checked=2,
                        fail_line=f'  FAIL коммит вне зоны: architect {viol[:8]} plans/x.md — '
                                  f'зона автора (объединение всех замороженных): zones/w6/ ',
                        cache_stays=True)
        elif name == 'w7':
            w.seed([('001', ['ЗОНА architect: zones/w7/'], None),
                    ('002', ['ЗОНА architect: zones/w7/'], None)])
            w.c('architect', 'w-1', {'zones/w7/a.md': 'a\n'})
            saved_sha = w.sha('HEAD')
            wfile(w.root, 'contracts/001-x.md',
                  contract_body('001', ['ЗОНА architect: zones/w7/'],
                                f'СПАСЕНО architect: {saved_sha} — испытание replay'))
            git(w.root, 'add', '-A')
            git(w.root, 'commit', '-q', '-m', 'контракт 001 v2 со СПАСЕНО')
            git(w.root, 'tag', '-a', 'frozen/contracts/001/2', '-m', 'контракт 001 v2 утверждён')
            w.c('architect', 'w-2', {'zones/w7/b.md': 'b\n'})
            info.update(base=w.sha('HEAD~3'), head=w.sha('HEAD'), n=3, rc=0, fails=0,
                        commits=6, checked=3,
                        ok_line=f'  ok   контракт 001: коммит {saved_sha[:8]} (architect) — СПАСЕНО, из суда зон выведен')
        elif name == 'w8':
            w.seed([('001', ['ЗОНА architect: zones/a/'], None),
                    ('002', ['ЗОНА architect: zones/b/'], None)])
            w.c('architect', 'p-1', {'zones/b/f.md': 'f\n'})
            w.c('architect', 'p-2', {'plans/c.md': 'c\n'})
            viol = w.sha('HEAD')
            info.update(base=w.sha('HEAD~2'), head=viol, n=2, rc=1, fails=2,
                        commits=4, checked=4,
                        fail_line=f'  FAIL коммит вне зоны: architect {viol[:8]} plans/c.md — '
                                  f'зона автора (объединение всех замороженных): zones/a/ zones/b/ ',
                        cache_stays=True)
        elif name == 'w9':
            w.seed([('001', ['ЗОНА architect: zones/w9/'], None),
                    ('002', ['ЗОНА architect: zones/w9/'], None)])
            w.c('Фон', 'f-1', {'plans/f1.md': '1\n'})
            w.c('Фон', 'f-2', {'plans/f2.md': '2\n'})
            info.update(base=w.sha('HEAD~2'), head=w.sha('HEAD'), n=2, rc=0, fails=0,
                        commits=4, checked=0)
        elif name == 'w10':
            w.seed([('001', ['ЗОНА architect: zones/w10/'], None),
                    ('002', ['ЗОНА architect: zones/w10/'], None)])
            w.c('architect', 'v-pre', {'plans/old.md': 'o\n'})
            pre = w.sha('HEAD')
            w.c('architect', 'w-1', {'zones/w10/a.md': 'a\n'})
            w.c('architect', 'w-2', {'plans/mid.md': 'm\n'})
            viol = w.sha('HEAD')
            w.c('architect', 'w-3', {'zones/w10/b.md': 'b\n'})
            info.update(base=pre, head=w.sha('HEAD'), n=3, rc=1, fails=2,
                        commits=6, checked=6, compare_full=False,
                        fail_line=f'  FAIL коммит вне зоны: architect {viol[:8]} plans/mid.md — '
                                  f'зона автора (объединение всех замороженных): zones/w10/ ',
                        cache_stays=True)
        elif name == 'w11':
            w.seed([('001', ['ЗОНА architect: zones/w11/'], None)])
            w.c('architect', 'd-1', {'contracts/005-draft.md': '# черновик 005\n'})
            w.tag_id('005', 'HEAD')
            w.c('architect', 'd-2', {'plans/after.md': 'a\n'})
            viol = w.sha('HEAD')
            info.update(base=w.sha('HEAD~2'), head=viol, n=2, rc=1, fails=1,
                        commits=2, checked=2,
                        fail_line=f'  FAIL коммит вне зоны: architect {viol[:8]} plans/after.md — '
                                  f'зона автора (объединение всех замороженных): zones/w11/ ',
                        cache_stays=True)
        elif name == 'w12':
            wfile(w.root, 'registry/contracts.tsv', '')
            w.seed([('001', ['ЗОНА orchestrator: registry/'], None)])
            base = w.sha('HEAD')
            w.tag_id('301', base)
            tag_sha = w.sha('refs/tags/id/CONTRACT/301')
            w.c('orchestrator', 'm-1', {'registry/contracts.tsv': f'301 → {tag_sha}\n'})
            wfile(w.root, 'registry/contracts.tsv', f'301 → {tag_sha}\n302 → {"d" * 40}\n')
            git(w.root, 'add', '-A')
            git(w.root, 'commit', '-q', '-m', 'm-2', author='orchestrator')
            viol = w.sha('HEAD')
            info.update(base=base, head=viol, n=2, rc=1, fails=1,
                        commits=2, checked=2,
                        fail_line=f'  FAIL коммит вне зоны: orchestrator {viol[:8]} registry/contracts.tsv — '
                                  f'дверь минта 031: тег id/CONTRACT/302 не жив локально',
                        cache_stays=True)
        elif name == 'w13':
            w.seed([('001', ['ЗОНА architect: zones/w13/'], None)])
            w.c('architect', 'w-1', {'verdicts/critic/x.md': 'v\n', 'plans/y.md': 'y\n'})
            viol = w.sha('HEAD')
            info.update(base=w.sha('HEAD~1'), head=viol, n=1, rc=1, fails=1,
                        commits=1, checked=1,
                        fail_line=f'  FAIL коммит вне зоны: architect {viol[:8]} plans/y.md — '
                                  f'зона автора (объединение всех замороженных): zones/w13/ ',
                        cache_stays=True)
        elif name == 'wk0':
            w.seed([('001', ['РАБОТА НЕ РАЗДАЁТСЯ: документирует норму'], None)])
            w.c('architect', 'k0-1', {'plans/k0.md': 'k\n'})
            info.update(base=w.sha('HEAD~1'), head=w.sha('HEAD'), n=1, rc=0, fails=0,
                        commits=0, checked=0, cache_stays=True, no_zones=True)
        elif name == 'w14':
            w.seed([('001', ['ЗОНА architect: zones/a/'], None)])
            w.c('architect', 'first', {'plans/first.md': '1\n'})
            first = w.sha('HEAD')
            w.c('architect', 'second', {'plans/second.md': '2\n'})
            second = w.sha('HEAD')
            info.update(base=w.sha('HEAD~2'), head=second, n=2, rc=1, fails=2,
                        commits=2, checked=2, cache_stays=True,
                        fail_lines=[
                            f'  FAIL коммит вне зоны: architect {sha[:8]} plans/{path}.md — '
                            'зона автора (объединение всех замороженных): zones/a/ '
                            for sha, path in ((first, 'first'), (second, 'second'))])
        elif name == 'w15':
            w.seed([('001', ['ЗОНА architect: zones/a/'], None)])
            w.c('architect', 'two-paths', {'plans/b.md': 'b\n', 'plans/a.md': 'a\n'})
            sha = w.sha('HEAD')
            info.update(base=w.sha('HEAD~1'), head=sha, n=1, rc=1, fails=2,
                        commits=1, checked=1, cache_stays=True,
                        fail_lines=[
                            f'  FAIL коммит вне зоны: architect {sha[:8]} plans/{path}.md — '
                            'зона автора (объединение всех замороженных): zones/a/ '
                            for path in ('a', 'b')])
        elif name.startswith('wdif'):
            k = 8 if name == 'wdif8' else 24
            w.seed([(f'{i:03d}', ['ЗОНА architect: zones/d/'], None) for i in range(1, k + 1)])
            w.c('architect', 'd-1', {'zones/d/a.md': 'a\n'})
            w.c('Фон', 'd-fon', {'plans/f.md': 'f\n'})
            w.c('architect', 'd-2', {'zones/d/b.md': 'b\n'})
            info.update(base=w.sha('HEAD~3'), head=w.sha('HEAD'), n=3, rc=0, fails=0,
                        commits=3 * k, checked=2 * k)
        elif name == 'wa2':
            uniq = 605
            w.seed([(f'{i:03d}', ['ЗОНА architect: zones/a2/'], None) for i in range(1, 21)])
            for j in range(22):
                files = {}
                for kk in range(100):
                    idx = (j * 29 + kk) % uniq
                    files[f'zones/a2/p{idx:03d}.md'] = f'{j}.{kk}\n'
                w.c('architect', f'a2-{j}', files)
            covered = len(list((w.root / 'zones/a2').iterdir()))
            if covered < uniq:
                raise Prerequisite(f'покрытие путей A2 {covered} < {uniq}')
            info.update(base=w.sha('HEAD~22'), head=w.sha('HEAD'), n=22, rc=0, fails=0,
                        commits=440, checked=440, paths=covered)
        else:
            raise Prerequisite(f'неизвестный мир {name}')
        self.worlds[name] = info
        return info

    # ── субъекты ────────────────────────────────────────────────────────────
    def make_scratch(self, name, subject=None):
        dst = self.scratch / name
        shutil.rmtree(dst, ignore_errors=True)
        shutil.copytree(self.repo / 'scripts', dst)
        if subject is not None:
            shutil.copy2(subject, dst / 'check_zones.sh')
        return dst

    # ── вызов двери ──────────────────────────────────────────────────────────
    def full_world(self, winfo):
        """Для e10 полный канон судит то же окно: frozen/1 перенесён на кеш-базу.

        Это отдельный поддержанный git-мир; субъект исходных refs не меняет.
        """
        if winfo.get('compare_full', True):
            return winfo
        dst = self.scratch / (winfo['root'].name + '_full')
        if not dst.exists():
            shutil.copytree(winfo['root'], dst)
            for nnn in ('001', '002'):
                tag = f'frozen/contracts/{nnn}/1'
                git(dst, 'tag', '-d', tag)
                git(dst, 'tag', '-a', tag, '-m', 'полный канон окна', winfo['base'])
        return dict(winfo, root=dst)

    def door(self, scripts, winfo, incr=True, strace=False, timeout=300):
        world = winfo['root']
        cache = self.scratch / f'cache.{world.name}.{scripts.name}.{"i" if incr else "f"}'
        argv = ['bash', str(scripts / 'check_zones.sh')]
        if incr:
            cache.write_text(winfo['base'] + '\n')
            argv += ['--incr', str(cache)]
        argv += [str(world)]
        trace = self.scratch / f'trace.{world.name}.{scripts.name}.{"i" if incr else "f"}'
        t0 = time.time()
        if strace:
            for old_trace in self.scratch.glob(trace.name + '.*'):
                old_trace.unlink()
            # -ff: каждый PID в своём файле, нет разорванных interleaved execve.
            # Запас длины для полного argv мира; обрезанный execve — rc 2, не ноль.
            proc = subprocess.Popen(['strace', '-ff', '-s', '131072', '-e', 'trace=execve',
                                     '-o', str(trace)] + argv, cwd=world, env=environment(),
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                    start_new_session=True)
            try:
                out, err = proc.communicate(timeout=timeout)
                rc = proc.returncode
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGKILL)
                proc.communicate()
                rc = 124
                out, err = b'', b''
        else:
            rc, out, err = command(argv, cwd=world, timeout=timeout)
        seconds = time.time() - t0
        counters = None
        if strace:
            traces = list(self.scratch.glob(trace.name + '.*'))
            if not traces:
                raise Prerequisite('strace не создал трассу execve')
            counters = window_counters(traces, winfo['base'])
        cache_after = cache.read_text().strip() if (incr and cache.exists()) else None
        return {'rc': rc, 'out': out, 'err': err, 'cache': cache_after,
                'counters': counters, 'seconds': seconds}

    @staticmethod
    def strip_marker(err_bytes):
        return b'\n'.join(l for l in err_bytes.split(b'\n')
                          if not l.startswith('incr: check_zones судит'.encode()))

    @staticmethod
    def marker_of(winfo):
        return (f'incr: check_zones судит {winfo["base"][:8]}..{winfo["head"][:8]} '
                f'({plural(winfo["n"])})')

    @staticmethod
    def summary_of(winfo):
        if winfo.get('no_zones'):
            return (f'\nзамороженных контрактов: {winfo["contracts"]} · '
                    'зон не объявлено — проверять нечего')
        return (f'\nзамороженных контрактов: {winfo["contracts"]} · объявленных авторов: '
                f'{winfo["authors"]} · коммитов в диапазонах: {winfo["commits"]} · '
                f'проверено по зонам: {winfo["checked"]}')

    @staticmethod
    def fails_in(err_bytes):
        return [l for l in err_bytes.decode(errors='replace').splitlines()
                if l.startswith('  FAIL ')]


# ── клетки ────────────────────────────────────────────────────────────────────
class Runner:
    def __init__(self, battery, subjects, tree_door):
        self.b = battery
        self.s = subjects          # {'subj': scripts_dir, 'base': scripts_dir|None}
        self.tree = tree_door      # полная производственная дверь дерева (full-прогон)
        self.results = []

    @staticmethod
    def counter_problems(run, expected):
        if run['counters'] is None:
            raise Prerequisite('трасса не снята (нет strace?)')
        return [f'{key}={run["counters"][key]} ≠ {want} (судов окна)'
                for key, want in zip(('rk_rev', 'rk_merges', 'ak', 'dt'), expected)
                if run['counters'][key] != want]

    def eq_cell(self, name, wname, counters=None):
        w = self.b.world(wname)
        w['contracts'] = {'w1': 3, 'w2': 3, 'w3': 2, 'w4': 2, 'w4b': 2, 'w5': 2, 'w6': 2,
                          'w7': 2, 'w8': 2, 'w9': 2, 'w10': 2, 'w11': 1, 'w12': 1,
                          'w13': 1, 'w14': 1, 'w15': 1, 'wk0': 1,
                          'wdif8': 8, 'wdif24': 24, 'wa2': 20}[wname]
        w['authors'] = 1
        marker = self.b.marker_of(w)
        want_summary = self.b.summary_of(w)
        # Все канонические байты и rc — в памяти ДО вызова субъекта.
        full = self.b.door(self.tree, self.b.full_world(w), incr=False)
        baserun = (self.b.door(self.s['base'], w, incr=True, strace=w.get('no_zones', False))
                   if self.s.get('base') is not None else None)
        subj = self.b.door(self.s['subj'], w, incr=True, strace=counters is not None)
        problems = []
        if subj['rc'] != w['rc']:
            problems.append(f'rc={subj["rc"]} ≠ {w["rc"]}')
        if subj['rc'] != full['rc']:
            problems.append('rc incr ≠ полному прогону производственной двери')
        if subj['out'] != full['out']:
            problems.append('stdout incr ≠ полному прогону производственной двери (байты)')
        if self.b.strip_marker(subj['err']) != full['err']:
            problems.append('stderr incr (без маркера) ≠ полному прогону производственной двери (байты)')
        err = subj['err'].decode(errors='replace')
        if marker not in err.splitlines():
            problems.append(f'нет маркера «{marker}»')
        if want_summary not in err:
            problems.append(f'нет сводки «{want_summary.strip()}»')
        fails = self.b.fails_in(subj['err'])
        if len(fails) != w['fails']:
            problems.append(f'FAIL-строк {len(fails)} ≠ {w["fails"]}')
        if 'fail_line' in w and fails and fails[0] != w['fail_line']:
            problems.append(f'диагноз «{fails[0][:100]}…» ≠ ожидаемому')
        if 'fail_lines' in w and fails != w['fail_lines']:
            problems.append('порядок полных FAIL-строк ≠ ожидаемому')
        if 'ok_line' in w:
            oks = [l for l in err.splitlines() if l.startswith('  ok   контракт')]
            if oks != [w['ok_line']]:
                problems.append(f'СПАСЕНО-строки {oks} ≠ ожидаемой одной')
        want_cache = w['base'] if w.get('cache_stays') else w['head']
        if subj['cache'] != want_cache:
            problems.append(f'кеш {subj["cache"]} ≠ {want_cache}')
        if baserun is not None:
            for channel in ('rc', 'out', 'err'):
                if baserun[channel] != subj[channel]:
                    problems.append(f'{channel} модели ≠ базовой двери (полные байты/rc)')
        if counters is not None:
            problems.extend(self.counter_problems(subj, counters))
            if baserun is not None and w.get('no_zones'):
                problems.extend('база: ' + p for p in self.counter_problems(baserun, counters))
        detail = f"rc={subj['rc']} FAIL={len(fails)} stdout={len(subj['out'])} stderr={len(subj['err'])}"
        if counters is not None:
            detail += f" судов={subj['counters']} сек={subj['seconds']:.1f}"
        self.results.append((name, not problems, '; '.join(problems) or detail, subj['seconds']))

    def counter_cell(self, name, wname, rk_rev, rk_merges, ak, dt):
        self.eq_cell(name, wname, counters=(rk_rev, rk_merges, ak, dt))

    def run_cell(self, name):
        if name in EQ_CELLS:
            self.eq_cell(name, EQ_CELLS[name])
        elif name == 'k0-bez-zon':
            self.eq_cell(name, 'wk0', counters=(0, 0, 0, 0))
        elif name in COUNTER_CELLS:
            self.counter_cell(name, *COUNTER_CELLS[name])
        else:
            raise Prerequisite(f'неизвестная клетка {name}')

    def git_form_cell(self, name, replacement):
        scr = self.b.make_scratch(name, MODEL)
        (scr / 'check_zones.sh').write_text(model_text(
            name, 'g() { git -C "$ROOT" "$@"; }', replacement))
        r = Runner(self.b, dict(self.s, subj=scr), self.tree)
        r.eq_cell(name, 'w1', counters=(1, 1, 1, 1))
        self.results.extend(r.results)


EQ_CELLS = {
    'e1-chistoe-okno': 'w1',
    'e2-chuzhaja-zona': 'w2',
    'e3-arhitektor-v-zone-implementer': 'w3',
    'e4-merge-okno-svoi-chuzhie': 'w4',
    'e5-pustoe-okno': 'w5',
    'e6-okno-odin-kommit': 'w6',
    'e7-spaseno-replay': 'w7',
    'e8-peresechenie-zon': 'w8',
    'e9-fon-okno': 'w9',
    'e10-seredina-i-do-bazy': 'w10',
    'e11-draft-priznanie': 'w11',
    'e12-mint-priznanie': 'w12',
    'e13-processnye-vne-suda': 'w13',
    'e14-porjadok-replay': 'w14',
    'e15-porjadok-putej': 'w15',
}
COUNTER_CELLS = {
    'c1-okno-odin-raz': ('w1', 1, 1, 1, 1),
    'c2-pustoe-okno-schet': ('w5', 1, 1, 0, 0),
    'c3-fon-okno-schet': ('w9', 1, 1, 1, 0),
    'c4-byudzhet-a2': ('wa2', 1, 1, 1, 1),
    'c5-nezavisimost-k8': ('wdif8', 1, 1, 1, 1),
    'c6-nezavisimost-k24': ('wdif24', 1, 1, 1, 1),
}
GIT_FORMS = {
    'h1-bin-git': 'g() { /bin/git -C "$ROOT" "$@"; }',
    'h2-command-git': 'g() { command git -C "$ROOT" "$@"; }',
    'h3-simlink-git': ('ln -sf /usr/bin/git "$SELF_DIR/alias207-link"\n'
                       'g() { "$SELF_DIR/alias207-link" -C "$ROOT" "$@"; }'),
    'h4-exec-a': 'g() { ( exec -a alias207 /usr/bin/git -C "$ROOT" "$@" ); }',
}


def cells(runner):
    for name in EQ_CELLS:
        runner.run_cell(name)
    runner.run_cell('k0-bez-zon')
    for name in COUNTER_CELLS:
        runner.run_cell(name)
    for name, replacement in GIT_FORMS.items():
        runner.git_form_cell(name, replacement)


def report(results, extra):
    green = sum(1 for _, ok, _, _ in results if ok)
    for name, ok, detail, _ in results:
        print(f'  {"ok  " if ok else "FAIL"} {name}: {detail}', file=sys.stderr)
    for line in extra:
        print(f'  набл {line}', file=sys.stderr)
    print(f'KLETKI={len(results)} ZELENYE={green} KRASNYE={len(results) - green}', file=sys.stderr)
    red = [name for name, ok, _, _ in results if not ok]
    if red:
        print('KRASNYE-KLETKI: ' + ', '.join(red), file=sys.stderr)
    return 0 if green == len(results) else 1


def load_stabs():
    rows = []
    for line in STABS_TSV.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        parts = line.split('\t')
        if len(parts) != 3:
            raise Prerequisite(f'stabs.tsv: строка без трёх полей: {line!r}')
        rows.append(tuple(parts))
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', nargs='?', default=None)
    ap.add_argument('--model', action='store_true')
    ap.add_argument('--stabs', action='store_true')
    ap.add_argument('--mutation', help='с --model: одно адресное предъявление, сырой rc клетки')
    ap.add_argument('--delta', choices=('k0', 'replay', 'stdout', 'git'), action='append',
                    help='с --stabs: адресная группа дельта-листа; можно повторить')
    args = ap.parse_args()

    repo = Path(args.repo).resolve() if args.repo else TREE
    if not (repo / 'scripts/check_zones.sh').exists():
        print('NOT_IMPLEMENTED: нет субъекта scripts/check_zones.sh', file=sys.stderr)
        return 2
    if not MODEL.exists():
        print('NOT_IMPLEMENTED: нет модели батареи', file=sys.stderr)
        return 2
    b = Battery(repo)
    try:
        if args.delta and not args.stabs:
            raise Prerequisite('--delta требует --stabs')
        if args.stabs:
            for tool in ('strace',):
                if shutil.which(tool) is None:
                    print(f'NOT_IMPLEMENTED: нет {tool} — счётчик судов окна нечем снимать',
                          file=sys.stderr)
                    return 2
            base_scr = b.make_scratch('scr_base')
            honest = b.make_scratch('scr_model', MODEL)
            tree = b.make_scratch('scr_tree')
            rows = load_stabs()
            if args.delta:
                prefixes = tuple('PATERN:' + group.upper() + '-' for group in args.delta)
                rows = [row for row in rows if row[0].startswith(prefixes)]
            if not rows:
                raise Prerequisite('пустая выборка адресных мутаций')
            mutacii = poimany = svjazi = 0
            results = []
            for name, subj_path, cell_name in rows:
                def run_cell(subject_dir):
                    r = Runner(b, {'subj': subject_dir, 'base': base_scr}, tree)
                    r.run_cell(cell_name)
                    return r.results[-1]
                ok_name, ok_honest, det_honest, _ = run_cell(honest)
                if not ok_honest:
                    print(f'ORACLE_TAMPERED: честная модель на клетке {cell_name} красна: {det_honest}',
                          file=sys.stderr)
                    return 2
                if name.startswith('PATERN:'):
                    anchor, replacement = PATERNS[name]
                    mut = b.make_scratch('scr_mut')
                    (mut / 'check_zones.sh').write_text(model_text(name, anchor, replacement))
                    subject_dir = mut
                else:
                    stab = HERE / 'stabs' / name
                    if not stab.exists():
                        print(f'NOT_IMPLEMENTED: стаб {name} не найден', file=sys.stderr)
                        return 2
                    subject_dir = b.make_scratch('scr_mut', stab)
                mutacii += 1
                svjazi += 1
                m_name, m_ok, m_det, _ = run_cell(subject_dir)
                if m_ok:
                    poimany_ = 0
                    print(f'  ZHIVOJ {name}: клетка {cell_name} зелёна на обманной реализации',
                          file=sys.stderr)
                else:
                    poimany_ = 1
                    poimany += 1
                    print(f'  pojman {name}: клетка {cell_name} красна: {m_det}', file=sys.stderr)
                results.append((f'{name}→{cell_name}', poimany_ == 1, m_det, 0.0))
            zhivyh = svjazi - poimany
            print(f'MUTACII={mutacii} SVJAZI={svjazi} POIMANY={poimany} ZHIVYH={zhivyh}',
                  file=sys.stderr)
            return 0 if zhivyh == 0 and poimany == svjazi else 1

        # --repo / --model
        for tool in ('strace',):
            if shutil.which(tool) is None:
                print(f'NOT_IMPLEMENTED: нет {tool} — счётчик судов окна нечем снимать',
                      file=sys.stderr)
                return 2
        tree = b.make_scratch('scr_tree')
        if args.model:
            subjects = {'subj': b.make_scratch('scr_model', MODEL), 'base': b.make_scratch('scr_base')}
        else:
            subjects = {'subj': tree, 'base': None}
        if args.mutation:
            bindings = {name: cell for name, _, cell in load_stabs()}
            if not args.model or args.mutation not in PATERNS or args.mutation not in bindings:
                raise Prerequisite('--mutation требует --model и имя адресной мутации')
            subject = b.make_scratch('scr_mut')
            (subject / 'check_zones.sh').write_text(model_text(
                args.mutation, *PATERNS[args.mutation]))
            subjects['subj'] = subject
            r = Runner(b, subjects, tree)
            r.run_cell(bindings[args.mutation])
        else:
            r = Runner(b, subjects, tree)
            cells(r)
        extra = []
        wa2 = b.worlds.get('wa2')
        if wa2:
            extra.append(f'окно A2: {wa2.get("paths")} путей, {wa2["n"]} коммитов')
        return report(r.results, extra)
    finally:
        b.cleanup()


PATERNS = {
    'PATERN:PROPUSK-SUDA-VTOROGO': (
        '  replay_prichina=207',
        '  replay_prichina=207; break'),
    'PATERN:PODMENA-VERDIKTA': (
        'if [ "$fails" -eq 0 ]; then',
        'if true; then'),
    'PATERN:OBREZKA-OKNA': (
        'g rev-list --no-merges --reverse "$range" > "$TMP/w_commits" 2>/dev/null',
        'g rev-list --no-merges --reverse "HEAD~1..HEAD" > "$TMP/w_commits" 2>/dev/null'),
    'PATERN:KESH-OKNA-IGNOR': (
        'g rev-list --no-merges --reverse "$range" > "$TMP/w_commits" 2>/dev/null',
        'g rev-list --no-merges --reverse "$INCR_BASE^..HEAD" > "$TMP/w_commits" 2>/dev/null'),
    'PATERN:SCHETCHIK-CHECKED': (
        '    checked=$((checked + 1))  # 207-replay',
        '    :  # 207-replay'),
    'PATERN:KESH-NE-PISHETSJA': (
        '  incr_finish 0',
        '  :  # 207-kesh-off'),
    'PATERN:PROPUSK-MERGE-ISKL': (
        '        "land: wip/"*) [ -s "$TMP/w_merges/$mc" ] && cat "$TMP/w_merges/$mc" >> "$TMP/exclude" ;;',
        '        "land: wip/"*) : ;;'),
    'PATERN:SPASENO-NE-CHITAETSJA': (
        '    if grep -qxF "$(printf \'%s\\t%s\\t%s\' "$an" "$c" "$nnn")" "$TMP/saved"; then',
        '    if false; then'),
    'PATERN:K0-SUDIT-OKNO': (
        'if [ ! -s "$TMP/zones_scoped" ]; then',
        'if [ ! -s "$TMP/zones_scoped" ]; then\n'
        '  g rev-list --no-merges --reverse "$INCR_BASE..HEAD" > /dev/null'),
    'PATERN:K0-NEMOJ-VYHOD': (
        '  printf \'\\nзамороженных контрактов: %d · зон не объявлено — проверять нечего\\n\' "$contracts" >&2',
        '  : # потеря вывода при K=0'),
    'PATERN:REPLAY-TAC': (
        '  cp "$TMP/w_commits" "$TMP/commits"',
        '  tac "$TMP/w_commits" > "$TMP/commits"'),
    'PATERN:REPLAY-PUTI-TAC': (
        '      done < "$TMP/w_dec/$c.bad"',
        '      done < <(tac -s \'\' "$TMP/w_dec/$c.bad")'),
    'PATERN:STDOUT-DUBL': (
        'printf \'\\nпроцессных вне суда:%s\\n\' "${process_list:+ $process_list}" >&2',
        'printf \'\\nпроцессных вне суда:%s\\n\' "${process_list:+ $process_list}" >&2\n'
        'printf \'\\nпроцессных вне суда:%s\\n\' "${process_list:+ $process_list}"'),
    'PATERN:STDOUT-SPASENO': (
        '      printf \'  ok   контракт %s: коммит %s (%s) — СПАСЕНО, из суда зон выведен\\n\' "$nnn" "${c:0:8}" "$an" >&2',
        '      printf \'  ok   контракт %s: коммит %s (%s) — СПАСЕНО, из суда зон выведен\\n\' "$nnn" "${c:0:8}" "$an" >&2\n'
        '      printf \'  ok   контракт %s: коммит %s (%s) — СПАСЕНО, из суда зон выведен\\n\' "$nnn" "${c:0:8}" "$an"'),
    'PATERN:GIT-INYM-PUTEM': (
        '    if ! g log --no-walk',
        '    /bin/git -C "$ROOT" log --no-walk --format=\'%H%x00%an%x00\' --stdin < "$TMP/w_commits" > /dev/null\n'
        '    if ! g log --no-walk'),
    'PATERN:GIT-EXEC-A-DUBL': (
        '    if ! g log --no-walk',
        '    ( exec -a alias207 /usr/bin/git -C "$ROOT" log --no-walk --format=\'%H%x00%an%x00\' --stdin < "$TMP/w_commits" > /dev/null )\n'
        '    if ! g log --no-walk'),
}


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Prerequisite as exc:
        print(f'NOT_IMPLEMENTED: {exc}', file=sys.stderr)
        sys.exit(2)
