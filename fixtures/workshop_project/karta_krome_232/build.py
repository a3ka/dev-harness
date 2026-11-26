#!/usr/bin/env python3
"""Generate full library carriers; each mutation names an observable input (Н-39)."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

sys.dont_write_bytecode = True
from probe import CASES

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = '568f0ea63271e3461b574105cba8faec7563a8fd'
OLD = r'([.]|\ —\ .+)?$'
TEXT = r'[^[:space:]]([^[:cntrl:]]*[^[:space:]])?'
NEW = r'([.]|\ —\ .+|,\ кроме\ ' + TEXT + r'[.]|;\ ' + TEXT + r'[.])?$'


def replace(text, old, new, count=1):
    if text.count(old) != count:
        raise RuntimeError('ANCHOR: ' + repr(old) + ' count=' + str(text.count(old)))
    return text.replace(old, new)


def carriers():
    baseline = subprocess.run(['git', '-C', str(ROOT), 'show', BASE + ':scripts/lib_karta_sdachi.sh'],
                              capture_output=True, check=True).stdout.decode()
    model = replace(baseline, OLD, NEW, 2)
    numbered = next(line for line in model.splitlines() if 'if [[ "$rest" =~ ^без\\ изменений\\ с\\ вызова' in line)
    previous = next(line for line in model.splitlines() if 'elif [[ "$rest" =~ ^без\\ изменений\\ с\\ предыдущего' in line)
    old_numbered = next(line for line in baseline.splitlines() if 'if [[ "$rest" =~ ^без\\ изменений\\ с\\ вызова' in line)
    old_previous = next(line for line in baseline.splitlines() if 'elif [[ "$rest" =~ ^без\\ изменений\\ с\\ предыдущего' in line)
    # One registry defines mutations and exact independently red branches.
    mutations = {
        'st01-any-tail': (replace(model, NEW, r'(.*)?$', 2),
                          ['number-arbitrary', 'previous-arbitrary', 'number-no-comma-space']),
        'st02-empty-text': (replace(model, TEXT, r'[^[:cntrl:]]*', 4),
                            ['number-except-empty', 'previous-except-empty',
                             'number-semicolon-empty', 'previous-semicolon-empty']),
        'st03-dot-optional': (replace(model, r'[.]|;\ ', r'[.]?|;\ ', 2).replace(r'[.])?$', r'[.]?)?$'),
                              ['number-except-no-dot', 'previous-except-no-dot',
                               'number-semicolon-no-dot', 'previous-semicolon-no-dot']),
        'st04-promote-direct': (replace(model, '                rest="${stroka#*: }"',
                                        '                rest="${stroka#*: }"\n'
                                        '                if [[ "$rest" == "чисто — без изменений"* ]]; then\n'
                                        '                    rest="${rest#чисто — }"\n'
                                        '                fi'), ['direct-semicolon', 'direct-except']),
        'st05-case-insensitive': (replace(model, r'кроме\ ', r'[кК][рР][оО][мМ][еЕ]\ ', 2),
                                  ['number-uppercase', 'previous-uppercase']),
        'st06-number-only': (replace(model, previous, old_previous),
                             ['previous-except', 'previous-semicolon-command', 'previous-semicolon-prose']),
        'st07-previous-only': (replace(model, numbered, old_numbered),
                               ['number-except', 'number-semicolon-command', 'number-semicolon-prose']),
        'st08-greedy-newline': (replace(model, '        stroka="${stroka%$\'\\r\'}"',
                                       '        stroka="${stroka%$\'\\r\'}"\n'
                                       '        if [[ "$stroka" == К-*"без изменений"* ]] && [[ "$stroka" != *[.] ]]; then\n'
                                       '            IFS= read -r continuation && stroka="$stroka $continuation"\n'
                                       '        fi'), ['number-newline', 'previous-newline',
                                                       'number-except-newline', 'previous-except-newline']),
        'st09-no-expansion': (baseline, ['number-except', 'number-semicolon-command',
                                        'number-semicolon-prose', 'previous-except']),
        'st10-whitespace-text': (replace(model, TEXT, r'[^[:cntrl:]]+', 4),
                                 ['number-double-space', 'previous-double-space',
                                  'number-semicolon-double-space', 'previous-semicolon-double-space']),
    }
    return baseline, model, mutations


def main():
    baseline, model, mutations = carriers()
    outputs = {'model/lib_karta_sdachi.sh': model}
    links = []
    for name, (text, cases) in mutations.items():
        path = 'stabs/' + name + '/lib_karta_sdachi.sh'
        outputs[path] = text
        for case in cases:
            if case not in CASES:
                raise RuntimeError('Unknown case ' + case)
            links.append({'stab': path, 'case': case})
    hashes = {}
    for path, text in outputs.items():
        file = HERE / path
        file.parent.mkdir(parents=True, exist_ok=True)
        file.write_text(text)
        hashes[path] = hashlib.sha256(text.encode()).hexdigest()
    hashes['live178.md'] = hashlib.sha256((HERE / 'live178.md').read_bytes()).hexdigest()
    source = {'base': BASE, 'source': 'scripts/lib_karta_sdachi.sh',
              'base_sha256': hashlib.sha256(baseline.encode()).hexdigest(),
              'sha256': hashes, 'stab_vhod': links,
              'live_source': 'Complior-back@1a27515cb9e9010bb74cb2fc1b0439995d854f61:.harness/verdicts/critic/contracts-178-v1-krug6-fail.md'}
    (HERE / 'source.json').write_text(json.dumps(source, ensure_ascii=False, indent=2) + '\n')
    (HERE / 'stabs.tsv').write_text(''.join(x['stab'] + '\t' + x['case'] + '\n' for x in links))
    print('KLETKI', len(CASES), 'STABY', len(mutations), 'SVJAZI', len(links))


if __name__ == '__main__':
    main()
