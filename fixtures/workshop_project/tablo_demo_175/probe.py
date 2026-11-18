#!/usr/bin/env python3
"""175: run the actual board CLI program against in-memory GitHub/Git responses.

v1 worlds judge the demo-PR filter; v2 worlds add the mob stream led by the
separate Complior-mob project session (live journal in the project session
home). The world model covers BOTH journal placements (direct *.jsonl in the
session dir and nested */*.jsonl one level below), the INCLUSIVE mtime-window
boundary (exactly N minutes is fresh, N minutes 1 second is stale) and
form-agnostic filesystem queries: any equivalent standard lookup of the
session journals (glob of the full path, find, a directory walk) resolves the
same virtual world, so honest subjects are judged by behaviour, not syntax.
The clock is frozen: the world generator and the subject see one instant, so
the boundary comparison is deterministic.

v3 worlds split the session-home roots exactly as the real consumer does
(Б-1 Rev175): the board runs under omp where HOME is the zone directory
while the mob journals live in the passwd home. Every split world pins BOTH
roots itself — the HOME environment and a shimmed pwd.getpwuid, both in
checker memory — so home_only and passwd_only subjects go red whatever HOME
the battery run itself sits under; a duplicate HOME == passwd home must not
change the output. v3 also pins the minute arithmetic of the fact line:
partial minutes floor (N min 59 s reads as N) and the NEWEST of several
journals is named (С-2 Rev175b).

Modes: bare / --repo R judge a real
tree; --model the honest controls of every search form (must be green);
--stabs runs every deceptive stub against its own bound input (Н-39: a stub
is declared as a code mutation in the mutants list below, never in contract
prose). The oracle is retained in checker memory before invoking the subject
(rule 8), never derived from the candidate's output or files.
"""
import argparse
import contextlib
import datetime as dt
import fnmatch
import io
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

from model import (MOB_MINS_EXPR, MOB_VEDET_LINE, MOB_VEDET_LINES, honest,
                   honest_v2, honest_v2_find, honest_v2_fullpath, honest_v2_walk,
                   replace_once)

BOARD = 'ops/server/user/orch-tablo'
ROOT = Path(__file__).resolve().parents[3]
WINDOW_ARG = 20  # минут-окна, передаваемое субъекту во всех мирах

# Часы заморожены: генератор мира и субъект видят один момент, граница окна
# (ровно N минут) сравнивается детерминированно, без расхождения часов.
FROZEN_NOW = dt.datetime(2026, 11, 17, 12, 0, 0, tzinfo=dt.timezone.utc)


class _FrozenDateTime(dt.datetime):
    @classmethod
    def now(cls, tz=None):
        return FROZEN_NOW if tz is None else FROZEN_NOW.astimezone(tz)


# Канонические корни виртуального мира: любой равноправный способ обращения
# (путь с ~, полный абсолютный путь, составной синтетический путь) даёт один
# ответ — различается поведение субъекта на входах, не синтаксис запроса.
MOB_HOME = ('~/.local/state/dev-harness-projects/complior-mob/home/.omp'
            '/profiles/dev/agent/sessions/--home-harness-projects-Complior-mob--')
BACK_HOME = ('~/.local/state/dev-harness-projects/complior-back/home/.omp'
             '/profiles/dev/agent/sessions/--home-harness-projects-Complior-back--')
ROOTS = {os.path.expanduser(MOB_HOME): 'synthetic-mob-session',
         os.path.expanduser(BACK_HOME): 'synthetic-back-session'}
STATION_SUFFIX = '--home-harness-dev-harness--'
MOB_TAIL = MOB_HOME[1:]  # хвост дома сессии после '~' — общий всем корням дома

