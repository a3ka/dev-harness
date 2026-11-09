"""Independent honest board control, based on the pre-175 station entry point.

The model changes only PR selection. No model code is shipped to ops/server.
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


def replace_once(text, old, new):
    count = text.count(old)
    if count != 1:
        raise ValueError(f'model anchor must be unique, got {count}: {old!r}')
    return text.replace(old, new)


def honest():
    return replace_once(replace_once(BASE, OLD_QUERY, NEW_QUERY), OLD_LOOP, FILTER)
