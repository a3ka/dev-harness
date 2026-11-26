#!/usr/bin/env python3
"""231: reproducible reference and addressed full-door mutants; never production."""
import hashlib
import json
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = '568f0ea63271e3461b574105cba8faec7563a8fd'
OLD_NAMES = r'''    elif [[ "$name" =~ -impl-(krug)?([1-9][0-9]*)\.md$ ]]; then
      version="${BASH_REMATCH[2]}" declared="$version" legacy=1
    elif [[ "$name" == *-impl.md ]]; then
      version=1 declared=1 legacy=1
    elif [[ "$name" =~ -impl-([0-9]|krug) ]] || [[ "$name" == *-impl-.md ]]; then
      die "done: VERDICT_ROUND_INVALID: $role: $f"
'''
CALL_KEY = '''    # 231: a plain v carrier does not assert the call number.
    if [ "$legacy" -eq 1 ] && [ -n "$call" ] && [ "$call" != "$declared" ]; then
      die "done: VERDICT_ROUND_CONFLICT: $role: $f"
    fi
    if [ "$plain" -eq 1 ] && [ -n "$call" ]; then
      declared=''
      if [ -z "$phase_version" ]; then version="$call"; fi
    fi
'''
# One source of the observable mutant/input links (Н-39).
MUTATIONS = {
    'lexical': ('if [ "$key" -gt "$best" ]; then', 'if [[ "$key" > "$best" ]]; then', ['numeric-fail', 'numeric-accept']),
    'bare-zero': ('version=1 declared=1 legacy=1', 'version=0 declared=0 legacy=1', ['bare-duplicate']),
    'bare-skipped': ('version=1 declared=1 legacy=1', 'continue', ['bare-fail']),
    'krug-rejected': ('(krug)?([1-9][0-9]*)', '(absent)?([1-9][0-9]*)', ['krug']),
    'unchecked-call': (CALL_KEY, '    if [ "$legacy" -eq 1 ]; then declared=""; fi\n', ['old-conflict-low', 'old-conflict-high']),
    'always-conflict': ('[ "$legacy" -eq 1 ] && [ -n "$call" ] && [ "$call" != "$declared" ]', '[ "$legacy" -eq 1 ] && [ -n "$call" ]', ['old-call-equal']),
    'old-rejected': (OLD_NAMES, '', ['back181', 'back179', 'mobile218', 'krug']),
    'call-instead-name': ('version="${BASH_REMATCH[2]}" declared="$version" legacy=1', 'version="${BASH_REMATCH[2]}" declared="" legacy=0 plain=1', ['old-conflict-low', 'old-conflict-high']),
    'v-call-required': ('if [ "$plain" -eq 1 ] && [ -n "$call" ]; then', 'if false; then', ['live227', 'plain-call-high', 'plain-call-low']),
    'explicit-unchecked': ('[ "$call" = "$declared" ]', '[ "$explicit" -eq 1 ] || [ "$call" = "$declared" ]', ['explicit-conflict']),
    'duplicates-allowed': ('*" $key "*) die "done: VERDICT_ROUND_DUPLICATE: $role: $key: $f" ;;', '*" $key "*) : ;;', ['same-call', 'bare-duplicate']),
    'dot-rejected': (' || [ "$_pdecl" = "ПРОДУКТ: станция." ]', '', ['product-live215']),
    'dot-tail-allowed': ('[ "$_pdecl" = "ПРОДУКТ: станция." ]', '[[ "$_pdecl" == "ПРОДУКТ: станция."* ]]', ['product-double-dot', 'product-dot-x']),
    'zero-allowed': ('(krug)?([1-9][0-9]*)', '(krug)?([0-9]+)', ['old-zero', 'old-leading-zero']),
}


def one(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError('ANCHOR ' + repr(old) + ': ' + str(text.count(old)))
    return text.replace(old, new)


def blob(ref, path):
    return subprocess.run(['git', '-C', str(ROOT), 'show', ref + ':' + path],
                          capture_output=True, check=True).stdout


def reference():
    text = blob(BASE, 'scripts/done_contract.sh').decode()
    text = one(text, 'local version number declared call denominator phase_version explicit',
               'local version number declared call denominator phase_version explicit legacy plain')
    text = one(text, "version='' number=0 declared='' explicit=0", "version='' number=0 declared='' explicit=0 legacy=0 plain=0")
    text = one(text, 'version="${BASH_REMATCH[1]}" declared="$version"\n    elif [[ "$name" =~ -impl-a',
               'version="${BASH_REMATCH[1]}" declared="$version" plain=1\n    elif [[ "$name" =~ -impl-a')
    anchor = '    elif [[ "$name" =~ -(v|impl-v|impl-a)[0-9] ]]; then\n'
    text = one(text, anchor, OLD_NAMES + anchor)
    text = one(text, '    # ── сверка объявлений с именем носителя ──────────────────────────────\n',
               '    # ── сверка объявлений с именем носителя ──────────────────────────────\n' + CALL_KEY)
    text = one(text, '[ "$_pdecl" = "ПРОДУКТ: станция" ]; then',
               '[ "$_pdecl" = "ПРОДУКТ: станция" ] || [ "$_pdecl" = "ПРОДУКТ: станция." ]; then')
    # Only inherited warnings; the targeted changes remain checked.
    return one(text, '#!/usr/bin/env bash\n', '#!/usr/bin/env bash\n# shellcheck disable=SC2034,SC2295,SC1010\n')


def main():
    import sys
    sys.dont_write_bytecode = True
    from probe import CASES
    model = reference()
    carriers = {'model/done_contract.sh': model.encode()}
    links = []
    for name, (old, new, cells) in MUTATIONS.items():
        path = 'stabs/' + name + '/done_contract.sh'
        carriers[path] = one(model, old, new).encode()
        for cell in cells:
            names = [cell] if cell.startswith('product-') else [role + '-' + cell for role in ('review', 'adversary')]
            for case in names:
                if case not in CASES:
                    raise RuntimeError('UNKNOWN_CASE ' + case)
                links.append({'stab': path, 'case': case})
    for path, content in carriers.items():
        dest = HERE / path
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(content)
    (HERE / 'source.json').write_text(json.dumps({'base': BASE, 'nositeli': {
        p: hashlib.sha256(c).hexdigest() for p, c in carriers.items()}, 'stab_vhod': links}, indent=2) + '\n')
    (HERE / 'stabs.tsv').write_text(''.join(x['stab'] + '\t' + x['case'] + '\n' for x in links))
    print('NOSITELI', len(carriers), 'STABY', len(MUTATIONS), 'SVJAZI', len(links))


if __name__ == '__main__':
    main()
