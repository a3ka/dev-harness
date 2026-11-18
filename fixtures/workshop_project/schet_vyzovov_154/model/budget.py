#!/usr/bin/env python3
"""Reference for the real --sudit and freeze seams (154); production does not import it.
rc 0: legal ledger; rc 1: named refusal; rc 3: legacy subject, preserve old §6в.
START order is the call order. Versions, outcomes and RELEASE never subtract calls.
"""
import argparse
import datetime as _dt
import json
import os
import pathlib
import subprocess
import sys

GRANICA_NOVYH = '5ca237e4e6bc980c460ede8ee6d85af8a33d0601'
KONSULTANT_LIMIT = 2
ISTOCHNIKI = ('vladelec', 'konsultant', 'orchestrator')
RECEIPT_PREFIX = 'БЮДЖЕТ-154: '


def refuse(reason):
    print('ОТКАЗ: ' + reason, file=sys.stderr)
    return 1


def staryj_predmet(repo, subject):
    tag = 'id/CONTRACT/' + subject
    try:
        if subprocess.run(['git', '-C', repo, 'cat-file', '-e', tag + '^{commit}'],
                          capture_output=True).returncode:
            return False
        anc = subprocess.run(['git', '-C', repo, 'merge-base', '--is-ancestor',
                              tag, GRANICA_NOVYH], capture_output=True)
        return anc.returncode == 0
    except OSError:
        return False


def receipt_line(row):
    """One representation, used verbatim by fixture receipt writers and reader."""
    fields = ('t', 'repoId', 'subjectId')
    if row['t'] == 'SANKTSIYA':
        fields += ('object', 'nomer', 'istochnik')
    return RECEIPT_PREFIX + json.dumps({k: row[k] for k in fields},
                                      ensure_ascii=False, sort_keys=True,
                                      separators=(',', ':'))


def proof_ok(repo, row, cache):
    sha, path = row.get('basisCommit', ''), row.get('basisPath', '')
    if not isinstance(sha, str) or len(sha) != 40 or any(c not in '0123456789abcdef' for c in sha):
        return False
    if not isinstance(path, str) or path.startswith('/') or any(p in ('', '.', '..') for p in path.split('/')):
        return False
    if path != 'HANDOFF.md' and not (path.startswith('verdicts/arbitration/') and path.endswith('.md')):
        return False
    key = (sha, path)
    if key not in cache:
        exists = subprocess.run(['git', '-C', repo, 'cat-file', '-e', sha + '^{commit}'],
                                capture_output=True)
        data = subprocess.run(['git', '-C', repo, 'show', sha + ':' + path],
                              capture_output=True, text=True)
        cache[key] = data.stdout.splitlines() if not exists.returncode and not data.returncode else []
    return receipt_line(row) in cache[key]


def sanction_matches(row, pos, obj):
    return row['nomer'] == pos and row['object'] == obj


