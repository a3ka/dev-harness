#!/usr/bin/env python3
"""232 full reference carriers and addressable mutations; bindings live in code."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = '8fe4e79ca8c5165bcd1e7dfb75768c5bd329d3cb'


def replace(text, old, new, count=1):
    if text.count(old) != count:
        raise RuntimeError('ANCHOR: ' + repr(old) + ': ' + str(text.count(old)))
    return text.replace(old, new)


def original(path):
    return subprocess.run(['git', '-C', str(ROOT), 'show', BASE + ':' + path],
                          capture_output=True, check=True).stdout.decode()


def main():
    lib = original('scripts/lib_karta_sdachi.sh')
    pj = replace(original('scripts/pre_judge.sh'), 'while read -r ts name;', 'while read -r _ts name;')
    pj = replace(pj, 'local ts name role base n', 'local _ts name role base n')
    lib = replace(lib, '        karta_metadannye "$telo"',
                  '        telo="$(karta_tekst_bloha "$root" "$blob")" || { printf \'%s\' "$telo"; return 1; }\n'
                  '        karta_metadannye "$telo"')
    lib = replace(lib, '    local ryady\n    ryady="$(karta_stroki "$1")"',
                  '    local ryady telo="$1" blob\n'
                  '    if [ "$#" -eq 3 ]; then\n'
                  '        blob="$(git -C "$2" rev-parse "HEAD:$3")" || return 1\n'
                  '        telo="$(karta_tekst_bloha "$2" "$blob")" || { printf \'%s\' "$telo"; return 1; }\n'
                  '    fi\n    ryady="$(karta_stroki "$telo")"')
    lib += '\n# 232: policy is pinned to this installation, never the judged checkout.\n'
    lib += 'K232_SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"\n'
    lib += 'karta_tekst_bloha() { python3 -B "$K232_SCRIPTS/karta_registry.py" "$1" "$2"; }\n'
    gate = '''  # 232: every critic materialization, independent of decision/invocation.
  if [[ "$head_branch" == */critic || "$VREL" == */critic/* ]]; then
    map_scripts="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
    if ! map_out="$(bash "$map_scripts/check_verdict_karta.sh" "$R" "$VREL" 2>&1)"; then
      refuse KARTA_NE_SHTATNA "карта не штатная: $map_out"
    fi
  fi
'''
    pj = replace(pj, '  printf \'VERDICT_BRANCH=%s\\n\' "$head_branch"',
                 gate + '  printf \'VERDICT_BRANCH=%s\\n\' "$head_branch"')
    helper = (HERE / 'model/karta_registry.py').read_text()
    schema = (HERE / 'model/karta-exceptions.schema.json').read_text()
    raw = (HERE / 'live178.md').read_bytes()
    blob = hashlib.sha1(b'blob ' + str(len(raw)).encode() + b'\0' + raw).hexdigest()
    entry = dict(blob=blob, call='6', map=json.loads((HERE / 'normalized178.json').read_text()),
                 reason='Историческая карта 178, без изменения фактов; R-0168',
                 author='architect', date='2026-11-26', owner_ref='R-0168')
    policy = json.dumps(dict(version=1, exceptions=[entry]), ensure_ascii=False, indent=2) + '\n'
    outputs = {'model/lib_karta_sdachi.sh': lib, 'model/pre_judge.sh': pj,
               'model/karta_registry.py': helper, 'model/karta-exceptions.schema.json': schema,
               'model/karta-exceptions.json': policy}
    mutations = {}

    def mutation(name, file, text, cases):
        mutations[name] = (file, text, cases)

    mutation('st01-no-registry', 'karta_registry.py', replace(helper, 'if not POLICY.exists():',
             'if True:'), ['live-registered', 'config-add-only'])
    mutation('st02-hardcoded', 'karta_registry.py', replace(helper, "    entries = data['exceptions']",
             "    entries = data['exceptions'] or " + repr([entry])), ['live-empty', 'config-remove-only'])
    mutation('st03-prefix', 'karta_registry.py', replace(helper, "x['blob'] == blob",
             "x['blob'][:8] == blob[:8]"), ['foreign-sha-prefix'])
    mutation('st04-uppercase', 'karta_registry.py', replace(helper, "x['blob'] == blob",
             "x['blob'].lower() == blob.lower()"), ['uppercase-sha'])
    mutation('st05-no-identity', 'karta_registry.py', replace(helper, "x['blob'] == blob", "(x['blob'] == blob or 'в измеренных границах' in body)"),
             ['changed-blob', 'changed-other-path'])
    mutation('st06-schema-open', 'karta_registry.py', replace(helper, "    if p.returncode:\n        fail('schema/read: '",
             "    if False:\n        fail('schema/read: '"), ['prefix-sha', 'uppercase-sha', 'schema-missing', 'wrong-version'])
    mutation('st07-no-dedup', 'karta_registry.py', replace(helper, "if entry['blob'] in seen:",
             'if False:'), ['duplicate-sha'])
    mutation('st08-repaint', 'karta_registry.py', replace(helper,
             "if entry['map'] != normalize(body):", 'if False:'),
             ['repaint-block', 'repaint-reference', 'change-tail', 'change-reference-target'])
    mutation('st09-global-normalize', 'karta_registry.py', replace(helper,
             "        print(body, end='')\n        return 0\n    if entry['map']",
             "        print(body[:body.index('## Карта классов')] + '## Карта классов\\n' + '\\n'.join(normalize(body)))\n"
             "        return 0\n    if entry['map']"), ['live-empty', 'changed-blob'])
    mutation('st10-index-raw', 'lib_karta_sdachi.sh', replace(lib,
             '        telo="$(karta_tekst_bloha "$root" "$blob")" || { printf \'%s\' "$telo"; return 1; }\n', ''),
             ['index-call6', 'last-fail6'])
    mutation('st11-raw-current', 'lib_karta_sdachi.sh', replace(lib,
             '        telo="$(karta_tekst_bloha "$2" "$blob")" || { printf \'%s\' "$telo"; return 1; }', '        :'), ['live-registered'])
    mutation('st12-no-prejudge', 'pre_judge.sh', replace(pj, gate, ''), ['pj-invalid-accept', 'pj-invalid-fail'])
    mutation('st13-prejudge-weakened', 'pre_judge.sh', replace(pj,
             '      refuse KARTA_NE_SHTATNA "карта не штатная: $map_out"', '      :'), ['pj-invalid-fail'])
    mutation('st14-only-accept', 'pre_judge.sh', replace(pj,
             '    if ! map_out=', '    if [ "$(git -C "$R" show "HEAD:$VREL" | head -n 1)" = accept ] && ! map_out='),
             ['pj-invalid-fail'])
    mutation('st15-only-first', 'pre_judge.sh', replace(pj,
             '    if ! map_out=', '    if git -C "$R" show "HEAD:$VREL" | grep -q "вызов=1;" && ! map_out='),
             ['pj-invalid-call2'])
    mutation('st16-wrong-install', 'pre_judge.sh', replace(pj,
             '"$map_scripts/check_verdict_karta.sh"', '"$R/scripts/check_verdict_karta.sh"'),
             ['pj-local-fake'])
    mutation('st17-call-repaint', 'karta_registry.py', replace(helper,
             "if current and str(int(current[1])) != entry['call']:", 'if False:'), ['change-call'])
    mutation('st18-registry-from-subject', 'karta_registry.py', replace(helper,
             "    body = git(root, 'cat-file', '-p', blob)",
             "    global POLICY\n    POLICY = Path(root) / 'registry/karta-exceptions.json'\n"
             "    body = git(root, 'cat-file', '-p', blob)"), ['config-add-only', 'subject-policy-bait'])
    mutation('st19-flag-bypass', 'pre_judge.sh', replace(pj,
             '    --file) ', '    --skip-karta) printf \'VERDICT_BRANCH=wip/777/critic\\n\'; exit 0 ;;\n    --file) '),
             ['pj-no-skip-flag'])
    mutation('st20-role-bypass', 'pre_judge.sh', replace(pj,
             '"$head_branch" == */critic || "$VREL" == */critic/*', '"$head_branch" == */critic'),
             ['pj-role-bypass'])
    mutation('st21-hardcoded-tail', 'lib_karta_sdachi.sh', replace(lib,
             r'([.]|\ —\ .+)?$', r'([.]|\ —\ .+|,\ кроме\ .+|;\ .+)?$', 2),
             ['unregistered-comma', 'unregistered-semicolon'])
    mutation('st22-no-json-dedup', 'karta_registry.py', replace(helper,
             'object_pairs_hook=pairs', 'object_pairs_hook=dict'), ['duplicate-json-key'])
    mutation('st23-hardcoded-key', 'karta_registry.py', replace(helper, "x['blob'] == blob",
             "x['blob'] == blob and blob == " + repr(blob)), ['config-new-blob-only'])
    mutation('st24-hardcoded-map', 'karta_registry.py', replace(helper,
             '    return result', '    return ' + repr(entry['map'])), ['config-new-map-only'])
    # Schema case weakening must accompany the identity mutation to expose the
    # actual acceptance path; otherwise the grammar rejects before comparison.
    weakened = json.loads(schema)
    weakened['properties']['exceptions']['items']['properties']['blob']['pattern'] = '^[0-9a-fA-F]{40}$'
    outputs['stabs/st04-uppercase/karta-exceptions.schema.json'] = json.dumps(weakened)
    old = HERE / 'stabs'
    if old.exists():
        shutil.rmtree(old)
    links = []
    for name, (file, text, cases) in mutations.items():
        outputs['stabs/' + name + '/' + file] = text
        for case in cases:
            links.append(dict(stab=name, case=case))
    hashes = {}
    for path, text in outputs.items():
        p = HERE / path
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text)
        hashes[path] = hashlib.sha256(text.encode()).hexdigest()
    for path in ('live178.md', 'normalized178.json'):
        hashes[path] = hashlib.sha256((HERE / path).read_bytes()).hexdigest()
    source = dict(base=BASE, sha256=hashes, stab_vhod=links, live_git_blob=blob,
                  live_sha256=hashes['live178.md'], old=dict(cells=69, stabs=10, links=33))
    (HERE / 'source.json').write_text(json.dumps(source, ensure_ascii=False, indent=2) + '\n')
    (HERE / 'stabs.tsv').write_text(''.join(x['stab'] + '\t' + x['case'] + '\n' for x in links))
    print('STABY', len(mutations), 'SVJAZI', len(links), 'LIVE_GIT_BLOB', blob)


if __name__ == '__main__':
    main()
