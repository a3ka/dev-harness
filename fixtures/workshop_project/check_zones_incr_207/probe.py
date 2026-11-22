#!/usr/bin/env python3
"""207: check_zones --incr — суд окна один раз.

--repo [ROOT] — субъект scripts/check_zones.sh выбранного дерева (по умолчанию
дерево батареи): эквивалентность incr↔полный прогон на той же двери, счётчики
судов окна под strace (красное до реализации), нарушения зон по классам.
--model — добавляет модель (окно судится один раз): байт-в-байт равенство с
базовой дверью на каждом мире, счётчики == 1.
--stabs — адресные мутации модели и обманные стабы по stabs.tsv (Н-39):
честный контроль зелёный, мутация различима на связанной клетке; ZHIVYH == 0.
Оракул (ожидания, sha, маркеры, сводки) снимается в память ДО вызова субъекта;
субъект пишет только в одноразовых git-мирах и свой скратч.
"""
import argparse
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

FAIL_RE = re.compile(r'^  FAIL ', re.M)


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
            if trace.exists():
                trace.unlink()
            proc = subprocess.Popen(['strace', '-f', '-s', '400', '-e', 'trace=execve',
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
        if strace and trace.exists():
            lines = trace.read_text(errors='replace').splitlines()
            rng = f'"{winfo["base"]}..HEAD"'
            counters = {
                'rk_rev': sum(1 for l in lines
                              if '"rev-list", "--no-merges", "--reverse", ' + rng in l),
                'rk_merges': sum(1 for l in lines if '"rev-list", "--merges", ' + rng in l),
                'ak': sum(1 for l in lines
                          if '"log", "--no-walk"' in l and 'execve("/usr/bin/git"' in l),
                'dt': sum(1 for l in lines
                          if '"diff-tree"' in l and 'execve("/usr/bin/git"' in l),
            }
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

    def eq_cell(self, name, wname, seconds_observed=False):
        w = self.b.world(wname)
        w['contracts'] = {'w1': 3, 'w2': 3, 'w3': 2, 'w4': 2, 'w4b': 2, 'w5': 2, 'w6': 2,
                          'w7': 2, 'w8': 2, 'w9': 2, 'w10': 2, 'w11': 1, 'w12': 1,
                          'w13': 1, 'wdif8': 8, 'wdif24': 24, 'wa2': 20}[wname]
        w['authors'] = 1 if wname not in ('w3', 'w12') else 1
        subj = self.b.door(self.s['subj'], w, incr=True, strace=seconds_observed,
                           timeout=300 if wname == 'wa2' else 120)
        problems = []
        if subj['rc'] != w['rc']:
            problems.append(f'rc={subj["rc"]} ≠ {w["rc"]}')
        marker = self.b.marker_of(w)
        err = subj['err'].decode(errors='replace')
        if marker not in err.splitlines():
            problems.append(f'нет маркера «{marker}»')
        if w.get('compare_full', True):
            full = self.b.door(self.tree, w, incr=False)
            if self.b.strip_marker(subj['err']) != full['err']:
                problems.append('вывод incr (без маркера) ≠ полному прогону производственной двери')
        want_summary = self.b.summary_of(w)
        if want_summary not in err:
            problems.append(f'нет сводки «{want_summary.strip()}»')
        fails = self.b.fails_in(subj['err'])
        if len(fails) != w['fails']:
            problems.append(f'FAIL-строк {len(fails)} ≠ {w["fails"]}')
        if 'fail_line' in w and fails and fails[0] != w['fail_line']:
            problems.append(f'диагноз «{fails[0][:100]}…» ≠ ожидаемому')
        if 'ok_line' in w:
            oks = [l for l in err.splitlines() if l.startswith('  ok   контракт')]
            if oks != [w['ok_line']]:
                problems.append(f'СПАСЕНО-строки {oks} ≠ ожидаемой одной')
        if subj['cache'] is not None:
            if w.get('cache_stays'):
                if subj['cache'] != w['base']:
                    problems.append(f'кеш {subj["cache"][:8]} перезаписан при rc={subj["rc"]}')
            else:
                if subj['cache'] != w['head']:
                    problems.append(f'кеш {subj["cache"][:8] if subj["cache"] else "пусто"} ≠ HEAD {w["head"][:8]}')
        if self.s.get('base') is not None:
            baserun = self.b.door(self.s['base'], w, incr=True)
            if baserun['err'] != subj['err'] or baserun['rc'] != subj['rc']:
                problems.append('вывод модели ≠ выводу базовой двери (байты)')
        detail = f"rc={subj['rc']} FAIL={len(fails)}"
        if seconds_observed:
            detail += f" сек={subj['seconds']:.1f}"
        self.results.append((name, not problems, '; '.join(problems) or detail, subj['seconds']))

    def counter_cell(self, name, wname, rk_rev, rk_merges, ak, dt, budget=False):
        w = self.b.world(wname)
        w['contracts'] = {'w1': 3, 'w5': 2, 'w9': 2, 'wdif8': 8, 'wdif24': 24, 'wa2': 20}[wname]
        w['authors'] = 1
        subj = self.b.door(self.s['subj'], w, incr=True, strace=True,
                           timeout=300)
        problems = []
        if subj['counters'] is None:
            problems.append('трасса не снята (нет strace?)')
        else:
            c = subj['counters']
            for key, want in (('rk_rev', rk_rev), ('rk_merges', rk_merges), ('ak', ak), ('dt', dt)):
                if c[key] != want:
                    problems.append(f'{key}={c[key]} ≠ {want} (судов окна больше одного)')
        if budget:
            if subj['rc'] != w['rc']:
                problems.append(f"rc={subj['rc']} ≠ {w['rc']}")
            if subj['cache'] != w['head']:
                problems.append('кеш не перезаписан HEAD')
            if plural(w['n']) not in subj['err'].decode(errors='replace'):
                problems.append('нет маркера окна')
        detail = (f"судов={subj['counters']} сек={subj['seconds']:.1f}" if subj['counters']
                  else 'нет счётчиков')
        self.results.append((name, not problems, '; '.join(problems) or detail, subj['seconds']))


def cells(runner):
    runner.eq_cell('e1-chistoe-okno', 'w1')
    runner.eq_cell('e2-chuzhaja-zona', 'w2')
    runner.eq_cell('e3-arhitektor-v-zone-implementer', 'w3')
    runner.eq_cell('e4-merge-okno-svoi-chuzhie', 'w4')
    runner.eq_cell('e5-pustoe-okno', 'w5')
    runner.eq_cell('e6-okno-odin-kommit', 'w6')
    runner.eq_cell('e7-spaseno-replay', 'w7')
    runner.eq_cell('e8-peresechenie-zon', 'w8')
    runner.eq_cell('e9-fon-okno', 'w9')
    runner.eq_cell('e10-seredina-i-do-bazy', 'w10')
    runner.eq_cell('e11-draft-priznanie', 'w11')
    runner.eq_cell('e12-mint-priznanie', 'w12')
    runner.eq_cell('e13-processnye-vne-suda', 'w13')
    runner.counter_cell('c1-okno-odin-raz', 'w1', 1, 1, 1, 1)
    runner.counter_cell('c2-pustoe-okno-schet', 'w5', 1, 1, 0, 0)
    runner.counter_cell('c3-fon-okno-schet', 'w9', 1, 1, 1, 0)
    runner.counter_cell('c4-byudzhet-a2', 'wa2', 1, 1, 1, 1, budget=True)
    runner.counter_cell('c5-nezavisimost-k8', 'wdif8', 1, 1, 1, 1)
    runner.counter_cell('c6-nezavisimost-k24', 'wdif24', 1, 1, 1, 1)


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
            mutacii = poimany = svjazi = 0
            results = []
            for name, subj_path, cell_name in rows:
                cell_fn = {'e1-chistoe-okno': ('w1',), 'e2-chuzhaja-zona': ('w2',),
                           'e4-merge-okno-svoi-chuzhie': ('w4',),
                           'e7-spaseno-replay': ('w7',),
                           'e10-seredina-i-do-bazy': ('w10',)}[cell_name]
                def run_cell(subject_dir):
                    r = Runner(b, {'subj': subject_dir, 'base': base_scr}, tree)
                    r.eq_cell(cell_name, cell_fn[0])
                    return r.results[-1]
                ok_name, ok_honest, det_honest, _ = run_cell(honest)
                if not ok_honest:
                    print(f'ORACLE_TAMPERED: честная модель на клетке {cell_name} красна: {det_honest}',
                          file=sys.stderr)
                    return 2
                if name.startswith('PATERN:'):
                    anchor, replacement = PATERNS[name]
                    text = MODEL.read_text()
                    if text.count(anchor) != 1:
                        print(f'ORACLE_TAMPERED: якорь {name} встречается {text.count(anchor)} раз',
                              file=sys.stderr)
                        return 2
                    mut = b.make_scratch('scr_mut')
                    (mut / 'check_zones.sh').write_text(text.replace(anchor, replacement))
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
}


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Prerequisite as exc:
        print(f'NOT_IMPLEMENTED: {exc}', file=sys.stderr)
        sys.exit(2)