# v3 (Б-1 Rev175): расщеплённые корни дома сессии. Потребитель табло
# (оркестратор, wait-guard 128) зовёт его под omp, где HOME — каталог зоны без
# журналов mob, а журналы лежат в доме из passwd. Мир задаёт корни сам:
# home_root — HOME среды субъекта (шим os.environ), pw_root — pw_dir (шим
# pwd.getpwuid в памяти проверяющего), mob_gde — под каким корнем лежит каталог
# сессии ('home' | 'passwd' | 'oba'). Совпавшие корни (dublikat) — один каталог.
ZONE_ROOT = '/synthetic-omp-zone'      # HOME мира: зона omp, своих журналов mob нет
PASSWD_ROOT = '/synthetic-passwd-dom'  # дом из passwd мира
DUP_ROOT = '/synthetic-dom-dublikat'   # HOME мира равен дому из passwd


def canon(path, roots=ROOTS):
    """Map an equivalent query spelling onto the canonical synthetic name."""
    p = os.path.expanduser(path)
    for real, synthetic in roots.items():
        if p == real or p.startswith(real + '/'):
            return synthetic + p[len(real):]
    return p


def split_roots(world):
    """Корни расщеплённого мира: путь корня → синтетическое имя каталога
    сессии. Совпавшие корни дают один ключ — один и тот же каталог (dublikat)."""
    roots = {}
    if world.get('home_root') is not None:
        roots[world['home_root']] = 'synthetic-session-home'
    if world.get('pw_root') is not None:
        roots[world['pw_root']] = 'synthetic-session-passwd'
    return roots


def world_roots(world):
    """Корни канона мира: прежние (по ambient HOME) или расщеплённые (v3)."""
    if 'home_root' in world or 'pw_root' in world:
        return {root + MOB_TAIL: name for root, name in split_roots(world).items()}
    return ROOTS


def path_match(path, pattern):
    """Pathname-aware match like glob.glob: '*' does not cross '/'."""
    pseg, fseg = path.split('/'), pattern.split('/')
    if len(pseg) != len(fseg):
        return False
    return all(fnmatch.fnmatchcase(ps, fs) for ps, fs in zip(pseg, fseg))


def vdirs(files):
    out = set()
    for f in files:
        parts = f.split('/')
        for i in range(1, len(parts)):
            out.add('/'.join(parts[:i]))
    return out


# Each PR input is conformant to gh pr list --json's real public response.
CASES = {
    'demo_branch': [('a3ka/Complior-mob', 901, 'demo/investor-d24', 'Temporary presentation', 'SUCCESS', False)],
    'demo_title': [('a3ka/Complior-mob', 902, 'wip/902/implementer', 'DEMO ONLY: presentation', 'SUCCESS', False)],
    'do_not_merge': [('a3ka/Complior-mob', 903, 'wip/903/implementer', 'Показ инвестору — НЕ МЕРЖИТЬ', 'SUCCESS', False)],
    'real_green': [('a3ka/Complior-mob', 904, 'wip/904/implementer', 'Screen work ready', 'SUCCESS', True)],
    'real_red': [('a3ka/Complior-mob', 905, 'wip/905/implementer', 'Screen work blocked', 'FAILURE', True)],
    'not_demo_word': [('a3ka/Complior-mob', 906, 'wip/906/implementer', 'DEMOGRAPHIC metrics', 'SUCCESS', True)],
    'harness_demo': [('a3ka/dev-harness', 907, 'demo/station-talk', 'Presentation', 'SUCCESS', False)],
    'harness_real': [('a3ka/dev-harness', 908, 'owner/train-main', 'Real station task', 'SUCCESS', True)],
    'upper_branch': [('a3ka/Complior-mob', 909, 'DeMo/investor', 'Presentation', 'SUCCESS', False)],
    'lower_title': [('a3ka/Complior-mob', 910, 'wip/910/implementer', 'demo presentation', 'SUCCESS', False)],
    'harness_title': [('a3ka/dev-harness', 911, 'owner/title-only', 'DEMO presentation', 'SUCCESS', False)],
    'harness_marker': [('a3ka/dev-harness', 912, 'owner/marker-only', 'Не Мержить этот PR', 'SUCCESS', False)],
    'harness_red': [('a3ka/dev-harness', 913, 'owner/red-build', 'Real red build', 'FAILURE', True)],
    'combined_demo': [('a3ka/Complior-mob', 914, 'demo/combined', 'DEMO — НЕ МЕРЖИТЬ', 'FAILURE', False)],
    'multirow': [
        ('a3ka/dev-harness', 915, 'demo/pr-before-real', 'DEMO — НЕ МЕРЖИТЬ', 'FAILURE', False),
        ('a3ka/dev-harness', 916, 'owner/next-pr', 'Real green build', 'SUCCESS', True),
        ('a3ka/Complior-mob', 917, 'demo/preview', 'Presentation', 'FAILURE', False),
        ('a3ka/Complior-mob', 918, 'wip/918/implementer', 'Real red build', 'FAILURE', True),
    ],
}

