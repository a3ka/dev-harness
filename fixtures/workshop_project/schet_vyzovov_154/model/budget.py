#!/usr/bin/env python3
"""Reference decision for the two real CLI seams; no product scripts import this."""
import argparse
import json
import os
import pathlib
import subprocess
import sys


def refuse(reason):
    print('ОТКАЗ: ' + reason, file=sys.stderr)
    return 1


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--sostojanie', required=True)
    p.add_argument('--repo', required=True)
    p.add_argument('--subject', required=True)
    p.add_argument('--zhurnaly')
    p.add_argument('--phase', choices=('spawn', 'freeze'), required=True)
    a = p.parse_args()
    ledger = pathlib.Path(a.sostojanie) / 'uchet.jsonl'
    if not ledger.is_file() or not os.access(ledger, os.R_OK):
        return refuse('SCHET_NEIZVESTEN: учёт START недоступен: ' + str(ledger))
    try:
        rows = [json.loads(s) for s in ledger.read_text().splitlines() if s]
        if any(not isinstance(r, dict) for r in rows):
            raise ValueError('битая JSONL-строка')
        remote = subprocess.run(['git', '-C', a.repo, 'remote', 'get-url', 'origin'],
                                capture_output=True, text=True, check=True).stdout.strip()
        repo_id = pathlib.PurePosixPath(remote).name.removesuffix('.git')
        if not repo_id:
            raise ValueError('repoId пуст')
        starts = [r for r in rows if r.get('t') == 'START' and
                  r.get('repoId') == repo_id and r.get('subjectId') == a.subject and
                  r.get('klass') == 'sudja' and r.get('rol') in ('critic', 'critic-sol')]
        if any(
            not isinstance(r.get('holder'), str) or not r['holder'] or
            not isinstance(r.get('object'), str) for r in starts
        ):
            raise ValueError('битая START-строка')
        # Veredicts are secondary evidence only; edited/renamed/copied files do NOT mint calls.
        verdicts = list((pathlib.Path(a.repo) / 'verdicts' / 'critic').glob(
            'contracts-' + a.subject + '-*.md'))
        for f in verdicts:
            if f.read_text().splitlines()[0].strip() not in ('accept', 'FAIL', 'ESCALATE'):
                raise ValueError('битый вердикт: ' + str(f))
        if verdicts and not starts:
            return refuse('SCHET_RASHOZHDENIE: вердикт есть без START по предмету ' + a.subject)
    except (ValueError, TypeError, UnicodeError, OSError, IndexError,
            subprocess.CalledProcessError) as e:
        return refuse('SCHET_NEIZVESTEN: учёт/вердикты не читаются: ' + str(e))
    count = len(starts)
    if a.phase == 'spawn' and count >= 5:
        return refuse('KAP_VYZOVOV_KRITIKA: предмет ' + a.subject + ': ' + str(count) + '/5 до спавна')
    if a.phase == 'freeze' and count > 5:
        return refuse('KAP_VYZOVOV_KRITIKA: предмет ' + a.subject + ': ' + str(count) + '/5 при freeze')
    if a.phase == 'freeze' and count == 0:
        return refuse('SCHET_RASHOZHDENIE: accept без START по предмету ' + a.subject)
    return 0


if __name__ == '__main__':
    sys.exit(main())
