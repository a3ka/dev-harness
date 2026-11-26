#!/usr/bin/env python3
"""232: highest live frozen zones and normative evidence, never edit frozen files."""
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OWN = [('architect', 'contracts/232-gramm-karta-krome.md'),
       ('architect', 'fixtures/workshop_project/karta_krome_232/'),
       ('implementer', 'scripts/lib_karta_sdachi.sh'),
       ('implementer', 'scripts/check_verdict_karta.sh'),
       ('implementer', 'scripts/pre_judge.sh'),
       ('implementer', 'scripts/karta_registry.py'),
       ('implementer', 'registry/karta-exceptions.json'),
       ('implementer', 'registry/karta-exceptions.schema.json'),
       ('orchestrator', 'registry/ci-steps.tsv'),
       ('orchestrator', 'registry/ci-zamery.tsv'),
       ('orchestrator', '.github/workflows/ci.yml')]


def git(*args):
    return subprocess.run(['git', '-C', str(ROOT), *args], check=True,
                          capture_output=True, text=True).stdout.strip()


def declarations(verbose=False):
    tags = {}
    for ref in git('for-each-ref', '--format=%(refname:short)', 'refs/tags/frozen/contracts/').splitlines():
        m = re.fullmatch(r'frozen/contracts/([0-9]{3})/([0-9]+)', ref)
        if m and (m[1] not in tags or int(m[2]) > tags[m[1]][0]):
            tags[m[1]] = int(m[2]), ref
    result = set()
    for n, (_, tag) in sorted(tags.items()):
        paths = [p for p in git('ls-tree', '-r', '--name-only', tag, '--', 'contracts/').splitlines()
                 if re.fullmatch('contracts/' + n + r'-[^/]+\.md', p)]
        if len(paths) != 1:
            raise RuntimeError('AMBIGUOUS_FROZEN_PATH: ' + tag)
        text = git('show', tag + '^{commit}:' + paths[0])
        hits = []
        for line_no, line in enumerate(text.splitlines(), 1):
            m = re.fullmatch(r'ЗОНА ([^:]+): (.+)', line)
            if not m:
                continue
            for old in m[2].split():
                for author, own in OWN:
                    overlap = old == own or (old.endswith('/') and own.startswith(old)) or (own.endswith('/') and old.startswith(own))
                    if overlap and (m[1] != author or author == 'implementer'):
                        reason = ('только реестр исторических карт и обязательная дверь materialization; прочие обязательства сохраняются'
                                  if author == 'implementer' else 'только своя семья и шаг 232; чужие строки сохраняются')
                        result.add(f'ПЕРЕСЕЧЕНИЕ {author}: {own} — {n} {reason}')
                        hits.append(f'{paths[0]}:{line_no}: {line}')
        if verbose and hits:
            print('ИСТОЧНИК', tag, git('rev-parse', tag + '^{commit}'))
            print('\n'.join(sorted(set(hits))))
        if verbose and n == '193':
            for no, line in enumerate(text.splitlines(), 1):
                if 115 <= no <= 126:
                    print('ОБЯЗАТЕЛЬСТВО', paths[0] + ':' + str(no), line)
    if not result:
        raise RuntimeError('EMPTY_CENSUS')
    return sorted(result)


if __name__ == '__main__':
    lines = declarations(True)
    if '--write' in sys.argv:
        contract = ROOT / 'contracts/232-gramm-karta-krome.md'
        text = contract.read_text()
        start = '<!-- BEGIN FROZEN CENSUS -->'
        end = '<!-- END FROZEN CENSUS -->'
        before, rest = text.split(start)
        _, after = rest.split(end)
        contract.write_text(before + start + '\n' + '\n'.join(lines) + '\n' + end + after)
    print('ДЕКЛАРАЦИИ', len(lines))
    print('\n'.join(lines))