PR_GREEN = ('a3ka/Complior-mob', 930, 'wip/930/implementer', 'Screen work ready', 'SUCCESS', True)
PR_RED = ('a3ka/Complior-mob', 931, 'wip/931/implementer', 'Screen work blocked', 'FAILURE', True)
# v2: состояние мира сессии проекта моба. mob_dir — каталог сессии есть;
# mob_files — в нём есть jsonl; mob_age_s — возраст самого свежего jsonl (с);
# mob_layout — где лежит журнал: 'oba' (по умолчанию — прямой и вложенный),
# 'prjamoj' — только *.jsonl в самом каталоге, 'vlozhennyj' — только */*.jsonl
# на уровень ниже; pstate — есть каталог состояния проекта без сессии;
# back_age_s — возраст журнала ЧУЖОЙ сессии проекта (Complior-back).
NO_SESSION = dict(mob_dir=False, mob_files=False, mob_age_s=None)
NEW_WORLDS = {
    'mob_session_zel_pr': dict(prs=[PR_GREEN], mob_dir=True, mob_files=True, mob_age_s=300),
    'mob_session_krasny_pr': dict(prs=[PR_RED], mob_dir=True, mob_files=True, mob_age_s=300),
    'mob_bez_sessii': dict(prs=[PR_GREEN], **NO_SESSION),
    'mob_pustoj_zhurnal': dict(prs=[PR_GREEN], mob_dir=True, mob_files=False, mob_age_s=None),
    'mob_stary_zhurnal': dict(prs=[PR_GREEN], mob_dir=True, mob_files=True, mob_age_s=2700),
    'mob_tolko_prjamoj_zhurnal': dict(prs=[PR_GREEN], mob_dir=True, mob_files=True, mob_age_s=300, mob_layout='prjamoj'),
    'mob_tolko_vlozhennyj_zhurnal': dict(prs=[PR_GREEN], mob_dir=True, mob_files=True, mob_age_s=300, mob_layout='vlozhennyj'),
    'mob_granica_okna': dict(prs=[PR_GREEN], mob_dir=True, mob_files=True, mob_age_s=WINDOW_ARG * 60),
    'mob_za_granicej_okna': dict(prs=[PR_GREEN], mob_dir=True, mob_files=True, mob_age_s=WINDOW_ARG * 60 + 1),
    'otlozhennaja_sessija': dict(prs=[PR_GREEN], pstate=True, **NO_SESSION),
    'chuzhaja_sessija': dict(prs=[PR_GREEN], back_age_s=180, **NO_SESSION),
}
# v3 (Б-1 Rev175): журналы сессии ищутся по ОБЪЕДИНЕНИЮ корней дома — $HOME
# запускающего и дом из passwd; клетка задаёт корни сама и кладёт журнал в
# один из них, поэтому субъекты «только $HOME» и «только passwd» красны при
# любом ambient HOME прогона. v3 (С-2 Rev175b): mob_age_starshij_s — возраст
# старшего журнала того же каталога (назвать самый свежий, не самый старый);
# хвост :59 — минута возраста округляется вниз, не потолком.
NEW_WORLDS_V3 = {
    'dom_zhurnal_v_passwd': dict(prs=[PR_GREEN], home_root=ZONE_ROOT,
                                 pw_root=PASSWD_ROOT, mob_gde='passwd',
                                 mob_dir=True, mob_files=True, mob_age_s=300),
    'dom_zhurnal_v_home': dict(prs=[PR_GREEN], home_root=ZONE_ROOT,
                               pw_root=PASSWD_ROOT, mob_gde='home',
                               mob_dir=True, mob_files=True, mob_age_s=300),
    'dom_zhurnal_nigde': dict(prs=[PR_GREEN], home_root=ZONE_ROOT,
                              pw_root=PASSWD_ROOT, mob_gde='oba',
                              mob_dir=True, mob_files=False, mob_age_s=None),
    'dom_dublikat_kornej': dict(prs=[PR_GREEN], home_root=DUP_ROOT,
                                pw_root=DUP_ROOT, mob_gde='oba',
                                mob_dir=True, mob_files=True, mob_age_s=300),
    'mob_granica_minuty': dict(prs=[PR_GREEN], mob_dir=True, mob_files=True,
                               mob_age_s=5 * 60 + 59),
    'mob_svezhij_i_starshij': dict(prs=[PR_GREEN], mob_dir=True, mob_files=True,
                                   mob_age_s=180, mob_age_starshij_s=600),
}
WORLDS = {name: dict(prs=rows, **NO_SESSION) for name, rows in CASES.items()}
WORLDS.update(NEW_WORLDS)
WORLDS.update(NEW_WORLDS_V3)