def _neizvesten(what):
    return refuse('SCHET_NEIZVESTEN: ' + what)


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--sostojanie', required=True)
    p.add_argument('--repo', required=True)
    p.add_argument('--subject', required=True)
    p.add_argument('--object', default='')
    p.add_argument('--zhurnaly')
    p.add_argument('--phase', choices=('spawn', 'freeze'), required=True)
    a = p.parse_args()
    if staryj_predmet(a.repo, a.subject):
        return 3
    if not a.sostojanie:
        return _neizvesten('корень состояния не передан')
    ledger = pathlib.Path(a.sostojanie) / 'uchet.jsonl'
    if not ledger.is_file() or not os.access(ledger, os.R_OK):
        return _neizvesten('учёт START недоступен: ' + str(ledger))
    seed_k = 0
    try:
        rows = [json.loads(s) for s in ledger.read_text().splitlines() if s]
        if any(not isinstance(r, dict) for r in rows):
            raise ValueError('битая JSONL-строка')
        remote = subprocess.run(['git', '-C', a.repo, 'remote', 'get-url', 'origin'],
                                capture_output=True, text=True).stdout.strip()
        repo_id = remote.rsplit('/', 1)[-1] if remote else ''
        if repo_id.endswith('.git'):
            repo_id = repo_id[:-len('.git')]
        if not repo_id:
            repo_id = pathlib.Path(a.repo).name
        judges = [r for r in rows if r.get('t') == 'START' and
                  r.get('klass') == 'sudja' and r.get('rol') in ('critic', 'critic-sol')]
        starts = [r for r in judges if r.get('repoId') == repo_id and
                  r.get('subjectId') == a.subject]
        if any(not isinstance(r.get('holder'), str) or not r['holder'] or
               not isinstance(r.get('object'), str) or
               not isinstance(r.get('at'), str) or not r['at'] for r in starts):
            raise ValueError('битая START-строка')
        for r in rows:
            if r.get('t') == 'ARBITRAZH':
                if (not isinstance(r.get('repoId'), str) or not r['repoId'] or
                        not isinstance(r.get('subjectId'), str) or not r['subjectId'] or
                        not isinstance(r.get('at'), str) or not r['at']):
                    raise ValueError('битая строка ARBITRAZH')
            elif r.get('t') == 'SANKTSIYA':
                nom = r.get('nomer')
                if (not isinstance(r.get('repoId'), str) or not r['repoId'] or
                        not isinstance(r.get('subjectId'), str) or not r['subjectId'] or
                        not isinstance(r.get('object'), str) or len(r['object']) != 40 or
                        any(c not in '0123456789abcdef' for c in r['object']) or
                        isinstance(nom, bool) or not isinstance(nom, int) or nom < 3 or
                        r.get('istochnik') not in ISTOCHNIKI or
                        (r['istochnik'] == 'orchestrator' and nom != 3) or
                        not isinstance(r.get('at'), str) or not r['at']):
                    raise ValueError('битая строка SANKTSIYA')
        arbitrazh = [r for r in rows if r.get('t') == 'ARBITRAZH' and
                     r.get('repoId') == repo_id and r.get('subjectId') == a.subject]
        sank = [r for r in rows if r.get('t') == 'SANKTSIYA' and
                r.get('repoId') == repo_id and r.get('subjectId') == a.subject]
        cache = {}
        for r in arbitrazh + sank:
            if not proof_ok(a.repo, r, cache):
                return refuse(('ARBITRAZH_NE_PODTVERZHDEN' if r['t'] == 'ARBITRAZH'
                               else 'SANKTSIYA_NE_PODTVERZHDENA') + ': нет закоммиченной адресной строки')
        t0 = None
        for r in judges:
            ts = _dt.datetime.fromisoformat(r['at'].replace('Z', '+00:00'))
            if t0 is None or ts < t0:
                t0 = ts
        verdicts = list((pathlib.Path(a.repo) / 'verdicts' / 'critic').glob(
            'contracts-' + a.subject + '-*.md'))
        for f in verdicts:
            if f.read_text().splitlines()[0].strip() not in ('accept', 'FAIL', 'ESCALATE'):
                raise ValueError('битый вердикт: ' + str(f))
        log = subprocess.run(['git', '-C', a.repo, 'log', '--format=%at', '--',
                              'verdicts/critic/contracts-' + a.subject + '-*.md'],
                             capture_output=True, text=True, check=True).stdout.split()
        c0 = min(int(x) for x in log) if log else None
        do_zhurnala = t0 is not None and c0 is not None and c0 < t0.timestamp()
        if do_zhurnala:
            seed_path = pathlib.Path(a.sostojanie) / 'zasev_kritika.jsonl'
            if not seed_path.is_file() or not os.access(seed_path, os.R_OK):
                return _neizvesten('история критика старше журнала, записи-засева нет')
            srows = [json.loads(s) for s in seed_path.read_text().splitlines() if s]
            match = [r for r in srows if isinstance(r, dict) and
                     r.get('subjectId') == a.subject and r.get('repoId') == repo_id]
            k = match[-1].get('doZhurnala') if match else None
            if not isinstance(k, int) or isinstance(k, bool) or k < 1:
                return _neizvesten('засев без целого doZhurnala >= 1')
            seed_k = k
        if not do_zhurnala and verdicts and not starts:
            return refuse('SCHET_RASHOZHDENIE: вердикт есть без START')
    except (ValueError, TypeError, UnicodeError, OSError, IndexError, KeyError,
            subprocess.CalledProcessError) as e:
        return _neizvesten('учёт/вердикты не читаются: ' + str(e))
    count = len(starts)
    objs = [None] * seed_k + [r['object'] for r in starts][:count]
    if a.phase == 'spawn':
        objs.append(a.object)
    used = 0
    for pos, obj in enumerate(objs, 1):
        if pos <= 2:
            continue
        if obj is None:
            return _neizvesten('до-журнальная позиция без OBJECT: ' + str(pos))
        if pos == 4 and arbitrazh:
            continue
        grants = [s for s in sank if sanction_matches(s, pos, obj)]
        if any(s['istochnik'] == 'vladelec' or
               (pos == 3 and s['istochnik'] == 'orchestrator') for s in grants):
            continue
        if any(s['istochnik'] == 'konsultant' for s in grants) and used < KONSULTANT_LIMIT:
            used += 1
            continue
        return refuse('KAP_VYZOVOV_KRITIKA: предмет ' + a.subject + ': позиция ' +
                      str(pos) + ' не покрыта; консультантских вызовов=' + str(used))
    if a.phase == 'freeze' and count == 0:
        return refuse('SCHET_RASHOZHDENIE: accept без START')
    return 0


if __name__ == '__main__':
    sys.exit(main())
