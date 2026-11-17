"""Independent honest board control: pre-175 entry point + v1 filter + v2 mob stream.

v1: demo PR filter. v2: the mob stream led by the separate Complior-mob project
session (its live journal in the project session home, 055 И-2) prints a fact
line instead of «СТОИТ ПОТОК mob» and does not count into «стоит без хода».
No model code is shipped to ops/server.
"""
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
BASE = subprocess.run(
    ['git', '-C', str(ROOT), 'show', '24cc7ea9c:ops/server/user/orch-tablo'],
    check=True, capture_output=True, text=True,
).stdout
OLD_QUERY = "'number,headRefName,statusCheckRollup,updatedAt'"
NEW_QUERY = "'number,headRefName,title,statusCheckRollup,updatedAt'"
OLD_LOOP = '    for p in rows:\n        st = [c.get'
FILTER = '''    for p in rows:
        title = p.get('title') or ''
        if (p['headRefName'].casefold().startswith('demo/')
                or re.search(r'\\bDEMO\\b', title, re.IGNORECASE)
                or 'НЕ МЕРЖИТЬ' in title.upper()):
            continue
        st = [c.get'''

# ── v2: поток mob ведёт отдельная сессия проекта (живой журнал) ──────────────
PRS_ANCHOR = 'prs = []   # (репо, номер, ветка, состояние, обновлён)'
MOB_BLOCK = (
    "# Ведущий потока mob — отдельная сессия проекта Complior-mob (125/055): её дом\n"
    "# вне дерева станции, журнал сессия пишет сама. Живой журнал = самый свежий jsonl\n"
    "# (сессия или её субагент) не старше окна табло; мера та же, что у журналов\n"
    "# станции. Наличие состояния проекта (bin/wt/архив) ведущим не считается.\n"
    "mob_ses = glob.glob(os.path.expanduser(\n"
    "    '~/.local/state/dev-harness-projects/complior-mob/home/.omp/profiles/dev'\n"
    "    '/agent/sessions/--home-harness-projects-Complior-mob--'))\n"
)
MOB_VEDET_LINE = 'mob_vedet = bool(mob_last) and max(mob_last) >= NOW.timestamp() - WINDOW * 60'
MOB_VEDET_LINES = (
    "mob_last = [os.path.getmtime(f) for b in mob_ses\n"
    "            for f in glob.glob(b + '/*.jsonl') + glob.glob(b + '/*/*.jsonl')]\n"
    + MOB_VEDET_LINE + "\n"
)
MOB_MINS_EXPR = 'int((NOW.timestamp() - max(mob_last)) // 60)'
LOOP_OLD = (
    "for s in ('харнесс', 'mob'):\n"
    "    if active.get(s):\n"
    "        print(f'  {s}: в работе предметов — {active[s]}')\n"
    "    else:\n"
)
LOOP_NEW = (
    "for s in ('харнесс', 'mob'):\n"
    "    if active.get(s):\n"
    "        print(f'  {s}: в работе предметов — {active[s]}')\n"
    "    elif s == 'mob' and mob_vedet:\n"
    "        print(f'  mob: ведёт сессия проекта Complior-mob (журнал '\n"
    "              f'{" + MOB_MINS_EXPR + "} мин назад) — станция поток не требует')\n"
    "    else:\n"
)


def replace_once(text, old, new):
    count = text.count(old)
    if count != 1:
        raise ValueError(f'model anchor must be unique, got {count}: {old!r}')
    return text.replace(old, new)


def honest():
    return replace_once(replace_once(BASE, OLD_QUERY, NEW_QUERY), OLD_LOOP, FILTER)


def honest_v2():
    src = replace_once(honest(), PRS_ANCHOR, MOB_BLOCK + MOB_VEDET_LINES + PRS_ANCHOR)
    return replace_once(src, LOOP_OLD, LOOP_NEW)

# ── v2: равноправные честные формы поиска журналов (блок 3 критика) ─────────
# Инвариант один и тот же — прямые *.jsonl и вложенные */*.jsonl в доме
# сессии; форма обращения к файловой системе не предписана: glob составного
# пути (honest_v2), glob полного пути, find, обход каталога — каждый контроль
# обязан быть зелёным на всех мирах; батарея судит поведение, не синтаксис.
ALT_FULLPATH_SEARCH = (
    "mob_last = [os.path.getmtime(f) for p in ('*.jsonl', '*/*.jsonl')\n"
    "            for f in glob.glob(os.path.expanduser(\n"
    "                '~/.local/state/dev-harness-projects/complior-mob/home/.omp/profiles/dev'\n"
    "                '/agent/sessions/--home-harness-projects-Complior-mob--/' + p))]\n"
)
ALT_FIND_SEARCH = (
    "mob_last = [os.path.getmtime(f) for b in mob_ses for f in sh(\n"
    "    'find', b, '-name', '*.jsonl', '-maxdepth', '2').splitlines() if f]\n"
)
ALT_WALK_SEARCH = (
    "mob_last = [os.path.getmtime(os.path.join(r, f))\n"
    "            for b in mob_ses for r, _d, fs in os.walk(b)\n"
    "            for f in fs if f.endswith('.jsonl')]\n"
)


def _v2_alt(search_lines):
    return replace_once(honest_v2(), MOB_VEDET_LINES, search_lines + MOB_VEDET_LINE + '\n')


def honest_v2_fullpath():
    return _v2_alt(ALT_FULLPATH_SEARCH)


def honest_v2_find():
    return _v2_alt(ALT_FIND_SEARCH)


def honest_v2_walk():
    return _v2_alt(ALT_WALK_SEARCH)