# Честные контроли разных равноправных форм поиска журналов (блок 3): каждая
# форма обязана быть зелёной на всех мирах — батарея судит поведение, не синтаксис.
CONTROLS = [
    ('ctl-glob', honest_v2),
    ('ctl-fullpath', honest_v2_fullpath),
    ('ctl-find', honest_v2_find),
    ('ctl-walk', honest_v2_walk),
]

POTOK_HARNESS = re.compile(
    r'^  СТОИТ ПОТОК харнесс: ни один предмет не в работе — (?:больше )?\d+ мин; '
    r'возьми следующую задачу потока$')
POTOK_MOB = re.compile(
    r'^  СТОИТ ПОТОК mob: ни один предмет не в работе — (?:больше )?\d+ мин; '
    r'возьми следующую задачу потока$')
BACK_LINE = '  бэкенд: ведёт сессия проекта Complior-back — станция его предметы НЕ исполняет'


def vedet_line(minutes):
    return (f'  mob: ведёт сессия проекта Complior-mob '
            f'(журнал {minutes} мин назад) — станция поток не требует')


def vfiles(world):
    """Virtual journals of the session homes: canonical path -> age (seconds)."""
    files = {}
    if 'home_root' in world or 'pw_root' in world:
        # v3 (Б-1): каталог сессии лежит под корнями мира — под HOME-корнем,
        # под корнем passwd или под обоими; журнал виден под тем корнем, где
        # лежит; совпавшие корни — один каталог, журнал не дублируется.
        gde = world.get('mob_gde', 'oba')
        names = split_roots(world)
        for side, root in (('home', world.get('home_root')),
                           ('passwd', world.get('pw_root'))):
            if root is None or (gde != 'oba' and gde != side):
                continue
            if world['mob_files']:
                files[names[root] + '/zhurnal.jsonl'] = world['mob_age_s']
        return files
    if world['mob_dir'] and world['mob_files'] and world['mob_age_s'] is not None:
        layout = world.get('mob_layout', 'oba')
        if layout in ('prjamoj', 'oba'):
            files['synthetic-mob-session/zhurnal.jsonl'] = world['mob_age_s']
        if layout in ('vlozhennyj', 'oba'):
            starshij = world.get('mob_age_starshij_s')
            files['synthetic-mob-session/sub/zhurnal.jsonl'] = (
                world['mob_age_s'] if starshij is None else starshij)
    if world.get('back_age_s') is not None:
        files['synthetic-back-session/zhurnal.jsonl'] = world['back_age_s']
    return files


