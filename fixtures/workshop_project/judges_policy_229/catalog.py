#!/usr/bin/env python3
"""Read-only inventory of refusal sites and latest actual frozen contracts."""
import collections
import json
from pathlib import Path
import re
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = '78672b79bac88b9c3765b3d9b53cd983d4a13728'
NUMBERS = ('140', '154', '167', '172', '211', '222', '224', '218', '206', '230')
MERGED = ('AGENT_NET', 'IMJA_NET', 'GRAMMATIKA_IMENI',
          'SUBJECT_NET_V_ZADANII', 'SUBEKT_DVA_V_ZADANII', 'GRAMMATIKA_SUBEKTA',
          'PIN_NET', 'GRAMMATIKA_PINA', 'RASHOZHDENIE_PINA',
          'OBJECT_OTSTUTSVUET', 'SUBEKT_DVA_OBJECTA', 'GRAMMATIKA_OBJECTA')


def git(*args):
    return subprocess.run(['git', '-C', str(ROOT), *args], check=True,
                          capture_output=True, text=True).stdout


def inventory(text):
    # Same literal-call measure as Fable; dynamic perenos_otkaz sites also listed.
    return collections.Counter(re.findall(r'\botp ([A-Z][A-Z0-9_]+)', text))


def frozen():
    out = {}
    for n in NUMBERS:
        refs = git('for-each-ref', '--format=%(refname)',
                   'refs/tags/frozen/contracts/' + n + '/').splitlines()
        refs = [r for r in refs if r.rsplit('/', 1)[1].isdigit()]
        if not refs:
            out[n] = {'frozen': None}
            continue
        ref = max(refs, key=lambda r: int(r.rsplit('/', 1)[1]))
        files = git('ls-tree', '-r', '--name-only', ref + '^{commit}', '--', 'contracts').splitlines()
        files = [p for p in files if p.startswith('contracts/' + n + '-') and p.endswith('.md')]
        if len(files) != 1:
            raise RuntimeError('ambiguous frozen contract: ' + ref)
        text = git('show', ref + '^{commit}:' + files[0])
        out[n] = {'ref': ref, 'file': files[0],
                  'commit': git('rev-parse', ref + '^{commit}').strip(),
                  'zones': [s for s in text.splitlines() if s.startswith(('ЗОНА', 'ПЕРЕСЕЧЕНИЕ'))]}
    return out


def main():
    import sys
    if '--frozen' in sys.argv:
        print(json.dumps(frozen(), ensure_ascii=False, indent=2))
    else:
        text = git('show', BASE + ':scripts/zamok_predmeta.sh')
        counts = inventory(text)
        for code, count in sorted(counts.items()):
            print(code, count, '->', 'BITYJ_VHOD' if code in MERGED else code)
        print('BASE_CODES', len(counts), 'LITERAL_SITES', sum(counts.values()),
              'TARGET_CODES', len(set(counts) - set(MERGED)))
        dynamic = collections.Counter(re.findall(r'\bperenos_otkaz ([A-Z][A-Z0-9_]+)', text))
        print('DYNAMIC_TRANSFER', json.dumps(dynamic, sort_keys=True))


if __name__ == '__main__':
    main()
