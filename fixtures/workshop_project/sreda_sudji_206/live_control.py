#!/usr/bin/env python3
"""Test observer validity, not the behavior of a live judge; no genuine ledger writes."""
import copy
import json
from pathlib import Path
import subprocess
import tempfile
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
T0 = '2026-11-22T00:00:00Z'
rows = []
for n, role in enumerate(('critic', 'adversary', 'reviewer')):
    shared = dict(repoId='disposable', subjectId='206', holder=role, at=f'2026-11-22T00:00:0{n}Z')
    rows.extend([dict(shared, t='START', klass='sudja', rol=role), dict(shared, t='RELEASE', prichina='verdikt_zakommiten')])
cases = [('honest', rows, 0, 'SUDA=3 OBRYVOV=0 VERDIKTOV=3'), ('empty', [], 1, 'TRI_SUDA_NE_PREDJAVLENY')]
for count in (1, 2, 4):
    value = rows[:2*count] if count < 4 else rows + [dict(rows[0], holder='fourth')]
    cases.append((f'count-{count}', value, 1, 'TRI_SUDA_NE_PREDJAVLENY'))
value = copy.deepcopy(rows)
value[3]['prichina'] = 'obryv_bez_verdikta'
cases.append(('intermediate-obryv', value, 1, 'OBRYV_BEZ_VERDIKTA'))
cases.append(('missing-release', rows[:-1], 1, 'VERDIKT_NE_PODTVERZHDEN'))
value = copy.deepcopy(rows)
value[5]['prichina'] = 'yield'
cases.append(('yield-not-verdict', value, 1, 'VERDIKT_NE_PODTVERZHDEN'))
cases.append(('overlapping-judges', [rows[i] for i in (0, 2, 1, 3, 4, 5)], 1, 'VERDIKT_NE_PODTVERZHDEN'))
value = copy.deepcopy(rows)
value[2]['holder'] = value[0]['holder']
cases.append(('duplicate-holder', value, 1, 'TRI_SUDA_NE_PREDJAVLENY'))
value = copy.deepcopy(rows)
value[0]['repoId'] = 'other'
cases.append(('foreign-repo', value, 1, 'TRI_SUDA_NE_PREDJAVLENY'))
value = copy.deepcopy(rows)
value[0]['at'] = '2026-11-21T00:00:00Z'
cases.append(('before-window', value, 1, 'TRI_SUDA_NE_PREDJAVLENY'))

scratch = ROOT / '.scratch-206'
scratch.mkdir(exist_ok=True)
failed = 0
with tempfile.TemporaryDirectory(prefix='observer.', dir=scratch) as temp:
    ledger = Path(temp) / 'synthetic.jsonl'
    for name, records, rc, message in cases:
        ledger.write_bytes(b''.join((json.dumps(row) + '\n').encode() for row in records))
        p = subprocess.run([sys.executable, str(HERE / 'live.py'), '--ledger', str(ledger), '--since', T0, '--repo-id', 'disposable', '--subject', '206'], cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=10)
        ok = (p.returncode, p.stdout, p.stderr) == (rc, (message + '\n').encode(), b'')
        failed += not ok
        print(f'{name}: {"ZELEN" if ok else "KRASEN"}')
print(f'OBSERVER_CONTROLS={len(cases)} KRASNYE={failed}; LIVE_JUDGES_NOT_RUN')
sys.exit(int(failed != 0))
