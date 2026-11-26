#!/usr/bin/env python3
"""224 precedent: highest frozen blobs, actual zones, deduplicated intersections."""
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OWN = [('architect', 'contracts/227-sh5f-zashivki-otchet.md'),
       ('architect', 'fixtures/workshop_project/zashivki_otchet_227/'),
       ('implementer', 'scripts/report_zashivki.sh'), ('implementer', 'config/zashivki.json'),
       ('orchestrator', 'registry/ci-steps.tsv'), ('orchestrator', 'registry/ci-zamery.tsv'),
       ('orchestrator', '.github/workflows/ci.yml')]


def git(*args):
    return subprocess.run(['git', '-C', str(ROOT), *args], capture_output=True,
                          text=True, check=True).stdout.strip()


def main():
    tags = {}
    for ref in git('for-each-ref', '--format=%(refname:short)', 'refs/tags/frozen/contracts/').splitlines():
        match = re.fullmatch(r'frozen/contracts/([0-9]{3})/([0-9]+)', ref)
        if match:
            n, v = match.groups()
            if n not in tags or int(v) > tags[n][0]:
                tags[n] = int(v), ref
    declarations = set()
    for n, (_, tag) in sorted(tags.items()):
        files = [p for p in git('ls-tree', '-r', '--name-only', tag, '--', 'contracts/').splitlines()
                 if re.fullmatch('contracts/' + n + r'-[^/]+\.md', p)]
        if len(files) != 1:
            raise RuntimeError('FROZEN_PATH_AMBIGUOUS: ' + tag)
        text = git('show', tag + '^{commit}:' + files[0])
        evidence = []
        for line in text.splitlines():
            match = re.fullmatch(r'ЗОНА ([^:]+): (.+)', line)
            if not match:
                continue
            author, paths = match.groups()
            for old in paths.split():
                for role, path in OWN:
                    overlap = old == path or (old.endswith('/') and path.startswith(old)) or (path.endswith('/') and old.startswith(path))
                    if overlap and author != role:
                        reason = 'только свой отчёт/шаг/замер 227; чужие обязательства сохраняются'
                        if role == 'architect':
                            reason = 'только страница и новая семья 227; старые семьи не меняются'
                        declarations.add(f'ПЕРЕСЕЧЕНИЕ {role}: {path} — {n} {reason}')
                        evidence.append(line)
        if evidence:
            print('ИСТОЧНИК', tag, git('rev-parse', tag + '^{commit}'), files[0])
            print('\n'.join(sorted(set(evidence))))
    if not tags or not declarations:
        raise RuntimeError('EMPTY_CENSUS')
    print('ДЕКЛАРАЦИИ', len(declarations))
    print('\n'.join(sorted(declarations)))


if __name__ == '__main__':
    main()
