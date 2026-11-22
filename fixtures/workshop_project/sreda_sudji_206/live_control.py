#!/usr/bin/env python3
"""Test observer validity, not live judges; never write genuine accounting."""
import argparse
import copy
import json
from pathlib import Path
import subprocess
import tempfile
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
T0 = '2026-11-22T00:00:00Z'
OBJECT = 'a' * 40


def controls():
    rows = []
    for n, role in enumerate(('critic', 'adversary', 'reviewer')):
        shared = dict(repoId='disposable', subjectId='206', holder=role, at=f'2026-11-22T00:00:0{n}Z')
        rows.extend([dict(shared, t='START', klass='sudja', rol=role, object=OBJECT),
                     dict(shared, t='RELEASE', prichina='verdikt_zakommiten')])
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
    value = copy.deepcopy(rows)
    for i, char in zip((0, 2, 4), 'abc'):
        value[i]['object'] = char * 40
    cases.append(('different-objects', value, 1, 'OBJECT_NE_SOVPADAET'))
    value = copy.deepcopy(rows)
    for i in (0, 2, 4):
        value[i]['object'] = 'd' * 40
    cases.append(('unassigned-object', value, 1, 'OBJECT_NE_SOVPADAET'))
    value = copy.deepcopy(rows)
    del value[2]['object']
    cases.append(('missing-object', value, 1, 'OBJECT_NE_SOVPADAET'))
    for name, payload in [('null', b'null\n'), ('number', b'1\n'), ('string', b'"x"\n'),
                          ('array', b'[]\n'), ('broken-json', b'{\n'), ('bom', b'\xef\xbb\xbf{}\n')]:
        cases.append((name, payload, 2, 'NOT_IMPLEMENTED: NEVALIDNYJ_ZHURNAL'))
    return cases


def suite(observer, sandbox, only=None):
    sandbox.mkdir(parents=True, exist_ok=True)
    ledger = sandbox / 'synthetic.jsonl'
    results = {}
    for name, records, rc, message in controls():
        cell = 'observer-' + name
        if only is not None and cell != only:
            continue
        payload = records if isinstance(records, bytes) else b''.join((json.dumps(row) + '\n').encode() for row in records)
        expected = (rc, b'' if rc == 2 else (message + '\n').encode(), (message + '\n').encode() if rc == 2 else b'')
        ledger.write_bytes(payload)
        p = subprocess.run([sys.executable, str(observer), '--ledger', str(ledger), '--since', T0,
                            '--repo-id', 'disposable', '--subject', '206', '--object', OBJECT],
                           cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=10)
        actual = (p.returncode, p.stdout, p.stderr)
        if p.returncode not in (0, 1, 2) or (p.returncode == 1 and p.stderr):
            raise RuntimeError(f'OBSERVER_INFRA: {name}: {actual!r}')
        results[cell] = actual == expected
    return results


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--case', choices=[name for name, *_ in controls()])
    args = p.parse_args()
    scratch = ROOT / '.scratch-206'
    scratch.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='observer.', dir=scratch) as temp:
        results = suite(HERE / 'live.py', Path(temp), 'observer-' + args.case if args.case else None)
    for name, ok in results.items():
        print(f'{name}: {"ZELEN" if ok else "KRASEN"}')
    failed = sum(not ok for ok in results.values())
    print(f'OBSERVER_CONTROLS={len(results)} KRASNYE={failed}; LIVE_JUDGES_NOT_RUN')
    return int(failed != 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError, subprocess.SubprocessError) as error:
        print(f'NOT_IMPLEMENTED: {error}', file=sys.stderr)
        sys.exit(2)
