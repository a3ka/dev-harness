#!/usr/bin/env python3
"""Read highest frozen blobs, emit the actual 224 overlap declaration (no edits)."""
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OWN = [('architect', 'contracts/224-svezhest-verdikta-done.md'),
       ('architect', 'fixtures/workshop_project/svezhest_verdikta_done_224/'),
       ('implementer', 'scripts/done_contract.sh'),
       ('orchestrator', 'registry/ci-steps.tsv'),
       ('orchestrator', 'registry/ci-zamery.tsv'),
       ('orchestrator', '.github/workflows/ci.yml')]


def git(*args):
    return subprocess.run(['git', '-C', str(ROOT), *args], capture_output=True, text=True, check=True).stdout.strip()


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
            raise RuntimeError('frozen contract path ambiguous: ' + tag)
        file = files[0]
        text = git('show', tag + '^{commit}:' + file)
        zone_lines = [line for line in text.splitlines() if line.startswith('ЗОНА ')]
        matched = []
        for line in zone_lines:
            match = re.fullmatch(r'ЗОНА ([^:]+): (.+)', line)
            if not match:
                continue
            author, paths = match.groups()
            for old in paths.split():
                for own_author, own in OWN:
                    overlap = old == own or (old.endswith('/') and own.startswith(old)) or (own.endswith('/') and old.startswith(own))
                    if overlap and (author != own_author or own == 'scripts/done_contract.sh'):
                        reason = 'только свой шаг/замер 224; чужие строки и поведение сохраняются'
                        if own_author == 'architect':
                            reason = 'только контракт/новая семья 224; прежние продуктовые семьи сохраняются'
                        if own_author == 'implementer':
                            reason = 'только порядок кругов; frozen/OBJECT, fail-closed и остальные гейты сохраняются'
                        declarations.add(f'ПЕРЕСЕЧЕНИЕ {own_author}: {own} — {n} {reason}')
                        matched.append(line)
        if matched:
            print('ИСТОЧНИК', tag, git('rev-parse', tag + '^{commit}'), file)
            print('\n'.join(sorted(set(matched))))
            if n in ('038', '201'):
                for line in text.splitlines():
                    if any(term in line for term in ('свеж', 'OBJECT-', 'коммит-истор', 'по коммит', 'ПРОВОДКА через')):
                        print('ОБЯЗАТЕЛЬСТВО', line)
    if not declarations:
        raise RuntimeError('empty overlap census')
    print('\nДЕКЛАРАЦИИ', len(declarations))
    print('\n'.join(sorted(declarations)))


if __name__ == '__main__':
    main()