def run_case(source, name, tag=''):
    world = WORLDS[name]
    entries = world['prs']
    now0 = FROZEN_NOW
    timestamp = (now0 - dt.timedelta(minutes=2)).isoformat()
    rows = {
        repo: [{'number': number, 'headRefName': branch, 'title': title,
                'updatedAt': timestamp, 'statusCheckRollup': [{'conclusion': status}]}
               for target, number, branch, title, status, _visible in entries if target == repo]
        for repo in ('a3ka/dev-harness', 'a3ka/Complior-mob')
    }
    calls = []
    files = vfiles(world)
    roots = world_roots(world)

    def fake_run(argv, **kwargs):
        calls.append(tuple(argv))
        if tuple(argv[:3]) == ('gh', 'pr', 'list'):
            target = argv[argv.index('-R') + 1]
            fields = argv[argv.index('--json') + 1].split(',')
            output = json.dumps([{k: v for k, v in row.items() if k in fields} for row in rows.get(target, [])])
        elif argv[0] == 'git':
            output = ''
        elif argv[0] == 'find':
            output = fake_find(argv)
        else:
            raise AssertionError(f'unexpected dependency: {argv!r}')
        return subprocess.CompletedProcess(argv, 0, stdout=output, stderr='')

    def fake_glob(pattern):
        p = canon(pattern, roots)
        if p.endswith(STATION_SUFFIX):
            return ['synthetic-root']
        if p == 'synthetic-mob-session':
            return ['synthetic-mob-session'] if world['mob_dir'] else []
        if p == 'synthetic-back-session':
            return ['synthetic-back-session'] if world.get('back_age_s') is not None else []
        if p in ('synthetic-session-home', 'synthetic-session-passwd'):
            # v3: каталог сессии есть ровно под теми корнями мира, где он лежит.
            gde = world.get('mob_gde', 'oba')
            side = 'home' if p == 'synthetic-session-home' else 'passwd'
            return [p] if world['mob_dir'] and gde in (side, 'oba') else []
        if 'dev-harness-projects/*/home' in p:  # мутант «любая проектная сессия»
            dirs = []
            if world['mob_dir']:
                dirs.append('synthetic-mob-session')
            if world.get('back_age_s') is not None:
                dirs.append('synthetic-back-session')
            return dirs
        if p.endswith('dev-harness-projects/complior-mob*'):  # мутант «состояние вместо журнала»
            return ['synthetic-pstate'] if world.get('pstate') else []
        return sorted(f for f in files if path_match(f, p))

    def fake_getmtime(path):
        p = canon(path, roots)
        if p in files:
            return FROZEN_NOW.timestamp() - files[p]
        raise AssertionError(f'unexpected getmtime: {path!r}')

    def fake_find(argv):
        root = canon(argv[1], roots)
        rest = argv[2:]
        name, maxdepth = None, None
        i = 0
        while i < len(rest):
            if rest[i] == '-name' and i + 1 < len(rest):
                name = rest[i + 1]
                i += 2
            elif rest[i] == '-maxdepth' and i + 1 < len(rest):
                maxdepth = int(rest[i + 1])
                i += 2
            else:
                i += 1
        entries_ = sorted(files) + sorted(vdirs(files))
        out = []
        for e in entries_:
            if not e.startswith(root + '/'):
                continue
            rel = e[len(root) + 1:]
            if maxdepth is not None and rel.count('/') + 1 > maxdepth:
                continue
            if name is not None and not fnmatch.fnmatchcase(e.rsplit('/', 1)[-1], name):
                continue
            out.append(e)
        return '\n'.join(out)

    def fake_walk(top, *args, **kwargs):
        top = canon(top, roots)
        all_entries = sorted(files) + sorted(vdirs(files))
        if not any(e == top or e.startswith(top + '/') for e in all_entries):
            return iter(())
        results = []
        level = [top]
        while level:
            nxt = []
            for d in level:
                subdirs, subfiles = [], []
                for e in all_entries:
                    if not e.startswith(d + '/'):
                        continue
                    rel = e[len(d) + 1:]
                    head = rel.split('/')[0]
                    if '/' in rel:
                        if head not in subdirs:
                            subdirs.append(head)
                    elif head not in subfiles:
                        subfiles.append(head)
                results.append((d, sorted(subdirs), sorted(subfiles)))
                nxt.extend(d + '/' + s for s in subdirs)
            level = nxt
        return iter(results)

    stdout = io.StringIO()
    stderr = io.StringIO()
    code = 0
    patches = [
        patch('datetime.datetime', _FrozenDateTime),
        patch('glob.glob', side_effect=fake_glob),
        patch('os.path.getmtime', side_effect=fake_getmtime),
        patch('os.walk', side_effect=fake_walk),
        patch('subprocess.run', side_effect=fake_run),
        patch.object(sys, 'argv', [BOARD, str(WINDOW_ARG)]),
    ]
    if 'home_root' in world or 'pw_root' in world:
        # v3 (Б-1): корни дома задаёт МИР, а не окружение прогона — HOME среды
        # и pw_dir подменяются шимами в памяти проверяющего на время субъекта.
        patches.append(patch.dict(os.environ, {'HOME': world['home_root']}))
        patches.append(patch('pwd.getpwuid', lambda uid: SimpleNamespace(
            pw_dir=world.get('pw_root', world['home_root']))))
    try:
        with contextlib.ExitStack() as stack:
            for p in patches:
                stack.enter_context(p)
            with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
                exec(compile(source, BOARD, 'exec'), {'__name__': '__main__', '__file__': str(ROOT / BOARD)})
    except SystemExit as exc:
        code = exc.code if isinstance(exc.code, int) else 1
    except Exception as exc:
        code = 2
        stderr.write(f'{type(exc).__name__}: {exc}')
    # Expected PR rows, stream lines and totals are derived from the in-memory
    # world, never from the candidate's output or a file the candidate can edit.
    lines = stdout.getvalue().splitlines()
    pr_lines = [line for line in lines if re.match(r'^  СТОИТ \d+ мин PR ', line)]
    expected = [(repo.split('/')[1], number, branch, status, visible)
                for repo, number, branch, _title, status, visible in entries]
    observations = []
    for repo, number, branch, status, visible in expected:
        matching = [line for line in pr_lines if re.fullmatch(
            rf'  СТОИТ \d+ мин PR {re.escape(repo)}#{number} \({re.escape(branch)}\): '
            rf'CI {"красный" if status == "FAILURE" else "зелёный"}, по нему никто не работает', line)]
        observations.append(len(matching) == (1 if visible else 0))
    count = sum(visible for _repo, _number, _branch, _status, visible in expected)
    age = world['mob_age_s']
    leads = bool(world['mob_files']) and age is not None and age <= WINDOW_ARG * 60
    potok_mob = [line for line in lines if POTOK_MOB.match(line)]
    mob_facts = [line for line in lines if line.startswith('  mob: ведёт сессия')]
    if leads:
        stream_ok = (len(potok_mob) == 0 and mob_facts == [vedet_line(int(age // 60))])
        total = 1 + count
    else:
        stream_ok = (len(potok_mob) == 1 and not mob_facts)
        total = 2 + count
    stream_ok = stream_ok and len([l for l in lines if POTOK_HARNESS.match(l)]) == 1 and BACK_LINE in lines
    summary = f'итог: стоит без хода — {total}'
    summary += '  → сделай следующий шаг по каждой строке СТОИТ до wait'
    query = [call for call in calls if call[:3] == ('gh', 'pr', 'list')]
    valid = (code == 0 and not stderr.getvalue() and len(query) == 2
             and lines[-1:] == [summary] and len(pr_lines) == count
             and 'НЕ МЕРЖИТЬ' not in stdout.getvalue())
    ok = valid and all(observations) and stream_ok
    detail = ('' if ok else f' pr={len(pr_lines)}/{count} mob_facts={len(mob_facts)}'
              f' potok_mob={len(potok_mob)} err={stderr.getvalue()[:120]!r}')
    status = 'ok' if ok else 'KRASNO' + (detail or ' rasxozhdenie')
    print(f'175 {tag}{name} {status} rc={code}')
    return ok


def v2_stabs(source):
    """Deceptive v2/v3 stubs: code mutations of the honest model, each bound to
    the world where its defect is observable (Н-39)."""
    glob_sum = "glob.glob(b + '/*.jsonl') + glob.glob(b + '/*/*.jsonl')"
    union_roots = "(os.path.expanduser('~'), pwd.getpwuid(os.getuid()).pw_dir)"
    return [
        ('priznak_ignoriruetsja', replace_once(source, MOB_VEDET_LINE, 'mob_vedet = False'),
         'mob_session_zel_pr'),
        ('vechno_zhivoj', replace_once(source, MOB_VEDET_LINE, 'mob_vedet = bool(mob_last)'),
         'mob_stary_zhurnal'),
        ('pustoj_zhivoj', replace_once(source, MOB_VEDET_LINE, 'mob_vedet = bool(mob_ses)'),
         'mob_pustoj_zhurnal'),
        ('sostojanie_vmesto_zhurnala', replace_once(source, MOB_VEDET_LINES,
         "mob_last = [1]\n"
         "mob_vedet = bool(glob.glob(os.path.expanduser('~/.local/state/dev-harness-projects/complior-mob*')))\n"),
         'otlozhennaja_sessija'),
        ('ljuboj_proekt', replace_once(source,
         "h + '/.local/state/dev-harness-projects/complior-mob'\n"
         "                                     '/home/.omp/profiles/dev/agent/sessions'\n"
         "                                     '/--home-harness-projects-Complior-mob--')",
         "h + '/.local/state/dev-harness-projects/*'\n"
         "                                     '/home/.omp/profiles/dev/agent/sessions/*')"),
         'chuzhaja_sessija'),
        ('schetyaet_v_stoit', replace_once(source, "    elif s == 'mob' and mob_vedet:",
         "    elif s == 'mob' and mob_vedet:\n        stoit += 1"),
         'mob_session_zel_pr'),
        ('slepoj_harness', replace_once(source, "for s in ('харнесс', 'mob'):",
         "for s in ('mob',):"),
         'mob_bez_sessii'),
        ('terjaet_pr', replace_once(source, 'for repo, num, br, state, upd in prs:',
         "for repo, num, br, state, upd in [p for p in prs if not (mob_vedet and p[0] == 'Complior-mob')]:"),
         'mob_session_krasny_pr'),
        ('vret_o_svezhosti', replace_once(source, MOB_MINS_EXPR, '0'),
         'mob_session_zel_pr'),
        ('tolko_prjamoj_glob', replace_once(source, glob_sum, "glob.glob(b + '/*.jsonl')"),
         'mob_tolko_vlozhennyj_zhurnal'),
        ('tolko_vlozhennyj_glob', replace_once(source, glob_sum, "glob.glob(b + '/*/*.jsonl')"),
         'mob_tolko_prjamoj_zhurnal'),
        ('strogaja_granica', replace_once(source, MOB_VEDET_LINE,
         MOB_VEDET_LINE.replace(' >= ', ' > ')),
         'mob_granica_okna'),
        ('okno_shire', replace_once(source, MOB_VEDET_LINE,
         MOB_VEDET_LINE.replace('WINDOW * 60', '(WINDOW * 60 + 90)')),
         'mob_za_granicej_okna'),
        # v3 (Б-1 Rev175): выжившие корни дома — дефект ровно того класса, что
        # был зелёным в старой батарее; каждая форма красна на СВОЁМ мире, где
        # журнал лежит в другом корне.
        ('tolko_home_koren', replace_once(source, union_roots,
         "(os.path.expanduser('~'),)"),
         'dom_zhurnal_v_passwd'),
        ('tolko_passwd_koren', replace_once(source, union_roots,
         "(pwd.getpwuid(os.getuid()).pw_dir,)"),
         'dom_zhurnal_v_home'),
        # v3 (С-2 Rev175b): возраст — полные минуты вниз (не потолком), из
        # нескольких журналов называется самый свежий (не самый старый).
        ('potolok_minut', replace_once(source, MOB_MINS_EXPR,
         '-int(-(NOW.timestamp() - max(mob_last)) // 60)'),
         'mob_granica_minuty'),
        ('samyj_starshij_zhurnal', replace_once(source, MOB_MINS_EXPR,
         'int((NOW.timestamp() - min(mob_last)) // 60)'),
         'mob_svezhij_i_starshij'),
    ]


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--repo', type=Path)
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    args = parser.parse_args()
    if args.model or args.stabs:
        checks = []
        for tag, builder in CONTROLS:
            green = [run_case(builder(), key, tag + ':') for key in WORLDS]
            print(f'175 CONTROL {tag} {sum(green)}/{len(green)} ok')
            checks.extend(green)
        if not all(checks):
            print('175 CONTROL_INVALID', file=sys.stderr)
            return 2
        if args.model:
            return 0
        source = honest_v2()
        # Stubs are addressable code mutations. Each is judged by its own input,
        # never by the first red in a combined run (Н-39).
        mutants = [
            ('branch_only', replace_once(source, "or re.search(r'\\bDEMO\\b', title, re.IGNORECASE)", 'or False'), 'demo_title'),
            ('title_only', replace_once(source, "p['headRefName'].casefold().startswith('demo/')", 'False'), 'demo_branch'),
            ('marker_ignored', replace_once(source, "or 'НЕ МЕРЖИТЬ' in title.upper()", 'or False'), 'do_not_merge'),
            ('exclude_every_mob_pr', replace_once(source, "p['headRefName'].casefold().startswith('demo/')", "repo == 'a3ka/Complior-mob'"), 'real_green'),
            ('exclude_red_ci', replace_once(source, "p['headRefName'].casefold().startswith('demo/')", "(p['headRefName'].casefold().startswith('demo/') or any(c.get('conclusion') == 'FAILURE' for c in p.get('statusCheckRollup') or []))"), 'real_red'),
            ('word_substring', replace_once(source, "re.search(r'\\bDEMO\\b', title, re.IGNORECASE)", "'DEMO' in title.upper()"), 'not_demo_word'),
            ('case_sensitive_branch', replace_once(source, "p['headRefName'].casefold().startswith('demo/')", "p['headRefName'].startswith('demo/')"), 'upper_branch'),
            ('case_sensitive_title', replace_once(source, "re.search(r'\\bDEMO\\b', title, re.IGNORECASE)", "re.search(r'\\bDEMO\\b', title)"), 'lower_title'),
            ('title_mob_only', replace_once(source, "re.search(r'\\bDEMO\\b', title, re.IGNORECASE)", "(repo == 'a3ka/Complior-mob' and re.search(r'\\bDEMO\\b', title, re.IGNORECASE))"), 'harness_title'),
            ('marker_mob_only', replace_once(source, "'НЕ МЕРЖИТЬ' in title.upper()", "(repo == 'a3ka/Complior-mob' and 'НЕ МЕРЖИТЬ' in title.upper())"), 'harness_marker'),
            ('exclude_harness_red', replace_once(source, "if state in ('зелёный', 'красный') and not busy:", "if state in ('зелёный', 'красный') and not busy and not (repo == 'dev-harness' and state == 'красный'):"), 'harness_red'),
            ('combined_one_only', replace_once(source,
                "if (p['headRefName'].casefold().startswith('demo/')\n"
                "                or re.search(r'\\bDEMO\\b', title, re.IGNORECASE)\n"
                "                or 'НЕ МЕРЖИТЬ' in title.upper()):",
                "if sum((p['headRefName'].casefold().startswith('demo/'),\n"
                "                bool(re.search(r'\\bDEMO\\b', title, re.IGNORECASE)),\n"
                "                'НЕ МЕРЖИТЬ' in title.upper())) == 1:"), 'combined_demo'),
            ('break_filter', replace_once(source, "            continue\n        st = [c.get",
                                              "            break\n        st = [c.get"), 'multirow'),
        ] + v2_stabs(source)
        failed = False
        for label, mutated, target in mutants:
            caught = not run_case(mutated, target)
            print(f'175 STAB {label} {"caught" if caught else "ZHIV"} @ {target}')
            failed |= not caught
        return 1 if failed else 0
    repo = args.repo if args.repo else ROOT
    candidate = repo.resolve() / BOARD
    if not candidate.is_file():
        print('175 SUBJECT_ABSENT', file=sys.stderr)
        return 2
    source = candidate.read_text()
    checks = [run_case(source, key) for key in WORLDS]
    return 0 if all(checks) else 1


if __name__ == '__main__':
    sys.exit(main())
